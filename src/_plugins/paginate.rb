# frozen_string_literal: true

# Simple pagination generator. Replaces jekyll-paginate gem.
# Config: paginate (default: 10), paginate_path (default: /page:num/)

module Jekyll
  # Define the module Jekyll checks for to suppress deprecation warning
  module Paginate
  end

  class Paginator
    attr_reader :page, :total_pages, :posts, :previous_page, :next_page,
      :previous_page_path, :next_page_path

    def initialize(page:, total_pages:, posts:, previous_page:, next_page:,
      previous_page_path:, next_page_path:)
      @page = page
      @total_pages = total_pages
      @posts = posts
      @previous_page = previous_page
      @next_page = next_page
      @previous_page_path = previous_page_path
      @next_page_path = next_page_path
    end

    def to_liquid
      {
        "page" => @page,
        "total_pages" => @total_pages,
        "posts" => @posts,
        "previous_page" => @previous_page,
        "next_page" => @next_page,
        "previous_page_path" => @previous_page_path,
        "next_page_path" => @next_page_path
      }
    end
  end

  class PaginationPage < Page
    def initialize(site, base, dir, index_page, paginator)
      @site = site
      @base = base
      @dir = dir
      @name = "index.html"

      process(@name)
      read_yaml(File.join(base, "_layouts"), index_page.data["layout"] + ".html")

      self.data = index_page.data.dup
      data["paginator"] = paginator
      self.content = index_page.content
    end
  end

  class PaginateGenerator < Generator
    safe true
    priority :lowest

    def generate(site)
      per_page = site.config["paginate"] || 10
      path_pattern = site.config["paginate_path"] || "/page:num/"
      posts = site.posts.docs.reverse

      total_pages = (posts.size.to_f / per_page).ceil
      return if total_pages <= 1

      index_page = site.pages.find { |p| p.name == "index.html" && p.data["paginate"] }
      return unless index_page

      (1..total_pages).each do |page_num|
        start_idx = (page_num - 1) * per_page
        page_posts = posts.slice(start_idx, per_page)

        prev_page = (page_num > 1) ? page_num - 1 : nil
        next_page = (page_num < total_pages) ? page_num + 1 : nil

        prev_path = (prev_page == 1) ? "/" : path_pattern.sub(":num", prev_page.to_s)
        next_path = next_page ? path_pattern.sub(":num", next_page.to_s) : nil

        paginator = Paginator.new(
          page: page_num,
          total_pages: total_pages,
          posts: page_posts,
          previous_page: prev_page,
          next_page: next_page,
          previous_page_path: prev_page ? prev_path : nil,
          next_page_path: next_path
        )

        if page_num == 1
          index_page.data["paginator"] = paginator
        else
          dir = path_pattern.sub(":num", page_num.to_s).sub(%r{^/}, "").sub(%r{/$}, "")
          site.pages << PaginationPage.new(site, site.source, dir, index_page, paginator)
        end
      end
    end
  end
end
