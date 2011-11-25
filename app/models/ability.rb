class Ability
  include CanCan::Ability

  def initialize(user)
    if user

      ## Regular user
      if user.role >= 0
        
        # User
        
        # Can only update own user
        can :update, User, :id => user.id
        
        # Entries
        
        # Can only read published articles
        can :read,  Entry, :published => true
        # Can manage article that belongs to USER
        can :create, Entry
        can [:read,:update,:destroy], Entry, :author_id => user.id
        cannot :promote, Entry
        
        # Comments
        
        # Can only read and create comments in published topic that is commentable
        can [:read,:create], Comment, :topic => { :published => true, :commentable => true }
        # Can always create comments on topics that belong to USER
        can [:destroy,:read], Comment, :topic => { :author => user }
        # Can always destroy comments made by USER
        can :destroy, Comment, :author_id => user.id
        
        # Clouds
        can :read, Cloud, :hidden => false
        can :create, Cloud
        can [:update,:destroy], Cloud, :owner_id => user.id
        
      end
        
      if user.role >= 1  ## Donor
        # ...
      end  
        
      if user.role >= 2  ## Moderator
        # Articles
        can [:read,:update,:destroy,:promote], Entry
      end
      
      if user.role >= 3  ## Placeholder
      end
      
      if user.role >= 4  ## Admin
      end
    end
  end
end
