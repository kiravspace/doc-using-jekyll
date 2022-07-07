module Jekyll::Potion
  class Config < Liquid::Drop
    CONFIG_KEY = "jekyll-potion"

    PRIORITY = 10

    THEME_KEY = "theme"
    ASSETS_PATH_KEY = "assets"
    IS_SHOW_PAGINATION_KEY = "is_show_pagination"
    IS_SHOW_EMPTY_KEY = "is_show_empty"

    FAVICON_PATH_KEY = "path"
    FAVICON_ASSETS_KEY = "assets"
    PROCESSOR_KEY = "processors"

    SITE_KEY = "site"
    INDEX_PAGE_KEY = "index-page"
    PERMALINK_KEY = "permalink"
    TITLE_KEY = "title"
    ICON_KEY = "icon"
    SITE_THEME_KEY = "theme"
    FAVICON_KEY = "favicon"

    CUSTOM_THEMES_KEY = "custom-themes"

    DEFAULT = {
      PROCESSOR_KEY => [ # 필수, optional을 체크하고(필수는 빼고, optional), optional을 추가한다.
        "make-theme-processor",
        "make-front-matter-processor",
        "make-favicon-processor",
        "make-title-processor",
        "make-date-processor",
        "make-navigation-processor",
        "make-empty-content-processor",
        "rewrite-img-processor",
        "make-header-link-processor",
        "rewrite-a-href-processor",
        "make-search-index-processor",
        "make-og-tag-processor"
      ],
      SITE_KEY => {
        INDEX_PAGE_KEY => "",
        PERMALINK_KEY => "",
        TITLE_KEY => "",
        ICON_KEY => "",
        SITE_THEME_KEY => "proto",
        FAVICON_KEY => ""
      },
      CUSTOM_THEMES_KEY => []
    }

    POTION_KEY = "potion"

    ALL_PAGES_KEY = "all_pages"

    #####################################################################################################
    # 테마 설정은 Theme로 이동
    DEFAULT_THEME_NAME = "proto"

    DEFAULT_THEMES = [DEFAULT_THEME_NAME]

    METHODS = [
      :site_after_init,
      :site_post_read,
      :site_pre_render,
      :page_pre_render,
      :page_post_render,
      :site_post_render
    ]

    PRIORITY_MAP = {
      :lowest => 0,
      :low => 10,
      :normal => 20,
      :high => 30,
      :highest => 40,
    }.freeze

    attr_accessor :themes
    attr_reader :base_path
    attr_reader :site

    @@config = nil

    def initialize(site)
      @base_path = File.dirname(__FILE__)
      @base_path["#{Dir.pwd}/"] = ""

      @site = site
      @config = Merger.fill(site.config[CONFIG_KEY], DEFAULT)

      site.config["exclude"] << File.join(BASE_DIR, "")

      @processors = {}

      load_processors = @config[PROCESSOR_KEY].map { |processor| Processor.load_processor_class(processor) }

      METHODS.each { |method|
        processors = load_processors.select { |processor| processor.class.method_defined?(method, false) }
        processors.sort { |p1, p2| PRIORITY_MAP[p2.priority[method]] <=> PRIORITY_MAP[p1.priority[method]] }
        @processors[method] = processors
      }

      Tag.load_tag_classes(@base_path)

      @themes = {}
      @logger = Logger.new(self)
    end

    def permalink
      @config[SITE_KEY][PERMALINK_KEY]
    end

    def index_page
      @config[SITE_KEY][INDEX_PAGE_KEY]
    end

    def favicon
      @config[SITE_KEY][FAVICON_KEY]
    end

    def custom_themes
      @config[CUSTOM_THEMES_KEY]
    end

    def site_title
      @config[SITE_KEY][TITLE_KEY]
    end

    def site_icon
      @config[SITE_KEY][ICON_KEY]
    end

    def current_theme
      @themes[@config[SITE_KEY][SITE_THEME_KEY]]
    end

    def default_theme
      @themes[DEFAULT_THEME_NAME]
    end

    def markdown_converter
      @site.find_converter_instance(Jekyll::Converters::Markdown)
    end

    def site_after_init(site)
      @processors[:site_after_init].each { |processor| processor.site_after_init(site) }
    end

    def site_post_read(site)
      @processors[:site_post_read].each { |processor| processor.site_post_read(site) }
    end

    def site_pre_render(site)
      @processors[:site_pre_render].each { |processor| processor.site_pre_render(site) }
    end

    def page_pre_render(page)
      is_update = false

      html = Nokogiri::HTML.parse(page.output)
      @processors[:page_pre_render].each { |processor| processor.page_pre_render(page, html) { |_| is_update = true } }

      page.output = html.to_s if is_update
    end

    def page_post_render(page)
      is_update = false

      html = Nokogiri::HTML.parse(page.output)
      @processors[:page_post_render].each { |processor| processor.page_post_render(page, html) { |_| is_update = true } }

      page.output = html.to_s if is_update
    end

    def site_post_render(site)
      @processors[:site_post_render].each { |processor| processor.site_post_render(site) }
    end

    def self.initialize(site)
      @@config = Config.new(site)
      Util.initialize(@@config)
    end

    def self.potion
      @@config
    end

    def self.site
      @@config.site
    end

    def self.base_path
      @@config.base_path
    end

    def self.process(method, arg)
      @@config.method(method).call(arg)
    end

    def self.load_config
      Jekyll::Hooks.register_one(:site, :after_init, PRIORITY) do |site|
        Config.initialize(site)
        Config.process(:site_after_init, site)
      end

      Jekyll::Hooks.register_one(:site, :post_read, PRIORITY) do |site|
        Config.process(:site_post_read, site)
      end

      Jekyll::Hooks.register_one(:site, :pre_render, PRIORITY) do |site|
        Config.process(:site_pre_render, site)
      end

      Jekyll::Hooks.register_one(:pages, :pre_render, PRIORITY) do |page|
        Config.process(:page_pre_render, page)
      end

      Jekyll::Hooks.register_one(:pages, :post_render, PRIORITY) do |page|
        Config.process(:page_post_render, page)
      end

      Jekyll::Hooks.register_one(:site, :post_render, PRIORITY) do |site|
        Config.process(:site_post_render, site)
      end
    end
  end
end
