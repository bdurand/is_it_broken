# frozen_string_literal: true

require "spec_helper"

describe IsItBroken::RackHandler do
  after(:each) do
    IsItBroken.unregister(:foo)
    IsItBroken.unregister(:bar)
  end

  it "should respond with the results of the specified checks" do
    handler = IsItBroken::RackHandler.new(:foo, :bar)
    IsItBroken.register(:foo) { |result| result.success!("check1") }
    IsItBroken.register(:bar) { |result| result.success!("check2") }
    status, _headers, body = handler.call({})
    expect(status).to eq 200
    expect(body.join("")).to include "check1"
    expect(body.join("")).to include "check2"
  end

  it "should return a 500 error if any check fails" do
    handler = IsItBroken::RackHandler.new(:foo, :bar)
    IsItBroken.register(:foo) { |result| result.success!("check1") }
    IsItBroken.register(:bar) { |result| result.fail!("check2") }
    status, _headers, body = handler.call({})
    expect(status).to eq 500
    expect(body.join("")).to include "FAILURE"
  end

  it "should be able to customize the failure code" do
    handler = IsItBroken::RackHandler.new(:foo, :bar, failure_status: 418)
    IsItBroken.register(:foo) { |result| result.success!("check1") }
    IsItBroken.register(:bar) { |result| result.fail!("check2") }
    status, _headers, body = handler.call({})
    expect(status).to eq 418
    expect(body.join("")).to include "FAILURE"
  end

  it "should render text output if the request path ends with .txt" do
    handler = IsItBroken::RackHandler.new(:foo)
    IsItBroken.register(:foo) { |result| result.success!("check1") }
    status, headers, body = handler.call({"PATH_INFO" => "is_it_broken.txt"})
    expect(status).to eq 200
    expect(body.join("")).to include "check1"
    expect(headers["Content-Type"]).to eq "text/plain; charset=utf8"
  end

  it "should render text output if the request accepts plain text" do
    handler = IsItBroken::RackHandler.new(:foo)
    IsItBroken.register(:foo) { |result| result.success!("check1") }
    status, headers, body = handler.call({"HTTP_ACCEPT" => "text/plain"})
    expect(status).to eq 200
    expect(headers["Content-Type"]).to eq "text/plain; charset=utf8"
    expect(body.join("")).to include "check1"
  end

  it "should render json output if the request path ends with .json" do
    handler = IsItBroken::RackHandler.new(:foo)
    IsItBroken.register(:foo) { |result| result.success!("check1") }
    status, headers, body = handler.call({"PATH_INFO" => "is_it_broken.json"})
    expect(status).to eq 200
    expect(headers["Content-Type"]).to eq "application/json; charset=utf8"
    payload = JSON.parse(body.join(""))
    expect(payload["results"].first["name"]).to eq "foo"
    expect(payload["results"].first["messages"].first["status"]).to include "success"
    expect(payload["results"].first["messages"].first["text"]).to include "check1"
  end

  it "should render json output if the request accepts JSON" do
    handler = IsItBroken::RackHandler.new(:foo)
    IsItBroken.register(:foo) { |result| result.success!("check1") }
    status, headers, body = handler.call({"HTTP_ACCEPT" => "application/json"})
    expect(status).to eq 200
    expect(headers["Content-Type"]).to eq "application/json; charset=utf8"
    payload = JSON.parse(body.join(""))
    expect(payload["results"].first["name"]).to eq "foo"
    expect(payload["results"].first["messages"].first["status"]).to include "success"
    expect(payload["results"].first["messages"].first["text"]).to include "check1"
  end

  it "should render html output if the request path ends with .html" do
    handler = IsItBroken::RackHandler.new(:foo)
    IsItBroken.register(:foo) { |result| result.success!("check1") }
    status, headers, body = handler.call({"PATH_INFO" => "is_it_broken.html"})
    expect(status).to eq 200
    expect(body.join("")).to include "check1"
    expect(headers["Content-Type"]).to eq "text/html; charset=utf8"
  end

  it "should render html output if the request accepts HTML" do
    handler = IsItBroken::RackHandler.new(:foo)
    IsItBroken.register(:foo) { |result| result.success!("check1") }
    status, headers, body = handler.call({"HTTP_ACCEPT" => "text/html"})
    expect(status).to eq 200
    expect(body.join("")).to include "check1"
    expect(headers["Content-Type"]).to eq "text/html; charset=utf8"
  end
end
