local BitchModelLoad = false
local BitchAmbient = false
local Deskwarning = false
local SecretaryActive = true

function F_UpdateSEC()
    local hour, minute = ClockGet()
    local SecFacing = false
    if hour < 19 and 7 <= hour then
        SecretaryActive = true
    else
        SecretaryActive = false
    end
    if not MissionActiveSpecific("1_01") and not MissionActiveSpecific("1_02") and shared.gPrincipalCheck == true and SecretaryActive == true and BitchModelLoad == true then
        while not RequestModel(59, true) do
            Wait(0)
        end
        if not PedIsValid(shared.gSecretaryID) then
            shared.gSecretaryID = PedCreatePoint(59, POINTLIST._SECRETARY)
            PedModelNotNeededAmbient(shared.gSecretaryID)
            PedMakeAmbient(shared.gSecretaryID)
        else
            PedSetPosPoint(shared.gSecretaryID, POINTLIST._SECRETARY)
        end
        PedFollowPath(shared.gSecretaryID, PATH._SECRETARYOFFICEPATH, 2, 0)
        BitchModelLoad = false
    end
    if Deskwarning == true and BitchAmbient == false and PedIsValid(shared.gSecretaryID) then
        PedMakeAmbient(shared.gSecretaryID)
        BitchAmbient = true
    end
end

function main()
    F_PreDATInit()
    while not (AreaGetVisible() ~= 5 or SystemShouldEndScript()) do
        Wait(0)
    end
end

function F_RegisterPOEvents()
    RegisterTriggerEventHandler(TRIGGER._PSECRETARY, 1, F_SecCreate, 0)
    AreaSetTriggerMonitoringRules(TRIGGER._PSECRETARY, true)
end

function F_SecCreate(triggerID, pedID)
    if SecretaryActive == true and not PedIsValid(shared.gSecretaryID) then
        BitchModelLoad = true
    end
end

function F_SecDestroy(triggerID, pedID)
    if PedIsValid(shared.gSecretaryID) then
        PedDelete(shared.gSecretaryID)
        shared.gSecretaryID = nil
    end
    BitchAmbient = false
end
