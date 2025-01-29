--[[ Changes to this file:
    * Modified function F_CutStealCostume, may require testing
]]

local bDebugModeOn = false
local bDebugLevel = 2
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bMonitorMascotField = false
local bMascotIsDancing = false
local gLastPOI = 1
local sMascotState = "idle"
local gMascotNextObjectiveElement = 1
local tableMascotPOI = {
    1,
    2,
    3,
    4,
    5
}
local bPOI01Active = true
local bPOI02Active = true
local bPOI03Active = true
local bPOI04Active = true
local bPOI05Active = true
local tableTempMascotTalk = {
    20,
    26,
    27,
    29,
    30,
    34,
    35
}
local gFightPattern = 0
local bMonitorMascotPool = false
local bCostumeSpawned = false
local bNerdAmbush = false
local bLoadedPool = false
local bCheering = false
local bPushups = false
local bBreakMascotOutOfObjective = false
local bHitMascotInPOI4 = true
local bHitMascotInPOI5 = true
local tableExtraJocks = {}
local tableExtraJockModels = {
    17,
    109,
    204
}
local bMascotNeutral = false
local bMascotPissed = false
local deadX, deadY, deadZ = 0, 0, 0
local gMascotHealth = 0
local bPlayerTauntedMascot = false
local gSpawnAJockTimer = 0
local gSpawnAJockFrequency = 20000
local gMaxNumberOfJocksToSpawn = 3
local gNumberOfSpawnedJocks = 0
local bSkipFirstCutscene = false
local bSkipSecondCutscene = false
local bSpawnAJockDropPop = false
local bHitByStinkBomb = false
local gStinkBombTimer = GetTimer()
local gMissionFailMessage = 0
local gMascotSpeechTimer = 0
local gMascotHealthModifier = 1.5
local gMascotHalfHealth = 0

function MissionSetup()
    --print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
    SoundPlayInteractiveStream("MS_FightMid02.rsm", 0.5, 250, 500)
    SoundSetHighIntensityStream("MS_FightHigh02.rsm", 0.7, 0, 0)
    PlayCutsceneWithLoad("4-05", true)
    MissionDontFadeIn()
    DATLoad("4_05.DAT", 2)
    DATLoad("4_05cut.DAT", 2)
    DATInit()
    --print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
    --print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
    if not bGoToStage3 then
        F_ReleaseJocksAmbiently()
    end
    if bMissionPassed then
        ClothingGivePlayerOutfit("Mascot")
        F_EnableAllPopulation()
        F_setupAmbientBrawl()
        AreaTransitionPoint(0, POINTLIST._4_05CUT_ENDPLAYER)
        PedMakeAmbient(pedCutBo.id)
        PedMakeAmbient(pedCutCasey.id)
        PedMakeAmbient(pedCutThad.id)
        PedMakeAmbient(pedCutCornelius.id)
        PedMakeAmbient(pedCutJuri.id)
        PedMakeAmbient(pedCutBucky.id)
        PlayerSetControl(1)
    end
    F_MakePlayerSafeForNIS(false, false)
    PlayerSetInvulnerable(false)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    F_HideAgroMeter()
    AreaSetDoorLocked("DT_TSCHOOL_GYML", false)
    AreaSetDoorLocked("TSCHOOL_GYMR", false)
    AreaSetDoorLocked("TSCHOOL_POOLR", false)
    AreaSetDoorLocked("DT_TSCHOOL_POOLL", false)
    PedHideHealthBar()
    AreaRevertToDefaultPopulation()
    UnLoadAnimationGroup("F_Girls")
    UnLoadAnimationGroup("NPC_Mascot")
    UnLoadAnimationGroup("Hang_Workout")
    UnLoadAnimationGroup("IDLE_JOCK_A")
    UnLoadAnimationGroup("Russell")
    UnLoadAnimationGroup("Px_Ladr")
    UnLoadAnimationGroup("Cheer_Cool1")
    SoundEnableSpeech_ActionTree()
    DATUnload(2)
    DATInit()
    SoundFadeWithCamera(true)
    SoundStopInteractiveStream()
    MusicFadeWithCamera(true)
    DisablePunishmentSystem(false)
    EnablePOI()
    --print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
    --print("()xxxxx[:::::::::::::::> [start] main()")
    F_SetupMission()
    if bDebugModeOn then
        if bDebugLevel == 2 then
            F_StartAtStage2()
        elseif bDebugLevel == 3 then
            F_StartAtStage3()
        else
            F_Stage1()
        end
    else
        F_Stage1()
    end
    if bMissionFailed then
        TextPrint("4_05_EMPTY", 1, 1)
        SoundPlayMissionEndMusic(false, 4)
        if gMissionFailMessage == 1 then
            MissionFail(false, true, "4_05_FAIL_01")
        elseif gMissionFailMessage == 2 then
            MissionFail(false, true, "4_05_FAIL_02")
        else
            MissionFail(false)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
    --print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
    pedMascot = {
        spawn = POINTLIST._4_05_SPAWNMASCOT,
        element = 1,
        model = 88
    }
    pedBurton = {
        spawn = POINTLIST._4_05_SPAWNBURTON,
        element = 1,
        model = 55
    }
    pedJockPushup01 = {
        spawn = POINTLIST._4_05_SPAWNJOCKPUSHUPS,
        element = 1,
        model = 111
    }
    pedJockSmoke = {
        spawn = POINTLIST._4_05_SPAWNJOCKSMOKE,
        element = 1,
        model = 16
    }
    pedJockSprint01 = {
        spawn = POINTLIST._4_05_SPAWNJOCKSPRINTS,
        element = 1,
        model = 206
    }
    pedCheerleader01 = {
        spawn = POINTLIST._4_05_SPAWNCHEERLEADERS,
        element = 1,
        model = 182
    }
    pedCheerleader02 = {
        spawn = POINTLIST._4_05_SPAWNCHEERLEADERS,
        element = 2,
        model = 181
    }
    pedCutJuri = {
        spawn = POINTLIST._4_05CUT_SPAWNJURI,
        element = 1,
        model = 20
    }
    pedCutBo = {
        spawn = POINTLIST._4_05CUT_SPAWNBO,
        element = 1,
        model = 18
    }
    pedCutCasey = {
        spawn = POINTLIST._4_05CUT_SPAWNCASEY,
        element = 1,
        model = 17
    }
    pedCutDan = {
        spawn = POINTLIST._4_05CUT_SPAWNDAN,
        element = 1,
        model = 111
    }
    pedCutKirby = {
        spawn = POINTLIST._4_05CUT_SPAWNKIRBY,
        element = 1,
        model = 109
    }
    pedCutThad = {
        spawn = POINTLIST._4_05CUT_SPAWNTHAD,
        element = 1,
        model = 7
    }
    pedCutBucky = {
        spawn = POINTLIST._4_05CUT_SPAWNBUCKY,
        element = 1,
        model = 8
    }
    pedCutCornelius = {
        spawn = POINTLIST._4_05CUT_SPAWNCORNELIUS,
        element = 1,
        model = 9
    }
    --print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupMission()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
    WeaponRequestModel(341)
    WeaponRequestModel(305)
    WeaponRequestModel(301)
    LoadPedModels({
        88,
        55,
        17,
        111,
        109,
        16,
        206,
        204,
        182,
        181,
        180,
        20,
        18,
        7,
        8,
        9
    })
    LoadAnimationGroup("F_Girls")
    LoadAnimationGroup("NPC_Mascot")
    LoadAnimationGroup("Hang_Workout")
    LoadAnimationGroup("IDLE_JOCK_A")
    LoadAnimationGroup("Russell")
    LoadAnimationGroup("Px_Ladr")
    LoadAnimationGroup("NIS_4_05")
    LoadAnimationGroup("Cheer_Cool1")
    LoadActionTree("Act/AI/AI_MASCOT_4_05.act")
    LoadActionTree("Act/Conv/4_05.act")
    F_TableInit()
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
end

