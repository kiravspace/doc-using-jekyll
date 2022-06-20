# module Jekyll
#   module Potion
#     # class Generator < Jekyll::Generator
#     #   priority :lowest
#     #
#     #   def initialize(configuration)
#     #     @configuration = configuration[CONFIG_KEY]
#     #   end
#     #
#     #   def make_title?
#     #     @configuration.has_key?(IS_MAKE_TITLE_KEY) && @configuration[IS_MAKE_TITLE_KEY]
#     #   end
#     #
#     #   def markdown_converter
#     #     @markdown_converter ||= @site.find_converter_instance(Jekyll::Converters::Markdown)
#     #   end
#     #
#     #   def static_markdown_files
#     #     @site.static_files.select { |file| markdown_converter.matches(file.extname) }
#     #   end
#     #
#     #   def static_files_to_pages
#     #     static_markdown_files.map do |markdown_page|
#     #       base = markdown_page.instance_variable_get("@base")
#     #       dir = markdown_page.instance_variable_get("@dir")
#     #       name = markdown_page.instance_variable_get("@name")
#     #
#     #       jekyll_page = Jekyll::Page.new(@site, base, dir, name)
#     #       jekyll_page
#     #     end
#     #   end
#     #
#     #   def markdown_pages
#     #     @site.pages.select { |page| markdown_converter.matches(page.extname) }
#     #   end
#     #
#     #   def make_title(jekyll_page)
#     #     matches = jekyll_page.content.to_s.match(TITLE_REGEX)
#     #     if matches
#     #       matches[1] || matches[2]
#     #     else
#     #       jekyll_page.data[TITLE]
#     #     end
#     #   end
#     #
#     #   def depth_order(jekyll_page)
#     #     if jekyll_page.data[DEPTH_ORDER].nil?
#     #       99999999
#     #     else
#     #       jekyll_page.data[DEPTH_ORDER]
#     #     end
#     #   end
#     #
#     #   def generate(site)
#     #     @site = site
#     #     # site.pages.concat(static_files_to_pages)
#     #     # site.static_files -= static_markdown_files
#     #
#     #     # if make_title?
#     #     #   markdown_pages.select { |jekyll_page| jekyll_page.data["title"].nil? }
#     #     #                 .each { |jekyll_page|
#     #     #                   jekyll_page.data[TITLE] = make_title(jekyll_page)
#     #     #                   jekyll_page.content = jekyll_page.content.gsub(TITLE_REGEX, "").strip
#     #     #                 }
#     #     # end
#     #
#     #     # markdown_pages.each do |jekyll_page|
#     #     #   jekyll_page.data[DATA_KEY] = PagePotion::new(jekyll_page)
#     #     # end
#     #
#     #     # by_parent_path = markdown_pages.group_by { |jekyll_page| jekyll_page.data[DATA_KEY].parent_path }
#     #     #                                .map { |parent_path, child_pages| [parent_path, child_pages.sort_by { |jekyll_page| depth_order(jekyll_page) }] }
#     #     #                                .to_h
#     #     #
#     #     # markdown_pages.map { |jekyll_page| jekyll_page.data[DATA_KEY] }
#     #     #               .each { |potion|
#     #     #                 potion.child_pages = by_parent_path[potion.page.url] if by_parent_path.has_key?(potion.page.url)
#     #     #
#     #     #                 potion.child_pages.each do |jekyll_page|
#     #     #                   jekyll_page.data[DATA_KEY].parent_page = potion.page
#     #     #                 end
#     #     #               }
#     #     #
#     #     # root_pages = markdown_pages.select { |jekyll_page| jekyll_page.data[DATA_KEY].parent_path == "" }
#     #     #                            .sort_by { |jekyll_page| depth_order(jekyll_page) }
#     #     #
#     #     # order = 0
#     #     # root_pages.each { |jekyll_page| order = jekyll_page.data[DATA_KEY].set_order(order) }
#     #     #
#     #     # sorted_pages = markdown_pages.sort_by { |jekyll_page| jekyll_page.data[DATA_KEY].order }
#     #     #
#     #     # sorted_pages[1..sorted_pages.size].each_with_index { |jekyll_page, index|
#     #     #   jekyll_page.data[DATA_KEY].prev_page = sorted_pages[index]
#     #     # }
#     #     #
#     #     # sorted_pages[0..sorted_pages.size - 2].each_with_index { |jekyll_page, index|
#     #     #   jekyll_page.data[DATA_KEY].next_page = sorted_pages[index + 1]
#     #     # }
#     #     #
#     #     # sorted_pages.each { |jekyll_page| puts "#{jekyll_page.name} #{jekyll_page.data[DATA_KEY].order} #{jekyll_page.data[DATA_KEY].has_prev?} #{jekyll_page.data[DATA_KEY].has_next?}" }
#     #     #
#     #     # @site.data[DATA_KEY] = SitePotion.new(@configuration, root_pages, sorted_pages)
#     #   end
#     # end
#
#     # class Processor
#     #   def site_post_read(site)
#     #     @site = site
#     #     @configuration = site.config[CONFIG_KEY]
#     #     # @site.pages.concat(static_files_to_pages)
#     #     # @site.static_files -= static_markdown_files
#     #
#     #     # markdown_pages.each do |jekyll_page|
#     #     #   jekyll_page.data[DATA_KEY] = PagePotion::new(jekyll_page)
#     #     # end
#     #     #
#     #     # by_parent_path = markdown_pages.group_by { |jekyll_page| jekyll_page.data[DATA_KEY].parent_path }
#     #     #                                .map { |parent_path, child_pages| [parent_path, child_pages.sort_by { |jekyll_page| depth_order(jekyll_page) }] }
#     #     #                                .to_h
#     #     #
#     #     # markdown_pages.map { |jekyll_page| jekyll_page.data[DATA_KEY] }
#     #     #               .each { |potion|
#     #     #                 potion.child_pages = by_parent_path[potion.page.url] if by_parent_path.has_key?(potion.page.url)
#     #     #
#     #     #                 potion.child_pages.each do |jekyll_page|
#     #     #                   jekyll_page.data[DATA_KEY].parent_page = potion.page
#     #     #                 end
#     #     #               }
#     #     #
#     #     # root_pages = markdown_pages.select { |jekyll_page| jekyll_page.data[DATA_KEY].parent_path == "" }
#     #     #                            .sort_by { |jekyll_page| depth_order(jekyll_page) }
#     #     #
#     #     # order = 0
#     #     # root_pages.each { |jekyll_page| order = jekyll_page.data[DATA_KEY].set_order(order) }
#     #     #
#     #     # sorted_pages = markdown_pages.sort_by { |jekyll_page| jekyll_page.data[DATA_KEY].order }
#     #     #
#     #     # sorted_pages[1..sorted_pages.size].each_with_index { |jekyll_page, index|
#     #     #   jekyll_page.data[DATA_KEY].prev_page = sorted_pages[index]
#     #     # }
#     #     #
#     #     # sorted_pages[0..sorted_pages.size - 2].each_with_index { |jekyll_page, index|
#     #     #   jekyll_page.data[DATA_KEY].next_page = sorted_pages[index + 1]
#     #     # }
#     #     #
#     #     # sorted_pages.each { |jekyll_page| puts "#{jekyll_page.name} #{jekyll_page.data[DATA_KEY].order} #{jekyll_page.data[DATA_KEY].has_prev?} #{jekyll_page.data[DATA_KEY].has_next?}" }
#     #     #
#     #     # @site.data[DATA_KEY] = SitePotion.new(@configuration, root_pages, sorted_pages)
#     #
#     #     @site.data[DATA_KEY] = SitePotion.new(@configuration, [], [])
#     #
#     #     puts "===========================================================>>> #{site.data}"
#     #   end
#
#       # def markdown_converter
#       #   @site.find_converter_instance(Jekyll::Converters::Markdown)
#       # end
#       #
#       # def markdown_pages
#       #   @site.pages.select { |page| markdown_converter.matches(page.extname) }
#       # end
#       #
#       # def static_markdown_files
#       #   @site.static_files.select { |file| markdown_converter.matches(file.extname) }
#       # end
#       #
#       # def static_files_to_pages
#       #   static_markdown_files.map do |markdown_page|
#       #     base = markdown_page.instance_variable_get("@base")
#       #     dir = markdown_page.instance_variable_get("@dir")
#       #     name = markdown_page.instance_variable_get("@name")
#       #
#       #     jekyll_page = Jekyll::Page.new(@site, base, dir, name)
#       #     jekyll_page
#       #   end
#       # end
#       #
#       # def depth_order(jekyll_page)
#       #   if jekyll_page.data[DEPTH_ORDER].nil?
#       #     99999999
#       #   else
#       #     jekyll_page.data[DEPTH_ORDER]
#       #   end
#       # end
#       #
#       # def page_pre_render(jekyll_page)
#       #   if make_title? && markdown_converter.matches(jekyll_page.extname) && jekyll_page.data["title"].nil?
#       #     jekyll_page.data[TITLE] = make_title(jekyll_page)
#       #     jekyll_page.content = jekyll_page.content.gsub(TITLE_REGEX, "").strip
#       #   end
#       #   # jekyll_page.data[DATA_KEY] = PagePotion::new(jekyll_page)
#       # end
#       #
#       # def make_title?
#       #   @configuration.has_key?(IS_MAKE_TITLE_KEY) && @configuration[IS_MAKE_TITLE_KEY]
#       # end
#       #
#       # def make_title(jekyll_page)
#       #   matches = jekyll_page.content.to_s.match(TITLE_REGEX)
#       #   if matches
#       #     matches[1] || matches[2]
#       #   else
#       #     jekyll_page.data[TITLE]
#       #   end
#       # end
#       #
#       # def site_pre_render
#       #   puts "<====================================== site_pre_render"
#       # end
#     end
#
#     processor = Processor.new
#
#     page_indexes = []
#
#     # Jekyll::Hooks.register_one(:pages, :pre_render, 10) do |page|
#     #   processor.page_pre_render(page)
#     # end
#
#     # Jekyll::Hooks.register_one(:site, :pre_render, 10) do |site|
#     #   processor.site_pre_render
#     # end
#     #
#     # Jekyll::Hooks.register_one(:pages, :post_render, 10) do |page|
#     #   html = Nokogiri::HTML.parse(page.output)
#     #
#     #   if page.extname == ".md"
#     #     page_indexes << {
#     #       "url" => page.url,
#     #       "hashes" => create_indexes(page, html.css("section").css("div.container").css("div.content"))
#     #     }
#     #   end
#     # end
#     #
#     # Jekyll::Hooks.register_one(:site, :after_init, 10) do |site|
#     #   puts "after_init #{site.pages.size}"
#     # end
#     #
#     # Jekyll::Hooks.register_one(:site, :after_reset, 10) do |site|
#     #   puts "=================================================> after_reset #{site.pages.size}"
#     # end
#     #
#     # Jekyll::Hooks.register_one(:site, :post_read, 10) do |site|
#     #   puts "=================================================> post_read #{site.pages.size}"
#     #   processor.site_post_read(site)
#     # end
#     #
#     # Jekyll::Hooks.register_one(:site, :pre_render, 10) do |site|
#     #   puts "=================================================> pre_render #{site.pages.size}"
#     # end
#     #
#     # Jekyll::Hooks.register_one(:site, :post_render, 10) do |site|
#     #   # page_indexes.each { |page_index|
#     #   #   puts "#{page_index["hashes"].map { |hash| hash["indexes"].size }.inject(0) { |sum, x| sum + x }}"
#     #   # }
#     # end
#
#     # def self.create_indexes(page, content)
#     #   hash = ""
#     #
#     #   hashed = []
#     #
#     #   indexes = [page.data["title"], page.data["description"]]
#     #
#     #   titles = ["", "", "", "", "", ""]
#     #
#     #   content.children.each { |tag|
#     #     if tag.name =~ /h(\d+)/
#     #       unless tag.text.strip.empty?
#     #         current = $1.to_i
#     #
#     #         (current..6).each { |i| titles[i] = "" }
#     #
#     #         titles[current] = tag.text.strip
#     #
#     #         hashed << {
#     #           "hash" => hash,
#     #           "title" => titles.select { |title| !title.empty? }.join(" > "),
#     #           "indexes" => indexes.clone
#     #         }
#     #
#     #         hash = tag["id"]
#     #         indexes.clear
#     #         indexes << tag.text.strip
#     #       end
#     #     else
#     #       indexes.concat(create_default_index(tag))
#     #     end
#     #   }
#     #
#     #   hashed << {
#     #     "hash" => hash,
#     #     "title" => titles.select { |title| !title.empty? }.join(" > "),
#     #     "indexes" => indexes.clone
#     #   }
#     #
#     #   hashed
#     # end
#     #
#     # def self.create_default_index(tag)
#     #   indexes = []
#     #
#     #   case tag.name
#     #   when "a"
#     #     unless tag.text.strip.empty?
#     #       indexes << tag.text.strip
#     #     end
#     #   when "p", "blockquote"
#     #     unless tag.text.strip.empty?
#     #       indexes << tag.text.strip
#     #     end
#     #   when "ul", "ol"
#     #     tag.css("li").each { |li|
#     #       unless li.text.strip.empty?
#     #         indexes << li.text.strip
#     #       end
#     #     }
#     #   when "table"
#     #     tag.css("thread").css("tr").each { |tr|
#     #       indexes << tr.css("th").map { |td| td.text.strip }.join(" | ")
#     #     }
#     #     tag.css("tbody").css("tr").each { |tr|
#     #       indexes << tr.css("td").map { |td| td.text.strip }.join(" | ")
#     #     }
#     #   when "div"
#     #     indexes.concat(create_div_index(tag))
#     #   when "pre"
#     #     if tag.classes.include?("highlight")
#     #       unless tag.css("td.rouge-code").text.strip.empty?
#     #         indexes << tag.css("td.rouge-code").text.strip
#     #       end
#     #     end
#     #   when "text", "hr"
#     #     unless tag.text.strip.empty?
#     #       indexes << tag.text.strip
#     #     end
#     #   else
#     #     puts "undefined content ==========================> #{tag}"
#     #   end
#     #   indexes
#     # end
#     #
#     # def self.create_div_index(tag)
#     #   indexes = []
#     #
#     #   case
#     #   when tag.classes.include?("tabs")
#     #     indexes << tag.css("ul").css("li").map { |li| li.text.strip }.join(" | ")
#     #     tag.css("div.tab_content").each { |tab_content|
#     #       tab_content.children.each { |child_tag| indexes.concat(create_default_index(child_tag)) }
#     #     }
#     #   when tag.classes.include?("code")
#     #     unless tag.css(".code_title").text.strip.empty?
#     #       indexes << tag.css(".code_title").text.strip
#     #     end
#     #     unless tag.css("td.rouge-code").text.strip.empty?
#     #       indexes << tag.css("td.rouge-code").text.strip
#     #     end
#     #   else
#     #     tag.children.each { |child_tag| indexes.concat(create_default_index(child_tag)) }
#     #   end
#     #
#     #   indexes
#     # end
#   end
# end