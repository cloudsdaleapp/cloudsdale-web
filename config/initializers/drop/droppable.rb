module Droppable

  def create_drop_deposit_from_url_by_user(url,user)
    drop = Drop.find_or_initialize_from_matched_url(url)
    id   = self[:_id]
    type = self[:_type].classify
    drop.deposits.find_or_initialize_by(depositable_id: id, depositable_type: type).save if not drop.nil? and drop.save
    return drop
  end

end
