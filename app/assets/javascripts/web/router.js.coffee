Cloudsdale.Router.reopen
  location: 'history'

Cloudsdale.Router.map () ->
  @route 'root', path: '/'
  @route 'gaze', path: '/gaze'
  @route 'gaze.category', path: '/gaze/:category'
  @resource 'conversation', { path: '/convos/:topic' }
