module Jekyll::Potion
  class Theme
    @@themes = {}

    attr_reader :processors_config
    attr_reader :tags_config

    DEFAULT_THEME_CONFIG = {
      :internal => false,
      :path => "",
      :layouts_dir => "_layouts",
      :includes_dir => "_includes",
      :default_layout => "default",
      :assets => {
        :target_root_path => "_assets",
        :source_dir => "assets",
        :priority_files => [],
        :scss_source_dir => "_scss",
        :scss_files => []
      },
      :templates_dir => "_templates",
      :content_x_path => "main"
    }.freeze

    DEFAULT_THEME_RELATIVE_PATH = "/lib/theme".freeze

    DEFAULT_THEME = "proto".freeze

    DEFAULT_THEMES = [
      {
        "proto" => {
          "internal" => true,
          "path" => "proto",
          "assets" => {
            "priority_files" => ["js/jsrender.min.js"],
            "scss_files" => ["main.scss"]
          }
        }
      }
    ].freeze

    LIQUID_EXTENSION = ".liquid".freeze

    def initialize(name, site, config)
      @name = name
      @site = site
      @config = Util.extract(DEFAULT_THEME_CONFIG, config)

      raise SyntaxError, "themes.path must not null" if @config[:path].nil? or @config[:path].empty?

      if @config[:internal]
        @config[:path] = File.join(@site[:potion_base_dir], DEFAULT_THEME_RELATIVE_PATH, @name)
      end

      @config[:layouts_dir] = File.join(@config[:path], @config[:layouts_dir])
      @config[:includes_dir] = File.join(@config[:path], @config[:includes_dir])
      @config[:assets][:source_dir] = File.join(@config[:path], @config[:assets][:source_dir])
      @config[:assets][:scss_source_dir] = File.join(@config[:path], @config[:assets][:scss_source_dir])
      @config[:templates_dir] = File.join(@config[:path], @config[:templates_dir])

      @processors_config = ProcessorsConfig.new(config["processors"])
      @tags_config = TagsConfig.new(config["tags"])
    end

    def [] (key)
      @config[key]
    end

    def assets_static_file(base, dir, name, target = "")
      if target.empty?
        target = @config[:assets][:target_root_path]
      else
        target = File.join(@config[:assets][:target_root_path], target)
      end

      @site.static_file(base, dir, name, target)
    end

    def assets_potion_page(base, dir, name)
      @site.potion_page(base, dir, name, @config[:assets][:target_root_path])
    end

    def assets_scss_potion_page(base, dir, file_name)
      scss_file = assets_potion_page(base, dir, @site.replace_scss_ext(file_name))
      scss_file.output = @site.scss_convert(@site.read_file(File.join(base, dir, file_name)))
      scss_file
    end

    def assets_map_page(scss_file)
      PotionSourceMapPage.new(scss_file, @config[:assets][:target_root_path])
    end

    def base_assets_url(*args)
      File.join(File.join(@site.baseurl, @config[:assets][:target_root_path], *args))
    end

    def load_template(template_name, theme_path = "")
      begin
        theme_path = @config[:templates_dir] if theme_path.empty?
        @site.load_template(File.join(theme_path, [template_name, LIQUID_EXTENSION].join))
      rescue
        load_template(template_name, @@themes[DEFAULT_THEME][:templates_dir]) unless theme_path == @@themes[DEFAULT_THEME][:templates_dir]
      end
    end

    def render_template(template_name, context)
      load_template(template_name).render(context)
    end

    def self.initialize(site, config)
      DEFAULT_THEMES.each { |default_theme|
        @@themes[default_theme.keys[0]] = Theme.new(default_theme.keys[0], site, default_theme.values[0])
      }

      config.each { |theme|
        raise SyntaxError, "theme config is not valid" unless theme.size == 1
        @@themes[theme.keys[0]] = Theme.new(theme.keys[0], site, theme.values[0])
      }
    end

    def self.themes
      @@themes
    end

    def self.theme(theme_name)
      if @@themes.has_key?(theme_name)
        @@themes[theme_name]
      else
        @@themes[DEFAULT_THEME]
      end
    end
  end
end
