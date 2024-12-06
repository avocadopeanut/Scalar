--[[

    avocado (@avodey) -w-

    A library to dynamically adjust numbers.

    12/4/24

]]

local Super = {}
local Scalar = {}

local Scope = require("./Scope")

Super.Scope = Scope

--\\ Types

export type Scalar = {
    [string]: Scope.Scope<any>,

    _Base: number,
    _Container: {{string|Scope.Scope<any>}}
} & typeof(Scalar)

--\\ Private Methods

local function isScope(item): boolean
    if type(item) == "table" then
        local meta = getmetatable(item)
        return meta and meta.__type == "Scope"
    end

    return false
end

--\\ Public Methods

function Super.new(base): Scalar
    return setmetatable({
        _Base = base or 0,
        _Container = {},
    } :: Scalar, Scalar)
end

--\\ Instance Methods

function Scalar.Get(self, base: number?): number
    local result = base or self._Base

    for _, data in self._Container do
        local scope = data[2]
        for _, parameter in scope do
            result = scope(result, parameter)
        end
    end

    return result
end

function Scalar.GetBase(self): number
    return self._Base or 0
end

function Scalar.Extend(self) -- TODO
    local next = table.clone(self)
    next._Container = table.clone(next._Container)
    return next
end

--\\ Instance Metamethods

function Scalar.__index(self, i: string)
    local value = rawget(Scalar, i)
    if value ~= nil then return value end

    for _, data in self._Container do
        if data[1] == i then
            return data[2]
        end
    end

    return nil
end

function Scalar.__newindex(self, i: string, v: Scope.Scope<any>)
    assert(rawget(Scalar, i) == nil, tostring(i) .. " is read only.")
    assert(isScope(v), "Only new scopes may be assigned.")

    local order = getmetatable(v).__order

    if order then
        table.insert(self._Container, order, {i, v})
    else
        table.insert(self._Container, {i, v})
    end
end

function Scalar.__call(self: Scalar, base: number?)
    return self:Get(base)
end

function Scalar.__iter(self: Scalar)
    local list = self._Container
    local len = #list
    local index = 0

    return function()
        if len == 0 then return end

        index += 1

        while list[index] == nil and index ~= len do
            index += 1
        end

        local result = list[index]

        if result == nil then
            return result
        else
            return result[1], result[2]
        end
    end
end

function Scalar.__len(self: Scalar): number
    return #self._Container
end

return Super