# frozen_string_literal: true

require "spec_helper"

describe IsItBroken::CheckRunner do
  it "should run a list of checks" do
    config = IsItBroken::Configuration.new
    config.add(:test_1, check: IsItBroken::Check.new { |r| r.success!("Test 1 OK") })
    config.add(:test_2, check: IsItBroken::Check.new { |r| r.success!("Test 2 OK") })
    config.add(:test_3, check: IsItBroken::Check.new { |r| r.success!("Test 3 OK") })
    config.add(:test_4, check: IsItBroken::Check.new { |r| r.success!("Test 4 OK") })
    config.group(:grouping, [:test_1, :test_2])
    runner = IsItBroken::CheckRunner.new(config, [:test_3, :grouping, :test_1])

    results = runner.run

    expect(results.size).to eq 3
    expect(results[0].assertions.first.message).to eq "Test 3 OK"
    expect(results[1].assertions.first.message).to eq "Test 1 OK"
    expect(results[2].assertions.first.message).to eq "Test 2 OK"
  end
end
