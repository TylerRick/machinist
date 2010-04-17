module Machinist
    
  class ObjectCache
    def initialize
      @cache = {}
    end
    
    def [](klass, attributes)
      objects_for_class = (@cache[klass.name] ||= {})
      objects_for_class[attributes] ||= []
    end
  end
  
  class CacheRetrievalState
    def initialize
      @state = {}
    end
    
    def [](klass, attributes)
      states_for_class(klass)[attributes] ||= 0
    end
    
    def []=(klass, attributes, index)
      states_for_class(klass)[attributes] = index
    end
    
  private
  
    def states_for_class(klass)
      @state[klass.name] ||= {}
    end
  end
  
end
