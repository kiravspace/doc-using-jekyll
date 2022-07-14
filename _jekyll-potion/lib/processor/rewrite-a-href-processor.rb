module Jekyll::Potion
  class RewriteAHrefProcessor < Processor
    HTTP_SCHEME = %r!\Ahttp(s)?://!im.freeze
    ABSOLUTE_PATH = %r!\A/!im.freeze
    HASH_SCHEME = %r!\A#!im.freeze

    def page_post_render(page, html, modified)
      if modified
        href_count = 0
        hash_count = 0

        html.css("a[href]").each { |a_tag|
          href = a_tag["href"]

          next if href.strip.empty? && a_tag.has_attribute?(@config[:skip_keyword])
          next if href =~ HTTP_SCHEME

          if a_tag.has_attribute?(@config[:index_page_keyword])
            a_tag["href"] = @site.index_url
          elsif href =~ HASH_SCHEME
            hash_count += 1
            a_tag.add_class(@config[:hash_link_class])
          elsif href !~ ABSOLUTE_PATH
            a_tag["href"] = @site.base_absolute_url(File.dirname(page.path), href)
          end

          href_count += 1
          a_tag.add_class(@config[:internal_link_class])
        }

        if href_count > 0 || hash_count > 0
          @logger.trace("#{page.name} #{href_count} a tags replace absolute path") if href_count > 0
          @logger.trace("#{page.name} #{hash_count} hashed a tags add class") if hash_count > 0
          yield html
        end
      end
    end
  end
end
