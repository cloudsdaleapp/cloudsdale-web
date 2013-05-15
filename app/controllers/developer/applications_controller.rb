class Developer::ApplicationsController < DeveloperController

  before_filter :fetch_all_user_applications

  rescue_from ActionController::ParameterMissing do |message|
    flash[:error] = "Invalid parameters."
    redirect_to applications_path
  end

  def index
    if current_user.new_record?
      flash[:notice] = "You must be signed in to see and manage your apps."
      redirect_to login_path
    elsif not Doorkeeper::ApplicationPolicy.new(current_user,nil).index?
      raise Pundit::NotAuthorizedError, "You are not a Cloudsdale developer, please connect with GitHub to become one."
    end
  rescue Pundit::NotAuthorizedError => message
    flash[:error] = message
    redirect_to root_path
  end

  def new
    @application = Doorkeeper::Application.new
    authorize @application, :new?
  end

  def create

    @application = Doorkeeper::Application.new(permitted_params.application.create)
    @application.owner = current_user

    authorize @application, :create?

    if @application.save
      flash[:success] = "Application #{@application.name} created successfully."
      redirect_to application_path(@application)
    else
      render :new
    end

  end

  def show
    @application = Doorkeeper::Application.find(params[:id])
    authorize @application, :show?
  end

  def edit
    @application = Doorkeeper::Application.find(params[:id])
    authorize @application, :edit?
  end

  def update
    @application = Doorkeeper::Application.find(params[:id])
    authorize @application, :update?

    if @application.update_attributes(permitted_params.application.update)
      flash[:success] = "Application #{@application.name} updated successfully."
      redirect_to application_path(@application)
    else
      render :edit
    end
  end

  def destroy
    @application = Doorkeeper::Application.find(params[:id])
    authorize @application, :destroy?

    flash[:notice] = "Application #{@application.name} was removed." if @application.destroy
    redirect_to applications_path
  end

private

  def fetch_all_user_applications
    @applications = policy_scope(Doorkeeper::Application)
  end

end
