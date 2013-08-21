# encoding: utf-8
module ActionController::Collection

  extend ActiveSupport::Concern

  included do
    hide_action :offset
    hide_action :time
    hide_action :limit
    hide_action :total

    before_filter :extract_collection_parameters,      only: [:search,:index]
    after_filter  :build_collection_response_headers,  only: [:search,:index]
  end

private

  # Private: Evaluates the collection record offset.
  # Returns an Integer.
  def offset; @offset ||= 1; end

  # Private: Evaluates the collection freeze time.
  # Returns a DateTime.
  def time;   @time   ||= DateTime.current; end

  # Private: Evaluates the collection record limit.
  # Returns an Integer.
  def limit;  @limit  ||= 10; end

  # Private: Evaluates the total amount of records
  # in the current collection.
  #
  # Returns an Integer.
  def total;  @total  ||= 0; end

  # Private: Extracts collection metadata from HTTP headers
  # or regular URL parameters. To be called individually in
  # a controller action method or in conjunction with a rails
  # before_filter.
  #
  # Examples
  #
  # before_filter :extract_collection_parameters, only: [:search]
  #
  # Returns nothing of interest.
  def extract_collection_parameters
    @time   = request.headers["X_COLLECTION_TIME"] || params[:time]
    @time   = @time.numeric? ? Time.at(@time.to_i).to_datetime.utc : DateTime.parse(@time) if @time
    @offset = request.headers["X_COLLECTION_OFFSET"].try(:to_i) || params[:offset].try(:to_i)
    @limit  = request.headers["X_COLLECTION_LIMIT"].try(:to_i)  || params[:limit].try(:to_i)
  end

  # Private: Builds HTTP response headers based on a collection to
  # provide clients with useful data about how to further navigate
  # the current collection. This is to be used with an after_filter.
  #
  # Examples
  #
  # after_filter :build_collection_response_headers, only: [:search]
  #
  # Returns nothing of interest.
  def build_collection_response_headers
    response.headers["X-Collection-Offset"] = offset.to_s
    response.headers["X-Collection-Limit"]  = limit.to_s
    response.headers["X-Collection-Total"]  = total.to_s
    response.headers["X-Collection-Time"]   = time.to_ms.to_s
  end

  def collection_meta_hash_for(collection, parameters: [])
    meta = {}

    meta[:refs] = []

    parameters = params.select{ |k,_| parameters.include? k.to_sym }.merge(
      format: request.format.symbol,
      time: time.to_i,
      limit: limit
    )

    meta[:refs] << {
      href: url_for(parameters.merge({ offset: (offset - 1) })),
      rel: 'previous'
    } unless collection.first_page?

    meta[:refs] << {
      href: url_for(parameters.merge({ offset: offset })),
      rel: 'self'
    }

    meta[:refs] << {
      href: url_for(parameters.merge({ offset: (offset + 1) })),
      rel: 'next'
    } unless collection.last_page?

    return meta
  end

end