class MoveUserNameFromCharacterToUser < Mongoid::Migration
  
  def self.up
    User.all.each do |user|
      if user.character
        user[:name] = user.character.name
        unless user.save
          user[:name] = SecureRandom.hex(10)
          user[:force_name_change] = true
        end
      end
    end
  end

  def self.down
    User.all.each do |user|
      user.character[:name] = user.name
    end
  end
  
end