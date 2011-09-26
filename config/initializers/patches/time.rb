class Time  
  def to_js # to javascript, ie: "2007-06-09T14:23:11", usage: new Date("<%= Time.now.to_js %>")  
     self.strftime("%Y-%m-%dT%H:%M:%S")  
  end  
end