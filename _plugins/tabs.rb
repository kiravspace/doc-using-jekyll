require 'securerandom'

module Jekyll
  module Tags
    class TabsTag < Liquid::Block
      TAB_TAG_PATTERN = /({% tab (.*) %})/

      def initialize(tag_name, markup, options)
        super
        @template = Jekyll::Tags::find_template("tabs.liquid")
        @end_tag_name = "{% end#{tag_name} %}"
        @tabs_id = "tabs-#{options.line_number}"
      end

      def render(context)
        tabs = []

        self.nodelist.each do |tab|
          if tab.instance_of? Jekyll::Tags::TabTag
            tabs.push({"title" => tab.title, "tab_id" => tab.tab_id})
          end
        end
        context["tabs"] = tabs
        context["tabs_body"] = Jekyll::Tags::convert_body(context, super)
        @template.render(context)
      end
    end

    class TabTag < Liquid::Block
      attr_accessor :tab_id

      def initialize(tag_name, markup, options)
        super
        @template = Jekyll::Tags::find_template("tab.liquid")
        @params = Jekyll::Tags::attr_to_hash(markup)
        @tab_id = "tab-#{options.line_number}"

        Jekyll::Tags::ensure_valid_attr(tag_name, @params, ["title"])
      end

      def title
        @params["title"]
      end

      def render(context)
        context["tab_id"] = @tab_id
        context["tab_body"] = Jekyll::Tags::convert_body(context, super.strip)
        @template.render(context)
      end
    end
  end
end

Liquid::Template.register_tag('tabs', Jekyll::Tags::TabsTag)
Liquid::Template.register_tag('tab', Jekyll::Tags::TabTag)