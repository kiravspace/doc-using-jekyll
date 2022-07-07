module Jekyll::Potion
  class AlertsTag < PotionBlock
    tag_name "alerts"

    def initialize(tag_name, markup, options)
      puts "------------------------------------------- alerts"
      super
      ensure_valid_attr("style")
    end

    def render(page_context)
      config = Util[:tag].config("alerts")

      @params["style"] = config[@params["style"]] if config.has_key?(@params["style"])
      @params["body"] = Util[:tag].markdown_convert(super)

      Util[:tag].render_template(@template_name, @params)
    end
  end
end

# Liquid::Template.register_tag("alerts", Jekyll::Potion::AlertsTag)
