--[[ Changes to this file:
    * Removed function TestJohnny, not present in original script
    * Modified function T_MagnetVibrate, may require testing
]]

local bMissionRunning = true
local bPassedMission = false
local gObjective, gFailMessage
local MAX_JOHNNY_HEALTH = 500
local BIKE_REENTRY_DELAY = 5000
local BIKE_COUNTDOWN_MAX = 5
local STAGE_NONE = -1
local STAGE_START = 0
local STAGE_COP_CHASE = 1
local STAGE_BIKE_BATTLE = 2
local STAGE_JOHNNY_BATTLE = 3
local gCurrentStage = STAGE_START
local gPlayerBike, gJohnnyV, gJohnnyBike, gJV_OnBike, gJV_Bike, ThePipeIndex, ThePipeType, BikeIndex, BikeType, GreaseTable, gCopChaseCar, gChaseCarDriver
local CleanFirstDudes = true
local StartStage1 = false
local StartStage3 = true
local bCopChaseCarDistanceCheck = false
local bJohnnyCanAvoid = false
local JohnnyPrepAttack = false
local bJohnnyKnockDown = false
local bMagnetOn = false
local gCraneIndex, gCraneLights, gButtonIndex, gCraneButton, gPeter
local bAllBadGuysDead = false
local gPerimeterGreasers = {}
local gTotalDead = 0
local gPeterCurrentPath, gPeterCurrentPath_Length, gPeterCurrentPath_Arrival
local bPeterIsMovingAlready = false
local bPeterAtCrane = false
local gPeterStateCrouched = false
local gFirstAttempt = true

function MissionSetup()
    MissionDontFadeIn()
    SoundEnableInteractiveMusic(false)
    DisablePunishmentSystem(true)
    DATLoad("3_B.DAT", 2)
    DATLoad("3_B_BIKE_STUFF.DAT", 2)
    DATInit()
    LoadAnimationGroup("3_BFightJohnnyV")
    LoadAnimationGroup("P_Striker")
    LoadAnimationGroup("Boxing")
    LoadAnimationGroup("NIS_3_B")
    LoadActionTree("Act/Conv/3_B.act")
    LoadActionTree("Act/Anim/G_Ranged_A.act")
    CameraFade(1000, 0)
    if PlayerIsInAnyVehicle() then
        PlayerDetachFromVehicle()
    end
    PedSaveWeaponInventorySnapshot(gPlayer)
    if PlayerGetHealth() < 200 then
        PlayerSetHealth(200)
    end
    PedSetFlag(gPlayer, 58, true)
    F_RainBeGone()
    PlayerSetControl(0)
end

function MissionCleanup()
    --print(">>>[RUI]", "MissionCleanup")
    PlayerSetControl(1)
    ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrate")
    F2_CraneBlipCleanup()
    SoundStopInteractiveStream()
    SoundEnableInteractiveMusic(true)
    SoundFadeWithCamera(true)
    DisablePunishmentSystem(false)
    PedSetFlag(gPlayer, 58, false)
    WeatherSet(1)
    WeatherRelease()
    if PlayerHasWeapon(418) then
        PedSetWeaponNow(gPlayer, -1, 1)
    end
    if bHealthBarOn then
        PedHideHealthBar()
    end
    if RESTORE_AI_BUTES then
        PedSetAIButes("Default")
    end
    if PlayerIsInAnyVehicle() then
        PlayerDismountBike()
    end
    CopsCleanup()
    VehicleCleanup(gCopChaseCar, gChaseCarDriver, true)
    VehicleCleanup(gPlayerBike)
    VehicleCleanup(gJohnnyBike, gJohnnyV)
    if BikeIndex ~= nil then
        DeletePersistentEntity(BikeIndex, BikeType)
    end
    if ThePipeIndex ~= nil then
        DeletePersistentEntity(ThePipeIndex, ThePipeType)
    end
    if gCraneIndex ~= nil then
        DeletePersistentEntity(gCraneIndex, gCraneLights)
    end
    if gButtonIndex ~= nil then
        DeletePersistentEntity(gButtonIndex, gCraneButton)
    end
    FollowCamDefaultVehicleShot()
    PedSetPunishmentPoints(gPlayer, 0)
    UnLoadAnimationGroup("3_BFightJohnnyV")
    UnLoadAnimationGroup("P_Striker")
    UnLoadAnimationGroup("Boxing")
    UnLoadAnimationGroup("NIS_3_B")
    CameraAllowChange(true)
    CameraReset()
    CameraReturnToPlayer()
    FollowCamDefaultFightShot()
    CameraSetWidescreen(false)
    DATUnload(2)
    --print(">>>[RUI]", "--MissionCleanup")
end

function MissionInit()
    --print(">>>[RUI]", "++MissionInit")
    PedSetHealth(gPlayer, PedGetMaxHealth(gPlayer))
    gFirstAttempt = false
    if shared.g3BMissionState == STAGE_START then
        AreaTransitionPoint(43, POINTLIST._PLAYER_FIRSTSTART, 1, true)
        PlayerSetControl(0)
        gCurrentStage = STAGE_START
        gFirstAttempt = true
    elseif shared.g3BMissionState == STAGE_COP_CHASE then
        gCurrentStage = STAGE_COP_CHASE
    elseif shared.g3BMissionState == STAGE_BIKE_BATTLE then
        gCurrentStage = STAGE_BIKE_BATTLE
        --print(">>>[RUI]", "??MissionINIT  STAGE 2")
    elseif shared.g3BMissionState == STAGE_JOHNNY_BATTLE then
        gCurrentStage = STAGE_JOHNNY_BATTLE
        --print(">>>[RUI]", "??MissionINIT  STAGE 3")
    else
        --print(">>>[RUI]", "?? INVALID shared.g3BMissionState MISSION BORKED ?? " .. tostring(shared.g3BMissionState))
    end
end

function main()
    MissionInit()
    while bMissionRunning do
        if PlayerGetHealth() <= 0 then
            --print("==check player's health===")
            F_MissionFail()
            break
        end
        if gCurrentStage == STAGE_START then
            F0_NIS_HereComesDaCops()
        elseif gCurrentStage == STAGE_COP_CHASE then
            F1_StageOne()
        elseif gCurrentStage == STAGE_BIKE_BATTLE then
            F2_StageTwo()
        elseif gCurrentStage == STAGE_JOHNNY_BATTLE then
            F3_StageThree()
        elseif gCurrentStage == STAGE_NONE then
            break
        end
        Wait(0)
    end
    if bPassedMission then
        --print(">>>[RUI]", "MAIN bPassedMission==TRUE")
        Wait(2500)
        MusicAllowPlayDuringCutscenes(true)
        F3_EndCinematic()
        shared.g3BMissionState = STAGE_START
        PedDeleteWeaponInventorySnapshot(gPlayer)
        MusicAllowPlayDuringCutscenes(false)
        SetFactionRespect(4, 100)
        UnlockYearbookPicture(23)
        F_UnlockYearbookReward()
        MissionSucceed(true, false, false)
        PlayerSetScriptSavedData(14, 0)
    else
        --print(">>>[RUI]", "MAIN bPassedMission==FALSE " .. tostring(gCurrentStage) .. " " .. tostring(shared.g3BMissionState))
        MinigameSetCompletion("M_FAIL", false)
        Wait(1000)
        PedRestoreWeaponInventorySnapshot(gPlayer)
        SoundPlayMissionEndMusic(false, 8)
        if gFailMessage then
            --print(">>>[RUI]", "MAIN MissionFail(true, false, gFailMessage)")
            MissionFail(true, false, gFailMessage)
        else
            --print(">>>[RUI]", "MAIN MissionFail(true, false)")
            MissionFail(true, false)
        end
    end
end

function CopCarFollowPath(car, path)
    --print(">>>[RUI]", "!!CopCarFollowPath")
    VehicleEnableSiren(car, true)
    VehicleSetCruiseSpeed(car, 25)
    VehicleSetDrivingMode(car, 3)
    Wait(50)
    VehicleFollowPath(car, path)
end

function F_CopCarsBlockPath()
    --print(">>>[RUI]", "!!F_CopCarsBlockPath")
    CopCarFollowPath(gCopCar1, PATH._3B_BLOCKCOPCAR01PATH)
    CopCarFollowPath(gCopCar2, PATH._3B_BLOCKCOPCAR02PATH)
end

function F_CopCarAlleyChase()
    --print(">>>[RUI]", "!!F_CopCarAlleyChase")
    VehicleEnableSiren(gCopChaseCar, true)
    VehicleSetDrivingMode(gCopChaseCar, 3)
    VehicleSetCruiseSpeed(gCopChaseCar, 9)
    Wait(50)
    VehicleFollowPath(gCopChaseCar, PATH._3B_COPCARALLEYCHASE)
