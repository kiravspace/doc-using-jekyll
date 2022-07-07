module Jekyll::Potion
  class MakeFrontMatterProcessor < Processor
    priority :site_post_read, :highest

    def site_post_read(site)
      site.pages.concat(static_files_to_pages)
      site.static_files -= Util[:converter].static_markdown_files
    end

    def static_files_to_pages
      Util[:converter].static_markdown_files.map { |static|
        page = Util[:converter].static_to_page(static)
        @logger.trace("make to site page", page.name)
        page
      }
    end
  end
end
