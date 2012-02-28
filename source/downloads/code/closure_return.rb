def implicit_yield
    begin
        puts "before yield"
        yield
        puts "after yield"
    rescue Exception=>e
        puts "failure: #{e.class}: #{e}"
    end
end

x = 2
implicit_yield {
    x += 2
    return x
}

def call_closure(closure)
    begin
        puts "before calling #{closure}..."
        ret = closure.call
        puts "called #{closure} result:#{ret}"
    rescue Exception => e
        puts "during #{closure} failure: #{e.class}: #{e}"
    end
end

def test_method()
    return  "test method"
end

call_closure(Proc.new { return "value for Proc.new"} )
call_closure(proc { return "value from proc"} )


call_closure(lambda { return "value from proc" } )
call_closure(method(:test_method))

