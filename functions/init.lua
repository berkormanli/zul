local debug_getinfo = debug.getinfo

zlib = setmetatable({
    name = 'zul',
    context = IsDuplicityVersion() and 'server' or 'client',
}, {
    __newindex = function(self, name, fn)
        rawset(self, name, fn)

        if debug_getinfo(2, 'S').short_src:find('@zul/resource') then
            exports(name, fn)
        end
    end
})

cache = {
    resource = zlib.name,
    game = GetGameName(),
}

function zlib.hasLoaded() return true end