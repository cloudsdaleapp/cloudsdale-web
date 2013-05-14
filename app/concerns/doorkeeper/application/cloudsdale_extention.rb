class Doorkeeper::Application

  module CloudsdaleExtention

    extend ActiveSupport::Concern

    included do

      # Concerns
      include ActiveModel::Avatars

      attr_accessible :website, :description,
      :terms_of_use, :privacy_policy

      field :website,         type: String
      field :description,     type: String
      field :terms_of_use,    type: String
      field :privacy_policy,  type: String

      validates :website,
                :url => true,
                :allow_blank => true

      validates :description,
                :length => {
                  :within => 0..500
                },
                :allow_blank => true

    end

    module ClassMethods

      # Public: Returns the correct policy class for
      # the doorkeeper application. This is an absolute
      # neccessity because of name collisions and nested
      # models.
      def policy_class
        "Doorkeeper::ApplicationPolicy"
      end

    end

    # Public: Transforms privacy policy to html
    # from markdown using Redcarpet.
    #
    # Returns a html safe string.
    def formatted_privacy_policy
      Redcarpet::Markdown.new(
        Redcarpet::Render::HTML,REDCARPET_HTML_DEFAULTS
      ).render(self.privacy_policy).html_safe
    end

    # Public: Transforms terms of use to html
    # from markdown using Redcarpet.
    #
    # Returns a html safe string.
    def formatted_terms_of_use
      Redcarpet::Markdown.new(
        Redcarpet::Render::HTML,REDCARPET_HTML_DEFAULTS
      ).render(self.terms_of_use).html_safe
    end

    # Public: Extracts the domain name from
    # the website url.
    #
    # Returns a html safe string.
    def formatted_website
      self.website.split('/')[2]
    end

  end

end
