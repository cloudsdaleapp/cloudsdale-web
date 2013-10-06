# encoding: utf-8

class Api::V2::RootController < Api::V2Controller

  def index
    resp = {
      api: {
        version: 2,
        description:    "Cloudsdale Chat API",
        copyright:      "© IOMUSE 2012 – 2013",
        links: [
          {
            title: 'Cloudsdale',
            rel: 'website',
            href: root_url(subdomain: "www")
          },
          {
            title: 'Cloudsdale Terms of Service',
            rel: 'terms_of_use',
            href: page_url("terms-and-conditions", subdomain: "www")
          },
          {
            title: 'Cloudsdale Privacy Policy',
            rel: 'privacy_policy',
            href: page_url("privacy-policy",subdomain: "www")
          },
            title: 'Cloudsdale Developer Portal',
            rel: 'developers',
            href: root_url(subdomain: 'dev')
        ],
        refs: [
          {
            rel: 'me',
            href: v2_me_url(format: :json, host: $api_host)
          },
          {
            rel: 'me_auth_token',
            href: v2_auth_token_url(format: :json, host: $api_host)
          },
          {
            rel: 'me_session',
            href: v2_session_url(format: :json, host: $api_host)
          },
          {
            rel: 'convo',
            href: URI.unescape(v2_convo_url("{topic}",format: :json, host: $api_host))
          },
          {
            rel: 'convo_messages',
            href: URI.unescape(v2_convo_messages_url("{topic}",format: :json, host: $api_host))
          },
          {
            rel: 'cloud',
            href: URI.unescape(v2_cloud_url("{handle}", format: :json, host: $api_host))
          },
          {
            rel: 'clouds',
            href: URI.unescape(v2_clouds_url(format: :json, host: $api_host)) + "{?ids,id}"
          },
          {
            rel: 'search_clouds',
            href: URI.unescape(search_v2_clouds_url(format: :json, host: $api_host)) + "?query={keywords}"
          },
          {
            rel: 'user',
            href: URI.unescape(v2_user_url("{handle}", format: :json, host: $api_host))
          },
          {
            rel: 'users',
            href: URI.unescape(v2_users_url(format: :json, host: $api_host)) + "{?ids,id}"
          },
          {
            rel: 'search_users',
            href: URI.unescape(search_v2_users_url(format: :json, host: $api_host)) + "?query={keywords}"
          },
          {
            rel: 'spotlights',
            href: URI.unescape(v2_spotlights_url(format: :json, host: $api_host)) + "{?category}"
          },
          {
            rel: 'avatar',
            href: URI.unescape(avatar_url("{handle}", format: :png, host: $settings[:avatar][:https].gsub(/^(https?\:\/\/)/i,''), protocol: "https:"))
          }
        ]
      }
    }

    respond_with resp, status: 200
  end

  def lookup
    @record = Handle.lookup(params[:handle])
    @serializer = "#{@record.class.name}Serializer".constantize
    @root = @record.class.name.underscore
    respond_with_resource(@record, root: @root, serializer: @serializer)
  end

  def not_found
    render_exception("Resource could not be found. Are you sure this is what you're looking for?", 404)
  end

end
