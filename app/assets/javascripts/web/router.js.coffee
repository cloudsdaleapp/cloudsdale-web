Cloudsdale.Router.reopen
  location: 'history'

Cloudsdale.Router.map () ->
  @route 'root',                 { path: '/' }
  @route 'settings',             { path: '/settings' }

  @route 'conversation.index',   { path: '/:handle' }
  @route 'conversation.info',    { path: '/:handle/info' }
  @route 'conversation.share',   { path: '/:handle/share' }

  @resource 'gaze',              { path: '/gaze' }, ->
    @route 'category',           { path: '/:category' }