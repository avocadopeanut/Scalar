local Scalar = require("./src/Scalar")
local Scope = require("./src/Scope")

local example = Scalar.new(2)

example.Add = Scope (function(x, a)
    return x + a
end)

example.Scale = Scope (function(x, a)
    return x * a
end)

example.Exponent = Scope (function(x, a)
    return x ^ a
end)

example.Exponent.A = 2
example.Exponent.B = 3

print(example:Get()) --> 64

example.Exponent.A = 3
example.Exponent.B = 2

print(example:Get()) --> 64