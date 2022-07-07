module Jekyll::Potion
  class PagePotion < Liquid::Drop
    attr_accessor :parent_path
    attr_accessor :page
    attr_accessor :parent
    attr_accessor :children
    attr_accessor :order
    attr_accessor :before
    attr_accessor :after

    @@page_potions = {}

    def initialize(baseurl, page)
      @baseurl = baseurl

      if page.url == "/"
        @parent_path = ""
      else
        @parent_path = page.url.sub(/.*\K\/#{page.basename}/, "")
      end

      @page = page
      @children = []

      @@page_potions[page.url] = self
    end

    def set_order(order)
      @order = order

      order += 1

      if has_child?
        @children.each { |potion| order = potion.set_order(order) }
      end

      order
    end

    def title
      @page.data["title"]
    end

    def description
      @page.data["description"]
    end

    def url
      "#{@baseurl}#{@page.url}"
    end

    def has_child?
      !@children.empty?
    end

    def has_before?
      !@before.nil?
    end

    def has_after?
      !@after.nil?
    end

    def empty_content?
      @page.content.strip.empty?
    end

    def self.potion(page)
      if page.is_a?(Jekyll::Page)
        @@page_potions[page.url]
      elsif page.is_a?(Liquid::Context)
        page = page.registers[:page]
        @@page_potions[page["url"]]
      elsif page.is_a?(String)
        @@page_potions[page]
      end
    end

    def self.potion_from_context(page_context)
      self.potion(page_context.registers[:page])
    end
  end
end
