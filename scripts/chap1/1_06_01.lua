--[[ Changes to this file:
    * Heavily modified function F_SetupActions, requires testing
    * Modified function F_AchieveReceiver, may require testing
    * Modified function F_SetupNextMove, may require testing
    * Modified function F_MissionStageHoboFight, may require testing
]]

local gNumTransis = 0
local gGaryBlip, gPeteBlip, gGary, gPete
local gObjectives = {}
local nCurrentMission = 1
local gActions = {}
local gCurrentMove = 1
local gMoveSucceed = 0
local gMaxSucceedCount = 3
local gTotalMoves = 0
local gSequenceFailed = false
local gSequencePassed = false
local gButtonCorrect = false
local gUnlockName = -1
local gPlayerMoved = true
local gPassedFirstLevel = false
local gLastStage = 8
local gConditions = {
    "/Global/Actions/Grapples/Front/Grapples/Hold_Idle/GIVE",
    "/Global/Player"
}
local gButtons = {
    16,
    17,
    18,
    19,
    10,
    12,
    11,
    13,
    14,
    15,
    7,
    9,
    6,
    8
}

function MissionSetup()
    MissionDontFadeIn()
    ButtonHistoryEnableActionTreeInput(true)
    AreaSetDoorPathableToPeds(TRIGGER._BUSDOORS, true)
end

function MissionCleanup()
    PedLockTarget(gPlayer, -1)
    DisablePunishmentSystem(false)
    AreaSetDoorPathableToPeds(TRIGGER._BUSDOORS, false)
    ButtonHistoryEnableActionTreeInput(false)
    if not shared.hoboGateIndex then
        shared.hoboGateIndex, shared.hoboGateObject = CreatePersistentEntity("1_06_GateClosed", 165.967, 18.8144, 7.31457, 0, 0)
    end
    UnLoadAnimationGroup("DO_Striker")
    UnLoadAnimationGroup("DO_StrikeCombo")
    UnLoadAnimationGroup("Boxing")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    UnLoadAnimationGroup("Hobo_Cheer")
    UnLoadAnimationGroup("NPC_Adult")
    PAnimCloseDoor(TRIGGER._BUSDOORS)
    UnpauseGameClock()
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    PedStop(gPlayer)
    if not gPlayerMoved or PlayerIsInTrigger(TRIGGER._FINALPOSCHECK) then
        PlayerSetPosPoint(POINTLIST._ENDING, 1)
    end
    gMonitoringHealth = false
    ButtonHistoryIgnoreController(false)
    if nCurrentMission == 1 and not gMissionCompleted then
        ItemSetCurrentNum(476, 0)
        CollectiblesSetTypeAvailable(1, false)
        CollectiblesSetAllAsCollected(1, false)
    end
    PedSetUniqueModelStatus(87, -1)
    ToggleHUDComponentVisibility(4, true)
    ToggleHUDComponentVisibility(5, true)
    ToggleHUDComponentVisibility(11, true)
    ToggleHUDComponentVisibility(0, true)
    ToggleHUDComponentVisibility(0, true)
    ToggleHUDComponentVisibility(21, false)
    PedLockTarget(gPlayer, -1)
    AreaRevertToDefaultPopulation()
    CounterMakeHUDVisible(false, false)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    SoundStopInteractiveStream()
    SoundEnableInteractiveMusic(true)
    PlayerWeaponHudLock(false)
    CameraAllowChange(true)
    CameraReturnToPlayer()
    PlayerIgnoreTargeting(false)
    DATUnload(2)
    PedHideHealthBar()
end

