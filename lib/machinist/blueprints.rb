module Machinist
  # TODO: Blueprint docs.
  module Blueprints
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      # TODO: docs.
      def blueprint(&blueprint)
        @blueprint = blueprint if block_given?
        @blueprint
      end

      # TODO: docs.    
      def clear_blueprints!
        @blueprint = nil
      end
    end
    
  end
end
