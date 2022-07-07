module Jekyll::Potion
  class Path
    attr_reader :url
    attr_reader :path
    attr_reader :name

    def initialize(path)
      @url = "/#{path}"
      @path = File.dirname(path)
      @name = File.basename(path)
    end
  end

  class BaseUtil
    def initialize(config)
      @base_path = config.base_path
      @site = config.site
      @config = config
    end
  end

  class SiteUtil < BaseUtil
    def site_title
      @config.site_title
    end

    def page_title(page)
      if site_title.empty?
        page.data["title"]
      else
        "#{site_title} - #{page.data["title"]}"
      end
    end

    def site_icon?
      not @config.site_icon.empty?
    end

    def site_icon
      Util[:url].base_url(@config.site_icon)
    end

    def site_icon_with_domain
      File.join(@site.config["url"], site_icon)
    end

    def favicon?
      not @config.favicon.empty?
    end

    def favicon_path
      File.dirname(@config.favicon)
    end

    def read_favicon_file
      Util[:file].read_file(@config.favicon)
    end
  end

  class UrlUtil < BaseUtil
    def baseurl
      @site.config["baseurl"] ||= ""
    end

    def base_url(*args)
      File.join(baseurl, *args)
    end

    def index_url
      base_url("")
    end

    def base_url_with_domain(*args)
      File.join(@site.config["url"], base_url(*args))
    end

    def assets_base_url(*args)
      File.join(File.join(baseurl, Util[:theme].assets_target_root_path), *args)
    end
  end

  class FileUtil < BaseUtil
    def read_file(path)
      File.read(File.join(@site.source, path))
    end

    def jsonify(path)
      JSON.parse(read_file(path))
    end

    def load_files(base, dir, block)
      Dir.foreach(File.join(base, dir)) { |file_name|
        next if file_name == "." or file_name == ".."

        path = File.join(base, dir, file_name)

        if File.directory?(path)
          load_files(base, file_name, block)
        else
          block.call(base, dir, file_name)
        end
      }
    end
  end

  class PathUtil < BaseUtil
    def absolute_path(base, path, *args)
      Pathname.new(File.join(base, File.join(path, *args))).cleanpath.to_s
    end

    def based_absolute_path(path, *args)
      absolute_path(Util[:url].baseurl, path, *args)
    end

    def to_path(base, path, *args)
      Path.new(absolute_path(base, path, args))
    end
  end

  class ThemeUtil < BaseUtil
    def default_theme
      @config.default_theme
    end

    def current_theme
      @config.current_theme
    end

    def includes
      File.join(@site.source, current_theme._includes)
    end

    def layouts
      current_theme._layouts
    end

    def assets_target_root_path
      current_theme.assets_target_root_path
    end

    def load_files_in_assets(&block)
      Util[:file].load_files(current_theme.assets_source_dir, "", block)
    end

    def scss_source_dir
      current_theme.scss_source_dir
    end

    def include_scss_file?(file_name)
      current_theme.scss_scss_files.include?(file_name)
    end

    def theme_default(theme_name)
      Theme.default(theme_name, @config.base_path)
    end

    def index_page?
      not @config.index_page.empty?
    end

    def index_page
      @config.index_page
    end

    def index_scope
      {
        "scope" => {
          "path" => index_page
        },
        "values" => {
          "permalink" => ""
        }
      }
    end

    def permalink?
      @config.permalink.empty?
    end

    def default_scope
      default_scope = {
        "scope" => {
          "path" => ""
        },
        "values" => {
          "layout" => current_theme.default_layout
        }
      }
      default_scope["values"]["permalink"] = @config.permalink unless permalink?
      default_scope
    end
  end

  class ConverterUtil < BaseUtil
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

    def replace_scss_ext(file_name)
      "#{File.basename(file_name, ".*")}#{scss_converter.output_ext(File.extname(file_name))}"
    end
  end

  class PotionPageUtil < BaseUtil
    def static_file(base, dir, name, target)
      PotionStaticFile.new(@site, base, dir, name, target)
    end

    def assets_static_file(base, dir, name, target = "")
      if target.empty?
        target = Util[:theme].assets_target_root_path
      else
        target = File.join(Util[:theme].assets_target_root_path, target)
      end

      static_file(base, dir, name, target)
    end

    def potion_page(path, name, target)
      PotionPage.new(@site, path, name, target)
    end

    def assets_potion_page(path, name)
      potion_page(path, name, Util[:theme].current_theme.assets_target_root_path)
    end

    def assets_scss_potion_page(base, dir, file_name)
      scss_file = assets_potion_page(dir, Util[:converter].replace_scss_ext(file_name))
      scss_file.output = Util[:converter].scss_convert(Util[:file].read_file(File.join(base, dir, file_name)))
      scss_file
    end

    def assets_map_page(scss_file)
      PotionSourceMapPage.new(scss_file, Util[:theme].assets_target_root_path)
    end

    def page(base, dir, name)
      Jekyll::Page.new(@site, base, dir, name)
    end

    def static_to_page(static_page)
      base = static_page.instance_variable_get("@base")
      dir = static_page.instance_variable_get("@dir")
      name = static_page.instance_variable_get("@name")

      page(base, dir, name)
    end
  end

  class TagUtil < BaseUtil
    LIQUID_EXTENSION = ".liquid"

    TEMPLATE_PATH = "template"

    @@navigation = nil
    @@navigation_result = ""

    def load_tags_template(template_name, theme_path = "")
      begin
        theme_path = Util[:theme].current_theme.theme_path if theme_path.empty?
        load_template(File.join(theme_path, TEMPLATE_PATH, [template_name, LIQUID_EXTENSION].join))
      rescue
        load_tags_template(template_name, Util[:theme].default_theme.theme_path) unless theme_path == Util[:theme].default_theme.theme_path
      end
    end

    def load_template(path)
      Liquid::Template.parse(Util[:file].read_file(path))
    end

    def markdown_convert(body)
      Util[:converter].markdown_converter.convert(body)
    end

    def render_template(template_name, context)
      load_tags_template(template_name).render(context)
    end

    def config(tag_name)
      Util[:theme].current_theme.tag_config(tag_name)
    end

    def navigation(root_potions)
      @@navigation = root_potions
    end

    def render_navigation(tag)
      @@navigation_result = tag.render_only_one(@@navigation) if @@navigation_result.empty?
      @@navigation_result
    end
  end

  class Util
    @@utils = {}

    TYPES = {
      :site => SiteUtil,
      :file => FileUtil,
      :url => UrlUtil,
      :path => PathUtil,
      :theme => ThemeUtil,
      :converter => ConverterUtil,
      :page => PotionPageUtil,
      :tag => TagUtil
    }

    def self.initialize(config)
      TYPES.each { |type, utilClass| @@utils[type] = utilClass.new(config) }
    end

    def self.[] (type)
      @@utils[type]
    end
  end
end
