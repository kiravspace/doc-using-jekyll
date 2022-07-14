module Jekyll::Potion
  class MakeBaseJavascriptProcessor < Processor
    priority :site_after_init, :high
    priority :page_post_render, :low

    BASE_SCRIPT_PATH = "base".freeze
    BASE_SCRIPT_TEMPLATE_PATH = "base-template".freeze

    def initialize(site, theme, config, tags)
      super
      @base_dir = File.dirname(__FILE__)
      @base_dir["#{Dir.pwd}/"] = ""

      @script_files = []
    end

    def site_post_read(site)
      @script_files = []

      Util.load_files(@base_dir, BASE_SCRIPT_PATH) { |base, dir, file_name|
        @script_files << @theme.assets_static_file(File.join(base, dir), "", file_name, BASE_SCRIPT_PATH)
        @logger.trace("detect base javascript file #{File.join(@base_dir, dir, file_name)}")
      }
      Util.load_files(@base_dir, BASE_SCRIPT_TEMPLATE_PATH) { |base, dir, file_name|
        config = @tags[File.basename(file_name, ".*").to_sym]

        next if config.nil?

        script_file = @theme.assets_potion_page("", BASE_SCRIPT_PATH, file_name)
        script_file.output = @site.load_template(File.join(base, dir, file_name)).render(Util.string_key_hash(config))
        @script_files << script_file
        @logger.trace("detect base javascript file #{File.join(@base_dir, dir, file_name)}")
      }
    end

    def page_post_render(page, html, modified)
      head = html.css("head").first

      unless head.nil?
        @script_files.each { |file|
          script = Nokogiri::XML::Node.new("script", html)
          script["type"] = "text/javascript"
          script["src"] = @site.base_url(file.relative_path)
          head.add_child(script)
        }

        yield html
      end
    end

    def site_post_render(site)
      @script_files.each { |file| @logger.trace("add base javascript file #{file.relative_path}") }
      site.static_files -= @script_files
      site.static_files.concat(@script_files)
    end
  end
end