function F_Stage1()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
    F_Stage1_Setup()
    F_Stage1_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
    AreaTransitionPoint(0, POINTLIST._4_05_SPAWNPLAYER)
    F_SetupFootballField()
    F_ShowAgroMeter()
    bMonitorMascotField = true
    threadMonitorMascotField = CreateThread("T_MonitorMascotField")
    threadMonitorMascotForHits = CreateThread("T_MonitorMascotForHits")
    threadMonitorFieldTriggers = CreateThread("T_MonitorFieldTriggers")
    threadMissionTextQueue = CreateThread("T_MissionTextQueue")
    AreaSetDoorLocked("DT_TSCHOOL_GYML", true)
    AreaSetDoorLocked("TSCHOOL_GYMR", true)
    AreaSetDoorLocked("TSCHOOL_POOLR", true)
    AreaSetDoorLocked("DT_TSCHOOL_POOLL", true)
    PlayerRegisterSocialCallbackVsPed(pedMascot.id, 28, F_PlayerTauntedMascot)
    CameraReturnToPlayer()
    CameraReset()
    PlayerSetControl(1)
    CameraFade(500, 1)
    Wait(500)
    TextPrint("4_05_MOBJ_01", 6, 1)
    gObjective01 = MissionObjectiveAdd("4_05_MOBJ_01")
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
    while bLoop do
        Stage1_Objectives()
        if bMissionFailed then
            break
        end
        if bGoToStage2 then
            F_Stage2()
            break
        end
        Wait(0)
    end
end

function F_Stage2()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage2()")
    F_Stage2_Setup()
    F_Stage2_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
    F_HideAgroMeter()
    bMonitorMascotField = false
    MissionObjectiveComplete(gObjective01)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    F_cutMascotEnraged()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
    while bLoop do
        Stage2_Objectives()
        if bMissionFailed then
            break
        end
        if bGoToStage3 then
            F_Stage3()
            break
        end
        Wait(0)
    end
end

function F_Stage3()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage3()")
    F_Stage3_Setup()
    F_Stage3_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage3()")
end

function F_Stage3_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage3_Setup()")
    DisablePOI()
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    DisablePunishmentSystem(true)
    AreaTransitionPoint(13, POINTLIST._4_05_SPAWNPLAYERPOOL, nil, true)
    AreaClearAllPeds()
    PedSetInvulnerable(gPlayer, false)
    while IsStreamingBusy() do
        Wait(0)
    end
    pedMascot.id = PedCreatePoint(pedMascot.model, POINTLIST._4_05_SPAWNMASCOTPOOL, 1)
    pedMascot.blip = AddBlipForChar(pedMascot.id, 2, 26, 1, 0)
    local mascotHealth = PedGetMaxHealth(pedMascot.id)
    PedSetMaxHealth(pedMascot.id, mascotHealth * gMascotHealthModifier)
    PedSetHealth(pedMascot.id, mascotHealth * gMascotHealthModifier)
    gMascotHalfHealth = mascotHealth
    PedSetDamageTakenMultiplier(pedMascot.id, 0, 0.1)
    PedSetDamageTakenMultiplier(pedMascot.id, 3, 0.1)
    bMonitorMascotPool = true
    threadMonitorMascotPool = CreateThread("T_MonitorMascotPool")
    pickupHealth = PickupCreatePoint(362, POINTLIST._4_05_SPAWNHEALTHPOOL, 1, 0, "HealthBute")
    LoadAnimationGroup("NIS_4_05")
    CameraSetFOV(80)
    CameraSetXYZ(-673.86255, -75.12937, 60.326168, -674.47034, -74.338486, 60.39655)
    CameraSetWidescreen(true)
    CameraFade(500, 1)
    PedSetActionNode(pedMascot.id, "/Global/4_05/NIS/Mascot/MascotPool", "Act/Conv/4_05.act")
    SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 54, "large")
    F_WaitForSpeech(pedMascot.id)
    CameraSetFOV(30)
    SoundSetAudioFocusPlayer()
    CameraSetXYZ(-674.83936, -77.543335, 62.474476, -674.96344, -76.61372, 62.127563)
    PedSetActionNode(gPlayer, "/Global/4_05/NIS/Jimmy/Jimmy_Pool", "Act/Conv/4_05.act")
    SoundPlayScriptedSpeechEvent(gPlayer, "M_4_05", 60, "supersize")
    F_MakePlayerSafeForNIS(false)
    Wait(1500)
    PlayerWeaponHudLock(true)
    PlayerSetControl(0)
    PedSetInvulnerable(pedMascot.id, true)
    PedJump(pedMascot.id, POINTLIST._4_05_MASCOTJUMP, 1)
    CameraSetFOV(40)
    CameraSetXYZ(-672.4763, -54.21211, 56.213284, -672.89014, -55.114582, 56.332005)
    Wait(2000)
    SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 58, "large", false, true)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraReset()
    PlayerSetControl(1)
    PlayerWeaponHudLock(false)
    PedStop(pedMascot.id)
    PedClearObjectives(pedMascot.id)
    PedSetInvulnerable(pedMascot.id, false)
    PedSetAITree(pedMascot.id, "/Global/AI_MASCOT_4_05", "Act/AI/AI_MASCOT_4_05.act")
    Wait(500)
    PedAttackPlayer(pedMascot.id, 3)
    gObjective04 = MissionObjectiveAdd("4_05_MOBJ_04")
    TextPrint("4_05_MOBJ_04", 4, 1)
    PedShowHealthBar(pedMascot.id, true, "4_05_HEALTHBAR", true)
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage3_Setup()")
end

function F_Stage3_Loop()
    while bLoop do
        Stage3_Objectives()
        if bMissionFailed then
            break
        end
        if bMissionPassed then
            break
        end
        Wait(0)
    end
end

function Stage1_Objectives()
    if PlayerIsInTrigger(TRIGGER._4_05_WARNPATH) or PlayerIsInTrigger(TRIGGER._4_05_WARNMAIN) or PlayerIsInTrigger(TRIGGER._4_05_WARNALLEY) then
        TextPrint("4_05_WARN", 1, 1)
    end
    if PlayerIsInTrigger(TRIGGER._4_05_FAILPATH) or PlayerIsInTrigger(TRIGGER._4_05_FAILMAIN) or PlayerIsInTrigger(TRIGGER._4_05_FAILALLEY) then
        gMissionFailMessage = 1
        bMissionFailed = true
    end
end

function Stage2_Objectives()
    bGoToStage3 = true
end

function Stage3_Objectives()
    if not bCostumeSpawned and PedIsDead(pedMascot.id) then
        --print("()xxxxx[:::::::::::::::> Mascot is dead.")
        F_CutStealCostume()
    end
end

function F_StartAtStage2()
    --print("()xxxxx[:::::::::::::::> [start] F_StartAtStage2()")
    AreaTransitionPoint(0, POINTLIST._4_05_DEBUGSTAGE2PLAYER)
    gObjective01 = MissionObjectiveAdd("4_05_MOBJ_01")
    CameraFade(500, 1)
    Wait(500)
    DisablePOI()
    F_Stage2()
    --print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage2()")
end

function F_StartAtStage3()
    --print("()xxxxx[:::::::::::::::> [start] F_StartAtStage3()")
    LoadAnimationGroup("Russell")
    DisablePOI()
    F_DisableAllPopulation()
    F_Stage3()
    --print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage3()")
end

function F_SetupFootballField()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupFootballField()")
    pedMascot.id = PedCreatePoint(pedMascot.model, pedMascot.spawn, pedMascot.element)
    PedSetEmotionTowardsPed(pedMascot.id, gPlayer, 1, true)
    PedSetHealth(pedMascot.id, PedGetHealth(pedMascot.id) * 3)
    PedSetPedToTypeAttitude(pedMascot.id, 13, 1)
    PedClearAllWeapons(pedMascot.id)
    PedIgnoreStimuli(pedMascot.id, true)
    PedSetInfiniteSprint(pedMascot.id, true)
    pedMascot.blip = AddBlipForChar(pedMascot.id, 2, 0, 4, 0)
    PedSetAITree(pedMascot.id, "/Global/AI_MASCOT_4_05", "Act/AI/AI_MASCOT_4_05.act")
    PlayerSocialDisableActionAgainstPed(pedMascot.id, 35, true)
    PedOverrideStat(pedMascot.id, 6, 0)
    PedOverrideStat(pedMascot.id, 38, 100)
    PedSetFlag(pedMascot.id, 117, false)
    PedSetMissionCritical(pedMascot.id, true, F_MissionCritical, false)
    gMascotHealth = PedGetHealth(pedMascot.id)
    pedBurton.id = PedCreatePoint(pedBurton.model, pedBurton.spawn, pedBurton.element)
    pedJockPushup01.id = PedCreatePoint(pedJockPushup01.model, pedJockPushup01.spawn, pedJockPushup01.element)
    PedSetActionNode(pedJockPushup01.id, "/Global/4_05/Anims/Pushups/Start", "Act/Conv/4_05.act")
    F_PedSetDropItem(pedJockPushup01.id, 362, 100, 1)
    pedJockSmoke.id = PedCreatePoint(pedJockSmoke.model, pedJockSmoke.spawn, pedJockSmoke.element)
    F_PedSetDropItem(pedJockSmoke.id, 362, 100, 1)
    pedJockSprint01.id = PedCreatePoint(pedJockSprint01.model, pedJockSprint01.spawn, pedJockSprint01.element)
    F_PedSetDropItem(pedJockSprint01.id, 362, 100, 1)
    PedFollowPath(pedJockSprint01.id, PATH._4_05_LAPCLOCKWISE, 1, 1)
    pedCheerleader01.id = PedCreatePoint(pedCheerleader01.model, pedCheerleader01.spawn, pedCheerleader01.element)
    PedSetActionNode(pedCheerleader01.id, "/Global/4_05/Anims/Cheerleading/CheerRoutineA", "Act/Conv/4_05.act")
    pedCheerleader02.id = PedCreatePoint(pedCheerleader02.model, pedCheerleader02.spawn, pedCheerleader02.element)
    PedSetActionNode(pedCheerleader02.id, "/Global/4_05/Anims/Cheerleading/CheerRoutineA", "Act/Conv/4_05.act")
    bCheering = true
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupFootballField()")
end

