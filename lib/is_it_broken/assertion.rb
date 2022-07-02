# frozen_string_literal: true

module IsItBroken
  # Class for holding the status and text for a response message.
  class Assertion
    STATUSES = [:success, :warning, :failure].freeze
    LABELS = {success: "SUCCESS", warning: "WARNING", failure: "FAILURE"}.freeze

    attr_reader :status, :message

    def initialize(status, message)
      unless STATUSES.include?(status)
        raise ArgumentError.new("status must be one of #{STATUSES.collect(&:inspect).join(", ")}")
      end
      @status = status
      @message = message
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

    def status_label
      LABELS[status]
    end
  end
end
