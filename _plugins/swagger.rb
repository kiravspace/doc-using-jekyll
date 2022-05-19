module Jekyll
  module Tags
    class SwaggerTag < Liquid::Block
      def initialize(tag_name, markup, options)
        super
      end

      def render(context)
        text = super
        "<p>swagger</p>"
      end
    end
  end
end

Liquid::Template.register_tag('swagger', Jekyll::Tags::SwaggerTag)
