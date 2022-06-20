# require "#{__dir__}/lib/logger.rb"
# require "#{__dir__}/processor/potion_processor.rb"
# require "#{__dir__}/processor/optional_front_matter_processor.rb"
# require "#{__dir__}/processor/make_title_processor.rb"
# require "#{__dir__}/lib/config.rb"

module Jekyll
  module Potion
    DATA_KEY = "potion"
    CONFIG_KEY = "potion_config"
    THEME_KEY = "theme"
    DEFAULT_THEME = "proto"

    IS_MAKE_TITLE_KEY = "is_make_title"
    IS_SHOW_PAGINATION = "is_show_pagination"
    IS_SHOW_EMPTY_TO_CHILD_PAGES = "is_show_empty_to_child_pages"

    TITLE_REGEX = %r! \A\s* (?: \#{1,3}\s+(.*)(?:\s+\#{1,3})? | (.*)\r?\n[-=]+\s* )$ !x.freeze

    TEMPLATE_PATH = "/_plugins/templates"

    TITLE = "title"
    DEPTH_ORDER = "depth_order"

    # Config.load_config
  end
end

require "#{__dir__}/../potion/lib/site.rb"
require "#{__dir__}/../potion/lib/page.rb"
require "#{__dir__}/../potion/lib/registry.rb"
require "#{__dir__}/../potion/lib/tag_module.rb"
require "#{__dir__}/../potion/lib/block.rb"
require "#{__dir__}/../potion/lib/child.rb"

