require "spec_helper"

describe IsItBroken do
  after(:each) do
    IsItBroken.unregister(:foo)
    IsItBroken.unregister(:bar)
  end

  describe "register" do
    it "should be able to register checks" do
      check = IsItBroken::Check.new do |result|
        result.ok!("bar")
      end
      IsItBroken.register(:foo, check: check)
      results = IsItBroken.check(:foo)
      expect(results.size).to eq 1
      expect(results.first.success?).to eq true
      expect(results.first.to_s).to match(/\AOK:   foo - bar/)
    end

    it "should be able to register blocks" do
      IsItBroken.register(:foo) { |result| result.ok!("moo") }
      results = IsItBroken.check(:foo)
      expect(results.size).to eq 1
      expect(results.first.success?).to eq true
      expect(results.first.to_s).to match(/\AOK:   foo - moo/)
    end
  end

  describe "group" do
    it "should be able to register groups of checks" do
      IsItBroken.register(:foo) { |result| result.ok!("moo") }
      IsItBroken.register(:bar) { |result| result.ok!("boo") }
      IsItBroken.group(:both, [:foo, :bar])
      results = IsItBroken.check(:both)
      expect(results.size).to eq 2
      expect(results.first.to_s).to match(/\AOK:   foo - moo/)
      expect(results.last.to_s).to match(/\AOK:   bar - boo/)
    end

    it "should not run duplicate checks" do
      IsItBroken.register(:foo) { |result| result.ok!("moo") }
      IsItBroken.register(:bar) { |result| result.ok!("boo") }
      IsItBroken.group(:both, [:foo, :bar])
      results = IsItBroken.check(:bar, :both, :foo, :both)
      expect(results.size).to eq 2
      expect(results.first.to_s).to match(/\AOK:   bar - boo/)
      expect(results.last.to_s).to match(/\AOK:   foo - moo/)
    end
  end

  describe "asynchronous" do
    it "should be able to run checks in asynchronously is multiple threads" do
      IsItBroken.register(:foo) { |result| result.ok!("~#{Thread.current.object_id}~") }
      IsItBroken.register(:bar) { |result| result.ok!("~#{Thread.current.object_id}~") }
      results = IsItBroken.check(:foo, :bar)
      thread_1 = results[0].to_s.match(/~(.+)~/)[1]
      thread_2 = results[1].to_s.match(/~(.+)~/)[1]
      expect(thread_1).to_not eq thread_2
      expect(thread_1).to_not eq Thread.current.object_id.to_s
      expect(thread_2).to_not eq Thread.current.object_id.to_s
    end

    it "should be able to specify synchronous checks that should run in the master thread" do
      IsItBroken.register(:foo, async: false) { |result| result.ok!("~#{Thread.current.object_id}~") }
      IsItBroken.register(:bar) { |result| result.ok!("~#{Thread.current.object_id}~") }
      results = IsItBroken.check(:foo, :bar)
      thread_1 = results[0].to_s.match(/~(.+)~/)[1]
      thread_2 = results[1].to_s.match(/~(.+)~/)[1]
      expect(thread_1).to_not eq thread_2
      expect(thread_1).to eq Thread.current.object_id.to_s
      expect(thread_2).to_not eq Thread.current.object_id.to_s
    end
  end

  describe "failure" do
    it "should record a failure if any check fails" do
      IsItBroken.register(:foo) do |result|
        result.ok!("good")
        result.fail!("bad")
      end
      IsItBroken.register(:bar) { |result| result.ok!("woot") }
      results = IsItBroken.check([:foo, :bar])
      expect(results[0].success?).to eq false
      expect(results[1].success?).to eq true
    end
  end
end
