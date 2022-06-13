module Jekyll
  module Potion
    class Generator < Jekyll::Generator
      def initialize(configuration)
        @configuration = configuration[CONFIG_KEY]
      end

      def make_title?
        @configuration.has_key?(IS_MAKE_TITLE_KEY) && @configuration[IS_MAKE_TITLE_KEY]
      end

      def markdown_converter
        @markdown_converter ||= @site.find_converter_instance(Jekyll::Converters::Markdown)
      end

      def static_markdown_files
        @site.static_files.select { |file| markdown_converter.matches(file.extname) }
      end

      def static_files_to_pages
        static_markdown_files.map do |markdown_page|
          base = markdown_page.instance_variable_get("@base")
          dir = markdown_page.instance_variable_get("@dir")
          name = markdown_page.instance_variable_get("@name")

          jekyll_page = Jekyll::Page.new(@site, base, dir, name)
          jekyll_page
        end
      end

      def markdown_pages
        @site.pages.select { |page| markdown_converter.matches(page.extname) }
      end

      def make_title(jekyll_page)
        matches = jekyll_page.content.to_s.match(TITLE_REGEX)
        if matches
          matches[1] || matches[2]
        else
          jekyll_page.data[TITLE]
        end
      end

      def depth_order(jekyll_page)
        if jekyll_page.data[DEPTH_ORDER].nil?
          99999999
        else
          jekyll_page.data[DEPTH_ORDER]
        end
      end

      def generate(site)
        @site = site
        site.pages.concat(static_files_to_pages)
        site.static_files -= static_markdown_files

        if make_title?
          markdown_pages.select { |jekyll_page| jekyll_page.data["title"].nil? }
                        .each { |jekyll_page|
                          jekyll_page.data[TITLE] = make_title(jekyll_page)
                          jekyll_page.content = jekyll_page.content.gsub(TITLE_REGEX, "").strip
                        }
        end

        markdown_pages.each do |jekyll_page|
          jekyll_page.data[DATA_KEY] = PagePotion::new(jekyll_page)
        end

        by_parent_path = markdown_pages.group_by { |jekyll_page| jekyll_page.data[DATA_KEY].parent_path }
                                       .map { |parent_path, child_pages| [parent_path, child_pages.sort_by { |jekyll_page| depth_order(jekyll_page) }] }
                                       .to_h

        markdown_pages.map { |jekyll_page| jekyll_page.data[DATA_KEY] }
                      .each { |potion|
                        potion.child_pages = by_parent_path[potion.page.url] if by_parent_path.has_key?(potion.page.url)

                        potion.child_pages.each do |jekyll_page|
                          jekyll_page.data[DATA_KEY].parent_page = potion.page
                        end
                      }

        root_pages = markdown_pages.select { |jekyll_page| jekyll_page.data[DATA_KEY].parent_path == "" }
                                   .sort_by { |jekyll_page| depth_order(jekyll_page) }

        order = 0
        root_pages.each { |jekyll_page| order = jekyll_page.data[DATA_KEY].set_order(order) }

        sorted_pages = markdown_pages.sort_by { |jekyll_page| jekyll_page.data[DATA_KEY].order }

        sorted_pages[1..sorted_pages.size].each_with_index { |jekyll_page, index|
          jekyll_page.data[DATA_KEY].prev_page = sorted_pages[index]
        }

        sorted_pages[0..sorted_pages.size - 2].each_with_index { |jekyll_page, index|
          jekyll_page.data[DATA_KEY].next_page = sorted_pages[index + 1]
        }

        sorted_pages.each { |jekyll_page| puts "#{jekyll_page.name} #{jekyll_page.data[DATA_KEY].order} #{jekyll_page.data[DATA_KEY].has_prev?} #{jekyll_page.data[DATA_KEY].has_next?}" }

        @site.data[DATA_KEY] = SitePotion.new(@configuration, root_pages, sorted_pages)
      end
    end
  end
end