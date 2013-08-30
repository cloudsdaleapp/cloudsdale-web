# encoding: utf-8

module Mongoid

  module Identifiable

    extend ActiveSupport::Concern

    included do

      class_attribute :identity_field

      class << self

        def lookup(id)
          Handle.lookup(id, kind: self)
        end

        def identity(value, allowed_changes: 1, diversity: true, dependent: :destroy)

          # Set identity field on a class level.
          self.identity_field = value

          # Create an association for the model
          # and handles based on the identity field.
          self.belongs_to(:handle, foreign_key: identity_field, primary_key: :name, :validate => false, autosave: true, dependent: dependent)

          if diversity
            self.has_many(:handles, as: :identifiable, dependent: dependent, inverse_of: :identifiable)
          end

          # Make the identity field accessible for
          # old API endpoints not using strong
          # parameters.
          self.attr_accessible(identity_field)

          # Index the identity field.
          self.index({ identity_field => 1 }, { unique: 1 })

          # Create the identity field.
          self.field("#{identity_field}", type: String)

          # Add validation for the identity field.
          self.validates(identity_field, presence: true)
          self.validate(:identity_validity)

          # Set a before filter to generate an
          # identity handle before validation
          # if it's missing.
          before_validation(:generate_identity, :unless => "#{identity_field}? && handle?")

          # Only add identity field meta-data
          # if allowed changes is a number.
          if not allowed_changes.nil?
            self.field("force_#{identity_field}_change",    type: Boolean,  default: false)
            self.field("#{identity_field}_changed_at",      type: DateTime)
            self.field("#{identity_field}_changes_allowed", type: Integer,  default: allowed_changes)

            self.validates(identity_field, variety: true, change: {
              :allow => -> { self.send("#{identity_field}_changes_allowed") >= 1 },
              :message => "has been changed too many times"
            })

            self.after_validation(:decrease_identity_changes, :if => "#{identity_field}_changed?")
          end

          # Create a custom setter for the identity
          # field that will manage the changes meta
          # as well as constructing handles.
          define_method "#{identity_field}=" do |value|
            if value.present?
              self.handle = Handle.build(self, value)
              self.handle.identifiable = self

              if not allowed_changes.nil?
                self.send("force_#{identity_field}_change=", false) if self.send("force_#{identity_field}_change")
                self.send("#{identity_field}_changed_at=", DateTime.now)
              end

              self[identity_field] = handle.name
              self.instance_variable_set(:"@#{identity_field}", handle.name)
              super(handle.name)
            end
          end

        end

      end

    end

  private

    # Private: Proxy field errors from the handle to the
    # identity field on the current record.
    #
    # Returns the errors if the handle exists and contains errors.
    def identity_validity
      handle.errors[:_id].each { |error| errors.add(identity_field, error) } if handle? && !handle.valid?
    end

    # Private: Generates an identity for the record based
    # on id or name fields.
    #
    # Returns the new identity value.
    def generate_identity
      handle_name ||= username   if respond_to?(:username)
      handle_name ||= short_name if respond_to?(:short_name)
      handle_name ||= name.parameterize("_").gsub("-","_") if respond_to?(:name)

      self.handle = Handle.build_unique(self, handle_name)
      self.handle.identifiable = self

      self[identity_field] = handle.name
      instance_variable_set(:"@#{identity_field}", handle.name)
    end

    # Private: Decreas the allowed user name changes by one
    # if identity is changed manually by the user. Stop
    # decrement if value has reached zero.
    #
    # Returns the remaining changes.
    def decrease_identity_changes
      if not new_record? and respond_to?("#{identity_field}_changes_allowed")
        current_value = self.send("#{identity_field}_changes_allowed") || 1
        new_value     = current_value >= 1 ? current_value - 1 : 0
        self.send("#{identity_field}_changes_allowed=",new_value)
      end
    end

  end

end