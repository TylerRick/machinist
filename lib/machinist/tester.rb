module Machinist
  module Tester
    
    def self.tester_class
      @tester_class ||= Simple
    end
    
    def self.tester_class=(klass)
      @tester_class = klass
      reset
    end

    def self.reset
      @tester = tester_class.new
    end

    def self.current
      @tester ||= tester_class.new
    end
    
    class Simple
      def make(klass, attributes = {})
        Lathe.make(klass, attributes)
      end
    end
    
  end
end
