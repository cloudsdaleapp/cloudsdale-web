class TransformAssociatedCloudsToConversations < Mongoid::Migration

  def self.up
    gt1 = Time.now

    User.all.each do |user|
      clouds = user.clouds
      t1 = Time.now.to_i

      puts "Creating #{clouds.count} conversations for @#{user.username}"
      clouds.each do |cloud|
        conversation = Conversation.sortie by: user, on: cloud, as: :granted
        if conversation.save
          puts "-> Created conversation on topic #{cloud.name}"
        else
          puts "-! Failed to create conversation on topic #{cloud.name}"
        end
      end

      t2 = Time.now.to_i

      puts "-> Operation done in #{(t2-t1)} seconds"
    end

    gt2 = Time.now

    puts "|| Finished in #{(gt2-gt1)} seconds ||"
  end

  def self.down
    User.all.set(:conversations,[])
  end

end
