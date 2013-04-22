class Dispatch

  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :subject, :body, :published_at
  attr_accessible :banner, :remove_banner, :remote_banner_url

  field :subject,       type: String
  field :body,          type: String
  field :published_at,  type: DateTime

  mount_uploader :banner, EmailBannerUploader

  def formatted_body
    Redcarpet::Markdown.new(Redcarpet::Render::HTML,REDCARPET_HTML_DEFAULTS).render(self.body).html_safe
  end

  def unformatted_body
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown,REDCARPET_DEFAULTS).render(self.body).html_safe
  end

  def status
    if published_at.nil?
      return :draft
    else
      return :sent
    end
  end

end
