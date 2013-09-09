Cloudsdale.SpotlightController = Ember.ObjectController.extend({

  foo: "bar"

  foobar: ( () ->
    switch @get('target').get('type')
      when "cloud"
        return @get('target').get('participant_count') + " participants"
      when "user"
        return "foobar"
      else
        return "fix"
  ).property('target.participant_count')

})