class Users::SubscribersController < ApplicationController
  
  before_filter do
    @publisher = User.find(params[:user_id])
  end
  
  def create
    @publisher.subscribers << current_user
    respond_to do |format|
      if @publisher.save
        format.html { redirect_to :back }
      else
        format.html { raise @publisher.errors }
      end
    end
  end
  
  def destroy
    @publisher.subscribers.delete(current_user)
    respond_to do |format|
      if @publisher.save
        format.html { redirect_to :back }
      else
        format.html { raise @publisher.errors }
      end
    end
  end
  
end