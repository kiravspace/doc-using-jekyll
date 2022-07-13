module Jekyll::Potion
  class Util
    # load_files(base, dir, &block)
    #
    # base, dir을 기준으로 조회되는 모든 파일의 base, dir, file_name 을 block method 으로 전달한다.
    def self.load_files(base, dir = "", &block)
      Dir.foreach(File.join(base, dir)) { |file_name|
        next if file_name == "." or file_name == ".."

        path = File.join(base, dir, file_name)

        if File.directory?(path)
          self.load_files(base, file_name, &block)
        else
          block.call(base, dir, file_name)
        end
      }
    end

    def self.read_file(base, path)
      File.read(File.join(base, path))
    end

    def self.load_template(base, path)
      Liquid::Template.parse(read_file(base, path))
    end

    def self.jsonify(base, path)
      JSON.parse(read_file(base, path))
    end

    def self.extract(base, config, check_type = true, parent_key = "")
      config = {} if config.nil?

      raise SyntaxError, "config is not valid type #{base.class} <=> #{config.class}" unless base.is_a?(Hash) and config.is_a?(Hash)

      extracted = {}

      base.each { |key, value|
        config_value = config[key] ||= config[key.to_s]

        if config_value.nil?
          extracted[key] = value
        elsif (value.is_a?(TrueClass) or value.is_a?(FalseClass)) and (config_value.is_a?(TrueClass) or config_value.is_a?(FalseClass))
          extracted[key] = config_value
        else
          raise SyntaxError, "#{parent_key}#{key} is not valid base[#{value.class}] <=> config[#{config_value.class}]" if check_type && value.class != config_value.class

          if config_value.is_a?(Hash)
            extracted[key] = self.extract(base[key], config_value, check_type, "#{parent_key}#{key}.")
          else
            extracted[key] = config_value
          end
        end
      }

      extracted
    end

    def self.string_key_hash(sym_key_hash)
      sym_key_hash.map { |k, v|
        if v.is_a?(Hash)
          [k.to_s, string_key_hash(v)]
        else
          [k.to_s, v]
        end
      }.to_h
    end
  end
end
