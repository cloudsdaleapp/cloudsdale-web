module DropsHelper
  
  def depositable_path(deposit)
    reciever_type = deposit.depositable_type
    if reciever_type == "User"
      return user_path(deposit.depositable._id.to_s)
    elsif reciever_type == "Cloud"
      return cloud_path(deposit.depositable._id.to_s)
    end
    return "#"
  end
  
end
