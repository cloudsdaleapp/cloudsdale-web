class Cloudsdale.Collections.CloudsUsers extends Backbone.Collection

  model: Cloudsdale.Models.User
  url: -> "/v1/#{@topic.type}s/#{@topic.id}/users/online.json"

  topic: 'cloud'

  initialize: (args,options) ->

    args    ||= {}
    options ||= {}

    @topic = options.topic

    this

  cachedFetch: (options) ->
    options = {} unless options
    session.get('users').findOrInitialize [],
      specific_endpoint: true
      url: @url()
      success: (collection, resp, xhr) =>
        $.each resp.result, (i,user) => @findOrInitialize(user)
        options.success(collection, resp, xhr) if options.success

      error: (resp, xhr,_options) =>
        options.error(resp, xhr,_options) if options.error

    this

  listen: ->
    nfc.on "#{@topic.type}s:#{@topic.id}:users:*", (payload) =>
      @findOrInitialize(payload)

  findOrInitialize: (args) ->
    user = session.get('users').findOrInitialize(args)
    user.set(args)
    @add(user)
