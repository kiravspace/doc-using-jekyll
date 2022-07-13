module Jekyll::Potion
  class TagsConfig
    DEFAULT_TAGS_CONFIG = {
      :alerts => {
        :info => "info",
        :warning => "warning",
        :danger => "danger",
        :success => "success"
      },
      :code => {
        :code_class => "code",
        :success_class => "copy-text",
        :success_show_class => "show"
      },
      :tabs => {
        :tabs_class => "tabs",
        :active_class => "active"
      },
      :navigation => {
        :active_class => "active",
        :fold_class => "fold"
      }
    }.freeze

    def initialize(config)
      @config = Util.extract(DEFAULT_TAGS_CONFIG, config)
    end

    def [] (tag_name)
      Util.string_key_hash(@config[tag_name])
    end
  end

  module PotionTag
    TEMPLATE_DELIMITER = "-"
    ATTRIBUTES_REGEX = /(\S*)="(.*?[^\\])"/
    POTION_TAG_PARAM_REGEX = /(?:#{TEMPLATE_DELIMITER}(\S*) )?((?:#{ATTRIBUTES_REGEX}\s?)*)/

    attr_accessor :id
    attr_accessor :template_name
    attr_accessor :logger

    @@registry = {}

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

      @logger = Logger.new(self)
    end

    def id_format
      "#{@tag_name}-#{@options.line_number}"
    end

    def attr_to_hash(str)
      str.scan(ATTRIBUTES_REGEX).to_h.map { |k, v| [k.strip, v.strip] }.to_h
    end

    def ensure_valid_attr(*keys)
      keys.each { |key|
        unless @params.has_key?(key)
          raise SyntaxError, "#{@tag_name} required #{key} attribute"
        end
      }
    end
  end

  class PotionBlock < Liquid::Block
    include PotionTag

    attr_accessor :elements

    FULL_TOKEN = /\A\{%\s*(\w+::(\w+))\s*(.*?)%}\z/om

    def initialize(tag_name, markup, options)
      super
      @elements = []
    end

    def parse(tokens)
      options.line_number = tokens.line_number
      while (token = tokens.shift)
        next if token.empty?

        if token == @end_tag_name
          return
        end

        if token =~ FULL_TOKEN
          tag_name = $1
          markup = $3

          child_tag_class = @@registry[$2]

          unless child_tag_class.nil?
            @elements << child_tag_class.parse(tag_name, markup, tokens, options)
          end
        end
        @options.line_number = tokens.line_number
      end
    end

    def nodelist
      @elements
    end

    def blank?
      @elements.empty?
    end

    def self.registered_tag(tag_name)
      return nil unless @@registry.has_key?(tag_name)
      @@registry[tag_name]
    end

    def self.register_tag(tag_name, tag_class)
      @@registry[tag_name] = tag_class
    end
  end

  module PotionBlockElement
    include PotionTag

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
