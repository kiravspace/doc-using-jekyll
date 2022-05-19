module Generator
  class SiteMeta < Liquid::Drop
    attr_accessor :page_metas
    attr_accessor :root_page_metas

    def initialize
      @site_template = Jekyll::Tags::find_template("site_meta.liquid")
      @page_template = Jekyll::Tags::find_template("page_meta.liquid")
    end

    def generate(pages)
      @page_metas = pages.map do |page|
        page_meta = PageMeta.new(page, @page_template)
        page.data["meta"] = page_meta
      end
      @by_parent_path = @page_metas.group_by(&:parent_path)
                                   .map { |parent_path, child_pages| [parent_path, child_pages.sort_by { |page| page.depth_order }] }
                                   .to_h

      @page_metas.each { |page| page.child_pages = @by_parent_path[page.url] if @by_parent_path.has_key?(page.url) }
      @root_page_metas = @page_metas.select { |page| page.parent_path == "" }.sort_by { |page| page.depth_order }

      page_order = 0

      @root_page_metas.each do |page|
        page_order = set_order(page, page_order)
      end

      @page_metas = @page_metas.sort_by { |page| page.order }

      @page_metas[1..@page_metas.size].each_with_index { |page, index| page.prev = @page_metas[index] }
      @page_metas[0..@page_metas.size - 2].each_with_index { |page, index| page.next = @page_metas[index + 1] }
    end

    def set_order(page, page_order)
      page.order = page_order

      page_order += 1

      unless page.empty_child?
        page.child_pages.each { |child| page_order = set_order(child, page_order) }
      end

      page_order
    end

    def render
      @site_template.render(self)
    end
  end

  class PageMeta < Liquid::Drop
    attr_accessor :parent_path
    attr_accessor :url
    attr_accessor :name
    attr_accessor :basename
    attr_accessor :title
    attr_accessor :depth_order
    attr_accessor :order
    attr_accessor :child_pages
    attr_accessor :prev
    attr_accessor :next

    def initialize(page, template)
      if page.url == "/"
        @parent_path = ""
      else
        @parent_path = page.url.sub(/.*\K\/#{page.basename}/, "")
      end

      @url = page.url
      @name = page.name
      @basename = page.basename
      @title = page.data["title"]
      @depth_order = page.data["depth_order"]
      @child_pages = []
      @_page = page
      @template = template
    end

    def empty_child?
      @child_pages.empty?
    end

    def has_prev?
      !@prev.nil?
    end

    def has_next?
      !@next.nil?
    end

    def has_nav?
      has_prev? || has_next?
    end

    def empty_content?
      @_page.content.strip == ""
    end

    def render
      @template.render(self)
    end
  end
end