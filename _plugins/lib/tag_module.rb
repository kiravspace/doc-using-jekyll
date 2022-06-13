module Jekyll
  module Potion
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
  end
end