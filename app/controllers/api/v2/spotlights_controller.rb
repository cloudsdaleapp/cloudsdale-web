# encoding: utf-8

class Api::V2::SpotlightsController < Api::V2Controller

  include ActionController::Collection

  collections :index

  def show
    @spotlight = Spotlight.find(params[:id])
    respond_with_resource(@spotlight, serializer: SpotlightSerializer)
  end

  def index

    parameters  = []

    if ids = params[:ids]
      parameters << :ids
      @spotlights = Spotlight.find(ids)
      @total      = @spotlights.count
      @spotlights = Kaminari.paginate_array(@spotlights).page(offset).per(limit)
    elsif categories = params[:categories]
      categories << params[:category] if params[:category]
      @total      = Spotlight.where(:created_at.lt => time, :category.in => categories).order_by(created_at: :desc).count
      @spotlights = Spotlight.where(:created_at.lt => time, :category.in => categories).order_by(created_at: :desc).page(offset).per(limit)
    elsif category = params[:category]
      @total      = Spotlight.where(:created_at.lt => time, :category => category).order_by(created_at: :desc).count
      @spotlights = Spotlight.where(:created_at.lt => time, :category => category).order_by(created_at: :desc).page(offset).per(limit)
    else
      @total      = Spotlight.where(:created_at.lt => time).order_by(created_at: :desc).count
      @spotlights = Spotlight.where(:created_at.lt => time).order_by(created_at: :desc).page(offset).per(limit)
    end

    respond_with(@spotlights,
      meta: collection_meta_hash_for(@spotlights, parameters: parameters),
      meta_key: :collection,
      serializer: SpotlightsSerializer
    )

  end

end
