module Jekyll::Potion
  class MakeHeaderLinkProcessor < Processor
    priority :site_after_init, :normal
    priority :page_post_render, Processor::PRIORITY_MAP[:low] - 2

    SCRIPT_TEMPLATE_PATH = "header-template".freeze

    SELECTOR_KEY = "selector".freeze
    HASH_CLASS_KEY = "hash_class".freeze
    COPY_CLASS_KEY = "copy_class".freeze

    DEFAULT_CONFIG = {
      SELECTOR_KEY => "data-header-link",
      HASH_CLASS_KEY => "go-hash",
      COPY_CLASS_KEY => "copy-link"
    }

    def initialize(site, theme, config, tags)
      super
      @base_dir = File.dirname(__FILE__)
      @base_dir["#{Dir.pwd}/"] = ""

      @script_files = []
    end

    def site_after_init(site)
      Util.load_files(@base_dir, SCRIPT_TEMPLATE_PATH) { |base, dir, file_name|
        script_file = @theme.assets_potion_page("", MakeBaseJavascriptProcessor::BASE_SCRIPT_PATH, file_name)
        script_file.output = @site.load_template(File.join(base, dir, file_name)).render(Util.string_key_hash(@config))
        @script_files << script_file
      }
    end

    def page_post_render(page, html, modified)
      if modified
        update_a_tag_count = 0
        create_a_tag_count = 0

        html.css("h1", "h2", "h3", "h4", "h5", "h6")
          .select { |h_tag| h_tag.has_attribute?("id") }
          .each { |h_tag|
            id = h_tag["id"]

            next if id.strip.empty?

            a_tag = h_tag.css("a").first

            target_hash = ""

            if a_tag.nil?
              create_a_tag_count += 1
              new_a_tag = Nokogiri::XML::Node.new("a", html)
              new_a_tag["href"] = "##{id}"
              target_hash = "##{id}"
              new_a_tag.add_class(@config[:hash_class])
              h_tag.add_child(new_a_tag)
            else
              update_a_tag_count += 1
              if a_tag.has_attribute?("id")
                a_tag["href"] = "##{a_tag["id"]}"
                target_hash = "##{a_tag["id"]}"
              else
                a_tag["href"] = "##{id}"
                target_hash = "##{id}"
              end
              a_tag.add_class(@config[:hash_class])
            end

            copy_link = Nokogiri::XML::Node.new("div", html)
            copy_link.add_class(@config[:copy_class])

            absolute_href = @site.base_absolute_url(page.url)

            copy_link[@config[:selector]] = "#{absolute_href}#{target_hash}"
            h_tag.add_child(copy_link)
          }

        @logger.trace("#{page.name} update header #{update_a_tag_count} a tags href update, #{create_a_tag_count} a tag create")
      end

      head = html.css("head").first

      unless head.nil?
        @script_files.each { |file|
          script = Nokogiri::XML::Node.new("script", html)
          script["type"] = "text/javascript"
          script["src"] = @site.base_url(file.relative_path)
          head.add_child(script)
        }
      end

      yield html
    end

    def site_post_render(site)
      @script_files.each { |file| @logger.trace("add base javascript file #{file.relative_path}") }
      site.static_files -= @script_files
      site.static_files.concat(@script_files)
    end
  end
end
