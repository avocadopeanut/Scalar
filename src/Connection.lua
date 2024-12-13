return function(list, item)
    table.insert(list, item)

    local connection = {
        Disconnect = function()
            if not item then return end
            local i = table.find(list, item)
            if i then
                table.remove(list, i)
                item = nil
            end
        end
    }

    connection.Destroy = connection.Disconnect

    return connection
end