function F_ShowAgroMeter()
    --print("()xxxxx[:::::::::::::::> [start] F_ShowAgroMeter()")
    CounterSetCurrent(0)
    CounterSetMax(36)
    CounterUseMeter(true)
    CounterMakeHUDVisible(true)
    CounterSetIcon("Bull_happy", "Bull_happy_x")
    --print("()xxxxx[:::::::::::::::> [finish] F_ShowAgroMeter()")
end

function F_HideAgroMeter()
    --print("()xxxxx[:::::::::::::::> [start] F_HideAgroMeter()")
    CounterClearIcon()
    CounterUseMeter(false)
    CounterMakeHUDVisible(false)
    --print("()xxxxx[:::::::::::::::> [finish] F_HideAgroMeter()")
end

function FightingPattern()
    --print("()xxxxx[:::::::::::::::> FightingPattern: " .. gFightPattern)
    return gFightPattern
end

function F_DeleteAPed(ped)
    if F_PedExists(ped) then
        PedDelete(ped)
    end
end

function F_CleanupNerdAmbush()
    F_DeleteAPed(pedCornelius.id)
    F_DeleteAPed(pedAlgie.id)
    F_DeleteAPed(pedBucky.id)
    F_DeleteAPed(pedDonald.id)
end

function F_HitByPlayer(pedID)
    if PedIsHit(pedID, 2, 250) then
        if PedGetWhoHitMeLast(pedID) == gPlayer then
            return true
        end
    else
        return false
    end
end

function F_CheckCheerleaders()
    if F_HitByPlayer(pedCheerleader01.id) or F_HitByPlayer(pedCheerleader02.id) then
        return true
    else
        return false
    end
end

function F_CheckSmoker()
    if F_HitByPlayer(pedJockSmoke.id) then
        return true
    else
        return false
    end
end

function F_DisableAllPopulation()
    --print("()xxxxx[:::::::::::::::> [start] F_DisableAllPopulation()")
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    --print("()xxxxx[:::::::::::::::> [finish] F_DisableAllPopulation()")
end

function F_EnableAllPopulation()
    --print("()xxxxx[:::::::::::::::> [start] F_EnableAllPopulation()")
    AreaRevertToDefaultPopulation()
    --print("()xxxxx[:::::::::::::::> [finish] F_EnableAllPopulation()")
end

function F_CleanupField()
    --print("()xxxxx[:::::::::::::::> [start] F_CleanupField()")
    PedSetMissionCritical(pedMascot.id, false)
    F_DeleteAPed(pedMascot.id)
    F_DeleteAPed(pedBurton.id)
    F_DeleteAPed(pedJockPushup01.id)
    F_DeleteAPed(pedJockSmoke.id)
    F_DeleteAPed(pedJockSprint01.id)
    F_DeleteAPed(pedCheerleader01.id)
    F_DeleteAPed(pedCheerleader02.id)
    --print("()xxxxx[:::::::::::::::> [finish] F_CleanupField()")
end

function F_SetupFieldForCutscene()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupFieldForCutscene()")
    pedMascot.id = PedCreatePoint(pedMascot.model, POINTLIST._4_05CUT_SPAWNMASCOT, 1)
    PedSetPedToTypeAttitude(pedMascot.id, 13, 4)
    PedSetInfiniteSprint(pedMascot.id, true)
    pedCutJuri.id = PedCreatePoint(pedCutJuri.model, pedCutJuri.spawn, pedCutJuri.element)
    pedCutBo.id = PedCreatePoint(pedCutBo.model, pedCutBo.spawn, pedCutBo.element)
    pedCutCasey.id = PedCreatePoint(pedCutCasey.model, pedCutCasey.spawn, pedCutCasey.element)
    pedCutDan.id = PedCreatePoint(pedCutDan.model, pedCutDan.spawn, pedCutDan.element)
    pedCutKirby.id = PedCreatePoint(pedCutKirby.model, pedCutKirby.spawn, pedCutKirby.element)
    PedClearAllWeapons(pedCutJuri.id)
    PedClearAllWeapons(pedCutBo.id)
    PedClearAllWeapons(pedCutCasey.id)
    PedClearAllWeapons(pedCutDan.id)
    PedClearAllWeapons(pedCutKirby.id)
    PedSetInfiniteSprint(pedCutJuri.id, true)
    PedSetInfiniteSprint(pedCutBo.id, true)
    PedSetInfiniteSprint(pedCutCasey.id, true)
    PedSetInfiniteSprint(pedCutDan.id, true)
    PedSetInfiniteSprint(pedCutKirby.id, true)
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupFieldForCutscene()")
end

function F_SetupNerdsForCutscene()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupNerdsForCutscene()")
    pedCutThad.id = PedCreatePoint(pedCutThad.model, pedCutThad.spawn, pedCutThad.element)
    PedSetStationary(pedCutThad.id, true)
    PedSetWeaponNow(pedCutThad.id, 301, 100)
    PedOverrideStat(pedCutThad.id, 10, 100)
    PedOverrideStat(pedCutThad.id, 11, 85)
    PedOverrideStat(pedCutThad.id, 3, 25)
    pedCutBucky.id = PedCreatePoint(pedCutBucky.model, pedCutBucky.spawn, pedCutBucky.element)
    PedSetStationary(pedCutBucky.id, true)
    PedSetWeaponNow(pedCutBucky.id, 305, 100)
    PedOverrideStat(pedCutBucky.id, 10, 100)
    PedOverrideStat(pedCutBucky.id, 11, 85)
    PedOverrideStat(pedCutBucky.id, 3, 25)
    pedCutCornelius.id = PedCreatePoint(pedCutCornelius.model, pedCutCornelius.spawn, pedCutCornelius.element)
    PedSetStationary(pedCutCornelius.id, true)
    PedSetWeaponNow(pedCutCornelius.id, 301, 100)
    PedOverrideStat(pedCutCornelius.id, 10, 100)
    PedOverrideStat(pedCutCornelius.id, 11, 85)
    PedOverrideStat(pedCutCornelius.id, 3, 25)
    PedSetPedToTypeAttitude(pedCutThad.id, 2, 0)
    PedSetPedToTypeAttitude(pedCutBucky.id, 2, 0)
    PedSetPedToTypeAttitude(pedCutCornelius.id, 2, 0)
    PedSetInvulnerable(pedCutThad.id, true)
    PedSetInvulnerable(pedCutBucky.id, true)
    PedSetInvulnerable(pedCutCornelius.id, true)
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupNerdsForCutscene()")
end

function F_CleanupCutPeds()
    --print("()xxxxx[:::::::::::::::> [start] F_CleanupCutPeds()")
    F_DeleteAPed(pedMascot.id)
    F_DeleteAPed(pedCutJuri.id)
    F_DeleteAPed(pedCutBo.id)
    F_DeleteAPed(pedCutCasey.id)
    F_DeleteAPed(pedCutDan.id)
    F_DeleteAPed(pedCutKirby.id)
    F_DeleteAPed(pedCutThad.id)
    F_DeleteAPed(pedCutBucky.id)
    F_DeleteAPed(pedCutCornelius.id)
    --print("()xxxxx[:::::::::::::::> [finish] F_CleanupCutPeds()")
end

