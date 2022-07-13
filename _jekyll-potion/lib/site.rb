module Jekyll::Potion
  class Url
    attr_reader :url
    attr_reader :path
    attr_reader :name

    def initialize(path)
      @url = "/#{path}"
      @path = File.dirname(path)
      @name = File.basename(path)
    end
  end

  class Site
    DEFAULT_SITE_CONFIG = {
      :index_page => "",
      :permalink => "",
      :title => "",
      :icon => "",
      :theme => "proto",
      :favicon => ""
    }

    def initialize(potion_base_dir, site, config)
      @site = site
      @config = Util.extract(DEFAULT_SITE_CONFIG, config)
      @config[:potion_base_dir] = potion_base_dir

      @navigation = nil
      @navigation_result = ""
    end

    def [] (key)
      @config[key]
    end

    def empty?(key)
      not @config.has_key?(key) or @config[key].nil? or @config[key].empty?
    end

    def baseurl
      @site.config["baseurl"] ||= ""
    end

    def url
      @site.config["url"] ||= ""
    end

    def absolute_url(base, path, *args)
      Pathname.new(File.join(base, File.join(path, *args))).cleanpath.to_s
    end

    def base_absolute_url(path, *args)
      absolute_url(baseurl, path, *args)
    end

    def base_url(*args)
      File.join(baseurl, *args)
    end

    def to_url(base, path, *args)
      Url.new(absolute_url(base, path, args))
    end

    def index_url
      base_url("")
    end

    def full_url(*args)
      File.join(url, base_url(*args))
    end

    def page_title(page)
      if empty?(:title)
        page.data["title"]
      else
        "#{@config[:title]} - #{page.data["title"]}"
      end
    end

    def static_file(base, dir, name, target)
      PotionStaticFile.new(@site, base, dir, name, target)
    end

    def potion_page(base, dir, name, target)
      PotionPage.new(@site, base, dir, name, target)
    end

    def static_to_page(static_page)
      base = static_page.instance_variable_get("@base")
      dir = static_page.instance_variable_get("@dir")
      name = static_page.instance_variable_get("@name")

      page(base, dir, name)
    end

    def markdown_converter
      @site.find_converter_instance(Jekyll::Converters::Markdown)
    end

    def markdown_pages
      @site.pages.select { |page| markdown_converter.matches(page.extname) }
    end

    def static_markdown_files
      @site.static_files.select { |file| markdown_converter.matches(file.extname) }
    end

    def scss_converter
      @site.find_converter_instance(Jekyll::Converters::Scss)
    end

    def scss_convert(body)
      scss_converter.convert(body)
    end

    def markdown_convert(body)
      markdown_converter.convert(body)
    end

    def replace_scss_ext(file_name)
      "#{File.basename(file_name, ".*")}#{scss_converter.output_ext(File.extname(file_name))}"
    end

    def read_file(path)
      File.read(File.join(@site.source, path))
    end

    def load_template(path)
      Liquid::Template.parse(read_file(path))
    end

    def jsonify(path)
      JSON.parse(read_file(path))
    end

    def navigation(root_potions)
      @navigation = root_potions
    end

    def render_navigation(tag)
      @navigation_result = tag.render_only_one(@navigation) if @navigation_result.empty?
      @navigation_result
    end
  end
end
