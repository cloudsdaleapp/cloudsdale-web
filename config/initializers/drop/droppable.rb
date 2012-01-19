module Droppable
  
  def create_drop_deposit_from_url_by_user(url,user)
    drop = Drop.find_or_initialize_from_matched_url(url)
    if drop.save
      deposit = drop.deposits.find_or_initialize_by(depositable_id: self.id, depositable_type: self._type.classify)
      deposit.depositers << user unless deposit.depositer_ids.include?(user.id)
      deposit.save
      drop
    else
      nil
    end
  end
  
end