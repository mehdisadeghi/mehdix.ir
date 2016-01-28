module Jekyll
  module URLJoinFilter
    def urljoin(*args)
      File.join(args.join('/').split('/').uniq)
    end
  end
end

Liquid::Template.register_filter(Jekyll::URLJoinFilter)
