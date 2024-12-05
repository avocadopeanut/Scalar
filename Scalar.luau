--[[

    avocado (@avodey) -w-

    A library to dynamically adjust numbers.

    12/4/24

]]

local Super = {}
local Scalar = {}

--\\ Types
--[[
export type Scalar = {
    [string]: Scope<any>,

    _Base: number,
    _Scopes: {{string, Scope<any>}}
} & typeof(Scalar)

type Scope<T> = {
    [any]: T
} & (number, T) -> number
]]
--\\ Private Methods

local function isScope(item)--: boolean
    if type(item) == "table" then
        local meta = getmetatable(item)
        return meta and meta.__type == "Scope"
    end

    return false
end

--\\ Public Methods

function Super.new(base)--: Scalar
    return setmetatable({
        _Base = base or 0,
        _Scopes = {},
    }, Scalar)
end

function Super:Scope(callback, order)
    assert(type(callback) == "function", "Argument #1 must be a callback.")
    return setmetatable({}, {
        __call = function(_, ...)
            return callback(...)
        end,
        __type = "Scope",
        __order = type(order) == "number" and order or nil,
    })
end

--\\ Instance Methods

function Scalar.Get(self, base)--: number
    local result = base or self._Base

    print("BASE:", result)
    for _, data in pairs(self._Scopes) do
        local scope = data[2]
        for _, parameter in pairs(scope) do
            print(_, parameter)
            result = scope(result, parameter)
        end
    end

    return result
end

function Scalar.GetBase(self)--: number
    return self._Base or 0
end

function Scalar.Extend(self) -- TODO

end

--\\ Instance Metamethods

function Scalar.__index(self, i)
    local value = rawget(Scalar, i)
    if value ~= nil then return value end

    for _, data in pairs(self._Scopes) do
        if data[1] == i then
            return data[2]
        end
    end

    return nil
end

function Scalar.__newindex(self, i, v)
    assert(rawget(Scalar, i) == nil, tostring(i) .. " is read only.")
    assert(isScope(v), "Only new scopes may be assigned.")

    local order = getmetatable(v).__order

    if order then
        table.insert(self._Scopes, order, {i, v})
    else
        table.insert(self._Scopes, {i, v})
    end
end

return Scalar