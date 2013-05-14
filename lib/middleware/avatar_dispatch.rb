class AvatarDispatch

  BASE_SIZES    = Array.new(10){ |n| 2 ** (n + 1) }
  SPECIAL_SIZES = [24,40,50,70,200]
  ALLOWED_SIZES = (BASE_SIZES + SPECIAL_SIZES).uniq.sort
  PATH_MATCH    = /\/(?<model>user|app|cloud)\/((?<md5>[0-9a-f]{32})|(?<bson>[0-9a-fA-F]{24}))\.(?<format>png)/
  DOMAIN_MATCH  = /^(avatar)\..*$/
  TIMESTAMP      = DateTime.parse("2012-01-01").to_i
  HTTP_TIMESTAMP = DateTime.parse("2012-01-01").httpdate

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env.deep_dup)
    if DOMAIN_MATCH.match(request.host)
      if path_match = PATH_MATCH.match(request.path)

        options = Hash.new

        if path_match[:md5]
          options[:type]  = :email_hash
          options[:id]    = path_match[:md5]
        elsif path_match[:bson]
          options[:type]  = :id
          options[:id]    = path_match[:bson]
        end

        options[:model] = path_match[:model].to_sym
        options[:size]  = request.params["s"].try(:to_i) || 256

        file_path, timestamp = ALLOWED_SIZES.include?(options[:size]) ? resolve_file(options) : nil

        image = file_path.present? ? proccess(file_path, options[:size]) : nil

        if image
          file = File.read(image.path)
          [ 200,
            {
              "Last-Modified"  => timestamp.httpdate,
              "MIME-Version"   => "1.0",
              "Content-Type"   => "image/png",
              "Content-Length" => StringIO.new(file).size.to_s
            }, [file]
          ]
        else
          [ 404,
            {
              "Last-Modified"  => HTTP_TIMESTAMP,
              "MIME-Version"   => "1.0",
              "Content-Type"   => "text/plain",
              "Content-Length" => "0"
            }, [""]
          ]
        end

      else
        [ 204,
          {
            "Last-Modified"  => HTTP_TIMESTAMP,
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

private

  def resolve_file(options)

    path_query  = "cloudsdale:avatar:#{options[:model]}:#{options[:id]}"
    time_query  = "cloudsdale:avatar:#{options[:model]}:#{options[:id]}:timestamp"

    file_path   = Cloudsdale.redisClient.get(path_query).try(:to_s) || nil
    timestamp   = Cloudsdale.redisClient.get(time_query).try(:to_i) || TIMESTAMP

    unless file_path

      record    = scope(options).where(
                    options[:type] => options[:id]
                  ).first

      if record.present? && record.avatar.present?
        timestamp = record.avatar_uploaded_at.to_i
        file_path = record.full_file_path
      else
        timestamp = TIMESTAMP
        file_path = Rails.root.join(
          'app', 'assets', 'images', 'fallback', 'avatar', "#{options[:model]}.png"
        ).to_s
      end

      Cloudsdale.redisClient.set(time_query,timestamp)
      Cloudsdale.redisClient.set(path_query,file_path)

    end

    return file_path, Time.at(timestamp).to_datetime
  end

  def scope(options)
    @scope ||= case options[:model]
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

end
