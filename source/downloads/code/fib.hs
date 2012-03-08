-- lazy evaluation implementation for fibonacci series
fib :: Integer -> Integer -> [Integer]
fib 0 _ = []
fib m n = m : (fib n (m+n))

getIt :: [Integer] -> Integer -> Integer
getIt [] _ = 0
getIt (x:xs) 1 = x
getIt (x:xs) n = getIt xs (n-1)

-- below calculation will end once it's computed though fib function never terminate for large m/n
fetch :: Integer -> Integer -> Integer -> Integer
fetch x y z = getIt (fib x y) z

main = print ( fetch 1 1 10000 )
