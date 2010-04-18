require 'machinist/blueprints'
require 'active_record'

module Machinist
  module Adapters
    module ActiveRecord
      
      def self.serialize(klass, object)
        object.id
      end
      
      def self.instantiate(klass, object)
        klass.find(object)
      end
      
      def self.outside_transaction
        thread = Thread.new do
          begin
            yield
          ensure
            ::ActiveRecord::Base.connection_pool.checkin(::ActiveRecord::Base.connection)
          end
        end
        thread.value
      end
      
    end
  end
end

class ActiveRecord::Base #:nodoc:
  include Machinist::Blueprints
  
  def self.machinist_adapter
    Machinist::Adapters::ActiveRecord
  end
  
  def self.make(attributes = {}, &block)
    object = Machinist::Shop.instance.make(self, attributes)
    block_given? ? yield(object) : object
  end
end