function main()
    while not bStageLoaded do
        Wait(0)
    end
    if nCurrentMission == 1 then
        PlayCutsceneWithLoad("1-06", true)
    end
    DATLoad("1_06.DAT", 2)
    DATInit()
    LoadActionTree("Act/Conv/1_06.act")
    LoadAnimationGroup("DO_Striker")
    LoadAnimationGroup("DO_StrikeCombo")
    LoadAnimationGroup("Boxing")
    LoadAnimationGroup("NPC_AggroTaunt")
    LoadAnimationGroup("Hobo_Cheer")
    LoadAnimationGroup("NPC_Adult")
    LoadPedModels({
        134,
        130,
        87
    })
    LoadWeaponModels({ 379 })
    if nCurrentMission == 1 then
        LoadAnimationGroup("MINI_React")
        AreaTransitionPoint(0, POINTLIST._BEGGINING, 3, true)
        gMonitorAllies = true
        gGary = PedCreatePoint(130, POINTLIST._BEGGINING, 1)
        gPete = PedCreatePoint(134, POINTLIST._BEGGINING, 2)
        gGaryBlip = AddBlipForChar(gGary, 6, 2, 1)
        gPeteBlip = AddBlipForChar(gPete, 6, 2, 1)
        PedSetInfiniteSprint(gGary, true)
        PedSetInfiniteSprint(gPete, true)
        PedRecruitAlly(gPlayer, gGary)
        PedRecruitAlly(gGary, gPete)
        PedShowHealthBar(gGary, true, "1_06_GARY", false, gPete, "1_06_PETE")
        gNumTransis = ItemGetCurrentNum(476)
    end
    if nCurrentMission == 1 then
        F_FirstMission()
    else
        local totalRadios = ItemGetCurrentNum(476)
        totalRadios = totalRadios - 1
        if totalRadios < 0 then
            totalRadios = 0
        end
        ItemSetCurrentNum(476, totalRadios)
        gMissionFunction = F_GoMeetWithHobo
    end
    gMissionRunning = true
    while gMissionRunning do
        if gMonitorAllies then
            if F_PedIsDead(gGary) then
                gMissionFailMessage = "1_06_GARYKO"
                gMissionFail = true
            elseif F_PedIsDead(gPete) then
                gMissionFail = true
                gMissionFailMessage = "1_06_PETEKO"
            end
        end
        gMissionFunction()
        if gMissionFail then
            Wait(1000)
            if gHoboDied and PedIsValid(gHobo) and not PedIsDead(gHobo) then
                PlayerSetControl(0)
                PedSetActionNode(gHobo, "/Global/1_06/HoboIdleCycle", "Act/Conv/1_06.act")
                PedSetActionNode(gPlayer, "/Global/1_06/Failure", "Act/Conv/1_06.act")
                SoundPlayScriptedSpeechEvent(gHobo, "SEE_SOMETHING_CRAP", 0, "jumbo")
            end
            SoundPlayMissionEndMusic(false, 10)
            if gMissionFailMessage then
                MissionFail(true, true, gMissionFailMessage)
            else
                MissionFail(true)
            end
            gMissionRunning = false
        end
        Wait(0)
    end
end

function F_FirstMission()
    PlayerSetPosPoint(POINTLIST._BEGGINING, 3)
    Wait(1000)
    PedSetPosPoint(gGary, POINTLIST._BEGGINING, 1)
    PedSetPosPoint(gPete, POINTLIST._BEGGINING, 2)
    CameraReset()
    CameraReturnToPlayer()
    PedSetMissionCritical(gGary, true, CB_GaryDied, false)
    PedSetMissionCritical(gPete, true, CB_PeteDied, false)
    GameSetPedStat(gGary, 6, 0)
    GameSetPedStat(gPete, 6, 90)
    CameraFade(500, 1)
    Wait(500)
    gMissionFunction = F_SetupRoutingToHobo
end

function T_GarySpeech()
    if not PedIsDead(gGary) then
        F_PlaySpeechAndWait(gGary, "M_1_06_01", 1, "jumbo")
    end
    if not PedIsDead(gPete) then
        F_PlaySpeechAndWait(gPete, "M_1_06_01", 2, "jumbo")
    end
    if not PedIsDead(gGary) then
        F_PlaySpeechAndWait(gGary, "M_1_06_01", 3, "jumbo")
    end
    if not PedIsDead(gPete) then
        F_PlaySpeechAndWait(gPete, "M_1_06_01", 4, "jumbo")
    end
    if not PedIsDead(gGary) then
        F_PlaySpeechAndWait(gGary, "M_1_06_01", 5, "jumbo")
    end
end

function F_SetupRoutingToHobo()
    table.insert(gObjectives, MissionObjectiveAdd("1_06_OBJ01"))
    TextPrint("1_06_OBJ01", 3, 1)
    gObjBlip = BlipAddPoint(POINTLIST._1_06BEGIN, 0, 2, 1)
    CreateThread("T_GarySpeech")
    if shared.hoboGateIndex then
        DeletePersistentEntity(shared.hoboGateIndex, shared.hoboGateObject)
        shared.hoboGateIndex = nil
        shared.hoboGateObject = nil
    end
    gMissionFunction = F_RoutingToHobo
end

