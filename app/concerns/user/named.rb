# encoding: utf-8

class User
  module Named

    extend ActiveSupport::Concern
    USERNAME_MAX_LENGTH = 20

    included do

      attr_accessible :name, :username

      field :name,                      type: String
      field :force_name_change,         type: Boolean,    default: false
      field :name_changed_at,           type: DateTime

      field :username,                  type: String
      field :force_username_change,     type: Boolean,    default: false
      field :username_changed_at,       type: DateTime

      field :also_known_as,             type: Array,      default: []

      validates :name,     presence: true, variety: true, format: {
        with: /^([a-z]*\s?){1,5}$/i,
        message: "must use a-z and max five words"
      }, length: {
        maximum: 30,
        minimum: 3,
        too_long:  "must not be longer than 30 characters.",
        too_short: "must contain at least 3 characters."
      }

      validates :username, presence: true, variety: true, username: true, length: {
        maximum: USERNAME_MAX_LENGTH,
        minimum: 1,
        too_long:  "must not be longer than 20 characters.",
        too_short: "must contain characters."
      }, remote_uniqueness: {
        with: {
          "username"   => User,
          "short_name" => Cloud
        },
      }

      before_save :add_known_name
      before_validation :generate_unique_username, :unless => :username?

      # Public: Customer setter for the name attribute.
      #
      # Returns the name String.
      def name=(val=nil)
        if val.present?
          self.force_name_change = false if self.force_name_change

          val = val.strip
          val = val.gsub(/[^a-z]/i," ")
          val = val.gsub(/^\s*/i,"")
          val = val.gsub(/[^a-z]/i," ")
          val = val.gsub(/\s\s+/," ")
          words = val.split(/\s/)

          words.each do |word|
            word.downcase!
            word.capitalize!
          end

          val = words[0..4].join(" ")
        end

        if val.present?
          self.name_changed_at = DateTime.now
          self[:name] = val
          @name       = val
          super(val)
        end
      end

    end

    # Public: Customer setter for the username attribute.
    #
    # Returns the username String.
    def username=(val=nil)
      if val.present?
        self.force_username_change = false if self.force_username_change
        self.username_changed_at   = DateTime.now
        self[:username]            = val
        @username                  = val
        super(val)
      end
    end

    # Public: Adds the previously used name to the "also_known_as" array
    # Also makes sure to keep names in array unique, and limit to five names
    #
    # Returns the "also_known_as" array.
    def add_known_name
      if self.name_changed?
        self.also_known_as.unshift(self.name_was) if self.name_was
        self.also_known_as.reject! { |n| n == self.name }
        self.also_known_as.uniq!
        self.also_known_as = also_known_as[0..4]
      end
    end

    # Public: Determines wether the user has to change it's name
    # depending on if the :force_name_change attribute is true
    # or if :name is not present.
    #
    # Examples
    #
    # @user.force_password_change
    # # => true
    #
    # Returns true or false depending on if the users has
    # to change it's name.
    def needs_name_change?
      self[:force_name_change] || !self.name.present?
    end

    # Public: Generates a unique username based on the name
    # if none is provided and a username is not already set.
    def generate_unique_username
      sanitized_name  = name.strip.gsub(" ","").downcase.first(20)
      records_found   = 0
      begin
        iteration = "#{records_found}"
        if records_found.zero?
          new_username = sanitized_name
        else
          if (sanitized_name + iteration).length >= USERNAME_MAX_LENGTH
            new_username = (sanitized_name + " ").truncate(USERNAME_MAX_LENGTH, omission: iteration, separator: "")
          else
            new_username = sanitized_name + iteration
          end
        end
        records_found += 1
      end while User.where(username: /^#{new_username}$/).only(:username).exists? or
                Cloud.where(short_name: /^#{new_username}$/).only(:short_name).exists?

      self.username = new_username
    end

  end
end
