module Jekyll::Potion
  class ApiTag < PotionBlock

    QUERY_CATEGORY = "query"
    BODY_CATEGORY = "body"

    def initialize(tag_name, markup, options)
      super

      ensure_valid_attr("method", "path", "summary")
    end

    def blank?
      false
    end

    def api_description(page_context)
      output = []
      @elements.select { |e| e.instance_of? ApiDescriptionTag }
               .each { |e| output << e.render(page_context) }
      output.join
    end

    def api_responses(page_context)
      output = []
      @elements.select { |e| e.instance_of? ApiResponseTag }
               .each { |e| output << e.render(page_context) }
      output.join
    end

    def render(page_context)
      @params["description"] = api_description(page_context)

      parameter_map = @elements.select { |e| e.instance_of? ApiParameterTag }
                               .group_by { |parameter| parameter.category }
                               .map { |category, parameters| [category, parameters.sort_by { |parameter| parameter.line_number }] }
                               .to_h

      @params["query_parameters"] = parameter_map[QUERY_CATEGORY].map { |query_parameters| query_parameters.render(page_context) }
                                                                 .join if parameter_map.has_key?(QUERY_CATEGORY)

      @params["body_parameters"] = parameter_map[BODY_CATEGORY].map { |query_parameters| query_parameters.render(page_context) }
                                                               .join if parameter_map.has_key?(BODY_CATEGORY)

      @params["responses"] = api_responses(page_context)

      Potion[:theme].render_template(@template_name, @params)
    end
  end

  class ApiDescriptionTag < Liquid::Block
    include PotionBlockElement

    def render(page_context)
      @params["description"] = @body.render(page_context)
      Potion[:theme].render_template(@template_name, @params)
    end
  end

  class ApiParameterTag < Liquid::Block
    include PotionBlockElement

    def initialize(tag_name, markup, options)
      super

      ensure_valid_attr("name", "type", "category")
    end

    def category
      @params["category"]
    end

    def render(page_context)
      @params["description"] = @body.render(page_context)
      Potion[:theme].render_template(@template_name, @params)
    end
  end

  class ApiResponseTag < Liquid::Block
    include PotionBlockElement

    def initialize(tag_name, markup, options)
      super

      ensure_valid_attr("status")
    end

    def status
      @params["status"]
    end

    def render(page_context)
      @params["body"] = @body.render(page_context)
      Potion[:theme].render_template(@template_name, @params)
    end
  end
end

Jekyll::Potion::ApiTag.register_tag("description", Jekyll::Potion::ApiDescriptionTag)
Jekyll::Potion::ApiTag.register_tag("parameter", Jekyll::Potion::ApiParameterTag)
Jekyll::Potion::ApiTag.register_tag("response", Jekyll::Potion::ApiResponseTag)
Liquid::Template.register_tag("api", Jekyll::Potion::ApiTag)
