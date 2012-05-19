class Api::V1::Users::ProsecutionController
  
  before_filter do
    @user = User.find(params[:user_id])
  end
  
  # Public: Creates a prosecution based on parameters.
  #
  #   prosecution - A Hash of parameters to send to the prosecution model instance.
  #
  # Returns the prosecution object with a 200 status.
  def create
    
    @prosecution = @user.prosecutions.build(params[:prosecution])
    authorize! :start, @prosecution
    
    if @prosecution.save
      render status: 200
    else
      render status: 422
    end
    
  end
  
  # Public: Updates a prosecution node.
  #
  #   id - A BSON id of the prosecution to perform the update on
  #   prosecution - A Hash of parameters to send to the prosecution model instance:
  #                 :get_verdict
  #
  # Returns the prosecution object with a 200 status.
  def update
    
    @prosecution = @user.prosecutions.find(params[:id])
    authorize! :update, @prosecution
    
    if @prosecution.update_attributes(params[:prosecution], as: :prosecutor)
      render status: 200
    else
      render status: 422
    end
    
  end
  
  # Public: Votes on a prosecution.
  #
  #   vote_value -  A String that can be either :up or :down
  #                 If left empty, it will try to remove your vote.
  #
  # Returns the prosecution object with a 200 status.
  def vote
    
    @prosecution = @user.prosecutions.find(params[:id])
    authorize! :vote, @prosecution
    
    if params[:vote_value]
      current_user.vote(@prosecution, params[:vote_value])
    else
      current_user.unvote(@prosecution)
    end
    
    render status: 200
    
  end

end