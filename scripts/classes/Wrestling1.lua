ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibPlayer.lua")
local L0_1 = 3
local L1_1 = 2
local L2_1 = 3
local MISSION_TIME = 30
local L4_1 = nil
local opponent, burton
local classNumber = 1
local opponentModel = 122
local L9_1 = nil
local mission_started = false
local L11_1 = false
local L12_1 = false
local L13_1 = false
local L14_1 = false
local L15_1 = false
local L16_1 = false
local gParam, index_mat, simpleObject_mat, index_glow, simpleObject_glow
local L22_1 = false
local gMaxSucceedCount = 2
local gAnims = {
    "/Global/Actions/Grapples/Front/Grapples/Hold_Idle",
    "/Global/Actions/Grapples/Front/Grapples/GrappleMoves/GrappleStrikes",
    "/Global/Actions/Grapples/Mount/MountIdle",
    "/Global/Actions/Grapples/RunningTakedown/Takedown"
}

function MissionSetup()
    MissionDontFadeIn()
    PedSetWeaponNow(0, -1, 0)
    DATLoad("C3.DAT", 2)
    DATInit()
    F_MakePlayerSafeForNIS(true)
    PlayerActivateCombatSphere(true)
    SoundEnableInteractiveMusic(false)
    DisablePunishmentSystem(true)
    NonMissionPedGenerationDisable()
    ToggleHUDComponentVisibility(20, false)
    F_ToggleHUDItems(false)
    if not shared.bBustedClassLaunched and not ClothingIsWearingOutfit("Wrestling") then
        ClothingBackup()
        ClothingSetPlayerOutfit("Wrestling")
        ClothingBuildPlayer()
    end
    ButtonHistoryEnableActionTreeInput(true)
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PedSetHealth(gPlayer, PedGetMaxHealth(gPlayer))
    end
    SoundStopPA()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
end

function MissionCleanup()
    gMissionRunning = false
    gHealthTreadCheck = false
    PlayerActivateCombatSphere(false)
    ButtonHistoryEnableActionTreeInput(false)
    SoundEnableSpeech_ActionTree()
    SoundEnableInteractiveMusic(true)
    SoundRestartPA()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    NonMissionPedGenerationEnable()
    UnLoadAnimationGroup("MINI_React")
    UnLoadAnimationGroup("Cheer_Cool2")
    UnLoadAnimationGroup("Cheer_Cool3")
    UnLoadAnimationGroup("Dodgeball")
    UnLoadAnimationGroup("POI_ChLead")
    UnLoadAnimationGroup("C_Wrestling")
    PedLockTarget(gPlayer, -1)
    DisablePunishmentSystem(false)
    PlayerWeaponHudLock(false)
    CameraAllowChange(true)
    CameraReturnToPlayer()
    ClothingRestore()
    ClothingBuildPlayer()
    CameraSetWidescreen(false)
    DeletePersistentEntity(index_mat, simpleObject_mat)
    DeletePersistentEntity(index_glow, simpleObject_glow)
    ToggleHUDComponentLocked(37, false)
    AreaRevertToDefaultPopulation()
    PlayerSetControl(1)
    PlayerSetPosPoint(POINTLIST._C3_PEND)
    F_ToggleHUDItems(true)
    F_MakePlayerSafeForNIS(false)
    ToggleHUDComponentVisibility(21, false)
    ToggleHUDComponentVisibility(20, true)
    PedSetActionTree(gPlayer, "/Global/Player", "Act/Player.act")
    DATUnload(2)
end

function F_ToggleHUDItems(b_on)
    ToggleHUDComponentVisibility(4, b_on)
    ToggleHUDComponentVisibility(11, b_on)
    ToggleHUDComponentVisibility(0, b_on)
end

function F_SetupClass(param)
    gParam = param
    if param == 1 then
        MISSION_TIME = 90
        opponentModel = 122
        opponentHealth = 95
        classNumber = 1
        gGrade = 1
    elseif param == 2 then
        MISSION_TIME = 90
        opponentModel = 122
        opponentHealth = 150
        classNumber = 2
        gMaxSucceedCount = 1
        gGrade = 3
    elseif param == 3 then
        MISSION_TIME = 60
        opponentModel = 121
        opponentHealth = 200
        classNumber = 3
        gGrade = 3
    elseif param == 4 then
        MISSION_TIME = 90
        opponentModel = 121
        opponentHealth = 250
        classNumber = 4
        gGrade = 4
    elseif param == 5 then
        MISSION_TIME = 120
        opponentModel = 92
        opponentHealth = 300
        classNumber = 5
        gGrade = 5
    elseif 6 <= param then
        opponentHealth = 310
        MISSION_TIME = 175
        opponentModel = 92
        classNumber = 5
        gGrade = 5
    end
    setupDone = true
