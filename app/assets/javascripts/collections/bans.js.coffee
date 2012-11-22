class Cloudsdale.Collections.Bans extends Backbone.Collection

  model: Cloudsdale.Models.Ban

  initialize: (models,options) ->
    # wat

  activeOn: (jurisdiction) ->
    @filter (ban) ->
      idMatch = (ban.get('jurisdiction_id') == jurisdiction.id)
      isActive = ban.get('is_active')
      return isActive && idMatch

