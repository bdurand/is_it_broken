# frozen_string_literal: true

module IsItBroken
  # Class for holding the list of checks.
  class Configuration
    def initialize
      @lock = Mutex.new
      @checks = {}
    end

    def add(name, check: nil, async: true, &block)
      check = Check.new(async: async, &block) if check.nil? && block
      unless check
        raise ArgumentError.new("Either a check or a block must be specified")
      end
      @lock.synchronize do
        @checks[name.to_s] = [check, async]
      end
    end

    def delete(name)
      @lock.synchronize do
        @checks.delete(name.to_s)
      end
    end

    def clear
      @lock.synchronize do
        @checks.clear
      end
    end

    def group(name, check_names)
      @lock.synchronize do
        @checks[name.to_s] = [Group.new(self, check_names), true]
      end
    end

    # Returns [check, async] for the named check.
    def fetch(name) #:nodoc:
      @checks[name.to_s]
    end
  end
end
