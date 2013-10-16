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
        if match = /(^(beta|www)\.(cloudsdale)\.(org|dev)(\/.*)?)/ig.exec(url)

          if match[5]
            path = match[5].split('/')
            href = match[5]

            linkName = url

            if path.length == 2 and not ["gaze","settings"].contains(path[1])
              linkName = "@#{path[1]}"
            else if path.length == 3 and ["clouds","users"].contains(path[1])
              linkName = "@#{path[2]}"
              href = "/#{path[2]}"

            return "<a href='#{href}' #{lnkAttr.trim()} internal>#{linkName}</a>"

        return "<a href='#{full}' #{lnkAttr.trim()}>#{url}</a>"
      )
    else
      template = @replace(pattern, "<a href='$1'>$1</a>")

    return template

  String::["autoLink"] = autoLink

).call(this)