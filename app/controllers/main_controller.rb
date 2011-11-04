class MainController < ApplicationController
  
  def index
    if current_user
      @featured_article = Article.promoted.first
      @recent_items = Article.order_by(:created_at,:desc).limit(5)
    end
  end

end
