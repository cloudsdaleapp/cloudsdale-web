module ApplicationHelper
  
  def current_tab(expected_tab=:default)
    params[:tab] == expected_tab
  end
  
  # Takes the flash key value and uses it to
  # determine which alert class to be used
  def to_type(flash_key)
    case flash_key.to_sym
      when :alert
        "alert-warning"
      when :error
        "alert-error"
      when :notice
        "alert-info"
      when :success
        "alert-success"
      else
        flash_key.to_s
    end
  end
  
end