function F_RoutingToHobo()
    if PlayerIsInTrigger(TRIGGER._FIGHTINGAREA) then
        PlayerSetControl(0)
        UnLoadAnimationGroup("DO_Striker")
        UnLoadAnimationGroup("DO_StrikeCombo")
        UnLoadAnimationGroup("Boxing")
        UnLoadAnimationGroup("NPC_AggroTaunt")
        gMonitorAllies = false
        PedSetMissionCritical(gPete, false)
        PedSetMissionCritical(gGary, false)
        CameraFade(-1, 0)
        Wait(FADE_OUT_TIME)
        PedDelete(gPete)
        PedDelete(gGary)
        BlipRemove(gGaryBlip)
        BlipRemove(gPeteBlip)
        MissionObjectiveComplete(gObjectives[1])
        ModelNotNeeded(134)
        ModelNotNeeded(130)
        CollectiblesSetTypeAvailable(1, true)
        PlayCutsceneWithLoad("1-06B", true)
        SoundStopInteractiveStream(0)
        SoundPlayInteractiveStream("MS_SearchingLow.rsm", MUSIC_DEFAULT_VOLUME)
        SoundSetMidIntensityStream("MS_SearchingMid.rsm", MUSIC_DEFAULT_VOLUME)
        SoundSetHighIntensityStream("MS_SearchingHigh.rsm", 0.7)
        LoadAnimationGroup("DO_Striker")
        LoadAnimationGroup("DO_StrikeCombo")
        LoadAnimationGroup("Boxing")
        LoadAnimationGroup("NPC_AggroTaunt")
        CameraSetWidescreen(false)
        PlayerSetControl(1)
        gHobo = PedCreatePoint(87, POINTLIST._1_06BEGIN, 1)
        PedSetMissionCritical(gHobo, true, F_CriticalPedDied, true)
        PedSetEmotionTowardsPed(gHobo, gPlayer, 7)
        PlayerSetPosPoint(POINTLIST._AFTERCUTSCENE, 1)
        PedLockTarget(gHobo, gPlayer, 3)
        PedFaceObject(gHobo, gPlayer, 3, 1, false)
        PlayerSocialDisableActionAgainstPed(gHobo, 29, true)
        PlayerSocialDisableActionAgainstPed(gHobo, 28, true)
        PedSetFlag(gHobo, 129, true)
        CameraReset()
        CameraReturnToPlayer()
        PedHideHealthBar()
        PedSetAsleep(gHobo, true)
        PedSetStationary(gHobo, true)
        CameraFade(500, 1)
        Wait(500)
        gMissionFunction = F_SetupAchieveReceiver
    end
end

function F_SetupAchieveReceiver()
    TextPrint("1_06_OBJ02", 5, 1)
    CreateThread("T_TransForFight1")
    BlipRemove(gObjBlip)
    gPlayerState = 0
    gCoronaBlip = BlipAddPoint(POINTLIST._STAIRCORONA, 0, 1, 1, 7)
    sX, sY, sZ = GetPointList(POINTLIST._STAIRCORONA)
    table.insert(gObjectives, MissionObjectiveAdd("1_06_OBJ02"))
    gAchieveReveiverTime = GetTimer()
    gMissionFunction = F_AchieveReceiver
end

function T_TransForFight1()
    Wait(1500)
    TutorialShowMessage("TUT_TRANX01", 4500, false)
    Wait(4500)
    collectgarbage()
end

function F_AchieveReceiver() -- ! Modified
    if not gMissionFail then
        if ItemGetCurrentNum(476) > 0 then
            if gObjBlip then
                BlipRemove(gObjBlip)
                gObjBlip = nil
            end
            if gObjBlipHigh then
                BlipRemove(gObjBlipHigh)
                gObjBlipHigh = nil
            end
            if gCoronaBlip then
                BlipRemove(gCoronaBlip)
            end
            --Wait(5000)
            gObjBlip = AddBlipForChar(gHobo, 9, 17, 4)
            MissionObjectiveComplete(gObjectives[2])
            table.insert(gObjectives, MissionObjectiveAdd("1_06_OBJ03"))
            TextPrint("1_06_OBJ03", 5, 1)
            PedStop(gHobo)
            PedClearObjectives(gHobo)
            PedFaceObject(gHobo, gPlayer, 3, 1, false)
            F_Socialize(gHobo, true)
            gMissionFunction = F_GoMeetWithHobo
        elseif gPlayerState == 0 then
            if PlayerIsInTrigger(TRIGGER._LOWCORONA) and PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions", true) then
                if gCoronaBlip then
                    BlipRemove(gCoronaBlip)
                end
                gObjBlipHigh = BlipAddPoint(POINTLIST._TRANSMITTERBLIP, 29, 2, 1)
                gPlayerState = 1
            elseif PlayerIsInTrigger(TRIGGER._HIGHGROUND) then
                if gCoronaBlip then
                    BlipRemove(gCoronaBlip)
                end
                gObjBlip = BlipAddPoint(POINTLIST._TRANSMITTERBLIP, 0, 2, 1)
                gPlayerState = 2
            end
        elseif gPlayerState == 1 then
            if not PlayerIsInTrigger(TRIGGER._LOWCORONA) and not PlayerIsInTrigger(TRIGGER._HIGHGROUND) then
                if gObjBlipHigh then
                    BlipRemove(gObjBlipHigh)
                end
                gCoronaBlip = BlipAddPoint(POINTLIST._STAIRCORONA, 0, 1, 1, 7)
                gPlayerState = 0
            elseif PlayerIsInTrigger(TRIGGER._HIGHGROUND) then
                if gObjBlipHigh then
                    BlipRemove(gObjBlipHigh)
                end
                gObjBlip = BlipAddPoint(POINTLIST._TRANSMITTERBLIP, 0, 2, 1)
                gPlayerState = 2
            end
        elseif gPlayerState == 2 then
            if not PlayerIsInTrigger(TRIGGER._LOWCORONA) and not PlayerIsInTrigger(TRIGGER._HIGHGROUND) then
                if gObjBlip then
                    BlipRemove(gObjBlip)
                end
                gCoronaBlip = BlipAddPoint(POINTLIST._STAIRCORONA, 0, 1, 1, 7)
                gPlayerState = 0
            elseif PlayerIsInTrigger(TRIGGER._LOWCORONA) and PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions", true) then
                if gObjBlip then
                    BlipRemove(gObjBlip)
                end
                gObjBlipHigh = BlipAddPoint(POINTLIST._TRANSMITTERBLIP, 29, 2, 1)
                gPlayerState = 1
            end
        end
        if PlayerIsInAreaObject(gHobo, 2, 5, 0) and GetTimer() - gAchieveReveiverTime > 7000 then
            SoundPlayScriptedSpeechEvent(gHobo, "M_1_06_01", 33, "jumbo")
            gAchieveReveiverTime = GetTimer()
        end
        if not PAnimIsOpen(TRIGGER._BUSDOORS) then
            PAnimOpenDoor(TRIGGER._BUSDOORS)
        end
    end
