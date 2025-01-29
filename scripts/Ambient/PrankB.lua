POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local AcceptScenario = false
local GoalsCreated = false
local ObjectiveMet = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = {
    42,
    76,
    77,
    78,
    79,
    80,
    81
}
local bActive = false
local ObjFlag = false
local timeLimit = 60
local bTimeNotSet = true
local bToldToGoBack = true
local MissionScenarioComplete = false
local bReturn = false
local gBlipTap = 0
local hitCount = 0
local hitGoal = 3
local downCount = hitGoal
local tblDeadPool = {}
local tblCityFolk = {}
local bGotBalloon = false
local tapX, tapY, tapZ = 553.839, -76.2001, 13.6951
local STATE_NONE = 0
local STATE_GO01 = 1
local STATE_GO02 = 2
local STATE_GONE = 3
local STATE_FEAR = 4
local tblTarget01 = {
    { id = -1, state = STATE_NONE },
    { id = -1, state = STATE_NONE },
    { id = -1, state = STATE_NONE }
}
local tblTarget02 = {
    { id = -1, state = STATE_NONE },
    { id = -1, state = STATE_NONE },
    { id = -1, state = STATE_NONE }
}
local spawnTime01 = 0
local spawnTime02 = 0
local s1x, s1y, s1z = 528.156, -104.979, 4.76785
local s2x, s2y, s2z = 528.583, -96.0501, 4.46353
local s3x, s3y, s3z = 567.977, -96.634, 5.6796
local s4x, s4y, s4z = 569.008, -77.5168, 5.69518
local s5x, s5y, s5z = 567.892, -83.6508, 5.69863
local s6x, s6y, s6z = 528.379, -83.0481, 4.55547

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
    DoSocialErrands(false, "AS_PB_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(42, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(42, POIInfo)
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
        tblCityFolk = {
            76,
            77,
            78,
            79,
            80,
            81
        }
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 30, 4)
        return true
    else
        return false
    end
end

function F_PlayerOutOfRange()
    local x1, y1, z1 = POIGetPosXYZ(POIInfo)
    local x2, y2, z2 = PlayerGetPosXYZ()
    if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > AreaGetPopulationCullDistance() then
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 79, "generic", false, true)
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
        PedMakeMissionChar(ScenarioPed)
        PedLockTarget(ScenarioPed, gPlayer, 3)
        shared.balloonErrandActive = true
        PAnimSetActionNode("tbusines_pxSink", 553.77, -76.201, 12.5949, 2, "/Global/WaterFaucet/Off", "Act/Props/WaterFaucet.act")
        BlipRemove(ScenarioPedBlip)
        for i = 1, 20 do
            table.insert(tblDeadPool, 0)
        end
        Wait(1000)
        RegisterGlobalEventHandler(7, F_CheckHit)
        bActive = true
        gBlipTap = BlipAddXYZ(tapX, tapY, tapZ, 30, 4)
        DoSocialErrands(true, "AS_PB_ACTION")
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
    if not bGotBalloon and PlayerHasWeapon(383) then
        BlipRemove(gBlipTap)
        gBlipTap = BlipAddXYZ(tapX, tapY, tapZ, 30, 2)
        DoSocialErrands(true, "AS_PB_OBJCOUNT", hitGoal)
        return true
    else
        return false
    end
end

function F_SpawnManagement()
    if spawnTime01 <= GetTimer() then
        for i, ped in tblTarget01 do
            if ped.id == 0 then
                local pedmodel = RandomTableElement(tblCityFolk)
                ped.id = PedCreateXYZ(pedmodel, s1x, s1y, s1z)
                PedMoveToXYZ(ped.id, 0, s2x, s2y, s2z, 1)
                ped.state = STATE_GO01
                spawnTime01 = GetTimer() + 4000
                break
            end
        end
    end
    if spawnTime02 <= GetTimer() then
        for i, ped in tblTarget02 do
            if ped.id == 0 then
                local pedmodel = RandomTableElement(tblCityFolk)
                ped.id = PedCreateXYZ(pedmodel, s4x, s4y, s4z)
                PedMoveToXYZ(ped.id, 0, s5x, s5y, s5z, 1)
                ped.state = STATE_GO01
                spawnTime02 = GetTimer() + 4000
                break
            end
        end
    end
