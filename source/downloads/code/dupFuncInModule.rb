module BaseModule1
    def func()
        puts "called in BaseModule1"
    end

    def func1()
        puts "unique func in module1"
    end
end

module BaseModule2
    def func()
        puts "called in BaseModule2"
    end

    def func2()
        puts "unique func in module2"
    end
end

class BaseClass
    def func()
        puts "called in base class"
    end
end


class Child < BaseClass
    include BaseModule1
    include BaseModule2
end

obj = Child.new
obj.func 
obj.func1
obj.func2

