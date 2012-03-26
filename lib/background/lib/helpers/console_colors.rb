String.class_eval do
  
  # Public: Used to convert ruby strings to yeild themselves with colors
  # inside unix consoles. Powerful when you want to emphezise your output
  # and make it more compelling for the user.
  #
  # Examples
  # 
  # "hello world".as_color(:red)
  # => "\e[31mhello world\e[0m"
  #
  # Returns self with console coloring.
  def as_color(color_value=:red)
    case color_value
    when :red
      color_code = 31
    when :green
      color_code = 32
    when :yellow
      color_code = 33
    when :blue
      color_code = 34
    else
      color_code = 32
    end
    
    "\e[#{color_code}m#{self.to_s}\e[0m"
  end
  
end