end

function cbPlayerAtBike(pedId, pathId, pathNode)
    if pathNode == 2 then
        --print(">>>[RUI]", "!!cbPlayerAtBike")
        bPlayerAtBike = true
    end
end

function TimerPassed(time)
    return time < GetTimer()
end

function F0_JohnnyAttacksJimmy()
    --print(">>>[RUI]", "++F0_JohnnyAttacksJimmy")
    MusicFadeWithCamera(false)
    SoundDisableSpeech_ActionTree()
    SoundPlayStream("MS_3B_JohhnyV_NIS.rsm", 0.6, 0, 500)
    --print(">>>[RUI]", "!!F0_JohnnyAttacksJimmy  Johnny Attack")
    gkoTimer = GetTimer() + 2000
    PedLockTarget(gJohnnyV, gPlayer)
    PedSetActionNode(gJohnnyV, "/Global/G_Johnny/Cinematic/ThroatGrab", "Act/Anim/G_Johnny.act")
    while not PedIsPlaying(gPlayer, "/Global/G_Johnny/Cinematic/ThroatGrab/Dash/ThroatGrab/ThroatGrab_Rcv", false) do
        if TimerPassed(gkoTimer) then
            --print(">>>[RUI]", "F0_JohnnyAttacksJimmy safety")
            PedSetActionNode(gJohnnyV, "/Global/G_Johnny/Cinematic/ThroatGrab", "Act/Anim/G_Johnny.act")
            PedSetActionNode(gPlayer, "/Global/G_Johnny/Cinematic/ThroatGrab/Dash/ThroatGrab/ThroatGrab_Rcv", "Act/Anim/G_Johnny.act")
            break
        end
        Wait(0)
    end
    --print(">>>[RUI]", "!!F0_JohnnyAttacksJimmy  player being throttled")
    while not PedIsPlaying(gPlayer, "/Global/G_Johnny/Cinematic/Jimmy/BellyUp/On_Ground", false) do
        Wait(0)
    end
    --print(">>>[RUI]", "jimmy down")
    PedFaceObject(gJohnnyV, gPlayer, 3, 1, false)
    Wait(500)
    --print(">>>[RUI]", "player hit down.")
    PedLockTarget(gJohnnyV, -1)
    --print(">>>[RUI]", "--F0_JohnnyAttacksJimmy")
end

function F0_GreasersCreateForAlley()
    --print(">>>[RUI]", "++F0_GreasersCreateForAlley")
    greaser1 = PedCreatePoint(29, POINTLIST._3B_ALLEYGREASER, 1)
    PedIgnoreStimuli(greaser1, true)
    PedSetStationary(greaser1, true)
    greaser2 = PedCreatePoint(28, POINTLIST._3B_ALLEYGREASER, 2)
    PedIgnoreStimuli(greaser2, true)
    PedSetStationary(greaser2, true)
end

function F0_NIS_HereComesDaCops()
    --print(">>>[RUI]", "++F0_NIS_HereComesDaCops")
    PlayerSetControl(0)
    SoundFadeWithCamera(false)
    SoundSetAudioFocusPlayer()
    AreaClearAllExplosions()
    AreaClearAllProjectiles()
    PedSetWeaponNow(gPlayer, -1, 0)
    if PlayerIsInAnyVehicle() then
        bike = VehicleFromDriver(gPlayer)
        PlayerDetachFromVehicle()
    end
    if not bike then
        bike = PedGetLastVehicle(gPlayer)
    end
    VehicleCleanup(bike)
    AreaClearAllVehicles()
    PlayCutsceneWithLoad("3-B", true, true)
    LoadModels({ 97, 295 })
    LoadModels({
        29,
        24,
        21,
        27,
        28,
        134,
        418
    })
    F0_StageZeroSetup()
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    CameraFade(500, 1)
    Wait(250)
    F0_JohnnyAttacksJimmy()
    Wait(250)
    CameraSetXYZ(-582.79126, -594.27374, 8.513312, -583.26483, -595.07214, 8.141765)
    F0_CopsSetup()
    PlayerSetControl(0)
    F_CopCarsBlockPath()
    Wait(200)
    F0_JohnnyStartRun()
    while not bJohnnyAtBike do
        Wait(0)
    end
    Wait(100)
    F_CopCarAlleyChase()
    PedStop(gJohnnyV)
    PedPutOnBike(gJohnnyV, gJohnnyBike)
    Wait(20)
    PedFollowPath(gJohnnyV, PATH._JOHNNYFLEE01, 0, 2)
    Wait(250)
    CameraSetXYZ(-585.0719, -622.286, 7.183745, -585.29443, -621.3288, 6.998803)
    Wait(100)
    --print(">>>[RUI]", "send player to bike")
    PedSetActionNode(gPlayer, "/Global/G_Johnny/Cinematic/Jimmy/BellyUp/BellyUpGetUp/BellyUpGetUpGetUp", "Act/Anim/G_Johnny.act")
    Wait(100)
    while PedIsPlaying(gPlayer, "/Global/G_Johnny/Cinematic/Jimmy/BellyUp/BellyUpGetUp/BellyUpGetUpGetUp", false) do
        Wait(0)
    end
    PedFollowPath(gPlayer, PATH._3B_PLAYERFLEECOPALLEY, 0, 2, cbPlayerAtBike)
    while not bPlayerAtBike do
        Wait(10)
    end
    F_MakePlayerSafeForNIS(false)
    CameraFade(400, 0)
    Wait(400)
    SoundEnableSpeech_ActionTree()
    VehicleCleanup(gJohnnyBike, gJohnnyV)
    CopsCleanup()
    gCurrentStage = STAGE_COP_CHASE
    --print(">>>[RUI]", "--F0_NIS_HereComesDaCops")
end

function T0_GreaserRunOffGetBusted()
    --print(">>>[RUI]", "++T0_GreaserRunOffGetBusted")
    --print(">>>[RUI]", "!!send greaser1 " .. tostring(greaser1))
    Wait(500)
    PedSetStationary(greaser1, false)
    PedClearObjectives(greaser1)
    PedIgnoreStimuli(greaser1, false)
    PedMoveToPoint(greaser1, 1, POINTLIST._3B_GREASERFLEETO)
    Wait(250)
    SoundPlayScriptedSpeechEvent(gCops[2], "CHASE", 0, "supersize")
    PedStop(gCops[1])
    PedAttack(gCops[1], greaser1, 1, true)
    PedSetPunishmentPoints(greaser1, 600)
    --print(">>>[RUI]", "!!send greaser2 " .. tostring(greaser2))
    PedSetStationary(greaser2, false)
    PedClearObjectives(greaser2)
    PedIgnoreStimuli(greaser2, false)
    PedMoveToPoint(greaser2, 1, POINTLIST._3B_GREASERFLEETO2)
    Wait(350)
    --print(">>>[RUI]", "!!attack greaser1 " .. tostring(gCops[3]) .. " " .. tostring(gCops[1]))
    PedStop(gCops[3])
    PedAttack(gCops[3], greaser2, 1, true)
    PedSetPunishmentPoints(greaser2, 600)
    Wait(2000)
    SoundPlayScriptedSpeechEvent(gCops[2], "CHASE", 0, "supersize")
    PedStop(greaser1)
    PedSetFocus(greaser1, gCops[1])
    PedFlee(greaser1, gCops[1])
    PedStop(greaser2)
    PedSetFocus(greaser2, gCops[3])
    PedFlee(greaser2, gCops[3])
    --print(">>>[RUI]", "--T0_GreaserRunOffGetBusted")
    collectgarbage()
end

function F0_JohnnyStartRun()
    --print(">>>[RUI]", "!!F0_JohnnyStartRun")
    SoundPlayScriptedSpeechEvent_2D("M_3_B_2D", 4, "supersize")
    Wait(1800)
    SoundPlayScriptedSpeechEvent(gJohnnyV, "M_3_B", 5, "supersize")
    while SoundSpeechPlaying(gJohnnyV) do
        Wait(0)
    end
    CreateThread("T0_GreaserRunOffGetBusted")
    PedStop(gJohnnyV)
    PedIgnoreStimuli(gJohnnyV, true)
    PedSetActionNode(gJohnnyV, "/Global/G_Johnny", "Act/Anim/G_Johnny.act")
    PedSetActionNode(gJohnnyV, "/Global/G_Johnny", "Act/Anim/G_Johnny.act")
    PedMoveToPoint(gJohnnyV, 2, POINTLIST._3_B_JOHNNYTOBIKE, 1, cbJohnnyAtBike, 0.5)
