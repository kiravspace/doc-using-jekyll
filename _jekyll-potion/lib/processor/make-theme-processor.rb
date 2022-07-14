module Jekyll::Potion
  class MakeThemeProcessor < Processor
    priority :site_after_init, :highest
    priority :page_post_render, Processor::PRIORITY_MAP[:low] - 1

    JS_PATTERN = %r!^\.js$!i.freeze
    CSS_PATTERN = %r!^\.css$!i.freeze
    SCSS_PATTERN = Jekyll::Converters::Scss::EXTENSION_PATTERN

    def initialize(site, theme, config, tags)
      super
      init
    end

    def init
      @js_files = []
      @css_files = []
      @static_files = []
    end

    def site_after_init(site)
      # Potion[:themes].values.select { |theme| not theme[:internal] }
      #   .each { |theme| site.config["exclude"] << File.join(theme[:path], "") }

      permalink = find_default_scope(site)
      if permalink.nil?
        site.config["defaults"] << default_scope
      else
        if permalink.has_key?("values")
          permalink["values"]["layout"] = @theme[:default_layout]
        else
          permalink["values"] = { "layout" => @theme[:default_layout] }
        end

        permalink["values"]["permalink"] = @site[:permalink] unless @site.empty?(:permalink)
      end

      unless @site.empty?(:index_page)
        index = find_index_scope(site)

        if index.nil?
          site.config["defaults"] << index_scope
        else
          if index.has_key?("values")
            index["values"]["permalink"] = ""
          else
            index["values"] = { "permalink" => "" }
          end
        end
      end

      site.includes_load_paths << @theme[:includes_dir]
      site.config["layouts_dir"] = @theme[:layouts_dir]
      site.config["sass"]["sass_dir"] = @theme[:assets][:scss_source_dir]
    end

    def include_scss_file?(file_name)
      @theme[:assets][:scss_files].include?(file_name)
    end

    def site_post_read(site)
      init

      Util.load_files(@theme[:assets][:source_dir]) { |base, dir, file_name|
        case
        when scss_matches(file_name) && @theme[:assets][:scss_files].include?(file_name)
          scss_file = @theme.assets_scss_potion_page(base, dir, file_name)
          scss_map = @theme.assets_map_page(scss_file)
          @css_files << scss_file
          @static_files << scss_map
          @logger.trace("detect scss file #{File.join(@theme[:assets][:source_dir], dir, scss_file.name)}")
          @logger.trace("detect scss map file #{File.join(@theme[:assets][:source_dir], dir, scss_map.name)}")
        when js_matches(file_name)
          js_file = @theme.assets_static_file(base, dir, file_name)
          @js_files << js_file
          @logger.trace("detect javascript file #{File.join(@theme[:assets][:source_dir], dir, file_name)}")
        when css_matches(file_name)
          css_file = @theme.assets_static_file(base, dir, file_name)
          @css_files << css_file
          @logger.trace("detect css file #{File.join(@theme[:assets][:source_dir], dir, file_name)}")
        else
          @static_files << @theme.assets_static_file(base, dir, file_name)
          @logger.trace("detect static file #{File.join(@theme[:assets][:source_dir], dir, file_name)}")
        end
      }
    end

    def page_post_render(page, html, modified)
      head = html.css("head").first

      unless head.nil?
        priority_files = @theme[:assets][:priority_files]

        priority_files.each { |priority_filepath|
          file = @css_files.find { |file| priority_filepath == file.relative_path }
          head.add_child(css_meta(file, html)) unless file.nil?
        }

        @css_files.each { |file|
          next if priority_files.include?(file.relative_path)
          head.add_child(css_meta(file, html))
        }

        priority_files.each { |priority_filepath|
          file = @js_files.find { |file| priority_filepath == file.relative_path }
          head.add_child(js_meta(file, html)) unless file.nil?
        }

        @js_files.each { |file|
          next if priority_files.include?(file.relative_path)
          head.add_child(js_meta(file, html))
        }

        yield html
      end
    end

    def css_meta(file, html)
      link = Nokogiri::XML::Node.new("link", html)
      link["rel"] = "stylesheet"
      link["href"] = @site.base_url(file.relative_path)
      link
    end

    def js_meta(file, html)
      script = Nokogiri::XML::Node.new("script", html)
      script["type"] = "text/javascript"
      script["src"] = @site.base_url(file.relative_path)
      script
    end

    def find_scope(site, path)
      site.config["defaults"].find { |default| default.has_key?("scope") && default["scope"].has_key?("path") && default["scope"]["path"] == path }
    end

    def find_default_scope(site)
      find_scope(site, "")
    end

    def find_index_scope(site)
      find_scope(site, @site[:index_page])
    end

    def default_scope
      default_scope = {
        "scope" => {
          "path" => ""
        },
        "values" => {
          "layout" => Potion[:theme][:default_layout]
        }
      }
      default_scope["values"]["permalink"] = @site[:permalink] unless @site.empty?(:permalink)
      default_scope
    end

    def index_scope
      {
        "scope" => {
          "path" => @site[:index_page]
        },
        "values" => {
          "permalink" => ""
        }
      }
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

    def site_post_render(site)
      static_files = [@css_files, @js_files, @static_files].flatten

      in_theme_static_files = site.static_files.select { |file| file.relative_path.start_with?("/#{@theme[:path]}") }

      in_theme_static_files.each { |file| @logger.trace("remove previous theme static file #{file.relative_path}") }

      site.static_files -= in_theme_static_files
      site.static_files -= static_files

      static_files.each { |file| @logger.trace("add theme static file #{file.relative_path}") }

      site.static_files.concat(static_files)
    end
  end

end
