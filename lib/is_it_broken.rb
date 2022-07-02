# frozen_string_literal: true

require "erb"
require "json"
require "rack"
require "time"

module IsItBroken
  require_relative "is_it_broken/check"
  require_relative "is_it_broken/check/file"
  require_relative "is_it_broken/check/ping"
  require_relative "is_it_broken/check/url"
  require_relative "is_it_broken/check_runner"
  require_relative "is_it_broken/configuration"
  require_relative "is_it_broken/group"
  require_relative "is_it_broken/message"
  require_relative "is_it_broken/rack_handler"
  require_relative "is_it_broken/result"

  @configuration ||= Configuration.new

  class << self
    def register(name, check: nil, async: true, &block)
      @configuration.add(name, check: check, async: async, &block)
    end

    def unregister(name)
      @configuration.delete(name)
    end

    def clear
      @configuration.clear
    end

    def group(name, check_names)
      @configuration.group(name, check_names)
    end

    def check(*names)
      CheckRunner.new(@configuration, names).run
    end

    def application_name
      @application_name ||= "Application"
    end

    def application_name=(value)
      @application_name = value.to_s.dup.freeze
    end
  end
end
