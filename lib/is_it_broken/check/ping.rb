# frozen_string_literal: true

require "socket"
require "timeout"

module IsItBroken
  # Check if a host is reachable and accepting connections on a specified port.
  #
  # The port can be either a port number or port name for a well known port (i.e. "smtp" and 25 are
  # equivalent).
  #
  # By default, the host name will be included in the output. If this could pose a security
  # risk by making the existence of the host known to the world, you can supply the host_alias
  # argument which will be used for output purposes. In general, you should supply this option
  # unless the host is on a private network behind a firewall.
  class Check::Ping < Check
    def initialize(host, port, timeout: 2.0, host_alias: nil)
      @host = host
      @port = port
      @timeout = timeout
      @display_name = (host_alias || "#{@host}:#{@port}")
    end

    def call(result)
      ping(@host, @port)
      result.success!("#{@display_name} is accepting connections")
    rescue Errno::ECONNREFUSED
      result.fail!("#{@display_name} is not accepting connections")
    rescue Errno::EHOSTUNREACH
      result.fail!("#{@display_name} is not reachable")
    rescue SocketError => e
      result.fail!("connection to #{@display_name} failed with #{e.message.inspect}")
    rescue Timeout::Error
      result.fail!("#{@display_name} did not respond within #{@timeout} seconds")
    end

    private

    def ping(host, port)
      Timeout.timeout(@timeout) do
        s = TCPSocket.new(host, port)
        s.close
      end
      true
    end
  end
end
