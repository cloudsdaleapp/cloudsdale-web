class Admin::DispatchesController < AdminController

  def index
    @dispatches = Dispatch.all
  end

  def show
    @dispatch = Dispatch.find(params[:id])
  end

  def create
    @dispatch = Dispatch.new
    @dispatch.save
    redirect_to admin_dispatch_path(@dispatch)
  end

  def update
    @dispatch = Dispatch.find(params[:id])
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
      redirect_to admin_dispatch_path(@dispatch)
    else
      redirect_to admin_dispatch_path(@dispatch)
    end
  end

end
