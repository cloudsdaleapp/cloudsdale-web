class Ability

  include CanCan::Ability

  def initialize(user)

    can :read, User
    can :read, Cloud

    can :restore, User do |u|
      !u.banned?
    end

    if user.is_of_role?(:normal)

      unless user.banned?

        can [:accept_tnc,:update], User, _id: user.id

        # Normal users can create clouds.
        can :create, Cloud do
          user.is_registered?
        end

        # Normal users can destroy clouds they own.
        can [:update,:destroy], Cloud, :owner_id => user.id

        # Normal users can add clouds if they are registered.
        can :add, Cloud do |cloud|
          user.is_registered?
        end

        # Normal users can deduct clouds if their cloud portfolio include that cloud.
        can :deduct, Cloud do |cloud|
          user.is_registered?
        end

        # Normal users can only create messages in clouds that are unlocked or that they have added.
        can :create, Message do |message|
          (user.cloud_ids.include?(message.chat.topic.id) || !message.chat.topic.locked?) && user.is_registered?
        end

        can [:create,:update], Ban do |ban|
          i_am_a_moderator        = ban.jurisdiction.moderator_ids.include?(user.id)
          prosecuting_myself      = ban.offender.id == user.id
          offender_was_there      = ban.jurisdiction.user_ids.include?(offender.id)

          i_am_a_moderator and offender_was_there and !prosecuting_myself
        end

      end

    end

    if user.is_of_role?(:donor)
      # ...
    end

    if user.is_of_role?(:moderator)

      if !user.banned?

        # You can't ban users that have higher role than you
        can [:ban,:unban], User do |_user|
          (_user.try(:_id) != user.try(:_id)) && user.role > _user.role
        end

        can :destroy, Drop

      end

    end

    if user.is_of_role? :placeholder
      # ...
    end

    if user.is_of_role?(:admin)
      can :destroy, Cloud
      can :destroy, User
      can :create, Message
    end

  end

end
