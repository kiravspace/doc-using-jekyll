module Jekyll::Potion
  class CodeTag < Liquid::Block
    include PotionTag

    def initialize(tag_name, markup, options)
      super
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

    def render(page_context)
      @params["body"] = Potion[:site].markdown_convert(@body)
      @params.merge!(Potion[:tags][:code])

      Potion[:theme].render_template(@template_name, @params)
    end
  end
end

Liquid::Template.register_tag("code", Jekyll::Potion::CodeTag)
