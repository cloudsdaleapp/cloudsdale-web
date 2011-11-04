class Articles::CommentsController < ApplicationController
  
  before_filter do
    @article = Article.find(params[:article_id])
  end
  
  def create
    @comment = @article.comments.build(params[:comment])
    @comment.author = current_user
    authorize! :create, @comment
    respond_to do |format|
      if @comment.save
        format.html { redirect_to article_path(@article),
                      notice: notify_with(:success,"Successfully","left a comment.")
                    }
      else
        format.html { redirect_to article_path(@article),
                      notice: notify_with(:error,"Comment","could not be saved.")
                    }
      end
    end
  end
  
  def destroy
    @comment = @article.comments.find(params[:id])
    authorize! :destroy, @comment
    respond_to do |format|
      if @comment.destroy
        format.html { redirect_to article_path(@article),
                      notice: notify_with(:success,"Successfully","removed comment.")
                    }
      else
        format.html { redirect_to article_path(@article),
                      notice: notify_with(:error,"Comment","could not be removed.")
                    }
      end
    end
  end
  
end