# frozen_string_literal: true

module IsItBroken
  # Base class for defining a check. Subclasses should override the `call` method.
  class Check
    attr_reader :options

    def initialize(options = nil, &block)
      @options = (options ? options.dup : {})
      @block = block
    end

    def run(name)
      result = IsItBroken::Result.new(name)
      begin
        call(result)
      rescue => e
        result.fail!(e.class.name)
      end
      result
    end

    # Subclasses can override the call method to implement their own behavior.
    # The default behavior is to call the block passed to the constructor.
    def call(result)
      @block.call(result)
    end

    def async?
      options[:async] != false
    end
  end
end
