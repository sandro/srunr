module Srunr
  class Configuration
    attr_accessor :options

    DEFAULTS = {
      hostname: ""
    }

    DEFAULTS.each do |k,v|
      define_method(k) do
        get_option(k)
      end

      define_method("#{k}=") do |val|
        options[k] = val
      end
    end

    def initialize(opts=nil)
      @options = opts || DEFAULTS
    end

    def get_option(key)
      val = options[key]
      if val.respond_to?(:call)
        val.call
      else
        val
      end
    end

  end
end
