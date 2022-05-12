module Jekyll
  module Tags
    class AlertsTag < Liquid::Block
      def initialize(tag_name, markup, options)
        super
        @style = markup
      end

      def render(context)
        text = super
        site = context.registers[:site]
        converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
        "<p>#{@style} #{converter.convert(text)}</p>"
      end
    end
  end
end

Liquid::Template.register_tag('alerts', Jekyll::Tags::AlertsTag)
