module Jekyll::Potion
  class LogoTag < Liquid::Tag
    include PotionTag

    def initialize(tag_name, markup, options)
      super
    end

    def render(page_context)
      @params["index_url"] = Potion[:site].index_url
      @params["site_icon"] = Potion[:site].base_url(Potion[:site][:icon]) unless Potion[:site].empty?(:icon)
      @params["site_title"] = Potion[:site][:title]

      Potion[:theme].render_template(@template_name, @params)
    end
  end
end

Liquid::Template.register_tag("logo", Jekyll::Potion::LogoTag)
