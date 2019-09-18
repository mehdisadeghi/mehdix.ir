source "https://rubygems.org"

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
gem "jekyll", "~> 4.0"

gem "jekyll-theme-mehdix-rtl", "~> 3.0"#, :path => '../jekyll-theme-mehdix-rtl'
gem "jekyll-tagging-related_posts", :git => "https://github.com/mehdisadeghi/jekyll-tagging-related_posts", :ref => "a58844c"

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 2.0"
  gem "tzinfo-data"
end