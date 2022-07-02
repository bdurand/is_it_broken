# frozen_string_literal: true

module IsItBroken
  # TODO document behavior and options
  # TODO add options for https_only, headers, and auth

  class RackHandler
    JSON_CONTENT_TYPE = "application/json"
    TEXT_CONTENT_TYPE = "text/plain"
    HTML_CONTENT_TYPE = "text/html"

    def initialize(*check_names)
      @check_names = check_names.flatten.dup
      @failure_status = 500
      @warning_status = 200
      if @check_names.last.is_a?(Hash)
        options = @check_names.pop
        @failure_status = options[:failure_status] if options[:failure_status]
        @warning_status = options[:warning_status] if options[:warning_status]
      end
      @check_names.freeze
      @html_template = ERB.new(File.read(File.join(__dir__, "response.html.erb")))
    end

    def call(env)
      start_time = Time.now
      results = IsItBroken.check(@check_names)
      elapsed_time_ms = ((Time.now - start_time) * 1000).round
      render(env, results, start_time, elapsed_time_ms)
    end

    private

    def render(env, results, timestamp, elapsed_time_ms) # :nodoc:
      content_type = response_content_type(env)

      headers = {
        "Content-Type" => "#{content_type}; charset=utf8",
        "Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate",
        "Date" => timestamp.httpdate,
        "X-Robots" => "noindex, nofollow, nosnippet",
        "Access-Control-Allow-Origin" => "*"
      }

      status = 200
      if results.any?(&:failure?)
        status = @failure_status
      elsif results.any?(&:warning?)
        status = @warning_status
      end

      body = if content_type == "text/html"
        render_html(results, timestamp, elapsed_time_ms)
      elsif content_type == "application/json"
        render_json(results, timestamp, elapsed_time_ms)
      else
        render_text(results, timestamp, elapsed_time_ms)
      end

      [status, headers, [body]]
    end

    def render_text(results, timestamp, elapsed_time_ms)
      info = []
      info << "Timestamp: #{timestamp.iso8601}"
      info << "Elapsed Time: #{elapsed_time_ms.round}ms"
      info << "\n"
      results.each do |result|
        result.messages.each do |message|
          info << "#{message.status_label} #{result.name} - #{message.text} (#{sprintf("%0.1f", message.time_ms)}ms)"
        end
      end
      info.join("\n")
    end

    def render_html(results, timestamp, elapsed_time_ms)
      @html_template.result(binding)
    end

    def render_json(results, timestamp, elapsed_time_ms)
      results_payload = []
      results.each do |result|
        message_payloads = []
        result.messages.each do |message|
          message_payloads << {status: message.status, text: message.text, elapsed_time: message.time}
        end
        results_payload << {name: result.name, status: result.status, messages: message_payloads}
      end
      payload = {timestamp: timestamp.iso8601, elapsed_time: elapsed_time_ms, results: results_payload}
      JSON.dump(payload)
    end

    def response_content_type(env)
      request = Rack::Request.new(env)

      accept = request.env["HTTP_ACCEPT"].to_s.downcase
      [JSON_CONTENT_TYPE, HTML_CONTENT_TYPE, TEXT_CONTENT_TYPE].each do |content_type|
        return content_type if accept.include?(content_type)
      end

      return JSON_CONTENT_TYPE if request.path.end_with?(".json")
      return TEXT_CONTENT_TYPE if request.path.end_with?(".txt")
      return HTML_CONTENT_TYPE if request.path.end_with?(".html")

      HTML_CONTENT_TYPE
    end
  end
end
