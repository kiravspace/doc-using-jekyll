require "nokogiri"

module Jekyll::Potion
  class Processor
    attr_accessor :config
    attr_accessor :logger

    def initialize(config)
      @config = config
      @logger = Logger.new(self)
    end

    def site_pre_render(site) end

    def site_post_read(site) end

    def site_post_render(site) end

    def page_pre_render(page) end

    def page_post_render(page) end

    def self.load_processor_class(processor_name)
      require_relative "processor/#{processor_name}.rb"

      constants = Jekyll::Potion.constants.select { |c|
        c.downcase.to_s == processor_name.to_s.gsub(/-/, "").downcase
      }

      raise SyntaxError, "undefined #{processor_name} class" if constants.empty?
      raise SyntaxError, "duplicate #{processor_name} class" if constants.size > 1

      Logger.trace(name, "load processor", processor_name)

      Jekyll::Potion.const_get(constants.first)
    end

    def self.do_with_site(processors, symbol, site)
      processors.select { |processor| processor.class.method_defined?(symbol, false) }
                .each { |processor| processor.method(symbol).call(site) }
    end

    def self.do_with_page(processors, symbol, page)
      processors.each { |processor|
        html = Nokogiri::HTML.parse(page.output)

        if processor.is_a?(HTMLPageProcessor)
          method = HTMLPageProcessor.replace_method(processor, symbol)
          method.call(page, html) { |updated| page.output = updated.to_s } unless method.nil?
        elsif processor.class.method_defined?(symbol, false)
          processor.method(symbol).call(page)
        end
      }
    end
  end

  class HTMLPageProcessor < Processor
    def html_pre_render(page, html) end

    def html_post_render(page, html) end

    def self.replace_method(processor, symbol)
      processor.method(symbol.to_s.gsub("page", "html").to_sym)
    end
  end

end