function F_setupAmbientBrawl()
    --print("()xxxxx[:::::::::::::::> [start] F_setupAmbientBrawl()")
    pedCutBo.id = PedCreatePoint(pedCutBo.model, POINTLIST._4_05CUT_ENDBO, 1)
    pedCutCasey.id = PedCreatePoint(pedCutCasey.model, POINTLIST._4_05CUT_ENDCASEY, 1)
    pedCutJuri.id = PedCreatePoint(pedCutJuri.model, POINTLIST._4_05CUT_ENDJURI, 1)
    pedCutThad.id = PedCreatePoint(pedCutThad.model, POINTLIST._4_05CUT_ENDTHAD, 1)
    pedCutCornelius.id = PedCreatePoint(pedCutCornelius.model, POINTLIST._4_05CUT_ENDCORNELIUS, 1)
    pedCutBucky.id = PedCreatePoint(pedCutBucky.model, POINTLIST._4_05CUT_ENDBUCKY, 1)
    PedSetWeapon(pedCutCornelius.id, 305, 100)
    PedSetWeapon(pedCutBucky.id, 301, 100)
    PedSetWeapon(pedCutThad.id, 305, 100)
    PedAttack(pedCutBo.id, pedCutThad.id, 3)
    PedAttack(pedCutCasey.id, pedCutCornelius.id, 3)
    PedAttack(pedCutJuri.id, pedCutBucky.id, 3)
    PedAttack(pedCutThad.id, pedCutBo.id, 3)
    PedAttack(pedCutCornelius.id, pedCutCasey.id, 3)
    PedAttack(pedCutBucky.id, pedCutJuri.id, 3)
    PedSetPedToTypeAttitude(pedCutThad.id, 2, 0)
    PedSetPedToTypeAttitude(pedCutBucky.id, 2, 0)
    PedSetPedToTypeAttitude(pedCutCornelius.id, 2, 0)
    SoundPlayScriptedSpeechEventWrapper(pedCutCornelius.id, "M_4_05", 14, "large")
    --print("()xxxxx[:::::::::::::::> [finish] F_setupAmbientBrawl()")
end

function F_SpawnAJock()
    --print("()xxxxx[:::::::::::::::> [start] F_SpawnAJock()")
    if gNumberOfSpawnedJocks < gMaxNumberOfJocksToSpawn and gSpawnAJockTimer + gSpawnAJockFrequency < GetTimer() then
        --print("()xxxxx[:::::::::::::::> SPAWNING A JOCK!")
        local randModel = tableExtraJockModels[gNumberOfSpawnedJocks + 1]
        local tempPed = PedCreatePoint(randModel, POINTLIST._4_05_SPAWNJOCKS, 1)
        if not bSpawnAJockDropPop then
            F_PedSetDropItem(tempPed, 362, 100, 1)
            bSpawnAJockDropPop = true
        else
            bSpawnAJockDropPop = false
        end
        PedMoveToPoint(tempPed, 1, POINTLIST._4_05_SPAWNJOCKS, 1, cbSpawnedJockArrived)
        table.insert(tableExtraJocks, tempPed)
        gSpawnAJockTimer = GetTimer()
        gNumberOfSpawnedJocks = gNumberOfSpawnedJocks + 1
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_SpawnAJock()")
end

function F_CleanupExtraJocks()
    --print("()xxxxx[:::::::::::::::> [start] F_CleanupExtraJocks()")
    for i = 1, table.getn(tableExtraJocks) do
        if F_PedExists(tableExtraJocks[i]) then
            PedStop(tableExtraJocks[i])
            PedClearObjectives(tableExtraJocks[i])
            PedMakeAmbient(tableExtraJocks[i])
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_CleanupExtraJocks()")
end

function F_WaitForSpeech(pedID)
    --print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeech()")
    if pedID == nil then
        while SoundSpeechPlaying() do
            Wait(0)
        end
    else
        while SoundSpeechPlaying(pedID) do
            Wait(0)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeech()")
end

function F_PlayerTauntedMascot()
    --print("()xxxxx[:::::::::::::::> [start] F_PlayerTauntedMascot()")
    SoundPlayAmbientSpeechEvent(gPlayer, "PLAYER_TAUNT")
    bPlayerTauntedMascot = true
    --print("()xxxxx[:::::::::::::::> [finish] F_PlayerTauntedMascot()")
end

function F_WaitForSpeechCutscene01(pedID)
    --print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeechCutscene01()")
    if pedID == nil then
        while SoundSpeechPlaying() do
            Wait(0)
        end
    else
        while SoundSpeechPlaying(pedID) do
            if bSkipFirstCutscene then
                break
            end
            Wait(0)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeechCutscene01()")
end

function F_ReleaseJocksAmbiently()
    local tableAllJocks = {
        pedBurton.id,
        pedJockPushup01.id,
        pedJockSmoke.id,
        pedJockSprint01.id,
        pedCheerleader01.id,
        pedCheerleader02.id
    }
    for i = 1, table.getn(tableAllJocks) do
        if F_PedExists(tableAllJocks[i]) then
            PedMakeAmbient(tableAllJocks[i])
        end
    end
    for i = 1, table.getn(tableExtraJocks) do
        if F_PedExists(tableExtraJocks[i]) then
            PedMakeAmbient(tableExtraJocks[i])
        end
    end
end

function F_MissionCritical()
    gMissionFailMessage = 2
    bMissionFailed = true
end

function F_StopCheering()
    --print("()xxxxx[:::::::::::::::> [start] F_StopCheering()")
    PedSetActionNode(pedCheerleader01.id, "/Global/4_05/Anims/Empty", "Act/Conv/4_05.act")
    PedSetActionNode(pedCheerleader02.id, "/Global/4_05/Anims/Empty", "Act/Conv/4_05.act")
    --print("()xxxxx[:::::::::::::::> [finish] F_StopCheering()")
end

function F_StartCheering()
    --print("()xxxxx[:::::::::::::::> [start] F_StartCheering()")
    PedSetActionNode(pedCheerleader01.id, "/Global/4_05/Anims/Cheerleading/CheerRoutineA/CheerRoutineA_00/CheerRoutineA_01", "Act/Conv/4_05.act")
    PedSetActionNode(pedCheerleader02.id, "/Global/4_05/Anims/Cheerleading/CheerRoutineA/CheerRoutineA_00/CheerRoutineA_01", "Act/Conv/4_05.act")
    --print("()xxxxx[:::::::::::::::> [finish] F_StartCheering()")
end

function F_StopPushups()
    --print("()xxxxx[:::::::::::::::> [start] F_StopPushups()")
    PedSetActionNode(pedJockPushup01.id, "/Global/4_05/Anims/Pushups/Start/End", "Act/Conv/4_05.act")
    --print("()xxxxx[:::::::::::::::> [finish] F_StopPushups()")
end

function F_StartPushups()
    --print("()xxxxx[:::::::::::::::> [start] F_StartPushups()")
    PedSetActionNode(pedJockPushup01.id, "/Global/4_05/Anims/Pushups/Start", "Act/Conv/4_05.act")
    --print("()xxxxx[:::::::::::::::> [finish] F_StartPushups()")
end

function F_DispersePOI01()
    local tempPOIToRemove = 0
    --print("()xxxxx[:::::::::::::::> [start] F_DispersePOI01()")
    for i = 1, table.getn(tableMascotPOI) do
        if tableMascotPOI[i] == 1 then
            tempPOIToRemove = i
        end
    end
    --print("()xxxxx[:::::::::::::::> POI's remaining are")
    for i = 1, table.getn(tableMascotPOI) do
        --print("()xxxxx[:::::::::::::::> POI #: " .. tableMascotPOI[i])
    end
    --print("()xxxxx[:::::::::::::::> tableMascotPOI current size is: " .. table.getn(tableMascotPOI))
    --print("()xxxxx[:::::::::::::::> REMOVING POI: " .. tempPOIToRemove .. " from tableMascotPOI")
    table.remove(tableMascotPOI, tempPOIToRemove)
    --print("()xxxxx[:::::::::::::::> tableMascotPOI current size is: " .. table.getn(tableMascotPOI))
    --print("()xxxxx[:::::::::::::::> POI's remaining are")
    for i = 1, table.getn(tableMascotPOI) do
        --print("()xxxxx[:::::::::::::::> POI #: " .. tableMascotPOI[i])
    end
    F_StopCheering()
    PedMakeAmbient(pedCheerleader01.id)
    PedMakeAmbient(pedCheerleader02.id)
    PedFlee(pedCheerleader01.id, gPlayer)
    PedFlee(pedCheerleader02.id, gPlayer)
    bPOI01Active = false
    --print("()xxxxx[:::::::::::::::> [finish] F_DispersePOI01()")
