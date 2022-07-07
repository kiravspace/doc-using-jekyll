require "nokogiri"

module Jekyll::Potion
  class Processor
    @@priority = {}

    DEFAULT_PRIORITY = {
      :site_after_init => :lowest,
      :site_pre_render => :lowest,
      :site_post_read => :lowest,
      :page_pre_render => :lowest,
      :page_post_render => :lowest,
      :site_post_render => :lowest
    }

    attr_reader :priority

    def initialize
      @logger = Logger.new(self)
      @priority = Merger.fill(@@priority, DEFAULT_PRIORITY)
      @@priority = {}
    end

    def site_after_init(site) end

    def site_pre_render(site) end

    def site_post_read(site) end

    def site_post_render(site) end

    def page_pre_render(page, html) end

    def page_post_render(page, html) end

    def self.priority(event, priority)
      @@priority[event] = priority
    end

    def self.load_processor_class(processor_name)
      require_relative "processor/#{processor_name}.rb"

      constants = Jekyll::Potion.constants.select { |c|
        c.downcase.to_s == processor_name.to_s.gsub(/-/, "").downcase
      }

      raise SyntaxError, "undefined #{processor_name} class" if constants.empty?
      raise SyntaxError, "duplicate #{processor_name} class" if constants.size > 1

      Logger.trace(name, "load processor", processor_name)

      Jekyll::Potion.const_get(constants.first).new
    end
  end
end
