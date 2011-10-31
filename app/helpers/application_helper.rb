module ApplicationHelper
  
  def current_tab(expected_tab=:default)
    params[:tab] == expected_tab
  end
  
end
