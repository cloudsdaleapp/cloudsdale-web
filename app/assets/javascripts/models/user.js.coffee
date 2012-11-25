class Cloudsdale.Models.User extends Backbone.Model

  url: -> "/v1/users/#{@id}.json"
  type: 'user'

  defaults:
    name: ""
    avatar: {}
    clouds: []
    bans: undefined
    email: ""
    time_zone: ""
    role: "normal"
    member_since: null
    invisible: false
    is_transient: true
    avatar_url: null
    status: "offline"

  initialize: (args,options) ->

    @bans = new Cloudsdale.Collections.Bans()

    if args.bans
      @bans.add(args.bans)
      delete @attributes['bans']

    this


  acceptTnc: (attr) ->
    attr ||= {}
    attr.url = "/v1/users/#{@id}/accept_tnc.json"
    return @save({},attr)

  removeAvatar: (options) ->
    attr = {}
    attr.remove_avatar = true
    return @save(attr,options)

  memberSince: ->
    new Date(@get('member_since'))

  ban: (attr) ->
    attr ||= {}
    attr.url = "/v1/users/#{@id}/ban.json"
    return @save({},attr)

  unban: (attr) ->
    attr ||= {}
    attr.url = "/v1/users/#{@id}/unban.json"
    return @save({},attr)

  addCloud: (cloud,options) ->

    options = {} unless options

    options.url = "/v1/clouds/#{cloud.id}/users/#{@id}.json"
    options.type = 'PUT'

    return @save({},options)

  leaveCloud: (cloud,options) ->

    options = {} unless options

    options.url = "/v1/clouds/#{cloud.id}/users/#{@id}.json"
    options.type = 'DELETE'

    return @save({},options)

  toJSON: ->
    obj =
      id: @id
      name: @get('name')
      email: @get('email')
      invisible: @get('invisible')
      time_zone: @get('time_zone')
      preferred_status: @get('preferred_status')

    if @get('password')
      obj.password = @get('password')
    if @get('remote_avatar_url')
      obj.remote_avatar_url = @get('remote_avatar_url')
    if @get('remove_avatar')
      obj.remove_avatar = @get('remove_avatar')
    if @get('skype_name')
      obj.skype_name = @get('skype_name')

    return { user: obj }

  toBroadcastJSON: ->
    obj = @toJSON()
    _.pick obj, "id"

  toSelectable: ->
    return { id: @id, text: @get('name'), avatar: @get('avatar').mini }

  # Checks if @this outranks a {User} on a {Cloud}
  #
  # @this {User}
  # @param {user} an instance of {User}
  # @param {cloud} an instance of {Cloud}
  # @return {boolean} about if the statement is true or false
  outRanksOn: (user,cloud) ->
    @rankOn(cloud) > user.rankOn(cloud)

  # Checks what rank @this has in relation to {Cloud}
  #
  # @this {User}
  # @param {cloud} an instance of {Cloud}
  # @return {number} 0 is not a member, 1 is a normal member, 2 is a moderator and 3 is the owner
  rankOn: (cloud) ->
    if cloud.get('owner_id') == @id
      return 3
    else if _.include(cloud.get('moderator_ids'), @id)
      return 2
    else if _.include(cloud.get('user_ids'), @id)
      return 1
    else
      return 0

  numericStatus: ->
    switch @get('status')
      when 'online' then 0
      when 'away' then 0
      when 'busy' then 0
      when 'offline' then 1

