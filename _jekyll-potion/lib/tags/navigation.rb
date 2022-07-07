module Jekyll::Potion
  class NavigationTag < PotionTag
    tag_name "navigation"

    POTION_KEY = "potion"

    def initialize(tag_name, markup, options)
      super
    end

    def render(page_context)
      if @template_name == @tag_name
        Util[:tag].render_navigation(self)
      else
        @params[POTION_KEY] = page_context[POTION_KEY]
        Util[:tag].render_template(@template_name, @params)
      end
    end

    def render_only_one(navigation)
      @params["navigation"] = navigation
      Util[:tag].render_template(@template_name, @params)
    end
  end
end

# Liquid::Template.register_tag("navigation", Jekyll::Potion::NavigationTag)
