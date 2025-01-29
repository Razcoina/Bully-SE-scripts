ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibPed.lua")
local russell, russellstarthealth
local gRussellAngry = false
local gCrowdHushUp = false
local crowds = {}
local mission_success = false
local holeGateCloseIndex, holeGateCloseGeometry
local gPlayingFail = true
local RUSSELL_HEALTH = true
local GET_RUSSELL_HEALTH = 0
local RUSSELL_BESERK = false
local CHECK_RUSSELL = true
local gRandomizer = 0
local tblCheerJimmy = {
    "Algie_FIGHW_v1",
    "Corneli_FIGHW",
    "RUSS_GRUNT"
}
local tblCheerRussell = {
    "Trent_FIGHW_v1",
    "Gary_FIGHW_v2",
    "RUSS_ROAR"
}
local tblCheer = {
    "Gary_FIGHW_v1",
    "Lola_FIGHW_v2",
    "Gord_FIGHW_v1"
}
local gRussellTalks = false
local gFirstObj

function CrowdsSetup()
    crowdModels = {
        35,
        37,
        38,
        23,
        25,
        29,
        12,
        19,
        14,
        99,
        130,
        85,
        6,
        10,
        5
    }
    LoadModels(crowdModels)
    L_PedLoadPoint("CheerDudes", {
        {
            model = 35,
            point = POINTLIST._1_B_CROWD02
        },
        {
            model = 37,
            point = POINTLIST._1_B_CROWD03
        },
        {
            model = 38,
            point = POINTLIST._1_B_CROWD04
        },
        {
            model = 23,
            point = POINTLIST._1_B_CROWD08
        },
        {
            model = 25,
            point = POINTLIST._1_B_CROWD09
        },
        {
            model = 29,
            point = POINTLIST._1_B_CROWD10
        },
        {
            model = 12,
            point = POINTLIST._1_B_CROWD11
        },
        {
            model = 19,
            point = POINTLIST._1_B_CROWD12
        },
        {
            model = 14,
            point = POINTLIST._1_B_CROWD13
        },
        {
            model = 99,
            point = POINTLIST._1_B_CROWD14
        },
        {
            model = 130,
            point = POINTLIST._1_B_CROWD15
        },
        {
            model = 85,
            point = POINTLIST._1_B_CROWD16
        },
        {
            model = 6,
            point = POINTLIST._1_B_CROWD19
        },
        {
            model = 10,
            point = POINTLIST._1_B_CROWD20
        },
        {
            model = 5,
            point = POINTLIST._1_B_CROWD21
        }
    })
    L_PedExec("CheerDudes", PedMakeTargetable, "id", false)
    L_PedExec("CheerDudes", PedSetCheap, "id", true)
    L_PedExec("CheerDudes", PedSetStationary, "id", true)
    L_PedExec("CheerDudes", PedSetTaskNode, "id", "/Global/AI/ScriptedAI/CheeringAINode", "Act/AI/AI.act")
    --print(">>>[RUI]", "++CrowdsCleanup")
end

function CrowdsCleanup()
    if not bCrowdsCleanedup then
        bCrowdsCleanedup = true
        L_PedDeleteGroup("CheerDudes")
        --print(">>>[RUI]", "--CrowdsCleanup")
    end
    UnloadModels(crowdModels)
end

function CreateRussell()
    LoadAnimationGroup("Russell")
    russell = PedCreatePoint(75, POINTLIST._1_B_RUSSELL)
    PedSetActionTree(russell, "/Global/BOSS_Russell", "Act/Anim/Boss_Russell.act")
    PedSetCombatZoneMask(russell, false, true, true)
    PedSetStatsType(russell, "STAT_BOSS_RUSSELL")
    PedSetDamageTakenMultiplier(russell, 0, 0.5)
    PedSetDamageTakenMultiplier(russell, 3, 0.2)
    PedSetDamageTakenMultiplier(russell, 0, 0.3)
    PedIgnoreStimuli(russell, true)
    russellstarthealth = PedGetHealth(russell)
