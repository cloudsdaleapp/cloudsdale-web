namespace :drops do
  
  namespace :images do
    
    task :reload => :environment do
      
      Drop.where(strategy:'image').each do |d|
        print "Reloading #{d.title}..."
        begin
          d.re_fetch!
          print " success!\n"
        rescue Exception => msg
          print " fail! - #{msg.inspect}\n\n"
        rescue IOError
          print " IOERROR!\n\n"
        end
      end
      
    end
    
  end
  
end