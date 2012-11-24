class Cloudsdale.Models.Cloud extends Backbone.Model

  url: ->
    if @id
      "/v1/clouds/#{@id}.json"
    else
      "v1/clouds.json"

  type: 'cloud'

  defaults:
    name: ""
    description: ""
    short_name: ""
    avatar: {}
    owner_id: null
    moderator_ids: []
    user_ids: []
    is_transient: true
    member_count: 0
    hidden: false
    avatar_url: null

  initialize: (args) ->
    args = {} unless args

    @recentDrops = new Cloudsdale.Collections.Clouds(@get('recent_drops')) if @get('recent_drops')

    this

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

  createdAt: ->
    new Date(@get('created_at'))

  lastMessageAt: ->
    if @get('chat')
      new Date(@get('chat').last_message_at)
    else
      new Date(0)

  link: ->
    if @get('short_name')
      return "/clouds/#{@get('short_name')}"
    else
      return "/clouds/#{@id}"

  owner: ->
    return session.get('users').findOrInitialize { id: @owner_id },
      fetch: false

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

  importantUsers: (options) ->
    options = {} unless options

    ids = if @get('owner_id') then _.union([@get('owner_id')],@get('moderator_ids')) else @get('moderator_ids')
    if ids.length <= 8
      availableUserIds = _.shuffle( _.without(@get('user_ids'), ids) )
      numberOfIdsToPluck = 8 - ids.length
      normalUserIds = availableUserIds[0..numberOfIdsToPluck]

      ids = _.union(ids,normalUserIds)

    ids = _.uniq(ids)

    session.get('users').findOrInitialize ids,
      specific_endpoint: true
      url: "/v1/clouds/#{@id}/users.json"
      success: (resp, status, xhr) =>
        _users = resp.filter (_user) =>
          return _.include(ids,_user.id)
        options.success(_users, status, xhr) if options.success

      error: (resp, xhr,_options) =>
        options.error(resp, xhr,_options) if options.error

  toJSON: ->
    obj =
      id: @id
      name: @get('name')
      description: @get('description')
      short_name: @get('short_name')
      hidden: @get('hidden')
      time_zone: @get('time_zone')
      rules: @get('rules')

    if @get('x_moderator_ids')
      obj.x_moderator_ids = @get('x_moderator_ids')
    if @get('remote_avatar_url')
      obj.remote_avatar_url = @get('remote_avatar_url')
    if @get('remove_avatar')
      obj.remove_avatar = @get('remove_avatar')

    return { cloud: obj }

  isModerator: (user) ->
    _.include(@get('moderator_ids'), user.id)

  # Bans {User} from @this
  #
  # @param {user}
  # @return false
  ban: (user,args) ->
    args ||= {}

