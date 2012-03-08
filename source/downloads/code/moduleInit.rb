module BaseModule
    def initialize(value)
        @value = value
    end

    def func()
        puts "called with value = #{@value}"
    end
end

class Test1
    include BaseModule
    def initialize(value)
        super(value)
    end
end

class Test2
    include BaseModule
    def show()
        puts "my value is: #{@value}"
    end
end

class Test3
    include BaseModule
    def initialize(value)
        @myvalue = value
    end
    def show()
        puts "called with myvalue = #{@myvalue}"
    end
end

obj1 = Test1.new("test1")
obj1.func()
obj2 = Test2.new("test2")
obj2.func()
obj2.show()
obj3 = Test3.new("test3")
obj3.func()
obj3.show()