end

function F_DispersePOI02()
    --print("()xxxxx[:::::::::::::::> [start] F_DispersePOI02()")
    local tempPOIToRemove = 0
    --print("()xxxxx[:::::::::::::::> [start] F_DispersePOI01()")
    for i = 1, table.getn(tableMascotPOI) do
        if tableMascotPOI[i] == 2 then
            tempPOIToRemove = i
        end
    end
    --print("()xxxxx[:::::::::::::::> POI's remaining are")
    for i = 1, table.getn(tableMascotPOI) do
        --print("()xxxxx[:::::::::::::::> POI #: " .. tableMascotPOI[i])
    end
    --print("()xxxxx[:::::::::::::::> tableMascotPOI current size is: " .. table.getn(tableMascotPOI))
    --print("()xxxxx[:::::::::::::::> REMOVING POI: " .. tempPOIToRemove .. " from tableMascotPOI")
    table.remove(tableMascotPOI, tempPOIToRemove)
    --print("()xxxxx[:::::::::::::::> tableMascotPOI current size is: " .. table.getn(tableMascotPOI))
    --print("()xxxxx[:::::::::::::::> POI's remaining are")
    for i = 1, table.getn(tableMascotPOI) do
        --print("()xxxxx[:::::::::::::::> POI #: " .. tableMascotPOI[i])
    end
    PedMakeAmbient(pedBurton.id)
    if PlayerIsInStealthProp() then
        PedMakeAmbient(pedJockPushup01.id)
    elseif F_PedExists(pedJockPushup01.id) then
        PedAttackPlayer(pedJockPushup01.id, 3)
    end
    bPOI02Active = false
    --print("()xxxxx[:::::::::::::::> [finish] F_DispersePOI02()")
end

function F_DispersePOI03()
    local tempPOIToRemove = 0
    --print("()xxxxx[:::::::::::::::> [start] F_DispersePOI03()")
    for i = 1, table.getn(tableMascotPOI) do
        if tableMascotPOI[i] == 3 then
            tempPOIToRemove = i
        end
    end
    --print("()xxxxx[:::::::::::::::> POI's remaining are")
    for i = 1, table.getn(tableMascotPOI) do
        --print("()xxxxx[:::::::::::::::> POI #: " .. tableMascotPOI[i])
    end
    --print("()xxxxx[:::::::::::::::> tableMascotPOI current size is: " .. table.getn(tableMascotPOI))
    --print("()xxxxx[:::::::::::::::> REMOVING POI: " .. tempPOIToRemove .. " from tableMascotPOI")
    table.remove(tableMascotPOI, tempPOIToRemove)
    --print("()xxxxx[:::::::::::::::> tableMascotPOI current size is: " .. table.getn(tableMascotPOI))
    --print("()xxxxx[:::::::::::::::> POI's remaining are")
    for i = 1, table.getn(tableMascotPOI) do
        --print("()xxxxx[:::::::::::::::> POI #: " .. tableMascotPOI[i])
    end
    if PlayerIsInStealthProp() then
        PedMakeAmbient(pedJockSmoke.id)
    else
        PedAttackPlayer(pedJockSmoke.id, 3)
    end
    bPOI03Active = false
    --print("()xxxxx[:::::::::::::::> [finish] F_DispersePOI03()")
end

function F_MascotFindObjective()
    --print("()xxxxx[:::::::::::::::> [start] F_MascotFindObjective()")
    local gNextPOI = math.random(1, table.getn(tableMascotPOI))
    while gNextPOI == gLastPOI do
        gNextPOI = math.random(1, table.getn(tableMascotPOI))
    end
    gMascotNextObjectiveElement = tableMascotPOI[gNextPOI]
    --print("()xxxxx[:::::::::::::::> [mascot] POI's remaining: " .. table.getn(tableMascotPOI))
    --print("()xxxxx[:::::::::::::::> [mascot] Moving to POI #: " .. gMascotNextObjectiveElement)
    PedMoveToPoint(pedMascot.id, 1, POINTLIST._4_05_MASCOTPOI, gMascotNextObjectiveElement, cbMascotReachedObjective)
    gLastPOI = gMascotNextObjectiveElement
    sMascotState = "moving"
    --print("()xxxxx[:::::::::::::::> [finish] F_MascotFindObjective()")
end

function F_MascotPerform()
    --print("()xxxxx[:::::::::::::::> [start] F_MascotPerform()")
    if gMascotNextObjectiveElement == 1 then
        if math.random(1, 2) == 1 then
            F_MascotDance()
        else
            F_MascotChatCheerleaders()
        end
        --print("()xxxxx[:::::::::::::::> [mascot] dance for cheerleaders")
        F_FinishedPerforming()
    elseif gMascotNextObjectiveElement == 2 then
        if math.random(1, 2) == 1 then
            F_MascotPushups()
        else
            F_MascotChat()
        end
        --print("()xxxxx[:::::::::::::::> [mascot] do pushups or chat")
        F_FinishedPerforming()
    elseif gMascotNextObjectiveElement == 3 then
        F_MascotChat()
        --print("()xxxxx[:::::::::::::::> [mascot] chat with smoker")
        F_FinishedPerforming()
    elseif gMascotNextObjectiveElement == 4 then
        PedFaceHeading(pedMascot.id, 10, 0)
        if math.random(1, 2) == 1 then
            F_MascotDance()
        else
            F_MascotPracticeCharge()
        end
        --print("()xxxxx[:::::::::::::::> [mascot] dance or practice charge moves")
        F_FinishedPerforming()
    elseif gMascotNextObjectiveElement == 5 then
        F_MascotSit()
        --print("()xxxxx[:::::::::::::::> [mascot] sits down")
        F_FinishedPerforming()
    end
    while sMascotState ~= "idle" do
        Wait(0)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_MascotPerform()")
end

function F_CheckMascotStatus()
    if PedIsHit(pedMascot.id, 2, 100) or F_MascotIsTaunted() then
        if PedGetLastHitWeapon(pedMascot.id) == 309 then
            if not bHitByStinkBomb then
                F_SpawnAJock()
                CounterSetCurrent(CounterGetCurrent() + 1)
                PedSetHealth(pedMascot.id, gMascotHealth)
                PedStop(pedMascot.id)
                PedClearObjectives(pedMascot.id)
                PedMoveToPoint(pedMascot.id, 1, POINTLIST._4_05_MASCOTPOI, 2, cbMascotReachedFleePoint)
                gStinkBombTimer = GetTimer()
                bHitByStinkBomb = true
            elseif gStinkBombTimer + 5000 <= GetTimer() then
                bHitByStinkBomb = false
            end
        else
            F_SpawnAJock()
            CounterSetCurrent(CounterGetCurrent() + 1)
            PedSetHealth(pedMascot.id, gMascotHealth)
            PedStop(pedMascot.id)
            PedClearObjectives(pedMascot.id)
            PedMoveToPoint(pedMascot.id, 1, POINTLIST._4_05_MASCOTPOI, 2, cbMascotReachedFleePoint)
            if GetTimer() > gMascotSpeechTimer + 5000 then
                SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 52, "large", false, true)
                gMascotSpeechTimer = GetTimer()
            end
        end
        if PedIsInTrigger(pedMascot.id, TRIGGER._4_05_MASCOTPOI1) then
            --print("()xxxxx[:::::::::::::::> Mascot Hit in POI 1")
            if bPOI01Active then
                F_DispersePOI01()
            end
        end
        if PedIsInTrigger(pedMascot.id, TRIGGER._4_05_MASCOTPOI2) then
            --print("()xxxxx[:::::::::::::::> Mascot Hit in POI 2")
            if bPOI02Active then
                F_DispersePOI02()
            end
        end
        if PedIsInTrigger(pedMascot.id, TRIGGER._4_05_MASCOTPOI3) then
            --print("()xxxxx[:::::::::::::::> Mascot Hit in POI 3")
            if bPOI03Active then
                F_DispersePOI03()
            end
        end
        if PedIsInTrigger(pedMascot.id, TRIGGER._4_05_MASCOTPOI4) then
            --print("()xxxxx[:::::::::::::::> Mascot Hit in POI 4")
            if not bHitMascotInPOI4 then
                if F_PedExists(pedJockSprint01.id) then
                    PedAttackPlayer(pedJockSprint01.id, 3)
                end
                bHitMascotInPOI4 = true
            end
        end
        if PedIsInTrigger(pedMascot.id, TRIGGER._4_05_MASCOTPOI5) then
            --print("()xxxxx[:::::::::::::::> Mascot Hit in POI 5")
            if not bHitMascotInPOI5 then
                bHitMascotInPOI5 = true
            end
        end
    end
    if CounterGetCurrent() >= 12 and not bMascotNeutral then
        CounterSetIcon("Bull_neutral", "Bull_neutral_x")
        SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 52, "jumbo", false, true)
        bMascotNeutral = true
    end
    if CounterGetCurrent() >= 24 and not bMascotPissed then
        CounterSetIcon("Bull_piss", "Bull_piss_x")
        SoundStopCurrentSpeechEvent(pedMascot.id)
        SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 44, "jumbo", false, true)
        bMascotPissed = true
    end
    if CounterGetCurrent() >= 36 and not PedIsPlaying(pedMascot.id, "/Global/Actions/Grapples", true) then
        bGoToStage2 = true
    end