end

function BeatRussell()
    if PedIsDead(russell) then
        MissionObjectiveComplete(gFirstObj)
        mission_success = true
        return true
    else
        return false
    end
end

function F_RusselGroundCheck()
    if PedIsPlaying(russell, "/Global/HitTree/Standing/PostHit/BellyUp/DownOnGround", true) then
        Wait(1000)
        if PedIsPlaying(russell, "/Global/HitTree/Standing/PostHit/BellyUp/DownOnGround", true) then
            --print(">>>[RUI]", "F_RusselGroundCheck  PedSetActionNode(russell, /Global/BOSS_Russell/Default_KEY/RisingAttacks/HeavyAttacks/RisingAttacks")
            PedSetActionNode(russell, "/Global/BOSS_Russell/Default_KEY/RisingAttacks/HeavyAttacks/RisingAttacks", "Act/Anim/Boss_Russell.act")
        end
    elseif PedIsPlaying(russell, "/Global/HitTree/Standing/PostHit/BellyDown/DownOnGround", true) then
        Wait(1000)
        if PedIsPlaying(russell, "/Global/HitTree/Standing/PostHit/BellyDown/DownOnGround", true) then
            --print(">>>[RUI]", "F_RusselGroundCheck /Global/BOSS_Russell/Default_KEY/RisingAttacks/HeavyAttacks/RisingAttacks")
            PedSetActionNode(russell, "/Global/BOSS_Russell/Default_KEY/RisingAttacks/HeavyAttacks/RisingAttacks", "Act/Anim/Boss_Russell.act")
        end
    elseif PedIsPlaying(russell, "/Global/HitTree/Standing/PostHit/SitOnWall/DownOnGround/Sit", true) then
        Wait(1000)
        --print(">>>[RUI]", "F_RusselGroundCheck  /Global/BOSS_Russell/Default_KEY/RisingAttacks/HeavyAttacks/RisingAttacks")
        PedSetActionNode(russell, "/Global/BOSS_Russell/Default_KEY/RisingAttacks/HeavyAttacks/RisingAttacks", "Act/Anim/Boss_Russell.act")
    end
end

function F_CanRussellTalk()
    if not gRussellAngry then
        return 1
    else
        return 0
    end
end

function F_RussellTalks()
    gRussellTalks = true
end

function T_RussellTalks()
    while not L_ObjectiveProcessingDone() do
        if gRussellTalks then
            gCrowdHushUp = true
            ChooseLine = math.random(1, 6)
            Wait(500)
            if ChooseLine == 1 then
                SoundPlayScriptedSpeechEvent(russell, "M_1_B", 8, "large")
                Wait(3000)
            elseif ChooseLine == 2 then
                SoundPlayScriptedSpeechEvent(russell, "M_1_B", 10, "large")
                Wait(3000)
            elseif ChooseLine == 3 then
                SoundPlayScriptedSpeechEvent(russell, "M_1_B", 12, "large")
                Wait(3000)
            else
                SoundPlayScriptedSpeechEvent(russell, "M_1_B", 2, "large")
            end
            gCrowdHushUp = false
            gRussellTalks = false
        end
        Wait(0)
    end
end

function TimerPassed(time)
    return time <= GetTimer()
end

function CrowdCheers()
    if not gCrowdCheerTime then
        gCrowdCheerTime = GetTimer() + 5000
    elseif TimerPassed(gCrowdCheerTime) then
        local sound = RandomTableElement(tblCrowdCheers)
        local sx, sy, sz = GetPointFromPointList(sound.point, 1)
        SoundPlay3D(sx, sy, sz, sound.sfx)
        --print(">>>[RUI]", "++CrowdCheers")
        gCrowdCheerTime = GetTimer() + 5000 + math.random(2000, 5000)
    end
end

