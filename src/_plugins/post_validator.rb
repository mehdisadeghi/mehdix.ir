module Jekyll
  class PostValidator < Generator
    safe true
    priority :high

    def generate(site)
      all_categories = Set.new
      tag_sources = {}  # tag => [posts using it as tag]

      site.posts.docs.each do |post|
        Array(post.data["category"]).each { |c| all_categories << c }
        Array(post.data["categories"]).each { |c| all_categories << c }
        Array(post.data["tags"]).each do |t|
          (tag_sources[t] ||= []) << post.relative_path
        end
      end

      overlap = all_categories & tag_sources.keys
      return if overlap.empty?

      Jekyll.logger.error ""
      Jekyll.logger.error "Post Validator: Categories and tags must not overlap."
      overlap.each do |term|
        Jekyll.logger.error "Post Validator: '#{term}' is a category but used as tag in:"
        tag_sources[term].each { |path| Jekyll.logger.error "Post Validator:   - #{path}" }
      end
      Jekyll.logger.error ""
      Jekyll.logger.error "Post Validator: Fix by removing from tags or renaming the category."
      Jekyll.logger.error ""
      exit! 1
    end
  end
end
