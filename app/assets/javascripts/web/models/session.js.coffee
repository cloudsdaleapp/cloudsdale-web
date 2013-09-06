Cloudsdale.Session = DS.Model.extend

  user:          DS.belongsTo('user')
  conversations: DS.hasMany('conversation')

Cloudsdale.SessionAdapter = DS.CloudsdaleAdapter.extend(

  namespace: 'v2/me'

  buildURL: (type, id) ->
    url = []
    url.push @get('host')
    url.push @get('namespace')
    url.push type
    return url.join("/") + ".json"

)