end

function cbJohnnyAtBike()
    --print(">>>[RUI]", "!!cbJohnnyAtBike")
    bJohnnyAtBike = true
end

function F1_StageOne()
    --print(">>>[RUI]", "++F1_STAGE_ONE")
    F1_StageOneSetup()
    CameraFade(FADE_IN_TIME, 1)
    Wait(FADE_IN_TIME)
    SoundPlayStream("MS_FightingJohnnyVincentBikeRide.rsm", 0.8, 0, 500)
    gFirstAttempt = true
    PlayerSetControl(1)
    gObjective = ObjectiveLogUpdateItem("3_B_COP_OBJ", nil)
    bCopChaseCarDistanceCheck = false
    VehicleSetCruiseSpeed(gCopChaseCar, 8)
    VehicleSetDrivingMode(gCopChaseCar, 3)
    Wait(50)
    VehicleFollowPath(gCopChaseCar, PATH._3_B_COPCARCHASEPLAYER, true)
    FollowCamSetVehicleShot("JunkyardChase")
    CreateThread("T1_CopChaseCarCam")
    local TriggerHandler = 0
    while gCurrentStage == STAGE_COP_CHASE and bMissionRunning do
        if 0 >= PlayerGetHealth() then
            F_MissionFail()
            return
        end
        if PlayerIsInTrigger(TRIGGER._3B_COPSSPEEDUP) then
            if not bCopCarSpedUp then
                --print(">>>[RUI]", "!!Speed up chase car")
                VehicleSetCruiseSpeed(gCopChaseCar, 25)
                bCopChaseCarDistanceCheck = true
                bCopCarSpedUp = true
            end
        elseif PlayerIsInTrigger(TRIGGER._GREASERS_JET01) then
            if TriggerHandler == 0 then
                --print(">>>[RUI]", "TRIGGER._GREASERS_JET01")
                if CleanFirstDudes then
                    F0_StageZeroCleanup()
                end
                F1_GreasersRun(1)
                TriggerHandler = 1
            end
        elseif PlayerIsInTrigger(TRIGGER._GREASERS_JET02) then
            if TriggerHandler == 1 then
                --print(">>>[RUI]", "TRIGGER._GREASERS_JET02")
                F1_GreasersRun(2)
                TriggerHandler = 2
            end
        elseif PlayerIsInTrigger(TRIGGER._JOHNNYRAMBLE02) then
            if TriggerHandler == 2 then
                --print(">>>[RUI]", "TRIGGER._JOHNNYRAMBLE02")
                OnLookersCleanup()
                PedCleanup(CrateCheerer02)
                PedCleanup(CrateCheerer)
                TriggerHandler = 3
            end
        elseif PlayerIsInTrigger(TRIGGER._GREASERS_JET03) then
            if TriggerHandler == 3 then
                --print(">>>[RUI]", "TRIGGER._GREASERS_JET03")
                F1_GreasersRun(3)
                TriggerHandler = 4
            end
        elseif PlayerIsInTrigger(TRIGGER._GREASERS_JET04) then
            if TriggerHandler == 4 then
                --print(">>>[RUI]", "TRIGGER._GREASERS_JET04")
                F1_GreasersRun(4)
                TriggerHandler = 5
            end
        elseif PlayerIsInTrigger(TRIGGER._GREASERS_JET05) then
            if TriggerHandler == 5 then
                --print(">>>[RUI]", "TRIGGER._GREASERS_JET05")
                F1_GreasersRun(5)
                TriggerHandler = 6
            end
        elseif PlayerIsInTrigger(TRIGGER._3_B_STAGE_2_TRIGGER) and TriggerHandler == 6 then
            --print(">>>[RUI]", "TRIGGER._3_B_STAGE_2_TRIGGER")
            MusicAllowPlayDuringCutscenes(true)
            SoundFadeWithCamera(false)
            MusicFadeWithCamera(false)
            CameraFade(500, 0)
            Wait(500)
            PlayerSetControl(0)
            VehicleStop(gCopChaseCar)
            PedStop(gChaseCarDriver)
            PedClearObjectives(gChaseCarDriver)
            TriggerHandler = 7
            gCurrentStage = STAGE_BIKE_BATTLE
            --print(">>>[RUI]", "StageOne END")
            break
        end
        Wait(0)
    end
end

function F1_MovePlayerOnBike(point)
    --print(">>>[RUI]", "++F1_MovePlayerOnBike")
    local x, y, z = GetPointList(point)
    PlayerSetPosSimple(x, y, z)
    if not gPlayerBike or gPlayerBike == -1 then
        gPlayerBike = VehicleCreatePoint(273, POINTLIST._PLAYERBIKEFIRSTSTART)
    else
        VehicleSetPosPoint(gPlayerBike, POINTLIST._PLAYERBIKEFIRSTSTART)
    end
    Wait(100)
    if not PlayerIsInAnyVehicle() then
        PlayerPutOnBike(gPlayerBike)
    end
    while not PlayerIsInAnyVehicle() do
        Wait(0)
    end
    --print(">>>[RUI]", "!!F1_STAGE_ONE player mounted")
end

function F1_StageOneSetup()
    --print(">>>[RUI]", "!!F1_StageOneSetup")
    shared.g3BMissionState = STAGE_COP_CHASE
    DisablePunishmentSystem(true)
    F1_MovePlayerOnBike(POINTLIST._PLAYERBIKEFIRSTSTART)
    F1_CopChaseCarReset()
    F1_OnLookersSetup()
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraReset()
    CameraFade(250, 1)
    PlayerSetControl(1)
    Wait(250)
    Wait(500)
    SoundFadeWithCamera(false)
    PedSetPunishmentPoints(gPlayer, 800)
    StartStage1 = true
    --print(">>>[RUI]", "--F1_StageOneSetup")
end

function F1_OnLookersSetup()
    --print(">>>[RUI]", "++F1_OnLookersSetup")
    GreaseTable = {
        {
            point = POINTLIST._GREASECHEER03,
            model = 29,
            path = nil
        },
        {
            point = POINTLIST._GREASECHEER04,
            model = 24,
            path = nil
        },
        {
            point = POINTLIST._GREASECHEER05,
            model = 21,
            path = nil
        },
        {
            point = POINTLIST._GREASECHEER06,
            model = 27,
            path = nil
        }
    }
    for _, dude in GreaseTable do
        dude.id = PedCreatePoint(dude.model, dude.point)
        PedIgnoreStimuli(dude.id, true)
        PedAddPedToIgnoreList(dude.id, gPlayer)
    end
    CrateCheerer = PedCreatePoint(24, POINTLIST._CRATES_CHEERER)
    CrateCheerer02 = PedCreatePoint(28, POINTLIST._CRATES_CHEERER02)
end

function OnLookersRun()
    --print(">>>[RUI]", "!!OnLookersRun")
    for _, guy in GreaseTable do
        PedMoveToPoint(guy.id, 2, POINTLIST._3_B_GREASER_FLEE_POINT)
    end
end

function OnLookersCleanup()
    --print(">>>[RUI]", "--OnLookersCleanup")
    for _, guy in GreaseTable, nil do
        PedCleanup(guy.id)
    end
end

