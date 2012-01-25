namespace :users do
  task :reload_avatars => :environment do
    users = User.all
    tot = users.count
    users.each_with_index do |user,i|
      puts "processed #{i+1}/#{tot}" if (i%10==0) or (tot==i+1)
      user.avatar.recreate_versions!
    end
    puts "complete!"
  end
end

