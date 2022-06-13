module Jekyll
  module Potion
    class RootBlockTagRegistry
      TAGS = {}

      def self.registered_tag(root_block_class, tag_name)
        return nil unless TAGS.has_key?(root_block_class)
        return nil unless TAGS[root_block_class].has_key?(tag_name)
        TAGS[root_block_class][tag_name]
      end

      def self.register_tag(root_block_class, tag_name, tag_class)
        if TAGS.has_key?(root_block_class)
          TAGS[root_block_class][tag_name] = tag_class
        else
          TAGS[root_block_class] = { tag_name => tag_class }
        end
      end
    end
  end
end