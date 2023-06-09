local _registerCommand = RegisterCommand

---@param commandName string
---@param callback fun(source, args, raw)
---@param restricted boolean?
function RegisterCommand(commandName, callback, restricted)
	_registerCommand(commandName, function(source, args, raw)
		if not restricted or zlib.callback.await('zul:checkPlayerAce', 100, ('command.%s'):format(commandName)) then
			callback(source, args, raw)
		end
	end)
end