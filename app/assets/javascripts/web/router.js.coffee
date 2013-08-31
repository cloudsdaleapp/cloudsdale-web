Cloudsdale.Router.reopen
  location: 'history'

Cloudsdale.Router.map () ->
  @route 'root',             { path: '/' }
  @resource 'gaze',          { path: '/gaze' }
  @resource 'gaze.category', { path: '/gaze/:category' }
  @resource 'conversation',  { path: '/convos/:topic' }
