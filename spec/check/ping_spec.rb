# frozen_string_literal: true

require "spec_helper"

describe IsItBroken::Check::Ping do
  it "can check if a port can be connected to on host" do
    check = IsItBroken::Check::Ping.new("localhost", 19864)
    TCPServer.open("127.0.0.1", 19864) do |serv|
      result = check.run(:ping)
      expect(result.assertions.first.success?).to eq true
      expect(result.assertions.first.message).to eq "localhost:19864 is accepting connections"
    end
    result = check.run(:ping)
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to eq "localhost:19864 is not accepting connections"
  end

  it "can alias the host name in the message" do
    check = IsItBroken::Check::Ping.new("localhost", 19864, host_alias: "foobar")
    result = check.run(:ping)
    expect(result.assertions.first.message).to eq "foobar is not accepting connections"
  end
end
