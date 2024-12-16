--[[

    avocado (@avodey) -w-

    A library to dynamically adjust values.

    12/11/24

]]

local Super = {}
local Scalar = {__type = "Scalar"}

local Scope = require("./Scope")
local Connection = require("./Connection")

Super.Scope = Scope.new

--\\ Types

export type Scalar = {
    [string]: Scope.Scope<any>,

    _Base: any,
    _Binds: {(any) -> ()},
    _Container: {{string|Scope.Scope<any>}},
} & typeof(Scalar)

--\\ Private Methods

local function isScope(item): boolean
    if type(item) == "table" then
        local meta = getmetatable(item)
        return meta and meta.__type == "Scope"
    end

    return false
end

local function isScalar(item): boolean
    return type(item) == "table" and getmetatable(item) == Scalar
end

--\\ Public Methods

function Super.new(base: any?): Scalar
    return setmetatable({
        _Base = base or 0,
        _Binds = {},
        _Container = {},
    } :: Scalar, Scalar)
end

function Super:IsValid(item): boolean
    return isScalar(item)
end

--\\ Instance Methods

function Scalar.Get(self: Scalar, base: any?): any -- TO TEST
    local result = base or self._Base

    for i, data in self._Container do
        local scope = data[2]

        if isScope(scope) then
            for _, parameter in scope do
                if isScalar(parameter) then
                    parameter = parameter:Get()
                end

                result = scope(result, parameter)
            end
        elseif isScalar(scope) then
            result = scope:Get(result)
        elseif type(scope) == "function" then
            result = scope(result)
        else
            error(`Bad member '{i}'. Expected Scope or Scalar, got '{typeof(data)}'.`, 2)
        end
    end

    return result
end

function Scalar.GetBase(self: Scalar): any
    return self._Base
end

function Scalar.Bind(self: Scalar, callback: (any) -> ()) -- TO TEST
    if type(callback) ~= "function" then error("Argument #1 must be a callback.") end
    return Connection(self._Binds, callback)
end

function Scalar.Extend(self: Scalar) -- TO TEST
    local next = table.clone(self)
    next._Container = table.create(#self._Container)

    for i, scope in self._Container do
        next._Container[i] = scope:Clone()
    end

    return next
end

function Scalar._Fire(self: Scalar)
    local result = self:Get()

    for _, bind in self._Binds do
        coroutine.wrap(bind)(result)
    end
end

--\\ Instance Metamethods

function Scalar.__len(self: Scalar): number
    return #self._Container
end

function Scalar.__iter(self: Scalar) -- TO TEST
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

function Scalar.__call(self: Scalar, base: number?)
    return self:Get(base)
end

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

function Scalar.__newindex(self, name: string, scope: Scope.Scope<any>) -- TO TEST
    assert(isScope(scope), "Only new scopes may be assigned.")

    local order = scope:GetOrder()

    for i, pair in self._Container do
        if pair[1] == name then
            table.remove(self._Container, i)
            break
        end
    end

    if order then
        table.insert(self._Container, order, {name, scope})
    else
        table.insert(self._Container, {name, scope})
    end
end

table.freeze(Super)
table.freeze(Scalar)

return Super