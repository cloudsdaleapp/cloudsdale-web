# encoding: utf-8

class User
  module Named

    extend ActiveSupport::Concern

    included do

      attr_accessible :name

      field :name,                      type: String
      field :force_name_change,         type: Boolean,    default: false
      field :also_known_as,             type: Array,      default: []

      validates_length_of     :name,  within: 3..30, message: "must be between 3 and 30 characters", if: :name?
      validates_format_of     :name,  with: /^([a-z]*\s?){1,5}$/i, message: "must use a-z and max five words", if: :name?
      validates_uniqueness_of :name,  case_sensitive: false, if: :name?

      validates_presence_of   :name,  :unless => :new_record?
      validates_presence_of   :name,  :if => :confirm_registration

      validate :forced_name_change,     if: :force_name_change_changed?

      before_save do
        add_known_name
      end

      # Public: Customer setter for the name attribute.
      #
      # Returns the name String.
      def name=(val=nil)
        if val.present?
          self.force_name_change = false if self.force_name_change

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
          self[:name] = val
          @name       = val
          super(val)
        end
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

  private

    # Private: Validation for when name is changed while forced name
    # equates to true.
    #
    # Returns false if validation fails
    def forced_name_change
      if (name_was == name) && force_name_change_was == true
        errors.add(:name, "cannot be the same")
        return false
      end
    end

  end
end
