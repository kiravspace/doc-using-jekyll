module Jekyll::Potion
  class MakeDateProcessor < Processor
    priority :page_post_render, :highest

    def page_post_render(page, html, modified)
      head = html.css("head").first

      unless head.nil?
        if File.method_defined?(:birthtime)
          meta = Nokogiri::XML::Node.new("meta", html)
          meta["name"] = "Date"
          meta["content"] = File.birthtime(page.path)
          head.add_child(meta)
        end

        if File.method_defined?(:mtime)
          meta = Nokogiri::XML::Node.new("meta", html)
          meta["http-equiv"] = "Last-Modified"
          meta["content"] = File.mtime(page.path)
          head.add_child(meta)
        end

        yield html
      end
    end
  end
end
