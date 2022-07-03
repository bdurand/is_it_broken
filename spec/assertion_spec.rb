# frozen_string_literal: true

require "spec_helper"

describe IsItBroken::Assertion do
  it "should be determine if the assertion is a success" do
    assertion = IsItBroken::Assertion.new(:success, "test")
    expect(assertion.success?).to eq true
    expect(assertion.warning?).to eq false
    expect(assertion.failure?).to eq false
  end

  it "should be determine if the assertion is a warning" do
    assertion = IsItBroken::Assertion.new(:warning, "test")
    expect(assertion.success?).to eq false
    expect(assertion.warning?).to eq true
    expect(assertion.failure?).to eq false
  end

  it "should be determine if the assertion is a failure" do
    assertion = IsItBroken::Assertion.new(:failure, "test")
    expect(assertion.success?).to eq false
    expect(assertion.warning?).to eq false
    expect(assertion.failure?).to eq true
  end
end
