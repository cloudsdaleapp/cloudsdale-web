module ActionDispatch::Routing
  class Mapper
    def api(options = {}, &block)
      version   = 'v' + options[:version].to_s
      subdomain = options[:subdomain] || 'api'

      constraints subdomain: subdomain do
        scope(module: :api) do
          namespace(version, &block)
        end
      end
    end
  end
end
