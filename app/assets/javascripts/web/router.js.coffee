Cloudsdale.Router.reopen
  location: 'history'

Cloudsdale.Router.map () ->
  @route 'root',             { path: '/' }
  @route 'settings',         { path: '/settings' }
  @resource 'gaze',          { path: '/gaze' }
  @resource 'gaze.category', { path: '/gaze/:category' }
  @resource 'conversation',  { path: '/convos/:topic' }
