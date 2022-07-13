module Jekyll::Potion
  class NavigationTag < Liquid::Tag
    include PotionTag

    POTION_KEY = "potion".freeze

    DEFAULT_CONFIG = {
      "active_class" => "active",
      "fold_class" => "fold"
    }

    def initialize(tag_name, markup, options)
      super
    end

    def render(page_context)
      if @template_name == @tag_name
        Potion[:site].render_navigation(self)
      else
        @params[POTION_KEY] = page_context[POTION_KEY]
        Potion[:theme].render_template(@template_name, @params)
      end
    end

    def render_only_one(navigation)
      @params["navigation"] = navigation
      Potion[:theme].render_template(@template_name, @params)
    end
  end
end

Liquid::Template.register_tag("navigation", Jekyll::Potion::NavigationTag)
