class Ability
  
  include CanCan::Ability

  def initialize(user)

    if user.is_of_role? :normal
      
      can [:read,:update], User, _id: user.id
      
      can [:read,:create], Cloud

      can [:update,:destroy], Cloud, :owner_id => user.id
      
      can :create, Message do |message|
        user.cloud_ids.include?(message.chat.topic.id)
      end
      
    end
    
    if user.is_of_role? :donor
      # ...
    end
    
    if user.is_of_role? :moderator
      can [:ban,:unban], User
    end
    
    if user.is_of_role? :placeholder
      # ...
    end
    
    if user.is_of_role? :admin
      # ...
    end
      
  end
  
end
