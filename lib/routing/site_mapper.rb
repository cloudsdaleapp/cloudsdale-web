module ActionDispatch::Routing
  class Mapper
    def site(name, options = {}, &block)
      subdomain = options[:subdomain] || 'www'

      constraints subdomain: /(#{subdomain}|#{name})/ do
        namespace(name.to_sym, module: name.to_sym, path: '/', &block)
      end

    end
  end
end
