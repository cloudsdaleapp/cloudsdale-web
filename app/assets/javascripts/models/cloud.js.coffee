class Cloudsdale.Models.Cloud extends Backbone.GSModel
  
  url: ->
    if @id
      "/v1/clouds/#{@id}.json"
    else
      "v1/clouds.json"
      
  type: 'cloud'
  
  defaults:
    name: ""
    description: ""
    avatar: {}
    owner_id: null
    moderator_ids: []
    user_ids: []
    is_transient: true
  
  initialize: (args) ->
    args = {} unless args
      
  removeAvatar: (options) ->
    attr = {}
    attr.remove_avatar = true
    return @save(attr,options)
  
  addUser: (user,options) ->
    # options = {} unless options
    # 
    # # collection = new Cloudsdale.Collections.Users attr.users,
    # #   url: "/v1/clouds/#{@id}/users.json"
    #     
    # collection.save()
  
  containsUser: (user) -> _.include @get('user_ids'), user.id
  
  lastMessageAt: ->
    if @get('chat')
      new Date(@get('chat').last_message_at)
    else
      new Date(0)
  
  owner: ->
    return session.get('users').findOrInitialize(@owner_id)

  users: (options) ->
    options = {} unless options
    session.get('users').findOrInitialize @get('user_ids'),
      specific_endpoint: true
      url: "/v1/clouds/#{@id}/users.json"
      success: (resp, status, xhr) =>
        _users = resp.filter (_user) =>
          return _.include(@get('user_ids'),_user.id)
        options.success(_users, status, xhr) if options.success
        
      error: (resp, xhr,_options) =>
        options.error(resp, xhr,_options) if options.error
              
  moderators: (options) ->
    options = {} unless options
    session.get('users').findOrInitialize @get('moderator_ids'),
      specific_endpoint: true
      url: "/v1/clouds/#{@id}/users/moderators.json"
      success: (resp, status, xhr) =>
        _users = resp.filter (_user) =>
          return _.include(@get('moderator_ids'),_user.id)        
        options.success(_users, status, xhr) if options.success
        
      error: (resp, xhr,_options) =>
        options.error(resp, xhr,_options) if options.error
        
  
  # Announces your chat presence in the chat room periodicly
  # every 27 seconds with a 3 second delay before restarting the timer
  #
  # Returns false.
  announcePresence: ->
    setTimeout( =>
      nfc.cli.publish "/clouds/#{@id}/users/#{session.get('user').id}", {}
      setTimeout( =>
        @announcePresence()
      , 27000)
    , 3000)
    false