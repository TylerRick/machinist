require 'machinist/warehouse'

module Machinist
  class Shop

    def self.instance
      @instance ||= Shop.new
    end
    
    def initialize
      reset_warehouse
    end
    
    def reset_warehouse
      @warehouse = Warehouse.new
      reset
    end

    def reset
      @back_room = @warehouse.clone
    end

    # TODO: This should work with sqlite too.
    def make(klass, attributes = {})
      adapter = klass.machinist_adapter
      shelf = @back_room[klass, attributes]
      if shelf.empty?
        item = adapter.outside_transaction do
          item = Lathe.make(klass, attributes)
          item.save! if item.respond_to?(:save!) # FIXME: Where should this live?
          item
        end
        @warehouse[klass, attributes] << adapter.serialize(klass, item)
        item
      else
        adapter.instantiate(klass, shelf.shift)
      end
    end

  end
end
