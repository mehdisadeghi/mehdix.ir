# frozen_string_literal: true

require "date"

module Jekyll
  class PageAgeChecker < Jekyll::Generator
    safe true

    def generate(site)
      stale_days = site.config.dig("comments", "stale_days") || 180

      site.posts.docs.each do |post|
        threshold_date = DateTime.now - stale_days
        post.data["is_stale"] = post.date < threshold_date.to_time
      end
    end
  end
end
