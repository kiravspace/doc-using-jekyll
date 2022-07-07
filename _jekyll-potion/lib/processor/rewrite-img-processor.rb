module Jekyll::Potion
  class RewriteImgProcessor < Processor
    HTTP_SCHEME = %r!\Ahttp(s)?://!im.freeze
    ABSOLUTE_PATH = %r!\A/!im.freeze

    SKIP_KEYWORD = "data-skip-src-to-absolute"

    RELATIVE_SRC = %r!src\s*="(?<src>\.+[^"]*?)"!im.freeze

    def page_post_render(page, html)
      src_count = 0
      inline_count = 0

      html.css("img[src]").each { |img_tag|
        src = img_tag["src"]

        next if src.strip.empty? && img_tag.has_attribute?(SKIP_KEYWORD)

        unless img_tag.parent.text.strip.empty?
          inline_count += 1
          img_tag.add_class("img-inline")
        end

        next if src =~ HTTP_SCHEME || src =~ ABSOLUTE_PATH

        src_count += 1
        img_tag["src"] = Util[:path].based_absolute_path(File.dirname(page.path), src)
        img_tag.add_class("img-internal")
      }

      if src_count > 0 || inline_count > 0
        @logger.trace("#{page.name} #{src_count} img tags replace absolute path") if src_count > 0
        @logger.trace("#{page.name} #{inline_count} inline img tags add class") if inline_count > 0
        yield html
      end
    end
  end
end
