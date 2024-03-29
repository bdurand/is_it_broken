# frozen_string_literal: true

module IsItBroken
  # TODO document behavior and options
  # TODO add options for https_only, headers, and auth

  class RackHandler
    JSON_CONTENT_TYPE = "application/json"
    TEXT_CONTENT_TYPE = "text/plain"
    HTML_CONTENT_TYPE = "text/html"

    def initialize(*check_names)
      @failure_status = 500
      @warning_status = 200
      @check_names = check_names.flatten.dup

      if @check_names.last.is_a?(Hash)
        options = @check_names.pop
        @failure_status = options[:failure_status] if options[:failure_status]
        @warning_status = options[:warning_status] if options[:warning_status]
      end

      if @check_names.empty?
        @check_names = IsItBroken.check_names
      end

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

      status_code = 200
      status = :success
      if results.any?(&:failure?)
        status = :failure
        status_code = @failure_status
      elsif results.any?(&:warning?)
        status_code = @warning_status
        status = :warning
      end

      body = if content_type == "text/html"
        render_html(status, results, timestamp, elapsed_time_ms)
      elsif content_type == "application/json"
        render_json(status, results, timestamp, elapsed_time_ms)
      else
        render_text(status, results, timestamp, elapsed_time_ms)
      end

      [status_code, headers, [body]]
    end

    def render_text(status, results, timestamp, elapsed_time_ms)
      info = []
      info << status.to_s.upcase
      info << "Timestamp: #{timestamp.iso8601}"
      info << "Elapsed Time: #{elapsed_time_ms.round}ms"
      info << "\n"
      results.each do |result|
        result.assertions.each do |assertion|
          info << "#{assertion.status_label} #{result.name} - #{assertion.message}"
        end
      end
      info.join("\n")
    end

    def render_html(status, results, timestamp, elapsed_time_ms)
      @html_template.result(binding)
    end

    def render_json(status, results, timestamp, elapsed_time_ms)
      results_payload = []
      results.each do |result|
        assertion_payloads = []
        result.assertions.each do |assertion|
          assertion_payloads << {status: assertion.status, message: assertion.message}
        end
        results_payload << {name: result.name, status: result.status, assertions: assertion_payloads}
      end
      payload = {timestamp: timestamp.iso8601, elapsed_time_ms: elapsed_time_ms, status: status, results: results_payload}
      JSON.dump(payload)
    end

    def response_content_type(env)
      request = Rack::Request.new(env)

      return JSON_CONTENT_TYPE if request.path.end_with?(".json")
      return TEXT_CONTENT_TYPE if request.path.end_with?(".txt")
      return HTML_CONTENT_TYPE if request.path.end_with?(".html")

      accept = request.env["HTTP_ACCEPT"].to_s.downcase
      [JSON_CONTENT_TYPE, HTML_CONTENT_TYPE, TEXT_CONTENT_TYPE].each do |content_type|
        return content_type if accept.include?(content_type)
      end

      HTML_CONTENT_TYPE
    end
  end
end
