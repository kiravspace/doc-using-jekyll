module Jekyll::Potion
  class MakeNavigationProcessor < Processor
    NAVIGATION_KEY = "navigation".freeze
    DEPTH_ORDER = "depth_order".freeze

    def initialize(site, theme, config, tags)
      super
      @root_potions = []
    end

    def site_post_read(site)
      page_map = {}
      potion_map = {}

      @site.markdown_pages.each { |page|
        def page.depth_order
          self.data[DEPTH_ORDER] ||= 99999999
        end

        page_map[page.url] = page
        potion_map[page.url] = PagePotion.new(@site.baseurl, page)
      }

      potion_map.values.each { |potion| potion.parent = potion_map[potion.parent_path] }

      potion_map.values.group_by { |potion| potion.parent_path }.to_h
        .each { |parent_path, children|
          potion_map[parent_path].children = children.sort_by { |potion| potion.page.depth_order } if potion_map.has_key?(parent_path)
        }

      @root_potions = potion_map.values.select { |potion| potion.parent_path == "" }
                        .sort_by { |potion| potion.page.depth_order }

      order = 0
      @root_potions.each { |potion| order = potion.set_order(order) }

      sorted_potions = potion_map.values.sort_by { |potion| potion.order }

      sorted_potions[1..sorted_potions.size].each_with_index { |potion, index|
        potion.before = sorted_potions[index]
      }

      sorted_potions[0..sorted_potions.size - 2].each_with_index { |potion, index|
        potion.after = sorted_potions[index + 1]
      }

      @site.navigation(@root_potions)
    end
  end
end
