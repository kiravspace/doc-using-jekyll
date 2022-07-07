module Jekyll::Potion
  class MakeFaviconProcessor < Processor
    RELATIVE_PATH = %r!^\.!i.freeze

    FAVICON_PATH = "favicon"

    def initialize
      super
      @favicons = Favicons.new
      @favicon_tags = []
    end

    def site_after_init(site)
      if Util[:site].favicon?
        @favicon_path = Util[:site].favicon_path
        site.config["exclude"] << File.join(@favicon_path, "")
      end
    end

    def site_post_read(site)
      load_favicon if Util[:site].favicon?
    end

    def page_post_render(page, html)
      if Util[:site].favicon?
        head = html.css("head").first
        @favicon_tags.each { |favicon_tag| head.add_child(favicon_tag) }
        yield html
      end
    end

    def site_post_render(site)
      site.static_files -= site.static_files.select { |file| file.is_a?(Jekyll::StaticFile) && @favicons.keys.include?(file.url) }
      site.static_files.concat(@favicons.values)
    end

    def load_favicon
      Nokogiri::HTML.parse(Util[:site].read_favicon_file).css("head").children.each { |tag|
        if tag.name == "link" and tag["href"] =~ RELATIVE_PATH
          path = Util[:path].to_path(@favicon_path, tag["href"])

          unless @favicons.contains?(path.url)
            if path.name == "manifest.json"
              resolve_manifest(path)
            else
              @favicons.add(path.url, Util[:page].assets_static_file(path.path, "", path.name, FAVICON_PATH))
            end
          end

          tag["href"] = Util[:url].assets_base_url(FAVICON_PATH, path.name)
        elsif tag.name == "meta" and tag["content"] =~ RELATIVE_PATH
          path = Util[:path].to_path(@favicon_path, tag["content"])
          @favicons.add(path.url, Util[:page].assets_static_file(path.path, "", path.name, FAVICON_PATH)) unless @favicons.contains?(path.url)
          tag["content"] = Util[:url].assets_base_url(FAVICON_PATH, path.name)
        end

        @favicon_tags << tag
      }
    end

    def resolve_manifest(m_path)
      manifest = Util[:file].jsonify(m_path.url)

      if manifest.has_key?("icons")
        manifest["icons"]
          .select { |icon| icon.has_key?("src") }
          .each { |icon|
            path = Util[:path].to_path(@favicon_path, icon["src"])
            @favicons.add(path.url, Util[:page].assets_static_file(path.path, "", path.name, FAVICON_PATH)) unless @favicons.contains?(path.url)
            icon["src"] = Util[:url].assets_base_url(FAVICON_PATH, path.name)
          }
      end

      manifest_file = Util[:page].assets_potion_page(FAVICON_PATH, m_path.name)
      manifest_file.output = JSON.pretty_generate(manifest)

      @favicons.add(m_path.url, manifest_file) unless @favicons.contains?(m_path.url)
    end
  end
end
