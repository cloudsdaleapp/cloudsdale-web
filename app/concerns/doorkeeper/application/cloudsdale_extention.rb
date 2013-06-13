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
      field :official,        type: Boolean,    default: false
      field :main_app,        type: Boolean,    default: false

      validates :website,
                :url => true,
                :presence => true

      validates :description,
                :length => {
                  :within => 0..500
                },
                :presence => true

    end

    def main_app=(value=nil)
      if value == true && !new_record?
        Doorkeeper::Application.where(
          :main_app => true,
          :id.nin => [self.id]
        ).set(:main_app,false)
        self.set(:main_app,true)
        self.set(:official,true)
      end
      super(value)
    end

    module ClassMethods

      # Public: Returns the correct policy class for
      # the doorkeeper application. This is an absolute
      # neccessity because of name collisions and nested
      # models.
      def policy_class
        "Doorkeeper::ApplicationPolicy"
      end

      # Public: Used by the avatar uploader to determine
      # the avatar path. Usually defaults to the image class
      # downcased. But in this case we need to specify it
      # further.
      #
      # Returns a string.
      def avatar_namespace
        "app"
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
