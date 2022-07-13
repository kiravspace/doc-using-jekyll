module Jekyll::Potion
  class TabsTag < PotionBlock
    DEFAULT_CONFIG = {
      "tabs_class" => "tabs",
      "active_class" => "active"
    }

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

      @params["tabs"] = tabs
      @params["contents"] = render_tab_content(page_context)
      @params.merge!(Potion[:tags][:tabs])

      Potion[:theme].render_template(@template_name, @params)
    end
  end

  class TabContentTag < Liquid::Block
    include PotionBlockElement

    attr_accessor :first

    def id_format
      "tab-content-#{options.line_number}"
    end

    def title
      @params["title"]
    end

    def render(page_context)
      @params["id"] = id
      @params["first"] = first
      @params["body"] = Potion[:site].markdown_convert(@body.render(page_context))
      @params.merge!(Potion[:tags][:tabs])

      Potion[:theme].render_template(@template_name, @params)
    end
  end
end

Jekyll::Potion::TabsTag.register_tag("content", Jekyll::Potion::TabContentTag)
Liquid::Template.register_tag("tabs", Jekyll::Potion::TabsTag)