end

function F_WanderManagement()
    for i, ped in tblTarget01 do
        if ped.state == STATE_GO01 then
            if PedIsInAreaXYZ(ped.id, s2x, s2y, s2z, 1, 0) then
                PedMoveToXYZ(ped.id, 0, s3x, s3y, s3z, 1)
                ped.state = STATE_GO02
                break
            end
        elseif ped.state == STATE_GO02 then
            if PedIsInAreaXYZ(ped.id, s3x, s3y, s3z, 1, 0) then
                PedWander(ped.id, 0)
                PedMakeAmbient(ped.id)
                ped.id = 0
                ped.state = STATE_NONE
                break
            end
        elseif ped.state ~= STATE_NONE and PedGetLastHitWeapon(ped.id) == 383 then
            PedFlee(ped.id, gPlayer)
            PedMakeAmbient(ped.id)
            ped.state = STATE_NONE
            ped.id = 0
            break
        end
    end
    for i, ped in tblTarget02 do
        if ped.state == STATE_GO01 then
            if PedIsInAreaXYZ(ped.id, s5x, s5y, s5z, 1, 0) then
                PedMoveToXYZ(ped.id, 0, s6x, s6y, s6z, 1)
                ped.state = STATE_GO02
                break
            end
        elseif ped.state == STATE_GO02 then
            if PedIsInAreaXYZ(ped.id, s6x, s6y, s6z, 1, 0) then
                PedWander(ped.id, 0)
                PedMakeAmbient(ped.id)
                ped.id = 0
                ped.state = STATE_NONE
                break
            end
        elseif ped.state ~= STATE_NONE and PedGetLastHitWeapon(ped.id) == 383 then
            PedFlee(ped.id, gPlayer)
            PedMakeAmbient(ped.id)
            ped.state = STATE_NONE
            ped.id = 0
            break
        end
    end
end

function F_CheckHit(pedID)
    if PedGetWhoHitMeLast(pedID) == gPlayer and PedGetLastHitWeapon(pedID) == 383 then
        bAlreadyHit = false
        for v, victim in tblDeadPool do
            if pedID == victim then
                bAlreadyHit = true
                break
            end
        end
        if not bAlreadyHit then
            hitCount = hitCount + 1
            downCount = downCount - 1
            if downCount == 1 then
                DoSocialErrands(true, "AS_PB_OBJCOUNT1", downCount)
            else
                DoSocialErrands(true, "AS_PB_OBJCOUNT", downCount)
            end
            table.insert(tblDeadPool, hitCount, ped)
            PedClearHitRecord(pedID)
            PedMakeAmbient(pedID)
            PedWander(pedID, 2)
        end
    end
end

function F_MissionSpecificCheck()
    if hitCount ~= hitGoal then
        return false
    else
        return true
    end
end

function F_NotCounted(ped)
    for v, victim in tblDeadPool do
        if victim == ped then
            return false
        end
    end
    return true
end

function F_ObjectiveMet()
    if hitCount ~= 0 then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(30, "AS_COMPLETE", true, 2000, "AS_BALLOONS")
    else
        DoSocialErrands(false)
        MinigameSetErrandCompletion(30, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
    end
    shared.gCurrentAmbientScenarioObject.completed = true
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
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(30, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup   ========= Prank B")
    MissionTimerStop()
    shared.balloonErrandActive = nil
    RegisterGlobalEventHandler(7, nil)
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    BlipRemove(gBlipTap)
    for i, ped in tblTarget01 do
        if ped.id ~= 0 and not PedIsDead(ped.id) then
            PedWander(ped.id, 0)
            PedMakeAmbient(ped.id)
        end
    end
    for i, ped in tblTarget02 do
        if ped.id ~= 0 and not PedIsDead(ped.id) then
            PedWander(ped.id, 0)
            PedMakeAmbient(ped.id)
        end
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
