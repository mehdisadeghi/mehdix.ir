# frozen_string_literal: true

# Simple TOC generator.
# Usage: {{ content | toc }}
# Enable per-page with `toc: true` in front matter.

module Jekyll
  module TocFilter
    HEADING_RE = /<(h[2-6]) id="([^"]+)"[^>]*>(.+?)<\/\1>/m

    def toc(content)
      return content unless @context.registers[:page]["toc"]

      headings = content.scan(HEADING_RE).map do |tag, id, text|
        clean_text = text.gsub(/<[^>]+>/, "")
        {level: tag[1].to_i, id: id, text: clean_text}
      end

      return content if headings.empty?

      toc_html = build_toc(headings)
      toc_html + content
    end

    private

    def build_toc(headings)
      return "" if headings.empty?

      html = %(<nav class="toc">\n)
      current_level = headings.first[:level]

      html += "<ul>\n"

      headings.each do |h|
        if h[:level] > current_level
          html += "<ul>\n" * (h[:level] - current_level)
        elsif h[:level] < current_level
          html += "</li>\n</ul>\n" * (current_level - h[:level])
          html += "</li>\n"
        else
          html += "</li>\n" unless h == headings.first
        end

        html += %(<li><a href="##{h[:id]}">#{h[:text]}</a>)
        current_level = h[:level]
      end

      html += "</li>\n"
      html += "</ul>\n" * (current_level - headings.first[:level] + 1)
      html += "</nav>\n"
    end
  end
end

Liquid::Template.register_filter(Jekyll::TocFilter)
