module Jekyll::Potion
  class EmptyTag < PotionTag
    tag_name "empty"

    def initialize(tag_name, markup, options)
      super
    end

    def render(page_context)
      @params["potion"] = PagePotion.potion(page_context)

      Util[:tag].render_template(@template_name, @params)
    end
  end
end

# Liquid::Template.register_tag("empty", Jekyll::Potion::EmptyTag)
