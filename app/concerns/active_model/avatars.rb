module ActiveModel

  module Avatars

    extend ActiveSupport::Concern

    included do

      attr_accessible :avatar, :remote_avatar_url, :remove_avatar

      field :avatar_uploaded_at,   type: DateTime

      mount_uploader :avatar, AvatarUploader

      before_save :set_avatar_uploaded_at!

      def avatar_uploaded_at
        self[:avatar_uploaded_at] || self.updated_at
      end

    end

    # Public: Fetches the URL's for the avatar versions
    #
    # args - A hash of arguments of what to do with the avatar versions.
    #
    #   :except - Array of the version keys to be omitted from the hash
    #
    #   :only   - An array of specific keys you want to include.
    #             will be overridden by any values from except.
    #
    # Examples
    #
    # @user.avatar_versions([:normal,:mini,:thumb,:preview])
    # # => { chat: "http://..." }
    #
    # Returns a hash of keys pointing at url values.
    def avatar_versions(args={})

      args = { except: [], only: nil }.merge(args)

      allowed_keys = [:normal,:thumb,:mini,:preview,:chat]

      allowed_keys.select! { |value| args[:only].include? value } if args[:only]
      allowed_keys -= args[:except]

      {
        normal:  dynamic_avatar_url(200),
        mini:    dynamic_avatar_url(24),
        thumb:   dynamic_avatar_url(50),
        preview: dynamic_avatar_url(70),
        chat:    dynamic_avatar_url(40)

      }.delete_if do |key,value|

        !allowed_keys.include? key

      end

    end

    # Public: Generates the new type of avatar URL on demand
    #
    # Returns the full image path.
    def dynamic_avatar_url(size=256)
      tld = Rails.env.production? ? 'org'       : 'dev'
      sub = Rails.env.production? ? 'avatar.cf' : 'avatar'
      "http://#{sub}.cloudsdale.#{tld}/#{avatar_namespace}/#{self.id}.png?s=#{size}"
    end

    # Public: Determines which namespace the avatar
    # should use. Defaults to the class name downcased.
    #
    # Returns a string.
    def avatar_namespace
      if self.class.respond_to?(:avatar_namespace)
        self.class.avatar_namespace
      else
        self.class.to_s.downcase
      end
    end

    # Private: Sets the avatar upload date.
    #
    # Returns the date the avatar was uploaded.
    def set_avatar_uploaded_at!
      self.avatar_uploaded_at = DateTime.now
    end

  end

end
