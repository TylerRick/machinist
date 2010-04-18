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

    def make(klass, attributes = {})
      shelf = @back_room[klass, attributes]
      if shelf.empty?
        item = on_other_connection { Lathe.make(klass, attributes) }
        @warehouse[klass, attributes] << serialize(klass, item)
        item
      else
        instantiate(klass, shelf.shift)
      end
    end

    def serialize(klass, item)
      # item.id 
      item
    end

    def instantiate(klass, item)
      # klass.find(item)
      item.dup
    end

    def on_other_connection(&block)
      Thread.new(&block).value
    end

  end
end