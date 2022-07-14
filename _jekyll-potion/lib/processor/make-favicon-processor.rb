module Jekyll::Potion
  class MakeFaviconProcessor < Processor
    priority :page_post_render, Processor::PRIORITY_MAP[:low] - 3

    RELATIVE_PATH = %r!^\.!i.freeze

    FAVICON_KEY = "favicon".freeze
    FAVICON_PATH = "favicon".freeze

    def initialize(site, theme, config, tags)
      super
      @favicons = Favicons.new
      @favicon_tags = []
    end

    def favicon?
      not @site.empty?(:favicon)
    end

    def favicon_path
      File.dirname(@site[:favicon])
    end

    def read_favicon_file
      @site.read_file(@site[:favicon])
    end

    def site_after_init(site)
      if favicon?
        @favicon_path = favicon_path
      end
    end

    def site_post_read(site)
      if favicon?
        Nokogiri::HTML.parse(read_favicon_file).css("head").children.each { |tag|
          if tag.name == "link" and tag["href"] =~ RELATIVE_PATH
            url = @site.to_url(@favicon_path, tag["href"])

            unless @favicons.contains?(url.url)
              if url.name == "manifest.json"
                resolve_manifest(url)
              else
                @favicons.add(url.url, @theme.assets_static_file(url.path, "", url.name, FAVICON_PATH))
              end
            end

            tag["href"] = @theme.base_assets_url(FAVICON_PATH, url.name)
          elsif tag.name == "meta" and tag["content"] =~ RELATIVE_PATH
            url = @site.to_url(@favicon_path, tag["content"])
            @favicons.add(url.url, @theme.assets_static_file(url.path, "", url.name, FAVICON_PATH)) unless @favicons.contains?(url.url)
            tag["content"] = @theme.base_assets_url(FAVICON_PATH, url.name)
          end

          @favicon_tags << tag
        }
      end

      @favicons.values.each { |file| @logger.trace("detect favicon file #{file.relative_path}") }
    end

    def page_post_render(page, html, modified)
      if favicon?
        head = html.css("head").first

        unless head.nil?
          @favicon_tags.each { |favicon_tag| head.add_child(favicon_tag) }
          yield html
        end
      end
    end

    def site_post_render(site)
      if favicon?
        previous_static_files = site.static_files.select { |file| file.relative_path.start_with?("/#{@favicon_path}") }

        previous_static_files.each { |file| @logger.trace("remove previous favicon file #{file.relative_path}") }

        site.static_files -= previous_static_files

        @favicons.values.each { |file| @logger.trace("add favicon file #{file.relative_path}") }
        site.static_files.concat(@favicons.values)
      end
    end

    def resolve_manifest(m_path)
      manifest = @site.jsonify(m_path.url)

      if manifest.has_key?("icons")
        manifest["icons"]
          .select { |icon| icon.has_key?("src") }
          .each { |icon|
            url = @site.to_url(@favicon_path, icon["src"])
            @favicons.add(url.url, @theme.assets_static_file(url.path, "", url.name, FAVICON_PATH)) unless @favicons.contains?(url.url)
            icon["src"] = @theme.base_assets_url(FAVICON_PATH, url.name)
          }
      end

      manifest_file = @theme.assets_potion_page("", FAVICON_PATH, m_path.name)
      manifest_file.output = JSON.pretty_generate(manifest)

      @favicons.add(m_path.url, manifest_file) unless @favicons.contains?(m_path.url)
    end
  end
end
