# frozen_string_literal: true

require "spec_helper"

describe IsItBroken::Result do
  let(:result) { IsItBroken::Result.new(:test) }

  it "should be able to add success assertions" do
    result.success!("msg")
    assertion = result.assertions.first
    expect(assertion.success?).to eq true
    expect(assertion.message).to eq "msg"
  end

  it "should be able to add warning assertions" do
    result.warn!("msg")
    assertion = result.assertions.first
    expect(assertion.warning?).to eq true
    expect(assertion.message).to eq "msg"
  end

  it "should be able to add failure assertions" do
    result.fail!("msg")
    assertion = result.assertions.first
    expect(assertion.failure?).to eq true
    expect(assertion.message).to eq "msg"
  end

  it "should be determine if the assertion is a success" do
    result.success!("msg")
    expect(result.success?).to eq true
    result.warn!("msg")
    expect(result.success?).to eq false
    result.fail!("msg")
    expect(result.success?).to eq false
  end

  it "should be determine if the assertion is a warning" do
    result.success!("msg")
    expect(result.warning?).to eq false
    result.warn!("msg")
    expect(result.warning?).to eq true
    result.fail!("msg")
    expect(result.warning?).to eq false
  end

  it "should be determine if the assertion is a failure" do
    result.success!("msg")
    expect(result.failure?).to eq false
    result.warn!("msg")
    expect(result.failure?).to eq false
    result.fail!("msg")
    expect(result.failure?).to eq true
  end

  it "should have status derived from the assertions" do
    result.success!("msg")
    expect(result.status).to eq :success
    result.warn!("msg")
    expect(result.status).to eq :warning
    result.fail!("msg")
    expect(result.status).to eq :failure
    result.success!("msg")
    expect(result.status).to eq :failure
  end
end