end

function F_ClassInit(parm)
    PedSetHealth(opponent, opponentHealth)
    if parm == 1 then
        gActions = {
            {
                { 6, true }
            },
            {
                { 6, false },
                { 6, false },
                { 6, true }
            },
            gTotalMoves = 2,
            condition = 1,
            moveUnlockName = { "C3_Unlock02", "C3_Unlock04" },
            moveName = { "C3_Move02", "C3_Move04" }
        }
        gOverrideVictory = true
    elseif parm == 2 then
        gActions = {
            {
                { 8, false }
            },
            gTotalMoves = 1,
            condition = 1,
            moveUnlockName = { false },
            moveName = { "C3_Move06" }
        }
        gOverrideVictory = true
    elseif parm == 3 then
        TextPrint("C3_01_25", 3, 1)
        MissionObjectiveAdd("C3_01_25")
        Wait(2000)
    elseif parm == 4 then
        TextPrint("C3_01_26", 3, 1)
        MissionObjectiveAdd("C3_01_26")
        F_PlaySpeechAndWait(burton, "WRESTLING", 6, "jumbo")
    elseif parm == 5 or parm == 6 then
        TextPrint("C3_01_27", 3, 1)
        MissionObjectiveAdd("C3_01_27")
    end
end

function F_CheckLoop(classNo)
    if classNo == 3 then
        if GetTimer() - gSpeechTimer > 15000 then
            gSpeechTimer = GetTimer()
            SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 12, "jumbo")
        end
    elseif classNo == 4 then
        if GetTimer() - gSpeechTimer > 15000 then
            gSpeechTimer = GetTimer()
            SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 12, "jumbo")
        end
    elseif 5 <= classNo and GetTimer() - gSpeechTimer > 15000 then
        gSpeechTimer = GetTimer()
        SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 14, "jumbo")
    end
end

function main()
    while not setupDone do
        Wait(0)
    end
    while AreaIsLoading() do
        Wait(0)
    end
    AreaTransitionPoint(13, POINTLIST._C3_PLAYERINIT, nil, true)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    LoadAnimationGroup("MINI_React")
    LoadAnimationGroup("Cheer_Cool2")
    LoadAnimationGroup("Cheer_Cool3")
    LoadAnimationGroup("Dodgeball")
    LoadAnimationGroup("POI_ChLead")
    LoadAnimationGroup("C_Wrestling")
    LoadModels({
        opponentModel,
        55,
        182,
        181,
        180,
        181,
        30,
        70,
        17,
        13,
        72,
        73
    })
    local matX1, matY1 = GetPointList(POINTLIST._C3_RECTPT_01)
    local matX2, matY2 = GetPointList(POINTLIST._C3_RECTPT_02)
    index_mat, simpleObject_mat = CreatePersistentEntity("Wrestling_mat05", -619.16, -59.6952, 59.5695, 0, 13)
    index_glow, simpleObject_glow = CreatePersistentEntity("FlrGlowTOP", -619.198, -59.7191, 59.6611, 0, 13)
    LoadModels({ 341 }, true)
    F_SetupOpponent(classNumber)
    F_SetupSpectators()
    F_SetupBurton()
    mission_started = true
    F_Intro()
    CameraSetWidescreen(true)
    SoundPlayStream("MS_GymClass.rsm", 0.5, 2, 1)
    if classNumber == 5 then
        CameraLookAtXYZ(-620.81586, -62.866936, 60.866943, true)
        CameraSetXYZ(-618.8813, -60.227734, 60.907146, -620.81586, -62.866936, 60.866943)
        CameraFade(1000, 1)
        PedSetActionNode(opponent, "/Global/C31Strt/LuisIntro", "Act/Conv/C3_1.act")
        Wait(3000)
        CameraFade(500, 0)
        Wait(550)
    end
    PedLockTarget(gPlayer, opponent, 3)
    PlayerWeaponHudLock(true)
    L_PedExec("spectator", PedSetCheering, "id", true)
    PedSetActionTree(opponent, "/Global/WrestlingNPC", "Act/Anim/WrestlingNPC_ACT.act")
    PedSetActionTree(gPlayer, "/Global/WrestlingACT", "Act/Anim/WrestlingACT.act")
    Wait(500)
    CameraLookAtXYZ(-618.5461, -59.794083, 60.806877, true)
    CameraSetXYZ(-622.76666, -59.71638, 60.706867, -618.5461, -59.794083, 60.806877)
    local px, py, pz = GetPointList(POINTLIST._C3_PSTART)
    PlayerSetPosSimple(px, py, pz)
    PedSetPosPoint(opponent, POINTLIST._C3_ESTART)
    AreaClearAllPeds()
    PedFaceObject(burton, gPlayer, 3, 0, false)
    Wait(100)
    F_MakePlayerSafeForNIS(false)
    DisablePunishmentSystem(true)
    PedStop(opponent)
    PedClearObjectives(opponent)
    CameraFade(1000, 1)
    F_ClassInit(classNumber)
    gOldHealth = PedGetHealth(opponent)
    gInsideMat = true
    PedSetActionNode(opponent, "/Global/WrestlingNPC", "Act/Anim/WrestlingNPC_ACT.act")
    F_PreFight(classNumber)
    L11_1 = true
    gMissionRunning = true
    SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 13, "jumbo")
    local newHealth = PedGetMaxHealth(opponent) / 3 * 2
    PedSetHealth(opponent, newHealth)
    PedSetMaxHealth(opponent, newHealth)
    while gMissionRunning do
        F_CheckLoop(classNumber)
        PedInRectangle(opponent, matX1, matY1, matX2, matY2)
        if PedIsDead(opponent) then
            gMissionRunning = false
            missionPassed = true
        end
        if gMissionTimer and MissionTimerHasFinished() then
            MissionTimerStop()
            L22_1 = true
            gMissionRunning = false
            missionPassed = true
        end
        F_InMat()
        Wait(0)
    end
    SoundFadeoutStream()
    if missionPassed then
        PlayerSetGrade(6, gGrade)
        F_CompleteMission()
    else
        F_PlaySpeechAndWait(burton, "WRESTLING", 15, "jumbo")
        SoundPlayMissionEndMusic(false, 9)
        MissionFail(true, false)
    end
