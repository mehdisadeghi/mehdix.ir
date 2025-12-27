require "htmlbeautifier"

Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
  next unless doc.output_ext == ".html"
  doc.output = HtmlBeautifier.beautify(doc.output)
end
