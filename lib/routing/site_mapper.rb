module ActionDispatch::Routing
  class Mapper
    def site(name, options = {}, &block)
      subdomain = options[:subdomain] || name.to_s

      constraints subdomain: /(#{subdomain})/ do
        scope(name.to_sym, module: name.to_sym, path: '/', &block)
      end

    end
  end
end
