module TestModule
    def foo
        puts "foo"
    end
end

class NewClsIncludeModule
    include TestModule
end

class NewClsExtendModule
    extend TestModule
end

begin
    NewClsIncludeModule.foo
    NewClsIncludeModule.new.foo
rescue Exception => e
    puts e
end

begin
    NewClsExtendModule.foo
    NewClsExtendModule.new.foo
rescue Exception => e
    puts e
end
