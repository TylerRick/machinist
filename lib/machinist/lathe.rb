require 'blankslate'

module Machinist

  # A Lathe is used to execute the blueprint and construct an object.
  #
  # The blueprint is instance_eval'd against the Lathe.
  class Lathe
    def self.make(klass, attributes = {})
      run(klass.new, attributes).object
    end
    
    def self.run(object, attributes = {})
      raise "No blueprint for class #{object.class}" if object.class.blueprint.nil?
      
      lathe = self.new(object, attributes)
      klass = object.class
      while klass
        lathe.instance_eval(&klass.blueprint) if klass.respond_to?(:blueprint) && klass.blueprint
        klass = klass.superclass
      end
      lathe
    end
    
    def initialize(object, attributes = {})
      @object  = object
      attributes.each {|key, value| assign_attribute(key, value) }
    end

    def object
      yield @object if block_given?
      @object
    end
    
    def method_missing(symbol, *args)
      if attribute_assigned?(symbol)
        @object.send(symbol)
      elsif block_given?
        assign_attribute(symbol, yield)
      else
        raise "Attribute not assigned."
      end
    end

  private
    
    def assigned_attributes
      @assigned_attributes ||= {}
    end
    
    def assign_attribute(key, value)
      assigned_attributes[key.to_sym] = value
      @object.send("#{key}=", value)
    end
  
    def attribute_assigned?(key)
      assigned_attributes.has_key?(key.to_sym)
    end
    
  end
end