end

function CbPlayerPath(pedId, pathId, nodeId)
    if nodeId == 2 then
    elseif nodeId == 4 then
        PedSetActionNode(gPlayer, "/Global/C31Strt/PlayerStretch", "Act/Conv/C3_1.act")
    end
end

function F_SetupOpponent(count)
    opponent = PedCreatePoint(opponentModel, POINTLIST._C3_ESTART)
    PedSetPedToTypeAttitude(opponent, 13, 0)
    PlayerSocialDisableActionAgainstPed(opponent, 23, true)
    PlayerSocialDisableActionAgainstPed(opponent, 33, true)
    PlayerSocialDisableActionAgainstPed(opponent, 25, true)
    PlayerSocialDisableActionAgainstPed(opponent, 27, true)
    PlayerSocialDisableActionAgainstPed(opponent, 32, true)
    PlayerSocialDisableActionAgainstPed(opponent, 35, true)
    PlayerSocialDisableActionAgainstPed(opponent, 30, true)
    PlayerSocialDisableActionAgainstPed(opponent, 34, true)
    PlayerSocialDisableActionAgainstPed(opponent, 26, true)
    PlayerSocialDisableActionAgainstPed(opponent, 29, true)
    PlayerSocialDisableActionAgainstPed(opponent, 24, true)
    PlayerSocialDisableActionAgainstPed(opponent, 31, true)
    PlayerSocialDisableActionAgainstPed(opponent, 28, true)
    ToggleHUDComponentLocked(37, true)
    PedHideHealthBar(opponent)
    if count == 1 or count == 2 then
        PedOverrideStat(opponent, 38, 0)
        PedOverrideStat(opponent, 39, 0)
    end
    PedStop(opponent)
    PedIgnoreAttacks(opponent, true)
end

function F_OpponentStartFight()
    PedIgnoreAttacks(opponent, false)
end