end

function F_FinishedPerforming()
    --print("()xxxxx[:::::::::::::::> [start] F_FinishedPerforming()")
    bBreakMascotOutOfObjective = false
    sMascotState = "idle"
    --print("()xxxxx[:::::::::::::::> [finish] F_FinishedPerforming()")
end

function F_MascotDance()
    --print("()xxxxx[:::::::::::::::> [start] F_MascotDance()")
    sMascotState = "dancing"
    local gNumberOfDances = math.random(2, 5)
    local gWhichDance = 1
    --print("()xxxxx[:::::::::::::::> [mascot] Dancing: " .. gNumberOfDances .. " times.")
    SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 56, "large")
    for i = 1, gNumberOfDances do
        gWhichDance = math.random(1, 4)
        bMascotIsDancing = true
        if gWhichDance == 1 then
            PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/DanceA", "Act/Conv/4_05.act")
        elseif gWhichDance == 2 then
            PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/DanceB", "Act/Conv/4_05.act")
        elseif gWhichDance == 3 then
            PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/DanceC", "Act/Conv/4_05.act")
        else
            PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/DanceD", "Act/Conv/4_05.act")
        end
        --print("()xxxxx[:::::::::::::::> [mascot] Dance Move: " .. gWhichDance .. " which is " .. i .. " of " .. gNumberOfDances)
        while bMascotIsDancing do
            if bBreakMascotOutOfObjective then
                break
            end
            Wait(0)
        end
        if bBreakMascotOutOfObjective then
            break
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_MascotDance()")
end

function F_MascotChat()
    sMascotState = "chatting"
    --print("()xxxxx[:::::::::::::::> [start] F_MascotChat()")
    SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 53, "large")
    F_WaitForSpeech(pedMascot.id)
    Wait(2000)
    --print("()xxxxx[:::::::::::::::> [finish] F_MascotChat()")
end

function F_MascotChatCheerleaders()
    sMascotState = "chatting"
    --print("()xxxxx[:::::::::::::::> [start] F_MascotChatCheerleaders()")
    SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 55, "large")
    F_WaitForSpeech(pedMascot.id)
    Wait(2000)
    --print("()xxxxx[:::::::::::::::> [finish] F_MascotChatCheerleaders()")
end

function F_MascotPushups()
    sMascotState = "push-ups"
    --print("()xxxxx[:::::::::::::::> [start] F_MascotPushups()")
    SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 56, "large")
    PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/Pushups/Start", "Act/Conv/4_05.act")
    while PedIsPlaying(pedMascot.id, "/Global/4_05/Anims/MascotActions/Pushups", true) do
        Wait(0)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_MascotPushups()")
end

function F_MascotPracticeCharge()
    sMascotState = "practice charge"
    --print("()xxxxx[:::::::::::::::> [start] F_MascotPracticeCharge()")
    SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 56, "large")
    PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/PracticeCharge", "Act/Conv/4_05.act")
    while PedIsPlaying(pedMascot.id, "/Global/4_05/Anims/MascotActions/PracticeCharge", true) do
        Wait(0)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_MascotPracticeCharge()")
end

function F_MascotSit()
    sMascotState = "sitting"
    --print("()xxxxx[:::::::::::::::> [start] F_MascotSit()")
    local gNumberOfDances = math.random(2, 5)
    local gWhichDance = 1
    SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 56, "large")
    --print("()xxxxx[:::::::::::::::> [mascot] Dancing: " .. gNumberOfDances .. " times.")
    PedFaceHeading(pedMascot.id, 250, 0)
    for i = 1, gNumberOfDances do
        gWhichDance = math.random(1, 4)
        bMascotIsDancing = true
        if gWhichDance == 1 then
            PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/DanceA", "Act/Conv/4_05.act")
        elseif gWhichDance == 2 then
            PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/DanceB", "Act/Conv/4_05.act")
        elseif gWhichDance == 3 then
            PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/DanceC", "Act/Conv/4_05.act")
        else
            PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/MascotActions/DanceD", "Act/Conv/4_05.act")
        end
        --print("()xxxxx[:::::::::::::::> [mascot] Dance Move: " .. gWhichDance .. " which is " .. i .. " of " .. gNumberOfDances)
        while bMascotIsDancing do
            if bBreakMascotOutOfObjective then
                break
            end
            Wait(0)
        end
        if bBreakMascotOutOfObjective then
            break
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_MascotSit()")
end

function F_DoneDance()
    --print("()xxxxx[:::::::::::::::> [start] F_DoneDance()")
    bMascotIsDancing = false
    --print("()xxxxx[:::::::::::::::> [finish] F_DoneDance()")
end

function cbMascotReachedObjective()
    --print("()xxxxx[:::::::::::::::> [start] cbMascotReachedObjective()")
    sMascotState = "performing"
    --print("()xxxxx[:::::::::::::::> [finish] cbMascotReachedObjective()")
end

function cbMascotReachedFleePoint()
    --print("()xxxxx[:::::::::::::::> [start] cbMascotReachedFleePoint()")
    bBreakMascotOutOfObjective = true
    sMascotState = "idle"
    --print("()xxxxx[:::::::::::::::> [finish] cbMascotReachedFleePoint()")
end

function F_MascotIsTaunted()
    if bPlayerTauntedMascot then
        --print("()xxxxx[:::::::::::::::> [F_MascotIsTaunted] MASCOT WAS TAUNTED")
        Wait(1000)
        SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 52)
        bPlayerTauntedMascot = false
        return true
    else
        return false
    end
end

