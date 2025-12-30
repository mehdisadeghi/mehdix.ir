# frozen_string_literal: true

# Jekyll plugin for generating tag pages and tag cloud with weighted sizes.
#
# Provides:
#   - Automatic /tag/<name>/ pages for each tag
#   - {{ tag | tag_url }} filter - returns URL for a tag
#   - {{ site | tag_cloud }} filter - returns HTML links with size classes
#
# Tag parsing:
#   - Supports quoted multi-word tags: tags: "Peter Hintjens" book
#   - Supports YAML arrays: tags: [foo, bar] or multiline
#
# Config (optional):
#   tag_page_dir:     "tag"         # output directory
#   tag_page_layout:  "tag_page"    # layout to use

module Jekyll
  # Parse tags string, respecting quoted multi-word tags.
  # "Pieter Hintjens" book → ["Pieter Hintjens", "book"]
  def self.parse_tags(value)
    return [] if value.nil?
    return value if value.is_a?(Array)
    return [value] unless value.is_a?(String)

    value.scan(/"([^"]+)"|(\S+)/).flatten.compact
  end

  # Converts a tag to a URL-safe slug.
  # Removes zero-width characters (ZWNJ, ZWJ, ZWSP) common in Persian/Arabic text.
  def self.slugify(tag)
    tag.to_s.downcase
      .gsub(/[\u200B-\u200D\uFEFF]/, "") # remove zero-width chars
      .gsub(/\s+/, "-") # spaces to dashes
  end

  class TagPageGenerator < Generator
    safe true

    def generate(site)
      # Pre-compute size buckets for all tags (used by tag_cloud filter)
      site.config["tag_buckets"] = compute_size_buckets(site.tags, 10)

      # Create a page for each tag
      site.tags.each do |tag, posts|
        site.pages << TagPage.new(site, tag, posts.sort_by(&:date).reverse)
      end
    end

    # Assigns each tag a "size bucket" (1 to N) based on how many posts it has.
    # Tags with more posts get higher bucket numbers → larger font in CSS.
    #
    # Example with 5 buckets:
    #   - Tag with fewest posts  → bucket 1 (smallest)
    #   - Tag with most posts    → bucket 5 (largest)
    #   - Tags in between        → buckets 2-4 proportionally
    #
    # Returns: {"ruby" => 5, "jekyll" => 2, "linux" => 3, ...}
    #
    def compute_size_buckets(tags, buckets)
      # Step 1: Count posts per tag
      # tags = {"ruby" => [post1, post2, ...], "jekyll" => [post1], ...}
      # counts = [["ruby", 10], ["jekyll", 2], ["linux", 5]]
      counts = tags.map { |tag, posts| [tag, posts.size] }

      # Step 2: Find the range (min and max post counts)
      min, max = counts.map(&:last).minmax

      # Edge case: all tags have the same count → everyone gets bucket 1
      return counts.to_h.transform_values { 1 } if min == max

      # Step 3: Assign each tag to a bucket using linear interpolation
      # Maps a value to a bucket number using linear interpolation.
      # Formula breakdown:
      #   1. (value - min) / (max - min)  →  position as 0.0 to 1.0
      #   2. * buckets                    →  scale to 0.0 to N
      #   3. .ceil                        →  round up (so 0.1 becomes 1, not 0)
      #   4. .clamp(1, buckets)           →  ensure result stays in 1..N range
      #
      counts.sort.to_h.transform_values do |n|
        ((n - min).to_f / (max - min) * buckets).ceil.clamp(1, buckets)
      end
    end
  end

  class TagPage < Page
    def initialize(site, tag, posts)
      @site = site
      @base = site.source

      dir = site.config["tag_page_dir"] || "tag"
      layout = site.config["tag_page_layout"] || "tag"

      # Build the output path: /tag/my-tag/index.html
      slug = Jekyll.slugify(tag)
      @dir = "#{dir}/#{slug}"
      @name = "index.html"

      # Required Jekyll::Page setup
      process(@name)
      read_yaml(File.join(@base, "_layouts"), "#{layout}.html")

      data["tag"] = tag
      data["title"] = tag
      data["items"] = posts
    end
  end

  module TaggingFilters
    # Usage: {{ "ruby" | tag_url }}  →  "/tag/ruby/"
    #
    def tag_url(tag)
      site = @context.registers[:site]
      dir = site.config["tag_page_dir"] || "tag"
      baseurl = site.config["baseurl"].to_s
      slug = Jekyll.slugify(tag)

      File.join(baseurl, dir, slug, "") # trailing "" ensures trailing slash
    end

    # Returns HTML for all tags as links with size classes.
    # Usage: {{ site | tag_cloud }}
    # Output: <a href="/tag/ruby/" class="set-5">ruby</a> <a href="/tag/jekyll/" class="set-1">jekyll</a>
    #
    def tag_cloud(_site_drop)
      site = @context.registers[:site]
      buckets = site.config["tag_buckets"] || {} # Injected at build time

      buckets.map do |tag, size_class|
        %(<a href="#{tag_url(tag)}" class="set-#{size_class}">#{tag}</a>)
      end.join(" ")
    end
  end
end

Liquid::Template.register_filter(Jekyll::TaggingFilters)

# Parse quoted tags from raw front matter (runs before TagPageGenerator)
Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each do |doc|
    next unless doc.data["tags"]

    full_path = File.join(site.source, doc.relative_path)
    next unless File.exist?(full_path)

    content = File.read(full_path)
    if content =~ /\A---\s*\n(.*?)\n---/m
      front_matter = $1
      if front_matter =~ /^tags:\s*(.+)$/
        raw_tags = $1.strip
        unless raw_tags.start_with?("[", "-")
          doc.data["tags"] = Jekyll.parse_tags(raw_tags)
        end
      end
    end
  end
end
