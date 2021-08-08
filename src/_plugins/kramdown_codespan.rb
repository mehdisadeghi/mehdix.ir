require 'kramdown/converter/html'

module StandaloneCodespans
  def convert_codespan(el, indent)
    el.attr["dir"] = "ltr"
    super
  end
end

Kramdown::Converter::Html.prepend StandaloneCodespans
