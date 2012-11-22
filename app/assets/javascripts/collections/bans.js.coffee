class Cloudsdale.Collections.Bans extends Backbone.Collection

  model: Cloudsdale.Models.Ban

  initialize: (models,options) ->
    options ||= {}
    @url = options.url if options.url

  activeOn: (jurisdiction) ->
    @filter (ban) ->
      idMatch = (ban.get('jurisdiction_id') == jurisdiction.id)
      isActive = ban.get('is_active')
      return isActive && idMatch

  findOrInitialize: (args,options) ->
    args ||= {}

    ban = @get(args.id)
    if ban
      ban.set(args)
      return ban
    else
      ban = new Cloudsdale.Models.Ban(args)
      @add(ban)
      return ban
