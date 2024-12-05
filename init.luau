local Scalar = require("./Scalar")

local example = Scalar.new(1)

example.Add = Super:Scope(function(x, a)
    return x + a
end)

example.Scale = Super:Scope(function(x, a)
    return x * a
end)

example.Add.Test = 3 --> 4
example.Scale.Test2 = 0.5

print(example:Get()) --> 2
print(example:Get(-1)) --> 1