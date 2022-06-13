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
  end
end

require "#{__dir__}/lib/site.rb"
require "#{__dir__}/lib/page.rb"
require "#{__dir__}/lib/registry.rb"
require "#{__dir__}/lib/tag_module.rb"
require "#{__dir__}/lib/block.rb"
require "#{__dir__}/lib/child.rb"
