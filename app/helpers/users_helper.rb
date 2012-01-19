module UsersHelper
  
  def dynamic_user_name(user)
    (user == current_user) ? "You" : current_user.name
  end
  
end