end

function F_GoMeetWithHobo()
    if nCurrentMission ~= 1 then
        AreaTransitionPoint(0, POINTLIST._1_06BEGIN, 5)
        gHobo = PedCreatePoint(87, POINTLIST._1_06BEGIN, 1)
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        F_MakePlayerSafeForNIS(true)
        CameraReset()
        CameraReturnToPlayer()
        PedSetEmotionTowardsPed(gHobo, gPlayer, 7)
        PedFaceObject(gHobo, gPlayer, 3, 0)
        PedFaceObject(gPlayer, gHobo, 2, 0)
        PedSetFlag(gHobo, 129, true)
        CameraFade(-1, 1)
        PedLockTarget(gPlayer, gHobo, 3)
        PedSetActionNode(gPlayer, "/Global/1_06/1_06_Give/Give/GiveHobo_1_06", "Act/Conv/1_06.act")
        Wait(1000)
        SoundPlayScriptedSpeechEvent(gHobo, "M_1_06_01", 12, "large")
        while PedIsPlaying(gPlayer, "/Global/1_06/1_06_Give/Give/GiveHobo_1_06", true) do
            Wait(0)
        end
        PedStopSocializing(gHobo)
        PedFaceObject(gHobo, gPlayer, 3, 0)
        PedFaceObject(gPlayer, gHobo, 2, 0)
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        Wait(1500)
        PedSetMissionCritical(gHobo, false)
        hx, hy, hz = PedGetPosXYZ(gHobo)
        PedDelete(gHobo)
        F_MakePlayerSafeForNIS(false)
        gOriginalHealth = PedGetHealth(gHobo)
        gReachedTheHobo = true
        gMissionFunction = F_SetupMissionStageHoboFight
    elseif PlayerIsInAreaObject(gHobo, 2, 2, 0) then
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        F_MakePlayerSafeForNIS(true)
        PedSetPedToTypeAttitude(gHobo, 13, 3)
        PedClearHasAggressed(gPlayer)
        PedSetAsleep(gHobo, false)
        PedSetStationary(gHobo, false)
        PedStop(gHobo)
        PedSetMissionCritical(gHobo, false)
        PedClearObjectives(gHobo)
        PedFaceObject(gHobo, gPlayer, 3, 1)
        PedFaceObject(gPlayer, gHobo, 2, 1)
        PedLockTarget(gPlayer, gHobo, 3)
        local totalRadios = ItemGetCurrentNum(476)
        totalRadios = totalRadios - 1
        if totalRadios < 0 then
            totalRadios = 0
        end
        ItemSetCurrentNum(476, totalRadios)
        PedClearObjectives(gHobo)
        PedSetActionNode(gPlayer, "/Global/1_06/1_06_Give/Give/GiveHobo_1_06", "Act/Conv/1_06.act")
        Wait(1000)
        SoundPlayScriptedSpeechEvent(gHobo, "THANKS_JIMMY", 0, "large")
        while PedIsPlaying(gPlayer, "/Global/1_06/1_06_Give/Give/GiveHobo_1_06", true) do
            Wait(0)
        end
        while SoundSpeechPlaying(gPlayer) do
            Wait(0)
        end
        PedStopSocializing(gHobo)
        MissionObjectiveComplete(gObjectives[3])
        BlipRemove(gObjBlip)
        PedFaceObject(gHobo, gPlayer, 3, 0)
        PedFaceObject(gPlayer, gHobo, 2, 0)
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        Wait(1500)
        hx, hy, hz = PedGetPosXYZ(gHobo)
        PedDelete(gHobo)
        F_MakePlayerSafeForNIS(false)
        gOriginalHealth = PedGetHealth(gHobo)
        gReachedTheHobo = true
        gMissionFunction = F_SetupMissionStageHoboFight
    end
    if not PAnimIsOpen(TRIGGER._BUSDOORS) then
        PAnimOpenDoor(TRIGGER._BUSDOORS)
    end
