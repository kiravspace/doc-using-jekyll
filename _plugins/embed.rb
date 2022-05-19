require 'net/http'
require 'nokogiri'

module Jekyll
  module Tags
    class EmbedTag < Liquid::Tag
      def initialize(tag_name, markup, options)
        super
        @template = Jekyll::Tags::find_template("embed.liquid")
        @params = Jekyll::Tags::attr_to_hash(markup)
      end

      def render(context)
        context["embed_title"] = get_title_from_html(@params["url"])
        context["embed_caption"] = @params["caption"]
        @template.render(context)
      end

      def get_title_from_html(url)
        title = ''
        begin
          res = Net::HTTP.get_response URI(url)
          raise res.body unless res.is_a?(Net::HTTPSuccess)
          parsed_data = Nokogiri::HTML.parse(res.body)
          title = parsed_data.title
        rescue StandardError => msg
          title = url
          puts msg
        end
        title
      end
    end
  end
end

Liquid::Template.register_tag('embed', Jekyll::Tags::EmbedTag)
