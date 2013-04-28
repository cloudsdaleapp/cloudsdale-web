class Admin::DispatchesController < AdminController

  def index
    @dispatches = Dispatch.order_by(:published_at => :desc, :created_at => :desc).all
    authorize @dispatches
  end

  def show
    @dispatch = Dispatch.find(params[:id])
    authorize @dispatch, :show?
  end

  def create
    @dispatch = Dispatch.new

    authorize @dispatch, :create?

    @dispatch.save
    redirect_to admin_dispatch_path(@dispatch)
  end

  def update
    @dispatch = Dispatch.find(params[:id])

    authorize @dispatch, :update?

    @dispatch.update_attributes(params[:dispatch])

    case params[:commit].parameterize
    when "save-test"
      DispatchMailer.delay(
        :queue => :high,
        :retry => false
      ).default_mail(
        @dispatch.id.to_s,
        current_user.id.to_s,
        SecureRandom.hex(4)
      )
      redirect_to admin_dispatch_path(@dispatch)
    when "save-publish"
      @dispatch.published_at = Time.now
      @dispatch.save
      DispatchesWorker.perform_async(@dispatch.id.to_s)
      redirect_to admin_dispatch_path(@dispatch)
    else
      redirect_to admin_dispatch_path(@dispatch)
    end
  end

end
