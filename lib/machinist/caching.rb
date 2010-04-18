module Machinist
  
  # TODO: Document caching.
  module Caching
    
    def self.object_cache
      @object_cache ||= {}
    end
    
    def self.clear_object_cache
      @object_cache = {}
    end
    
    class Tester
      def initialize
        @retrieval_state = {}
      end
    
      def make(klass, attributes = {})
        index          = (@retrieval_state[[klass, attributes]] ||= 0)
        cached_objects = (Machinist::Caching.object_cache[[klass, attributes]] ||= [])
        
        if index < cached_objects.length
          object = cached_objects[index]
        else
          object = Lathe.make(klass, attributes)
          cached_objects << object
        end
      
        @retrieval_state[[klass, attributes]] = index + 1
        
        object.dup
      end
    end
    
  end
end
