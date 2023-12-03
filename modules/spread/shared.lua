

---@param self table
---@return fun(table): table
function zlib.spread(self)
    local result = {}
    for key, value in pairs(self) do
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

OR

local player2 = default_player:spread(){
    name = 'Alice'
}

]]