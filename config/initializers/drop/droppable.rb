module Droppable
  
  def create_drop_deposit_from_url_by_user(url,user)
    d = Drop.find_or_initialize_from_matched_url(url)
    if d.save
      dp = drop.deposits.find_or_initialize_by(depositable_id: self.id, depositable_type: self._type.classify)
      dp.depositers << user unless dp.depositer_ids.include?(user.id)
      dp.save
      d
    else
      nil
    end
  end
  
end