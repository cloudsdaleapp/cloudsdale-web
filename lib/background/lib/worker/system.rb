module System
  
  # Public: Safely forks a new child process
  #
  # Examples
  # 
  # System.safefork
  # => 12345
  #
  # Returns process id.
  def safefork
    tryagain = true  
    while tryagain
      tryagain = false
      begin
        if pid = fork
          return pid
        end
      rescue Errno::EWOULDBLOCK
        sleep 5
        tryagain = true
      end
    end
  end

  # Public: Checks if the given PID has a living process.
  #
  # pid - The process ID you want to see if it exists
  #
  # Examples
  # 
  # System.pid_alive?(12345)
  # => true
  #
  def pid_alive?(pid)
    begin
      ::Process.kill(0, pid)
      true
    rescue Errno::ESRCH
      false
    end
  end
  
end