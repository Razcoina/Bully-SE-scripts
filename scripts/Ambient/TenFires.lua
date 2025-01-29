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
local peds = { 234 }
local bActive = false
local firecounter = 6
local ObjFlag = false
local bExit = false
local bGoneIn = false
local MissionScenarioComplete = false
local windowX, windowY, windowZ = 0, 0, 0
local tblFires = {}
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
    DoSocialErrands(false, "AS_TF_OBJECTIVE")
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 34, "generic", false, true)
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
        PlayerSetControl(0)
        while not WeaponRequestModel(326) do
            Wait(0)
        end
        bOnMission = true
        PedSetActionNode(ScenarioPed, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PedSetWeaponNow(gPlayer, 326, 100, false)
        Wait(1000)
        PlayerSetControl(1)
        BlipRemove(ScenarioPedBlip)
        DoSocialErrands(true, "AS_ENTER_TENS")
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
        AreaTransitionPoint(36, POINTLIST._TENFIRES_ENTERANCE)
        DATLoad("TenErrands.DAT", 2)
        DATInit()
        SoundLoadBank("OBJECTS\\FIRECAN.bnk")
        while not AreaGetVisible() == 36 do
            Wait(0)
        end
        F_CreateFires()
        CameraFade(1000, 1)
        Wait(1000)
        PlayerSetControl(1)
        bGoneIn = true
        AreaDisableCameraControlForTransition(false)
        DoSocialErrands(true, "AS_TF_OBJCOUNT", firecounter)
        return true
    end
    return false
end

function F_CreateFires()
    tblFires = {
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE01,
            x = -532.175,
            y = -23.1511,
            z = 30.9426,
            bOut = false
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE02,
            x = -523.533,
            y = -46.119,
            z = 30.9215,
            bOut = false
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE04,
            x = -520.094,
            y = -21.4904,
            z = 35.6585,
            bOut = false
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE05,
            x = -543.076,
            y = -48.2422,
            z = 35.611,
            bOut = false
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE08,
            x = -531.517,
            y = -48.0586,
            z = 40.3952,
            bOut = false
        },
        {
            id = -1,
            blip = 0,
            trigger = TRIGGER._TEN_FIRE10,
            x = -533.552,
            y = -31.7882,
            z = 30.9426,
            bOut = false
        }
    }
    for f, fire in tblFires do
        fire.id = FireCreate(fire.trigger, 750, 15, 100, 115, "GymFire")
        FireSetScale(fire.id, 1)
        FireSetDamageRadius(fire.id, 1)
        PAnimHideHealthBar(fire.trigger)
        local x, y, z = GetAnchorPosition(fire.trigger)
        fire.blip = BlipAddXYZ(x, y, z, 1, 4)
    end
end

function F_MissionSpecificCheck()
    local firesOut = 0
    for f, fire in tblFires do
        if not fire.bOut and 0 >= FireGetHealth(fire.id) then
            fire.bOut = true
            firecounter = firecounter - 1
            BlipRemove(fire.blip)
            DoSocialErrands(true, "AS_TF_OBJCOUNT", firecounter)
        elseif fire.bOut then
            firesOut = firesOut + 1
        end
    end
    if firesOut == 6 then
        return true
    else
        return false
    end
end

function F_ObjectiveMet()
    DoSocialErrands(false)
    MinigameSetErrandCompletion(46, "AS_COMPLETE", true, 2500)
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
            MinigameSetErrandCompletion(46, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_CleanupFires()
    for i, fire in tblFires do
        if fire.id ~= -1 and not fire.bOut then
            FireDestroy(fire.id)
            fire.id = -1
        end
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    SoundUnLoadBank("OBJECTS\\FIRECAN.bnk")
    --print("F_ScenarioCleanup    ========= Ten Fires")
    BlipRemove(gWindowBlip)
    BlipRemove(ScenarioBlip)
    AreaDisableCameraControlForTransition(false)
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
    F_CleanupFires()
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
