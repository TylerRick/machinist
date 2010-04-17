module Machinist
  # Include this in a class to allow defining blueprints for that class.
  module Blueprints
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def blueprint(&blueprint)
        @blueprint = blueprint if block_given?
        @blueprint
      end
    
      def clear_blueprints!
        @blueprint = nil
      end
    end
    
  end
end
