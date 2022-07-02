# frozen_string_literal: true

module IsItBroken
  # Class for holding the status and text for a response message.
  class Message
    STATUSES = [:success, :warning, :failure].freeze
    LABELS = {success: "SUCCESS", warning: "WARNING", failure: "FAILURE"}

    attr_reader :status, :text, :time

    def initialize(status, text, time)
      unless STATUSES.include?(status)
        raise ArgumentError.new("status must be one of #{STATUSES.collect(&:inspect).join(", ")}")
      end
      @status = status
      @text = text
      @time = time
    end

    def success?
      @status == :success
    end

    def warning?
      @status == :warning
    end

    def failure?
      @status == :failure
    end

    def time_ms
      (@time / 1000).round
    end

    def status_label
      LABELS[status]
    end
  end
end
