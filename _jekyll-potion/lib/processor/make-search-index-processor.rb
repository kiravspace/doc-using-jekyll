require "nokogiri"
require "json"

module Jekyll::Potion
  class PageIndex
    def initialize(potion)
      @url = potion.url
      @order = potion.order
      @indexes = []
    end

    def add_index(index)
      @indexes << index
    end

    def count_sentences
      @indexes.map { |index| index.count_sentences }.sum
    end

    def to_json(_)
      JSON.pretty_generate(instance_variables.map { |var| [var.to_s.delete("@"), instance_variable_get(var)] }.to_h)
    end

    def self.title(titles)
      titles.select { |title| !title.empty? }.join(" > ")
    end

    def self.parse(skip_keyword, page, html, content_x_path)
      potion = PagePotion.potion(page)

      page_index = PageIndex.new(potion)

      search_index = SearchIndex.from_potion(skip_keyword, potion)

      titles = [page.data["title"], "", "", "", "", "", ""]

      html.css(content_x_path).children.each { |tag|
        if tag.name =~ /h(\d+)/
          unless tag.text.strip.empty?
            page_index.add_index(search_index)

            current = $1.to_i + 1

            (current..7).each { |i| titles[i] = "" }

            titles[current] = tag.text.strip

            search_index = SearchIndex.from_hash(skip_keyword, self.title(titles), tag["id"])
            search_index.add_sentence(tag.text.strip) unless tag.text.empty?
          end
        else
          search_index.parse(tag)
        end
      }
      page_index.add_index(search_index)
      page_index
    end
  end

  class SearchIndex
    def initialize(skip_keyword, title, hash = "")
      @skip_keyword = skip_keyword
      @title = title
      @hash = hash
      @sentences = []

      @hash = "##{@hash}" unless hash.empty?
    end

    def add_sentence(sentence)
      @sentences << sentence
    end

    def concat_sentences(sentences)
      @sentences.concat(sentences)
    end

    def parse(tag)
      unless tag.has_attribute?(@skip_keyword)
        case tag.name
        when "ul", "ol"
          tag.css("li").each { |li|
            @sentences << li.text.strip unless li.text.strip.empty?
          }
        when "table"
          if tag.classes.include?("rouge-table")
            @sentences << tag.css("td.rouge-code").text.strip unless tag.css("td.rouge-code").text.strip.empty?
          else
            tag.css("thread").css("tr").each { |tr|
              @sentences << tr.css("th").map { |td| td.text.strip }.join(" | ")
            }
            tag.css("tbody").css("tr").each { |tr|
              @sentences << tr.css("td").map { |td| td.text.strip }.join(" | ")
            }
          end
        when "pre"
          if tag.classes.include?("highlight")
            @sentences << tag.css("td.rouge-code").text.strip unless tag.css("td.rouge-code").text.strip.empty?
          end
        else
          tag.children.each { |child_tag|
            if child_tag.is_a?(Nokogiri::XML::Text)
              @sentences << child_tag.text.strip unless child_tag.text.strip.empty?
            else
              parse(child_tag)
            end
          }
        end
      end
    end

    def count_sentences
      @sentences.size
    end

    def to_json(_)
      JSON.pretty_generate(instance_variables.map { |var| [var.to_s.delete("@"), instance_variable_get(var)] }.to_h)
    end

    def self.from_potion(skip_keyword, potion)
      search_index = SearchIndex.new(skip_keyword, potion.title)
      search_index.add_sentence(potion.title) unless potion.title.nil? or potion.title.empty?
      search_index.add_sentence(potion.description) unless potion.description.nil? or potion.description.empty?
      search_index
    end

    def self.from_hash(skip_keyword, title, hash)
      search_index = SearchIndex.new(skip_keyword, title, hash)
      search_index
    end
  end

  class MakeSearchIndexProcessor < Processor
    priority :page_post_render, :lowest

    SCRIPT_TEMPLATE_PATH = "search-template".freeze
    SEARCH_SCRIPT_NAME = "search.js".freeze

    def initialize(site, theme, config, tags)
      super

      @base_dir = File.dirname(__FILE__)
      @base_dir["#{Dir.pwd}/"] = ""

      @base_path = MakeBaseJavascriptProcessor::BASE_SCRIPT_PATH

      @script_files = []
      @indexes = {}
    end

    def site_after_init(site)
      config = {
        "search_file" => @theme.base_assets_url(@base_path, @config[:search_file_name])
      }
      @script_file = @theme.assets_potion_page("", @base_path, SEARCH_SCRIPT_NAME)
      @script_file.output = @site.load_template(File.join(@base_dir, SCRIPT_TEMPLATE_PATH, SEARCH_SCRIPT_NAME)).render(config)
      @logger.trace("add base javascript file #{File.join(SCRIPT_TEMPLATE_PATH, SEARCH_SCRIPT_NAME)}")
    end

    def page_post_render(page, html, modified)
      if modified
        potion = PagePotion.potion(page)

        return if potion.nil?

        page_index = PageIndex.parse(@config[:skip_keyword], page, html, @theme[:content_x_path])
        @indexes[page.url] = page_index

        @logger.trace("make search index", "#{page.name}[#{page_index.count_sentences}]")
      end

      head = html.css("head").first

      unless head.nil?
        script = Nokogiri::XML::Node.new("script", html)
        script["type"] = "text/javascript"
        script["src"] = @site.base_url(@script_file.relative_path)
        head.add_child(script)
      end

      yield html
    end

    def site_post_render(site)
      index_file = @theme.assets_potion_page("", @base_path, @config[:search_file_name])
      index_file.output = JSON.pretty_generate(@indexes.values)

      site.pages -= [@script_file, index_file]

      @logger.trace("add base javascript file #{@script_file.relative_path}")
      @logger.trace("add search index file #{index_file.relative_path}")

      site.pages << @script_file
      site.pages << index_file
    end
  end
end
