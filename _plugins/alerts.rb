module Jekyll
  module Tags
    class AlertsTag < Liquid::Block
      def initialize(tag_name, markup, options)
        super
        @template = Jekyll::Tags::find_template("alerts.liquid")
        @params = Jekyll::Tags::attr_to_hash(markup)

        Jekyll::Tags::ensure_valid_attr(tag_name, @params, ["style"])
      end

      def render(context)
        context["style"] = @params["style"]
        context["alert_body"] = Jekyll::Tags::convert_body(context, super)
        @template.render(context)
      end
    end
  end
end

Liquid::Template.register_tag("alerts", Jekyll::Tags::AlertsTag)
