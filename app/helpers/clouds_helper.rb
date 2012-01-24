module CloudsHelper
  
  def cloud_avatar_path(path,version=nil)
    if !path.nil?
      path
    elsif !version.nil?
      image_path("other/unknown_cloud_#{version.to_s}.png")
    else
      image_path("other/unknown_cloud.png")
    end
  end
  
end