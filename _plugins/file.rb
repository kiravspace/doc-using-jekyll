module Jekyll
  module Tags
    class FileTag < Liquid::Tag
      def initialize(tag_name, markup, options)
        super
      end

      def render(context)
        text = super
        "<p>file</p>"
      end
    end
  end
end

Liquid::Template.register_tag('file', Jekyll::Tags::FileTag)
