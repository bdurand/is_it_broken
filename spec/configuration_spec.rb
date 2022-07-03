# frozen_string_literal: true

require "spec_helper"

describe IsItBroken::Configuration do
  let(:config) { IsItBroken::Configuration.new }

  it "should add a check with an object" do
    check_1 = IsItBroken::Check.new
    check_2 = IsItBroken::Check.new
    config.add(:test_1, check: check_1)
    config.add(:test_2, check: check_2, async: false)
    expect(config.fetch(:test_1)).to eq [check_1, true]
    expect(config.fetch(:test_2)).to eq [check_2, false]
  end

  it "should add a check with a block" do
    config.add(:test_1) { |result| 1 }
    config.add(:test_2, async: false) { |result| 2 }

    check_1, async_1 = config.fetch(:test_1)
    expect(async_1).to eq true
    expect(check_1.async?).to eq true
    expect(check_1.call(IsItBroken::Result.new(:test))).to eq 1

    check_2, async_2 = config.fetch(:test_2)
    expect(async_2).to eq false
    expect(check_2.async?).to eq false
    expect(check_2.call(IsItBroken::Result.new(:test))).to eq 2
  end

  it "should group checks" do
    config.add(:test_1, check: IsItBroken::Check.new)
    config.add(:test_2, check: IsItBroken::Check.new)
    config.add(:test_3, check: IsItBroken::Check.new)
    config.group(:test_4, [:test_1, :test_2])
    group, async = config.fetch(:test_4)
    expect(async).to eq true
    expect(group.names).to eq ["test_1", "test_2"]
  end

  it "should delete checks" do
    check_1 = IsItBroken::Check.new
    check_2 = IsItBroken::Check.new
    config.add(:test_1, check: check_1)
    config.add(:test_2, check: check_2)
    config.delete(:test_1)
    expect(config.fetch(:test_1)).to eq nil
    expect(config.fetch(:test_2)).to eq [check_2, true]
  end
end
