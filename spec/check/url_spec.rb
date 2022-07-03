# frozen_string_literal: true

require "spec_helper"

describe IsItBroken::Check::Url do
  it "can check if a URL can be fetched" do
    stub_request(:get, "https://example.com/test").to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test")
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "GET https://example.com/test responded with '200 "
  end

  it "fails if a URL cannot be fetched" do
    stub_request(:get, "https://example.com/test").to_return(status: 404)
    check = IsItBroken::Check::Url.new("https://example.com/test")
    result = check.run(:url)
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to include "GET https://example.com/test failed with '404 "
  end

  it "can speicify the request method" do
    stub_request(:post, "https://example.com/test").to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test", method: :post)
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "POST https://example.com/test responded with '200 "
  end

  it "can test a head request" do
    stub_request(:head, "https://example.com/test").to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test", method: :head)
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "HEAD https://example.com/test responded with '200 "
  end

  it "can test a options request" do
    stub_request(:options, "https://example.com/test").to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test", method: :options)
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "OPTIONS https://example.com/test responded with '200 "
  end

  it "can test a trace request" do
    stub_request(:trace, "https://example.com/test").to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test", method: :trace)
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "TRACE https://example.com/test responded with '200 "
  end

  it "can send request headers" do
    stub_request(:get, "https://example.com/test").with(headers: {Accept: "application/json"}).to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test", headers: {"Accept" => "application/json"})
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "GET https://example.com/test responded with '200 "
  end

  it "can set Basic authorization" do
    stub_request(:get, "https://example.com/test").with(basic_auth: ["user", "pass"]).to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test", username: "user", password: "pass")
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "GET https://example.com/test responded with '200 "
  end

  it "can set request timeouts" do
    stub_request(:get, "https://example.com/test").to_timeout
    check = IsItBroken::Check::Url.new("https://example.com/test")
    result = check.run(:url)
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to include "timed out after"
  end

  it "fails on redirects by default" do
    stub_request(:get, "https://example.com/test").to_return(status: 302)
    check = IsItBroken::Check::Url.new("https://example.com/test")
    result = check.run(:url)
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to include "GET https://example.com/test failed with '302 "
  end

  it "can follow redirects" do
    stub_request(:get, "https://example.com/test").to_return(status: 302, headers: {"Location" => "https://example.com/new"})
    stub_request(:get, "https://example.com/new").to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test", allow_redirects: true)
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "GET https://example.com/test responded with '200 "
  end

  it "limits redirects" do
    6.times do |i|
      stub_request(:get, "https://example.com/test/#{i}").to_return(status: 302, headers: {"Location" => "https://example.com/test/#{i + 1}"})
    end
    check = IsItBroken::Check::Url.new("https://example.com/test/0", allow_redirects: true)
    result = check.run(:url)
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to eq "GET https://example.com/test/0 failed with too many redirects"
  end

  it "won't follow circular redirects" do
    stub_request(:get, "https://example.com/test").to_return(status: 302, headers: {"Location" => "https://example.com/test"})
    check = IsItBroken::Check::Url.new("https://example.com/test", allow_redirects: true)
    result = check.run(:url)
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to eq "GET https://example.com/test failed with cicular redirect"
  end

  it "can use a proxy" do
    stub_request(:get, "https://example.com/test").to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test", proxy: {host: "proxy.exmple.com", port: 80})
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "GET https://example.com/test responded with '200 "
  end

  it "can alias the URL name" do
    stub_request(:get, "https://example.com/test").to_return(status: 200)
    check = IsItBroken::Check::Url.new("https://example.com/test", url_alias: "site")
    result = check.run(:url)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "GET site responded with '200 "
  end
end
