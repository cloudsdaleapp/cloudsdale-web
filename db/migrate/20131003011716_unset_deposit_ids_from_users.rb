class UnsetDepositIdsFromUsers < Mongoid::Migration

  def self.up
    User.all.unset(:deposit_ids)
  end

  def self.down
  end

end