--[[ Changes to this file:
    * Modified function MissionCleanup, may require testing
    * Modified function F_StartMission, may require testing
]]

local bLoop = true
local countMax = 3
local CurrentMissionIndex = 0
local CurrentMission
local tblRiderData = {}
local tblPedModels = {
    252,
    42,
    43,
    41,
    45,
    91,
    97
}
local lVictim = {}
local lVictimBlip = {}
local ModelBikes = {
    274,
    273,
    272,
    281
}
local tblVictimInfo = {}
local tblMissionParams = {}
local VictimCounter = 0
local VictimMax = 10
local bRudyBusted = false
local ACTIONFILE

function MissionSetup()
    print("***************************************** 3_10 Mission setup *************************************")
    DATLoad("3_01A.DAT", 2)
    DATInit()
    if AreaGetVisible() ~= 0 then
        AreaTransitionPoint(0, POINTLIST._3_10_PLAYERSCENE01)
    else
        PlayerSetPosPoint(POINTLIST._3_10_PLAYERSCENE01)
    end
    PlayCutsceneWithLoad("3-01AA", true)
    MissionDontFadeIn()
    tblMissionParams = {
        {
            "3_01A_MOBJ_01",
            POINTLIST._3_10_LADDER01,
            POINTLIST._3_10_RUDYMOVE01,
            POINTLIST._3_10_MISSION01
        },
        {
            POINTLIST._3_10_MISSION01FIRE,
            POINTLIST._3_10_PLAYERWARP,
            "3_01A_TEXT_01"
        }
    }
    tblVictimInfo = {
        {
            TYPE = 0,
            MODEL = tblPedModels[2],
            STARTFLG = POINTLIST._3_10_SSSTART01,
            MOVETO = POINTLIST._3_10_SSMOVE01
        },
        {
            TYPE = 0,
            MODEL = tblPedModels[3],
            STARTFLG = POINTLIST._3_10_SSSTART02,
            MOVETO = POINTLIST._3_10_SSMOVE02
        },
        {
            TYPE = 1,
            MODEL = tblPedModels[4],
            STARTFLG = POINTLIST._3_10_SBSTART01,
            PATH = PATH._3_10_PATH01,
            PATHSTART = 0
        },
        {
            TYPE = 1,
            MODEL = tblPedModels[5],
            STARTFLG = POINTLIST._3_10_SBSTART02,
            PATH = PATH._3_10_PATH02,
            PATHSTART = 0
        },
        {
            TYPE = 2,
            MODEL = tblPedModels[6],
            STARTFLG = POINTLIST._3_10_BIKER01,
            PATH = PATH._3_10_BIKEPATH01,
            PATHSTART = 0,
            BIKESTART = POINTLIST._3_10_BIKE01
        },
        {
            TYPE = 2,
            MODEL = tblPedModels[3],
            STARTFLG = POINTLIST._3_10_BIKER02,
            PATH = PATH._3_10_BIKEPATH01,
            PATHSTART = 3,
            BIKESTART = POINTLIST._3_10_BIKE02
        },
        {
            TYPE = 1,
            MODEL = tblPedModels[4],
            STARTFLG = POINTLIST._3_10_SBSTART01,
            PATH = PATH._3_10_PATH01,
            PATHSTART = 0
        },
        {
            TYPE = 1,
            MODEL = tblPedModels[5],
            STARTFLG = POINTLIST._3_10_SBSTART02,
            PATH = PATH._3_10_PATH02,
            PATHSTART = 0
        },
        {
            TYPE = 2,
            MODEL = tblPedModels[6],
            STARTFLG = POINTLIST._3_10_BIKER01,
            PATH = PATH._3_10_BIKEPATH01,
            PATHSTART = 0,
            BIKESTART = POINTLIST._3_10_BIKE01
        },
        {
            TYPE = 2,
            MODEL = tblPedModels[3],
            STARTFLG = POINTLIST._3_10_BIKER02,
            PATH = PATH._3_10_BIKEPATH01,
            PATHSTART = 3,
            BIKESTART = POINTLIST._3_10_BIKE02
        }
    }
    LoadPedModels(tblPedModels)
    LoadAnimationGroup("MINI_BallToss")
    ACTIONFILE = "Act/Conv/3_01a.act"
    LoadActionTree(ACTIONFILE)
    LoadWeaponModels({ 313 })
