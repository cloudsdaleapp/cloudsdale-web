# encoding: UTF-8
class Chat::RoomsController < ApplicationController
  
  def connect
    t = Time.now
    render :partial => 'connect.js.erb', :locals => { :timestamp => t.to_js, :sender => "System", :message => "Connected to #{params[:id]}", :humanized_timestamp => t.strftime('%R')}
  end
  
  def disconnect
    t = Time.now
    render :partial => 'disconnect.js.erb',
    :locals => { :timestamp => t.to_js, :sender => "System",
                  :message_self => "Disconnected from #{params[:id]}",
                  :message_others => "#{session[:chat][:display_name]} has disconnected.",
                  :humanized_timestamp => t.strftime('%R')
                }
  end
  
  def presence
    render :partial => 'presence.js.erb',
    :locals => { :display_name => session[:chat][:display_name],
                  :token => session[:chat][:token]
                }
  end
  
end