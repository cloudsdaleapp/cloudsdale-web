# encoding: utf-8

require 'eventmachine'
require "em-synchrony"
require "em-synchrony/em-http"

module Worker
  
  # Public: To create a worker of some sort you need to start by including
  # this Base module. This will give give you the methods required to spawn
  # the worker through the executable, add logging & process tracking.
  module Base
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      # Public: Initializes a worker and calls start on it's instance it straight after
      #
      # options - A hash of options for the worker
      #
      # Examples
      #
      # SomeWorker.start
      #
      # Returns whatever start returns.
      def start(options={})
        self.new(options).start
      end
      
      # Public: Initializes a worker and calls start on it's instance it straight after
      #
      # options - A hash of options for the worker
      #
      # Examples
      #
      # SomeWorker.start
      #
      # Returns whatever start returns.
      # def spawn(options={})
      #   self.new(options).start
      # end
      
    end
    
    # Public: Initializes a worker
    #
    # options - A hash of options for the worker
    #
    # Examples
    #
    # SomeWorker.new()
    #
    # Returns the worker object.
    def initialize(options={})
    end
    
    # Internal This is used gracefully kill the application
    # when process receives certain signals.
    #
    # Examples
    #
    # EM.run do
    #   shutdown!
    # end
    #
    def register_signal_handlers
      trap('TERM') { shutdown }
      trap('INT')  { shutdown }
      trap('QUIT') { shutdown }
      trap 'SIGHUP', 'IGNORE'
    end
    
    # Public: Starts the worker eventloop
    #
    # Examples
    #
    # worker = SomeWorker.new()
    # worker.start
    #
    def start
  
      register_signal_handlers
    
      EM.synchrony do
        do_work
      end
  
    end
    
    # Internal Gracefully kills the eventmachine loop
    #
    # Examples
    # 
    # EM.run do
    #   ... do stuff ...
    #   shutdown
    # end
    #
    def shutdown
      EM.stop_event_loop
    end
    
    # Internal A method called inside of an eventmachine loop
    # on the class including the Base module. Remember adding
    # a do_work method to any other module included in the same
    # class as Base will need to call super to not break any
    # functionality.
    #
    # Examples
    # 
    # EM.run do
    #   do_work
    # end
    #
    def do_work
      # does things
    end
    
  end
  
end