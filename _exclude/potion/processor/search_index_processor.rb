require "nokogiri"

module Potion
  class SearchIndexProcessor < PotionProcessor
    def initialize(config)
      super
      @indexes = []
    end

    def page_post_render(page)
      if config.markdown_converter.matches(page.extname)
        html = Nokogiri::HTML.parse(page.output)

        page_index = {
          "url" => page.url,
          "hashes" => create_indexes(page, html.css("section").css("div.container").css("div.content"))
        }
        @indexes << page_index
        logger.trace(
          "make search index",
          "#{page.name}[#{page_index["hashes"].map { |hash| hash["indexes"].size }.inject(0) { |sum, x| sum + x }}]"
        )
      end
    end

    def create_indexes(page, content)
      hash = ""

      hashed = []

      indexes = [page.data["title"], page.data["description"]]

      titles = ["", "", "", "", "", ""]

      content.children.each { |tag|
        if tag.name =~ /h(\d+)/
          unless tag.text.strip.empty?
            current = $1.to_i

            (current..6).each { |i| titles[i] = "" }

            titles[current] = tag.text.strip

            hashed << {
              "hash" => hash,
              "title" => titles.select { |title| !title.empty? }.join(" > "),
              "indexes" => indexes.clone
            }

            hash = tag["id"]
            indexes.clear
            indexes << tag.text.strip
          end
        else
          indexes.concat(create_default_index(tag))
        end
      }

      hashed << {
        "hash" => hash,
        "title" => titles.select { |title| !title.empty? }.join(" > "),
        "indexes" => indexes.clone
      }

      hashed
    end

    def create_default_index(tag)
      indexes = []

      case tag.name
      when "a"
        unless tag.text.strip.empty?
          indexes << tag.text.strip
        end
      when "p", "blockquote"
        unless tag.text.strip.empty?
          indexes << tag.text.strip
        end
      when "ul", "ol"
        tag.css("li").each { |li|
          unless li.text.strip.empty?
            indexes << li.text.strip
          end
        }
      when "table"
        tag.css("thread").css("tr").each { |tr|
          indexes << tr.css("th").map { |td| td.text.strip }.join(" | ")
        }
        tag.css("tbody").css("tr").each { |tr|
          indexes << tr.css("td").map { |td| td.text.strip }.join(" | ")
        }
      when "div"
        indexes.concat(create_div_index(tag))
      when "pre"
        if tag.classes.include?("highlight")
          unless tag.css("td.rouge-code").text.strip.empty?
            indexes << tag.css("td.rouge-code").text.strip
          end
        end
      when "text", "hr"
        unless tag.text.strip.empty?
          indexes << tag.text.strip
        end
      else
        puts "undefined content ==========================> #{tag}"
      end
      indexes
    end

    def create_div_index(tag)
      indexes = []

      case
      when tag.classes.include?("tabs")
        indexes << tag.css("ul").css("li").map { |li| li.text.strip }.join(" | ")
        tag.css("div.tab_content").each { |tab_content|
          tab_content.children.each { |child_tag| indexes.concat(create_default_index(child_tag)) }
        }
      when tag.classes.include?("code")
        unless tag.css(".code_title").text.strip.empty?
          indexes << tag.css(".code_title").text.strip
        end
        unless tag.css("td.rouge-code").text.strip.empty?
          indexes << tag.css("td.rouge-code").text.strip
        end
      else
        tag.children.each { |child_tag| indexes.concat(create_default_index(child_tag)) }
      end

      indexes
    end
  end
end