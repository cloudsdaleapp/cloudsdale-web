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
          cloud.user_ids.include?(user.id)
        end
              
        # Normal users can only create messages in clouds that are unlocked or that they have added. 
        can :create, Message do |message|
          (user.cloud_ids.include?(message.chat.topic.id) || !message.chat.topic.locked?) && user.is_registered?
        end
      
        # Can only start & vote on prosecutions where they are a moderator or owner of the cloud.
        can [:start,:vote], Prosecution do |prosecution|
          prosecution.crime_scene.moderator_ids.include?(user.id) or prosecution.crime_scene.owner_id == user.id
        end
        
        # Can only update prosection if you're the prosecutor.
        can :update, Prosecution do |prosecution|
          prosecution.prosecutor_id == user.id
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
          puts "Banner: #{user.role}"
          puts "Banee: #{_user.role}"
          (_user.try(:_id) != user.try(:_id)) && user.role > _user.role
        end
        
        can [:start,:vote], Prosecution
        
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
    
    # You can't start a prosecution against yourself.
    cannot [:start,:vote], Prosecution do |prosecution|
      prosecution.offender.id == user.id
    end
    
    # You can't start prosecutions that have a judgement in place.
    cannot :vote, Prosecution do |prosecution|
      prosecution.judgement.present?
    end
      
  end
  
end
