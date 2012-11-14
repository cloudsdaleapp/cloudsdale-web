module ApplicationHelper

  def current_tab(expected_tab=:default)
    params[:tab] == expected_tab
  end

  # Takes the flash key value and uses it to
  # determine which alert class to be used
  def to_type(flash_key)
    case flash_key.to_sym
      when :alert
        "alert-warning"
      when :error
        "alert-error"
      when :notice
        "alert-info"
      when :success
        "alert-success"
      else
        flash_key.to_s
    end
  end

  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    result = block.call
    self.formats = old_formats
    result
  end

  def page_title; @page_title || "Cloudsdale"; end

  def page_image
    @page_image || Rails.env.development? ? (Cloudsdale.config['url'] + image_path('logo/main_logo.png')) : image_path('logo/main_logo.png')
  end

  def page_url
    @page_url || "http://www.cloudsdale.org"
  end

  def page_type
    @page_type || "website"
  end

  def page_description
    @page_description || "Cloudsdale, the best place in the sky. A fast,
    reliable and beautiful chat app exclusively for bronies."
  end

  def page_keywords
    @page_keywords || "Cloudsdale, MLP, MLP:FiM, FiM, My Little Pony,
    My Little Pony: Friendship is Magic, Friendship is Magic, Social Network,
    chat, web, app, desktop, mobile, Android, iOS, Windows Phone 7, Ruby On Rails,
    HTML5, CSS3, Javascript, Equestria, Cloud, raindrop, drop, pony, brony,
    Twilight Sparkle, Pinkie Pie, Fluttershy, Rarity, Applejack, Rainbow Dash,
    Zeeraw, Lisinge, Berwyn, Zimber Fuzz, Manearion, Xtux, Shansai, Aethe,
    Connorcpu, fansite, Nginx"
  end

end
