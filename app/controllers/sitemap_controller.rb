class SitemapController < ApplicationController
  
  layout nil

  def index
    
    headers['Content-Type'] = 'application/xml'
    
    last_cloud = Cloud.last
    
    if stale?(:etag => last_cloud, :last_modified => last_cloud.updated_at.utc)
      
      respond_to do |format|
        format.xml { @clouds = Cloud.order_by([:member_count,:desc]).only([:id,:updated_at]) } # sitemap is a named scope
      end
      
    end
    
  end
  
end