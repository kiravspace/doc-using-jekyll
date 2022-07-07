module Jekyll::Potion
  class Merger
    def self.merge(config, default)
      self.merge!(config, default.clone)
    end

    def self.merge!(config, default = {})
      if config.nil?
        default
      else
        config.each do |k, v|
          if v.instance_of? Hash
            self.merge!(config[k], default[k])
          else
            default[k] = config[k] ||= default[k]
          end
        end
        default
      end
    end

    def self.fill(config, default)
      self.fill!(config, default.clone)
    end

    def self.fill!(config, default)
      if config.nil?
        default
      else
        default.each do |k, v|
          if v.instance_of? Hash
            self.fill!(config[k], v)
          else
            default[k] = config[k] ||= v
          end
        end
        default
      end
    end
  end
end
