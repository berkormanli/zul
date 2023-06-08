local function allowAce(allow)
	return allow == false and 'deny' or 'allow'
end

-- Adds the ace to the principal.
function zlib.addAce(principal, ace, allow)
	if type(principal) == 'number' then
		principal = 'player.'..principal
	end

	ExecuteCommand(('add_ace %s %s %s'):format(principal, ace, allowAce(allow)))
end

-- Removes the ace from the principal.
function zlib.removeAce(principal, ace, allow)
	if type(principal) == 'number' then
		principal = 'player.'..principal
	end

	ExecuteCommand(('remove_ace %s %s %s'):format(principal, ace, allowAce(allow)))
end

-- Adds the child principal to the parent principal.
function zlib.addPrincipal(child, parent)
	if type(child) == 'number' then
		child = 'player.'..child
	end

	ExecuteCommand(('add_principal %s %s'):format(child, parent))
end

-- Removes the child principal from the parent principal.
function zlib.removePrincipal(child, parent)
	if type(child) == 'number' then
		child = 'player.'..child
	end

	ExecuteCommand(('remove_principal %s %s'):format(child, parent))
end

zlib.callback.register('zul:checkPlayerAce', function(source, command)
    return IsPlayerAceAllowed(source, command)
end)