end

function F_SetupMissionStageHoboFight()
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    CameraSetWidescreen(true)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    PauseGameClock()
    ToggleHUDComponentVisibility(4, false)
    ToggleHUDComponentVisibility(5, false)
    ToggleHUDComponentVisibility(11, false)
    ToggleHUDComponentVisibility(0, false)
    if IsMissionFromDebug() then
        AreaTransitionPoint(0, POINTLIST._1_06BEGIN, 2)
    else
        PlayerSetPosPoint(POINTLIST._1_06BEGIN, 2)
    end
    AreaClearAllPeds()
    if hx then
        gHobo = PedCreateXYZ(87, hx, hy, hz)
    else
        gHobo = PedCreatePoint(87, POINTLIST._1_06BEGIN, 1)
    end
    PedSetMinHealth(gHobo, 100)
    PedSetFlag(gHobo, 129, true)
    gPlayerMoved = false
    PlayerUnequip()
    PedClearWeapon(gPlayer, PedGetWeapon(gPlayer))
    PedFaceObject(gPlayer, gHobo, 2, 0)
    PedFaceObject(gHobo, gPlayer, 2, 0)
    PedSetCombatZoneMask(gHobo, true, true, false)
    if not shared.hoboGateIndex then
        shared.hoboGateIndex, shared.hoboGateObject = CreatePersistentEntity("1_06_GateClosed", 165.967, 18.8144, 7.31457, 0, 0)
    end
    while WeaponEquipped() do
        PlayerUnequip()
        Wait(0)
    end
    PlayerWeaponHudLock(true)
    ObjectRemovePickupsInTrigger(TRIGGER._FIGHTINGAREA)
    PedOverrideStat(gHobo, 38, 100)
    PedOverrideStat(gHobo, 39, 100)
    LoadActionTree("Act/Anim/Hobo_Blocker.act")
    CameraLookAtXYZ(157.27258, 21.92584, 7.0297775, true)
    CameraSetPath(PATH._FIGHTCUT, true)
    CameraSetSpeed(4, 4, 4)
    CameraFade(500, 1)
    Wait(500)
    if 1 < nCurrentMission then
        F_PlaySpeechAndWait(gHobo, "M_1_06_01", 12)
    end
    PedSetAsleep(gHobo, false)
    gLastInstructions = GetTimer()
    GameSetPedStat(gHobo, 12, 100)
    GameSetPedStat(gHobo, 8, 0)
    PedSetHealth(gHobo, 5000)
    table.insert(gObjectives, MissionObjectiveAdd("1_06_OBJ04_LG"))
    PedSetActionTree(gHobo, "/Global/Hobo_Blocker", "Act/Anim/Hobo_Blocker.act")
    PedRestrictToTrigger(gHobo, TRIGGER._RINGAREA)
    PedSetTetherMoveToCenter(gHobo, true)
    PedSetInvulnerableToPlayer(gHobo, false)
    PedSetPedToTypeAttitude(gHobo, 3, 0)
    gFailTimer = GetTimer()
    F_SetupActions(nCurrentMission)
    gCurrentMove = 1
    gMoveSucceed = 0
    gTotalMoves = gActions.gTotalMoves
    SoundPlayScriptedSpeechEvent(gHobo, "M_1_06_01", gActions.speech[gCurrentMove])
    if nCurrentMission <= 1 then
        Wait(2500)
    end
    PedAttack(gHobo, gPlayer, 3)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    DisablePunishmentSystem(true)
    CameraReturnToPlayer(false)
    Wait(1000)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    gMonitoringHealth = true
    CreateThread("T_MonitorHoboHealth")
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedLockTarget(gPlayer, gHobo)
    F_SetupNextMove()
    gHoboTrainingNow = true
    gMissionFunction = F_MissionStageHoboFight
end

