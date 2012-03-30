class ApiVersion
  def initialize(options)
    @version = options[:version]
  end

  def matches?(request)
    accept = request.headers['Accept']
    if accept && accept[/application\/vnd\.cloudsdale-v#{@version}/]
      request.headers['Accept'][/vnd\.cloudsdale-v#{@version}\+?/] = ''
      true
    else
      false
    end
  end

end

module ActionDispatch::Routing
  class Mapper
    def api(options = {}, &block)
      v = 'v' + options[:version].to_s
      constraints subdomain: /api|api\.local/i do
        scope module: :api do
          namespace v, &block
          scope module: v, constraints: ApiVersion.new(options), &block
        end
      end
    end
  end
end