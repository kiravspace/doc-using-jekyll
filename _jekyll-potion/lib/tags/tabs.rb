module Jekyll::Potion
  class TabsTag < PotionWrapBlock
    tag_name "tabs"

    def render_tab_content(page_context)
      output = []
      @elements.each { |e| output << e.render(page_context) }
      output.join
    end

    def render(page_context)
      @params["id"] = id

      tabs = []
      @elements.each_index { |i|
        @elements[i].first = i == 0;
      }

      @elements.each do |e|
        tabs.push({ "title" => e.title, "id" => e.id, "first" => e.first })
      end

      config = Util[:tag].config("tabs")

      @params["tabs"] = tabs
      @params["contents"] = render_tab_content(page_context)
      @params["active_class"] = config["active-class"]

      Util[:tag].render_template(@template_name, @params)
    end
  end

  class TabContentTag < ElementBlock
    tag_name "tabs", "content"

    attr_accessor :first

    def id_format
      "tab-content-#{options.line_number}"
    end

    def title
      @params["title"]
    end

    def render(page_context)
      config = Util[:tag].config("tabs")

      @params["id"] = id
      @params["first"] = first
      @params["body"] = Util[:tag].markdown_convert(@body.render(page_context))
      @params["active_class"] = config["active-class"]

      Util[:tag].render_template(@template_name, @params)
    end
  end
end

# Jekyll::Potion::TabsTag.register_tag("content", Jekyll::Potion::TabContentTag)
# Liquid::Template.register_tag("tabs", Jekyll::Potion::TabsTag)
