# encoding: utf-8
require 'digest/md5'

class User
  module Emailable

    extend ActiveSupport::Concern

    included do

      attr_accessible :email

      field :email,                     type: String
      field :email_hash,                type: String
      field :email_token,               type: String
      field :email_verified_at,         type: DateTime
      field :email_subscriber,          type: Boolean,    default: true
      field :email_bounces,             type: Integer,    default: 0

      field :force_email_change,        type: Boolean,    default: false

      index( { email: 1 },        { unique: true, name: "email_index",     background: true } )
      index( { email_hash: 1 },   { unique: true, name: "auth_hash_index", background: true } )
      index( { email_token: 1 },  { name: "email_token_index", background: true } )

      validates :email, :email => true, :if => :email?

      validates_presence_of   :email, :if => :confirm_registration
      validates_presence_of   :email, :unless => :new_record?
      validates_uniqueness_of :email, :case_sensitive => false, if: :email?

      validate :forced_email_change,    if: :force_email_change_changed?

      before_save do
        generate_email_token unless email_token.present?
      end

      # Public: Custom email setter that will reset some related
      # attributes.
      #
      # Returns the email.
      def email=(val="")

        val ||= ""
        val.downcase!
        val.strip!

        if val.present? and val != self[:email]
          self.force_email_change = false if self.force_email_change

          self.email_verified_at = nil
          self.email_bounces     = 0

          self[:email] = val
          @email       = val
          super(val)

          generate_email_hash
          generate_email_token
        end

        return val
      end

    end

    # Public: Renews the email token and makes the old one unusable.
    # Good idea to do this when an email token has been consumed.
    def generate_email_token
      self[:email_token] = SecureRandom.hex(4)
    end

    # Public: Generates an MD5 hexdigest hash out of the email address.
    # Good idea to do this whenever the email address has changed.
    def generate_email_hash
      self.email_hash = Digest::MD5.hexdigest(self.email) if self.email.present?
    end

    # Public: Determines wether the user has to change it's email
    # depending on if the :force_email_change attribute is true
    # or if :email is not present.
    #
    # Examples
    #
    # @user.force_password_change
    # # => true
    #
    # Returns true or false depending on if the users has
    # to change it's email.
    def needs_email_change?
      self[:force_email_change] || !self.email.present?
    end

    module ClassMethods
    end

  private

    # Private: Validation for when password is changed while forced passowrd
    # equates to true.
    #
    # Returns false if validation fails
    def forced_email_change
      if (email_was == email) && force_email_change_was == true
        errors.add(:email, "cannot be the same")
        return false
      end
    end

  end
end
