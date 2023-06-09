

---@param template table
---@return table
function zlib.spread(template)
    local result = {}
    for key, value in pairs(template) do
        result[key] = value
    end

    return function(table)
        for key, value in pairs(table) do
            result[key] = value
        end
        return result
    end
end

return zlib.spread

--[[-- Example Usage --

local default_player = {
    name = '',
    score = 0,
    position = {
        x = 0,
        y = 0,
    }
}

local player1 = zlib.spread(default_player) {
    name = 'Alice'
}

]]