function F_SetupNextMove() -- ! Modified
    if gConditions[gActions.condition] then
        if gActions.condition == 1 then
            ButtonHistoryIgnoreController(true)
            ButtonHistoryClearSequence()
            ToggleHUDComponentVisibility(21, true)
            ButtonHistoryAddSequence(9, false)
            ButtonHistoryAddSequenceLocalText("1_06_GRAPPLE")
            ButtonHistorySetSequenceTime(10)
            ButtonHistoryIgnoreController(false)
            while not PedIsPlaying(gPlayer, gConditions[gActions.condition], true) do
                Wait(0)
            end
        end
        --[[
        print("[RAUL] Waiting for:", gConditions[gActions.condition])
        while not PedIsPlaying(gPlayer, gConditions[gActions.condition], true) do
            Wait(0)
        end
        ]]
        ToggleHUDComponentVisibility(21, false)
    end
    gButtonCorrect = false
    ButtonHistoryIgnoreController(true)
    ButtonHistoryClearSequence()
    if not gIgnoresOff then
        ButtonHistoryIgnoreSequence(16, 17, 18, 19, 10, 11, 14, 12, 13, 15, 7, 9, 8)
    end
    ButtonHistorySetCallbackPassed(F_PassedCallback)
    ButtonHistorySetCallbackFailed(F_FailedCallback)
    ButtonHistorySetCallbackCorrectButton(F_CorrectButtonPressed)
    ToggleHUDComponentVisibility(21, true)
    ButtonHistorySetSequenceTime(10)
    ButtonHistoryAddSequenceLocalText(gActions.moveName[gCurrentMove])
    gUnlockName = gActions.moveUnlockName[gCurrentMove]
    local currentAction = gActions[gCurrentMove]
    for i, action in currentAction do
        if table.getn(action) == 2 then
            ButtonHistoryAddSequence(action[1], action[2])
        else
            ButtonHistoryAddSequenceTimeInterval(action[1], action[2], action[3])
        end
    end
    gSequencePassed = false
    ButtonHistoryIgnoreController(false)
end

function F_MissionStageHoboFight() -- ! Modified
    if gSequencePassed then
        while not PedIsPlaying(gPlayer, gConditions[gActions.condition], true) do
            Wait(0)
        end
        gMoveSucceed = gMoveSucceed + 1
        if gMoveSucceed >= gMaxSucceedCount then
            gMoveSucceed = 0
            gCurrentMove = gCurrentMove + 1
            gNewMove = true
            CameraSetWidescreen(true)
            PedSetFlag(gHobo, 129, true)
            Wait(1000)
            PlayerSetControl(0)
            PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
            ToggleHUDComponentVisibility(21, false)
        else
            SoundPlayScriptedSpeechEvent(gHobo, "M_1_06_01", 13)
        end
        Wait(1000)
        if gCurrentMove > gTotalMoves then
            gPassedFirstLevel = true
            if nCurrentMission == 1 then
                SoundFadeWithCamera(false)
                MusicFadeWithCamera(false)
            end
            gMonitoringHealth = false
            F_PlaySpeechAndWait(gHobo, "M_1_06_01", 32)
            CameraFade(-1, 0)
            --[[
            PedStop(gHobo)
            Wait(FADE_OUT_TIME + 500)
            ]] -- Removed this
            Wait(FADE_OUT_TIME)
            F_FirstMissionEndCutscene()
            PedStop(gPlayer)
            PedClearObjectives(gPlayer)
            PlayerSetPosPoint(POINTLIST._ENDING)
            gPlayerMoved = true
            gMissionRunning = false
            CameraReset()
            CameraReturnToPlayer()
            gMissionCompleted = true
            MissionSucceed(true, false, false)
            PlayerSetControl(1)
        else
            if gNewMove then
                F_PlaySpeechAndWait(gHobo, "M_1_06_01", gActions.speech[gCurrentMove])
                gNewMove = false
                CameraSetWidescreen(false)
                PlayerSetControl(1)
            end
            F_SetupNextMove()
        end
    end
    if gSequenceFailed then
        if GetTimer() - gFailTimer > 5000 then
            SoundPlayScriptedSpeechEvent(gHobo, "M_1_06_01", 14)
            gFailTimer = GetTimer()
        end
        gSequenceFailed = false
        F_SetupNextMove()
    end
end

function F_PassedCallback(button)
    --print("-----> [RAUL] Passed Callback called")
    gSequencePassed = true
    SoundPlay2D("RightBtn")
    ToggleHUDComponentVisibility(21, false)
end

function F_FailedCallback(button, timesUp)
    --print("{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{[")
    --print("-----> [RAUL] Failed Callback called", tostring(button), tostring(timesUp))
    ButtonHistoryIgnoreController(false)
    gSequenceFailed = true
end

function F_CorrectButtonPressed(button)
    gButtonCorrect = true
end

function F_GiveTransistorToHobo()
    bHoboReceivedTransistor = true
end

