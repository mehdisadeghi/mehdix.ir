module Jekyll
  module URLJoinFilter
    def urljoin(first, second)
      print first
      print second
      File.join(first, second)
    end
  end
end

Liquid::Template.register_filter(Jekyll::URLJoinFilter)
