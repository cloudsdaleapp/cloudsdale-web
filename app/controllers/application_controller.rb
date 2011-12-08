class ApplicationController < ActionController::Base
  
  helper_method :current_user, :markdown
  
  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      redirect_to root_path, notice: notify_with(:error,"Access denied","you're not authorized to perform this action. We've taken notice of this attempt")
    else
      session[:original_path] = request.path
      redirect_to login_path, notice: notify_with(:warning,"You have to be signed in to do that.")
    end
  end
  
  before_filter :force_password_change!
  
  before_filter do
    response.headers["controller"], response.headers["action"] = controller_name.parameterize, action_name.parameterize
    begin
      current_user.log_activity! if current_user
    rescue
      session[:user_id] = nil
    end
  end
  
  
  protect_from_forgery
  
  def render(options = nil, extra_options = {}, &block)
    if request.headers['X-PJAX'] == 'true'
      options = {} if options.nil?
      options[:layout] = false 
    end
    super(options, extra_options, &block)
  end
  
  def authenticated?
    raise CanCan::AccessDenied.new unless current_user
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def authenticate!(user)
    raise "No user to authenticate" if user.nil?
    session[:user_id] = user.id
    session[:display_name] = user.character.name
    @current_user = user
  end
  
  def notify_with(cat=:success,title="Sucessful",msg="")
    { "category" => cat.to_s, "title" => title, "message" => msg }
  end
  
  def faye_broadcast(channel, data)
    message = { channel: channel, data: data, ext: { auth_token: FAYE_TOKEN } }
    Net::HTTP.post_form(Cloudsdale.faye_path, message: message.to_json)
  end
  
  private
  
  def render_and_act_as(controller,action,lo="application")
    params[:controller], params[:action] = controller, action
    render "#{controller.to_s}/#{action.to_s}", :layout => lo
  end
  
  def unless_pending_request_go_to(fallback_path)
    pending_path = session[:original_path]
    if pending_path
      session[:original_path] = nil
      pending_path
    else
      fallback_path
    end
  end
  
  def markdown(text)
    if text
      options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
      Redcarpet.new(text, *options).to_html.html_safe
    end
  end
  

  # Forces the users to change their passwords if they are flagged to do so.
  def force_password_change!
    if current_user.try(:force_password_change?) == true
      redirect_to change_password_user_path(current_user), notice: notify_with(:warning,"Please change your password before proceeding.")
    end
  end
  
end