function F_SetupActions(stageNo) -- ! Heavily modified
    if stageNo == 1 then
        gActions = {
            {
                --{37, false}
                { 6, true }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 30 },
            moveUnlockName = {
                "1_06_MOVEUNLK01"
            },
            moveName = {
                "1_06_MOVE01"
            }
        }
    elseif stageNo == 2 then
        gActions = {
            {
                --{33, false},
                --{38, false}
                { 6, false },
                { 6, true }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 22 },
            moveUnlockName = {
                "1_06_MOVEUNLK02"
            },
            moveName = {
                "1_06_MOVE02"
            }
        }
    elseif stageNo == 3 then
        gActions = {
            {
                --[[
                {33, false},
                {32, false},
                {37, false}
                ]]
                { 6, false },
                { 6, false },
                { 6, true }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 28 },
            moveUnlockName = {
                "1_06_MOVEUNLK03"
            },
            moveName = {
                "1_06_MOVE03"
            }
        }
    elseif stageNo == 4 then
        gActions = {
            {
                --[[
                {33, false},
                {32, false},
                {33, false},
                {32, false},
                {33, false}
                ]]
                { 6, false },
                { 6, false },
                { 6, false },
                { 6, false },
                { 6, false }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 17 },
            moveUnlockName = {
                "1_06_MOVEUNLK05"
            },
            moveName = {
                "1_06_MOVE05"
            }
        }
    elseif stageNo == 7 then
        gActions = {
            {
                --[[
                {33, false},
                {32, false},
                {33, false},
                {38, false}
                ]]
                { 6, false },
                { 6, false },
                { 6, false },
                { 6, true }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 19 },
            moveUnlockName = {
                "1_06_MOVEUNLK08"
            },
            moveName = {
                "1_06_MOVE08"
            }
        }
        gOverrideVictory = true
    elseif stageNo == 8 then
        gActions = {
            {
                --[[
                {33, false},
                {32, false},
                {33, false},
                {32, false},
                {37, false}
                ]]
                { 6, false },
                { 6, false },
                { 6, false },
                { 6, false },
                { 6, true }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 18 },
            moveUnlockName = {
                "1_06_MOVEUNLK09"
            },
            moveName = {
                "1_06_MOVE09"
            }
        }
        gOverrideVictory = true
    elseif stageNo == 9 then
        gActions = {
            {
                { 7, false },
                { 7, false },
                { 6, false }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 22 },
            moveUnlockName = {
                "1_06_MOVEUNLK13"
            },
            moveName = {
                "1_06_MOVE13"
            }
        }
    elseif stageNo == 10 then
        gActions = {
            {
                { 7, false },
                { 7, false },
                --[[
                { 6, false }
                ]] -- Changed to:
                { 6, true }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 23 },
            moveUnlockName = {
                "1_06_MOVEUNLK14"
            },
            moveName = {
                "1_06_MOVE14"
            }
        }
    elseif stageNo == 11 then
        gActions = {
            {
                { 7, false },
                { 7, false },
                { 7, false },
                { 6, false }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 25 },
            moveUnlockName = {
                "1_06_MOVEUNLK15"
            },
            moveName = {
                "1_06_MOVE15"
            }
        }
    elseif stageNo == 12 then
        gActions = {
            {
                { 7, false },
                { 7, false },
                { 7, false },
                --{6, false}
                { 6, true }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 24 },
            moveUnlockName = {
                "1_06_MOVEUNLK16"
            },
            moveName = {
                "1_06_MOVE16"
            }
        }
    elseif stageNo == 13 then
        gActions = {
            {
                {
                    12,
                    --false,
                    true,
                    10
                },
                { 16, false }
            },
            {
                { 7, false },
                { 7, false },
                { 6, false },
                { 6, false }
            },
            {
                { 7, false },
                { 7, false },
                { 6, false },
                { 6, false }
            },
            gTotalMoves = 3,
            condition = 2,
            speech = { 18, 24 },
            moveUnlockName = {
                "1_06_MOVEUNLK17",
                "1_06_MOVEUNLK18"
            },
            moveName = {
                "1_06_MOVE17",
                "1_06_MOVE18"
            }
        }
        gIgnoresOff = true
    elseif stageNo == 14 then
        gActions = {
            {
                { 7, false },
                { 7, false },
                { 6, false },
                { 6, false }
            },
            gTotalMoves = 1,
            condition = 2,
            speech = { 31 },
            moveUnlockName = {
                "1_06_MOVEUNLK20"
            },
            moveName = {
                "1_06_MOVE20"
            }
        }
    end
end

function F_SetStage(param)
    nCurrentMission = param
    --print("------[RAUL] Current Hobo Mission:", param)
    bStageLoaded = true
end

function F_FirstAttack()
    if gHoboTrainingNow then
        return 1
    else
        return 0
    end
end

function F_SecondAttack()
    if 2 <= gCurrentMove then
        return 1
    else
        return 0
    end
end

