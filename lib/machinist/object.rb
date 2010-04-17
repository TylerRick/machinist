require 'machinist'
require 'machinist/blueprints'

module Machinist
  
  module ObjectExtensions
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    module ClassMethods
      def make(*args, &block)
        lathe = Lathe.run(self.new, *args)
        lathe.object(&block)
      end
    end
  end
  
end

class Object
  include Machinist::Blueprints
  include Machinist::ObjectExtensions
end
