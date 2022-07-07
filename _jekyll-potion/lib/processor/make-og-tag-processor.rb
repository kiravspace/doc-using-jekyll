module Jekyll::Potion
  class MakeOgTagProcessor < Processor
    priority :page_post_render, :normal

    def page_post_render(page, html)
      head = html.css("head").first

      or_url = Nokogiri::XML::Node.new("meta", html)
      or_url["property"] = "og:url"
      or_url["content"] = Util[:url].base_url_with_domain(page.url)
      head.add_child(or_url)

      or_type = Nokogiri::XML::Node.new("meta", html)
      or_type["property"] = "og:type"
      or_type["content"] = "website"
      head.add_child(or_type)

      og_title = Nokogiri::XML::Node.new("meta", html)
      og_title["property"] = "og:title"
      og_title["content"] = Util[:site].page_title(page)
      head.add_child(og_title)

      if page.data.has_key?("description") and not page.data["description"].empty?
        og_description = Nokogiri::XML::Node.new("meta", html)
        og_description["property"] = "og:description"
        og_description["content"] = page.data["description"]
        head.add_child(og_description)
      end

      if Util[:site].site_icon?
        og_image = Nokogiri::XML::Node.new("meta", html)
        og_image["property"] = "og:image"
        og_image["content"] = Util[:site].site_icon_with_domain
        head.add_child(og_image)
      end
      yield html
    end
  end
end
