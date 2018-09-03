# frozen_string_literal: true

module IsItBroken
  # Class for holding the status and text for a response message.
  class Message
    attr_reader :text, :time

    def initialize(success, text, time)
      @success = !!success
      @text = text
      @time = time
    end

    def success?
      @success
    end
  end
end
