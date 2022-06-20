module Jekyll
  module Potion
    class PagePotion < Liquid::Drop
      attr_accessor :parent_path
      attr_accessor :page
      attr_accessor :parent_page
      attr_accessor :child_pages
      attr_accessor :order
      attr_accessor :prev_page
      attr_accessor :next_page

      def initialize(page)
        if page.url == "/"
          @parent_path = ""
        else
          @parent_path = page.url.sub(/.*\K\/#{page.basename}/, "")
        end

        @page = page
        @child_pages = []
      end

      def set_order(order)
        @order = order

        order += 1

        unless child_pages.empty?
          child_pages.each { |jekyll_page| order = jekyll_page.data[DATA_KEY].set_order(order) }
        end

        order
      end

      def has_child?
        !child_pages.empty?
      end

      def has_prev?
        !prev_page.nil?
      end

      def has_next?
        !next_page.nil?
      end

      def empty_content?
        page.content.strip == ""
      end
    end
  end
end