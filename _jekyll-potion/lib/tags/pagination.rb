module Jekyll::Potion
  class PaginationTag < Liquid::Tag
    include PotionTag

    def initialize(tag_name, markup, options)
      super
    end

    def render(page_context)
      @params["potion"] = PagePotion.potion(page_context)

      Potion[:theme].render_template(@template_name, @params)
    end
  end
end

Liquid::Template.register_tag("pagination", Jekyll::Potion::PaginationTag)
