module AntiCaptcha
  class Configuration

    @@config_keys = []

    def self.config_key(key, default_value = nil)
      attr_accessor key
      @@config_keys << key
      if default_value
        define_method key do
          instance_variable_get(:"@#{key}") || default_value
        end
      end
    end

    config_key :key
    config_key :phrase, 0
    config_key :regsense, 0
    config_key :numeric, 0
    config_key :calc, 0
    config_key :min_len, 0
    config_key :max_len, 0
    config_key :is_russian, 0

    def options
      @@config_keys.each_with_object({}) do |key, hash|
        hash[key] = __send__(key) if __send__(key)
      end
    end

  end
end
