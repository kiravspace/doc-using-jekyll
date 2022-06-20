%w[lib processor tags].each do |path|
  lib = File.expand_path(path, __dir__)
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

require "#{__dir__}/../potion/lib/logger"
require "#{__dir__}/../potion/processor/potion_processor"
require "#{__dir__}/../potion/processor/optional_front_matter_processor"
require "#{__dir__}/../potion/processor/make_title_processor"
require "#{__dir__}/../potion/processor/site_potion_processor"
require "#{__dir__}/../potion/processor/search_index_processor"
require "#{__dir__}/../potion/lib/config"

module Potion
  Config.load_config
end