end

function MissionCleanup() -- ! Modified
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    F_KillControls(false)
    DATUnload(2)
    PedSetTypeToTypeAttitude(3, 4, 2)
    PedSetTypeToTypeAttitude(3, 9, 2)
    PedSetTypeToTypeAttitude(9, 4, 2)
    lVictim = nil
    tblVictimInfo = nil
    UnloadModels(tblPedModels)
    PlayerSetInvulnerable(false) -- Added this
end

function main()
    print("*************************** 3_10 Main ******************************************")
    SetPopulation()
    F_KillControls(true)
    PedSetWeaponNow(gPlayer, MODELENUM._NOWEAPON, 1)
    if PedIsOnVehicle(gPlayer) then
        PlayerDetachFromVehicle()
    end
    PedSetWeaponNow(gPlayer, -1, 0)
    gRudy = PedCreatePoint(252, POINTLIST._3_10_RUDYSCENE01, 1)
    PedLockTarget(gRudy, gPlayer)
    PedFaceObject(gRudy, gPlayer, 3, 1)
    CameraReset()
    CameraReturnToPlayer()
    PedIgnoreStimuli(gRudy, true)
    PedSetStationary(gRudy, true)
    PedSetMissionCritical(gRudy, true, F_MissionFailed, true)
    PedMakeTargetable(gRudy, true)
    F_SetNextMission()
end

function SetPopulation()
    SetAmbientPedsIgnoreStimuli(true)
    DisablePOI()
    AreaClearAllPeds()
    AreaOverridePopulation(20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 0, 0)
    AreaClearAllVehicles()
    VehicleOverrideAmbient(0, 0, 0, 0)
end

function F_InitMission()
    local bTimerExpired = false
    PedSetMissionCritical(gRudy, true, F_RUDYBUSTED, true)
    CameraFade(500, 1)
    Wait(1000)
    F_KillControls(false)
    SoundPlayInteractiveStream("MS_XmasBellsRudyLow.rsm", 0.9, 0, 500)
    SoundSetMidIntensityStream("MS_XmasBellsRudyMid.rsm", 0.9, 0, 500)
    SoundSetHighIntensityStream("MS_XmasBellsRudyHigh.rsm", 0.9, 0, 500)
    TextPrint(tblMissionParams[CurrentMissionIndex][1], 5, 1)
    objId = MissionObjectiveAdd(tblMissionParams[CurrentMissionIndex][1], 1)
    Mission_blip = BlipAddPoint(tblMissionParams[CurrentMissionIndex][2], 0, 1, 1, 7)
    while bLoop do
        Wait(0)
        if PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions/Climb_ON_BOT", true) then
            BlipRemove(Mission_blip)
            PedSetStationary(gRudy, false)
            PedMoveToPoint(gRudy, 0, tblMissionParams[CurrentMissionIndex][3], 1)
            break
        end
        if F_CheckDist() then
            bTimerExpired = true
            break
        end
    end
    if not bTimerExpired then
        Mission_blip = BlipAddPoint(tblMissionParams[CurrentMissionIndex][4], 0, 1, 1, 7)
        local bx, by, bz = GetPointList(tblMissionParams[CurrentMissionIndex][4])
        while bLoop do
            Wait(0)
            if PlayerIsInAreaXYZ(bx, by, bz, 1, 1) then
                Mission_blip = BlipRemove(Mission_blip)
                objId = MissionObjectiveRemove(objId)
                break
            end
            if F_CheckDist() then
                bTimerExpired = true
                break
            end
        end
    end
    if not bTimerExpired then
        F_SetNextMission()
    end
end

function F_DistanceBetweenPeds(ped1, ped2)
    local X1, Y1, _ = PedGetPosXYZ(ped1)
    local X2, Y2, _ = PedGetPosXYZ(ped2)
    return DistanceBetweenCoords2d(X1, Y1, X2, Y2)
