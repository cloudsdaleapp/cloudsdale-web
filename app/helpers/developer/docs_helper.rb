module Developer::DocsHelper

  # Public: Renders a document sidebar link and activates it
  # if it matches the current documentation page.
  #
  # name - The name to be displaied in the menu as well as the title tag.
  # page - The page ID which should be linked ti.
  #
  # Returns a HTML li tag containing a HTML link tag.
  def docs_sidebar_link_to(name,page='introduction')
    current_page ||= @page_id || 'introduction'
    href         = (page == 'introduction') ? docs_path : doc_path(page)
    active       = (current_page == page)
    content_tag(:li,
      content_tag(:a, name,
        :href => href,
        :title => name
      ),
      :class => active ? 'active' : ''
    )
  end

end
