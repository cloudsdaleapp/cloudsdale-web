
namespace :updater do

  task :web, [:message] => :environment do |t,args|

    class Cloudsdale::Updater

      include AMQPConnector

      def initialize(channel,data)

        enqueue! "faye", { channel: "/#{channel}", data: data }

      end

    end

    puts "-> Will send update notification to all clients in 15 seconds."

    sleep 15

    @message = args[:message]

    puts "-> Sending update notification... '#{@message}'"

    Cloudsdale::Updater.new("web",{ version: @message })

    puts "-> Update notification successfully sent to all clients."

  end

end
