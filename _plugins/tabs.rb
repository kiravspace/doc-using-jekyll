module Jekyll
  module Potion
    class TabsTag < Liquid::Block
      include RootBlockModule

      def initialize(tag_name, markup, options)
        super
      end

      def render_tab_content(page_context)
        output = []
        @children.each { |child| output << child.render(page_context) }
        output.join
      end

      def render(page_context)
        render_from_custom_context(
          page_context,
          ->(context) do
            context["tabs_id"] = id

            tabs = []
            children.each do |child|
              tabs.push({ "title" => child.title, "tab_id" => child.id })
            end

            context["tabs"] = tabs
            context["tab_contents"] = render_tab_content(page_context)
          end
        )
      end
    end

    class TabContentTag < Liquid::Block
      include ChildBlockModule

      def id_format
        "tab-content-#{options.line_number}"
      end

      def title
        params["title"]
      end

      def render(page_context)
        render_from_custom_context(
          page_context,
          ->(context) do
            context["tab_id"] = id
            context["tab_body"] = @body.render(page_context)
          end
        )
      end
    end
  end
end

Liquid::Template.register_tag('tabs', Jekyll::Potion::TabsTag)
Jekyll::Potion::RootBlockTagRegistry.register_tag(Jekyll::Potion::TabsTag, "tabs::content", Jekyll::Potion::TabContentTag)