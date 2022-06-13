module Jekyll
  module Potion
    DATA_KEY = "potion"
    CONFIG_KEY = "potion_config"
    THEME_KEY = "theme"
    DEFAULT_THEME = "proto"

    IS_MAKE_TITLE_KEY = "is_make_title"
    IS_SHOW_PAGINATION = "is_show_pagination"
    IS_SHOW_EMPTY_TO_CHILD_PAGES = "is_show_empty_to_child_pages"

    TITLE_REGEX = %r! \A\s* (?: \#{1,3}\s+(.*)(?:\s+\#{1,3})? | (.*)\r?\n[-=]+\s* )$ !x.freeze

    TEMPLATE_PATH = "/_plugins/templates"

    TITLE = "title"
    DEPTH_ORDER = "depth_order"

    class Generator < Jekyll::Generator
      def initialize(configuration)
        @configuration = configuration[CONFIG_KEY]
      end

      def make_title?
        @configuration.has_key?(IS_MAKE_TITLE_KEY) && @configuration[IS_MAKE_TITLE_KEY]
      end

      def markdown_converter
        @markdown_converter ||= @site.find_converter_instance(Jekyll::Converters::Markdown)
      end

      def static_markdown_files
        @site.static_files.select { |file| markdown_converter.matches(file.extname) }
      end

      def static_files_to_pages
        static_markdown_files.map do |markdown_page|
          base = markdown_page.instance_variable_get("@base")
          dir = markdown_page.instance_variable_get("@dir")
          name = markdown_page.instance_variable_get("@name")

          jekyll_page = Jekyll::Page.new(@site, base, dir, name)
          jekyll_page
        end
      end

      def markdown_pages
        @site.pages.select { |page| markdown_converter.matches(page.extname) }
      end

      def make_title(jekyll_page)
        matches = jekyll_page.content.to_s.match(TITLE_REGEX)
        if matches
          matches[1] || matches[2]
        else
          jekyll_page.data[TITLE]
        end
      end

      def depth_order(jekyll_page)
        if jekyll_page.data[DEPTH_ORDER].nil?
          99999999
        else
          jekyll_page.data[DEPTH_ORDER]
        end
      end

      def generate(site)
        @site = site
        site.pages.concat(static_files_to_pages)
        site.static_files -= static_markdown_files

        if make_title?
          markdown_pages.select { |jekyll_page| jekyll_page.data["title"].nil? }
                        .each { |jekyll_page|
                          jekyll_page.data[TITLE] = make_title(jekyll_page)
                          jekyll_page.content = jekyll_page.content.gsub(TITLE_REGEX, "").strip
                        }
        end

        markdown_pages.each do |jekyll_page|
          jekyll_page.data[DATA_KEY] = PagePotion::new(jekyll_page)
        end

        by_parent_path = markdown_pages.group_by { |jekyll_page| jekyll_page.data[DATA_KEY].parent_path }
                                       .map { |parent_path, child_pages| [parent_path, child_pages.sort_by { |jekyll_page| depth_order(jekyll_page) }] }
                                       .to_h

        markdown_pages.map { |jekyll_page| jekyll_page.data[DATA_KEY] }
                      .each { |potion|
                        potion.child_pages = by_parent_path[potion.page.url] if by_parent_path.has_key?(potion.page.url)

                        potion.child_pages.each do |jekyll_page|
                          jekyll_page.data[DATA_KEY].parent_page = potion.page
                        end
                      }

        root_pages = markdown_pages.select { |jekyll_page| jekyll_page.data[DATA_KEY].parent_path == "" }
                                   .sort_by { |jekyll_page| depth_order(jekyll_page) }

        order = 0
        root_pages.each { |jekyll_page| order = jekyll_page.data[DATA_KEY].set_order(order) }

        sorted_pages = markdown_pages.sort_by { |jekyll_page| jekyll_page.data[DATA_KEY].order }

        sorted_pages[1..sorted_pages.size].each_with_index { |jekyll_page, index|
          jekyll_page.data[DATA_KEY].prev_page = sorted_pages[index]
        }

        sorted_pages[0..sorted_pages.size - 2].each_with_index { |jekyll_page, index|
          jekyll_page.data[DATA_KEY].next_page = sorted_pages[index + 1]
        }

        sorted_pages.each { |jekyll_page| puts "#{jekyll_page.name} #{jekyll_page.data[DATA_KEY].order} #{jekyll_page.data[DATA_KEY].has_prev?} #{jekyll_page.data[DATA_KEY].has_next?}" }

        @site.data[DATA_KEY] = SitePotion.new(@configuration, root_pages, sorted_pages)
      end
    end

    class SitePotion < Liquid::Drop
      attr_accessor :pages

      def initialize(configuration, pages, sorted_pages)
        @configuration = configuration
        @pages = pages
        @by_src = sorted_pages.map { |jekyll_page| [jekyll_page.url, jekyll_page] }.to_h
      end

      def theme
        if @configuration.has_key?(THEME_KEY)
          @configuration[THEME_KEY]
        else
          DEFAULT_THEME
        end
      end

      def is_show_pagination?
        @configuration.has_key?(IS_SHOW_PAGINATION) && @configuration[IS_SHOW_PAGINATION]
      end

      def is_show_empty_to_child_pages?
        @configuration.has_key?(IS_SHOW_EMPTY_TO_CHILD_PAGES) && @configuration[IS_SHOW_EMPTY_TO_CHILD_PAGES]
      end

      def theme_path
        "theme/#{theme}"
      end

      def title
        @configuration[TITLE]
      end

      def page(url)
        @by_src[url]
      end
    end

    class PagePotion < Liquid::Drop
      attr_accessor :parent_path
      attr_accessor :page
      attr_accessor :parent_page
      attr_accessor :child_pages
      attr_accessor :order
      attr_accessor :prev_page
      attr_accessor :next_page

      def initialize(page)
        if page.url == "/"
          @parent_path = ""
        else
          @parent_path = page.url.sub(/.*\K\/#{page.basename}/, "")
        end

        @page = page
        @child_pages = []
      end

      def set_order(order)
        @order = order

        order += 1

        unless child_pages.empty?
          child_pages.each { |jekyll_page| order = jekyll_page.data[DATA_KEY].set_order(order) }
        end

        order
      end

      def has_child?
        !child_pages.empty?
      end

      def has_prev?
        !prev_page.nil?
      end

      def has_next?
        !next_page.nil?
      end

      def empty_content?
        page.content.strip == ""
      end
    end

    module TagModule
      ATTRIBUTES_REGEX = /(\S*)="(.*?[^\\])"/
      TEMPLATE_DELIMITER = "-"
      POTION_TAG_PARAM_REGEX = /(?:#{TEMPLATE_DELIMITER}(\S*) )?((?:#{ATTRIBUTES_REGEX}\s?)*)/

      attr_accessor :tag_name
      attr_accessor :end_tag_name
      attr_accessor :options
      attr_accessor :id
      attr_accessor :template_name
      attr_accessor :params

      def initialize(tag_name, markup, options)
        super

        @tag_name = tag_name
        @end_tag_name = "{% end#{tag_name} %}"
        @options = options
        @id = id_format
        @template_name = "#{tag_name}"
        @params = {}

        if markup =~ POTION_TAG_PARAM_REGEX
          @template_name << "-#{$1}" unless $1.nil?
          @params = attr_to_hash($2) unless $2.nil?
        end
      end

      def id_format
        "#{tag_name}-#{options.line_number}"
      end

      def attr_to_hash(str)
        str.scan(ATTRIBUTES_REGEX).to_h.map { |k, v| [k.strip, v.strip] }.to_h
      end

      def ensure_valid_attr(tag_name, keys)
        keys.each { |key|
          unless params.has_key?(key)
            raise SyntaxError, "#{tag_name} required #{key} attribute"
          end
        }
      end

      def convert_body(context, body)
        if @context.nil?
          init_render(context)
        end
        find_converter.convert(body)
      end

      def find_converter
        if @context.nil?
          init_render(context)
        end
        @site.find_converter_instance(::Jekyll::Converters::Markdown)
      end

      def template_render
        if @context.nil?
          init_render(context)
        end
        @template.render(@context)
      end

      def init_render(context)
        @context = context
        @site = context.registers[:site]
        @template = Liquid::Template.parse(
          File.read("#{Dir.pwd}#{TEMPLATE_PATH}/#{@site.data["potion"].theme_path}/#{@template_name}.liquid")
        )
      end

      def default_render(context)
        if @context.nil?
          init_render(context)
        end
        template_render
      end

      def render_from_custom_context(page_context, customizer)
        site = page_context.registers[:site]
        page = page_context.registers[:page]
        context = {
          "site" => site,
          "page" => page,
          "site_potion" => site.data[DATA_KEY],
          "page_potion" => page[DATA_KEY]
        }
        customizer.call(context)
        template = Liquid::Template.parse(
          File.read("#{Dir.pwd}#{TEMPLATE_PATH}/#{site.data["potion"].theme_path}/#{template_name}.liquid")
        )
        template.render(context)
      end

      def render_from_page_context(page_context)
        site = page_context.registers[:site]
        template = Liquid::Template.parse(
          File.read("#{Dir.pwd}#{TEMPLATE_PATH}/#{site.data["potion"].theme_path}/#{template_name}.liquid")
        )
        template.render(page_context)
      end

      def body_to_string(context, body)
        context["site"].find_converter_instance(::Jekyll::Converters::Markdown).convert(body)
      end
    end

    class RootBlockTagRegistry
      TAGS = {}

      def self.registered_tag(root_block_class, tag_name)
        return nil unless TAGS.has_key?(root_block_class)
        return nil unless TAGS[root_block_class].has_key?(tag_name)
        TAGS[root_block_class][tag_name]
      end

      def self.register_tag(root_block_class, tag_name, tag_class)
        if TAGS.has_key?(root_block_class)
          TAGS[root_block_class][tag_name] = tag_class
        else
          TAGS[root_block_class] = { tag_name => tag_class }
        end
      end
    end

    module RootBlockModule
      include Jekyll::Potion::TagModule

      attr_accessor :children

      FULL_TOKEN = /\A\{%\s*(\w+::\w+)\s*(.*?)%}\z/om

      def initialize(tag_name, markup, options)
        @children = []
        super
      end

      def parse(tokens)
        options.line_number = tokens.line_number
        while (token = tokens.shift)
          next if token.empty?

          if token == end_tag_name
            return
          end

          if token =~ FULL_TOKEN
            tag_name = $1
            markup = $2

            child_tag_class = RootBlockTagRegistry.registered_tag(self.class, tag_name)

            unless child_tag_class.nil?
              @children << child_tag_class.parse(tag_name, markup, tokens, options)
            end
          end
          @options.line_number = tokens.line_number
        end
      end

      def nodelist
        @children
      end

      def blank?
        @children.empty?
      end
    end

    module ChildBlockModule
      include Jekyll::Potion::TagModule

      MAX_DEPTH = 100

      def block_delimiter
        "end#{tag_name}"
      end

      def parse_body(body, tokens)
        if parse_context.depth >= MAX_DEPTH
          raise StackLevelError, "Nesting too deep".freeze
        end
        parse_context.depth += 1
        begin
          body.parse(tokens, parse_context) do |end_tag_name, end_tag_params|
            @blank &&= body.blank?

            return false if "#{end_tag_name}#{end_tag_params}".strip == block_delimiter
            unless end_tag_name
              raise SyntaxError.new(parse_context.locale.t("errors.syntax.tag_never_closed".freeze, block_name: block_name))
            end

            # this tag is not registered with the system
            # pass it to the current block for special handling or error reporting
            unknown_tag(end_tag_name, end_tag_params, tokens)
          end
        ensure
          parse_context.depth -= 1
        end

        true
      end
    end
  end
end