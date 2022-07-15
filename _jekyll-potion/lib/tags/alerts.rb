module Jekyll::Potion
  class AlertsTag < Liquid::Block
    include PotionTag

    def initialize(tag_name, markup, options)
      super
      ensure_valid_attr("style")
    end

    def render(page_context)
      config = Potion[:tags][:alerts]

      @params["style"] = config[@params["style"]] if config.has_key?(@params["style"])
      @params["body"] = Potion[:site].markdown_convert(super)

      Potion[:theme].render_template(@template_name, @params)
    end
  end
end

Liquid::Template.register_tag("alerts", Jekyll::Potion::AlertsTag)
