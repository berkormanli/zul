local isServer = IsDuplicityVersion()

Timer = zlib.class()

function Timer:__init()
    self.timer = GetGameTimer()
    self.intervalActive = false
end

function Timer:SetIntervalActive(bool)
    self.intervalActive = bool
end

function Timer:ToggleIntervalActive()
    self.intervalActive = not self.intervalActive
end

function Timer:GetIntervalActive()
    return self.intervalActive
end

function Timer:GetMilliseconds()
    return GetGameTimer() - self.timer
end

function Timer:GetSeconds()
    return self:GetMilliseconds() / 1000
end

function Timer:GetMinutes()
    return self:GetSeconds() / 60
end

function Timer:GetHours()
    return self:GetMinutes() / 60
end

function Timer:Restart()
    self.timer = GetGameTimer()
end

if isServer then
    function Timer:SetExport(exportName, delay, isInterval)
        if not delay then delay = 0 end
        if not isInterval then isInterval = false end
        self.export = exports[GetInvokingResource()][exportName]
        if isInterval then
            CreateThread(function()
                while self:GetIntervalActive() do
                    Wait(delay)
                    self.export()
                end
            end)
        else
            CreateThread(function()
                Wait(delay)
                self.export()
            end)
        end
    end

    function Timer:SetEvent(eventName, delay, isInterval)
        if not isInterval then isInterval = false end
        self.serverEvent = eventName
        if isInterval then
            CreateThread(function()
                while self:GetIntervalActive() do
                    Wait(delay)
                    TriggerEvent(self.serverEvent)
                end
            end)
        else
            CreateThread(function()
                Wait(delay)
                TriggerEvent(self.serverEvent)
            end)
        end
    end

    function Timer:SetServerEvent(eventName, delay, isInterval)
    end
else
    function Timer:SetExport(exportName, delay, isInterval)
        if not isInterval then isInterval = false end
        self.export = exports[GetInvokingResource()][exportName]
        if isInterval then
            CreateThread(function()
                while self:GetIntervalActive() do
                    Wait(delay)
                    self.export()
                end
            end)
        else
            CreateThread(function()
                Wait(delay)
                self.export()
            end)
        end
    end

    function Timer:SetEvent(eventName, delay, isInterval)
        if not isInterval then isInterval = false end
        self.clientEvent = eventName
        if isInterval then
            CreateThread(function()
                while self:GetIntervalActive() do
                    Wait(delay)
                    TriggerEvent(self.clientEvent)
                end
            end)
        else
            CreateThread(function()
                Wait(delay)
                TriggerEvent(self.clientEvent)
            end)
        end
    end

    function Timer:SetServerEvent(eventName, delay, isInterval)
        if not isInterval then isInterval = false end
        self.serverEvent = eventName
        if isInterval then
            CreateThread(function()
                while self:GetIntervalActive() do
                    Wait(delay)
                    TriggerEvent(self.serverEvent)
                end
            end)
        else
            CreateThread(function()
                Wait(delay)
                TriggerEvent(self.serverEvent)
            end)
        end
    end
end