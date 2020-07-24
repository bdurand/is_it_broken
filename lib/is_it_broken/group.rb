# frozen_string_literal: true

module IsItBroken
  # Class used for grouping checks by name.
  class Group
    attr_reader :names

    def initialize(config, names)
      @names = validate_names(config, names)
    end

    private

    def validate_names(config, names)
      check_names = []
      names.flatten.collect(&:to_s).each do |name|
        next if check_names.include?(name)
        check, _async = config.fetch(name)
        if check.nil?
          raise ArgumentError.new("Check not registered: #{name.inspect}")
        elsif check.is_a?(Group)
          check_names.concat(check.names)
        else
          check_names << name
        end
      end
      check_names.uniq
    end
  end
end
