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
        can :read, Cloud do |cloud|
          cloud.user_ids.include?(user.id)
        end
        can [:update,:destroy], Cloud, :owner_id => user.id
        
        # FAQ
        can :read, Faq
        
        
      end
        
      if user.role >= 1  ## Donor
        # ...
      end  
        
      if user.role >= 2  ## Moderator
        # Articles
        can [:read,:update,:destroy,:promote], Entry
        can :update, User
        can [:update,:destroy,:create], Faq
      end
      
      if user.role >= 3  ## Placeholder
      end
      
      if user.role >= 4  ## Admin
      end
    end
  end
end
