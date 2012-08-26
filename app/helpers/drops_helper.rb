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
      latest_update = deposits.order_by([:updated_at,:desc]).first.updated_at
      ts = time_ago_in_words(latest_update)
    else
      latest_update = deposits.order_by_depositable(depositable,:desc).first.updated_at_on_depositable(depositable) || Time.now.utc
      ts = time_ago_in_words(latest_update)
    end
    content_tag(:span, class: :timestamp, data: { timestamp: latest_update.to_js }) do
      "#{ts} ago"
    end
  end
  
end
