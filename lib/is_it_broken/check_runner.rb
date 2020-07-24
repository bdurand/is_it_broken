# frozen_string_literal: true

module IsItBroken
  # Class for running a list of checks.
  class CheckRunner
    class SyncRunner #:nodoc:
      def initialize(name, check)
        @result = check.run(name)
      end

      def value #:nodoc:
        @result
      end
    end

    class AsyncRunner < Thread #:nodoc:
      def initialize(name, check)
        super { check.run(name) }
      end
    end

    attr_reader :names

    def initialize(config, names)
      @config = config
      @names = names.flatten.collect(&:to_s)
    end

    def run
      checks = []
      names.each do |name, index|
        add_check(name, checks)
      end

      # Run the async checks in threads and then the synchronous checks, but return them
      # in the order they were defined.
      async_runners = []
      sync_runners = []
      order = {}
      index = 0
      checks.each do |name, async, check|
        index += 1
        order[name] = index
        if async
          async_runners << AsyncRunner.new(name, check)
        else
          sync_runners << SyncRunner.new(name, check)
        end
      end

      results = (async_runners + sync_runners).collect(&:value)
      results.sort_by { |result| order[result.name] }
    end

    private

    def add_check(name, checks)
      return if checks.detect { |n, async, check| name == n }
      check, async = @config.fetch(name)
      if check.nil?
        raise ArgumentError.new("Check not registered: #{name.inspect}")
      elsif check.is_a?(Group)
        check.names.each do |check_name|
          add_check(check_name, checks)
        end
      elsif async && check.async?
        checks << [name, async, check]
      else
        checks << [name, async, check]
      end
    end
  end
end