function F_cutMascotEnraged()
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    F_CleanupExtraJocks()
    F_MakePlayerSafeForNIS(true)
    SoundPlayStream("MS_ActionBeatBreak.rsm", 0.7, 0, 0)
    SoundDisableSpeech_ActionTree()
    PedSetActionNode(pedMascot.id, "/Global/4_05/Anims/Empty", "Act/Conv/4_05.act")
    PedSetActionNode(gPlayer, "/Global/4_05/Anims/Empty", "Act/Conv/4_05.act")
    PedStop(pedMascot.id)
    PedClearObjectives(pedMascot.id)
    PedSetStationary(pedMascot.id, true)
    PedFaceObject(pedMascot.id, gPlayer, 3, 0)
    local x1, y1, z1 = PedGetOffsetInWorldCoords(pedMascot.id, 1.25, 2.5, 1)
    local x2, y2, z2 = PedGetOffsetInWorldCoords(pedMascot.id, -1, -0.7, 1.2)
    CameraSetXYZ(x1, y1, z1, x2, y2, z2)
    CameraAllowChange(false)
    PedMoveToXYZ(gPlayer, 2, x1 + 5, y1 + 5, z1)
    SoundStopCurrentSpeechEvent(pedMascot.id)
    PedSetActionNode(pedMascot.id, "/Global/4_05/NIS/Mascot/Mascot01", "Act/Conv/4_05.act")
    SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 57, "jumbo", false, true)
    F_WaitForSpeech(pedMascot.id)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(500)
    --print("()xxxxx[:::::::::::::::> [F_cutMascotEnraged] USING NEW PEDFLAG START")
    PedSetFlag(gPlayer, 108, true)
    --print("()xxxxx[:::::::::::::::> [F_cutMascotEnraged] USING NEW PEDFLAG END")
    F_CleanupField()
    F_DisableAllPopulation()
    F_SetupFieldForCutscene()
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedSetActionNode(gPlayer, "/Global/4_05/Anims/Empty", "Act/Conv/4_05.act")
    PlayerSetPosPoint(POINTLIST._4_05CUT_SPAWNPLAYER, 1)
    CameraAllowChange(true)
    CameraSetXYZ(-21.520882, -72.65287, 1.166132, -22.4455, -72.928215, 1.428625)
    CameraAllowChange(false)
    CameraFade(500, 1)
    Wait(500)
    CreateThread("T_CutsceneMascotAngry")
    while not bSkipFirstCutscene do
        if IsButtonPressed(7, 0) then
            bSkipFirstCutscene = true
        end
        Wait(0)
    end
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(500)
    PedStop(pedMascot.id)
    PedClearObjectives(pedMascot.id)
    PedSetPosPoint(pedMascot.id, POINTLIST._4_05CUT_SPAWNMASCOT, 2)
    PedDelete(pedCutDan.id)
    PedDelete(pedCutKirby.id)
    PedStop(pedCutJuri.id)
    PedClearObjectives(pedCutJuri.id)
    PedStop(pedCutCasey.id)
    PedClearObjectives(pedCutCasey.id)
    PedStop(pedCutBo.id)
    PedClearObjectives(pedCutBo.id)
    PedSetPosPoint(pedCutJuri.id, POINTLIST._4_05CUT_SPAWNJURI, 2)
    PedSetPosPoint(pedCutCasey.id, POINTLIST._4_05CUT_SPAWNCASEY, 2)
    PedSetPosPoint(pedCutBo.id, POINTLIST._4_05CUT_SPAWNBO, 2)
    PedIgnoreAttacks(pedCutJuri.id, true)
    PedIgnoreAttacks(pedCutCasey.id, true)
    PedIgnoreAttacks(pedCutBo.id, true)
    PAnimDelete(TRIGGER._DT_TSCHOOL_POOLL)
    PAnimCreate(TRIGGER._4_05CUT_FAKEDOOR)
    F_SetupNerdsForCutscene()
    PedClearObjectives(gPlayer)
    PedStop(gPlayer)
    PlayerSetPosPoint(POINTLIST._4_05CUT_SPAWNPLAYER, 2)
    CameraSetXYZ(55.750095, -97.229095, 9.53612, 55.246677, -96.42208, 9.227898)
    CameraAllowChange(false)
    CameraFade(500, 1)
    Wait(500)
    CreateThread("T_CutsceneNerdAmbush")
    while not bSkipSecondCutscene do
        if IsButtonPressed(7, 0) then
            bSkipSecondCutscene = true
        end
        Wait(0)
    end
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(500)
    PedSetFlag(gPlayer, 108, false)
    CameraAllowChange(true)
    CameraReturnToPlayer()
    CameraReset()
    UnLoadAnimationGroup("NIS_4_05")
    F_CleanupCutPeds()
    SoundEnableSpeech_ActionTree()
end

function cbMascotFledToPool(pedID, pathID, nodeID)
    --print("()xxxxx[:::::::::::::::> cbMascotFledToPool() @ node : " .. nodeID)
    if nodeID == 1 then
        bGoToStage3 = true
    end
end

function F_CutStealCostume() -- ! Modified
    --print("()xxxxx[:::::::::::::::> [start] F_CutStealCostume()")
    PlayerSetControl(0)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(-1, 0)
    Wait(500)
    PedDelete(pedMascot.id)
    F_MakePlayerSafeForNIS(true, false)
    CameraSetWidescreen(true)
    PlayerSetPosPoint(POINTLIST._4_05CUT_POOLJIMMY)
    pedDeadMascot = PedCreatePoint(88, POINTLIST._4_05CUT_POOLCONST, 1)
    PedSetPedToTypeAttitude(pedDeadMascot, 13, 4)
    Wait(200)
    PedSetActionNode(pedDeadMascot, "/Global/4_05/Anims/StealCostumeCut/KnockedOut", "Act/Conv/4_05.act")
    Wait(100)
    CameraSetXYZ(-674.7147, -65.22737, 55.77168, -675.0499, -64.290924, 55.87489)
    CameraFade(-1, 1)
    Wait(500)
    --[[
    PedFollowPath(gPlayer, PATH._4_05CUT_POOLJIMMY, 0, 0, cbPlayerKneel)
    ]] -- Removed this
    SoundPlayScriptedSpeechEventWrapper(gPlayer, "M_4_05", 47)
    F_WaitForSpeech(gPlayer)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(500)
    ClothingSetPlayerOutfit("Mascot")
    ClothingBuildPlayer()
    PedDelete(pedDeadMascot)
    pedStrippedKid = PedCreatePoint(235, POINTLIST._4_05CUT_POOLCONST, 1)
    PedSetPedToTypeAttitude(pedStrippedKid, 13, 4)
    local x, y, z = GetPointList(POINTLIST._4_05CUT_POOLJIMMY02)
    PlayerSetPosSimple(x, y, z)
    Wait(200)
    PedSetActionNode(pedStrippedKid, "/Global/4_05/Anims/StealCostumeCut/KnockedOut", "Act/Conv/4_05.act")
    PedSetActionNode(gPlayer, "/Global/4_05/Anims/StealCostumeCut/Dance", "Act/Conv/4_05.act")
    Wait(100)
    CameraSetXYZ(-673.1245, -59.698437, 55.635456, -673.6623, -60.501358, 55.892105)
    CameraFade(500, 1)
    Wait(501)
    MinigameSetCompletion("M_PASS", true, 0, "4_05_MPASS01")
    MinigameAddCompletionMsg("MRESPECT_NP5", 2)
    MinigameAddCompletionMsg("MRESPECT_JM10", 1)
    SoundPlayAmbientSpeechEvent(pedStrippedKid, "WHINE")
    SoundPlayMissionEndMusic(true, 4)
    Wait(1000)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    Wait(1000)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    PedSetActionNode(gPlayer, "/Global/4_05/Anims/Empty", "Act/Conv/4_05.act")
    bMissionPassed = true
    bCostumeSpawned = true
    --print("()xxxxx[:::::::::::::::> [finish] F_CutStealCostume()")
    SetFactionRespect(2, GetFactionRespect(2) - 10)
    SetFactionRespect(1, GetFactionRespect(1) + 5)
    MissionSucceed(false, false, false)
end

function T_MonitorMascotField()
    while bMonitorMascotField do
        if sMascotState == "idle" then
            F_MascotFindObjective()
        elseif sMascotState == "performing" then
            F_MascotPerform()
        end
        Wait(0)
    end
    collectgarbage()
end

function T_MonitorMascotForHits()
    while bMonitorMascotField do
        F_CheckMascotStatus()
        Wait(0)
    end
    collectgarbage()
end

function T_MonitorFieldTriggers()
    while bMonitorMascotField do
        if bPOI01Active then
            if bCheering then
                if PedIsInTrigger(pedMascot.id, TRIGGER._4_05_MASCOTPOI1) then
                    F_StopCheering()
                    bCheering = false
                end
            elseif not PedIsInTrigger(pedMascot.id, TRIGGER._4_05_MASCOTPOI1) then
                F_StartCheering()
                bCheering = true
            end
            if F_CheckCheerleaders() then
                F_DispersePOI01()
            end
        end
        if bPOI02Active then
            if bPushups then
                if PedIsInTrigger(pedMascot.id, TRIGGER._4_05_MASCOTPOI2) then
                    F_StopPushups()
                    bPushups = false
                end
            elseif not PedIsInTrigger(pedMascot.id, TRIGGER._4_05_MASCOTPOI2) then
                F_StartPushups()
                bPushups = true
            end
        end
        if bPOI03Active and F_CheckSmoker() then
            F_DispersePOI03()
        end
        Wait(0)
    end
    collectgarbage()
end

function T_MonitorMascotPool()
    while bMonitorMascotPool do
        if PedGetHealth(pedMascot.id) <= gMascotHalfHealth then
            SoundStopCurrentSpeechEvent(pedMascot.id)
            SoundPlayScriptedSpeechEvent(pedMascot.id, "M_4_05", 58, "large", false, true)
            --print("()xxxxx[:::::::::::::::> [mascot] Switching to fight pattern 1")
            gFightPattern = 1
            break
        end
        Wait(0)
    end
    collectgarbage()
end

function T_MissionTextQueue()
    --print("()xxxxx[:::::::::::::::> [start] T_MissionTextQueue()")
    while bLoop do
        UpdateTextQueue()
        Wait(0)
    end
    collectgarbage()
    --print("()xxxxx[:::::::::::::::> [finish] T_MissionTextQueue()")
