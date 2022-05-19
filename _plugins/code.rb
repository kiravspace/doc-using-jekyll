module Jekyll
  module Tags
    class CodeTag < Liquid::Block
      def initialize(tag_name, markup, options)
        super
        @template = Jekyll::Tags::find_template("code.liquid")
        @params = Jekyll::Tags::attr_to_hash(markup)
        @end_tag_name = "{% end#{tag_name} %}"
      end

      def parse(tokens)
        @body = +""
        while (token = tokens.shift)
          if token == @end_tag_name
            return
          end
          @body << token unless token.empty?
        end

        raise SyntaxError, parse_context.locale.t("errors.syntax.tag_never_closed", block_name: @end_tag_name)
      end

      def nodelist
        [@body]
      end

      def blank?
        @body.empty?
      end

      def render(context)
        context["code_title"] = @params["title"]
        context["code_body"] = Jekyll::Tags::convert_body(context, @body)
        @template.render(context)
      end
    end
  end
end

Liquid::Template.register_tag("code", Jekyll::Tags::CodeTag)
