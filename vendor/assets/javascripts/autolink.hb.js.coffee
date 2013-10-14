(->

  autoLink = undefined
  __slice_ = Array::slice

  autoLink = ->
    key     = undefined
    lnkAttr = undefined
    options = undefined
    pattern = undefined
    value   = undefined
    _ref    = undefined

    options = (if 1 <= arguments.length then __slice_.call(arguments, 0) else [])
    pattern = /(\b(https?):\/\/([\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|]))/ig

    if options.length > 0
      lnkAttr = ""
      _ref = options[0]
      for key of _ref
        value = _ref[key]
        lnkAttr += " " + key + "='" + value + "'"
      template = @replace(pattern, (string, full, schema, url, index) ->
        match = /(\b(beta)\.(cloudsdale)\.(dev|org)(\/.*)?)/ig.exec(url)

        if match
          path = match[5].split('/')
          linkName = url
          linkName = "@#{path[1]}" if path.length == 2
          return "<a href='#{match[5]}' #{lnkAttr.trim()} internal>#{linkName}</a>"
        else
          return "<a href='#{full}' #{lnkAttr.trim()}>#{url}</a>"
      )
    else
      template = @replace(pattern, "<a href='$1'>$1</a>")

    return template

  String::["autoLink"] = autoLink

).call(this)