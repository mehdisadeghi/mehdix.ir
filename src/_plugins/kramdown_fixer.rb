# frozen_string_literal: true

require "kramdown/converter/html"
require "kramdown/parser/kramdown"

module StandaloneCodespans
  def convert_codespan(el, indent)
    el.attr["dir"] = "ltr"
    super
  end
end

module PersianFootnotes
  PERSIAN_DIGITS = "۰۱۲۳۴۵۶۷۸۹".chars.freeze

  def to_persian(num)
    num.to_s.gsub(/\d/) { |d| PERSIAN_DIGITS[d.to_i] }
  end

  def convert_footnote(el, _indent)
    repeat = ""
    name = @options[:footnote_prefix] + el.options[:name]
    if (footnote = @footnotes_by_name[name])
      number = footnote[2]
      repeat = ":#{footnote[3] += 1}"
    else
      number = @footnote_counter
      @footnote_counter += 1
      @footnotes << [name, el.value, number, 0]
      @footnotes_by_name[name] = @footnotes.last
    end
    display_number = to_persian(number)
    "<sup id=\"fnref:#{name}#{repeat}\">" \
      "<a href=\"#fn:#{name}\" class=\"footnote\" rel=\"footnote\" role=\"doc-noteref\">" \
      "#{display_number}</a></sup>"
  end
end

Kramdown::Converter::Html.prepend PersianFootnotes
Kramdown::Converter::Html.prepend StandaloneCodespans

# Patch kramdown to accept Unicode digits in footnotes (e.g., [^۱] for Persian)
module Kramdown
  module Parser
    class Kramdown
      # Unicode-aware patterns: \p{L} = letters, \p{N} = numbers, \p{M} = marks
      UNICODE_ID_CHARS = /[\p{L}\p{N}\p{M}_-]/
      UNICODE_ID_NAME = /[\p{L}\p{N}\p{M}_]#{UNICODE_ID_CHARS}*/

      remove_const(:FOOTNOTE_DEFINITION_START) if const_defined?(:FOOTNOTE_DEFINITION_START)
      remove_const(:FOOTNOTE_MARKER_START) if const_defined?(:FOOTNOTE_MARKER_START)

      FOOTNOTE_DEFINITION_START = /^#{OPT_SPACE}\[\^(#{UNICODE_ID_NAME})\]:\s*?(.*?\n#{CODEBLOCK_MATCH})/
      FOOTNOTE_MARKER_START = /\[\^(#{UNICODE_ID_NAME})\]/

      # Update existing parser registrations with new regex patterns
      @@parsers[:footnote_definition] =
        Data.new(:footnote_definition, FOOTNOTE_DEFINITION_START, nil, "parse_footnote_definition")
      @@parsers[:footnote_marker] = Data.new(:footnote_marker, FOOTNOTE_MARKER_START, '\[', "parse_footnote_marker")
    end
  end
end
