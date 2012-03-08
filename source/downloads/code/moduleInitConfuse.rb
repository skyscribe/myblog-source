module BaseModule
    def initialize(value)
        @value = value
    end

    def func()
        puts "called with value = #{@value}"
    end
end

class BaseClass
    def initialize(value)
        @baseValue = value
    end
    
    def show()
        puts "my basevalue=#{@baseValue}"
    end
end

class Test < BaseClass
    include BaseModule
    def initialize(value)
        super(value)
    end
end

obj = Test.new("test1")
obj.func
obj.show
