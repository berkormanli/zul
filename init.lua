-- zul <https://github.com/berkormanli/zul>
-- Copyright (C) 2023 Zeixna <https://github.com/berkormanli>
-- LGPL-3.0-or-later <https://www.gnu.org/licenses/lgpl-3.0.en.html>

if not _VERSION:find('5.4') then
	error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local zul = 'zul'
local export = exports[zul]

if not GetResourceState(zul):find('start') then
	error('^1zul should be started before this resource.^0', 2)
end

local status = export.hasLoaded()

if status ~= true then error(status, 2) end

-----------------------------------------------------------------------------------------------
-- Module
-----------------------------------------------------------------------------------------------

local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

function noop() end

local function loadModule(self, module)
	local dir = ('imports/%s'):format(module)
	local chunk = LoadResourceFile(zul, ('%s/%s.lua'):format(dir, context))
	local shared = LoadResourceFile(zul, ('%s/shared.lua'):format(dir))

	if shared then
		chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
	end

	if chunk then
		local fn, err = load(chunk, ('@@zul/%s/%s.lua'):format(module, context))

		if not fn or err then
			return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
        end

        local result = fn()
        self[module] = result or noop
        return self[module]
	end
end

-----------------------------------------------------------------------------------------------
-- API
-----------------------------------------------------------------------------------------------

local function call(self, index, ...)
	local module = rawget(self, index)

	if not module then
        self[index] = noop
		module = loadModule(self, index)

		if not module then
			local function method(...)
				return export[index](nil, ...)
			end

			if not ... then
				self[index] = method
			end

			return method
		end
	end

	return module
end

zlib = setmetatable({
	name = zul,
	context = context,
	onCache = function(key, cb)
		AddEventHandler(('zul:cache:%s'):format(key), cb)
	end
}, {
	__index = call,
	__call = call,
})

-- Override standard Lua require with our own.
require = zlib.require

local intervals = {}
--- Dream of a world where this PR gets accepted.
---@param callback function | number
---@param interval? number
---@param ... any
function SetInterval(callback, interval, ...)
	interval = interval or 0

    if type(interval) ~= 'number' then
        return error(('Interval must be a number. Received %s'):format(json.encode(interval --[[@as unknown]])))
    end

	local cbType = type(callback)

	if cbType == 'number' and intervals[callback] then
		intervals[callback] = interval or 0
		return
	end

    if cbType ~= 'function' then
        return error(('Callback must be a function. Received %s'):format(cbType))
    end

	local args, id = { ... }

	Citizen.CreateThreadNow(function(ref)
		id = ref
		intervals[id] = interval or 0
		repeat
			interval = intervals[id]
			Wait(interval)
			callback(table.unpack(args))
		until interval < 0
		intervals[id] = nil
	end)

	return id
end

---@param id number
function ClearInterval(id)
    if type(id) ~= 'number' then
        return error(('Interval id must be a number. Received %s'):format(json.encode(id --[[@as unknown]])))
	end

    if not intervals[id] then
        return error(('No interval exists with id %s'):format(id))
	end

	intervals[id] = -1
end

-----------------------------------------------------------------------------------------------
-- Cache
-----------------------------------------------------------------------------------------------

cache = { game = GetGameName(), resource = GetCurrentResourceName() }
local notify = ('__z_notify_%s'):format(cache.resource)

if context == 'client' then
	setmetatable(cache, {
		__index = function(self, key)
			AddEventHandler(('zul:cache:%s'):format(key), function(value)
				self[key] = value
			end)

			return rawset(self, key, export.cache(nil, key) or false)[key]
		end,
	})

	RegisterNetEvent(notify, function(data)
		if locale then
			if data.title then
				data.title = locale(data.title) or data.title
			end

			if data.description then
				data.description = locale(data.description) or data.description
			end
		end

		return export:notify(data)
	end)

	cache.playerId = PlayerId()
	cache.serverId = GetPlayerServerId(cache.playerId)
else
    ---Trigger a notification on the target playerId from the server.\
    ---If locales are loaded, the title and description will be formatted automatically.\
    ---Note: No support for locale placeholders when using this function.
    ---@param playerId number
    ---@param data NotifyProps
	function zlib.notify(playerId, data)
		TriggerClientEvent(notify, playerId, data)
	end
end