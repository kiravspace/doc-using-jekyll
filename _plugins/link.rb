module Jekyll
  module Potion
    class LinkTag < Liquid::Tag
      require "net/http"
      require "nokogiri"
      require "_plugins/potion"

      include Jekyll::Potion::TagModule

      HTTP_SCHEME = "http://".freeze
      HTTPS_SCHEME = "https://".freeze

      def initialize(tag_name, markup, options)
        super
        ensure_valid_attr(tag_name, %w[url])
      end

      def render(page_context)
        render_from_custom_context(
          page_context,
          ->(context) do
            if params["url"].start_with?(HTTP_SCHEME) || params["url"].start_with?(HTTPS_SCHEME)
              begin
                res = Net::HTTP.get_response URI(params["url"])
                raise res.body unless res.is_a?(Net::HTTPSuccess)
                html = Nokogiri::HTML.parse(res.body)
                context["link_title"] = html.title
                context["link_description"] = html.at("meta[name='description']")["content"] unless html.at("meta[name='description']").nil?
                context["link_url"] = params["url"]
              rescue StandardError => msg
                puts "#{params["url"]} is break."
                context["link_title"] = params["url"]
                context["link_url"] = params["url"]
              end
            else
              page = context["site_potion"].page(params["url"])

              unless page.nil?
                context["link_title"] = page.data["title"]
                context["link_description"] = page.data["description"]
                context["link_url"] = page.url
              end
            end

            context["link_title"] = params["caption"] unless params["caption"].nil? || params["caption"].empty?
          end
        )
      end
    end
  end
end

Liquid::Template.register_tag("link", Jekyll::Potion::LinkTag)
