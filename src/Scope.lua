export type Scope<T> = {
    [any]: T
} & (number, T) -> number

--\\ Private Methods

local function __index(self, i: string): any
    local list = getmetatable(self).__list

    for _, data in list do
        if data[1] == i then
            return data[2]
        end
    end

    return nil
end

local function __newindex(self, i: string, v: any)
    local list = getmetatable(self).__list

    for index, data in list do
        if data[1] == i then
            if v == nil then
                table.remove(list, index)
            else
                data[2] = v
            end

            return
        end
    end

    table.insert(list, {i, v})
end

local function __iter(self)
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

        if result == nil then
            return result
        else
            return result[1], result[2]
        end
    end
end

local function __len(self): number
    return #getmetatable(self).__list
end

local function __tostring(self): string
    return "<Scope>"
end

--\\ Public Methods

return function(callback: (number, any) -> number, order: number?)
    assert(type(callback) == "function", "Argument #1 must be a callback.")
    assert(order == nil or type(order) == "number", "Argument #2 must be a number or nil.")

    return setmetatable({}, {
        __call = function(_, ...)
            return callback(...)
        end,

        __type = "Scope",
        __order = type(order) == "number" and order or nil,
        __list = {},

        __len = __len,
        __iter = __iter,
        __index = __index,
        __newindex = __newindex,
        __tostring = __tostring,
    })
end