module Jekyll::Potion
  class MakeFrontMatterProcessor < Processor
    priority :site_post_read, :highest

    def site_post_read(site)
      site.pages.concat(static_files_to_pages)
      site.static_files -= @site.static_markdown_files
    end

    def static_files_to_pages
      @site.static_markdown_files.map { |static|
        page = @site.static_to_page(static)
        @logger.trace("make to site page", page.name)
        page
      }
    end
  end
end
