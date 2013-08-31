class Admin::SpotlightsController < AdminController

  before_filter :fetch_all_spotlights

  def index
    @spotlight  = Spotlight.new
  end

  def create
    @spotlight = Spotlight.refined_build(params)

    authorize(@spotlight,:create?)

    if @spotlight.save
      flash[:notice] = "Spotlight was created."
      redirect_to spotlights_path
    else
      flash[:error] = "Could not create spotlight."
      render :index
    end
  end

  def destroy
    @spotlight = Spotlight.find(params[:id])

    authorize(@spotlight,:destroy?)

    @spotlight.destroy

    flash[:notice] = "Spotlight was removed."
    redirect_to spotlights_path
  end

private

  def fetch_all_spotlights
    @spotlights = Spotlight.order_by(created_at: :desc)
  end

end
