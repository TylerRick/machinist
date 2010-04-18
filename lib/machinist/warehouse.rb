module Machinist
  class Warehouse < Hash #:nodoc:
    def initialize
      super { Array.new }
    end
    
    def clone
      clone = Warehouse.new
      each_pair do |key, value|
        clone[*key] = value.dup
      end
      clone
    end

    def []=(*keys)
      value = keys.pop
      super(keys, value)
    end

    def [](*keys)
      super(keys)
    end
  end
end
