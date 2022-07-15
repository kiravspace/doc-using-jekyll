module Jekyll::Potion
  require "nokogiri"

  class Potion
    @@potion = nil

    PRIORITY = 10

    CONFIG_KEY = "jekyll_potion".freeze
    SITE_KEY = "site".freeze
    THEME_KEY = "theme".freeze
    PROCESSOR_KEY = "processor".freeze

    def initialize(potion_base_dir, site)
      @logger = Logger.new(self)

      @mtime = {}
      @objects = {}

      raise SyntaxError, "config is empty" unless site.config.has_key?(CONFIG_KEY)

      config = site.config[CONFIG_KEY]

      @objects[:site] = Site.new(potion_base_dir, site, config[SITE_KEY])

      @objects[:site][:exclude].each { |file| site.config["exclude"] << file }

      Theme.initialize(@objects[:site], config[THEME_KEY])

      current_theme = Theme.theme(@objects[:site][:theme])
      @objects[:themes] = Theme.themes
      @objects[:theme] = current_theme
      @objects[:processors] = current_theme.processors_config
      @objects[:tags] = current_theme.tags_config

      processors = Processor.load_processors(@objects[:site], @objects[:theme], @objects[:processors], @objects[:tags], config[PROCESSOR_KEY])

      @processors = {}

      Processor::METHODS.each { |method|
        @processors[method] = processors.select { |processor| processor.class.method_defined?(method, false) }
                                .sort { |p1, p2| p2.find_priority(method) <=> p1.find_priority(method) }
      }
    end

    def [] (object_key)
      @objects[object_key]
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

    def modified?(page)
      if @mtime[page.path] != File.mtime(page.path)
        true
      else
        false
      end
    end

    def page_pre_render(page)
      is_update = false

      html = Nokogiri::HTML.parse(page.output)
      @processors[:page_pre_render].each { |processor| processor.page_pre_render(page, html, modified?(page)) { |_| is_update = true } }

      page.output = html.to_s if is_update
    end

    def page_post_render(page)
      is_update = false

      html = Nokogiri::HTML.parse(page.output)
      @processors[:page_post_render].each { |processor| processor.page_post_render(page, html, modified?(page)) { |_| is_update = true } }

      page.output = html.to_s if is_update

      @mtime[page.path] = File.mtime(page.path)
    end

    def site_post_render(site)
      @logger.error("site_post_render")
      @processors[:site_post_render].each { |processor| processor.site_post_render(site) }
    end

    def self.initialize(potion_base_dir, site)
      @@potion = Potion.new(potion_base_dir, site)
    end

    def self.[] (object_key)
      @@potion[object_key]
    end

    def self.process(method, arg)
      @@potion.method(method).call(arg)
    end

    def self.load(potion_base_dir)
      Jekyll::Hooks.register_one(:site, :after_init, PRIORITY) do |site|
        Potion.initialize(potion_base_dir, site)
        Potion.process(:site_after_init, site)
      end

      Jekyll::Hooks.register_one(:site, :post_read, PRIORITY) do |site|
        Potion.process(:site_post_read, site)
      end

      Jekyll::Hooks.register_one(:site, :pre_render, PRIORITY) do |site|
        Potion.process(:site_pre_render, site)
      end

      Jekyll::Hooks.register_one(:pages, :pre_render, PRIORITY) do |page|
        Potion.process(:page_pre_render, page)
      end

      Jekyll::Hooks.register_one(:pages, :post_render, PRIORITY) do |page|
        Potion.process(:page_post_render, page)
      end

      Jekyll::Hooks.register_one(:site, :post_render, PRIORITY) do |site|
        Potion.process(:site_post_render, site)
      end
    end
  end
end