function F1_GreasersRun(Encounter)
    --print(">>>[RUI]", "!!F1_GreasersRun")
    if Encounter == 1 then
        --print(">>>[RUI]", "F1_GreasersRun Encounter == 1 ")
        SoundPlayScriptedSpeechEvent_2D("M_3_B_2D", 3)
        OnLookersRun()
    elseif Encounter == 2 then
        --print(">>>[RUI]", "F1_GreasersRun Encounter == 2 ")
        PedCanTeleportOnAreaTransition(CrateCheerer, false)
        CrateJumper01 = PedCreatePoint(27, POINTLIST._CRATES_JUMPER01)
        PedMakeTargetable(CrateJumper01, false)
        CrateJumper02 = PedCreatePoint(21, POINTLIST._CRATES_JUMPER02)
        PedMakeTargetable(CrateJumper02, false)
        CrateJumper03 = PedCreatePoint(28, POINTLIST._CRATES_JUMPER03)
        PedMakeTargetable(CrateJumper03, false)
        LastJumper01 = PedCreatePoint(24, POINTLIST._LAST_JUMPER01)
        PedCanTeleportOnAreaTransition(LastJumper01, false)
        PedMakeTargetable(LastJumper01, false)
        LastJumper02 = PedCreatePoint(27, POINTLIST._LAST_JUMPER02)
        PedCanTeleportOnAreaTransition(LastJumper02, false)
        PedMakeTargetable(LastJumper02, false)
        LastRunner01 = PedCreatePoint(27, POINTLIST._LAST_RUNNER01)
        PedCanTeleportOnAreaTransition(LastRunner01, false)
        PedMakeTargetable(LastJumper01, false)
        LastRunner02 = PedCreatePoint(29, POINTLIST._LAST_RUNNER02)
        PedCanTeleportOnAreaTransition(LastRunner02, false)
        PedMakeTargetable(LastJumper02, false)
    elseif Encounter == 3 then
        --print(">>>[RUI]", "F1_GreasersRun Encounter == 3")
        PedJump(CrateJumper01, POINTLIST._JUMP_CRATES_2)
        PedJump(CrateJumper02, POINTLIST._JUMP_CRATES_2)
        PedJump(CrateJumper03, POINTLIST._JUMP_CRATES_3)
    elseif Encounter == 4 then
        --print(">>>[RUI]", "F1_GreasersRun Encounter == 4")
        SoundPlayScriptedSpeechEvent_2D("M_3_B_2D", 4)
        PedJump(LastJumper01, POINTLIST._LAST_JUMP01)
        PedJump(LastJumper02, POINTLIST._LAST_JUMP02)
    elseif Encounter == 5 then
        --print(">>>[RUI]", "F1_GreasersRun Encounter == 5")
        PedMoveToPoint(LastRunner01, 1, POINTLIST._LAST_RUNNER_POINT)
        PedMoveToPoint(LastRunner02, 1, POINTLIST._LAST_RUNNER_POINT)
    end
end

function CopCreate(point, element, bBlip)
    --print(">>>[RUI]", "++CopCreate")
    local i = element or 1
    local cop = PedCreatePoint(97, point, i)
    if not bBlip then
        BlipRemoveFromChar(cop)
    end
    return cop
end

function CopCarCreate(point, bBlipDriver)
    --print(">>>[RUI]", "++CopCarCreate")
    local driver = CopCreate(POINTLIST._3B_COPSPAWN, 1, bBlipDriver)
    local car = VehicleCreatePoint(295, point)
    PedIgnoreStimuli(driver, true)
    PedSetAsleep(driver, true)
    PedSetCheap(driver, true)
    PedWarpIntoCar(driver, car)
    --print(">>>[RUI]", "CopCarCreate  --Cop in car")
    return car, driver
end

function CopsCreateFromPointList(points)
    --print(">>>[RUI]", "++CopsCreateFromPointList")
    local cops = {}
    local n = GetPointListSize(points)
    for i = 1, n do
        cops[i] = CopCreate(points, i)
    end
    return cops
end

function F0_CopsSetup()
    --print(">>>[RUI]", "++F0_CopsSetup")
    gCops = {}
    gCops = CopsCreateFromPointList(POINTLIST._3B_COPS)
    gCopCar1, gDriver1 = CopCarCreate(POINTLIST._3B_BLOCKCOPCAR01)
    gCopCar2, gDriver2 = CopCarCreate(POINTLIST._3B_BLOCKCOPCAR02)
    gCopChaseCar, gChaseCarDriver = CopCarCreate(POINTLIST._3B_COPCHASECARSTART, true)
    bCopsExist = true
end

function F1_CopChaseCarReset()
    --print(">>>[RUI]", "!![[F1_CopChaseCarReset")
    if gCopChaseCar and VehicleIsValid(gCopChaseCar) then
        VehicleSetPosPoint(gCopChaseCar, POINTLIST._3_B_COPCAR_WARP)
        --print(">>>[RUI]", "F1_CopChaseCarReset moved car to warp spot")
    else
        gCopChaseCar = VehicleCreatePoint(295, POINTLIST._3_B_COPCAR_WARP)
        gChaseCarDriver = PedCreatePoint(97, POINTLIST._3B_COPSPAWN)
        PedIgnoreStimuli(gChaseCarDriver, true)
        PedIgnoreAttacks(gChaseCarDriver, true)
        PedSetCheap(gChaseCarDriver, true)
        PedWarpIntoCar(gChaseCarDriver, gCopChaseCar)
        --print(">>>[RUI]", "F1_CopChaseCarReset create new")
    end
    VehicleEnableSiren(gCopChaseCar, true)
    bCopsExist = true
    --print(">>>[RUI]", "!!F1_CopChaseCarReset]]")
end

function CopsCleanup()
    if not bCopsExist then
        return
    end
    if gCops then
        for _, cop in gCops do
            PedCleanup(cop)
        end
    end
    VehicleCleanup(gCopCar1, gDriver1, true)
    VehicleCleanup(gCopCar2, gDriver2, true)
    --print(">>>[RUI]", "--CopsCleanup")
end

function DistanceToCar(car)
    local px, py, _ = PlayerGetPosXYZ()
    local cx, cy, _ = VehicleGetPosXYZ(car)
    local dist = DistanceBetweenCoords2d(px, py, cx, cy)
    return dist
end

function PlayerHitByCar(car)
    if PedIsPlaying(gPlayer, "/Global/Bikes/HIT/FallOff", true) then
        --print(">>>[RUI]", "PlayerHitByCar YES")
        if DistanceToCar(car) <= 5 then
            return true
        end
        --print(">>>[RUI]", "PlayerHitByCar dist: " .. tostring(DistanceToCar(car)))
    end
    return false
end

function T1_CopChaseCarCam()
    --print(">>>[RUI]", "++T1_CopChaseCarCam")
    FollowCamSetVehicleShot("JunkyardChase")
    while gCurrentStage == STAGE_COP_CHASE and bMissionRunning do
        if VehicleIsValid(gPlayerBike) then
            dist = DistanceToCar(gCopChaseCar)
            PlayerHitByCar(gCopChaseCar)
            if PedIsPedInBox(gChaseCarDriver, gPlayer, -10, 10, -2, 3, -5, 5) then
                F1_Arrested()
                break
            end
            if PlayerLeftBikeTimedOut() then
                F1_Arrested(true)
                break
            end
            if bCopChaseCarDistanceCheck then
                if dist < 8 then
                    VehicleSetCruiseSpeed(gCopChaseCar, 12)
                elseif dist < 8.5 then
                    VehicleSetCruiseSpeed(gCopChaseCar, 17)
                elseif dist < 20 then
                    VehicleSetCruiseSpeed(gCopChaseCar, 22)
                elseif dist < 25 then
                    VehicleSetCruiseSpeed(gCopChaseCar, 25)
                end
            end
        end
        Wait(0)
    end
    FollowCamDefaultVehicleShot()
    collectgarbage()
    --print(">>>[RUI]", "--T1_CopChaseCarCam")
end

function F1_Arrested(bOnFoot)
    --print(">>>[RUI]", "!!F1_Arrested")
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    if gCopChaseCar then
        VehicleStop(gCopChaseCar)
    end
    SoundPlayScriptedSpeechEvent(gChaseCarDriver, "BUSTING", 0, "large")
    if not bOnFoot then
        --print(">>>[RUI]", "F1_Arrested fall off BIKE")
        PedSetActionNode(gPlayer, "/Global/3_B/PlayerFallOffBike", "Act/Conv/3_B.act")
        while PedIsPlaying(gPlayer, "/Global/3_B/PlayerFallOffBike/HitHardBack", false) do
            Wait(10)
        end
    end
    PlayerSetHealth(0)
    Wait(3000)
    CameraFade(1000, 0)
    Wait(1000)
    if PlayerIsInAnyVehicle() then
        PlayerDetachFromVehicle()
    end
    if CleanFirstDudes then
        F0_StageZeroCleanup()
    end
    PedSetPunishmentPoints(gPlayer, 0)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    F_MissionFail("3_B_FAIL01")
    return
end

function TimerPassed(time)
    return time < GetTimer()
end

function PlayerLeftBikeTimedOut()
    if not PedIsInVehicle(gPlayer, gPlayerBike) then
        if gBikeExitTimer then
            TextAddParamNum(gBikeCountDown)
            TextPrintF("3B_BIKEWARN", 0.5, 1)
            if TimerPassed(gBikeCountDownTime) then
                gBikeCountDown = gBikeCountDown - 1
                if gBikeCountDown < 0 then
                    gBikeCountDown = 0
                end
                gBikeCountDownTime = GetTimer() + 1000
            end
            if TimerPassed(gBikeExitTimer) then
                onBike = false
            end
        else
            gBikeExitTimer = GetTimer() + BIKE_REENTRY_DELAY
            gBikeCountDown = BIKE_COUNTDOWN_MAX
            gBikeCountDownTime = GetTimer() + 1000
        end
    else
        gBikeCountDown = BIKE_COUNTDOWN_MAX
        gBikeCountDownTime = nil
        gBikeExitTimer = nil
        onBike = true
    end
    return not onBike
