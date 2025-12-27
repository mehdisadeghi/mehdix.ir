module Jekyll
  class RelatedPostsByTags < Generator
    safe true
    priority :low

    def generate(site)
      site.posts.docs.each do |post|
        post.data["related_posts"] = find_related(post, site.posts.docs)
      end
    end

    private

    def find_related(post, all_posts)
      others = all_posts.reject { |p| p == post }

      # Try matching by tags first
      tags = post.data["tags"] || []
      unless tags.empty?
        by_tags = others
          .map { |p| [p, (p.data["tags"] || []) & tags] }
          .select { |_, shared| shared.any? }
          .sort_by { |_, shared| -shared.size }
          .take(5)
          .map(&:first)
        return by_tags if by_tags.any?
      end

      # Fallback to category
      category = post.data["category"] || post.data["categories"]&.first
      return [] unless category

      others
        .select { |p| (p.data["category"] || p.data["categories"]&.first) == category }
        .sort_by { |p| -p.date.to_i }
        .take(5)
    end
  end
end
