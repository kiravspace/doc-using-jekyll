module Jekyll::Potion
  class RewriteAHrefProcessor < HTMLPageProcessor
    HTTP_SCHEME = %r!\Ahttp(s)?://!im.freeze
    ABSOLUTE_PATH = %r!\A/!im.freeze
    HASH_SCHEME = %r!\A#!im.freeze

    SKIP_KEYWORD = "data-skip-href-to-absolute"

    def html_post_render(page, html)
      href_count = 0
      hash_count = 0

      html.css("a[href]").each { |a_tag|
        href = a_tag["href"]

        next if href.strip.empty? && a_tag.has_attribute?(SKIP_KEYWORD)

        if href =~ HASH_SCHEME
          hash_count += 1
          a_tag.add_class("hash_internal")
        end

        next if href =~ HTTP_SCHEME || href =~ ABSOLUTE_PATH || href =~ HASH_SCHEME

        absolute_href = Pathname.new(
          File.join(config.baseurl, File.dirname(page.path), href)
        ).cleanpath.to_s

        href_count += 1
        a_tag["href"] = absolute_href
        a_tag.add_class("a_internal")
      }

      if href_count > 0 || hash_count > 0
        logger.trace("#{page.name} #{href_count} a tags replace absolute path") if href_count > 0
        logger.trace("#{page.name} #{hash_count} hashed a tags add class") if hash_count > 0
        yield html
      end
    end
  end
end