end

function F0_StageZeroCleanup()
    --print(">>>[RUI]", "--F0_StageZeroCleanup")
    PedCleanup(greaser1)
    PedCleanup(greaser2)
    CopsCleanup()
    CleanFirstDudes = false
end

function PedCleanup(ped, bAmbient)
    if F_PedExists(ped) then
        if bAmbient then
            PedMakeAmbient(ped)
            --print(">>>[RUI]", "--PedCleanup go AMBIENT")
        else
            PedDelete(ped)
            --print(">>>[RUI]", "--PedCleanup DELETE")
        end
    end
end

function VehicleCleanup(car, driver, bSiren)
    PedCleanup(driver)
    if F_ObjectIsValid(car) and VehicleIsValid(car) then
        VehicleStop(car)
        if bSiren then
            VehicleEnableSiren(car, false)
        end
        VehicleDelete(car)
        --print(">>>[RUI]", "--VechicleCleanup")
    end
end

function F1_StageOneCleanUp()
    VehicleCleanup(gCopChaseCar, gChaseCarDriver, true)
    VehicleCleanup(gPlayerBike)
    VehicleCleanup(gJohnnyBike, gJohnnyV)
    PedCleanup(CrateJumper01)
    PedCleanup(CrateJumper02)
    PedCleanup(CrateJumper03)
    PedCleanup(LastJumper01)
    PedCleanup(LastJumper02)
    PedCleanup(LastRunner01)
    PedCleanup(LastRunner02)
    --print(">>>[RUI]", "--F1_StageOneCleanUp")
end

function F2_NIS_PeteyGoesForCrane()
    --print(">>>[RUI]", "!!F2_NIS_PeteyGoesForCrane")
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    CameraSetWidescreen(true)
    CameraSetXYZ(-745.0174, -626.3674, 6.700609, -744.0291, -626.30493, 6.562034)
    F2_PeteySetup()
    PedFaceObject(gPeter, gPlayer, 3, 0)
    PedFaceObject(gPlayer, gPeter, 3, 0)
    CameraFade(1000, 1)
    Wait(1000)
    CameraSetXYZ(-731.6686, -630.00653, 6.095325, -730.84235, -629.4809, 6.297467)
    SoundEmitterEnable("MagnetHum", true)
    PedSetActionNode(gPeter, "/Global/3_B/NIS/Peter/Peter01", "Act/Conv/3_B.act")
    SoundPlayScriptedSpeechEvent(gPeter, "M_3_B", 46, "supersize")
    while SoundSpeechPlaying(gPeter) do
        Wait(2500)
        CameraSetXYZ(-745.9005, -625.6178, 4.381477, -746.1365, -624.6878, 4.662223)
        Wait(2500)
    end
    PedFaceObject(gPlayer, gJV_OnBike, 3, 0)
    F_MakePlayerSafeForNIS(false)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    CameraReturnToPlayer()
    CameraReset()
    --print(">>>[RUI]", "--F2_NIS_PeteyGoesForCrane")
end

function F2_StageTwo()
    --print(">>>[RUI]", "++F2_StageTwo")
    if PlayerGetHealth() <= 0 then
        F_MissionFail()
        return
    end
    if not gFirstAttempt then
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        MusicAllowPlayDuringCutscenes(true)
        SoundPlayStream("MS_FightingJohnnyVincentFight.rsm", 0.8, 0, 500)
        Wait(250)
    end
    F2_StageTwoSetup()
    gFirstAttempt = false
    F2_NIS_PeteyGoesForCrane()
    AddBlipForChar(gPeter, 2, 2, 1)
    local johnnyUpdatesHandle = CreateThread("T2_JohnnyUpdates")
    CreateThread("T2_PeterLogic")
    CreateThread("T2_WatchForDeadGuys")
    SoundPlayScriptedSpeechEvent(gJV_OnBike, "M_3_B", 9, "medium")
    Wait(1000)
    AddBlipForChar(gJV_OnBike, 2, 26, 1)
    F3_PerimeterEggersStart()
    F2_JohnnyChoosePath()
    local johnnyAttacksHandle = CreateThread("T2_JohnnyAttacks")
    local bJohnnyOnBike = true
    while not bAllBadGuysDead and bJohnnyOnBike do
        if PlayerGetHealth() <= 0 then
            F_MissionFail()
            return
        end
        if F_PedIsDead(gJV_OnBike) then
            F_MissionPass()
            return
        end
        bJohnnyOnBike = PedIsInAnyVehicle(gJV_OnBike)
        Wait(0)
    end
    if not bMissionRunning then
        return
    end
    --print(">>>[RUI]", "T2_StageTwoMonitor all guards dead")
    --print(">>>[RUI]", "T2_StageTwoMonitor wait for magnet")
    while not bMagnetOn and bMissionRunning and bJohnnyOnBike do
        if PlayerGetHealth() <= 0 then
            F_MissionFail()
            return
        end
        if F_PedIsDead(gJV_OnBike) then
            F_MissionPass()
            return
        end
        bJohnnyOnBike = PedIsInAnyVehicle(gJV_OnBike)
        Wait(0)
    end
    --print(">>>[RUI]", "T2_StageTwoMonitor  magnet on")
    while not PedIsInTrigger(gJV_OnBike, TRIGGER._3_B_MAGNET) and bJohnnyOnBike do
        if PlayerGetHealth() <= 0 then
            F_MissionFail()
            return
        end
        if F_PedIsDead(gJV_OnBike) then
            F_MissionPass()
            return
        end
        bJohnnyOnBike = PedIsInAnyVehicle(gJV_OnBike)
        Wait(0)
    end
    --print(">>>[RUI]", "T2_StageTwoMonitor  johnny magnetized")
    TerminateThread(johnnyUpdatesHandle)
    TerminateThread(johnnyAttacksHandle)
    if bJohnnyOnBike then
        JohnnyMagnetized()
    else
        --print(">>>[RUI]", "@@F2_STAGETWO EMERGENCY FAILSAFE FORCE STAGE 3")
        PedDestroyWeapon(gJV_OnBike, 418)
    end
    StartStage3 = true
    gCurrentStage = STAGE_JOHNNY_BATTLE
    --print(">>>[RUI]", "--F2_StageTwo")
end

function JohnnyMagnetized()
    --print(">>>[RUI]", "!!JohnnyMagnetized")
    PedStop(gJV_OnBike)
    PedSetAsleep(gJV_OnBike, true)
    PedDestroyWeapon(gJV_OnBike, 418)
    PedSetFlag(gJV_OnBike, 13, false)
    Wait(10)
    PedSetActionNode(gJV_OnBike, "/Global/Vehicles/Bikes/ScriptCalls/3B_JohnnyVincent/Magnetized", "Act/Vehicles.act")
    SoundEmitterEnable("MagnetHum", false)
    ThePipeIndex, ThePipeType = CreatePersistentEntity(418, -745.667, -611.574, 3.99679, 0, 43, 90)
    PAnimFollowPath(ThePipeIndex, ThePipeType, PATH._3_B_LEAD_PIPE_PATH, false)
    PAnimSetPathFollowSpeed(ThePipeIndex, ThePipeType, 3.5)
    while PedIsPlaying(gJV_OnBike, "/Global/Vehicles/Bikes/ScriptCalls/3B_JohnnyVincent", true) do
        Wait(0)
    end
    PedSetAsleep(gJV_OnBike, false)
end

function F2_JohnnySetUpForBikeBattle()
    --print(">>>[RUI]", "++F2_JohnnySetUpForBikeBattle")
    gJV_OnBike = PedCreatePoint(23, POINTLIST._3_B_JOHNNY_SPAWN)
    gJV_Bike = VehicleCreatePoint(282, POINTLIST._3_B_JOHNNY_BIKE_SPAWN)
    PedSetWeaponNow(gJV_OnBike, 418, 1)
    PedSetActionTree(gJV_OnBike, "/Global/G_Johnny", "Act/Anim/G_Johnny.act")
    PedSetHealth(gJV_OnBike, MAX_JOHNNY_HEALTH)
    PedShowHealthBar(gJV_OnBike, true, "3_B_JOHNNY_HEALTH", true)
    bHealthBarOn = true
    VehicleSetEntityFlag(gJV_Bike, 41, true)
    VehicleBikeForceBoundingSphereUpdate(gJV_Bike, true)
    PedPathNodeReachedDistance(gJV_OnBike, 2.5)
    PedOverrideStat(gJV_OnBike, 33, 100)
    PedOverrideStat(gJV_OnBike, 34, 0)
    PedOverrideStat(gJV_OnBike, 24, 50)
    PedSetFlag(gJV_OnBike, 107, true)
    PedSetDamageTakenMultiplier(gJV_OnBike, 3, 0.2)
    PedSetDamageTakenMultiplier(gJV_OnBike, 0, 0.3)
    PedIgnoreStimuli(gJV_OnBike, true)
    PedLockTarget(gJV_OnBike, gPlayer)
    Wait(100)
    PedPutOnBike(gJV_OnBike, gJV_Bike)
