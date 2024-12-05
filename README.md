# Scalar
Roblox library to dynamically adjust numbers.

# Example Usage
```lua
local attackSpeed = Scalar.Default:Extend(1)
attackSpeed.Scale.SpeedPotion = 2
print(attackSpeed.Value) --> 2
attackSpeed.Scale.Drowsiness = 0.25
print(attackSpeed.Value) --> 0.5
attackSpeed.Add.Hype = 1
print(attackSpeed.Value) --> 1.5
```
```lua
local energy = Scalar.new()

energy.Scale = energy:NextScope(function(x, a)
    return x * a
end)

energy.Add = energy:NextScope(function(x, b)
    return x + b
end)

energy.Disabled = energy:NextScope(100, function(x, disable)
    return disable and 0 or x
end)

energy.Scale.Upgrade = 2
print(energy:Get(5)) --> 10
print(energy.Value) --> 0 (Default Base = 0)
energy.Disabled.Dizzy = true
print(energy:Get(5)) --> 0

return Super
```