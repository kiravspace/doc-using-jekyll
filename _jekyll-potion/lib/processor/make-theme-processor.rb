module Jekyll::Potion
  class MakeThemeProcessor < Processor
    priority :site_after_init, :highest

    JS_PATTERN = %r!^\.js$!i.freeze
    CSS_PATTERN = %r!^\.css$!i.freeze
    SCSS_PATTERN = Jekyll::Converters::Scss::EXTENSION_PATTERN

    def initialize
      super
      @js_files = []
      @css_files = []
      @scss_files = []
      @static_files = []
    end

    def site_after_init(site)
      themes = Config::DEFAULT_THEMES.map { |theme_name| Util[:theme].theme_default(theme_name) }
      Config.potion.custom_themes.each { |theme| themes << Theme.custom(theme.keys[0], theme.values[0]) }

      Config.potion.themes = themes.map { |theme| [theme.name, theme] }.to_h

      Config.potion.themes.values.select { |theme| !theme.is_default? }
            .each { |theme| site.config["exclude"] << File.join(theme.theme_path, "") }

      permalink = find_default_scope(site)
      if permalink.nil?
        site.config["defaults"] << Util[:theme].default_scope
      else
        Merger.merge!(Util[:theme].default_scope, permalink)
      end

      if Util[:theme].index_page?
        index = find_index_scope(site)

        if index.nil?
          site.config["defaults"] << Util[:theme].index_scope
        else
          Merger.merge!(Util[:theme].index_scope, index)
        end
      end

      site.includes_load_paths << Util[:theme].includes
      site.config["layouts-dir"] = Util[:theme].layouts

      site.config["sass"]["sass_dir"] = Util[:theme].scss_source_dir
    end

    def site_post_read(site)
      Util[:theme].load_files_in_assets { |base, dir, file_name|
        case
        when scss_matches(file_name) && Util[:theme].include_scss_file?(file_name)
          scss_file = Util[:page].assets_scss_potion_page(base, dir, file_name)
          scss_map = Util[:page].assets_map_page(scss_file)
          @scss_files << scss_file
          @static_files << scss_map
          @logger.trace("add scss file #{File.join(dir, scss_file.name)}")
          @logger.trace("add scss map file #{File.join(dir, scss_map.name)}")
        when js_matches(file_name)
          js_file = Util[:page].assets_static_file(base, dir, file_name)
          @js_files << js_file
          @logger.trace("add javascript file #{File.join(dir, file_name)}")
        when css_matches(file_name)
          css_file = Util[:page].assets_static_file(base, dir, file_name)
          @css_files << css_file
          @logger.trace("add css file #{File.join(dir, file_name)}")
        else
          @static_files << Util[:page].assets_static_file(base, dir, file_name)
          @logger.trace("add static file #{File.join(dir, file_name)}")
        end
      }
    end

    def page_post_render(page, html)
      head = html.css("head").first
      @scss_files.each { |scss_file|
        link = Nokogiri::XML::Node.new("link", html)
        link["rel"] = "stylesheet"
        link["href"] = Util[:url].base_url(scss_file.relative_path)
        head.add_child(link)
      }
      @css_files.each { |css_file|
        link = Nokogiri::XML::Node.new("link", html)
        link["rel"] = "stylesheet"
        link["href"] = Util[:url].assets_base_url(css_file.relative_path)
        head.add_child(link)
      }
      @js_files.each { |js_file|
        script = Nokogiri::XML::Node.new("script", html)
        script["type"] = "text/javascript"
        script["src"] = Util[:url].assets_base_url(js_file.relative_path)
        head.add_child(script)
      }
      yield html
    end

    def site_post_render(site)
      static_files = [@scss_files, @css_files, @js_files, @static_files].flatten
      site.static_files -= static_files
      site.static_files.concat(static_files)
    end

    def find_scope(site, path)
      site.config["defaults"].find { |default| default.has_key?("scope") && default["scope"].has_key?("path") && default["scope"]["path"] == path }
    end

    def find_default_scope(site)
      find_scope(site, "")
    end

    def find_index_scope(site)
      find_scope(site, Util[:theme].index_page)
    end

    def js_matches(file_name)
      File.extname(file_name).match?(JS_PATTERN)
    end

    def css_matches(file_name)
      File.extname(file_name).match?(CSS_PATTERN)
    end

    def scss_matches(file_name)
      File.extname(file_name).match?(SCSS_PATTERN)
    end
  end
end