function T_CrowdCheering()
    SoundPlayAmbience("Fight_Group_Sml_Int.rsm", 0.5)
    while not L_ObjectiveProcessingDone() do
        CrowdCheers()
        Wait(12000)
        Wait(0)
    end
    SoundFadeoutAmbience(500)
end

function F_RusselCalm()
    RUSSELL_BESERK = false
    GET_RUSSELL_HEALTH = true
    PedOverrideStat(russell, 13, 10)
    --print("F_RusselCalm ==================RUSSELL IS CALM AGAIN==========================")
end

function F_RusselUninterupt()
    if RUSSELL_BESERK == true then
        return 1
    else
        return 0
    end
end

function PlayerDie()
    if F_PlayerIsDead() then
        MinigameSetCompletion("M_FAIL", false, 0, "1_B_PLAYERKO")
        SoundPlayMissionEndMusic(false, 10)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        CameraFade(500, 0)
        Wait(501)
        mission_success = false
        return true
    else
        return false
    end
end

function CB_PlayerDead()
    mission_success = false
end

function MissionSetup()
    DisablePunishmentSystem(true)
    PlayCutsceneWithLoad("1-B", true)
    NonMissionPedGenerationDisable()
    DATLoad("1_B.DAT", 2)
    DATInit()
    MissionDontFadeIn()
    LoadAnimationGroup("STRAF_WREST")
    LoadAnimationGroup("C_Wrestling")
    AreaTransitionPoint(8, POINTLIST._1_B_PLAYER, 1, true)
    DeletePersistentEntity(shared.gHoleGateOpenIndex, shared.gHoleGateOpenGeometry)
    holeGateCloseIndex, holeGateCloseGeometry = CreatePersistentEntity("FightPit_DoorClose", -771.439, -127.039, 8.801, 0, 8)
    tblCrowdCheers = {
        {
            sfx = "Gary_FIGHW_v1",
            point = POINTLIST._1_B_CROWD15
        },
        {
            sfx = "Gary_FIGHW_v2",
            point = POINTLIST._1_B_CROWD15
        },
        {
            sfx = "Lola_FIGHW_v1",
            point = POINTLIST._1_B_CROWD09
        },
        {
            sfx = "Gord_FIGHW_v1",
            point = POINTLIST._1_B_CROWD03
        },
        {
            sfx = "Corneli_FIGHW",
            point = POINTLIST._1_B_CROWD20
        },
        {
            sfx = "Trent_FIGHW_v1",
            point = POINTLIST._1_B_CROWD14
        },
        {
            sfx = "Algie_FIGHW_v1",
            point = POINTLIST._1_B_CROWD21
        }
    }
    PlayerIgnoreTargeting(true)
    PickupSetIgnoreRespawnDistance(true)
    CreateRussell()
    CrowdsSetup()
    if PlayerGetHealth() < 200 then
        PlayerSetHealth(200)
    end
    PedSetFlag(gPlayer, 58, true)
    PedSetAIButes("Russell")
    LoadActionTree("Act/AI/AI_RUSSEL_1_B.act")
    PedSaveWeaponInventorySnapshot(gPlayer)
    PlayerSuppressFailDisplayOnDeath()
end

function MissionCleanup()
    DisablePunishmentSystem(false)
    if holeGateCloseIndex ~= nil or holeGateCloseGeometry ~= nil then
        DeletePersistentEntity(holeGateCloseIndex, holeGateCloseGeometry)
        shared.gHoleGateOpenIndex, shared.gHoleGateOpenGeometry = CreatePersistentEntity("FightPit_DoorOpen", -770.009, -127.039, 8.801, 0, 8)
        holeGateCloseIndex = nil
        holeGateCloseGeometry = nil
    end
    UnLoadAnimationGroup("Russell")
    UnLoadAnimationGroup("STRAF_WREST")
    UnLoadAnimationGroup("C_Wrestling")
    CrowdsCleanup()
    NonMissionPedGenerationEnable()
    SoundFadeoutAmbience(500)
    SoundStopInteractiveStream()
    PickupSetIgnoreRespawnDistance(false)
    CameraAllowChange(true)
    CameraReturnToPlayer()
    FollowCamDefaultFightShot()
    PlayerSetPosPoint(POINTLIST._1_B_BOOKIE)
    PlayerWeaponHudLock(false)
    PedSetFlag(gPlayer, 58, false)
    PedSetAIButes("Default")
    PlayerIgnoreTargeting(false)
    DATUnload(2)
    PedHideHealthBar()
    ToggleHUDComponentVisibility(11, true)
    ToggleHUDComponentVisibility(0, true)
    ToggleHUDComponentVisibility(12, true)