end

--[[
function TestJohnny()
    PedSetActionNode(gJV_OnBike, "/Global/Vehicles/Bikes/Ground/Dismount/GetOff", "Act/Vehicles.act")
end
]] -- Not present in original script

function F2_PeteySetup()
    --print(">>>[RUI]", "++F2_PeteySetup")
    if not F_PedExists(gPeter) then
        gPeter = PedCreatePoint(134, POINTLIST._3_B_HELPER_SPAWN)
    else
        PedSetPosPoint(gPeter, POINTLIST._3_B_HELPER_SPAWN)
    end
    PedIgnoreStimuli(gPeter, true)
    PedSetTypeToTypeAttitude(5, 13, 2)
    PedSetInvulnerableToPlayer(gPeter, true)
    PedOverrideStat(gPeter, 3, 1)
    PedOverrideStat(gPeter, 2, 1)
    PedMakeTargetable(gPeter, false)
end

function F2_StageTwoSetup()
    --print(">>>[RUI]", "!!F2_StageTwoSetup")
    shared.g3BMissionState = STAGE_BIKE_BATTLE
    gObjective = ObjectiveLogUpdateItem(nil, gObjective)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CreateThread("T_MagnetVibrate")
    if PlayerIsInAnyVehicle() then
        PlayerDetachFromVehicle()
    end
    F1_StageOneCleanUp()
    MusicAllowPlayDuringCutscenes(true)
    PlayCutsceneWithLoad("3-BB", true, true)
    LoadModels({ 97, 295 })
    LoadModels({
        29,
        24,
        21,
        27,
        28,
        134,
        418
    })
    MusicAllowPlayDuringCutscenes(false)
    if gFirstAttempt then
        SoundPlayStream("MS_FightingJohnnyVincentFight.rsm", 0.8, 0, 500)
    end
    PlayerSetControl(0)
    local x, y, z = GetPointList(POINTLIST._3_B_STAGE2_TELEPORT)
    PlayerSetPosSimple(x, y, z)
    F2_JohnnySetUpForBikeBattle()
    F2_CreatePerimeterEggers()
    CreateThread("T3_PerimeterGreasesTaunt")
    table_BikeAttackLogic = {
        {
            trig = TRIGGER._3_B_BIKE_REGION_NE,
            path = PATH._3_B_JV_BIKE_PATH_NW,
            msg = "In Trigger NE"
        },
        {
            trig = TRIGGER._3_B_BIKE_REGION_NW,
            path = PATH._3_B_JV_BIKE_PATH_SW,
            msg = "In Trigger NW"
        },
        {
            trig = TRIGGER._3_B_BIKE_REGION_SE,
            path = PATH._3_B_JV_BIKE_PATH_NE,
            msg = "In Trigger SE"
        },
        {
            trig = TRIGGER._3_B_BIKE_REGION_SW,
            path = PATH._3_B_JV_BIKE_PATH_SE,
            msg = "In Trigger SW"
        }
    }
    ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateHEALTH")
end

function F2_CreatePerimeterEggers()
    --print(">>>[RUI]", "++F2_CreatePerimeterEggers")
    gPerimeterGreasers = {
        {
            index = 1,
            id = nil,
            model = 24,
            state = "alive",
            point = POINTLIST._3_B_STAGE2_THUG_A,
            blip_id = nil,
            dodge_freq = 5,
            cur_path = PATH._3_B_START,
            end_point = 1,
            cur_weapon = 312,
            ammo = 400,
            next_path = PATH._3_B_PATH_A,
            quote = "3_B_Pete_P1",
            bAlive = true
        },
        {
            index = 2,
            id = nil,
            model = 22,
            state = "alive",
            point = POINTLIST._3_B_STAGE2_THUG_B,
            blip_id = nil,
            dodge_freq = 5,
            cur_path = PATH._3_B_PATH_A,
            end_point = 1,
            cur_weapon = 312,
            ammo = 400,
            next_path = PATH._3_B_PATH_B,
            quote = "3_B_Pete_P2",
            bAlive = true
        },
        {
            index = 3,
            id = nil,
            model = 27,
            state = "alive",
            point = POINTLIST._3_B_STAGE2_THUG_C,
            blip_id = nil,
            dodge_freq = 5,
            cur_path = PATH._3_B_PATH_B,
            end_point = 1,
            cur_weapon = 312,
            ammo = 400,
            next_path = PATH._3_B_PATH_C,
            quote = "3_B_Pete_P3",
            bAlive = true
        },
        {
            index = 4,
            id = nil,
            model = 26,
            state = "alive",
            point = POINTLIST._3_B_STAGE2_THUG_D,
            blip_id = nil,
            dodge_freq = 5,
            cur_path = PATH._3_B_PATH_C,
            end_point = 2,
            cur_weapon = 312,
            ammo = 10000,
            next_path = PATH._3_B_PATH_D,
            quote = "3_B_Pete_P4",
            bAlive = true
        },
        {
            index = 5,
            id = nil,
            model = 28,
            state = "alive",
            point = POINTLIST._3_B_STAGE2_THUG_E,
            blip_id = nil,
            dodge_freq = 5,
            cur_path = PATH._3_B_PATH_D,
            end_point = 2,
            cur_weapon = 312,
            ammo = 400,
            next_path = PATH._3_B_PATH_E,
            quote = "3_B_Pete_P5",
            bAlive = true
        },
        {
            index = 6,
            id = nil,
            model = 29,
            state = "alive",
            point = POINTLIST._3_B_STAGE2_THUG_F,
            blip_id = nil,
            dodge_freq = 5,
            cur_path = PATH._3_B_PATH_E,
            end_point = 2,
            cur_weapon = 309,
            ammo = 400,
            next_path = PATH._3_B_PATH_F,
            quote = "3_B_Pete_Final",
            bAlive = true
        }
    }
    for each, entry in gPerimeterGreasers do
        entry.id = PedCreatePoint(entry.model, entry.point)
        --print(">>>[RUI]", "F2_CreatePerimeterEggers " .. tostring(entry.id))
        entry.blip_id = AddBlipForChar(entry.id, 2, 26, 1)
        PedFaceObjectNow(entry.id, gPlayer, 3)
        PedSetStationary(entry.id, true)
        PedClearAllWeapons(entry.id)
        PedSetHealth(entry.id, 20)
    end
end

function T3_PerimeterGreasesTaunt()
    --print(">>>[RUI]", "++T3_PerimeterGreasesTaunt")
    Wait(4000)
    while not bAllBadGuysDead do
        for _, greaser in gPerimeterGreasers do
            if F_PedExists(greaser.id) then
                --print(">>>[RUI]", "T3_PerimeterGreasesTaunt SoundPlayScriptedSpeechEvent(greaser.id, FIGHTING, 0)")
                SoundPlayScriptedSpeechEvent(greaser.id, "FIGHTING", 0, "supersize")
                Wait(5000 + math.random(3000))
                break
            end
        end
        Wait(0)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T3_PerimeterGreasesTaunt")
end

function F3_PerimeterEggersStart()
    --print(">>>[RUI]", "!!F3_PerimeterEggersStart")
    for _, entry in gPerimeterGreasers do
        --print(">>>[RUI]", "F3_PerimeterEggersStart " .. tostring(entry.id))
        PedOverrideStat(entry.id, 3, 100)
        PedOverrideStat(entry.id, 2, 100)
        PedOverrideStat(entry.id, 13, 0)
        PedOverrideStat(entry.id, 8, 10)
        PedOverrideStat(entry.id, 11, 90)
        PedOverrideStat(entry.id, 10, 10)
        PedOverrideStat(entry.id, 31, 10)
        PedOverrideStat(entry.id, 34, entry.dodge_freq)
        if entry.cur_weapon then
            --print(">>>[RUI]", "F3_PerimeterEggersStart give weapon to" .. tostring(entry.id))
            PedSetWeapon(entry.id, entry.cur_weapon, entry.ammo)
            PedLockTarget(entry.id, gPlayer, false)
            PedAttack(entry.id, gPlayer, 3)
        end
        PedSetActionTree(entry.id, "/Global/G_Ranged_A", "Act/Anim/G_Ranged_A.act")
    end
