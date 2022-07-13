require_relative "lib/models/favicon"
require_relative "lib/models/page-potion"
require_relative "lib/models/potion-page"
require_relative "lib/models/potion-static-file"
require_relative "lib/models/potion-source-map-page"

require_relative "lib/util"
require_relative "lib/logger"
require_relative "lib/processor"
require_relative "lib/tag"
require_relative "lib/site"
require_relative "lib/theme"
require_relative "lib/potion"

module Jekyll::Potion
  BASE_DIR = File.dirname(__FILE__)
  BASE_DIR["#{Dir.pwd}/"] = ""
  BASE_DIR.freeze

  potion_base_dir = File.dirname(__FILE__)
  potion_base_dir["#{Dir.pwd}/"] = ""

  Potion.load(potion_base_dir)
end

require_relative "lib/tags/alerts"
require_relative "lib/tags/api"
require_relative "lib/tags/code"
require_relative "lib/tags/empty"
require_relative "lib/tags/file"
require_relative "lib/tags/link"
require_relative "lib/tags/logo"
require_relative "lib/tags/navigation"
require_relative "lib/tags/pagination"
require_relative "lib/tags/tabs"
