module BaseModule
    def self.included(base)
        base.extend(ClassMethods)
    end

    module ClassMethods
        def bar
            puts "class methods"
        end
    end

    def foo
        puts "instance methods"
    end
end

class Test
    include BaseModule
end

# call class method
Test.bar 

# call instance method
Test.new.foo

# invalid calls for no method defined
begin
    Test.foo
    Test.new.bar
rescue Exception => e
    puts e
end

