# frozen_string_literal: true

require "bundler/setup"
require "fileutils"
require "yaml"
require "digest"
require "date"
require "json"

desc "Sync new comments from SQLite to YAML files"
task default: :comments
task :comments do
  require "sqlite3"
  require "fernet"

  secret = ENV.fetch("SECRET") { abort "SECRET not set" }
  dbpath = ENV.fetch("DBPATH", "mehdix.db")

  sync_comments(dbpath, secret, "src/_data/comments")
end

def sync_comments(dbpath, secret, comments_dir)
  FileUtils.mkdir_p(comments_dir)

  db = SQLite3::Database.new(dbpath)
  db.results_as_hash = true

  # Group comments by page_id
  comments_by_page = Hash.new { |h, k| h[k] = [] }

  db.execute("SELECT * FROM comments ORDER BY time") do |row|
    page_id = row["page_id"]&.sub(%r{^/}, "") || ""
    next if page_id.empty?

    email = row["email"] || ""
    comments_by_page[page_id] << {
      "id" => row["legacy_id"] || row["id"].to_s,
      "created_at" => row["time"],
      "reply_to" => row["reply_to"],
      "page_id" => row["page_id"],
      "name" => row["name"],
      "email" => Digest::MD5.hexdigest(email.encode("ascii", invalid: :replace, undef: :replace)),
      "bucket" => Fernet.generate(secret, email.to_json),
      "website" => row["website"],
      "message" => row["message"]
    }.compact
  end

  db.close

  # Write YAML files
  comments_by_page.each do |page_id, comments|
    yaml_file = File.join(comments_dir, "#{page_id}.yml")
    existing = File.exist?(yaml_file) ? YAML.safe_load_file(yaml_file, permitted_classes: [Time, DateTime]) || [] : []
    existing_times = existing.map { |c| c["created_at"] }

    incoming = comments.reject { |c| existing_times.include?(c["created_at"]) }

    if incoming.any?
      puts "Updating #{page_id}: #{incoming.size} new comments"
      File.open(yaml_file, "a") do |f|
        f.write(incoming.to_yaml.sub(/^---\n/, ""))
      end
    else
      puts "Already up to date: #{page_id}"
    end
  end
end
