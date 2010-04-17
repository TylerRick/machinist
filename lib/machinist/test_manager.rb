require 'machinist/object_cache'

module Machinist

  class TestManager
    def initialize(object_cache)
      @object_cache = object_cache
      @cache_retrieval_state = CacheRetrievalState.new
    end
    
    def make(klass, attributes = {})
      index = @cache_retrieval_state[klass, attributes]
      cached_objects = @object_cache[klass, attributes]
      
      if index < cached_objects.length
        object = cached_objects[index]
      else
        object = Machinist::Lathe.make(klass, attributes)
        cached_objects << object
      end
      
      @cache_retrieval_state[klass, attributes] = index + 1
        
      object.dup
    end
  end
  
end
