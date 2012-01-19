module UsersHelper
  
  def dynamic_user_name(user)
    (user == current_user) ? "You" : user.name
  end
  
end
