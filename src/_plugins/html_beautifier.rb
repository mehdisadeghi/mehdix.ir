# frozen_string_literal: true

begin
  require "htmlbeautifier"

  Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
    next unless [".html", ".xml"].include?(doc.output_ext)

    doc.output = HtmlBeautifier.beautify(doc.output)
  end
rescue LoadError
  Jekyll.logger.warn "HtmlBeautifier:", "gem not installed, skipping HTML formatting"
end
