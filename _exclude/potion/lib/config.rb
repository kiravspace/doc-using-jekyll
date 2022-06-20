module Potion
  class Config < Liquid::Drop
    CONFIG_KEY = "potion"
    PRIORITY = 10

    THEME_KEY = "theme"
    THEME_PATH_KEY = "theme_path"
    TITLE_KEY = "title"
    IS_MAKE_TITLE_KEY = "is_make_title"
    IS_SHOW_PAGINATION_KEY = "is_show_pagination"
    IS_SHOW_EMPTY_TO_CHILD_PAGES_KEY = "is_show_empty_to_child_pages"

    TEMPLATE_PATH = "/_plugins/templates"

    DEFAULT = {
      THEME_KEY => "proto",
      TITLE_KEY => "",
      IS_MAKE_TITLE_KEY => true,
      IS_SHOW_PAGINATION_KEY => true,
      IS_SHOW_EMPTY_TO_CHILD_PAGES_KEY => true
    }

    def initialize(site)
      @site = site

      @config = {}

      DEFAULT.each do |key, value|
        @config[key] = site.config[CONFIG_KEY][key] ||= value
      end

      @config[THEME_PATH_KEY] = "theme/#{@config[THEME_KEY]}"
    end

    def self.load_config
      processors = []

      Jekyll::Hooks.register_one(:site, :after_init, PRIORITY) do |site|
        config = Config.new(site)

        processors << OptionalFrontMatterProcessor.new(config)
        processors << MakeTitleProcessor.new(config)
        processors << SitePotionProcessor.new(config)
        processors << SearchIndexProcessor.new(config)
      end

      Jekyll::Hooks.register_one(:site, :post_read, PRIORITY) do |site|
        processors.each { |p| p.site_post_read(site) }
      end

      Jekyll::Hooks.register_one(:site, :pre_render, PRIORITY) do |site|
        processors.each { |p| p.site_pre_render(site) }
      end

      Jekyll::Hooks.register_one(:pages, :pre_render, PRIORITY) do |page|
        processors.each { |p| p.page_pre_render(page) }
      end

      Jekyll::Hooks.register_one(:pages, :post_render, PRIORITY) do |page|
        processors.each { |p| p.page_post_render(page) }
      end
    end

    def make_site_data(key, value)
      @site.data[key] = value
    end

    def make_site_potion
      @site.data[CONFIG_KEY] = self
    end

    def theme_path
      "theme/#{@config[THEME_KEY]}"
    end

    def make_title?
      @config[IS_MAKE_TITLE_KEY]
    end

    def is_show_empty_to_child_pages?
      @config[IS_SHOW_EMPTY_TO_CHILD_PAGES_KEY]
    end

    def make_page(base, dir, name)
      Jekyll::Page.new(@site, base, dir, name)
    end

    def load_template(template_name)
      Logger.trace("==========================>", __dir__, Dir.pwd)
      Liquid::Template.parse(
        File.read("#{Dir.pwd}#{TEMPLATE_PATH}/#{@config[THEME_PATH_KEY]}/#{template_name}.liquid")
      )
    end

    def markdown_converter
      @site.find_converter_instance(Jekyll::Converters::Markdown)
    end

    def markdown_pages
      @site.pages.select { |page| markdown_converter.matches(page.extname) }
    end

    def static_markdown_files
      @site.static_files.select { |file| markdown_converter.matches(file.extname) }
    end
  end
end