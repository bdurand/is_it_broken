# frozen_string_literal: true

require "spec_helper"

describe IsItBroken::Check do
  it "should run a check" do
    check = IsItBroken::Check.new { |result| result.success!("OK") }
    result = check.run(:test)
    expect(result.name).to eq "test"
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to eq "OK"
  end

  it "should capture any errors as a failure" do
    check = IsItBroken::Check.new { |result| raise "failed badly" }
    result = check.run(:test)
    expect(result.name).to eq "test"
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to include "failed badly"
  end
end
