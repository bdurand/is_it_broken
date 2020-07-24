require "spec_helper"

describe IsItBroken::RackHandler do
  after(:each) do
    IsItBroken.unregister(:foo)
    IsItBroken.unregister(:bar)
  end

  it "should respond with the results of the specified checks" do
    handler = IsItBroken::RackHandler.new(:foo, :bar)
    IsItBroken.register(:foo) { |result| result.ok!("check1") }
    IsItBroken.register(:bar) { |result| result.ok!("check2") }
    status, _headers, body = handler.call({})
    expect(status).to eq 200
    expect(body.join("")).to include "check1"
    expect(body.join("")).to include "check2"
  end

  it "should return a 418 error if any check fails" do
    handler = IsItBroken::RackHandler.new(:foo, :bar)
    IsItBroken.register(:foo) { |result| result.ok!("check1") }
    IsItBroken.register(:bar) { |result| result.fail!("check2") }
    status, _headers, body = handler.call({})
    expect(status).to eq 500
    expect(body.join("")).to include "FAIL"
  end

  it "should be able to customize the failure code" do
    handler = IsItBroken::RackHandler.new(:foo, :bar, status: 418)
    IsItBroken.register(:foo) { |result| result.ok!("check1") }
    IsItBroken.register(:bar) { |result| result.fail!("check2") }
    status, _headers, body = handler.call({})
    expect(status).to eq 418
    expect(body.join("")).to include "FAIL"
  end
end
