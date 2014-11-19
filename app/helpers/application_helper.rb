module ApplicationHelper

  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    result = block.call
    self.formats = old_formats
    result
  end

  def page_title; @page_title || "Cloudsdale"; end

  def page_image
    @page_image || image_path('icon/icon_avatar_color.png')
  end

  def page_url
    @page_url || "http://www.cloudsdale.org"
  end

  def page_type
    @page_type || "website"
  end

  def page_description
    @page_description || "Connect in Realtime. Meet new Friends."
  end

  def page_keywords
    @page_keywords || "Cloudsdale, MLP, MLP:FiM, FiM, My Little Pony,
    My Little Pony: Friendship is Magic, Friendship is Magic, Social Network,
    chat, web, app, desktop, mobile, Android, iOS, Windows Phone 7, Ruby On Rails,
    HTML5, CSS3, Javascript, Equestria, Cloud, raindrop, drop, pony, brony,
    Twilight Sparkle, Pinkie Pie, Fluttershy, Rarity, Applejack, Rainbow Dash,
    Zeeraw, Lisinge, Berwyn, Zimber Fuzz, Manearion, Xtux, Shansai, Aethe,
    Connorcpu, fansite, Nginx, Hammock, Equestria Gaming, My Little Game Dev".strip.chomp
  end

  def user_avatar_url(avatar_id, size = 256, schema = :http)
    url = case schema
          when :https then Figaro.env.avatar_https!
          when :ssl then Figaro.env.avatar_https!
          else Figaro.env.avatar_http!
          end

    size = !size.nil? ? "?s=#{size}" : ""

    "#{url}/user/#{avatar_id}.png#{size}"
  end

  def social_button_for(media_type,url,text=nil)
    case media_type.to_sym
    when :facebook
      content_tag(:span, "", :class => 'fb-like', data: { font: 'arial', href: url, layout: :button_count, send: false, 'show-faces' => false, width: 'auto' }).html_safe
    when :google
      content_tag(:span, "", :class => 'g-plusone', data: { size: 'medium', href: url } ).html_safe
    when :twitter
      text      ||= "Check out @cloudsdaleapp it's a pretty cool place"
      style     = 'line-height: 20px; height: 20px; font-size: 12px;'
      css_class = 'twitter-share-button'
      html_data = { text: text, url: url }
      content_tag(:a, "Tweet",:class => css_class, style: style, data: html_data, href: "https://twitter.com/share" ).html_safe
    when :flattr
      content_tag(:a, "",:class => 'FlattrButton', href: url, style: "display:none;", rev: "flattr;button:compact;" ).html_safe
    end
  end

end
