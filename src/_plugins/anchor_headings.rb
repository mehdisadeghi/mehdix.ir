# frozen_string_literal: true

# Wraps heading content in anchor links for shareable section URLs.
# Kramdown generates IDs; this adds clickable anchors.

HEADING_RE = /<(h[2-6]) id="([^"]+)"[^>]*>(.+?)<\/\1>/m

Jekyll::Hooks.register [:posts, :pages], :post_render do |doc|
  doc.output.gsub!(HEADING_RE) do
    %(<#{$1} id="#{$2}"><a href="##{$2}">#{$3}</a></#{$1}>)
  end
end
