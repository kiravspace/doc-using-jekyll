module Jekyll::Potion
  class RewriteImgProcessor < HTMLPageProcessor
    HTTP_SCHEME = %r!\Ahttp(s)?://!im.freeze
    ABSOLUTE_PATH = %r!\A/!im.freeze

    SKIP_KEYWORD = "data-skip-src-to-absolute"

    RELATIVE_SRC = %r!src\s*="(?<src>\.+[^"]*?)"!im.freeze

    def html_post_render(page, html)
      src_count = 0
      inline_count = 0

      html.css("img[src]").each { |img_tag|
        src = img_tag["src"]

        next if src.strip.empty? && img_tag.has_attribute?(SKIP_KEYWORD)

        unless img_tag.parent.text.strip.empty?
          inline_count += 1
          img_tag.add_class("img_inline")
        end

        next if src =~ HTTP_SCHEME || src =~ ABSOLUTE_PATH

        absolute_href = Pathname.new(
          File.join(config.baseurl, File.dirname(page.path), src)
        ).cleanpath.to_s

        src_count += 1
        img_tag["src"] = absolute_href
        img_tag.add_class("img_internal")
      }

      if src_count > 0 || inline_count > 0
        logger.trace("#{page.name} #{src_count} img tags replace absolute path") if src_count > 0
        logger.trace("#{page.name} #{inline_count} inline img tags add class") if inline_count > 0
        yield html
      end
    end
  end
end
