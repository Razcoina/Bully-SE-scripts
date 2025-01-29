POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local GoalsCreated = false
local ObjectiveMet = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = {
    234,
    136,
    234
}
local bActive = false
local ratsTotal = 18
local rats = 18
local dead = 0
local ObjFlag = false
local bExit = false
local bGoneIn = false
local MissionScenarioComplete = false
local tblRatLocs = {}
local tblRats = {
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1
}
local AcceptScenario = false

function main()
    while SetupComplete == false do
        if OutOfRange == true or POIInfo == nil then
            SetupComplete = true
        else
            SetupComplete = F_ScenarioSetup()
        end
        Wait(0)
    end
    while F_CheckConditions() == true do
        if GreetingComplete == false then
            GreetingComplete = F_OnGreeting()
        elseif DialogComplete == false then
            DialogComplete = F_OnDialog()
        elseif AcceptScenario == false then
            AcceptScenario = F_AcceptScenario()
        elseif GoalsCreated == false then
            GoalsCreated = F_ScenarioGoals()
        elseif MissionScenarioComplete == false then
            MissionScenarioComplete = F_MissionSpecificCheck()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_RO_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(234, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(234, POIInfo)
        if PedIsValid(ScenarioPed) then
            PedMakeAmbient(ScenarioPed, false)
        end
    else
        PedClearAllWeapons(ScenarioPed)
        PedSetPOI(ScenarioPed, POIInfo, true)
        PedEnableGiftRequirement(ScenarioPed, false)
    end
    if PedIsValid(ScenarioPed) then
        PedSetFlag(ScenarioPed, 110, true)
        PedSetPedToTypeAttitude(ScenarioPed, 13, 2)
        PedMoveToObject(ScenarioPed, gPlayer, 2, 1, nil, 2)
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 4)
        return true
    else
        return false
    end
end

function F_PlayerOutOfRange()
    local x1, y1, z1 = POIGetPosXYZ(POIInfo)
    local x2, y2, z2 = PlayerGetPosXYZ()
    if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > AreaGetPopulationCullDistance() == true then
        return true
    else
        return false
    end
end

function F_OnGreeting()
    if PedIsDoingTask(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen", false) == true then
        TimeOutTimer = GetTimer()
        return true
    else
        return false
    end
end

function F_OnDialog()
    if PedIsDoingTask(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 35, "generic", false, true)
        return true
    else
        if GetTimer() >= TimeOutTimer + TimeOutTime then
            SoundPlayAmbientSpeechEvent(ScenarioPed, "BYE")
            bTimedOut = true
        end
        return false
    end
end

function F_AcceptScenario()
    if PedIsDoingTask(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted", true) == true then
        --print("SCENARIOACCEPTED")
        PedMakeMissionChar(ScenarioPed)
        DoSocialErrands(true, "AS_RO_OBJECTIVE")
        bOnMission = true
        BlipRemove(ScenarioPedBlip)
        windowX, windowY, windowZ = 583.44, -472.398, 4.46054
        gWindowBlip = BlipAddXYZ(windowX, windowY, windowZ, 1)
        bActive = true
        return true
    else
        if GetTimer() >= TimeOutTimer + TimeOutTime then
            SoundPlayAmbientSpeechEvent(ScenarioPed, "BYE")
            bTimedOut = true
        end
        return false
    end
end

function F_ScenarioGoals()
    if not bEnterTenements and PlayerIsInAreaXYZ(windowX, windowY, windowZ, 1, 7) then
        BlipRemove(gWindowBlip)
        bEnterTenements = true
    end
    if bEnterTenements then
        PlayerSetControl(0)
        CameraFade(1000, 0)
        Wait(1000)
        AreaDisableCameraControlForTransition(true)
        AreaClearAllPeds()
        AreaTransitionPoint(36, POINTLIST._TENFIRES_ENTERANCE)
        DATLoad("TenErrands.DAT", 2)
        DATInit()
        while not AreaGetVisible() == 36 do
            Wait(0)
        end
        AreaClearAllPeds()
        F_CreateRats()
        CameraFade(1000, 1)
        Wait(1000)
        DoSocialErrands(true, "AS_RO_OBJCOUNT", dead)
        PlayerSetControl(1)
        AreaDisableCameraControlForTransition(false)
        bGoneIn = true
        return true
    end
    return false
end

function F_CreateRats()
    tblRatLocs = {
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE01
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE02
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE03
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE04
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE05
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE06
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE07
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE08
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE09
        }
    }
    for r, rat in tblRats do
        --print("== Rat ===", rat)
    end
    for r, rat in tblRatLocs do
        local x, y, z = GetAnchorPosition(rat.trigger)
        tblRats[r] = PedCreateXYZ(136, x, y, z)
        tblRats[r + 9] = PedCreateXYZ(136, x + 1, y, z)
        AddBlipForChar(tblRats[r], 0, 1, 4)
        AddBlipForChar(tblRats[r + 9], 0, 1, 4)
        PedWander(tblRats[r], 1)
        PedWander(tblRats[r + 9], 1)
    end
    for r, rat in tblRats do
        --print("== Rat ===", rat)
    end
    return true
end

function F_RatHit(pedID)
end

function F_MissionSpecificCheck()
    for r, rat in tblRats do
        if rat ~= -1 and PedIsValid(rat) then
            local health = PedGetHealth(rat)
            if PedGetHealth(rat) <= 0 then
                rats = rats - 1
                dead = dead + 1
                tblRats[r] = -1
                BlipRemoveFromChar(rat)
                DoSocialErrands(true, "AS_RO_OBJCOUNT", dead)
                break
            end
        end
    end
    if rats <= 0 then
        return true
    else
        return false
    end
end

function F_ObjectiveMet()
    DoSocialErrands(false)
    MinigameSetErrandCompletion(32, "AS_COMPLETE", true, 2500)
    local x, y, z = GetPointFromPointList(POINTLIST._TENEXIT, 1)
    bExit = true
    while PlayerIsInAreaXYZ(x, y, z, 100, 7) do
        Wait(0)
    end
    shared.gCurrentAmbientScenarioObject.completed = true
    shared.gCurrentAmbientScenarioObject.time = GetTimer() + 480000
    PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
    PedClearPOI(ScenarioPed)
    return true
end

function F_CheckConditions()
    if DialogComplete == false then
        OutOfRange = F_PlayerOutOfRange()
        if OutOfRange == true and PedIsValid(ScenarioPed) and PedIsOnScreen(ScenarioPed) == false then
            PedDelete(ScenarioPed)
        end
    end
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and shared.gBusTransition == nil and OutOfRange == false then
        if bActive and not bExit and bGoneIn and AreaGetVisible() == 0 then
            MinigameSetErrandCompletion(46, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            return false
        end
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(32, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup    ========= Rats Out")
    BlipRemove(ScenarioBlip)
    BlipRemove(gWindowBlip)
    if PedIsValid(ScenarioPed) == true then
        if ObjectiveMet then
            PedDelete(ScenarioPed)
        else
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
            PedSetFlag(ScenarioPed, 110, false)
            PedStop(ScenarioPed)
            PedMakeAmbient(ScenarioPed)
            PedClearPOI(ScenarioPed)
            BlipRemove(ScenarioPedBlip)
            PedWander(ScenarioPed, 0)
        end
    end
    RegisterGlobalEventHandler(7, nil)
    for r, rat in tblRats do
        if PedIsValid(rat) then
            PedDelete(rat)
        end
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 480000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
