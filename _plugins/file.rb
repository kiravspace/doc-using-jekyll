module Jekyll
  module Potion
    class FileTag < Liquid::Tag
      require "potion"

      include Jekyll::Potion::TagModule

      def initialize(tag_name, markup, options)
        super
        ensure_valid_attr(tag_name, %w[src])
      end

      def render(page_context)
        render_from_custom_context(
          page_context,
          ->(context) do
            context["file_src"] = params["src"]

            if params.has_key?("caption")
              context["file_caption"] = params["caption"]
            else
              context["file_caption"] = params["src"]
            end
          end
        )
      end
    end
  end
end

Liquid::Template.register_tag("file", Jekyll::Potion::FileTag)
