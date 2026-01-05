# frozen_string_literal: true

# CGI support: executable permissions on build, POST handling in dev server.

require "webrick"
require "open3"

Jekyll::Hooks.register :site, :post_write do |site|
  cgi_dir = File.join(site.dest, "cgi-bin")
  next unless Dir.exist?(cgi_dir)

  Dir.glob(File.join(cgi_dir, "*")).each do |script|
    File.chmod(0o755, script) if File.file?(script)
  end
end

module Jekyll
  module Commands
    class Serve
      class CgiServlet < WEBrick::HTTPServlet::AbstractServlet
        def initialize(server, root)
          super(server)
          @root = root
        end

        def do_POST(req, res)
          script = File.join(@root, req.path)
          unless File.executable?(script)
            res.status = 404
            res.body = "Not found: #{req.path}"
            return
          end

          # Prepend bin/ to PATH for dev mocks (e.g., mail command)
          bin_path = File.expand_path("../bin", @root)
          env = {
            "PATH" => "#{bin_path}:#{ENV["PATH"]}",
            "HTTP_USER_AGENT" => req["User-Agent"],
            "REMOTE_ADDR" => req.peeraddr[2],
            "CONTENT_TYPE" => req.content_type,
            "CONTENT_LENGTH" => req.content_length.to_s
          }

          stdout, stderr, = Open3.capture3(env, script, stdin_data: req.body, binmode: true)
          warn stderr unless stderr.empty?

          headers, body = stdout.force_encoding("UTF-8").split("\r\n\r\n", 2)
          headers.each_line do |line|
            key, value = line.strip.split(": ", 2)
            res[key] = value if key && value
          end
          res.body = body
        end
      end

      module CgiSupport
        def boot_or_detach(server, opts)
          server.mount("/cgi-bin", CgiServlet, opts["destination"])
          Jekyll.logger.info "CGI:", "POST to /cgi-bin/* enabled"
          super
        end
      end

      class << self
        prepend CgiSupport
      end
    end
  end
end