end

function T_CutsceneMascotAngry()
    if not bSkipFirstCutscene then
        PedFaceObject(pedCutBo.id, gPlayer, 2, 0)
        PedFaceObject(pedCutCasey.id, gPlayer, 2, 0)
        PedFaceObject(pedCutJuri.id, gPlayer, 2, 0)
        PedMoveToPoint(pedCutKirby.id, 1, POINTLIST._4_05CUT_KIRBYMOVE)
        PedMoveToPoint(pedCutDan.id, 1, POINTLIST._4_05CUT_DANMOVE)
        PedSetActionNode(pedCutBo.id, "/Global/4_05/NIS/Jocks/Bo_01", "Act/Conv/4_05.act")
        SoundPlayScriptedSpeechEvent(pedCutBo.id, "M_4_05", 40, "jumbo")
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(pedCutBo.id)
    end
    if not bSkipFirstCutscene then
        PedSetActionNode(pedCutCasey.id, "/Global/4_05/NIS/Jocks/Casey_01", "Act/Conv/4_05.act")
        SoundPlayScriptedSpeechEvent(pedCutCasey.id, "M_4_05", 39, "jumbo")
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(pedCutCasey.id)
    end
    if not bSkipFirstCutscene then
        PedSetActionNode(pedCutBo.id, "/Global/4_05/NIS/Jocks/Bo_02", "Act/Conv/4_05.act")
        SoundPlayScriptedSpeechEvent(pedCutBo.id, "M_4_05", 13, "large")
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(pedCutBo.id)
    end
    if not bSkipFirstCutscene then
        CameraAllowChange(true)
        CameraSetXYZ(-22.24371, -72.63743, 2.353733, -21.25111, -72.619514, 2.470597)
        SoundDisableSpeech_ActionTree()
        SoundPlayScriptedSpeechEvent(pedCutJuri.id, "M_4_05", 45, "large")
        PedFollowPath(gPlayer, PATH._4_05CUT_JIMMYFLEE, 0, 2)
        PedFollowPath(pedMascot.id, PATH._4_05CUT_MASCOTCHASE, 0, 2)
        SoundPlayScriptedSpeechEvent(pedCutBo.id, "CHASE", 0, "supersize")
        Wait(1000)
        SoundPlayStream("MS_ActionHigh_NISReturn.rsm", 0.7, 0)
    end
    if not bSkipFirstCutscene then
        WaitSkippable(1000)
    end
    if not bSkipFirstCutscene then
        PedFollowPath(pedCutJuri.id, PATH._4_05CUT_JOCKSCHASE03, 0, 2)
        PedFollowPath(pedCutBo.id, PATH._4_05CUT_JOCKSCHASE02, 0, 2)
    end
    if not bSkipFirstCutscene then
        WaitSkippable(1000)
    end
    if not bSkipFirstCutscene then
        PedFollowPath(pedCutCasey.id, PATH._4_05CUT_JOCKSCHASE, 0, 2)
    end
    if not bSkipFirstCutscene then
        WaitSkippable(1000)
    end
    if not bSkipFirstCutscene then
        PedFollowPath(pedCutDan.id, PATH._4_05CUT_JOCKSCHASE03, 0, 2)
        PedFollowPath(pedCutKirby.id, PATH._4_05CUT_JOCKSCHASE, 0, 2)
    end
    if not bSkipFirstCutscene then
        WaitSkippable(2000)
    end
    bSkipFirstCutscene = true
end

function T_CutsceneNerdAmbush()
    if not bSkipSecondCutscene then
        PedSetInvulnerable(pedMascot.id, true)
        PedIgnoreAttacks(pedMascot.id, true)
        PedFollowPath(gPlayer, PATH._4_05CUT_JIMMYTOPOOL, 0, 1, cbFakePlayer)
        PedFollowPath(pedMascot.id, PATH._4_05CUT_JIMMYTOPOOL, 0, 1)
    end
    if not bSkipSecondCutscene then
        WaitSkippable(3000)
    end
    if not bSkipSecondCutscene then
        PedSetPedToTypeAttitude(pedCutJuri.id, 13, 4)
        PedSetPedToTypeAttitude(pedCutBo.id, 13, 4)
        PedSetPedToTypeAttitude(pedCutCasey.id, 13, 4)
        PedStop(pedCutJuri.id)
        PedClearObjectives(pedCutJuri.id)
        PedStop(pedCutBo.id)
        PedClearObjectives(pedCutBo.id)
        PedStop(pedCutCasey.id)
        PedClearObjectives(pedCutCasey.id)
        PedFollowPath(pedCutJuri.id, PATH._4_05CUT_JURI, 0, 2, F_cutPathJuri)
        PedFollowPath(pedCutBo.id, PATH._4_05CUT_BO, 0, 2, F_cutPathBo)
        PedFollowPath(pedCutCasey.id, PATH._4_05CUT_CASEY, 0, 2, F_cutPathCasey)
        PedAttack(pedCutThad.id, pedCutJuri.id, 3)
        PedAttack(pedCutBucky.id, pedCutBo.id, 3)
        PedAttack(pedCutCornelius.id, pedCutCasey.id, 3)
    end
    if not bSkipSecondCutscene then
        WaitSkippable(3000)
    end
    if not bSkipSecondCutscene then
        SoundPlayScriptedSpeechEventWrapper(pedCutThad.id, "M_4_05", 8, "jumbo")
        CameraLookAtObject(pedCutThad.id, 2, false, 1)
        PedLockTarget(pedCutJuri.id, pedCutThad.id, 3)
        PedLockTarget(pedCutBo.id, pedCutBucky.id, 3)
        PedLockTarget(pedCutCasey.id, pedCutCornelius.id, 3)
    end
    if not bSkipSecondCutscene then
        WaitSkippable(1000)
    end
    if not bSkipSecondCutscene then
        SoundPlayScriptedSpeechEventWrapper(pedCutCasey.id, "M_4_05", 15, "jumbo")
    end
    if not bSkipSecondCutscene then
        WaitSkippable(1000)
    end
    if not bSkipSecondCutscene then
        CameraAllowChange(true)
        CameraSetXYZ(60.0062, -69.80368, 10.261972, 59.549133, -70.686714, 10.155866)
        CameraAllowChange(false)
        SoundPlayScriptedSpeechEventWrapper(pedCutJuri.id, "M_4_05", 17, "jumbo")
    end
    if not bSkipSecondCutscene then
        WaitSkippable(1000)
    end
    if not bSkipSecondCutscene then
        SoundPlayScriptedSpeechEventWrapper(pedCutBo.id, "M_4_05", 16, "jumbo")
    end
    if not bSkipSecondCutscene then
        WaitSkippable(2000)
    end
    CameraAllowChange(true)
    bSkipSecondCutscene = true
end

function cbFakePlayer(pedID, pathID, nodeID)
    if nodeID == 6 then
        PAnimOpenDoor(TRIGGER._4_05CUT_FAKEDOOR)
    end
end

function cbSpawnedJockArrived(pedID)
    if PlayerIsInTrigger(TRIGGER._4_05_FIELD) then
        PedAttackPlayer(pedID, 3)
    else
        PedMakeAmbient(pedID)
    end
end

function cbPlayerKneel(pedID, pathID, nodeID)
    if nodeID == 1 then
        PedSetActionNode(gPlayer, "/Global/4_05/Anims/StealCostumeCut/Kneel", "Act/Conv/4_05.act")
    end
end

function F_cutPathJuri(pedID, pathID, nodeID)
    if nodeID == 5 then
        PedFaceObject(pedID, pedCutThad.id, 2, 0)
        PedSetActionNode(pedID, "/Global/4_05/Anims/NISJocksTaunt/Taunt1", "Act/Conv/4_05.act")
    end
end

function F_cutPathBo(pedID, pathID, nodeID)
    if nodeID == 5 then
        PedFaceObject(pedID, pedCutBucky.id, 2, 0)
        PedSetActionNode(pedID, "/Global/4_05/Anims/NISJocksTaunt/Taunt2", "Act/Conv/4_05.act")
    end
end

function F_cutPathCasey(pedID, pathID, nodeID)
    if nodeID == 5 then
        PedFaceObject(pedID, pedCutCornelius.id, 2, 0)
        PedSetActionNode(pedID, "/Global/4_05/Anims/NISJocksTaunt/Taunt3", "Act/Conv/4_05.act")
    end
end
