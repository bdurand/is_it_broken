# frozen_string_literal: true

require 'time'
require 'thread'

module IsItBroken

  require_relative 'is_it_broken/check'
  require_relative 'is_it_broken/check/file'
  require_relative 'is_it_broken/check/ping'
  require_relative 'is_it_broken/check/url'
  require_relative 'is_it_broken/check_runner'
  require_relative 'is_it_broken/group'
  require_relative 'is_it_broken/message'
  require_relative 'is_it_broken/rack_handler'
  require_relative 'is_it_broken/result'

  @@checks = {}
  @@lock = Mutex.new

  class << self
    def register(name, check: nil, async: true, &block)
      check = Check.new(async: async, &block) if check.nil? && block
      unless check
        raise ArgumentError.new("Either a check or a block must be specified")
      end
      @@lock.synchronize do
        @@checks[name.to_s] = [check, async]
      end
    end

    def unregister(name)
      @@lock.synchronize do
        @@checks.delete(name.to_s)
      end
    end

    def group(name, check_names)
      @@lock.synchronize do
        @@checks[name.to_s] = [Group.new(check_names), true]
      end
    end

    def check(*names)
      CheckRunner.new(names).run
    end
    
    def fetch(name) #:nodoc:
      @@checks[name.to_s]
    end
  end
end
