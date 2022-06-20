module Jekyll
  module Potion
    class SitePotion < Liquid::Drop
      attr_accessor :pages

      def initialize(configuration, pages, sorted_pages)
        @configuration = configuration
        @pages = pages
        @by_src = sorted_pages.map { |jekyll_page| [jekyll_page.url, jekyll_page] }.to_h
      end

      def theme
        if @configuration.has_key?(THEME_KEY)
          @configuration[THEME_KEY]
        else
          DEFAULT_THEME
        end
      end

      def is_show_pagination?
        @configuration.has_key?(IS_SHOW_PAGINATION) && @configuration[IS_SHOW_PAGINATION]
      end

      def is_show_empty_to_child_pages?
        @configuration.has_key?(IS_SHOW_EMPTY_TO_CHILD_PAGES) && @configuration[IS_SHOW_EMPTY_TO_CHILD_PAGES]
      end

      def theme_path
        "theme/#{theme}"
      end

      def title
        @configuration[TITLE]
      end

      def page(url)
        @by_src[url]
      end
    end
  end
end