function F_SetupSpectators()
    L_PedLoadPoint("spectator", {
        {
            model = 30,
            point = POINTLIST._C3_SPECT_04
        },
        {
            model = 17,
            point = POINTLIST._C3_SPECT_05
        },
        {
            model = 13,
            point = POINTLIST._C3_SPECT_06
        },
        {
            model = 72,
            point = POINTLIST._C3_SPECT_09
        },
        {
            model = 73,
            point = POINTLIST._C3_SPECT_10
        },
        {
            model = 70,
            point = POINTLIST._C3_SPECT_11
        }
    })
    L_PedExec("spectator", PedSetInvulnerable, "id", true)
    L_PedExec("spectator", PedIgnoreAttacks, "id", true)
    L_PedExec("spectator", PedIgnoreStimuli, "id", true)
    L_PedExec("spectator", PedMakeTargetable, "id", false)
    L_PedExec("spectator", PedSetStationary, "id", true)
    iCheer01 = PedCreatePoint(181, POINTLIST._C3_SPECT_07)
    iCheer02 = PedCreatePoint(180, POINTLIST._C3_SPECT_08)
    iCheer03 = PedCreatePoint(180, POINTLIST._C3_SPECT_01)
    iCheer04 = PedCreatePoint(181, POINTLIST._C3_SPECT_02)
    iCheer05 = PedCreatePoint(182, POINTLIST._C3_SPECT_03)
    PedSetInvulnerable(iCheer01, true)
    PedSetInvulnerable(iCheer02, true)
    PedSetInvulnerable(iCheer03, true)
    PedSetInvulnerable(iCheer04, true)
    PedSetInvulnerable(iCheer05, true)
    PedMakeTargetable(iCheer01, false)
    PedMakeTargetable(iCheer02, false)
    PedMakeTargetable(iCheer03, false)
    PedMakeTargetable(iCheer04, false)
    PedMakeTargetable(iCheer05, false)
    PedIgnoreStimuli(iCheer01, true)
    PedIgnoreStimuli(iCheer02, true)
    PedIgnoreStimuli(iCheer03, true)
    PedIgnoreStimuli(iCheer04, true)
    PedIgnoreStimuli(iCheer05, true)
    PedSetActionNode(iCheer01, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
    PedSetActionNode(iCheer02, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
    PedSetActionNode(iCheer03, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
    PedSetActionNode(iCheer04, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
    PedSetActionNode(iCheer05, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
end

function F_SetupBurton()
    burton = PedCreatePoint(55, POINTLIST._C3_BURTON_START)
    PedSetInvulnerable(burton, true)
    PedIgnoreStimuli(burton, true)
    PedMakeTargetable(burton, false)
    PedSetStationary(burton, true)
    PedSetActionNode(burton, "/Global/C31Strt/BurtonIdle", "Act/Conv/C3_1.act")
end

function F_Intro()
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    --print("AFTER MAKE SAFE FOR NIS ")
    SoundDisableSpeech_ActionTree()
    Wait(2000)
    CameraSetWidescreen(true)
    if not F_CheckIfPrefect() then
        CameraFade(1000, 1)
    end
    PedFaceObject(burton, gPlayer, 3, 1, false)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedFollowPath(gPlayer, PATH._C3_PLAYERPATH, 0, 1)
    CameraSetPath(PATH._C3_CAMERAPATH, true)
    CameraSetSpeed(6, 6, 6)
    CameraLookAtPath(PATH._C3_CAMERALOOKAT, true)
    CameraLookAtPathSetSpeed(8, 8, 8)
    --print("FINTRO -----// ", classNumber)
    if classNumber <= 1 then
        F_PlaySpeechAndWait(burton, "WRESTLING", 1, "jumbo")
        CameraLookAtPath(PATH._C3_CAMERALOOKAT2, true)
        CameraSetPath(PATH._C3_CAMERAPATH02, false)
        PedFaceObject(gPlayer, opponent, 2, 1, true)
        F_PlaySpeechAndWait(burton, "WRESTLING", 3, "jumbo")
        PedSetActionNode(gPlayer, "/Global/C31Strt/PlayerTaunt", "Act/Conv/C3_1.act")
        PedSetActionNode(opponent, "/Global/C31Strt/FattyAvoid", "Act/Conv/C3_1.act")
        SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 4, "jumbo")
    elseif classNumber == 5 then
        SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 7, "jumbo")
    else
        F_PlaySpeechAndWait(burton, "WRESTLING", 1, "jumbo")
        PedFaceObject(gPlayer, opponent, 2, 1, true)
        CameraLookAtPath(PATH._C3_CAMERALOOKAT2, true)
        CameraSetPath(PATH._C3_CAMERAPATH02, false)
        SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 9, "jumbo")
        Wait(100)
        PedSetActionNode(gPlayer, "/Global/C31Strt/PlayerTaunt", "Act/Conv/C3_1.act")
        PedSetActionNode(opponent, "/Global/C31Strt/FattyAvoid", "Act/Conv/C3_1.act")
    end
    Wait(3500)
    CameraFade(1000, 0)
    Wait(1000)
    F_CleanPrefect()
    PedFaceObject(gPlayer, opponent, 2, 0, true)
    CameraReset()
    CameraReturnToPlayer()
    PedSetPosPoint(burton, POINTLIST._C3_BURTON)
    PedFaceObject(burton, opponent, 2, 1, false)
    SoundEnableSpeech_ActionTree()
    L_PedExec("spectator", PedClearAllWeapons, "id")
    L_PedExec("spectator", PedSetTaskNode, "id", "/Global/AI/ScriptedAI/CheeringAINode", "Act/AI/AI.act")
end

function F_CompleteMission()
    MissionTimerStop()
    SoundDisableSpeech_ActionTree()
    L_PedExec("spectator", PedSetCheap, "id", false)
    PlayerSetControl(0)
    CameraFade(1000, 0)
    Wait(1000)
    CameraSetWidescreen(true)
    PedSetActionTree(gPlayer, "/Global/Player", "Act/Player.act")
    PedLockTarget(gPlayer, -1)
    PlayerWeaponHudLock(false)
    CameraAllowChange(true)
    CameraReturnToPlayer()
    CameraReset()
    PedClearObjectives(gPlayer)
    PedStop(gPlayer)
    PedDelete(opponent)
    local x, y, z = GetPointList(POINTLIST._C3_PLAYERVICTORY)
    PlayerSetPosSimple(x, y, z)
    PlayerFaceHeadingNow(-43.4)
    opponent = PedCreatePoint(opponentModel, POINTLIST._C3_PLAYERVICTORY, 2)
    Wait(100)
    if classNumber ~= 3 then
        PedSetActionNode(opponent, "/Global/C31Strt/OpponentDefeated", "Act/Conv/C3_1.act")
    end
    CameraLookAtXYZ(-618.43317, -60.148853, 60.6069, true)
    CameraSetXYZ(-616.3086, -58.824932, 61.106567, -618.43317, -60.148853, 60.6069)
    CameraFade(500, 1)
    PedSetActionNode(gPlayer, "/Global/C31Strt/PlayerVictory", "Act/Conv/C3_1.act")
    if classNumber == 5 then
        F_PlaySpeechAndWait(burton, "WRESTLING", 18, "jumbo")
    else
        if classNumber == 1 then
            ClothingGivePlayerOutfit("Wrestling")
        elseif classNumber == 2 then
        end
        F_PlaySpeechAndWait(burton, "WRESTLING", 16, "jumbo")
    end
    MinigameSetGrades(6, gGrade - 1)
    SoundFadeoutStream()
    SoundPlayMissionEndMusic(true, 9)
    while MinigameIsShowingGrades() do
        Wait(0)
    end
    SoundEnableSpeech_ActionTree()
    MissionSucceed(true, true, false)
end

function F_FailMission()
    if not IsMissionRestartable() then
    end
    Wait(3000)
    SoundPlayMissionEndMusic(false, 9)
    MissionFail()
end

function F_SetupNextMove()
    if gAnims[gActions.condition] then
        if PedIsPlaying(opponent, "/Global/AI/CombatActions/CombatActions/PostHit/OnGround", true) then
            local startTime = GetTimer()
            ToggleHUDComponentVisibility(21, true)
            while PedIsPlaying(opponent, "/Global/AI/CombatActions/CombatActions/PostHit/OnGround", true) do
                if 5000 < GetTimer() - startTime then
                    break
                end
                Wait(0)
            end
        end
        if not PedIsPlaying(gPlayer, gAnims[gActions.condition], true) and not PedIsPlaying(gPlayer, gAnims[gActions.condition + 1], true) then
            ButtonHistoryIgnoreController(true)
            ButtonHistoryClearSequence()
            ToggleHUDComponentVisibility(21, true)
            gTutorialSequence = true
            if gActions.condition == 1 then
                ButtonHistoryAddSequence(9, false)
                ButtonHistoryAddSequenceLocalText("C3_Grapple")
            elseif gActions.condition == 3 then
                ButtonHistoryAddSequence(9, false)
                ButtonHistoryAddSequence(8, false)
                ButtonHistoryAddSequenceLocalText("C3_Move06")
            end
            ButtonHistorySetSequenceTime(10)
            ButtonHistoryIgnoreController(false)
            local L0_2 = true
            while L0_2 do
                F_InMat()
                if PedIsPlaying(gPlayer, gAnims[gActions.condition], true) then
                    L0_2 = false
                elseif PedIsPlaying(gPlayer, gAnims[gActions.condition + 1], true) then
                    L0_2 = false
                end
                Wait(0)
            end
            local randomNo = math.random(1, 100)
            if randomNo < 50 then
                SoundStopCurrentSpeechEvent()
                SoundPlayScriptedSpeechEvent(opponent, "VICTIMIZED", 0, "large", false, true)
            else
                SoundStopCurrentSpeechEvent()
                SoundPlayScriptedSpeechEvent(opponent, "SCARED", 0, "large", false, true)
            end
            ToggleHUDComponentVisibility(21, false)
            Wait(500)
            gTutorialSequence = false
        end
    end
    gButtonCorrect = false
    ButtonHistoryIgnoreController(true)
    ButtonHistoryClearSequence()
    ButtonHistoryIgnoreSequence(16, 17, 10)
    ButtonHistorySetCallbackPassed(F_PassedCallback)
    ButtonHistorySetCallbackFailed(F_FailedCallback)
    ButtonHistorySetCallbackCorrectButton(F_CorrectButtonPressed)
    ToggleHUDComponentVisibility(21, true)
    ButtonHistorySetSequenceTime(10)
    ButtonHistoryAddSequenceLocalText(gActions.moveName[gCurrentMove])
    gUnlockName = gActions.moveUnlockName[gCurrentMove]
    local L0_2 = gActions[gCurrentMove]
    for _, value in L0_2 do
        if table.getn(value) == 2 then
            ButtonHistoryAddSequence(value[1], value[2])
        else
            ButtonHistoryAddSequenceTimeInterval(value[1], value[2], value[3])
        end
    end
    gSequencePassed = false
    ButtonHistoryIgnoreController(false)
end

function F_MissionStageFight()
    if gSequencePassed then
        if gEnemyReverse then
            local startTime = GetTimer()
            while not PedIsPlaying(gPlayer, "/Global/Actions/Grapples/Mount/MountIdle", true) do
                F_InMat()
                if 2000 < GetTimer() - startTime then
                    break
                end
                if PedIsPlaying(gPlayer, "/Global/Actions/Grapples/RunningTakedown/Takedown", true) then
                    break
                end
                Wait(0)
            end
            PedSetActionNode(opponent, "/Global/Actions/Grapples/GrappleReversals/MountReversals/Pushoff/GIVE", "Act/Globals/GlobalActions.act")
        end
        local L0_2 = true
        while L0_2 do
            F_InMat()
            if PedIsPlaying(gPlayer, gAnims[gActions.condition], true) or PedIsPlaying(gPlayer, "/Global/WrestlingACT/Default_KEY/Locomotion_Move/CombatLoco", true) then
                L0_2 = false
            end
            Wait(0)
        end
        Wait(1000)
        if not gOverrideVictory then
            PedSetActionNode(gPlayer, "/Global/1_06/PlayerVictory", "Act/Conv/1_06.act")
        end
        gMoveSucceed = gMoveSucceed + 1
        if gMoveSucceed >= gMaxSucceedCount then
            gMoveSucceed = 0
            gCurrentMove = gCurrentMove + 1
            gNewMove = true
            if gUnlockName then
                CameraSetWidescreen(true)
            end
            ToggleHUDComponentVisibility(21, false)
        else
            SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 12, "jumbo")
        end
        Wait(1000)
        if gCurrentMove > gTotalMoves then
            if gUnlockName then
                TextPrint(gUnlockName, 3, 1)
                Wait(2500)
            end
            Wait(1000)
            gSucceededTutorial = true
            CameraSetWidescreen(false)
            gNewMove = false
        else
            if gNewMove then
                if gUnlockName then
                    TextPrint(gUnlockName, 3, 1)
                end
                SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 12, "jumbo")
                Wait(3500)
                gNewMove = false
                CameraSetWidescreen(false)
            end
            PlayerSetControl(1)
            F_SetupNextMove()
        end
        PlayerSetControl(1)
    end
    if gSequenceFailed and not gSucceededTutorial and not gSequencePassed and GetTimer() - gFailTimer > 8000 then
        SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 11, "jumbo")
        gFailTimer = GetTimer()
        gSequenceFailed = false
        F_SetupNextMove()
    end
