namespace :updater do

  task :load_amqp_connector => :environment do
    class Cloudsdale::Updater

      include AMQPConnector

      def initialize(channel,data)

        enqueue! "faye", { channel: "/#{channel}", data: data }

      end

    end
  end

  task :web, [:message] => :load_amqp_connector do |t,args|

    puts "-> Will send update notification to all clients in 15 seconds."

    sleep 15

    @message = args[:message]

    puts "-> Sending update notification... '#{@message}'"

    Cloudsdale::Updater.new("web",{ message: @message })

    puts "-> Update notification successfully sent to all clients."

  end

  task :announcement => :load_amqp_connector do

    options = {
      title: 'Site Update!',
      url: nil,
      scope: "web"
    }

    optparse = OptionParser.new do |opts|

      opts.on('-m', '--message ARG', 'The message to be displayed') do |message|
        options[:message] = message
      end

      opts.on('-t', '--title ARG', 'The title of the message') do |title|
        options[:title] = title
      end

      opts.on('-u', '--url ARG', 'An external url') do |url|
        options[:url] = url
      end

      opts.on('-s', '--scope ARG', 'Scope to a specific type of device') do |_scope|
        options[:scope] = _scope
      end

      opts.on('-h', '--help', 'Display this screen') do
        puts opts
        exit
      end
    end

    begin
      optparse.parse!
      mandatory = [:message]
      missing = mandatory.select{ |param| options[param].nil? }
      if not missing.empty?
        puts "Missing options: #{missing.join(', ')}"
        puts optparse
        exit
      end

    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      puts $!.to_s
      puts optparse
      exit
    end

    puts "-> Will send a notification to #{options[:scope] == '*' ? 'ALL' : options[:scope]} clients in 5 seconds."

    Cloudsdale::Updater.new("announcements/#{options[:scope]}", {
      message: options[:message],
      title:   options[:title],
      url:     options[:url]
    })

    puts "-> Notification successfully sent to clients."

  end

end
