require "nokogiri"
require "json"

module Jekyll::Potion
  class MakeSearchIndexProcessor < Processor
    priority :page_post_render, :lowest

    SKIP_KEYWORD = "data-skip-search-index"

    SEARCH_FILE_PATH = "data"
    SEARCH_FILE_NAME = "search.json"

    def initialize
      super
      @indexes = []
    end

    def page_post_render(page, html)
      page_potion = PagePotion.potion(page)

      return if page_potion.nil?

      page_index = {
        "url" => page_potion.url,
        "hashes" => create_indexes(page, html.css("#container > div.content")),
        "order" => page_potion.order
      }
      @indexes << page_index
      @logger.trace(
        "make search index",
        "#{page.name}[#{page_index["hashes"].map { |hash| hash["indexes"].size }.inject(0) { |sum, x| sum + x }}]"
      )

      head = html.css("head").first
      meta = Nokogiri::XML::Node.new("meta", html)
      meta["property"] = "search-indexes-location"
      meta["content"] = Util[:url].assets_base_url(SEARCH_FILE_PATH, SEARCH_FILE_NAME)

      head.add_child(meta)
      yield html
    end

    def site_post_render(site)
      page = Util[:page].assets_potion_page(SEARCH_FILE_PATH, SEARCH_FILE_NAME)
      page.output = JSON.pretty_generate(@indexes)
      site.pages << page
    end

    def create_indexes(page, content)
      hash = ""

      hashed = []

      indexes = []
      indexes << page.data["title"]
      indexes << page.data["description"] unless page.data["description"].nil? || page.data["description"].empty?

      titles = [page.data["title"], "", "", "", "", "", ""]

      content.children.each { |tag|
        if tag.name =~ /h(\d+)/
          unless tag.text.strip.empty?
            hashed << {
              "hash" => "#{hash}",
              "title" => titles.select { |title| !title.empty? }.join(" > "),
              "indexes" => indexes.clone
            }

            current = $1.to_i + 1

            (current..7).each { |i| titles[i] = "" }

            titles[current] = tag.text.strip

            hash = tag["id"]
            indexes.clear
            indexes << tag.text.strip unless tag.text.empty?
          end
        else
          indexes.concat(create_default_index(tag))
        end
      }

      hashed << {
        "hash" => "#{hash}",
        "title" => titles.select { |title| !title.empty? }.join(" > "),
        "indexes" => indexes.clone
      }

      hashed
    end

    def create_default_index(tag)
      indexes = []

      unless tag.has_attribute?(SKIP_KEYWORD)
        case tag.name
        when "ul", "ol"
          tag.css("li").each { |li|
            indexes << li.text.strip unless li.text.strip.empty?
          }
        when "table"
          tag.css("thread").css("tr").each { |tr|
            indexes << tr.css("th").map { |td| td.text.strip }.join(" | ")
          }
          tag.css("tbody").css("tr").each { |tr|
            indexes << tr.css("td").map { |td| td.text.strip }.join(" | ")
          }
        when "div", "article", "header"
          indexes.concat(create_div_index(tag))
        when "pre"
          if tag.classes.include?("highlight")
            indexes << tag.css("td.rouge-code").text.strip unless tag.css("td.rouge-code").text.strip.empty?
          end
        else
          indexes << tag.text.strip unless tag.text.strip.empty?
        end
      end

      indexes
    end

    def create_div_index(tag)
      indexes = []

      unless tag.has_attribute?(SKIP_KEYWORD)
        case
        when tag.classes.include?("tabs")
          indexes << tag.css("[data-content-id]").map { |title| title.text.strip }.join(" | ")
          tag.css("[id]").each { |tab_content|
            tab_content.children.each { |child_tag| indexes.concat(create_default_index(child_tag)) } }
        when tag.classes.include?("code")
          indexes << tag.css(".title").text.strip unless tag.css(".title").text.strip.empty?
          indexes << tag.css("td.rouge-code").text.strip unless tag.css("td.rouge-code").text.strip.empty?
        else
          tag.children.each { |child_tag| indexes.concat(create_default_index(child_tag)) }
        end
      end

      indexes
    end
  end
end
