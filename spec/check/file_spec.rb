# frozen_string_literal: true

require "spec_helper"

require "tempfile"

describe IsItBroken::Check::File do
  it "can check if a file exists" do
    check = IsItBroken::Check::File.new(__FILE__)
    result = check.run(:file)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to eq "#{File.expand_path(__FILE__)} exists"

    check = IsItBroken::Check::File.new("/no/such/file")
    result = check.run(:file)
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to eq "/no/such/file does not exist"
  end

  it "can check if a file is readable by the current user" do
    file = File.join(Dir.tmpdir, "is_it_broken_#{rand(2_000_000_000)}")
    File.write(file, "foo")
    begin
      check = IsItBroken::Check::File.new(file, permission: :read)
      result = check.run(:file)
      expect(result.assertions.first.success?).to eq true
      expect(result.assertions.first.message).to include "exists with read permission"

      File.chmod(0o000, file)
      result = check.run(:file)
      expect(result.assertions.first.failure?).to eq true
      expect(result.assertions.first.message).to include "is not readable by"
    ensure
      File.unlink(file)
    end
  end

  it "can check if a file is writable by the current user" do
    file = File.join(Dir.tmpdir, "is_it_broken_#{rand(2_000_000_000)}")
    File.write(file, "foo")
    begin
      check = IsItBroken::Check::File.new(file, permission: :write)
      result = check.run(:file)
      expect(result.assertions.first.success?).to eq true
      expect(result.assertions.first.message).to include "exists with write permission"

      File.chmod(0o000, file)
      result = check.run(:file)
      expect(result.assertions.first.failure?).to eq true
      expect(result.assertions.first.message).to include "is not writable by"
    ensure
      File.unlink(file)
    end
  end

  it "can check if a file is readable and writable by the current user" do
    file = File.join(Dir.tmpdir, "is_it_broken_#{rand(2_000_000_000)}")
    File.write(file, "foo")
    begin
      check = IsItBroken::Check::File.new(file, permission: [:read, :write])
      result = check.run(:file)
      expect(result.assertions.first.success?).to eq true
      expect(result.assertions.first.message).to include "exists with read/write permission"

      File.chmod(0o100, file)
      result = check.run(:file)
      expect(result.assertions.first.failure?).to eq true
      expect(result.assertions.first.message).to include "is not readable by"

      File.chmod(0o400, file)
      result = check.run(:file)
      expect(result.assertions.first.failure?).to eq true
      expect(result.assertions.first.message).to include "is not writable by"
    ensure
      File.unlink(file)
    end
  end

  it "can check if a file is a plain file" do
    check = IsItBroken::Check::File.new(__FILE__, type: :file)
    result = check.run(:file)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "exists"

    check = IsItBroken::Check::File.new(__dir__, type: :file)
    result = check.run(:file)
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to include "is not a file"
  end

  it "can check if a file is a directory" do
    check = IsItBroken::Check::File.new(__dir__, type: :directory)
    result = check.run(:file)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to include "exists"

    check = IsItBroken::Check::File.new(__FILE__, type: :directory)
    result = check.run(:file)
    expect(result.assertions.first.failure?).to eq true
    expect(result.assertions.first.message).to include "is not a directory"
  end

  it "can alias the file path" do
    check = IsItBroken::Check::File.new(__FILE__, file_alias: "current file")
    result = check.run(:file)
    expect(result.assertions.first.success?).to eq true
    expect(result.assertions.first.message).to eq "current file exists"
  end
end
