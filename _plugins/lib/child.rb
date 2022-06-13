module Jekyll
  module Potion
    module ChildBlockModule
      include TagModule

      MAX_DEPTH = 100

      def block_delimiter
        "end#{tag_name}"
      end

      def parse_body(body, tokens)
        if parse_context.depth >= MAX_DEPTH
          raise StackLevelError, "Nesting too deep".freeze
        end
        parse_context.depth += 1
        begin
          body.parse(tokens, parse_context) do |end_tag_name, end_tag_params|
            @blank &&= body.blank?

            return false if "#{end_tag_name}#{end_tag_params}".strip == block_delimiter
            unless end_tag_name
              raise SyntaxError.new(parse_context.locale.t("errors.syntax.tag_never_closed".freeze, block_name: block_name))
            end

            # this tag is not registered with the system
            # pass it to the current block for special handling or error reporting
            unknown_tag(end_tag_name, end_tag_params, tokens)
          end
        ensure
          parse_context.depth -= 1
        end

        true
      end
    end
  end
end