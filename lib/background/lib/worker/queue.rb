# encoding: utf-8

module Worker
  
  module Queue
  
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    # Public: Gives the class in which the Queue module is included
    # handy class methods to configure the way the Queue should behave.
    module ClassMethods
    
      # Public: Sets the @@queue instance variable
      #
      # name - The name of the queue from which AMQP will pull data
      #
      # Examples
      # 
      # class HelloWorldWorker
      #
      #   include Worker::Queue
      #   queue "hello.world"
      #
      # end
      def queue(name)
        self.class_variable_set(:"@@queue",name.to_s)
      end
    
    end
    
    # Public: Fetches the @@queue class variable
    #
    # name - The name of the queue
    #
    # Examples
    #
    # HelloWorldWorker.new().queue
    # => "hello.world"
    #
    # Returns the name of the queue.
    def queue
      self.class.class_variable_get(:"@@queue")
    end
  
    # Internal A method called inside of an eventmachine loop
    # on the class including the Queue module. Remember adding
    # a do_work method to any other module included in the same
    # class as Queue will need to call super to not break any
    # functionality.
    #
    # Examples
    # 
    # EM.run do
    #   do_work
    # end
    # 
    def do_work
  
      super
      
      log.info("Connecting to AMQP...")
      @amqp_connection = AMQP.connect({ :host => 'localhost',
                                        :user => 'guest',
                                        :pass => 'guest' })
                                        
      @amqp_channel = AMQP::Channel.new @amqp_connection, :auto_recovery => true, :prefetch => 1
      log.info("Subscribing to AMQP queue [#{queue}]...")
      @amqp_queue = @amqp_channel.queue queue, :auto_delete => false
      @amqp_queue.subscribe do |payload|
        log.info("Picked message from [#{queue}] queue")
        perform(Hashr.new(Yajl::Parser.parse(payload, :check_utf8 => true)))
      end
  
    end
  
  end
  
end