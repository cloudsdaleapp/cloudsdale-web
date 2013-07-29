Cloudsdale.Socket = DS.Model.extend

  accessToken:  DS.attr 'string'
  normalServer: DS.attr 'string'
  secureServer: DS.attr 'string'
  timeout:      DS.attr 'number'

  authExtention:
    outgoing: (message,callback) ->
      message.ext ||= {}
      message.ext.access_token = @accessToken
      callback(message)
    incoming: -> (message,callback) -> callback(message)

  init: -> @connect()

  subscribe: (channel) -> console.log "sub'd - #{channel}"

  unsubscribe: (channel) -> console.log "unsub'd - #{channel}"

  serverUri: -> if (location.protocol == "https:") then @get('secureServer') else @get('normalServer')

  connect: ->
    console.log "WAT"
    @connection = new Faye.Client(@serverUri(), {
      timeout: @timeout,
      endpoints: {
        websocket: @serverUri()
      }
    })

    @connection.addExtension(@authExtention)

    window.socket = this

    return true