end

function T2_PeterLogic()
    --print(">>>[RUI]", "++T2_PeterLogic")
    gPeterCurrentPath = PATH._3_B_START
    gPeterCurrentPath_Length = 2
    PedFollowPath(gPeter, gPeterCurrentPath, 0, 1, cbPeterPath)
    repeat
        if gPeterCurrentPath_Arrival then
            --print("==going to crouch==")
            F_PeterCrouch()
            gPeterCurrentPath_Arrival = false
            F2_UpdatePeterPos()
        end
        Wait(0)
        if not bMissionRunning then
            return
        end
    until PedIsInTrigger(gPeter, TRIGGER._AREA_AROUND_BUTTON)
    SoundPlayScriptedSpeechEvent(gPeter, "M_3_B", 28, "jumbo")
    --print(">>>[RUI]", "++T2_PeterLogic Peter Enter Crane")
    PedMoveToPoint(gPeter, 0, POINTLIST._3B_PETERCRANESYNCH, 1, cbPeterAtCraneDoor, 0.1)
    while not bPeterAtCraneDoor do
        Wait(0)
    end
    --print(">>>[RUI]", "T2_PeterLogic at crane entrance ready to enter")
    PedMakeTargetable(gPeter, false)
    PedSetInvulnerable(gPeter, true)
    PedSetFlag(gPeter, 13, true)
    --print(">>>[RUI]", "T2_PeterLogic interact with the target proxy")
    PedSetActionNode(gPeter, "/Global/3_B/PeteyUseCrane/GetInAndUseCrane", "Act/Conv/3_B.act")
    gButtonIndex, gCraneButton = CreatePersistentEntity("DPE_buttonOFF", -753.797, -606.439, 7.7574, -113.707, 43)
    gCraneIndex, gCraneLights = CreatePersistentEntity("JY1d_animlight", -749.922, -608.287, 8.51702, 0, 43)
    F2_CraneBlip()
    bMagnetOn = true
    collectgarbage()
    --print(">>>[RUI]", "--T2_PeterLogic")
end

function cbPeterAtCraneDoor()
    --print(">>>[RUI]", "!!cbPeterAtCraneDoor")
    bPeterAtCraneDoor = true
end

function F2_CraneBlip()
    --print(">>>[RUI]", "++F2_CraneBlip")
    local x, y, z = GetPointList(POINTLIST._3B_MAGNETBLIP)
    gMagnetBlip = BlipAddXYZ(x, y, z + 0.3, -1, 2)
end

function F2_CraneBlipCleanup()
    if gMagnetBlip and gMagnetBlip ~= -1 then
        BlipRemove(gMagnetBlip)
    end
    --print(">>>[RUI]", "--F2_CraneBlipCleanup")
end

function F2_UpdatePeterPos()
    --print(">>>[RUI]", "F2_UpdatePeterPos")
    for each, guy in gPerimeterGreasers do
        if guy.cur_path == gPeterCurrentPath and F_PedIsDead(guy.id) then
            --print(">>>[RUI]", "F2_UpdatePeterPos dead guy, move on")
            gPeterCurrentPath = guy.next_path
            gPeterCurrentPath_Length = guy.end_point
            SoundPlayScriptedSpeechEvent(gPeter, "M_3_B", 27, "supersize")
            F_PeterStand()
            PedFollowPath(gPeter, gPeterCurrentPath, 0, 1, cbPeterPath)
            bPeterIsMovingAlready = true
        end
    end
end

function cbPeterPath(PedID, PathID, NodeID)
    if PathID == PATH._3_B_PATH_F then
        if NodeID == 0 then
            TextClear()
            --print(">>>[RUI]", "cbPeterPath node 0")
        elseif NodeID == 4 then
            bPeterAtCrane = true
            --print(">>>[RUI]", "cbPeterPath at crane  TRUE")
        end
    elseif PathID == gPeterCurrentPath and NodeID == gPeterCurrentPath_Length then
        --print(">>>[RUI]", "At Position" .. tostring(3))
        bPeterIsMovingAlready = false
        gPeterCurrentPath_Arrival = true
        --print(">>>[RUI]", "cbPeterPath gPeterCurrentPath_Arrival == true")
    end
end

function T2_WatchForDeadGuys()
    local size = table.getn(gPerimeterGreasers)
    --print(">>>[RUI]", "++T2_WatchForDeadGuys " .. tostring(size))
    repeat
        for each, guy in gPerimeterGreasers do
            if guy.bAlive and F_PedIsDead(guy.id) then
                guy.bAlive = false
                gTotalDead = gTotalDead + 1
                --print(">>>[RUI]", "T2_WatchForDeadGuys  guy dead " .. tostring(guy.id) .. " #" .. tostring(gTotalDead))
                BlipRemove(guy.blip_id)
                if guy.cur_path == gPeterCurrentPath then
                    F2_UpdatePeterPos()
                end
            end
        end
        if not bMissionRunning then
            return
        end
        Wait(0)
    until gTotalDead == size
    bAllBadGuysDead = true
    collectgarbage()
    --print(">>>[RUI]", "--T2_WatchForDeadGuys")
end

function cbPeteyAtCraneDoor(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) then
        --print(">>>[RUI]", "!!cbPeteyAtCraneDoor")
        bPeteyAtCraneDoor = true
    end
end

function T2_JohnnyAttacks()
    --print(">>>[RUI]", "++T2_JohnnyAttacks")
    while gCurrentStage == STAGE_BIKE_BATTLE and bMissionRunning do
        X, Y, Z = 0, 0, 0
        if PedIsInAnyVehicle(gJV_OnBike) then
            JohnnyPrepAttack = true
            PedStop(gJV_OnBike)
            PedClearObjectives(gJV_OnBike)
            SoundPlayScriptedSpeechEvent(gJV_OnBike, "M_3_B", 18, "supersize")
            PedFaceObject(gJV_OnBike, gPlayer, 3, 0)
            --print(">>>[RUI]", "T2_JohnnyAttacks CHARGE")
            X, Y, Z = PlayerGetPosXYZ()
            PedMoveToXYZ(gJV_OnBike, 1, X, Y, Z)
            while not PedIsInAreaXYZ(gJV_OnBike, X, Y, Z, 3.5, 0) do
                if gCurrentStage == STAGE_JOHNNY_BATTLE then
                    break
                end
                Wait(0)
            end
            if not F_PedIsDead(gJV_OnBike) then
                --print(">>>[RUI]", "T2_JohnnyAttacks SWING")
                PedStop(gJV_OnBike)
                PedSetActionNode(gJV_OnBike, "/Global/Vehicles/Bikes/ExecuteNodes/Attacks/LeadPipe/SwingRightExec", "Act/Vehicles.act")
                Wait(200)
                PedSetActionNode(gJV_OnBike, "/Global/Vehicles/Bikes/ExecuteNodes/Attacks/LeadPipe/SwingLeftExec", "Act/Vehicles.act")
                F2_JohnnyChoosePath()
                JohnnyPrepAttack = false
                Wait(6000 + math.random(4000))
            else
                return
            end
        end
        Wait(0)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T2_JohnnyAttacks")
end

function F_MissionPass()
    --print(">>>[RUI]", "!!F_MissionPass")
    bMissionRunning = false
    bPassedMission = true
    gCurrentStage = STAGE_NONE
end

function F_MissionFail(why)
    --print(">>>[RUI]", "!!F_MissionFail")
    bMissionRunning = false
    bPassedMission = false
    gFailMessage = why
    gCurrentStage = STAGE_NONE
end

function T2_JohnnyUpdates()
    --print(">>>[RUI]", "++T2_JohnnyUpdates")
    while gCurrentStage == STAGE_BIKE_BATTLE and bMissionRunning do
        if F_PedIsDead(gJV_OnBike) then
            --print(">>>[RUI]", "T2_JohnnyUpdates Johnny Dead")
            F_MissionPass()
            return
        end
        if not JohnnyPrepAttack and not F_PedIsDead(gJV_OnBike) and DistanceBetweenPeds2D(gPlayer, gJV_OnBike) <= 2.3 and PedIsInVehicle(gJV_OnBike, gJV_Bike) and PedIsInAnyVehicle(gJV_OnBike) then
            PedSetActionNode(gJV_OnBike, "/Global/Vehicles/Bikes/ExecuteNodes/Attacks/LeadPipe/SwingLeftExec", "Act/Vehicles.act")
            Wait(200)
            PedSetActionNode(gJV_OnBike, "/Global/Vehicles/Bikes/ExecuteNodes/Attacks/LeadPipe/SwingRightExec", "Act/Vehicles.act")
            Wait(3000)
        end
        if not PedIsInAnyVehicle(gJV_OnBike) then
            PedStop(gJV_OnBike)
            PedClearObjectives(gJV_OnBike)
            while not PedIsInAnyVehicle(gJV_OnBike) do
                if not F_PedIsDead(gJV_OnBike) then
                    PedEnterVehicle(gJV_OnBike, gJV_Bike)
                else
                    --print(">>>[RUI]", "T2_JohnnyUpdates Johnny Dead")
                    F_MissionPass()
                    return
                end
                Wait(0)
            end
        end
        Wait(0)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T2_JohnnyUpdates")
