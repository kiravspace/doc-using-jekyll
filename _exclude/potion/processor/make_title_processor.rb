module Potion
  class MakeTitleProcessor < PotionProcessor
    TITLE_REGEX = %r! \A\s* (?: \#{1,3}\s+(.*)(?:\s+\#{1,3})? | (.*)\r?\n[-=]+\s* )$ !x.freeze

    def site_post_read(site)
      config.markdown_pages.each { |page|
        if config.make_title? && config.markdown_converter.matches(page.extname) && page.data[Config::TITLE_KEY].nil?
          page.data[Config::TITLE_KEY] = make_title(page)
          page.content = page.content.gsub(TITLE_REGEX, "").strip
          logger.trace("make title", page.name)
        end
      }
    end

    def make_title(page)
      if page.content.to_s =~ TITLE_REGEX
        $1 || $2
      else
        page.data[Config::TITLE_KEY]
      end
    end
  end
end