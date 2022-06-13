module Jekyll
  module Potion
    class ApiTag < Liquid::Block
      include RootBlockModule

      QUERY_CATEGORY = "query"
      BODY_CATEGORY = "body"

      def initialize(tag_name, markup, options)
        super

        ensure_valid_attr(tag_name, %w[method path summary])
      end

      def blank?
        false
      end

      def api_description(page_context)
        output = []
        @children.select { |child| child.instance_of? ApiDescriptionTag }
                 .each { |child| output << child.render(page_context) }
        output.join
      end

      def api_responses(page_context)
        output = []
        @children.select { |child| child.instance_of? ApiResponseTag }
                 .each { |child| output << child.render(page_context) }
        output.join
      end

      def render(page_context)
        render_from_custom_context(
          page_context,
          ->(context) do
            context["api_method"] = params["method"]
            context["api_base_url"] = params["base_url"]
            context["api_path"] = params["path"]
            context["api_summary"] = params["summary"]

            context["api_description"] = api_description(page_context)

            parameter_map = @children.select { |child| child.instance_of? ApiParameterTag }
                                     .group_by { |parameter| parameter.category }
                                     .map { |category, parameters| [category, parameters.sort_by { |parameter| parameter.line_number }] }
                                     .to_h

            context["api_query_parameters"] = parameter_map[QUERY_CATEGORY].map { |query_parameters| query_parameters.render(page_context) }
                                                                           .join if parameter_map.has_key?(QUERY_CATEGORY)

            context["api_body_parameters"] = parameter_map[BODY_CATEGORY].map { |query_parameters| query_parameters.render(page_context) }
                                                                         .join if parameter_map.has_key?(BODY_CATEGORY)

            context["api_responses"] = api_responses(page_context)
          end
        )
      end
    end

    class ApiDescriptionTag < Liquid::Block
      include ChildBlockModule

      def render(page_context)
        render_from_custom_context(
          page_context,
          ->(context) do
            context["api_description"] = @body.render(page_context)
          end
        )
      end
    end

    class ApiParameterTag < Liquid::Block
      include ChildBlockModule

      def initialize(tag_name, markup, options)
        super

        ensure_valid_attr(tag_name, %w[name type category])
      end

      def category
        params["category"]
      end

      def render(page_context)
        render_from_custom_context(
          page_context,
          ->(context) do
            context["api_request_name"] = params["name"]
            context["api_request_type"] = params["type"]
            context["api_request_category"] = params["category"]
            context["api_request_description"] = @body.render(page_context)
          end
        )
      end
    end

    class ApiResponseTag < Liquid::Block
      include ChildBlockModule

      def initialize(tag_name, markup, options)
        super

        ensure_valid_attr(tag_name, %w[status])
      end

      def status
        params["status"]
      end

      def render(page_context)
        render_from_custom_context(
          page_context,
          ->(context) do
            context["api_response_status"] = params["status"]
            context["api_response_description"] = params["description"]
            context["api_response_body"] = @body.render(page_context)
          end
        )
      end
    end
  end
end

Liquid::Template.register_tag("api", Jekyll::Potion::ApiTag)
Jekyll::Potion::RootBlockTagRegistry.register_tag(Jekyll::Potion::ApiTag, "api::description", Jekyll::Potion::ApiDescriptionTag)
Jekyll::Potion::RootBlockTagRegistry.register_tag(Jekyll::Potion::ApiTag, "api::parameter", Jekyll::Potion::ApiParameterTag)
Jekyll::Potion::RootBlockTagRegistry.register_tag(Jekyll::Potion::ApiTag, "api::response", Jekyll::Potion::ApiResponseTag)
