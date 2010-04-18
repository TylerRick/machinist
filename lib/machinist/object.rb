require 'machinist'
require 'machinist/blueprints'

module Machinist
  
  module ObjectExtensions
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end
  
    module ClassMethods
      def make(attributes = {}, &block)
        object = Machinist::Shop.instance.make(self, attributes)
        block_given? ? yield(object) : object
      end
    end
  end
  
end

class Object #:nodoc:
  include Machinist::Blueprints
  include Machinist::ObjectExtensions
end
