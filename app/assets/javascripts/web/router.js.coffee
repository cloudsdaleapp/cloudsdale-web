Cloudsdale.Router.reopen
  location: 'history'

Cloudsdale.Router.map () ->
  @route 'root',                 { path: '/' }
  @route 'settings',             { path: '/settings' }

  @resource 'conversation',      { path: '/:handle' }, ->
    @route 'index',              { path: '/' }
    @resource 'messages',        { path: '/' }

  @route 'conversation.info',    { path: '/:handle/info' }
  @route 'conversation.share',   { path: '/:handle/share' }

  @resource 'gaze',              { path: '/gaze' }, ->
    @route 'category',           { path: '/:category' }