end

function SecondStageCutscene()
    if PedGetHealth(russell) / russellstarthealth * 100 <= 50 then
        gRussellAngry = true
        return true
    else
        return false
    end
end

function ActionSecondStageCutscene()
    gCrowdHushUp = true
    CameraAllowChange(true)
    CameraFade(1000, 0)
    PlayerSetControl(0)
    PedClearObjectives(russell)
    PedSetAsleep(russell, true)
    Wait(1000)
    CrowdsCleanup()
    PlayCutsceneWithLoad("1-BB", true)
    gPlayingFail = false
end

function main()
    MissionSetAutoRestart(true)
    SoundPlayStream("MS_RussellInTheHole.rsm", 0.7)
    PedShowHealthBar(russell, true, "1_B_BAR_RUSSELL", true)
    gFirstObj = MissionObjectiveAdd("1_B_OBJ")
    MissionObjectiveReminderTime(-1)
    L_ObjectiveSetParam({
        objSecondStageCutscene = {
            successConditions = { SecondStageCutscene },
            stopOnCompleted = false
        },
        objBeatRussell = {
            successConditions = { BeatRussell },
            stopOnCompleted = true
        },
        objPlayerDie = {
            successConditions = { PlayerDie },
            stopOnCompleted = true
        }
    })
    PedLockTarget(gPlayer, russell)
    PedFaceObject(gPlayer, russell, 2, 1)
    PedFaceObject(russell, gPlayer, 2, 1)
    CameraFade(1000, 1)
    CameraSetSecondTarget(russell)
    FollowCamSetFightShot("1_B_X")
    CameraSetShot(1, "1_B_X", true)
    Wait(1000)
    PlayerSetControl(1)
    PedSetAITree(russell, "/Global/RusselAI", "Act/AI/AI_RUSSEL_1_B.act")
    PedAttack(russell, gPlayer, 3)
    CreateThread("T_CrowdCheering")
    CreateThread("T_RussellTalks")
    while not L_ObjectiveProcessingDone() do
        F_ObjectiveMonitor()
        Wait(0)
    end
    gCrowdHushUp = true
    Wait(1000)
    if mission_success then
        CameraFade(1000, 0)
        CameraAllowChange(true)
        Wait(1000)
        CrowdsCleanup()
        DeletePersistentEntity(holeGateCloseIndex, holeGateCloseGeometry)
        shared.gHoleGateOpenIndex, shared.gHoleGateOpenGeometry = CreatePersistentEntity("FightPit_DoorOpen", -770.009, -127.039, 8.801, 0, 8)
        holeGateCloseIndex = nil
        holeGateCloseGeometry = nil
        PlayerSetScriptSavedData(14, 0)
        PlayCutsceneWithLoad("1-BC", true)
        MissionSetAutoRestart(false)
        PedDeleteWeaponInventorySnapshot(gPlayer)
        SetFactionRespect(11, 100)
        SetFactionRespect(1, 85)
        SetFactionRespect(5, 50)
        UnlockYearbookPicture(75)
        F_UnlockYearbookReward()
        MissionSucceed(true, false, false)
    else
        ActionSecondStageCutscene()
        while gPlayingFail do
            Wait(0)
        end
        MissionSetAutoRestart(false)
        PedRestoreWeaponInventorySnapshot(gPlayer)
        MissionFail(true, false)
    end
end
