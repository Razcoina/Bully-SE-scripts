local Petey = -1
local Beatrice = -1
local PeteyBlip = 0
local PeX, PeY, PeZ = -514.286, 318.547, 31.465
local BeX, BeY, BeZ = 276.5, -36.2, 6.2
local TrX, TrY, TrZ = -502.246, 318.4, 31.46
local TrRadius = 3.75
local camX, camY, camZ = 0, 0, 0
local tarX, tarY, tarZ = 0, 0, 0
local bReturnCam = false
local GreetingComplete = false
local DialogComplete = false
local AcceptScenario = false
local GoalsCreated = false
local ObjectiveMet = false
local MissionScenarioComplete = false
local bActive = false
local bClockPaused = false
local peds = {
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

function MissionSetup()
    MissionDontFadeIn()
    PedSetUniqueModelStatus(134, 1)
end

function F_LoadModels()
    while not PedRequestModel(134) do
        Wait(0)
    end
    while not PedRequestModel(3) do
        Wait(0)
    end
end

function main()
    DisablePOI()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    PedClearPOIForAllPeds()
    AreaClearAllPeds()
    F_LoadModels()
    if ClockIsPaused() then
        bClockPaused = true
    end
    --print("CLOCK IS PAUSED: ", tostring(bClockPaused))
    --print("CLOCK IS PAUSED: ", tostring(bClockPaused))
    --print("CLOCK IS PAUSED: ", tostring(bClockPaused))
    PauseGameClock()
    PeteyBlip = BlipAddXYZ(PeX, PeY, PeZ, 1)
    --print("==== Made it into trigger. ====")
    F_SetupErrand()
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
    if not ObjectiveMet then
        MinigameSetErrandCompletion(-1, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        MissionFail(false, false)
    end
end

function F_CheckConditions()
    if MissionActive() and ObjectiveMet == false then
        if PedIsValid(Beatrice) and (F_PedIsDead(Beatrice) or PedGetWhoHitMeLast(Beatrice) == gPlayer) then
            MinigameSetErrandCompletion(-1, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            MissionFail(false, false)
            return false
        end
        if PedIsValid(Petey) and PedIsDead(Petey) then
            MinigameSetErrandCompletion(-1, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            MissionFail(false, false)
            return false
        end
        if bActive == false and AreaGetVisible() ~= 14 then
            MinigameSetErrandCompletion(-1, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            MissionFail(false, false)
            return false
        end
        return true
    else
        return false
    end
end

function F_SetupErrand()
    if AreaGetVisible() ~= 14 then
        return
    end
    PlayerSetControl(0)
    local weapon = PedGetWeapon(gPlayer)
    if weapon == 359 then
        PedDestroyWeapon(gPlayer, weapon)
    end
    F_MakePlayerSafeForNIS(true)
    AreaClearAllPeds()
    DoSocialErrands(false, "AS_PETEY_OBJECTIVE")
    BlipRemove(PeteyBlip)
    Petey = PedCreateXYZ(134, PeX, PeY, PeZ)
    PlayerSetPosSimple(-499.8, 318.3, 31.4)
    PedFaceObject(Petey, gPlayer, 2, 0)
    PedSetPedToTypeAttitude(Petey, 13, 2)
    PedSetFlag(Petey, 110, true)
    PedSetFlag(Petey, 108, true)
    PedSetFlag(Petey, 19, true)
    PedIgnoreStimuli(Petey, true)
    PeteyBlip = AddBlipForChar(Petey, 6, 1, 4)
    camX, camY, camZ = -499.713, 318, 33.207
    tarX, tarY, tarZ = PlayerGetPosXYZ()
    PedSetFlag(gPlayer, 2, false)
    PlayerSocialDisableActionAgainstPed(Petey, 28, true)
    PlayerSocialDisableActionAgainstPed(Petey, 29, true)
    PlayerSocialDisableActionAgainstPed(Petey, 35, true)
    PedClearPOIForAllPeds()
    AreaClearAllPeds()
    local x, y, z = PlayerGetPosXYZ()
    local bool = false
    bool, peds[1], peds[2], peds[3], peds[4], peds[5], peds[6], peds[7], peds[8], peds[9], peds[10], peds[11], peds[12], peds[13], peds[14] = PedFindInAreaXYZ(x, y, z, 50)
    if bool then
        for p, ped in peds do
            if PedIsValid(ped) and not PedIsModel(ped, 0) and not PedIsModel(ped, 134) then
                PedDelete(ped)
            end
        end
    end
    CameraSetXYZ(-510.8904, 317.7711, 33.16423, -511.8485, 318.01633, 33.01734)
    CameraFade(500, 1)
    Wait(501)
    PedFaceObject(gPlayer, Petey, 2, 0)
    Wait(500)
    TutorialShowMessage("TUT_ERR1", 4500, false)
    Wait(5000)
    TutorialShowMessage("TUT_ERR2", 4500, false)
    Wait(5000)
    PedMoveToObject(Petey, gPlayer, 2, 1, nil, 2)
    bReturnCam = true
    Wait(0)
end

function F_OnGreeting()
    --print("F_OnGreeting")
    if PedIsDoingTask(Petey, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen", false) == true then
        F_MakePlayerSafeForNIS(false)
        PlayerSetControl(1)
        PlayerLockButtonInputsExcept(true, 10)
        TutorialShowMessage("TUT_ERR3", -1, false)
        return true
    else
        if bReturnCam and PlayerIsInAreaObject(Petey, 2, 12, 0) then
            CameraSetXYZ(-496.71188, 317.6883, 33.327457, -497.6915, 317.80115, 33.161316)
        end
        return false
    end
end

function F_OnDialog()
    if PedIsDoingTask(Petey, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        TutorialRemoveMessage()
        SoundPlayAmbientSpeechEvent(Petey, "HELP_EXPLANATION")
        Wait(500)
        TutorialShowMessage("TUT_ERR4", 4500, false)
        Wait(5000)
        TutorialRemoveMessage()
        Wait(500)
        PlayerLockButtonInputsExcept(true, 10, 7)
        PlayerSocialDisableActionAgainstPed(Petey, 35, false)
        PedIgnoreStimuli(Petey, false)
        TutorialShowMessage("TUT_ERR5", -1, false)
        return true
    else
        return false
    end
end

function F_AcceptScenario()
    if PedIsDoingTask(Petey, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted", true) == true then
        bActive = true
        PlayerSetControl(0)
        TutorialRemoveMessage()
        PedMakeMissionChar(Petey)
        BlipRemove(PeteyBlip)
        PedLockTarget(gPlayer, Petey, 3)
        PedLockTarget(Petey, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_SCH_Tutorial2", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_SCH_Tutorial2", true) do
            Wait(0)
        end
        PedLockTarget(gPlayer, -1)
        PedLockTarget(Petey, -1)
        CameraReturnToPlayer(false)
        GiveItemToPlayer(521, 1)
        TutorialShowMessage("TUT_ERR6", 4500, false)
        DoSocialErrands(true, "AS_PETEY_OBJECTIVE")
        ScenarioBlip = BlipAddXYZ(BeX, BeY, BeZ, 1)
        Wait(2000)
        AreaSetDoorLocked("DT_DormExitDoorL", false)
        AreaSetDoorLockedToPeds("DT_DormExitDoorL", false)
        PlayerSetControl(1)
        EnablePOI()
        AreaRevertToDefaultPopulation()
        return true
    else
        return false
    end
end

function F_ScenarioGoals()
    if AreaGetVisible() == 0 then
        Beatrice = PedCreateXYZ(3, BeX, BeY, BeZ)
        PedFaceObjectNow(Beatrice, gPlayer, 2)
        BlipRemove(ScenarioBlip)
        ScenarioBlip = AddBlipForChar(Beatrice, 0, 1, 4)
        return true
    else
        return false
    end
end

function F_MissionSpecificCheck()
    return true
end

function F_ObjectiveMet()
    if PedIsInAreaObject(gPlayer, Beatrice, 2, 3, 0) and PedGetFlag(gPlayer, 1) then
        PedSetInvulnerable(Beatrice, true)
        MissionTimerStop()
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedMoveToObject(gPlayer, Beatrice, 2, 0)
        while not PlayerIsInAreaObject(Beatrice, 2, 1, 0) do
            Wait(0)
        end
        PedStop(gPlayer)
        PedLockTarget(gPlayer, Beatrice, 3)
        PedLockTarget(Beatrice, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_SCH_Tutorial", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_SCH_Tutorial", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(Beatrice, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_COMPLETE", true, 500)
        PedSetFlag(Petey, 110, false)
        PedClearPOI(Petey)
        BlipRemove(ScenarioBlip)
        DoSocialErrands(false)
        PedSetInvulnerable(Beatrice, false)
        MissionSucceed(false, false, false)
        return true
    else
        return false
    end
end

function MissionCleanup()
    --print("====== Ending Errand Tutorial =====")
    DoSocialErrands(false)
    AreaRevertToDefaultPopulation()
    EnablePOI()
    AreaSetDoorLocked("DT_DormExitDoorL", false)
    AreaSetDoorLockedToPeds("DT_DormExitDoorL", false)
    PedSetUniqueModelStatus(134, -1)
    PlayerSetControl(1)
    if IsMissionAvailable("1_11x1") then
        shared.lockClothingManager = true
    end
    if PedIsValid(Peter) then
        PedMakeAmbient(Peter, false)
    end
    if PedIsValid(Beatrice) then
        PedMakeAmbient(Beatrice, false)
    end
    ItemSetCurrentNum(521, 0)
    BlipRemove(ScenarioBlip)
    BlipRemove(PeteyBlip)
    --print("CLOCK IS PAUSED: ", tostring(bClockPaused))
    --print("CLOCK IS PAUSED: ", tostring(bClockPaused))
    --print("CLOCK IS PAUSED: ", tostring(bClockPaused))
    if not bClockPaused then
        UnpauseGameClock()
    end
    bClockPaused = false
    CameraSetWidescreen(false)
end
