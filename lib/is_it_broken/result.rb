# frozen_string_literal: true

module IsItBroken
  # Class for holding the result of a check.
  # TODO: add support for warning.
  class Result
    attr_reader :name, :messages

    def initialize(name)
      @name = name
      @messages = []
      @time = Time.now
    end

    def success?
      @messages.all?(&:success?)
    end

    def warning?
      !success? && !failure?
    end

    def failure?
      @messages.any?(&:failure?)
    end

    def ok!(message)
      t = Time.now
      @messages << IsItBroken::Message.new(:success, message, t - @time)
      @time = t
    end

    def warn!(message)
      t = Time.now
      @messages << IsItBroken::Message.new(:warning, message, t - @time)
      @time = t
    end

    def fail!(message)
      t = Time.now
      @messages << IsItBroken::Message.new(:failure, message, t - @time)
      @time = t
    end
  end
end
