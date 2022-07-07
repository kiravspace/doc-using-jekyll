module Jekyll::Potion
  module BaseModule
    TEMPLATE_DELIMITER = "-"
    ATTRIBUTES_REGEX = /(\S*)="(.*?[^\\])"/
    POTION_TAG_PARAM_REGEX = /(?:#{TEMPLATE_DELIMITER}(\S*) )?((?:#{ATTRIBUTES_REGEX}\s?)*)/

    def initialize(tag_name, markup, options)
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

  class TagMeta
    @@tags = {}
    @@elements = {}

    def self.tag_name(tag_name, tag_class)
      @@tags[tag_name] = tag_class
    end

    def self.append_elements(parent_tag_name, tag_name, tag_class)
      @@elements[@@tags[parent_tag_name]] = {} unless @@elements.has_key?(parent_tag_name)
      @@elements[@@tags[parent_tag_name]][tag_name] = tag_class
    end

    def self.tags
      @@tags
    end

    def self.elements
      @@elements
    end

    def self.find_element(parent_tag_class, element_tag_name)
      @@elements[parent_tag_class][element_tag_name]
    end
  end

  class PotionTag < Liquid::Tag
    include BaseModule

    def self.tag_name(tag_name)
      TagMeta.tag_name(tag_name, self)
    end
  end

  class PotionBlock < Liquid::Block
    include BaseModule

    def self.tag_name(tag_name)
      TagMeta.tag_name(tag_name, self)
    end
  end

  class PotionWrapBlock < Liquid::Block
    include BaseModule

    @@tag_name = nil
    @@elements = {}
    @@registry = {}

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

          child_tag_class = self.find_element($2)

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

    def self.tag_name(tag_name)
      TagMeta.tag_name(tag_name, self)
    end

    def self.find_element(element_tag_name)
      TagMeta.find_element(self, element_tag_name)
    end

    def self.elements(tag_name, tag_class)
      @@elements[tag_name] = tag_class
    end

    def self.get_elements
      @@elements
    end

    def self.registered_tag(tag_name)
      return nil unless @@registry.has_key?(tag_name)
      @@registry[tag_name]
    end

    def self.register_tag(tag_name, tag_class)
      @@registry[tag_name] = tag_class
    end
  end

  module PotionWrapModule
    include BaseModule

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

  class ElementTag < Liquid::Tag
    include PotionWrapModule

    def self.tag_name(parent_tag_name, tag_name)
      TagMeta.append_elements(parent_tag_name, tag_name, self)
    end
  end

  class ElementBlock < Liquid::Block
    include PotionWrapModule

    def self.tag_name(parent_tag_name, tag_name)
      TagMeta.append_elements(parent_tag_name, tag_name, self)
    end
  end

  module ScriptModule
    def generate_script

    end
  end

  # module PotionTag1
  #   TEMPLATE_DELIMITER = "-"
  #   ATTRIBUTES_REGEX = /(\S*)="(.*?[^\\])"/
  #   POTION_TAG_PARAM_REGEX = /(?:#{TEMPLATE_DELIMITER}(\S*) )?((?:#{ATTRIBUTES_REGEX}\s?)*)/
  #
  #   attr_accessor :id
  #   attr_accessor :template_name
  #   attr_accessor :logger
  #
  #   @@registry = {}
  #
  #   def initialize(tag_name, markup, options)
  #     super
  #     @tag_name = tag_name
  #     @end_tag_name = "{% end#{tag_name} %}"
  #     @options = options
  #     @id = id_format
  #
  #     @template_name = "#{tag_name}"
  #     @params = {}
  #
  #     if markup =~ POTION_TAG_PARAM_REGEX
  #       @template_name << "-#{$1}" unless $1.nil?
  #       @params = attr_to_hash($2) unless $2.nil?
  #     end
  #
  #     @logger = Logger.new(self)
  #   end
  #
  #   def id_format
  #     "#{@tag_name}-#{@options.line_number}"
  #   end
  #
  #   def attr_to_hash(str)
  #     str.scan(ATTRIBUTES_REGEX).to_h.map { |k, v| [k.strip, v.strip] }.to_h
  #   end
  #
  #   def ensure_valid_attr(*keys)
  #     keys.each { |key|
  #       unless @params.has_key?(key)
  #         raise SyntaxError, "#{@tag_name} required #{key} attribute"
  #       end
  #     }
  #   end
  # end
  #
  # class PotionBlock1 < Liquid::Block
  #   include PotionTag
  #
  #   attr_accessor :elements
  #
  #   FULL_TOKEN = /\A\{%\s*(\w+::(\w+))\s*(.*?)%}\z/om
  #
  #   def initialize(tag_name, markup, options)
  #     super
  #     @elements = []
  #   end
  #
  #   def parse(tokens)
  #     options.line_number = tokens.line_number
  #     while (token = tokens.shift)
  #       next if token.empty?
  #
  #       if token == @end_tag_name
  #         return
  #       end
  #
  #       if token =~ FULL_TOKEN
  #         tag_name = $1
  #         markup = $3
  #
  #         child_tag_class = @@registry[$2]
  #
  #         unless child_tag_class.nil?
  #           @elements << child_tag_class.parse(tag_name, markup, tokens, options)
  #         end
  #       end
  #       @options.line_number = tokens.line_number
  #     end
  #   end
  #
  #   def nodelist
  #     @elements
  #   end
  #
  #   def blank?
  #     @elements.empty?
  #   end
  #
  #   def self.registered_tag(tag_name)
  #     return nil unless @@registry.has_key?(tag_name)
  #     @@registry[tag_name]
  #   end
  #
  #   def self.register_tag(tag_name, tag_class)
  #     @@registry[tag_name] = tag_class
  #   end
  # end
  #
  # class PotionWrapBlock1 < Liquid::Block
  #   include PotionTag
  #
  #   attr_accessor :elements
  #
  #   FULL_TOKEN = /\A\{%\s*(\w+::(\w+))\s*(.*?)%}\z/om
  #
  #   def initialize(tag_name, markup, options)
  #     super
  #     @elements = []
  #   end
  #
  #   def parse(tokens)
  #     options.line_number = tokens.line_number
  #     while (token = tokens.shift)
  #       next if token.empty?
  #
  #       if token == @end_tag_name
  #         return
  #       end
  #
  #       if token =~ FULL_TOKEN
  #         tag_name = $1
  #         markup = $3
  #
  #         child_tag_class = @@registry[$2]
  #
  #         unless child_tag_class.nil?
  #           @elements << child_tag_class.parse(tag_name, markup, tokens, options)
  #         end
  #       end
  #       @options.line_number = tokens.line_number
  #     end
  #   end
  #
  #   def nodelist
  #     @elements
  #   end
  #
  #   def blank?
  #     @elements.empty?
  #   end
  #
  #   def self.registered_tag(tag_name)
  #     return nil unless @@registry.has_key?(tag_name)
  #     @@registry[tag_name]
  #   end
  #
  #   def self.register_tag(tag_name, tag_class)
  #     @@registry[tag_name] = tag_class
  #   end
  # end
  #
  # module PotionBlockElement1
  #   include PotionTag
  #
  #   MAX_DEPTH = 100
  #
  #   def block_delimiter
  #     "end#{tag_name}"
  #   end
  #
  #   def parse_body(body, tokens)
  #     if parse_context.depth >= MAX_DEPTH
  #       raise StackLevelError, "Nesting too deep".freeze
  #     end
  #     parse_context.depth += 1
  #     begin
  #       body.parse(tokens, parse_context) do |end_tag_name, end_tag_params|
  #         @blank &&= body.blank?
  #
  #         return false if "#{end_tag_name}#{end_tag_params}".strip == block_delimiter
  #         unless end_tag_name
  #           raise SyntaxError.new(parse_context.locale.t("errors.syntax.tag_never_closed".freeze, block_name: block_name))
  #         end
  #
  #         # this tag is not registered with the system
  #         # pass it to the current block for special handling or error reporting
  #         unknown_tag(end_tag_name, end_tag_params, tokens)
  #       end
  #     ensure
  #       parse_context.depth -= 1
  #     end
  #
  #     true
  #   end
  # end

  module Tag
    def self.load_tag_classes(base_path)
      self.load_files(base_path, "tags") { |_, dir, file_name| require_relative "#{File.join(dir, file_name)}" }

      TagMeta.tags.each { |tag_name, tag_class| Liquid::Template.register_tag(tag_name, tag_class)}

      puts TagMeta.tags
      puts TagMeta.elements
      # 1 / 0

      #
      # after_load_classes = Jekyll::Potion.constants.clone
      #
      # tag_classes = after_load_classes - before_load_classes
      #
      # tag_classes.each { |c|
      #   tag_class = Jekyll::Potion.const_get(c)
      #
      #   if tag_class.superclass == PotionTag or tag_class.superclass == PotionBlock
      #     Logger.error(tag_class, tag_class.get_tag_name)
      #   elsif tag_class.superclass == PotionWrapBlock
      #     Logger.error(tag_class, tag_class.get_tag_name)
      #   end
      #
      #   # Logger.error(tag_class, tag_class.to_s.split(/(?=[A-Z])/))
      # }

      # 1 / 0
      # , Jekyll::Potion.const_get(tag_class).include?(PotionBlockElement)

      # put AlertsTag.meta
      #
      # Logger.error(after_load_classes == before_load_classes)
      # Logger.error(tag_classes, "|", before_load_classes, "|", after_load_classes)
      #
      # 1 / 0
      # require_relative "tags/#{tag_name}.rb"
      #
      # constants = Jekyll::Potion.constants.select { |c|
      #   c.downcase.to_s == tag_name.to_s.gsub(/-/, "").downcase
      # }
      #
      # puts constants
    end

    # def self.load_files_in_tags(base_path, &block)
    #   self.load_files(base_path, "tags", block)
    # end

    def self.load_files(base, dir, &block)
      Dir.foreach(File.join(base, dir)) { |file_name|
        next if file_name == "." or file_name == ".."

        path = File.join(base, dir, file_name)

        if File.directory?(path)
          self.load_files(base, file_name) & block
        else
          block.call(base, dir, file_name)
        end
      }
    end
  end
end
