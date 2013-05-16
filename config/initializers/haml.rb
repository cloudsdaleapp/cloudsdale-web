require 'redcarpet'
require 'coderay'

module Haml::Filters

  remove_filter("Markdown")

  module Markdown

    include Haml::Filters::Base

    class CodeRayMarkdown < Redcarpet::Render::HTML
      def block_code(code, language)
        CodeRay.scan(code, language).html(
          wrap: :div,
          css:  :class
        )
      end
    end

    def render text
      markdown.render(text).html_safe
    end

  private

    def markdown

      coderay_markdown = CodeRayMarkdown.new(
        :filter_html        => true,
        :hard_wrap          => false
      )

      @markdown ||= Redcarpet::Markdown.new coderay_markdown, {
        autolink:         true,
        fenced_code:      true,
        generate_toc:     true,
        gh_blockcode:     true,
        hard_wrap:        false,
        no_intraemphasis: true,
        strikethrough:    true,
        tables:           true,
        xhtml:            true,
        superscript:      true,
        lax_html_blocks:  true,
        no_intra_emphasis: true,
        fenced_code_blocks: true,
      }

    end

  end

end
