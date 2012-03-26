module Worker

  # Public: Loads the rails environment when included
  # beneficial in need of very modualar workers.
  #
  # Examples
  #
  #   class SomeWorker
  #      include Worker::REnv
  #   end
  module REnv
    
    # Public: Launches when REnv is included
    #
    # Returns nil
    def self.included(base)
            
      require File.expand_path('../../../../../config/environment', __FILE__)
      
    end
    
  end

end