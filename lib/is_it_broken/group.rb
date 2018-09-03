# frozen_string_literal: true

module IsItBroken
  # Class used for grouping checks by name.
  class Group
    attr_reader :names
  
    def initialize(*names)
      @names = validate_names(names)
    end
  
    private
  
    def validate_names(names)
      check_names = []
      names.flatten.collect(&:to_s).each do |name|
        next if check_names.include?(name)
        check, async = IsItBroken.fetch(name)
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
