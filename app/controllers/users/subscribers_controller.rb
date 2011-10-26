class Users::SubscribersController < ApplicationController
  
  before_filter do
    @publisher = User.find(params[:user_id])
  end
  
  def create
    @publisher.subscribers << current_user
    respond_to do |format|
      if @publisher.save
        format.html { redirect_to :back, :notice => notify_with(:success,"Subscribed to #{@publisher.character.name}","") }
      else
        format.html { raise @publisher.errors }
      end
    end
  end
  
  def destroy
    @publisher.subscribers.delete(current_user)
    respond_to do |format|
      if @publisher.save
        format.html { redirect_to :back, :notice => notify_with(:warning,"No longer subscribing to #{@publisher.character.name}","") }
      else
        format.html { raise @publisher.errors }
      end
    end
  end
  
end