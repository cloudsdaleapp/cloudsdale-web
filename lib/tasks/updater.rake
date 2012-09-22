
namespace :updater do
  
  task :web => :environment do
    
    class Cloudsdale::Updater

      include AMQPConnector

      def initialize(channel,data)

        enqueue! "faye", { channel: "/#{channel}", data: data }

      end

    end
    
    puts "-> Will send update notification to all clients in 60 seconds."
    
    sleep 30
    
    puts "-> Sending update notification..."
    
    @file_path = Rails.root.join(".git","logs","refs","heads","deploy")
    @last_rev = File.open(@file_path,'r') do |f|
      f.extend(Enumerable).inject { |_,ln| ln }
    end.match(/^[a-f0-9]{40}\s(?<rev>[a-f0-9]{40})\s.*/i)
    
    @version =  @last_rev[:rev][0..9]
    
    Cloudsdale::Updater.new("web",{ version: @version })
    
    puts "-> Update notification successfully sent to all clients."
    
  end
  
end