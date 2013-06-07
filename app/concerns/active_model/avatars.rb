module ActiveModel

  module Avatars

    extend ActiveSupport::Concern

    included do

      attr_accessor :avatar_purged

      attr_accessible :avatar, :remote_avatar_url, :remove_avatar

      field :avatar_uploaded_at,   type: DateTime

      mount_uploader :avatar, AvatarUploader

      before_save :set_avatar_uploaded_at!

      def avatar_uploaded
        self[:avatar_uploaded_at] || self.updated_at || self.created_at
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
    def dynamic_avatar_url(size = 256, url_type = :id, schema = :http)
      url =   case schema
              when :https  then Cloudsdale.config['avatar']['https']
              when :ssl    then Cloudsdale.config['avatar']['https']
              else Cloudsdale.config['avatar']['http']
              end

      "#{url}#{dynamic_avatar_path(size,url_type)}"
    end

    # Public: Generates the new type of avatar path on demand
    #
    # Returns the relative avatar path.
    def dynamic_avatar_path(size = 256, url_type = :id)

      avatar_id = case url_type
                  when :hash       then self.email_hash
                  when :email      then self.email_hash
                  when :email_hash then self.email_hash
                  else self.id
                  end

      params = []
      params << "s=#{size}" if size
      params << "mtime=#{self.avatar_uploaded_at.to_i}" if avatar_uploaded_at
      params = !params.empty? ? "?" + params.join("&") : ""

      "/#{avatar_namespace}/#{avatar_id}.png#{params}"

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
      self.avatar_uploaded_at = DateTime.now if avatar_changed?
    end

  protected

    # Internal: Override to silently ignore trying to remove missing
    # previous avatar when destroying a User.
    def remove_avatar!
      begin
        super
      rescue Fog::Storage::Rackspace::NotFound
      end
    end

    # Internal: Override to silently ignore trying to remove missing
    # previous avatar when saving a new one.
    def remove_previously_stored_avatar
      begin
        super
      rescue Fog::Storage::Rackspace::NotFound
        @previous_model_for_avatar = nil
      end
    end

  end

end
