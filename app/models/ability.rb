class Ability
  include CanCan::Ability

  def initialize(user)
    if user

      ## Regular user
      if user.role >= 0
        
        # Logged in
        can :search, :database
        
        # User
        can :read, User, invisible: false
        can :read, User, _id: user.id
        can :update, User, _id: user.id # Can only update own user
        can :checklist, User, _id: user.id # Can only access own checklist
            
        # Clouds
        can :read, Cloud
        can :create, Cloud
        can [:update,:destroy], Cloud, :owner_id => user.id
        can :create, Message do |message|
          user.cloud_ids.include?(message.chat.topic.id)
        end
        
        # FAQ
        can :read, Faq
        
        can [:create, :destroy], Reflection, :author_id => user.id
        can :rate, Reflection do |r|
          r.author_id != user.try(:id)
        end
        
        
      end
        
      if user.role >= 1  ## Donor
        # ...
      end  
        
      if user.role >= 2  ## Moderator
        can :reach, :admin_panel
        can :update, User
        can [:destroy,:update,:feature], Cloud
        can [:update,:destroy,:create], Faq
        can :destroy, Reflection
      end
      
      if user.role >= 3  ## Placeholder
      end
      
      if user.role >= 4  ## Admin
      end
    end
  end
end
