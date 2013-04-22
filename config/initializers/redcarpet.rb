require 'redcarpet'
require 'redcarpet/render_strip'

REDCARPET_DEFAULTS = {
  :no_intra_emphasis => true,
  :autolink => true,
  :tables => true,
  :fenced_code_blocks => true,
  :space_after_headers => true
}

REDCARPET_HTML_DEFAULTS = REDCARPET_DEFAULTS.merge({
  :filter_html => true,
  :hard_wrap => true,
  :link_attributes => true
})
