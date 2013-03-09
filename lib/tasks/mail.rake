namespace :mail do
  task :beta => :environment do
    @users = User.all
    @tot_users = @users.count || 0
    @failed = 0
    puts "Sending an email to #{@tot_users}"

    @users.each_with_index do |user,i|

      if user.email? && user.name?
        begin
          mail = UserMailer.mobile_launch_mail(user)
          mail.deliver
        rescue
          @failed += 1
        end
      end

      if (i%10==0) or (@tot_users==i+1)
        system('clear')
        puts "Sent an email to #{i+1} out of #{@tot_users}"
      end

    end

    system('clear')
    puts "Sent emails to #{@tot_users}"
    puts "Succeeded: #{@tot_users - @failed}"
    puts "Failed: #{@failed}"
    puts "## Done! ##"

  end

end

