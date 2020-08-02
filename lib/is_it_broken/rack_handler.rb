# frozen_string_literal: true

module IsItBroken
  # TODO document behavior and options
  # TODO add options for https_only, headers, and auth
  # TODO is this the right class name?
  class RackHandler
    def initialize(*checks)
      @checks = checks.flatten
      @failure_status = 500
      @warning_status = 200
      if @checks.last.is_a?(Hash)
        options = @checks.pop
        @failure_status = options[:failure_status] if options[:failure_status]
        @warning_status = options[:warning_status] if options[:warning_status]
      end
    end

    def call(env)
      start_time = Time.now
      results = IsItBroken.check(@checks)
      elapsed_time_ms = ((Time.now - start_time) * 1000).round
      render(results, start_time, elapsed_time_ms)
    end

    private

    def render(results, timestamp, elapsed_time_ms) #:nodoc:
      content_type = response_content_type
      
      headers = {
        "Content-Type" => "#{content_type}; charset=utf8",
        "Cache-Control" => "no-cache",
        "Date" => timestamp.httpdate
      }

      status = 200
      if results.any?(&:failure?)
        status = @failure_status
      elsif results.any?(&:warning?)
        status = @warning_status
      end

      body = nil
      if content_type == "text/html"
        body = render_html(results, timestamp, elapsed_time_ms)
      elsif content_type == "application/json"
        body = render_json(results, timestamp, elapsed_time_ms)
      else
        body = render_text(results, timestamp, elapsed_time_ms)
      end
      
      [status, headers, [body]]
    end

    def render_text(results, timestamp, elapsed_time_ms)
      info = []
      info << "Timestamp: #{timestamp.iso8601}"
      info << "Elapsed Time: #{(elapsed_time * 1000).round}ms"
      info << "\n"
      results.each do |result|
        result.messages.each do |message|
          info << "#{message.status_label} #{result.name} - #{message.text} (#{sprintf("%0.1f", message.time_ms)}ms)"
        end
      end
      info.join("\n")
    end

    def render_html(results, timestamp, elapsed_time_ms)
      # TODO
    end

    def render_json(results, timestamp, elapsed_time_ms)
      # TODO
    end
    
    def response_content_type
      # TODO detect content type from request
      "text/plain"
    end
  end
end
