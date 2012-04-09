class Cloudsdale.Views.Root extends Backbone.View
 
  template: JST['root']
  
  tagName: 'div'
  className: 'main-container'
    
  initialize: ->
    @render()
    
    session.get('clouds').each (cloud) =>
      session.listenToCloud(cloud)
      if true #(Date.parse(cloud.get('chat').last_message_at)) > (Date.now() - (86400000*40))
        view = new Cloudsdale.Views.CloudsToggle(model: cloud)
        this.$el.find('.cloud-bar > .cloud-list').append(view.el)
  
  render: ->
    $(@el).html(@template())
    this