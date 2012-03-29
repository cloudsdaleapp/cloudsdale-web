# require modules/topbar
# require modules/bottombar

# require bootstrap.tabs

# require application/main
# require application/users
# require application/sessions
# require application/clouds
# require application/faqs
# require application/admin
# require application/explore
# require application/drops/reflections

window.Cloudsdale =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    new Cloudsdale.Routers.Sessions()
    new Cloudsdale.Routers.Clouds()
    Backbone.history.start({pushState: true})
    

$(document).ready ->
  Cloudsdale.init()

# $ ->
#   
#   document.window_focus = true
#   $(window).focus ->
#     document.window_focus = true
#   .blur ->
#     document.window_focus = false
#   
#   @userData = $('#user').data()
#   
#   document.fayeCli = new Faye.Client("<%=Cloudsdale.faye_path(:client)%>", { timeout: 500 })
#   subscription = document.fayeCli.subscribe('/')
#   
#   subscription.callback =>
#     if document.fayeCli.getState() == 'CONNECTED'
#       $.event.trigger "faye.connected"
#   
#   subscription.errback =>
#     if document.fayeCli.getState() == 'CONNECTED'
#       $.event.trigger "faye.connected"
#   
#   
#   $(document).bind 'faye.connected', =>
#     $('.navbar.navbar-fixed-top').topBar()
#     $('.bottombar').bottomBar
#       userData: @userData
#       userId: @userData.id
#       userName: @userData.name
#       userAvatar: @userData.avatar
#       userPath: @userData.path
# 
#   load_javascript = (controller,action) ->
#     $.event.trigger "application.load"
#     $.event.trigger "#{controller}.load"
#     $.event.trigger "#{action}_#{controller}.load"
#     $("li[data-main-menu]").removeClass('active')
#     $("li[data-main-menu=#{controller}]").addClass('active')
# 
#   $(document).bind 'application.load', =>
# 
#     $("form[data-validate='true']").validate()
# 
#     $(".alert-message > .close").bind "click", (e) ->
#       hide_alert_message $(@).parent()
# 
#     $(".alert-message.primary").hide().fadeIn(500).delay(8000).fadeOut 500, ->
#       hide_alert_message @
# 
#     $('[rel=twipsy]').tooltip()
#     $(".alert-message").alert()
#     
#     $("a.special_close").bind 'ajax:success', (request,response) ->
#       $(@).parent().remove()
# 
#   $(document).bind 'start.pjax', (a,b,c) ->
#     $("a.brand").addClass("loading")
# 
#   $(document).bind 'end.pjax', (a,b,c) ->
#     $("a.brand").removeClass("loading")
# 
#     controller = b.getResponseHeader('controller')
#     action     = b.getResponseHeader('action')
#     if controller != null and action != null
#       load_javascript(b.getResponseHeader('controller'),b.getResponseHeader('action'))
#       $("body").attr('class', "#{b.getResponseHeader('controller')} #{b.getResponseHeader('action')}").scrollTop(0)
# 
#   $(document).ready ->
#     load_javascript($("body").data('controller'),$("body").data('action'))