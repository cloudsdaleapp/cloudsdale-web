class Ability
  
  include CanCan::Ability

  def initialize(user)

    if user.is_of_role? :normal
      
      can [:read,:update], User, _id: user.id
      can :accept_tnc, User, _id: user.id
      
      can :add_to_cloud, User
      can :deduct_from_cloud, User
      
      can :read, Cloud
      can :create, Cloud do
        user.is_registered?
      end
      can [:update,:destroy], Cloud, :owner_id => user.id
            
      can :add, Cloud do |cloud|
        user.is_registered?
      end
      
      can :deduct, Cloud do |cloud|
        cloud.user_ids.include?(user.id)
      end
      
      can :create, Message do |message|
        user.cloud_ids.include?(message.chat.topic.id) || !message.chat.topic.locked?
      end
      
      can [:start,:vote], Prosecution do |prosecution|
        prosecution.crime_scene.moderator_ids.include?(user.id) or prosecution.crime_scene.owner_id == user.id
      end
      
    end
    
    if user.is_of_role? :donor
      # ...
    end
    
    if user.is_of_role? :moderator
      can [:ban,:unban], User
      can [:start,:vote], Prosecution
    end
    
    if user.is_of_role? :placeholder
      # ...
    end
    
    if user.is_of_role? :admin
      can :destroy, Cloud
      can :destroy, User
    end
    
    can :update, Prosecution do |prosecution|
      prosecution.prosecutor_id == user.id
    end
    
    cannot [:start,:vote], Prosecution do |prosecution|
      prosecution.offender.id == user.id
    end
    
    cannot :vote, Prosecution do |prosecution|
      prosecution.judgement.present?
    end
      
  end
  
end