end

local bGuyGotHit = false
local bEndVictimCheck = false

function F_StartMission() -- ! Modified
    local bCompleted = false
    local bx, by, bz = GetPointList(tblMissionParams[CurrentMissionIndex][1])
    local bTimerExpired = false
    PlayerSetInvulnerable(true) -- Added this
    F_SetVictim()
    F_SetVictim()
    Wait(100)
    F_EnterSnowBallCam(true, tblMissionParams[CurrentMissionIndex][1])
    TextPrint(tblMissionParams[CurrentMissionIndex][3], 5, 1)
    objId = MissionObjectiveAdd(tblMissionParams[CurrentMissionIndex][3], 1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    F_SetVictimCounter(VictimMax)
    BOSTimer(180)
    Wait(1000)
    CreateThread("F_CheckVicims")
    local bCopWasSummoned = false
    while bLoop do
        Wait(0)
        if CounterGetCurrent() >= CounterGetMax() then
            MissionObjectiveRemove(objId)
            break
        else
            F_RudySpeak()
        end
        if bResetPlayer == true then
            F_ResetPlayer()
        end
        PedSetPunishmentPoints(gRudy, PlayerGetPunishmentPoints())
        if PlayerGetPunishmentPoints() >= 300 and bCopWasSummoned == false then
            print("Here Comes the Cops")
            gCop1 = PedCreatePoint(97, POINTLIST._3_10_BIKER01, 1)
            PedMoveToPoint(gCop1, 2, POINTLIST._3_10_RudyMove01, 1)
            bCopWasSummoned = true
        end
        if bCopWasSummoned == true and gCop1 ~= nil and F_DistanceBetweenPeds(gCop1, gRudy) < 4 then
            bRudyBusted = true
            break
        end
        if BOSTimer() then
            bTimerExpired = true
            break
        end
        if bGuyGotHit == true then
            F_SetVictim()
            F_RudyCheer()
            bGuyGotHit = false
        end
        if not PlayerHasWeapon(313) and PlayerIsInAreaXYZ(bx, by, bz, 3, 1) then
            F_PlayerEquipSnowBall(true)
            F_RudyBoo()
        end
    end
    bEndVictimCheck = true
    Wait(1000)
    F_ClearVictimIcon()
    F_EnterSnowBallCam(false, tblMissionParams[CurrentMissionIndex][2], true)
    for i, tped in tblVictimInfo do
        if tped.lBike ~= nil then
            VehicleDelete(tped.lBike)
        end
    end
    BOSTimerEnd()
    if bRudyBusted == true then
        F_MissionFAILED()
    elseif bTimerExpired == true then
        F_MissionFAILEDTimer()
    else
        F_SetNextMission()
    end
end

local bDistWarning

function F_CheckDist()
    if F_DistanceBetweenPeds(gPlayer, gRudy) > 50 then
        if bDistWarning == nil then
            TutorialShowMessage("3_01A_WARNING2", -1, true)
            BOSTimer(30)
            bDistWarning = true
        elseif BOSTimer() == true then
            F_MissionFAILEDDist()
            bDistWarning = nil
            return true
        end
    elseif bDistWarning == true then
        BOSTimerEnd()
        TutorialRemoveMessage()
        bDistWarning = nil
    end
    return false
end

function F_MissionFAILEDDist()
    PedSetMissionCritical(gRudy, false)
    PedDelete(gRudy)
    SoundPlayMissionEndMusic(false, 10)
    MissionFail(false, true, "3_01A_FAIL_03")
end

function F_MissionFAILEDTimer()
    PedSetPunishmentPoints(gPlayer, 0)
    PedSetPunishmentPoints(gRudy, 0)
    DisablePunishmentSystem(true)
    AreaClearAllVehicles()
    PedSetMissionCritical(gRudy, false)
    PedDelete(gRudy)
    CameraReturnToPlayer()
    CameraFade(500, 1)
    Wait(500)
    SoundPlayMissionEndMusic(false, 10)
    MissionFail(false, true, "3_01A_FAIL_02")
end

function F_MissionFAILED()
    F_KillControls(true)
    PedSetPunishmentPoints(gPlayer, 0)
    PedSetPunishmentPoints(gRudy, 0)
    DisablePunishmentSystem(true)
    AreaClearAllVehicles()
    if gCop1 ~= nil and PedIsValid(gCop1) then
        PedDelete(gCop1)
    end
    PedSetMissionCritical(gRudy, false)
    PedDelete(gRudy)
    CameraReturnToPlayer()
    CameraFade(500, 1)
    Wait(500)
    F_KillControls(false)
    SoundPlayMissionEndMusic(false, 10)
    MissionFail(false, true, "3_01A_FAIL_01")
end

function F_MissionEnd()
    F_KillControls(true)
    PedSetPunishmentPoints(gPlayer, 0)
    PedSetPunishmentPoints(gRudy, 0)
    DisablePunishmentSystem(true)
    AreaClearAllVehicles()
    Wait(500)
    PlayCutsceneWithLoad("3-01AB", true)
    DisablePunishmentSystem(false)
    PedSetMissionCritical(gRudy, false)
    PedDelete(gRudy)
    PlayerSetPosPoint(POINTLIST._3_10_PLAYERWARP, 1)
    CameraReturnToPlayer()
    CameraFade(500, 1)
    Wait(500)
    F_KillControls(false)
    MinigameSetCompletion("M_PASS", true, 2000)
    SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
    SoundPlayMissionEndMusic(true, 10)
    Wait(2000)
    ClothingGivePlayer("SP_Antlers", 0)
    MinigameSetCompletion("MEN_BLANK", true, 0, "TUT_301A")
    MissionSucceed(false, false, false)
end

function F_KillControls(bOff)
    if bOff == true then
        print("**************** KillControl ON ********************")
        DisablePunishmentSystem(true)
        PauseGameClock()
        CameraSetWidescreen(true)
        PedMakeTargetable(gPlayer, false)
        PlayerSetControl(0)
    else
        print("**************** KillControl OFF ********************")
        DisablePunishmentSystem(false)
        UnpauseGameClock()
        CameraSetWidescreen(false)
        PedMakeTargetable(gPlayer, true)
        PlayerSetControl(1)
        ButtonHistoryIgnoreController(false)
        PedLockTarget(gPlayer, -1)
        SoundStopInteractiveStream()
        SoundEnableInteractiveMusic(true)
        PlayerWeaponHudLock(false)
        PlayerIgnoreTargeting(false)
    end
end

function EnableHudComponents(bShow)
    PlayerWeaponHudLock(not bShow)
    ToggleHUDComponentVisibility(11, bShow)
    ToggleHUDComponentVisibility(4, bShow)
    ToggleHUDComponentVisibility(0, bShow)
end

function F_SetVictimCounter(cMax)
    bCompleted = false
    CounterClearText()
    CounterSetCurrent(0)
    CounterSetMax(cMax)
    CounterSetIcon("snowface", "snowface_x")
    CounterMakeHUDVisible(true)
end

function F_HitAVictim()
    CounterIncrementCurrent(1)
    MissionObjectiveUpdateParam(objId, 1, CounterGetMax() - CounterGetCurrent())
    if CounterGetCurrent() >= CounterGetMax() then
        return true
    else
        return false
    end
end

function F_ClearVictimIcon(txtMissionText)
    if txtMissionText ~= nil then
        MissionObjectiveRemove(objId)
        objId = MissionObjectiveAdd(txtMissionText)
        MissionObjectiveComplete(objId)
    end
    Wait(100)
    CounterMakeHUDVisible(false)
    CounterSetMax(0)
    CounterSetCurrent(0)
    CounterClearIcon()
end

function F_SetVictim()
    if VictimCounter < VictimMax then
        VictimCounter = VictimCounter + 1
        --DebugPrint(" ************************* Vic Counter = " .. VictimCounter)
        PedSetTypeToTypeAttitude(3, 9, 4)
        lVictim[VictimCounter] = PedCreatePoint(tblPedModels[math.random(2, 6)], tblVictimInfo[VictimCounter].STARTFLG)
        tblVictimInfo[VictimCounter].HasBeenHit = false
        if tblVictimInfo[VictimCounter].TYPE == 1 then
            PedFollowPath(lVictim[VictimCounter], tblVictimInfo[VictimCounter].PATH, 1, 0)
        elseif tblVictimInfo[VictimCounter].TYPE == 2 then
            tblVictimInfo[VictimCounter].lBike = VehicleCreatePoint(ModelBikes[math.random(1, 4)], tblVictimInfo[VictimCounter].BIKESTART, 1)
            PedPutOnBike(lVictim[VictimCounter], tblVictimInfo[VictimCounter].lBike)
            PedFollowPath(lVictim[VictimCounter], tblVictimInfo[VictimCounter].PATH, 1, 0, F_FinishedRide, tblVictimInfo[VictimCounter].PATHSTART)
        else
            PedMoveToPoint(lVictim[VictimCounter], 1, tblVictimInfo[VictimCounter].MOVETO, 1)
        end
        lVictimBlip[VictimCounter] = AddBlipForChar(lVictim[VictimCounter], 12, 17, 4)
        PedIgnoreStimuli(lVictim[VictimCounter], true)
        PedSetStationary(lVictim[VictimCounter], false)
        PedIgnoreAttacks(lVictim[VictimCounter], true)
    end
end

function F_CheckVicims()
    local GotOne = false
    while true do
        for vIndex, vic in lVictim do
            if PedGetWhoHitMeLast(lVictim[vIndex]) == gPlayer and PedGetLastHitWeapon(lVictim[vIndex]) == 313 and tblVictimInfo[vIndex].HasBeenHit == false then
                BlipRemove(lVictimBlip[vIndex])
                tblVictimInfo[vIndex].HasBeenHit = true
                CounterIncrementCurrent(1)
                MissionObjectiveUpdateParam(objId, 1, CounterGetMax() - CounterGetCurrent())
                PedClearObjectives(lVictim[vIndex])
                PedSetStationary(lVictim[vIndex], false)
                PedIgnoreAttacks(lVictim[vIndex], false)
                PedIgnoreStimuli(lVictim[vIndex], false)
                PedClearHitRecord(lVictim[vIndex])
                PedMakeAmbient(lVictim[vIndex], true)
                PedSetMissionCritical(lVictim[vIndex], false)
                PedFlee(lVictim[vIndex], gPlayer)
                bGuyGotHit = true
            end
        end
        if bEndVictimCheck == true then
            break
        end
        Wait(0)
    end
end

function F_FinishedRide(pedID, pathID, PathNode)
end

function F_EnterSnowBallCam(bEnable, flgPlayerPos, bNoFadeIN)
    if bEnable == true then
        --print(">>>[RUI]", "++EnterSnowBallCam")
        CameraFade(500, 0)
        Wait(501)
        PlayerSetPosPoint(flgPlayerPos, 1)
        PedSetActionTree(gPlayer, "/Global/3_01A/SnowBall", ACTIONFILE)
        Wait(10)
        F_PlayerEquipSnowBall(true)
        Wait(10)
        PedSetFlag(gRudy, 117, true)
        PedMakeTargetable(gRudy, true)
        PedMakeTargetable(gPlayer, false)
        PedSetInvulnerable(gPlayer, true)
        RegisterPedEventHandler(gPlayer, 0, cbResetPlayer)
        AreaDisableCameraControlForTransition(false)
        CameraSetActive(13)
        Wait(0)
        CameraAllowChange(false)
        SoundPlayInteractiveStream("MS_XmasBellsRudyHigh.rsm", 0.9, 0, 500)
        SoundSetMidIntensityStream("MS_XmasBellsRudyHigh.rsm", 0.9, 0, 500)
        SoundSetHighIntensityStream("MS_XmasBellsRudyHigh.rsm", 0.9, 0, 500)
        if not bNoFadeIN then
            CameraFade(500, 1)
            Wait(501)
        end
    else
        --print(">>>[RUI]", "--EnterSnowBallCam")
        CameraFade(500, 0)
        Wait(501)
        SoundPlayInteractiveStream("MS_XmasBellsRudyLow.rsm", 0.9, 0, 500)
        SoundSetMidIntensityStream("MS_XmasBellsRudyMid.rsm", 0.9, 0, 500)
        SoundSetHighIntensityStream("MS_XmasBellsRudyHigh.rsm", 0.9, 0, 500)
        RegisterPedEventHandler(gPlayer, 0, nil)
        F_PlayerEquipSnowBall(false)
        Wait(200)
        PedSetActionTree(gPlayer, "/Global/Player", "Act/Player.act")
        PlayerSetPosPoint(flgPlayerPos, 1)
        PedSetFlag(gRudy, 117, false)
        PedMakeTargetable(gRudy, false)
        PedMakeTargetable(gPlayer, true)
        PedSetInvulnerable(gPlayer, false)
        CameraAllowChange(true)
        EnableHudComponents(true)
        CameraSetActive(1)
        AreaDisableCameraControlForTransition(false)
        CameraClearRotationLimit()
        CameraReturnToPlayer()
        CameraReset()
        if bNoFadeIN ~= true then
            print(" *******************  fade in worked **********************")
            CameraFade(500, 1)
            Wait(501)
        end
    end
end

local bResetPlayer = false

function cbResetPlayer()
    bResetPlayer = true
end

function F_ResetPlayer()
    F_EnterSnowBallCam(false, tblMissionParams[CurrentMissionIndex][1])
    PlayerSetControl(0)
    Wait(2000)
    PlayerSetControl(1)
    F_EnterSnowBallCam(true, tblMissionParams[CurrentMissionIndex][1])
    bResetPlayer = false
end

function F_PlayerEquipSnowBall(bEquip)
    if bEquip == true then
        --print(">>>[RUI]", "++PlayerEquipBaseball")
        PedSetActionNode(gPlayer, "/Global/3_01A/SnowBall/GiveBall/GiveBall", ACTIONFILE)
    else
        --print(">>>[RUI]", "--PlayerEquipBaseball")
        PedSetActionNode(gPlayer, "/Global/3_01A/SnowBall/RemoveBall", ACTIONFILE)
    end
end

local gSpeechPlayed = false
local gSpeechTimer = 0

function F_RudySpeak()
    if gSpeechPlayed == false then
        SoundStopCurrentSpeechEvent(gRudy)
        SoundPlayScriptedSpeechEvent(gRudy, "M_3_01A", 9, "jumbo", true)
        gSpeechPlayed = true
        gSpeechTimer = GetTimer()
    elseif GetTimer() - gSpeechTimer > 15000 then
        gSpeechPlayed = false
    end
end

function F_RudyCheer()
    print(" ********************** Rudy Cheer ******************************* ")
    SoundStopCurrentSpeechEvent(gRudy)
    SoundPlayScriptedSpeechEvent(gRudy, "M_3_01A", 10, "jumbo", true)
    gSpeechTimer = GetTimer()
    gSpeechPlayed = true
end

function F_RudyBoo()
    if gSpeechPlayed == false then
        SoundStopCurrentSpeechEvent(gRudy)
        SoundPlayScriptedSpeechEvent(gRudy, "M_3_01A", 11, "jumbo", true)
        gSpeechPlayed = true
        gSpeechTimer = GetTimer()
    elseif GetTimer() - gSpeechTimer > 20000 then
        gSpeechPlayed = false
    end
end

tblMissions = {
    F_InitMission,
    F_StartMission,
    F_MissionEnd
}

function F_SetNextMission()
    CurrentMissionIndex = CurrentMissionIndex + 1
    CurrentMission = tblMissions[CurrentMissionIndex]
    CurrentMission()
end

function F_RUDYBUSTED()
    print(" *************** Got Busted *************************")
    bRudyBusted = true
end

function BOSTimer(cTime)
    if cTime then
        MissionTimerStart(cTime)
    elseif MissionTimerHasFinished() then
        MissionTimerStop()
        return true
    end
    return false
end

function BOSTimerEnd()
    MissionTimerStop()
    ToggleHUDComponentVisibility(3, false)
end
