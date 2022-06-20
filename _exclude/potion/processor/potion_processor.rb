module Potion
  class PotionProcessor
    attr_accessor :config
    attr_accessor :logger

    def initialize(config)
      @config = config
      @logger = Logger.new(self)
    end

    def site_pre_render(site) end

    def site_post_read(site) end

    def page_pre_render(page) end

    def page_post_render(page) end
  end
end