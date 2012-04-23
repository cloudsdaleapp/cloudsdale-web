# encoding: utf-8

$LOAD_PATH.push File.expand_path("../../workers", __FILE__)
$LOAD_PATH.push File.expand_path("../worker", __FILE__)
$LOAD_PATH.push File.expand_path("../", __FILE__)

require 'yaml'
require 'hashr'
require 'fileutils'
require 'digest/md5'
require 'redis'
require 'socket'
require 'optparse'

CONFIG = Hashr.new(YAML.load_file(File.expand_path('../../../../config/config.yml', __FILE__))[ENV["RAILS_ENV"]])
REDIS = Redis.new(:host => CONFIG['redis']['host'], :username => CONFIG['redis']['username'], :password => CONFIG['redis']['password'])

# Public: Requireing this file will load the Worker module thus
# require all available worker submodules that can be used to
# perform certain things at runtime.
#
# Examples
#
# require 'worker'
#
module Worker
  
  require 'base'
  require 'queue'
  require 'renv'
  require 'system'
  
  extend System
  
  AVAILABLE_WORKERS = ["messages","drops"]
  NSPACE = "rainbowfactory"
  APPNAME = "Cloudsdale"
  
  
  # Public: Loads a worker class from a worker name
  #
  # worker_name - The name of the worker, this needs to match a file with the same name, suffixed with "_worker.rb"
  #
  # Examples
  #
  # Worker.load_by_name("HelloWorld")
  # => HelloWorld
  #
  # Returns the constant of the loaded worker.
  def self.load_by_name(worker_name)
    require "#{worker_name}_worker"
    Object.const_get("#{worker_name.capitalize}Worker")
  end
  
  # Public: Stop all processes by the name of the worker
  #
  # worker_name - The name of the worker
  #
  # Examples
  #
  # Worker.stop("HelloWorld")
  # => [12345,23456]
  #
  # Returns an array with the pids that was killed.
  def self.stop(worker_name)
    
    pids_to_die = pids(worker_name)
    
    pids_to_die.each do |pid|      
      Process.kill('TERM', pid.to_i) if pid_alive?(pid)
      REDIS.del "#{NSPACE}:#{worker_class_name(worker_name).to_s.downcase}:#{Digest::MD5.hexdigest(Socket.gethostname)}:#{pid}"
    end
    
    pids_to_die
    
  end
  
  # Public: Starts one instance of the worker
  #
  # worker_class - The worker class object
  # options - A hash of options to use to run the worker
  #
  # Examples
  # Worker.start(HelloWorldWorker)
  #
  # Returns AN ENDLESS LOOP OF EVENTS!
  def self.start(worker_class,options={})
    worker_class.start(options)
  end
  
  def self.spawn(worker_class,options={})
    read, write = IO.pipe
    
    
    if child = safefork # Parent
      
      write.close
      Process.detach(child)
      
      daemon_id = read.read.to_i
      read.close
      
      # Saves deamon ID in redis for future reference.
      REDIS.hset "#{NSPACE}:#{worker_class.to_s.downcase}:#{Digest::MD5.hexdigest(Socket.gethostname)}:#{daemon_id}", "pid", daemon_id
      
      return daemon_id if daemon_id > 0
      
    else # Child
      
      read.close
      
      daemon_id = spawn_child(worker_class,options)
      
      write.write daemon_id
      write.close
      
      exit
      
    end
  end
  
  def self.spawn_child(worker_class,options={})
    read, write = IO.pipe
    
    if child = safefork # Parent
      
      write.close
      daemon_pid = read.read.to_i
      read.close
      
      return daemon_pid
      
    else # Child
      
      read.close
      
      sess_id = Process.setsid
      trap 'SIGHUP', 'IGNORE'
      exit if pid = safefork
      
      write.write Process.pid
      write.close
      
      $0 = "#{APPNAME} - #{worker_class.to_s}"
      
      # Make sure all file descriptors are closed
      ObjectSpace.each_object(IO) do |io|
        unless [STDIN, STDOUT, STDERR].include?(io)
          begin
            unless io.closed?
              io.close
            end
          rescue ::Exception
          end
        end
      end
    
      ios = Array.new(8192){|i| IO.for_fd(i) rescue nil}.compact
      ios.each do |io|
        next if io.fileno < 3
        io.close
      end
    end
    
    STDIN.close
    STDOUT.reopen "/dev/null"
    STDERR.reopen STDOUT
    
    @w = worker_class.start(options)
    
    exit
  end
  
  # Public: Returns all pids for the given worker
  #
  # worker_name - The name of the worker
  #
  # Examples
  #
  # Worker.pids("HelloWorld")
  # => [12345,23456]
  #
  # Returns an array with the pids that was killed.
  def self.pids(worker_name)
    worker_keys = REDIS.keys("#{NSPACE}:#{worker_class_name(worker_name).downcase}:#{Digest::MD5.hexdigest(Socket.gethostname)}:*")
    
    pids = []
    
    worker_keys.each do |worker|
      pids << REDIS.hget(worker, 'pid').to_i
    end
    
    pids
  end
  
  
  # Public: Returns the constant class name of a worked based on worker name
  #
  # worker_name - The name of the worker
  #
  # Examples
  #
  # Worker.worker_class_name("HelloWorld")
  # => "HelloWorldWorker"
  #
  # Returns a string with the worker class name.
  def self.worker_class_name(worker_name)
    worker_name + "Worker"
  end
  
end