function F_ThirdAttack()
    if 3 <= gCurrentMove then
        return 1
    else
        return 0
    end
end

function CB_PeteDied()
    --print("PETE CALLBACK CALLED")
    gMissionFail = true
    gMissionFailMessage = "1_06_PETEHIT"
end

function CB_GaryDied()
    --print("GARY CALLBACK CALLED")
    gMissionFailMessage = "1_06_GARYHIT"
    gMissionFail = true
end

function F_CriticalPedDied()
    gMissionFail = true
    gMissionFailMessage = "1_06_HOBOKO"
    gHoboDied = true
    gPlayerMoved = false
end

function F_FirstMissionEndCutscene()
    PedDelete(gHobo)
    PedLockTarget(gPlayer, -1)
    PlayerSetControl(0)
    gHobo = PedCreatePoint(87, POINTLIST._1_06BEGIN, 1)
    PedSetFlag(gHobo, 129, true)
    if shared.hoboGateIndex then
        DeletePersistentEntity(shared.hoboGateIndex, shared.hoboGateObject)
        shared.hoboGateIndex = nil
        shared.hoboGateObject = nil
    end
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    Wait(100)
    PedSetPosPoint(gPlayer, POINTLIST._1_06BEGIN, 5)
    CameraFade(500, 1)
    --print("<<<<<<<<<<<<<<<<<<<<<<<<<<< TRYING TO PRINT THE UNLOCK TEXT", gUnlockName)
    TextPrint(gUnlockName, 5, 1)
    CameraLookAtXYZ(157.36598, 21.6731, 7.4697948, true)
    CameraSetXYZ(154.24036, 22.27509, 8.48136, 157.36598, 21.6731, 7.4697948)
    SoundPlayMissionEndMusic(true, 10)
    if nCurrentMission == 8 then
        SoundPlayScriptedSpeechEvent(gHobo, "M_1_06_01", 128, "jumbo", true)
    else
        SoundPlayScriptedSpeechEvent(gHobo, "M_1_06_01", 34, "jumbo", true)
    end
    PedFollowPath(gPlayer, PATH._ENDCUTSCENEPATH, 0, 0)
    Wait(7000)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    if nCurrentMission == 8 then
        if not shared.hoboGateIndex then
            shared.hoboGateIndex, shared.hoboGateObject = CreatePersistentEntity("1_06_GateClosed", 165.967, 18.8144, 7.31457, 0, 0)
        end
        SoundEnableInteractiveMusic(false)
        SoundStopInteractiveStream(0)
        Wait(1000)
        SoundPreloadStreamNoLoop("1-06_HoboNIS.rsm", 1)
        PlayerSetControl(0)
        PedDelete(gHobo)
        gHobo = PedCreatePoint(87, POINTLIST._ENDHOBONIS, 1)
        PedSetFlag(gHobo, 129, true)
        gPlayerMoved = true
        PedSetPosPoint(gPlayer, POINTLIST._ENDING, 1)
        PedStop(gPlayer)
        PedClearObjectives(gPlayer)
        local timeout = GetTimer()
        while not SoundIsPreloadReady() do
            if 7000 < GetTimer() - timeout then
                break
            end
            Wait(0)
        end
        CameraSetXYZ(171.95653, 15.019173, 7.10359, 171.17491, 15.608242, 7.306226)
        CameraFade(500, 1)
        Wait(500)
        SoundPlayPreloadedStream()
        local x, y, z = GetPointList(POINTLIST._BEAMEFFECT)
        Wait(6000)
        shared.HoboeffectId = EffectCreate("RaceBeam", x, y, z)
        Wait(3000)
        PedMoveToPoint(gHobo, 0, POINTLIST._BEAMEFFECT)
        Wait(1000)
        x, y, z = PedGetPosXYZ(gHobo)
        PedSetEffectedByGravity(gHobo, false)
        gTimer = GetTimer()
        gWaiting = true
        PedSetActionNode(gHobo, "/Global/1_06/HoboFly", "Act/Conv/1_06.act")
        while gWaiting do
            z = z + 0.1
            PedSetPosXYZ(gHobo, x, y, z)
            if GetTimer() - gTimer > 5000 then
                gWaiting = false
            end
            Wait(0)
        end
        CameraFade(-1, 0)
        Wait(FADE_OUT_TIME)
        PedDelete(gHobo)
    end
end

function F_Socialize(pedId, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 23, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 27, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 24, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 28, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 29, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 30, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 33, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 34, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 36, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 25, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 26, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 31, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 32, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 35, bDisable)
end

function T_MonitorHoboHealth()
    while gMonitoringHealth do
        if not PedIsValid(gHobo) or PedIsDead(gHobo) then
            gMissionFail = true
            gMissionFailMessage = "1_06_HOBOKO"
        end
        Wait(0)
    end
end