end

function T_RestoreHealth()
    --print("[RAUL] Start Restoring Health")
    while gHealthTreadCheck do
        PedSetHealth(opponent, gOldHealth)
        Wait(0)
    end
    --print("[RAUL] End Restoring Health")
end

function F_PreFight(parm)
    if parm == 1 then
        gHealthTreadCheck = true
        TextPrint("C3_01_30", 4, 1)
        Wait(3000)
        CameraSetWidescreen(false)
        PlayerSetControl(1)
        F_OpponentStartFight()
        PedClearObjectives(gPlayer)
        PedStop(gPlayer)
        gCurrentMove = 1
        gMoveSucceed = 0
        gTotalMoves = gActions.gTotalMoves
        gFailTimer = GetTimer()
        CameraSetShot(9, "Wrestling", false)
        CameraAllowChange(false)
        PedAttackPlayer(opponent)
        F_SetupNextMove()
        CreateThread("T_RestoreHealth")
        while not gSucceededTutorial do
            PedSetHealth(opponent, gOldHealth)
            F_InMat()
            F_MissionStageFight()
            Wait(0)
        end
        PedSetHealth(opponent, gOldHealth)
        TextPrint("C3_01_24", 3, 1)
        MissionObjectiveAdd("C3_01_24")
        gHealthTreadCheck = false
    elseif parm == 2 then
        gHealthTreadCheck = true
        TextPrint("C3_01_30", 4, 1)
        Wait(3000)
        CameraSetWidescreen(false)
        PlayerSetControl(1)
        CreateThread("T_RestoreHealth")
        F_OpponentStartFight()
        PedClearObjectives(gPlayer)
        PedStop(gPlayer)
        CameraSetShot(9, "Wrestling", false)
        CameraAllowChange(false)
        gCurrentMove = 1
        gMoveSucceed = 0
        gTotalMoves = gActions.gTotalMoves
        gFailTimer = GetTimer()
        F_SetupNextMove()
        gEnemyReverse = true
        while not gSucceededTutorial do
            PedSetHealth(opponent, gOldHealth)
            F_InMat()
            F_MissionStageFight()
            Wait(0)
        end
        gActions = {
            {
                { 7, false }
            },
            {
                { 9, false }
            },
            {
                { 8, false }
            },
            {
                { 6, false },
                { 6, false },
                { 6, false }
            },
            gTotalMoves = 4,
            condition = 3,
            moveUnlockName = {
                false,
                false,
                "C3_Unlock10",
                "C3_Unlock11"
            },
            moveName = {
                "C3_Move08",
                "C3_Move09",
                "C3_Move10",
                "C3_Move11"
            }
        }
        gEnemyReverse = false
        gCurrentMove = 1
        gMoveSucceed = 0
        gTotalMoves = gActions.gTotalMoves
        gFailTimer = GetTimer()
        F_SetupNextMove()
        gSucceededTutorial = false
        while not gSucceededTutorial do
            PedSetHealth(opponent, gOldHealth)
            F_InMat()
            F_MissionStageFight()
            Wait(0)
        end
        PedSetHealth(opponent, gOldHealth)
        TextPrint("C3_01_24", 3, 1)
        MissionObjectiveAdd("C3_01_24")
        gHealthTreadCheck = false
    elseif parm == 5 then
        gSpeechTimer = GetTimer()
        CameraSetWidescreen(false)
        PlayerSetControl(1)
        CameraSetShot(9, "Wrestling", false)
        CameraAllowChange(false)
        F_OpponentStartFight()
    elseif parm == 3 then
        gSpeechTimer = GetTimer()
        CameraSetWidescreen(false)
        PlayerSetControl(1)
        CameraSetShot(9, "Wrestling", false)
        CameraAllowChange(false)
        local L1_2 = 0
        local L2_2 = false
        CounterMakeHUDVisible(true, true)
        CounterSetCurrent(0)
        CounterSetMax(3)
        F_OpponentStartFight()
        PedSetInfiniteSprint(opponent, true)
        while L1_2 < 3 do
            F_InMat()
            if L1_2 <= 0 and PedIsPlaying(gPlayer, "/Global/Actions/Grapples/Front/Grapples/Hold_Idle/RCV", true) then
                TutorialRemoveMessage()
                TutorialShowMessage("C3_01_03", 4000)
            end
            if not L2_2 and PedIsPlaying(gPlayer, "/Global/Actions/Grapples/GrappleReversals", true) then
                L1_2 = L1_2 + 1
                CounterSetCurrent(L1_2)
                L2_2 = true
            elseif L2_2 and not PedIsPlaying(gPlayer, "/Global/Actions/Grapples/GrappleReversals", true) then
                L2_2 = false
            end
            Wait(0)
        end
        CounterMakeHUDVisible(false)
        MissionTimerStart(MISSION_TIME)
        gMissionTimer = true
    else
        gSpeechTimer = GetTimer()
        CameraSetWidescreen(false)
        PlayerSetControl(1)
        CameraSetShot(9, "Wrestling", false)
        CameraAllowChange(false)
        F_OpponentStartFight()
    end
