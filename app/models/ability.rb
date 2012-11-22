class Ability

  include CanCan::Ability

  def initialize(user)

    can :read, User
    can :read, Cloud

    can :restore, User do |u|
      !u.banned?
    end

    can [:accept_tnc,:update], User, _id: user.id

    if user.is_registered? and not user.banned?

      # Normal users can create clouds.
      can :create, Cloud

      # Normal users can destroy clouds they own.
      can [:update,:destroy], Cloud, :owner_id => user.id

      # Normal users can add clouds if they are registered.
      can :add, Cloud do |cloud|
        banned_from_cloud = cloud.has_banned?(user)
        not banned_from_cloud
      end

      # Normal users can deduct clouds if their cloud portfolio include that cloud.
      can :deduct, Cloud

      # Normal users can only create messages in clouds that are unlocked or that they have added.
      can :create, Message do |message|
        i_can_communicate_in_topic  = user.cloud_ids.include?(message.chat.topic.id)
        topic_is_not_locked         = !message.chat.topic.locked?
        i_am_not_banned_from_topic  = !message.chat.topic.has_banned?(user)

        (i_can_communicate_in_topic || topic_is_not_locked) && i_am_not_banned_from_topic
      end

      can [:list], Ban do |ban|
        ban.jurisdiction.moderator_ids.include?(user.id)
      end

      can [:create,:update], Ban do |ban|
        i_am_a_moderator        = ban.jurisdiction.moderator_ids.include?(user.id)
        not_prosecuting_myself  = ban.offender.id != user.id
        offender_was_there      = ban.jurisdiction.user_ids.include?(ban.offender.id)

        (i_am_a_moderator || offender_was_there) && not_prosecuting_myself
      end

    end

    # if user.is_of_role?(:moderator)

    #   if !user.banned?

    #     # You can't ban users that have higher role than you
    #     can [:ban,:unban], User do |_user|
    #       (_user.try(:_id) != user.try(:_id)) && user.role > _user.role
    #     end

    #     can :destroy, Drop

    #   end

    # end

    if user.is_of_role?(:admin)
      can :destroy, Cloud
      can :create, Message
    end

  end

end
