module ApplicationHelper
  
  def current_tab(expected_tab=:default)
    params[:tab] == expected_tab
  end
  
  def markdown(text)
    if text
      options = [:filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
      Redcarpet.new(text, *options).to_html.html_safe
    end
  end
  
end
