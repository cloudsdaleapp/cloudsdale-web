jQuery.fn.twitterButton = (el,options) ->
  $('#twitter-wjs').remove()
  $(@)
  .append('<a href="https://twitter.com/share" class="twitter-share-button" data-text="Guys, join me and chat on" data-url="http://www.cloudsdale.org" data-via="Cloudsdale_org">Tweet</a>')
  .append('<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>')
