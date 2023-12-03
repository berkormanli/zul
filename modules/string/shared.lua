---@class zulstring : stringlib
zlib.string = string

-- splits a string given a seperator
-- returns a sequential table of tokens, which could be empty
function string.split(self, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local t = {}
    for str in string.gmatch(self, "([^" .. seperator .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return zlib.string