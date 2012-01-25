namespace :users do
  task :reload_avatars => :environment do
    tot = 0
    User.all.each_with_index do |user,i|
      puts "processed #{i+1}/#{tot}" if (i%50==0) or (tot==i+1)
      user.avatar.recreate_versions!
    end
    puts "complete!"
  end
end

