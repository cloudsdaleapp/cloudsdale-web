class AvatarDispatch

  PATH_MATCH   = /\/(?<model>user|app|cloud)\/((?<md5>[0-9a-f]{32})|(?<bson>[0-9a-fA-F]{24}))\.(?<format>png)/
  DOMAIN_MATCH = /^(avatar)\..*$/

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
        options[:size]  = request.params["s"].try(:to_i) || 100
        options[:size]  = 200 if options[:size] > 200

        file_path = resolve_file(options)
        unless Rails.env.production?
          file_path = Rails.root.join('public',file_path.gsub(/^\//,"")).to_s
        end

        image = proccess(file_path, options[:size])

        if image
          f = File.read(image.path)
          [ 200,
            {
              "Content-Type"   => "image/png",
              "Content-Length" => f.length.to_s
            }, [f]
          ]
        else
          [ 404,
            {
              "Content-Type"   => "image/png",
              "Content-Length" => "0"
            }, [nil]
          ]
        end

      else
        @app.call(env)
      end

    else
      @app.call(env)
    end

  end

private

  def resolve_file(options)
    record = scope(options).where(options[:type] => options[:id]).first
    record.avatar.url
  end

  def scope(options)
    @scope ||= case options[:model]
      when :user  then User
      when :cloud then Cloud
      when :app   then Doorkeeper::Application
    end
  end

  def proccess(file_path, size)

    width   = size
    height  = size

    image   = MiniMagick::Image.open(file_path)

    image.format "png"

    cols, rows = image[:dimensions]

    image.combine_options do |cmd|

      if width != cols || height != rows

        scale_x = width  / cols.to_f
        scale_y = height / rows.to_f

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
      cmd.background "rgba(255,255,255,0.0)"
      cmd.extent "#{width}x#{height}" if cols != width || rows != height

    end

    return image

  rescue MiniMagick::Error, MiniMagick::Invalid => e
    nil
  end

end
