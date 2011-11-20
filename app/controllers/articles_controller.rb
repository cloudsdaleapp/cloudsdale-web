class ArticlesController < ApplicationController
  
  before_filter do
    @author = params[:cloud_id] ? Cloud.find(params[:cloud_id]) : current_user
  end
  
  def show
    @article = Article.find(params[:id])
    @article.log_view_count_and_save!
    @comments = Kaminari.paginate_array(@article.comments.page).page(params[:comment_page]).per(10)
    @comment = @article.comments.build
  end
  
  def new
    @article = Article.new
    authorize! :create, @article
  end
  
  def edit
    @article = Article.find(params[:id])
  end
  
  def create
    
    @article = Article.new(params[:article])
    @author.entries << @article
    respond_to do |format|
      if @article.save
        format.html { redirect_to article_path(@article),
                      notice: notify_with(:success,"#{@article.title}","has been successfully saved.")
                    }
      else
        format.html { render :new }
      end
    end
  end
  
  def update
    @article = Article.find(params[:id])
    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to article_path(@article),
                      notice: notify_with(:success,"#{@article.title}","has been successfully updated.")
                    }
      else
        format.html { render :edit }
      end
    end
  end
  
  def destroy
    @article = Article.find(params[:id])
    respond_to do |format|
      if @article.destroy
        format.html { redirect_to root_path,
                      notice: notify_with(:success,"#{@article.title}","has been successfully removed.")
                    }
      else
        format.html { redirect_to root_path,
                      notice: notify_with(:error,"#{@article.title}","could not be removed, contact the royal court of canterlot.")
                    }
      end
    end
  end
  
  def publish
    @article = Article.find(params[:id])
    respond_to do |format|
      if @article.publish_and_save!
        format.html { redirect_to :back,
                      notice: notify_with(:success,"#{@article.title}","has been successfully published.")
                    }
      else
        format.html { redirect_to :back,
                      notice: notify_with(:error,"#{@article.title}","could not be published, contact the royal court of canterlot.")
                    }
      end
    end
  end
  
  def promote
    @article = Article.find(params[:id])
    respond_to do |format|
      if @article.promote_and_save!
        format.html { redirect_to :back,
                      notice: notify_with(:success,"#{@article.title}","has been successfully promoted.")
                    }
      else
        format.html { redirect_to :back,
                      notice: notify_with(:error,"#{@article.title}","could not be promoted, contact the royal court of canterlot.")
                    }
      end
    end
  end
  
end