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
local AcceptScenario = false
local peds = { 69 }
local bActive = false
local currentArea = 0
local timeLimit = 120
local timeInMinutes = 2
local ObjFlag = false
local MissionScenarioComplete = false
local cannedCurrentCount = 0
local cannedLastCount = 0
local cannedGoal = 3
local downCount = cannedGoal
local bTimeNotSet = true
local bPlayerCanneding = false
local bCurrentTargetNotCanneded = true
local lastPed = 0
local currentPed = 0
local bFoundVic = false
local bToldToGoBack = true
local tblDeadPool = {}
local vic = 0
local vics = {}

function main()
    --print("()xxxxx[:::::::::::::::> CANNING [start] main()")
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
        if OutOfRange == true or POIInfo == nil then
            break
        end
        Wait(0)
    end
    F_ScenarioCleanup()
    --print("()xxxxx[:::::::::::::::> CANNING [finish] main()")
end

function F_ScenarioSetup()
    --print("()xxxxx[:::::::::::::::> CANNING [start] F_ScenarioSetup()")
    DoSocialErrands(false, "AS_CN_OBJECTIVE", cannedGoal)
    currentArea = AreaGetVisible()
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(69, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(69, POIInfo)
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
    --print("()xxxxx[:::::::::::::::> CANNING [finish] F_ScenarioSetup()")
end

function F_PlayerOutOfRange()
    local x1, y1, z1 = POIGetPosXYZ(POIInfo)
    local x2, y2, z2 = PlayerGetPosXYZ()
    if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > AreaGetPopulationCullDistance() or currentArea ~= AreaGetVisible() then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 45000
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 81, "generic", false, true)
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
        DoSocialErrands(true, "AS_CN_OBJECTIVE", cannedGoal)
        PedSetStationary(ScenarioPed, true)
        bOnMission = true
        BlipRemove(ScenarioPedBlip)
        for i = 1, 20 do
            table.insert(tblDeadPool, 0)
        end
        vics = {
            0,
            0,
            0,
            0,
            0,
            0
        }
        Wait(1000)
        bActive = true
        bTimeNotSet = true
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
    return true
end

function F_MissionSpecificCheck()
    if cannedCurrentCount == cannedGoal then
        return true
    else
        if not bPlayerCanneding and PedIsPlaying(gPlayer, "/Global/Garbagecan/PedPropsActions/StuffGrap/GIVE", false) then
            bPlayerCanneding = true
            peds, vics[1], vics[2], vics[3], vics[4], vics[5], vics[6] = PedFindInAreaObject(gPlayer, 1.5)
        elseif bPlayerCanneding and not bFoundVic then
            if peds then
                for i, ped in vics do
                    if ped ~= 0 then
                        --print("==== Non Zero Ped ====")
                        if PedIsValid(ped) and not PedIsDead(ped) and ped ~= gPlayer and PedIsPlaying(ped, "/Global/Garbagecan/PedPropsActions/StuffGrap/RCV", false) then
                            --print("==== Non Zero Ped ====", ped)
                            vic = ped
                            bFoundVic = true
                            break
                        end
                    end
                end
            end
        elseif bPlayerCanneding and not PedIsPlaying(gPlayer, "/Global/Garbagecan/PedPropsActions/StuffGrap/GIVE", false) then
            local bAlreadyDone = false
            for i, dude in tblDeadPool do
                --print("=== tblDeadPool dude vs ped ====", dude, vic)
                if dude ~= 0 and dude == vic then
                    bAlreadyDone = true
                    break
                end
            end
            if bAlreadyDone then
                DoSocialErrands(true, "AS_CN_REPEAT")
            else
                cannedCurrentCount = cannedCurrentCount + 1
                table.insert(tblDeadPool, cannedCurrentCount, vic)
                downCount = downCount - 1
                if 0 < downCount then
                    if downCount == 1 then
                        DoSocialErrands(true, "AS_CN_OBJCOUNT1", downCount)
                    else
                        DoSocialErrands(true, "AS_CN_OBJECTIVE", downCount)
                    end
                end
                CounterSetCurrent(cannedCurrentCount)
            end
            vics = {
                0,
                0,
                0,
                0,
                0,
                0
            }
            bFoundVic = false
            bPlayerCanneding = false
        end
        return false
    end
end

function F_ObjectiveMet()
    DoSocialErrands(false)
    MinigameSetErrandCompletion(6, "AS_COMPLETE", true, 1500)
    shared.gCurrentAmbientScenarioObject.completed = true
    shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    PedSetScenarioObjFlag(ScenarioPed, true)
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
            MinigameSetErrandCompletion(6, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    --print("()xxxxx[:::::::::::::::> CANNING [start] F_ScenarioCleanup()")
    DoSocialErrands(false)
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedMakeAmbient(ScenarioPed)
        PedWander(ScenarioPed, 0)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 45000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
    --print("()xxxxx[:::::::::::::::> CANNING [finish] F_ScenarioCleanup()")
end
