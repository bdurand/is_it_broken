# frozen_string_literal: true

require "spec_helper"

describe IsItBroken do
  after(:each) do
    IsItBroken.unregister(:foo)
    IsItBroken.unregister(:bar)
  end

  describe "register" do
    it "should be able to register checks" do
      check = IsItBroken::Check.new do |result|
        result.success!("bar")
      end
      IsItBroken.register(:foo, check: check)
      results = IsItBroken.check(:foo)
      expect(results.size).to eq 1
      expect(results.first.success?).to eq true
      expect(results.first.assertions.collect { |r| [r.status, r.message] }).to eq [[:success, "bar"]]
    end

    it "should be able to register blocks" do
      IsItBroken.register(:foo) { |result| result.success!("moo") }
      results = IsItBroken.check(:foo)
      expect(results.size).to eq 1
      expect(results.first.success?).to eq true
      expect(results.first.assertions.collect { |r| [r.status, r.message] }).to eq [[:success, "moo"]]
    end
  end

  describe "group" do
    it "should be able to register groups of checks" do
      IsItBroken.register(:foo) { |result| result.success!("moo") }
      IsItBroken.register(:bar) { |result| result.success!("boo") }
      IsItBroken.group(:both, [:foo, :bar])
      results = IsItBroken.check(:both)
      expect(results.size).to eq 2
      expect(results[0].assertions.collect { |r| [r.status, r.message] }).to eq [[:success, "moo"]]
      expect(results[1].assertions.collect { |r| [r.status, r.message] }).to eq [[:success, "boo"]]
    end

    it "should not run duplicate checks" do
      IsItBroken.register(:foo) { |result| result.success!("moo") }
      IsItBroken.register(:bar) { |result| result.success!("boo") }
      IsItBroken.group(:both, [:foo, :bar])
      results = IsItBroken.check(:bar, :both, :foo, :both)
      expect(results.size).to eq 2
      expect(results[0].assertions.collect { |r| [r.status, r.message] }).to eq [[:success, "boo"]]
      expect(results[1].assertions.collect { |r| [r.status, r.message] }).to eq [[:success, "moo"]]
    end
  end

  describe "asynchronous" do
    it "should be able to run checks in asynchronously is multiple threads" do
      IsItBroken.register(:foo) { |result| result.success!("~#{Thread.current.object_id}~") }
      IsItBroken.register(:bar) { |result| result.success!("~#{Thread.current.object_id}~") }
      results = IsItBroken.check(:foo, :bar)
      thread_1 = results[0].assertions.collect(&:message).join("\n").match(/~(.+)~/)[1]
      thread_2 = results[1].assertions.collect(&:message).join("\n").match(/~(.+)~/)[1]
      expect(thread_1).to_not eq thread_2
      expect(thread_1).to_not eq Thread.current.object_id.to_s
      expect(thread_2).to_not eq Thread.current.object_id.to_s
    end

    it "should be able to specify synchronous checks that should run in the master thread" do
      IsItBroken.register(:foo, async: false) { |result| result.success!("~#{Thread.current.object_id}~") }
      IsItBroken.register(:bar) { |result| result.success!("~#{Thread.current.object_id}~") }
      results = IsItBroken.check(:foo, :bar)
      thread_1 = results[0].assertions.collect(&:message).join("\n").match(/~(.+)~/)[1]
      thread_2 = results[1].assertions.collect(&:message).join("\n").match(/~(.+)~/)[1]
      expect(thread_1).to_not eq thread_2
      expect(thread_1).to eq Thread.current.object_id.to_s
      expect(thread_2).to_not eq Thread.current.object_id.to_s
    end
  end

  describe "failure" do
    it "should record a failure if any check fails" do
      IsItBroken.register(:foo) do |result|
        result.success!("good")
        result.fail!("bad")
      end
      IsItBroken.register(:bar) { |result| result.success!("woot") }
      results = IsItBroken.check([:foo, :bar])
      expect(results[0].success?).to eq false
      expect(results[1].success?).to eq true
    end
  end

  describe "application_name" do
    it "should be able to set the application name" do
      name = IsItBroken.application_name
      expect(name).to eq "Application"
      begin
        IsItBroken.application_name = "Foo"
        expect(IsItBroken.application_name).to eq "Foo"
      ensure
        IsItBroken.application_name = name
      end
    end
  end
end
