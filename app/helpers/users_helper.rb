module UsersHelper
  
  def dynamic_user_name(user)
    (user == current_user) ? "You" : user.name
  end
  
  def user_avatar_path(path,version=nil)
    if !path.nil?
      path
    elsif !version.nil?
      image_path("other/unknown_pony_#{version.to_s}.jpg")
    else
      image_path("other/unknown_pony.jpg")
    end
  end
  
end