end

function F2_JohnnyChoosePath()
    --print(">>>[RUI]", "!!F2_JohnnyChoosePath")
    local x, y, z = PedGetPosXYZ(gJV_OnBike)
    if bMagnetOn then
        if PedIsInTrigger(gJV_OnBike, TRIGGER._3_B_REGION_S) then
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_MAGNET_PATH_SW, 2, 4)
        else
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_MAGNET_PATH_NE, 2, 4)
        end
    elseif DistanceBetweenCoords2d(x, y, -740.763, -615.859) < 8 then
        --print("Inside inner radius")
        if PedGetHeading(gJV_OnBike) < 0 and PedGetHeading(gJV_OnBike) >= -1.5707964 then
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_NW, 1, 4)
        elseif PedGetHeading(gJV_OnBike) < -1.5707964 and PedGetHeading(gJV_OnBike) >= -3.1415927 then
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_SW, 1, 4)
        elseif PedGetHeading(gJV_OnBike) < -3.1415927 and PedGetHeading(gJV_OnBike) >= -4.712389 then
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_SE, 1, 4)
        elseif PedGetHeading(gJV_OnBike) < -4.712389 then
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_NE, 1, 4)
        elseif PedGetHeading(gJV_OnBike) >= 0 and PedGetHeading(gJV_OnBike) < 1.5707964 then
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_NE, 1, 4)
        elseif PedGetHeading(gJV_OnBike) >= 1.5707964 and PedGetHeading(gJV_OnBike) < 3.1415927 then
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_SE, 1, 4)
        elseif PedGetHeading(gJV_OnBike) >= 3.1415927 and PedGetHeading(gJV_OnBike) < 4.712389 then
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_SW, 1, 4)
        elseif PedGetHeading(gJV_OnBike) >= 4.712389 then
            PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_NW, 1, 4)
        end
    elseif PedIsInTrigger(gJV_OnBike, TRIGGER._3_B_BIKE_REGION_NE) then
        PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_NW, 1, 4)
    elseif PedIsInTrigger(gJV_OnBike, TRIGGER._3_B_BIKE_REGION_NW) then
        PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_SW, 1, 4)
    elseif PedIsInTrigger(gJV_OnBike, TRIGGER._3_B_BIKE_REGION_SW) then
        PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_SE, 1, 4)
    elseif PedIsInTrigger(gJV_OnBike, TRIGGER._3_B_BIKE_REGION_SE) then
        PedFollowPath(gJV_OnBike, PATH._3_B_JV_BIKE_PATH_NE, 1, 4)
    end
end

function F3_StageThreeSetup()
    --print(">>>[RUI]", "F3_StageThreeSetup")
    SoundPlayStream("MS_FightingJohnnyVincentBossFight.rsm", 0.7, 500, 250)
    shared.g3BMissionState = STAGE_BIKE_BATTLE
    F2_CraneBlipCleanup()
    F3_JohnnySetup()
end

function F3_StageThree()
    --print(">>>[RUI]", "++F3_StageThree")
    F3_StageThreeSetup()
    SoundPlayScriptedSpeechEvent(gPlayer, "M_3_B", 13, "supersize")
    while SoundSpeechPlaying(gPlayer) do
        Wait(0)
    end
    PedStop(gJV_OnGround)
    PedAttackPlayer(gJV_OnGround, 3, true)
    Wait(1000)
    while not F_PedIsDead(gJV_OnGround) do
        if 0 >= PlayerGetHealth() then
            F_MissionFail()
            return
        end
        Wait(0)
    end
    --print(">>>[RUI]", "Johnny Dead")
    CameraAllowChange(true)
    CameraReturnToPlayer()
    bMissionRunning = false
    bPassedMission = true
    gCurrentStage = STAGE_NONE
end

function T_MagnetVibrate() -- ! Modified
    --print(">>>[RUI]", "++T_MagnetVibrate")
    while bMissionRunning do
        if PlayerIsInTrigger(TRIGGER._3_B_MAGNET) then
            --print("[RW] IN TRIGGER >>>>>> IN TRIGGER")
            if bMagnetOn then
                --[[
                StartVibration(1, 500, 128)
                ]] -- Modified to:
                StartVibration(0, 1000, 255)
            else
                --[[
                StartVibration(1, 250, 64)
                ]] -- Modified to:
                StartVibration(0, 1000, 128)
            end
            --[[
            Wait(2000)
            ]] -- Modified to:
            Wait(1000)
        else
            Wait(100)
        end
        Wait(0)
    end
    StopVibration()
    collectgarbage()
    --print(">>>[RUI]", "--T_MagnetVibrate")
end

function F3_JohnnySetup()
    --print(">>>[RUI]", "++F3_JohnnySetup")
    gJV_OnGround = gJV_OnBike
    PedStop(gJV_OnGround)
    PedSetFlag(gJV_OnGround, 13, false)
    PedMakeTargetable(gJV_OnGround, true)
    --print(">>>[RUI]", "Johnny on ground")
end

function F3_EndCinematic()
    --print(">>>[RUI]", "!!F3_EndCinematic")
    SoundFadeWithCamera(false)
    PlayerSetControl(0)
    PedSetInvulnerable(gPlayer, true)
    MusicAllowPlayDuringCutscenes(true)
    SoundPlayStreamNoLoop("MS_3-B_ENDTAG.rsm", 0.7, 0, 0)
    CameraFade(1000, 0)
    Wait(1000)
    PedCleanup(gJV_OnGround)
    PedCleanup(gJV_OnBike)
    PedHideHealthBar()
    bHealthBarOn = false
    PlayCutsceneWithLoad("3-BD", true)
    CameraDefaultFOV()
    CameraReturnToPlayer()
    CameraFade(1000, 1)
    PedSetInvulnerable(gPlayer, false)
    PlayerSetControl(1)
end

function F_FightCondition()
    if bJohnnyKnockDown then
        --print(">>>[RUI]", "F_FightCondition return 1")
        return 1
    else
        --print(">>>[RUI]", "F_FightCondition return 0")
        return 0
    end
end

function F0_StageZeroSetup()
    --print(">>>[RUI]", "++F0_StageZeroSetup")
    shared.g3BMissionState = STAGE_NONE
    Wait(200)
    PlayerFaceHeadingNow(180)
    gPlayerBike = VehicleCreatePoint(273, POINTLIST._PLAYERBIKEFIRSTSTART)
    gJohnnyV = PedCreatePoint(23, POINTLIST._JOHNNY_FIRSTSTART)
    gJohnnyBike = VehicleCreatePoint(282, POINTLIST._JOHNNYBIKEFIRSTSTART)
    F0_GreasersCreateForAlley()
    --print(">>>[RUI]", "--F0_StageZeroSetup")
end

function F_DodgeCondition()
    if bJohnnyCanAvoid then
        --print(">>>[RUI]", "F_DodgeCondition return 1")
        return 1
    else
        --print(">>>[RUI]", "F_DodgeCondition return 0")
        return 0
    end
end

function F_PeterCrouch()
    if gPeterStateCrouched then
    else
        PedStop(gPeter)
        --print(">>>[RUI]", "====Peter crouch!=====")
        PedSetActionNode(gPeter, "/Global/3_B/Animation/Crouch/Crouch", "Act/Conv/3_B.act")
        gPeterStateCrouched = true
    end
end

function F_PeterStand()
    if gPeterStateCrouched then
        --print("====Peter stand!=====")
        PedSetActionNode(gPeter, "/Global/3_B/Animation/Stand/Stand", "Act/Conv/3_B.act")
        Wait(500)
        gPeterStateCrouched = false
    else
    end
end

function ObjectiveLogUpdateItem(newObjStr, oldObj, bSkipPrint)
    local newObj
    if newObjStr then
        newObj = MissionObjectiveAdd(newObjStr, 0, -1)
        if not bSkipPrint then
            TextPrint(newObjStr, 5.5, 1)
        end
        --print(">>>[RUI]", "!!ObjectiveLogUpdateItem " .. tostring(newObjStr))
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end
