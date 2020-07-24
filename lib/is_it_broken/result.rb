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

    def ok!(message)
      t = Time.now
      @messages << IsItBroken::Message.new(true, message, t - @time)
      @time = t
    end

    def fail!(message)
      t = Time.now
      @messages << IsItBroken::Message.new(false, message, t - @time)
      @time = t
    end

    def to_s
      text = []
      messages.each do |m|
        text << "#{m.success? ? "OK:  " : "FAIL:"} #{name} - #{m.text} (#{sprintf("%0.1f", m.time * 1000)}ms)"
      end
      text.join("\n")
    end
  end
end
