# frozen_string_literal: true

module IsItBroken
  # Class for holding the result of a check.
  class Result
    attr_reader :name, :assertions

    def initialize(name)
      @name = name.to_s
      @name = @name.dup.freeze unless @name.frozen?
      @assertions = []
    end

    def success?
      @assertions.all?(&:success?)
    end

    def warning?
      !success? && !failure?
    end

    def failure?
      @assertions.any?(&:failure?)
    end

    def status
      return :failure if failure?
      return :warning if warning?
      :success
    end

    def success!(message)
      @assertions << IsItBroken::Assertion.new(:success, message)
    end

    def warn!(message)
      @assertions << IsItBroken::Assertion.new(:warning, message)
    end

    def fail!(message)
      @assertions << IsItBroken::Assertion.new(:failure, message)
    end
  end
end
