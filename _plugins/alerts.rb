module Jekyll
  module Potion
    class AlertsTag < Liquid::Block
      include Jekyll::Potion::TagModule

      def initialize(tag_name, markup, options)
        super
        ensure_valid_attr(tag_name, %w[style])
      end

      def render(page_context)
        render_from_custom_context(
          page_context,
          ->(context, converter) do
            context["alert_style"] = params["style"]
            context["alert_body"] = converter.convert(super)
          end
        )
      end
    end
  end
end

Liquid::Template.register_tag("alerts", Jekyll::Potion::AlertsTag)
