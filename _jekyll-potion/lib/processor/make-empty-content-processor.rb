module Jekyll::Potion
  class MakeEmptyContentProcessor < Processor
    EMPTY_TAG = "{% empty %}"

    def page_pre_render(page, html)
      potion = PagePotion.potion(page)

      if not potion.nil? and potion.empty_content?
        page.content = EMPTY_TAG
      end
    end
  end
end
