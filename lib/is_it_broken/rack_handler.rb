# frozen_string_literal: true

module IsItBroken
  # TODO document behavior and options
  # TODO add options for https_only, headers, and auth
  # TODO add JSON output with .json suffix (or maybe need another option?)
  # TODO is this the right class name?
  class RackHandler
    def initialize(*checks)
      @checks = checks.flatten
      @failure_status = 500
      if @checks.last.is_a?(Hash)
        options = @checks.last
        @checks = @checks[0, @checks.size - 1]
        @failure_status = options[:status] if options[:status]
      end
    end

    def call(env)
      start_time = Time.now
      results = IsItBroken.check(@checks)
      elapsed_time = Time.now - start_time
      render(results, elapsed_time)
    end

    private

    def render(results, elapsed_time) #:nodoc:
      timestamp = Time. now
      fail = results.all? { |s| s.success? }
      headers = {
        "Content-Type" => "text/plain; charset=utf8",
        "Cache-Control" => "no-cache",
        "Date" => timestamp.httpdate,
      }

      info = []
      info << "Timestamp: #{timestamp.iso8601}"
      info << "Elapsed Time: #{(elapsed_time * 1000).round}ms"

      code = (fail ? 200 : @failure_status)

      [code, headers, [info.join("\n"), "\n\n", results.map(&:to_s).join("\n")]]
    end
  end
end
