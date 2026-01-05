# frozen_string_literal: true

module Jekyll
  class CommentFeedGenerator < Generator
    safe true

    def generate(site)
      site.posts.docs.each do |post|
        site.pages << FeedPage.new(site, site.source, site.dest, post)
      end
    end
  end

  class FeedPage < Page
    def initialize(site, base, dir, post)
      @site = site
      @base = base
      @dir = dir
      @name = "#{post.id}.xml"

      process(@name)
      read_yaml(File.join(base, "_layouts"), "comments_feed.liquid")
      data["post_id"] = post.id.sub! "/", ""
      data["feed_title"] = post.data["title"]
    end
  end
end
