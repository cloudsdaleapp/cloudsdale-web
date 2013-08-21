# encoding: utf-8

class Api::V2::CloudsController < Api::V2Controller

  include ActionController::Collection

  collections :index, :search

  def show
    @cloud = Cloud.lookup(params[:id])
    respond_with_resource(@cloud, serializer: CloudSerializer)
  end

  def index

    if ids = params[:ids]
      parameters = [:ids]
      @clouds = User.find(ids)
      @total = @clouds.count
      @clouds = Kaminari.paginate_array(@clouds).page(offset).per(limit)
    else
      parameters = []
      @total  = Cloud.where(:created_at.lt => time).count
      @clouds = Cloud.where(:created_at.lt => time).page(offset).per(limit)
    end

    meta = collection_meta_hash_for(@clouds, parameters: parameters)
    meta[:actions] ||= []
    meta[:actions].push({
      name: 'search',
      title: 'Search Clouds',
      type: 'application/json',
      method: 'GET',
      href: "#{search_v2_clouds_url}.json{?query,time,offset,limit}"
    })

    respond_with(@clouds,
      meta: meta,
      meta_key: :collection,
      serializer: CloudsSerializer
    )

  end

  def search

    @query   = params.require(:query) || ""
    @clouds  = Cloud.where(:created_at.lt => time).fulltext_search(@query)
    @total   = @clouds.count
    @clouds  = Kaminari.paginate_array(@clouds).page(offset).per(limit)

    meta = collection_meta_hash_for(@clouds, parameters: [:query])

    respond_with(@clouds,
      meta: meta,
      meta_key: :collection,
      serializer: CloudsSerializer
    )

  end

end
