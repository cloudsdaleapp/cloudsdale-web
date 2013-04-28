class GenerateEmailTokenOnAllUsers < Mongoid::Migration

  def self.up
    count = User.where(:email_token => nil).count
    User.where(:email_token => nil).each_with_index do |user,index|
      token = SecureRandom.hex(4)
      user.set(:email_token,token)
      if ((index%100)==1)
        puts "#{index+1}/#{count}"
      end
    end
  end

  def self.down
    count = User.all.count
    User.all.each_with_index do |user,index|
      user.unset(:email_token)
      if ((index%100)==1)
        puts "#{index+1}/#{count}"
      end
    end
  end

end
