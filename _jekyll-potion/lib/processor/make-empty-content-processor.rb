module Jekyll::Potion
  class MakeEmptyContentProcessor < Processor
    EMPTY_TAG = "{% empty %}".freeze

    def page_pre_render(page, html, modified)
      if modified
        potion = PagePotion.potion(page)

        if not potion.nil? and potion.empty_content?
          page.content = EMPTY_TAG
          @logger.trace("#{page.name} update empty tag")
        end
      end
    end
  end
end
