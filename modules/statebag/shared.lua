local isServer = IsDuplicityVersion()

if isServer then
    zlib.statebag = {}
    zlib.statebag.handlers = {}

    zlib.statebag.Player = {}

    function zlib.statebag.Player.SetNetworked(source, stateKey, value)
        if Player(source).state[stateKey] ~= value then
            Player(source).state:set(stateKey, value, true)
        end
    end

    function zlib.statebag.Player.SetForServer(source, stateKey, value)
        if Player(source).state[stateKey] ~= value then
            Player(source).state:set(stateKey, value, false)
        end
    end

    zlib.statebag.GlobalState = {}

    function zlib.statebag.GlobalState.Set(stateKey, value)
        GlobalState[stateKey] = value
    end

    zlib.statebag.Entity = {}

    function zlib.statebag.Entity.SetNetworked(entityNetID, stateKey, value)
        local entityID = NetworkGetEntityFromNetworkId(entityNetID)
        if not DoesEntityExist(entityID) then return false, 'entity_does_not_exist' end
        Entity(entityID).state:set(stateKey, value, true)
        return true, 'entity_state_bag_set_successfully'
    end

    function zlib.statebag.Entity.SetForServer(entityNetID, stateKey, value)
        local entityID = NetworkGetEntityFromNetworkId(entityNetID)
        if not DoesEntityExist(entityID) then return false, 'entity_does_not_exist' end
        Entity(entityID).state:set(stateKey, value, false)
        return true, 'entity_state_bag_set_successfully'
    end

    RegisterServerEvent('zlib:server:setEntityStateBag')
    AddEventHandler('zlib:server:setEntityStateBag', function(entityNetID, stateKey, value, replicated)
        if replicated then
            zlib.statebag.Entity.SetNetworked(entityNetID, stateKey, value)
        else
            zlib.statebag.Entity.SetForServer(entityNetID, stateKey, value)
        end
    end)

    local function splitString(inputString)
        local firstPart, secondPart = inputString:match("([^:]*):(.*)")
        return firstPart, secondPart
    end

    function zlib.statebag.addStateHandler(stateKey, bagFilter, handler)
        local stateHandlerCookie = AddStateBagChangeHandler(stateKey, bagFilter, function(bagName, key, newValue)
            local targetType, _ = splitString(bagName)

            local targetState
            if targetType == 'player' then
                local plySource = GetPlayerFromStateBagName(bagName)
                if plySource == 0 then return nil end
                targetState = Player(plySource).state
            elseif targetType == 'entity'then
                local entityNetID = GetEntityFromStateBagName(bagName)
                if entityNetID == 0 then return nil end
                targetState = Entity(entityNetID).state
            end

            handler(key, newValue, targetState)
        end)
        zlib.statebag.handlers[stateKey] = stateHandlerCookie
        return stateHandlerCookie
    end

    return zlib.statebag
else
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
end