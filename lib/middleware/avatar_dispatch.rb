require 'new_relic/agent/method_tracer'

class AvatarDispatch

  BASE_SIZES    = Array.new(9){ |n| 2 ** (n + 1) }.last(7)
  SPECIAL_SIZES = [24,40,50,70,200]
  ALLOWED_SIZES = (BASE_SIZES + SPECIAL_SIZES).uniq.sort
  PATH_MATCH    = /\/((?<model>user|app|cloud)\/((?<md5>[0-9a-f]{32})|(?<bson>[0-9a-fA-F]{24}))|(?<handle>[a-zA-Z0-9\_]{1,20}))\.(?<format>png)/
  DOMAIN_MATCH  = /^(avatar)\..*$/
  REDIS_EXPIRE   = 12.hours

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env.deep_dup)
    if DOMAIN_MATCH.match(request.host)
      if path_match = PATH_MATCH.match(request.path)
        transaction(env, request, path_match)
      else
        [ 204,
          {
            "MIME-Version"   => "1.0",
            "Content-Type"   => "text/plain",
            "Content-Length" => "0"
          }, [""]
        ]
      end
    else
      @app.call(env)
    end

  end

  def transaction(env, request, path_match, record: nil)
    options = Hash.new

    if path_match[:handle]
      record          = Handle.lookup!(path_match[:handle])
      options[:model] = record.class.to_s.downcase.to_sym
      options[:type]  = :id
      options[:id]    = record.id
    elsif path_match[:md5]
      options[:type]  = :email_hash
      options[:id]    = path_match[:md5]
    elsif path_match[:bson]
      options[:type]  = :id
      options[:id]    = path_match[:bson]
    end

    options[:model] ||= path_match[:model].to_sym
    options[:size]  = request.params["s"].try(:to_i) || 256

    file_path, timestamp = ALLOWED_SIZES.include?(options[:size]) ? resolve_file(options, record: record) : nil

    remote_ip = env["REMOTE_ADDR"] || env["HTTP_X_REAL_IP"] || env["HTTP_X_FORWARDED_FOR"]
    Rails.logger.debug("Started GET \"#{env['REQUEST_URI']}\" for #{remote_ip} at #{Time.now}")

    etag = ['avatar', options[:model], options[:id], options[:size], timestamp.utc.to_s(:number)].join("-")

    if etag == env['ETAG']
      [ 304,
        {
          "ETag"           => etag,
          "Cache-Control"  => "public, max-age=31536000",
          "MIME-Version"   => "1.0",
          "Content-Type"   => "image/png",
          "Content-Length" => "0"
        }, [""]
      ]
    else
      image = file_path.present? ? proccess(file_path, options[:size]) : nil

      if image
        file = File.read(image.path)
        [ 200,
          {
            "ETag"           => etag,
            "Cache-Control"  => "public, max-age=31536000",
            "Last-Modified"  => timestamp.httpdate,
            "MIME-Version"   => "1.0",
            "Content-Type"   => "image/png",
            "Content-Length" => StringIO.new(file).size.to_s
          }, [file]
        ]
      else
        [ 404,
          {
            "MIME-Version"   => "1.0",
            "Content-Type"   => "text/plain",
            "Content-Length" => "0"
          }, [""]
        ]
      end
    end

  end

private

  def resolve_file(options, record: nil)

    path_query  = "cloudsdale:avatar:#{options[:model]}:#{options[:id]}:path"
    time_query  = "cloudsdale:avatar:#{options[:model]}:#{options[:id]}:timestamp"

    file_path   = $redis.get(path_query).try(:to_s) || ""
    timestamp   = $redis.get(time_query).try(:to_i) || 0

    if file_path.empty? or timestamp.zero?

      record ||= scope(options).where(options[:type] => options[:id]).first unless record

      fallback_path = file_path = Rails.root.join(
        'app', 'assets', 'images', 'fallback', 'avatar', "#{options[:model]}.png"
      ).to_s

      if record
        file_path = record[:avatar].present? ? record.avatar.full_file_path : fallback_path
        timestamp = record.avatar_uploaded.to_i
      else
        file_path = fallback_path
        timestamp = File.mtime(file_path).to_i
      end

      $redis.set(time_query, timestamp)
      $redis.set(path_query, file_path)
      $redis.expire(time_query,REDIS_EXPIRE)
      $redis.expire(path_query,REDIS_EXPIRE)

    end

    return file_path, Time.at(timestamp).to_datetime
  end

  def scope(options)
    @scope = case options[:model].to_sym
      when :user  then User
      when :cloud then Cloud
      when :app   then Doorkeeper::Application
    end
  end

  def proccess(file_path, size)

    width   = size.to_i
    height  = size.to_i

    image   = MiniMagick::Image.open(file_path)

    cols, rows = image[:dimensions]

    image.format "png"

    image.combine_options do |cmd|

      if width != cols || height != rows

        scale_x = width.to_f  / cols.to_f
        scale_y = height.to_f / rows.to_f

        if scale_x >= scale_y
          cols = (scale_x * (cols + 0.5)).round
          rows = (scale_x * (rows + 0.5)).round
          cmd.resize "#{cols}"
        else
          cols = (scale_y * (cols + 0.5)).round
          rows = (scale_y * (rows + 0.5)).round
          cmd.resize "x#{rows}"
        end

      end

      cmd.gravity 'Center'
      cmd.background "rgba(255,255,255,1.0)"
      cmd.extent "#{width}x#{height}" if cols != width || rows != height

    end

    return image

  rescue MiniMagick::Error, MiniMagick::Invalid => e
    nil
  end

  # NewRelic Metric collection
  if defined?(NewRelic::Agent::Instrumentation::ControllerInstrumentation)
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation
    add_transaction_tracer(:transaction)
  end

  if defined?(NewRelic::Agent::MethodTracer)
    include NewRelic::Agent::MethodTracer
    add_method_tracer(:proccess, 'Custom/Image/process')
    add_method_tracer(:resolve_file, 'Custom/Image/resolve')
  end

end
