module Jekyll::Potion
  class FileTag < Liquid::Tag
    include PotionTag

    def initialize(tag_name, markup, options)
      super
      ensure_valid_attr("src")
    end

    def render(page_context)
      @params["src"] = Potion[:site].base_url(@params["src"])
      @params["caption"] = @params["src"] unless @params.has_key?("caption")

      Potion[:theme].render_template(@template_name, @params)
    end
  end
end

Liquid::Template.register_tag("file", Jekyll::Potion::FileTag)
