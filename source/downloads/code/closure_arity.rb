def call_with_less_args(closure)
    begin
        puts "arity = #{closure.arity}"
        closure.call(1)
        puts "less args for #{closure} also work"
    rescue Exception => e
        puts "too few args for #{closure} throw #{e.class}: #{e}"
    end
end

def call_with_more_args(closure)
    begin
        puts "arity = #{closure.arity}"
        closure.call(1,2,3,4,54,56,67)
        puts "more args also work for #{closure}"
    rescue Exception => e
        puts "too many args for #{closure} throw #{e.class}: #{e}"
    end
end

def test_method(x,y)
    puts x,y
end

call_with_less_args(Proc.new {|x,y|})
call_with_less_args(proc {|x,y|})
call_with_less_args(lambda {|x,y|})
call_with_less_args(method(:test_method))

call_with_more_args(Proc.new {|x,y|})
call_with_more_args(proc {|x,y|})
call_with_more_args(lambda {|x,y|})
call_with_more_args(method(:test_method))

