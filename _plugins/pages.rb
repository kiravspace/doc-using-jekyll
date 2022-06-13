module Jekyll
  module Potion
    class PagesTag < Liquid::Tag
      include TagModule

      def render(page_context)
        page_context["class"] = params["class"]
        render_from_page_context(page_context)
      end
    end
  end
end

Liquid::Template.register_tag("pages", Jekyll::Potion::PagesTag)
