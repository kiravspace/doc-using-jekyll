require "nokogiri"

module Jekyll::Potion
  class ProcessorsConfig
    DEFAULT_PROCESSORS_CONFIG = {
      :make_header_link_processor => {
        :selector => "data-header-link",
        :hash_class => "go-hash",
        :copy_class => "copy-link"
      },
      :rewrite_img_processor => {
        :skip_keyword => "data-skip-src-to-absolute",
        :inline_image_class => "img-inline",
        :internal_image_class => "img-internal"
      },
      :rewrite_a_href_processor => {
        :skip_keyword => "data-skip-href-to-absolute",
        :index_page_keyword => "data-to-index-page",
        :hash_link_class => "hash-internal",
        :internal_link_class => "a-internal"
      },
      :make_search_index_processor => {
        :skip_keyword => "data-skip-search-index",
        :search_file_name => "search.json"
      }
    }.freeze

    def initialize(config)
      @config = Util.extract(DEFAULT_PROCESSORS_CONFIG, config)
    end

    def [] (processor)
      @config[processor]
    end
  end

  class Processor
    @@priority = {}

    DEFAULT_PRIORITY = {
      :site_after_init => :lowest,
      :site_pre_render => :lowest,
      :site_post_read => :lowest,
      :page_pre_render => :lowest,
      :page_post_render => :lowest,
      :site_post_render => :lowest
    }.freeze

    PRIORITY_MAP = {
      :lowest => 0,
      :low => 10,
      :normal => 20,
      :high => 30,
      :highest => 40,
    }.freeze

    METHODS = [
      :site_after_init,
      :site_post_read,
      :site_pre_render,
      :page_pre_render,
      :page_post_render,
      :site_post_render
    ].freeze

    DEFAULT_PROCESSORS = [
      :make_base_javascript_processor,
      :make_theme_processor,
      :make_front_matter_processor,
      :make_title_processor,
      :make_date_processor,
      :make_favicon_processor
    ].freeze

    SELECTABLE_PROCESSORS = [
      :make_navigation_processor,
      :make_empty_content_processor,
      :make_header_link_processor,
      :rewrite_img_processor,
      :rewrite_a_href_processor,
      :make_search_index_processor,
      :make_og_tag_processor
    ].freeze

    ALL_PROCESSORS = [DEFAULT_PROCESSORS, SELECTABLE_PROCESSORS].flatten

    attr_reader :priority

    def initialize(site, theme, config, tags)
      @site = site
      @theme = theme
      @config = config
      @tags = tags
      @logger = Logger.new(self)
      @priority = Util.extract(DEFAULT_PRIORITY, @@priority, false)
      @@priority = {}
    end

    def site_after_init(site) end

    def site_pre_render(site) end

    def site_post_read(site) end

    def site_post_render(site) end

    def page_pre_render(page, html, modified) end

    def page_post_render(page, html, modified) end

    def find_priority(method)
      if @priority[method].is_a?(Numeric)
        @priority[method]
      else
        PRIORITY_MAP[@priority[method]]
      end
    end

    def self.priority(event, priority)
      @@priority[event] = priority
    end

    def self.load_processors(site, theme, processors, tags, processor_names)
      active_processor_names = []
      active_processor_names.concat(DEFAULT_PROCESSORS)

      processor_names.map { |active_processor_name| active_processor_name.to_sym }
        .select { |active_processor_symbol| SELECTABLE_PROCESSORS.any?(active_processor_symbol) }
        .each { |active_processor_symbol| active_processor_names << active_processor_symbol }

      active_processor_names.map { |processor_symbol|
        processor_name = processor_symbol.to_s.gsub("_", "-")

        require_relative "processor/#{processor_name}.rb"

        constants = Jekyll::Potion.constants.select { |c|
          c.downcase.to_s == processor_name.to_s.gsub(/-/, "").downcase
        }

        raise SyntaxError, "undefined #{processor_name} class" if constants.empty?
        raise SyntaxError, "duplicate #{processor_name} class" if constants.size > 1

        Logger.trace(name, "load processor", processor_name)

        Jekyll::Potion.const_get(constants.first).new(site, theme, processors[processor_symbol], tags)
      }
    end
  end
end
