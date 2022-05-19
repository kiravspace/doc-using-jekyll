module Jekyll
  module Tags
    ATTRIBUTE_REGEX = /(.*?)="(.*?)"/
    TEMPLATE_PATH = "/_plugins/templates/"

    def find_converter(context)
      site = context.registers[:site]
      site.find_converter_instance(::Jekyll::Converters::Markdown)
    end

    def convert_body(context, body)
      Tags::find_converter(context).convert(body)
    end

    def find_template(template)
      Liquid::Template.parse(File.read("#{Dir.pwd}#{TEMPLATE_PATH}#{template}"))
    end

    def attr_to_hash(markup)
      markup.scan(ATTRIBUTE_REGEX).to_h.map { |k, v| [k.strip, v.strip] }.to_h
    end

    def ensure_valid_attr(tag_name, params, keys)
      keys.each { |key|
        unless params.has_key?(key)
          raise SyntaxError, "#{tag_name} required #{key} attribute"
        end
      }
    end

    module_function :find_converter
    module_function :convert_body
    module_function :find_template
    module_function :attr_to_hash
    module_function :ensure_valid_attr
  end
end
