module Jekyll::Potion
  class LogoTag < PotionTag
    tag_name "logo"

    def initialize(tag_name, markup, options)
      super
    end

    def render(page_context)
      @params["index_url"] = Util[:url].index_url
      @params["site_icon"] = Util[:site].site_icon if Util[:site].site_icon?
      @params["site_title"] = Util[:site].site_title

      Util[:tag].render_template(@template_name, @params)
    end
  end
end

# Liquid::Template.register_tag("logo", Jekyll::Potion::LogoTag)