end

function F_PassedCallback(button)
    SoundPlay2D("RightBtn")
    if not gTutorialSequence then
        local randomNo = math.random(1, 100)
        if randomNo < 50 then
            SoundPlayScriptedSpeechEvent(opponent, "VICTIMIZED", 0, "large", false, true)
        else
            SoundPlayScriptedSpeechEvent(opponent, "DEFEAT_INDIVIDUAL", 0, "large", false, true)
        end
        ToggleHUDComponentVisibility(21, false)
        gSequencePassed = true
    end
end

function F_FailedCallback(button, timesUp)
    ButtonHistoryIgnoreController(false)
    gSequenceFailed = true
end

function F_CorrectButtonPressed(button)
    gButtonCorrect = true
end

function F_ResetPeds()
    --DebugPrint("************WMW - F_ResetPeds()***************************")
    CameraFade(500, 0)
    PlayerSetControl(0)
    Wait(500)
    CameraAllowChange(true)
    CameraLookAtXYZ(-619.46704, -60.716175, 60.486973, true)
    CameraSetXYZ(-615.8843, -55.617973, 61.187515, -619.46704, -60.716175, 60.486973)
    PedSetActionNode(opponent, "/Global/WrestlingNPC/Default_KEY/Locomotion/Free/Idle", "Act/Anim/WrestlingNPC_ACT.act")
    PedSetActionNode(gPlayer, "/Global/WrestlingACT/Default_KEY/Locomotion_Move/CombatLoco/StrafeIdle", "Act/Anim/WrestlingACT.act")
    Wait(1000)
    local px, py, pz = GetPointList(POINTLIST._C3_PSTART)
    PlayerSetPosSimple(px, py, pz)
    PedSetPosPoint(opponent, POINTLIST._C3_ESTART)
    PedSetActionNode(opponent, "/Global/WrestlingNPC/Default_KEY/Locomotion/Free/Idle", "Act/Anim/WrestlingNPC_ACT.act")
    PedSetActionNode(gPlayer, "/Global/WrestlingACT/Default_KEY/Locomotion_Move/CombatLoco/StrafeIdle", "Act/Anim/WrestlingACT.act")
    Wait(200)
    PedFaceObject(opponent, gPlayer, 3, 0)
    PedFaceObject(gPlayer, opponent, 2, 0)
    Wait(100)
    CameraFade(500, 1)
    TextPrint("C3_01_31", 4, 1)
    PlayerSetControl(1)
    CameraSetShot(9, "Wrestling", false)
    CameraAllowChange(false)
