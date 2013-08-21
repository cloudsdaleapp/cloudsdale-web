# encoding: utf-8

class Api::V2::UsersController < Api::V2Controller

  include ActionController::Collection

  collections :index, :search

  def show
    @user = User.lookup(params[:id])
    respond_with_resource(@user, serializer: UserSerializer)
  end

  def index

    if ids = params[:ids]
      parameters = [:ids]
      @users = User.find(ids)
      @total = @users.count
      @users = Kaminari.paginate_array(@users).page(offset).per(limit)
    else
      parameters = []
      @total = User.where(:created_at.lt => time).count
      @users = User.where(:created_at.lt => time).page(offset).per(limit)
    end

    meta = collection_meta_hash_for(@users, parameters: parameters)
    meta[:actions] ||= []
    meta[:actions].push({
      name: 'search',
      title: 'Search Users',
      type: 'application/json',
      method: 'GET',
      href: "#{search_v2_users_url}.json{?query,time,offset,limit}"
    })

    respond_with(@users,
      meta: meta,
      meta_key: :collection,
      serializer: UsersSerializer
    )

  end

  def search

    @query  = params.require(:query) || ""
    @users = User.where(:created_at.lt => time).fulltext_search(@query)
    @total = @users.count
    @users = Kaminari.paginate_array(@users).page(offset).per(limit)

    meta = collection_meta_hash_for(@users, parameters: [:query])

    respond_with(@users,
      meta: meta,
      meta_key: :collection,
      serializer: UsersSerializer
    )

  end

end
