module Generator
  class Generator < Jekyll::Generator
    attr_accessor :configuration
    attr_accessor :site
    priority :low

    CONFIG_KEY = "generator"

    def initialize(configuration)
      @configuration = configuration[CONFIG_KEY]
      @page_generator = PageGenerator.new(@configuration)
      @title_generator = TitleGenerator.new(@configuration)
      @meta_generator = MetaGenerator.new(@configuration)
    end

    def generate(site)
      @page_generator.generate(site)
      @title_generator.generate(site)
      @meta_generator.generate(site)
    end
  end

  class StepGenerator
    attr_accessor :site
    attr_accessor :configuration

    def initialize(configuration)
      @configuration = configuration[CONFIG_KEY] unless configuration.nil?
    end

    def generate(site)
      @site = site
    end

    def select_markdown_pages(files)
      files.select { |file| markdown_converter.matches(file.extname) }
    end

    def markdown_converter
      @markdown_converter ||= site.find_converter_instance(Jekyll::Converters::Markdown)
    end
  end

  class PageGenerator < StepGenerator
    CONFIG_KEY = "page_generator"

    def generate(site)
      super

      site.pages.concat(pages)
      site.static_files -= markdown_pages
    end

    def pages
      markdown_pages.map do |page|
        base = page.instance_variable_get("@base")
        dir = page.instance_variable_get("@dir")
        name = page.instance_variable_get("@name")
        Jekyll::Page.new(site, base, dir, name)
      end
    end

    def markdown_pages
      select_markdown_pages(site.static_files)
    end
  end

  class TitleGenerator < StepGenerator
    CONFIG_KEY = "title_generator"

    TITLE_REGEX =
      %r!
        \A\s*                             # Beginning and whitespace
          (?:                             # either
            \#{1,3}\s+(.*)(?:\s+\#{1,3})? # atx-style header
            |                             # or
            (.*)\r?\n[-=]+\s*             # Setex-style header
          )$                              # end of line
      !x.freeze

    def generate(site)
      super

      required_title_markdown_pages.each do |page|
        title = make_title(page)
        page.data["title"] = title
        page.content = page.content.gsub(TITLE_REGEX, "").strip
      end
    end

    def required_title_markdown_pages
      select_markdown_pages(site.pages).select { |page| page.data["title"].nil? }
    end

    def make_title(page)
      matches = page.content.to_s.match(TITLE_REGEX)
      if matches
        matches[1] || matches[2]
      else
        page.data["title"]
      end
    end
  end

  class MetaGenerator < StepGenerator
    CONFIG_KEY = "meta_generator"

    def initialize(configuration)
      super

      @site_meta = SiteMeta::new
    end

    def generate(site)
      super

      @site_meta.generate(select_markdown_pages(site.pages))
      site.data["meta"] = @site_meta
    end
  end
end
