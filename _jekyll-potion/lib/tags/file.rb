module Jekyll::Potion
  class FileTag < PotionTag
    tag_name "file"

    def initialize(tag_name, markup, options)
      super
      ensure_valid_attr("src")
    end

    def render(page_context)
      @params["src"] = Util[:url].base_url(@params["src"])
      @params["caption"] = @params["src"] unless @params.has_key?("caption")

      Util[:tag].render_template(@template_name, @params)
    end
  end
end

# Liquid::Template.register_tag("file", Jekyll::Potion::FileTag)
