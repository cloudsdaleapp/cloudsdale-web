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
          when :https  then Cloudsdale.config['avatar']['https']
          when :ssl    then Cloudsdale.config['avatar']['https']
          else Cloudsdale.config['avatar']['http']
          end

    size = !size.nil? ? "?s=#{size}" : ""

    "#{url}/user/#{avatar_id}.png#{size}"
  end

end
