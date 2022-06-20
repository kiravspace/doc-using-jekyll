module Jekyll
  module Potion
    module RootBlockModule
      include TagModule

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
  end
end