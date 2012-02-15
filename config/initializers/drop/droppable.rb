module Droppable
  
  def create_drop_deposit_from_url_by_user(url,user)
    d = Drop.find_or_initialize_from_matched_url(url)
    i = self[:_id]
    t = self[:_type].classify
    if d.save
      dp = d.deposits.find_or_initialize_by(depositable_id: i, depositable_type: t)
      dp.depositers << user unless dp.depositer_ids.include?(user.id)
      dp.save
    end
    d
  end
  
end