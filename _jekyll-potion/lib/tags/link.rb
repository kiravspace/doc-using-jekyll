module Jekyll::Potion
  class LinkTag < Liquid::Tag
    require "net/http"
    require "nokogiri"

    include PotionTag

    HTTP_SCHEME = %r!http(s)?://!im.freeze

    def initialize(tag_name, markup, options)
      super
      ensure_valid_attr("url")
    end

    def render(page_context)
      if @params["url"] =~ HTTP_SCHEME
        begin
          res = Net::HTTP.get_response URI(@params["url"])
          raise RuntimeError, res.class.name unless res.is_a?(Net::HTTPSuccess)
          html = Nokogiri::HTML.parse(res.body)
          @params["title"] = html.title
          @params["description"] = html.at("meta[name='description']")["content"] unless html.at("meta[name='description']").nil?
        rescue => error
          logger.warn("#{@params["url"]} is break.", error.message)
          @params["title"] = @params["url"]
        end
      else
        potion = PagePotion.potion(@params["url"])

        unless potion.nil?
          @params["title"] = potion.title
          @params["description"] = potion.description
          @params["url"] = potion.url
        end
      end

      @params["title"] = @params["caption"] unless @params["caption"].nil? || @params["caption"].empty?

      Potion[:theme].render_template(@template_name, @params)
    end
  end
end

Liquid::Template.register_tag("link", Jekyll::Potion::LinkTag)
