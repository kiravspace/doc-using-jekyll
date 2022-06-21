module Jekyll::Potion
  class MakeDateProcessor < Processor
    def site_post_read(site)
      config.markdown_pages.each { |page|
        page.data["created-date"] = File.birthtime(page.path)
        page.data["last-modified-date"] = File.mtime(page.path)
        logger.trace("make date", page.name)
      }
    end
  end
end