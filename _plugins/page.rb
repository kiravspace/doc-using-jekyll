module Jekyll
  module Tags
    class PageTag < Liquid::Tag
      def initialize(tag_name, markup, options)
        super
      end

      def render(context)
        text = super
        "<p>page</p>"
      end
    end
  end
end

Liquid::Template.register_tag('page', Jekyll::Tags::PageTag)
