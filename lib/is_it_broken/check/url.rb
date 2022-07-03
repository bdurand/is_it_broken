# frozen_string_literal: true

require "net/http"
require "net/https"

module IsItBroken
  # Check if a URL returns a successful response. Only responses in the range 2xx or 304
  # are considered successful. Redirects will not be followed.
  #
  # Available options are:
  # * :get - The URL to get.
  # * :headers - Hash of headers to send with the request
  # * :proxy - Hash of proxy server information. The hash must contain a :host key and may contain :port, :username, and :password
  # * :username - Username to use for Basic Authentication
  # * :password - Password to use for Basic Authentication
  # * :open_timeout - Time in seconds to wait for opening the connection (defaults to 5 seconds)
  # * :read_timeout - Time in seconds to wait for data from the connection (defaults to 10 seconds)
  # * :alias - Alias used for reporting in case making the URL known to the world could provide a security risk.
  class Check::Url < Check
    class RedirectError < StandardError; end

    def initialize(url, headers: {}, method: :get, proxy: nil, username: nil, password: nil, open_timeout: 5.0, read_timeout: 10.0, url_alias: nil, allow_redirects: false)
      @uri = URI.parse(url)
      @method = method.to_sym
      @headers = headers
      @proxy = proxy
      @username = username
      @password = password
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @display_name = (url_alias || url)
      @allow_redirects = allow_redirects
      raise ArgumentError.new("Invalid method: #{method.inspect}") unless http_request_class
    end

    def call(result)
      t = Time.now
      response = perform_http_request(@uri)
      if response.is_a?(Net::HTTPSuccess)
        result.success!("#{@method.to_s.upcase} #{@display_name} responded with '#{response.code} #{response.message}'")
      else
        result.fail!("#{@method.to_s.upcase} #{@display_name} failed with '#{response.code} #{response.message}'")
      end
    rescue Timeout::Error
      result.fail!("#{@method.to_s.upcase} #{@display_name} timed out after #{(Time.now - t).round(1)} seconds")
    rescue RedirectError => e
      result.fail!("#{@method.to_s.upcase} #{@display_name} failed with #{e.message}")
    end

    private

    # Perform an HTTP request and return the response
    def perform_http_request(uri, redirects = []) # :nodoc:
      request = http_request_class.new(uri.request_uri, @headers)
      request.basic_auth(@username, @password) if @username || @password
      http = instantiate_http(uri)
      response = http.start { http.request(request) }
      if @allow_redirects && response.is_a?(Net::HTTPRedirection)
        location = response_location(response)
        if redirects.size >= 5
          raise RedirectError, "too many redirects"
        elsif redirects.include?(location)
          raise RedirectError, "cicular redirect"
        elsif location.nil?
          raise RedirectError, "redirect to unknown location"
        else
          redirects << location
          response = perform_http_request(URI(location), redirects)
        end
      end
      response
    end

    def response_location(response)
      location = response["Location"]
      if location && !location.include?(":")
        location = begin
          URI.parse(location)
        rescue
          nil
        end
        if location
          location.scheme = uri.scheme
          location.host = uri.host
        end
      end
      location
    end

    # Create an HTTP object with the options set.
    def instantiate_http(uri) # :nodoc:
      http_class = if @proxy && @proxy[:host]
        Net::HTTP::Proxy(@proxy[:host], @proxy[:port], @proxy[:username], @proxy[:password])
      else
        Net::HTTP
      end

      http = http_class.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      http.open_timeout = @open_timeout
      http.read_timeout = @read_timeout

      http
    end

    def http_request_class # :nodoc:
      case @method
      when :get
        Net::HTTP::Get
      when :head
        Net::HTTP::Head
      when :post
        Net::HTTP::Post
      when :options
        Net::HTTP::Options
      when :trace
        Net::HTTP::Trace
      end
    end
  end
end
