zlib.statebag = {}
zlib.statebag.handlers = {}

zlib.statebag.LocalPlayer = {}

function zlib.statebag.LocalPlayer.SetNetworked(stateKey, value)
    if LocalPlayer.state[stateKey] ~= value then
        LocalPlayer.state:set(stateKey, value, true)
    end
end

function zlib.statebag.LocalPlayer.SetLocal(stateKey, value)
    if LocalPlayer.state[stateKey] ~= value then
        LocalPlayer.state:set(stateKey, value, false)
    end
end

zlib.statebag.Entity = {}

function zlib.statebag.Entity.SetNetworked(entityID, stateKey, value)
    if not DoesEntityExist(entityID) then return false, 'entity_does_not_exist' end
    if DoesEntityExist(entityID) and not NetworkGetEntityIsNetworked(entityID) then return false, 'entity_is_not_networked' end
    local entityNetID = NetworkGetEntityFromNetworkId(entityID)
    TriggerServerEvent('zlib:server:setEntityStateBag', entityNetID, stateKey, value)
end

function zlib.statebag.Entity.SetLocal(entityID, stateKey, value)
    if not DoesEntityExist(entityID) then return false, 'entity_does_not_exist' end
    if DoesEntityExist(entityID) and not NetworkGetEntityIsNetworked(entityID) then return false, 'entity_is_not_networked' end
    local entityNetID = NetworkGetEntityFromNetworkId(entityID)
    TriggerServerEvent('zlib:server:setEntityStateBag', entityNetID, stateKey, value)
end

local function splitString(inputString)
    local firstPart, secondPart = inputString:match("([^:]*):(.*)")
    return firstPart, secondPart
end


function zlib.statebag.addStateHandler(stateKey, bagFilter, handler)
    local stateHandlerCookie = AddStateBagChangeHandler(stateKey, bagFilter, function(bagName, key, newValue)
        local targetType, _ = splitString(bagName)

        local targetState
        if targetType == 'player' then
            local plyHandle = GetPlayerFromStateBagName(bagName)
            if plyHandle == 0 then return nil end
            targetState = Player(plyHandle).state
        elseif targetType == 'entity' or targetType == 'localEntity' then
            local entityHandle = GetEntityFromStateBagName(bagName)
            if entityHandle == 0 then return nil end
            targetState = Entity(entityHandle).state
        end

        handler(key, newValue, targetState)
    end)
    zlib.statebag.handlers[stateKey] = stateHandlerCookie
    return stateHandlerCookie
end

return zlib.statebag