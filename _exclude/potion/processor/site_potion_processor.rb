module Potion
  class PagePotion < Liquid::Drop
    attr_accessor :parent_path
    attr_accessor :page
    attr_accessor :parent
    attr_accessor :children
    attr_accessor :order
    attr_accessor :before
    attr_accessor :after

    def initialize(page, template)
      if page.url == "/"
        @parent_path = ""
      else
        @parent_path = page.url.sub(/.*\K\/#{page.basename}/, "")
      end

      @page = page
      @children = []

      @navigation_page_template = template
    end

    def set_order(order)
      @order = order

      order += 1

      if has_child?
        children.each { |potion| order = potion.set_order(order) }
      end

      order
    end

    def has_child?
      !children.empty?
    end

    def has_before?
      !before.nil?
    end

    def has_after?
      !after.nil?
    end

    def empty_content?
      page.content.strip == ""
    end

    def render_for_navigation
      @navigation_page_template.render(self)
    end

    def render_for_empty
      "empty"
    end
  end

  class SitePotionProcessor < PotionProcessor
    NAVIGATION_KEY = "navigation"
    DEPTH_ORDER = "depth_order"

    def initialize(config)
      super
      @navigation_template = config.load_template("navigation")
      @navigation_page_template = config.load_template("navigation_page")
    end

    def site_post_read(site)
      page_map = {}
      potion_map = {}

      config.markdown_pages.each { |page|
        def page.depth_order
          self.data[DEPTH_ORDER] ||= 99999999
        end

        page_map[page.url] = page
        potion_map[page.url] = PagePotion.new(page, @navigation_page_template)
      }

      potion_map.values.each { |potion| potion.parent = potion_map[potion.parent_path] }

      potion_map.values.group_by { |potion| potion.parent_path }.to_h
                .each { |parent_path, children|
                  potion_map[parent_path].children = children.sort_by { |potion| potion.page.depth_order } if potion_map.has_key?(parent_path)
                }

      root_potions = potion_map.values.select { |potion| potion.parent_path == "" }
                               .sort_by { |potion| potion.page.depth_order }

      order = 0
      root_potions.each { |potion| order = potion.set_order(order) }

      sorted_potions = potion_map.values.sort_by { |potion| potion.order }

      sorted_potions[1..sorted_potions.size].each_with_index { |potion, index|
        potion.before = sorted_potions[index]
      }

      sorted_potions[0..sorted_potions.size - 2].each_with_index { |potion, index|
        potion.after = sorted_potions[index + 1]
      }

      sorted_potions.each { |potion|
        potion.page.data[Config::CONFIG_KEY] = potion

        logger.trace("#{potion.page.name}##{potion.order} initialize")
      }

      config.make_site_potion
      config.make_site_data(NAVIGATION_KEY, @navigation_template.render({ "potions" => root_potions }))
    end
  end
end