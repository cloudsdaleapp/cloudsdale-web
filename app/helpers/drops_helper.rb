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
  
  def drop_timestamp(drop,deposits,depositable=nil)
    if depositable.nil?
      ts = time_ago_in_words(drop.updated_at)
    else
      latest_update = deposits.order_by("#{depositable.id.to_s}_updated_at",:desc).first.try(:updated_at) || Time.now.utc
      ts = time_ago_in_words(latest_update)
    end
    content_tag(:span, class: :timestamp) do
      "#{ts} ago"
    end
  end
  
end