end

function F_InMat()
    if gInsideMat and not PlayerIsInTrigger(TRIGGER._C3_MAT_BOUNDARY) then
        F_ResetPeds()
        SoundPlayScriptedSpeechEvent(burton, "WRESTLING", 10, "jumbo")
        gInsideMat = false
        gMatTimer = GetTimer()
        gCountdown = 13
    elseif not gInsideMat then
        if PlayerIsInTrigger(TRIGGER._C3_MAT_BOUNDARY) then
            gInsideMat = true
        end
        if 1000 < GetTimer() - gMatTimer then
            gCountdown = gCountdown - 1
            if gCountdown <= 10 then
                TextPrintString(tostring(gCountdown), 1, 2)
                if gCountdown == 10 then
                    TextPrint("C3_01_28", 3, 1)
                end
            end
            gMatTimer = GetTimer()
            if gCountdown <= 0 then
                gMissionRunning = false
            end
        end
    end
end

function F_CheckIfPrefect()
    if shared.bBustedClassLaunched then
        --print("BUSTEEEEEEEEEEED")
        local prefectModels = {
            49,
            50,
            51,
            52
        }
        local prefectModel = prefectModels[math.random(1, 4)]
        PlayerSetPosPoint(POINTLIST._PLAYERBUSTED)
        LoadModels({ prefectModel })
        prefect = PedCreatePoint(prefectModel, POINTLIST._PREFECTLOC)
        PedStop(prefect)
        PedClearObjectives(prefect)
        PedIgnoreStimuli(prefect, true)
        PedSetInvulnerable(prefect, true)
        PedFaceObject(gPlayer, prefect, 2, 0)
        PedFaceObject(prefect, gPlayer, 3, 1, false)
        PedSetPedToTypeAttitude(prefect, 3, 2)
        CameraLookAtXYZ(-647.591, -60.377666, 56.458607, true)
        CameraSetXYZ(-645.588, -57.811245, 56.65822, -647.591, -60.377666, 56.458607)
        CameraFade(-1, 1)
        SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
        PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
        PedSetActionNode(gPlayer, "/Global/C31Strt/PlayerFail", "Act/Conv/C3_1.act")
        Wait(3000)
        PedSetActionNode(gPlayer, "/Global/C31Strt/Clear", "Act/Conv/C3_1.act")
        local x, y, z = GetPointFromPointList(POINTLIST._PLAYERBUSTED, 2)
        PedFollowPath(gPlayer, PATH._BUSTEDPATH, 0, 0)
        Wait(1000)
        CameraFade(-1, 0)
        Wait(FADE_OUT_TIME + 110)
        if not ClothingIsWearingOutfit("Wrestling") then
            ClothingBackup()
            ClothingSetPlayerOutfit("Wrestling")
            ClothingBuildPlayer()
        end
        PedStop(gPlayer)
        PedClearObjectives(gPlayer)
        Wait(1000)
        PlayerSetPosPoint(POINTLIST._C3_PLAYERINIT)
        PedSetActionNode(gPlayer, "/Global/C31Strt/Clear", "Act/Conv/C3_1.act")
        CameraFade(-1, 1)
        shared.bBustedClassLaunched = false
        return true
    end
    return false
end

function F_CleanPrefect()
    if prefect and PedIsValid(prefect) then
        PedDelete(prefect)
    end
end
