class LazyEnumerable
    include Enumerable

    def initialize(tree)
        @tree = tree
    end

    def each
        while @tree
            car, cdr = @tree.call
            yield car
            @tree = cdr
        end
    end
end

def fib(a, b)
    lambda {[a, fib(b, a+b)]}
end

def fetch(a, b, num)
    cnt =0 
    ret = 0
    LazyEnumerable.new(fib(a, b)).each do |x|
        cnt = cnt + 1
        ret = x
        #puts "cnt=#{cnt}, num=#{num}, cur = #{x}"
        break if cnt == num
    end
    return ret
end

puts fetch(1,1,10000)

