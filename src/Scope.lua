--[[

    avocado (@avodey) -w-

    Creates an object containing a list of values and a callback.

    12/11/24

]]

local Super = {}
local Scope = {}

local Connection = require("./Connection")

export type Scope<T> = {
    [any]: T
} & typeof(Scope) & (number, T) -> number

--\\ Public Methods

function Super.new<T>(callback: (T, any) -> T, order: number?): Scope<T>
    assert(type(callback) == "function", "Argument #1 must be a callback.")
    assert(order == nil or type(order) == "number", "Argument #2 must be a number or nil.")

    local meta = table.clone(Scope)
    meta.__type = "Scope"
    meta.__order = tonumber(order)
    meta.__callback = callback
    meta.__list = {}
    meta.__binds = {}

    return setmetatable({}, meta) :: Scope<T>
end

--\\ Instance Methods

function Scope.Bind(self: Scope<any>, callback: () -> ())
    assert(type(callback) == "function", "Argument #1 expects a callback.")
    local meta = getmetatable(self)
    return Connection(meta._binds, callback)
end

function Scope.GetOrder(self: Scope<any>): number?
    return getmetatable(self).__order
end

function Scope.GetCallback<T>(self: Scope<T>): (T, any) -> T
    return getmetatable(self).__call
end

function Scope._Fire(self: Scope<any>)
    local meta = getmetatable(self)
    for _, callback in meta.__binds do
        coroutine.wrap(callback)()
    end
end

--\\ Instance Metamethods

function Scope.__len(self): number
    return #getmetatable(self).__list
end

function Scope.__iter(self): typeof(pairs)
    local list = getmetatable(self).__list
    local len = #list
    local index = 0

    return function()
        if len == 0 then return end

        index += 1

        while list[index] == nil and index < len do
            index += 1
        end

        local result = list[index]

        if result ~= nil then
            return unpack(result)
        end
    end
end

function Scope.__call(self, ...): number
    return getmetatable(self).__callback(...)
end

function Scope.__index(self, i: string): any
    local value = rawget(Scope, i)
    if value then return value end

    local list = getmetatable(self).__list

    for _, data in list do
        if data[1] == i then
            return data[2]
        end
    end

    return nil
end

function Scope.__newindex(self, i: string, v: any)
    local list = getmetatable(self).__list

    for index, data in list do
        if data[1] == i then
            if v == nil then
                table.remove(list, index)
                self:_Fire()
            elseif data[2] ~= v then
                data[2] = v
                self:_Fire()
            end

            return
        end
    end

    table.insert(list, {i, v})
    self:_Fire()
end

function Scope.__tostring(self): string
    return "<Scope>"
end

table.freeze(Super)
table.freeze(Scope)

return Super