module Jekyll::Potion
  class MakeTitleProcessor < Processor
    priority :page_post_render, :high

    TITLE_REGEX = %r! \A\s* (?: \#{1,3}\s+(.*)(?:\s+\#{1,3})? | (.*)\r?\n[-=]+\s* )$ !x.freeze

    def site_post_read(site)
      @site.markdown_pages.each { |page|
        if page.data["title"].nil?
          page.data["title"] = make_title(page)
          page.content = page.content.gsub(TITLE_REGEX, "").strip
        end
      }
    end

    def page_post_render(page, html, modified)
      head = html.css("head").first

      unless head.nil?
        title_value = @site.page_title(page)

        meta = Nokogiri::XML::Node.new("meta", html)
        meta["http-equiv"] = "Title"
        meta["content"] = title_value
        head.add_child(meta)

        if page.data.has_key?("description") and not page.data["description"].empty?
          meta = Nokogiri::XML::Node.new("meta", html)
          meta["http-equiv"] = "Description"
          meta["content"] = page.data["description"]
          head.add_child(meta)
        end

        title = Nokogiri::XML::Node.new("title", html)
        title.content = title_value
        head.add_child(title)

        yield html
      end
    end

    def make_title(page)
      if page.content.to_s =~ TITLE_REGEX
        $1 || $2
      else
        page.data["title"]
      end
    end
  end
end
