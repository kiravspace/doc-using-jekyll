module Jekyll::Potion
  class MakeHeaderLinkProcessor < HTMLPageProcessor
    def html_post_render(page, html)
      update_a_tag_count = 0
      create_a_tag_count = 0

      html.css("h1", "h2", "h3", "h4", "h5", "h6")
          .select { |h_tag| h_tag.has_attribute?("id") }
          .each { |h_tag|
            id = h_tag["id"]

            next if id.strip.empty?

            a_tag = h_tag.css("a").first

            target_hash = ""

            if a_tag.nil?
              create_a_tag_count += 1
              new_a_tag = Nokogiri::XML::Node.new("a", html)
              new_a_tag["href"] = "##{id}"
              target_hash = "##{id}"
              new_a_tag.add_class("go-hash")
              h_tag.add_child(new_a_tag)
            else
              update_a_tag_count += 1
              if a_tag.has_attribute?("id")
                a_tag["href"] = "##{a_tag["id"]}"
                target_hash = "##{a_tag["id"]}"
              else
                a_tag["href"] = "##{id}"
                target_hash = "##{id}"
              end
              a_tag.add_class("go-hash")
            end

            copy_link = Nokogiri::XML::Node.new("div", html)
            copy_link.add_class("copy-link")

            absolute_href = Pathname.new(
              File.join(config.baseurl, File.dirname(page.path))
            ).cleanpath.to_s

            copy_link["data-copy-link"] = "#{absolute_href}#{target_hash}"
            h_tag.add_child(copy_link)
          }

      logger.trace("#{page.name} update header #{update_a_tag_count} a tags href update, #{create_a_tag_count} a tag create")
      yield html
    end
  end
end
