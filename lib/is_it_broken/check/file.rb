# frozen_string_literal: true

module IsItBroken
  # Check if a file system file exists and has the correct access. This
  # can be very useful to check if the application relies on access to a specific file, directory, or socket.
  #
  # Any symlinks in the path will be expanded.
  #
  # The optional permission argument can be one of :read, :write, or an array with both to
  # check that the application user has the appropriate permission.
  #
  # The optional type argument can be one of :file, :directory, :socket, :pipe, :blockdev, or :chardev
  # to check that the path is of the proper underlying file system type.
  class Check::File < Check
    def initialize(path, permission: nil, type: nil)
      raise ArgumentError.new("path not specified") unless options[:path]
      @path = File.expand_path(options[:path])
      @permission = Array(permission)
      @type = type.to_s if type
    end

    def call(result)
      stat = File.stat(@path) if File.exist?(@path)
      if stat
        if correct_type?(stat)
          if @permission
            if @permission.include?(:read) && !stat.readable?
              result.fail!("#{@path} is not readable by #{ENV["USER"]}")
            elsif @permission.include?(:write) && !stat.writable?
              result.fail!("#{@path} is not writable by #{ENV["USER"]}")
            else
              result.ok!("#{@path} exists with #{@permission.collect { |a| a.to_s }.join("/")} permission")
            end
          else
            result.ok!("#{@path} exists")
          end
        else
          result.fail!("#{@path} is not a #{@type}")
        end
      else
        result.fail!("#{@path} does not exist")
      end
    end

    private

    def correct_type?(stat)
      case @type
      when nil
        true
      when "file"
        stat.file?
      when "directory"
        stat.directory?
      when "socket"
        stat.socket?
      when "pipe"
        stat.pipe?
      when "blockdev"
        stat.blockdev?
      when "chardev"
        stat.chardev?
      else
        false
      end
    end
  end
end
