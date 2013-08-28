Cloudsdale.Router.reopen
  location: 'history'

Cloudsdale.Router.map () ->
  @route 'root', path: '/'
  @resource 'conversation', { path: '/convos/:topic' }
