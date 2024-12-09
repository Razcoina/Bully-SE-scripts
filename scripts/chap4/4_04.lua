local bDebug = false
local gStage = 1
local gTablePeds = {}
local gNerds = {}
local gMissionState = "Running"
local toFunhouseTimer = 300
local bDoneSendingJocks = false
local gCurrentJock = 1
local nCurrentReaper = 1
local bAllJocksKilled = false
local nNerdsCurrentNode = -1
local nJocksCurrentNode = -1
local nMazeState = -1
local nJocksLeft = 0
local gGeoInfo = {}
local bCaseyDead = false
local bJuriDead = false
local bDanDead = false
local bJock1Fight = false
local bJock2Fight = false
local bJock3Fight = false
local gLastTimeScreamedForHelp = 0
local nMiner1Deactivated = 0
local nMiner2Deactivated = 0
local nMiner3Deactivated = 0
local bNerd1Dance = false
local bNerd2Dance = false
local bCurtainsOpen = false
local x, y, z = 0, 0, 0
local bDoneNIS = false
local bThadDied = false
local bFattyDied = false
local bStopWitches = false
local bNerdsSent = false
local bGetToMines = false
local gMineBlips = {}
function MissionSetup()
  MissionDontFadeIn()
  DATLoad("4_04.DAT", 2)
  DATInit()
  PlayerSetControl(0)
  LoadActionTree("Act/Conv/4_04.act")
  tblJockModels = {
    20,
    13,
    15,
    16,
    17,
    18
  }
  tblNerdModels = {8, 5}
  LoadPedModels(tblJockModels)
  LoadPedModels(tblNerdModels)
  LoadAnimationGroup("Ambient")
  LoadAnimationGroup("Hang_Jock")
  LoadAnimationGroup("NPC_Adult")
  LoadAnimationGroup("4_04_FunhouseFun")
  LoadAnimationGroup("NPC_AggroTaunt")
  PlayCutsceneWithLoad("4-04", true)
  PedSetTypeToTypeAttitude(2, 13, 1)
end
function MissionCleanup()
  if gMissionState == "Failed" and table.getn(gNerds) > 0 then
    AreaTransitionPoint(0, POINTLIST._4_04_FAILEXIT, 1)
  end
  if PAnimExists(TRIGGER._FUNTEETH) then
    PAnimCloseDoor(TRIGGER._FUNTEETH)
    AreaSetDoorLocked(TRIGGER._FUNTEETH, true)
    AreaSetDoorLockedToPeds(TRIGGER._FUNTEETH, true)
    AreaSetDoorPathableToPeds(TRIGGER._FUNTEETH, false)
  end
  SoundFadeWithCamera(true)
  MusicFadeWithCamera(true)
  UnLoadAnimationGroup("Ambient")
  UnLoadAnimationGroup("Hang_Jock")
  UnLoadAnimationGroup("NPC_Adult")
  UnLoadAnimationGroup("4_04_FunhouseFun")
  UnLoadAnimationGroup("NPC_AggroTaunt")
  PlayerSetControl(1)
  CameraDefaultFOV()
  CameraSetWidescreen(false)
  F_MakePlayerSafeForNIS(false)
  EnablePOI(true, true)
  SoundStopInteractiveStream()
  SoundEnableSpeech_ActionTree()
  if table.getn(gGeoInfo) > 0 then
    DeletePersistentEntity(gGeoInfo[1].obj, gGeoInfo[1].id)
  end
  F_CleanupNerds(false)
  ToggleHUDComponentVisibility(39, false)
  ToggleHUDComponentVisibility(11, true)
  MonitorSetText(0, "")
  MonitorSetText(1, "")
  MonitorSetText(2, "")
  MonitorSetText(3, "")
  AreaDisableCameraControlForTransition(false)
  SoundSetAudioFocusPlayer()
  DATUnload(2)
end
function main()
  gCurrentStage = F_SetupGoToFunHouse
  if bDebug then
    if gStage == 1 then
      gCurrentStage = F_SetupGraveyard
    elseif gStage == 2 then
      gCurrentStage = F_GoToMaze
    elseif gStage == 3 then
      gCurrentStage = F_SetupReachEndOfMine
    elseif gStage == 4 then
      gCurrentStage = F_SetupMoveToExit
      while gMissionState == "Running" do
        gCurrentStage()
        if bThadDied or bFattyDied then
          gMissionState = "Failed"
          break
        end
        Wait(0)
      end
    end
  end
  if gMissionState == "Completed" then
    CameraSetFOV(80)
    CameraSetXYZ(122.56052, 451.18747, 7.548725, 123.529434, 450.94116, 7.538793)
    x, y, z = GetPointFromPointList(POINTLIST._4_04_NerdsEndDest, 1)
    SoundPlayScriptedSpeechEvent(gNerds[2].id, "M_4_04", 1, "supersize", false)
    CameraFade(500, 1)
    CameraSetFOV(80)
    Wait(501)
    PedSetActionNode(gPlayer, "/Global/404Conv/Take", "Act/Conv/4_04.act")
    PedSetActionNode(gNerds[2].id, "/Global/404Conv/Give", "Act/Conv/4_04.act")
    Wait(3000)
    MinigameSetCompletion("M_PASS", true, 2500)
    MinigameAddCompletionMsg("MRESPECT_NP5", 2)
    MinigameAddCompletionMsg("MRESPECT_JM10", 1)
    SoundPlayMissionEndMusic(true, 4)
    SetFactionRespect(2, GetFactionRespect(2) - 10)
    SetFactionRespect(1, GetFactionRespect(1) + 5)
    PedSetInfiniteSprint(gNerds[1].id, true)
    PedSetInfiniteSprint(gNerds[2].id, true)
    PedMoveToXYZ(gNerds[1].id, 2, x, y, z)
    PedMoveToXYZ(gNerds[2].id, 2, x, y, z)
    PedMakeAmbient(gNerds[1].id)
    PedMakeAmbient(gNerds[2].id)
    while MinigameIsShowingCompletion() do
      Wait(0)
    end
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    CameraFade(500, 0)
    Wait(501)
    CameraReturnToPlayer(true)
    MissionSucceed(true, false, false)
  elseif gMissionState == "RanOutOfTime" then
    MissionFail(false, true, "4_04_FAIL03")
    SoundPlayMissionEndMusic(false, 4)
  else
    SoundPlayMissionEndMusic(false, 4)
    if 0 < table.getn(gNerds) then
      if 0 >= PedGetHealth(gNerds[1].id) then
        MissionFail(true, true, "4_04_THADIED")
      elseif 0 >= PedGetHealth(gNerds[2].id) then
        MissionFail(true, true, "4_04_FATTYDIED")
      end
    else
      MissionFail(true, true)
    end
  end
end
function F_SetupGoToFunHouse()
  ManagedPlayerSetPosPoint(POINTLIST._4_04_PSTART)
  local x, y, z = GetAnchorPosition(TRIGGER._SV_CARNIVALFUNHOUSE)
  F_AddObjectiveBlip("POINT", nil, nil, 1, x, y, z)
  PlayerSetControl(1)
  CameraFade(500, 1)
  Wait(501)
  TextPrint("4_04_INSTRUC00A", 3, 1)
  F_AddMissionObjective("4_04_INSTRUC00A")
  MissionTimerStart(toFunhouseTimer)
  gCurrentStage = F_GoToFunHouse
end
function F_GoToFunHouse()
  F_MissionTimerOut()
  local x, y, z = GetPointFromPointList(POINTLIST._4_04_ENTRANCE, 1)
  PlayerIsInAreaXYZ(x, y, z, 2, 7)
  if PlayerIsInTrigger(TRIGGER._4_04_REACHED_FUNHOUSE) then
    MissionTimerStop()
    shared.g404GotKey = true
    gCurrentStage = F_PlayerEnteredFunhouse
  end
end
function F_PlayerEnteredFunhouse()
  if shared.gAreaDATFileLoaded[37] then
    SoundPlayInteractiveStream("MS_CarnivalFunhouseAmbient.rsm", 0.3, 0, 1000)
    F_RemoveObjectiveBlip()
    F_CompleteMissionObjective("4_04_INSTRUC00A")
    F_AddMissionObjective("4_04_INSTRUC00B")
    TextPrint("4_04_INSTRUC00B", 4, 1)
    gCurrentStage = F_SetupFirstRoom
  elseif PAnimExists(TRIGGER._FUNTEETH) and PAnimIsPlayingNode(TRIGGER._FUNTEETH, "Closed") then
    PAnimOpenDoor(TRIGGER._FUNTEETH)
    PAnimDoorStayOpen(TRIGGER._FUNTEETH)
  end
end
function F_SetupFirstRoom()
  if PlayerIsInTrigger(TRIGGER._FUNHOUSE_UPSIDEDOWN) then
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FLBBOOK, "/Global/FunBook/NotUseable", "Act/Props/FunBook.act")
    gTablePeds[1] = {
      id = PedCreatePoint(18, POINTLIST._4_04_UDR_JOCK_01, 1)
    }
    gTablePeds[2] = {
      id = PedCreatePoint(13, POINTLIST._4_04_UDR_JOCK_02, 1)
    }
    GameSetPedStat(gTablePeds[1].id, 0, 362)
    GameSetPedStat(gTablePeds[1].id, 1, 100)
    PedClearAllWeapons(gTablePeds[2].id)
    PedClearAllWeapons(gTablePeds[1].id)
    F_SetupNerds(POINTLIST._4_04_UPSIDENERDS, POINTLIST._4_04_UPSIDENERDS2, false)
    PedAttack(gTablePeds[1].id, gNerds[1].id, 1)
    PedAttack(gTablePeds[1].id, gNerds[2].id, 1)
    PedAttack(gTablePeds[2].id, gNerds[2].id, 1)
    PedAttack(gTablePeds[2].id, gNerds[1].id, 1)
    PedAttack(gNerds[1].id, gTablePeds[1].id, 1)
    PedAttack(gNerds[1].id, gTablePeds[2].id, 1)
    PedAttack(gNerds[2].id, gTablePeds[2].id, 1)
    PedAttack(gNerds[2].id, gTablePeds[1].id, 1)
    SoundPlayScriptedSpeechEvent(gNerds[2].id, "SCARED", 0, "supersize", true)
    gCurrentStage = F_MonitorFirstRoom
  end
end
local bNerdObjectiveGiven = false
function F_MonitorFirstRoom()
  if not bNerdObjectiveGiven and PlayerIsInTrigger(TRIGGER._4_04_JOCKNIS) then
    bNerdObjectiveGiven = true
    F_CompleteMissionObjective("4_04_INSTRUC00B")
    F_AddMissionObjective("4_04_INSTRUC00")
    TextPrint("4_04_INSTRUC00", 4, 1)
    PedShowHealthBar(gNerds[1].id, true, "4_04_THAD", false, gNerds[2].id, "4_04_FATTY")
  end
  F_NerdsStillAlive()
  if F_JocksKilled() then
    F_NerdsTalkToPlayer()
    gCurrentStage = F_SetupGraveyard
  end
end
local bSetRotationLimit = false
function F_SetupGraveyard()
  if not bSetRotationLimit then
    if PedMePlaying(gPlayer, "Ladder", true) or PedMePlaying(gPlayer, "Climb_ON_BOT", true) or PedMePlaying(gPlayer, "TreeCheck", false) then
      bSetRotationLimit = true
      CameraSetXYZ(-749.1673, -536.1852, 12.608851, -749.6231, -536.949, 12.151998)
      Wait(500)
      CameraAllowChange(false)
    end
  elseif bSetRotationLimit and not PedMePlaying(gPlayer, "Ladder", true) and not PedMePlaying(gPlayer, "Climb_ON_BOT", true) and not PedMePlaying(gPlayer, "TreeCheck", false) then
    bSetRotationLimit = false
    CameraAllowChange(true)
    Wait(1)
    CameraReturnToPlayer(false)
  end
  if PlayerIsInTrigger(TRIGGER._FUNHOUSE_U_TO_G_TRANS) or bDebug then
    if bDebug then
      bDebug = false
      AreaTransitionPoint(37, POINTLIST._4_04_GRAVESTARTDBG, 1, false)
    end
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    PlayerSetControl(0)
    F_CleanupNerds(true)
    PedSetActionNode(gPlayer, "/Global/Ladder/PedPropsActions/DisEngage/reset_flags", "Act/Props/Ladder.act")
    PedSetFlag(gPlayer, 46, false)
    F_RestoreDefaultCam()
    F_SetupGraveyardCam()
    F_AddObjectiveBlip("POINT", POINTLIST._4_04_GRAVEBLIP1, 1, 1)
    PlayerSetPosPoint(POINTLIST._GRAVEYARD_START)
    AreaSetDoorLocked(TRIGGER._DT_IFUNHOUS_FMDOOR, false)
    AreaSetDoorLocked(TRIGGER._IFUNHOUS_CTRLROOM, true)
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER00, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER00B, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER01, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER01B, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER02, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER02B, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
    local geoObj, geoId = CreatePersistentEntity("fun_coffinExit", -751.251, -502.285, 26.7172, 0, 37)
    GeometryInstance("fun_coffinExit", false, -751.251, -502.285, 26.7172, true)
    table.insert(gGeoInfo, {obj = geoObj, id = geoId})
    CreateThread("T_WitchMonitor")
    CameraFade(500, 1)
    Wait(500)
    F_CompleteMissionObjective("4_04_INSTRUC01")
    F_AddMissionObjective("4_04_INSTRUC02")
    TextPrint("4_04_INSTRUC02", 4, 1)
    PedSetActionNode(gPlayer, "/Global/Player/JumpActions/Jump/IdleJump", "Act/Player.act")
    PlayerSetControl(1)
    gCurrentStage = F_GraveyardMonitor
  end
end
local bInPlaceGoingIn = false
local bInPlaceGoingOut = false
local nCurrentEntrance = 0
function F_GraveyardMonitor()
  bInPlaceGoingIn = false
  bInPlaceGoingOut = false
  x, y, z = GetPointFromPointList(POINTLIST._4_04_GRVDOORCORONAS, 1)
  if PlayerIsInAreaXYZ(x, y, z, 2, 0) then
    bInPlaceGoingIn = true
    nCurrentEntrance = 1
  end
  if bInPlaceGoingIn and PedIsPlaying(gPlayer, "/Global/Door/PedPropsActions", true) then
    PlayerSetControl(0)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    F_AddObjectiveBlip("POINT", POINTLIST._4_04_GRAVEBLIP2, 1, 1)
    PlayerSetPosPoint(POINTLIST._4_04_CONTROLROOM, 1)
    F_RestoreDefaultCam()
    CameraFade(500, 1)
    Wait(501)
    PlayerSetControl(1)
    F_CompleteMissionObjective("4_04_INSTRUC02")
    F_AddMissionObjective("4_04_ACTIVATEREPR")
    TextPrint("4_04_ACTIVATEREPR", 4, 1)
  end
  x, y, z = GetPointFromPointList(POINTLIST._4_04_CTRLROOMCORONAS, 1)
  if PlayerIsInAreaXYZ(x, y, z, 2, 0) then
    bInPlaceGoingOut = true
  end
  if not bNerdsSent then
    local x, y, z = GetPointFromPointList(POINTLIST._4_04_AFTERREAPER, 1)
    PlayerIsInAreaXYZ(x, y, z, 2, 7)
  end
  if bInPlaceGoingOut and PedIsPlaying(gPlayer, "/Global/Door/PedPropsActions", true) then
    PlayerSetControl(0)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    PlayerSetPosPoint(POINTLIST._4_04_GRVDOORCORONAS, nCurrentEntrance)
    F_SetupGraveyardCam()
    if bNerdsSent then
      gCurrentStage = F_SetupGoToMaze
    end
    CameraFade(500, 1)
    Wait(501)
    PlayerSetControl(1)
  end
end
function F_ProcessMonitor()
  SoundFadeWithCamera(false)
  MusicFadeWithCamera(false)
  CameraFade(500, 0)
  Wait(501)
  GeometryInstance("fun_coffinExit", true, -751.251, -502.285, 26.7172, false)
  F_SetupReaper()
  MonitorSetText(0, "")
  MonitorSetText(1, "")
  MonitorSetText(2, "")
  MonitorSetText(3, "")
  ToggleHUDComponentVisibility(39, false)
  ToggleHUDComponentVisibility(11, true)
  PedSetActionNode(gPlayer, "/Global/404Conv/QuickIdle/Anim", "Act/Conv/4_04.act")
  F_RestoreDefaultCam()
  PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER00, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER00B, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER01, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER01B, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER02, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER02B, "/Global/FunReapr/Active", "Act/Props/FunReapr.act")
  F_AddObjectiveBlip("POINT", POINTLIST._4_04_GRAVE_ESCAPE, 1, 1)
  AreaSetDoorLocked(TRIGGER._DT_IFUNHOUS_FMDOOR, true)
  nJocksLeft = 0
  for i, ped in gTablePeds, nil, nil do
    if ped.id and not PedIsDead(ped.id) and PedIsValid(ped.id) then
      nJocksLeft = nJocksLeft + 1
    end
  end
  for i, ped in gTablePeds, nil, nil do
    if ped.id and PedIsValid(ped.id) then
      PedDelete(ped.id)
    end
  end
  gTablePeds = {}
  PlayerSetControl(1)
  CameraFade(500, 1)
  Wait(501)
  AreaSetDoorLocked(TRIGGER._IFUNHOUS_CTRLROOM, false)
  F_CompleteMissionObjective("4_04_ACTIVATEREPR")
  F_AddMissionObjective("4_04_INSTRUC03")
  TextPrint("4_04_INSTRUC03", 4, 1)
  bNerdsSent = true
  gCurrentStage = F_GraveyardMonitor
end
function F_SetupGoToMaze()
  x, y, z = GetPointFromPointList(POINTLIST._4_04_GRAVETOMAZE, 1)
  if PlayerIsInAreaXYZ(x, y, z, 1, 7) or bDebug then
    PlayerSetControl(0)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    gCurrentStage = F_GoToMaze
  end
end
function F_GoToMaze()
  if bDebug then
    bDebug = false
    nJocksLeft = 0
    AreaTransitionPoint(37, POINTLIST._4_04_MAZESTART, 1, false)
  else
    PlayerSetPosPoint(POINTLIST._4_04_MAZESTART, 1)
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER00, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER00B, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER01, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER01B, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER02, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER02B, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
  end
  bGetToMines = true
  bStopWitches = true
  F_RemoveObjectiveBlip()
  F_CleanupNerds(true)
  F_RestoreDefaultCam()
  LoadPAnims({
    TRIGGER._IFUNHOUS_FMTRAPDR00L,
    TRIGGER._IFUNHOUS_FMTRAPDR01L,
    TRIGGER._IFUNHOUS_FMTRAPDR02L,
    TRIGGER._IFUNHOUS_FMTRAPDR03L,
    TRIGGER._IFUNHOUS_FMTRAPDR00O,
    TRIGGER._IFUNHOUS_FMTRAPDR01O,
    TRIGGER._IFUNHOUS_FMTRAPDR02O,
    TRIGGER._IFUNHOUS_FMTRAPDR03O
  })
  LoadPAnims({
    TRIGGER._IFUNHOUS_FMTRAPSW,
    TRIGGER._IFUNHOUS_FMTRAPSWB,
    TRIGGER._IFUNHOUS_FMTRAPSW01,
    TRIGGER._IFUNHOUS_FMTRAPSW02,
    TRIGGER._IFUNHOUS_FMTRAPSW03,
    TRIGGER._IFUNHOUS_FMTRAPSW04,
    TRIGGER._IFUNHOUS_FMTRAPSW05,
    TRIGGER._IFUNHOUS_FMTRAPSW06,
    TRIGGER._IFUNHOUS_FMTRAPSW07,
    TRIGGER._IFUNHOUS_FMTRAPSW01B,
    TRIGGER._IFUNHOUS_FMTRAPSW02B,
    TRIGGER._IFUNHOUS_FMTRAPSW03B,
    TRIGGER._IFUNHOUS_FMTRAPSW04B,
    TRIGGER._IFUNHOUS_FMTRAPSW05B,
    TRIGGER._IFUNHOUS_FMTRAPSW06B,
    TRIGGER._IFUNHOUS_FMTRAPSW07B
  })
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR00L, "/Global/FMTrapDr/CloseToEndQuick", "Act/Prop/FMTrapDr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR01L, "/Global/FMTrapDr/CloseToEndQuick", "Act/Prop/FMTrapDr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR02L, "/Global/FMTrapDr/CloseToEndQuick", "Act/Prop/FMTrapDr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR03L, "/Global/FMTrapDr/CloseToEndQuick", "Act/Prop/FMTrapDr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR00O, "/Global/FMTrapDr/OpenToEndQuick", "Act/Prop/FMTrapDr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR01O, "/Global/FMTrapDr/OpenToEndQuick", "Act/Prop/FMTrapDr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR02O, "/Global/FMTrapDr/OpenToEndQuick", "Act/Prop/FMTrapDr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR03O, "/Global/FMTrapDr/OpenToEndQuick", "Act/Prop/FMTrapDr.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSWB, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW01, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW02, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW03, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW04, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW05, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW06, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW07, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW01B, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW02B, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW03B, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW04B, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW05B, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW06B, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPSW07B, "/Global/Switch/Inactive", "Act/Prop/Switch.act")
  F_SetupNerds(POINTLIST._4_04_MAZENERDS, POINTLIST._4_04_MAZENERDS2, false)
  F_SetupJocksInTheMaze()
  TextPrintString("", 1, 1)
  PlayerSetControl(1)
  CameraFade(500, 1)
  Wait(500)
  F_CompleteMissionObjective("4_04_INSTRUC03")
  F_AddMissionObjective("4_04_INSTRUC04A")
  TextPrint("4_04_INSTRUC04A", 4, 1)
  gCurrentStage = F_TravelThroughMaze
end
local bFattyAlly = false
local bThadAlly = false
local bMazeBlip = false
function F_TravelThroughMaze()
  if nMazeState == 1 then
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR00L, "/Global/FMTrapDr/OpenToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR01L, "/Global/FMTrapDr/OpenToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR02L, "/Global/FMTrapDr/OpenToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR03L, "/Global/FMTrapDr/OpenToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR00O, "/Global/FMTrapDr/CloseToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR01O, "/Global/FMTrapDr/CloseToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR02O, "/Global/FMTrapDr/CloseToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR03O, "/Global/FMTrapDr/CloseToEnd", "Act/Prop/FMTrapDr.act")
    nMazeState = -2
  elseif nMazeState == 2 then
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR00L, "/Global/FMTrapDr/CloseToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR01L, "/Global/FMTrapDr/CloseToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR02L, "/Global/FMTrapDr/CloseToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR03L, "/Global/FMTrapDr/CloseToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR00O, "/Global/FMTrapDr/OpenToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR01O, "/Global/FMTrapDr/OpenToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR02O, "/Global/FMTrapDr/OpenToEnd", "Act/Prop/FMTrapDr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FMTRAPDR03O, "/Global/FMTrapDr/OpenToEnd", "Act/Prop/FMTrapDr.act")
    nMazeState = -1
  end
  if GetTimer() - gLastTimeScreamedForHelp > 6000 then
    local randomRoll = 0
    if not bThadAlly and not bFattyAlly then
      randomRoll = math.random(1, 100)
    elseif not bThadAlly then
      randomRoll = 51
    elseif not bFattyAlly then
      randomRoll = 1
    end
    if randomRoll > 50 then
      if not bThadAlly then
        SoundPlayScriptedSpeechEvent(gNerds[1].id, "ALLY_HELP_ME", 0, "xtralarge", false)
      end
    elseif not bFattyAlly then
      SoundPlayScriptedSpeechEvent(gNerds[2].id, "ALLY_HELP_ME", 0, "xtralarge", false)
    end
    gLastTimeScreamedForHelp = GetTimer()
  end
  if not bThadAlly and PlayerIsInTrigger(TRIGGER._4_04_MAZE_HALL_05) then
    bThadAlly = true
    if bFattyAlly then
      PedRecruitAlly(gNerds[2].id, gNerds[1].id)
      PedShowHealthBar(gNerds[1].id, true, "4_04_THAD", false, gNerds[2].id, "4_04_FATTY")
      F_SetupGoToMineObjectives()
    else
      PedRecruitAlly(gPlayer, v[1].id)
      PedShowHealthBar(gNerds[2].id, true, "4_04_THAD", false)
      F_AddMissionObjective("4_04_FINDFATTY")
      F_CompleteMissionObjective("4_04_INSTRUC04A")
      TextPrint("4_04_FINDFATTY", 4, 1)
    end
    SoundStopCurrentSpeechEvent(gNerds[1].id)
    SoundPlayScriptedSpeechEvent(gNerds[1].id, "THANKS_JIMMY", 0, "large", false)
  end
  if not bFattyAlly and PlayerIsInTrigger(TRIGGER._4_04_MAZE_HALL_07) then
    bFattyAlly = true
    if bThadAlly then
      PedRecruitAlly(gNerds[1].id, gNerds[2].id)
      PedShowHealthBar(gNerds[1].id, true, "4_04_THAD", false, gNerds[2].id, "4_04_FATTY")
      F_SetupGoToMineObjectives()
    else
      PedRecruitAlly(gPlayer, gNerds[2].id)
      PedShowHealthBar(gNerds[2].id, true, "4_04_FATTY", false)
      F_AddMissionObjective("4_04_FINDTHAD")
      F_CompleteMissionObjective("4_04_INSTRUC04A")
      TextPrint("4_04_FINDTHAD", 4, 1)
    end
    SoundStopCurrentSpeechEvent(gNerds[2].id)
    SoundPlayScriptedSpeechEvent(gNerds[2].id, "THANKS_JIMMY", 0, "large", false)
  end
  if not bJock1Fight and (PedCanSeeObject(gTablePeds[1].id, gPlayer, 3) or PedIsHit(gTablePeds[1].id, 2, 1000)) then
    PedStop(gTablePeds[1].id)
    PedClearObjectives(gTablePeds[1].id)
    bJock1Fight = true
    SoundPlayScriptedSpeechEvent(gTablePeds[1].id, "FIGHT_INITIATE", 0, "large", false)
    PedAttack(gTablePeds[1].id, gPlayer, 1)
  elseif not bJock2Fight and (PedCanSeeObject(gTablePeds[2].id, gPlayer, 3) or PedIsHit(gTablePeds[2].id, 2, 1000)) then
    PedStop(gTablePeds[2].id)
    PedClearObjectives(gTablePeds[2].id)
    bJock2Fight = true
    SoundPlayScriptedSpeechEvent(gTablePeds[2].id, "FIGHT_INITIATE", 0, "large", false)
    PedAttack(gTablePeds[2].id, gPlayer, 1)
  elseif not bJock3Fight and (PedCanSeeObject(gTablePeds[3].id, gPlayer, 3) or PedIsHit(gTablePeds[3].id, 2, 1000)) then
    PedStop(gTablePeds[3].id)
    PedClearObjectives(gTablePeds[3].id)
    bJock3Fight = true
    SoundPlayScriptedSpeechEvent(gTablePeds[3].id, "FIGHT_INITIATE", 0, "large", false)
    PedAttack(gTablePeds[3].id, gPlayer, 1)
  end
  if bFattyAlly and bThadAlly then
    if AreaIsDoorLocked(TRIGGER._IFUNHOUS_MZEMINE) then
      if PedIsInTrigger(gNerds[1].id, TRIGGER._4_04_MAZE_HALL_08) and PedIsInTrigger(gNerds[2].id, TRIGGER._4_04_MAZE_HALL_08) and not bMazeBlip then
        AreaSetDoorLocked(TRIGGER._IFUNHOUS_MZEMINE, false)
        F_AddObjectiveBlip("POINT", POINTLIST._4_04_ENDMAZEDOOR, 1, 1)
        bMazeBlip = true
      end
    else
      x, y, z = GetPointFromPointList(POINTLIST._4_04_ENDMAZEDOOR, 1)
      if PlayerIsInAreaXYZ(x, y, z, 4, 0) and PedIsPlaying(gPlayer, "/Global/Door/PedPropsActions", true) then
        PlayerSetControl(0)
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        Wait(501)
        gCurrentStage = F_SetupReachEndOfMine
      elseif (not PedIsInTrigger(gNerds[1].id, TRIGGER._4_04_MAZE_HALL_08) or not PedIsInTrigger(gNerds[2].id, TRIGGER._4_04_MAZE_HALL_08)) and not bMazeBlip then
        AreaSetDoorLocked(TRIGGER._IFUNHOUS_MZEMINE, true)
      end
    end
  end
end
function F_SetupGoToMineObjectives()
  F_RemoveMissionObjective("4_04_INSTRUC00A")
  F_RemoveMissionObjective("4_04_INSTRUC00B")
  F_RemoveMissionObjective("4_04_INSTRUC00")
  F_RemoveMissionObjective("4_04_INSTRUC01")
  F_RemoveMissionObjective("4_04_INSTRUC02")
  F_CompleteMissionObjective("4_04_FINDFATTY")
  F_CompleteMissionObjective("4_04_FINDTHAD")
  F_AddMissionObjective("4_04_INSTRUC04")
  TextPrint("4_04_INSTRUC04", 4, 1)
end
function F_SetupReachEndOfMine()
  if bDebug then
    bDebug = false
    AreaTransitionPoint(37, POINTLIST._4_04_MINESTARTPOS, 1, false)
  else
    PlayerSetPosXYZ(-764.595, -451.721, 15.502)
  end
  LoadPAnims({
    TRIGGER._IFUNHOUS_FMCNTRL08,
    TRIGGER._IFUNHOUS_FMCTRLMINE02,
    TRIGGER._IFUNHOUS_FMCTRLMINE03,
    TRIGGER._IFUNHOUS_FUNMINERB,
    TRIGGER._IFUNHOUS_FUNMINERD,
    TRIGGER._IFUNHOUS_FUNMINERG,
    TRIGGER._IFUNHOUS_FUNMINERH,
    TRIGGER._IFUNHOUS_FUNMINERI,
    TRIGGER._IFUNHOUS_FUNMINERX1,
    TRIGGER._IFUNHOUS_FUNMINERX2,
    TRIGGER._IFUNHOUS_FUNMINERX3,
    TRIGGER._IFUNHOUS_FUNMINERX4
  })
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERB, "/Global/FunMiner/Active", "Act/Prop/FunMiner.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERD, "/Global/FunMiner/Active", "Act/Prop/FunMiner.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERG, "/Global/FunMiner/Active", "Act/Prop/FunMiner.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERH, "/Global/FunMiner/Active", "Act/Prop/FunMiner.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERI, "/Global/FunMiner/Active", "Act/Prop/FunMiner.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX1, "/Global/FunMiner/Active", "Act/Prop/FunMiner.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX2, "/Global/FunMiner/Active", "Act/Prop/FunMiner.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX3, "/Global/FunMiner/Active", "Act/Prop/FunMiner.act")
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX4, "/Global/FunMiner/Active", "Act/Prop/FunMiner.act")
  F_CleanMazeJocks()
  F_CleanupNerds(true)
  F_SetupMiningJocks()
  F_SetupNerds(POINTLIST._4_04_MINENERDS1, POINTLIST._4_04_MINENERDS2, true)
  F_CompleteMissionObjective("4_04_INSTRUC04A")
  F_RemoveObjectiveBlip()
  PlayerSetControl(1)
  CameraFade(500, 1)
  Wait(501)
  table.insert(gMineBlips, {
    blip = BlipAddPoint(POINTLIST._4_04_MINEJOCKS, 0, 1, 1),
    bDisabled = false,
    nPoint = 1
  })
  table.insert(gMineBlips, {
    blip = BlipAddPoint(POINTLIST._4_04_MINEJOCKS, 0, 2, 1),
    bDisabled = false,
    nPoint = 2
  })
  table.insert(gMineBlips, {
    blip = BlipAddPoint(POINTLIST._4_04_MINEJOCKS, 0, 3, 1),
    bDisabled = false,
    nPoint = 3
  })
  PedFollowPath(gNerds[1].id, PATH._4_04_NERDR0, 0, 1, CB_Nerd1BegginingMinePath)
  PedFollowPath(gNerds[2].id, PATH._4_04_NERDL0, 0, 1, CB_Nerd2BegginingMinePath)
  F_CompleteMissionObjective("4_04_INSTRUC04")
  F_AddMissionObjective("4_04_INSTRUC05A")
  TextPrint("4_04_INSTRUC05A", 4, 1)
  gCurrentStage = F_ReachEndOfMine
end
function CB_Nerd1BegginingMinePath(pedId, pathId, nodeId)
  if nodeId == PathGetLastNode(PATH._4_04_NERDR0) then
    gNerds[1].bReachedPathEnd = true
  end
end
function CB_Nerd2BegginingMinePath(pedId, pathId, nodeId)
  if nodeId == PathGetLastNode(PATH._4_04_NERDL0) then
    gNerds[2].bReachedPathEnd = true
  end
end
function F_ReachEndOfMine()
  if not gTablePeds[1].bFight and (PedIsHit(gTablePeds[1].id, 2, 1000) or PlayerIsInTrigger(TRIGGER._4_04_MONITOR01)) then
    gTablePeds[1].bFight = true
    if PlayerIsInTrigger(TRIGGER._4_04_MONITOR01) then
      PedSetActionNode(gTablePeds[1].id, "/Global/404Conv/Idle", "Act/Conv/4_04.act")
    else
      PedSetActionNode(gTablePeds[1].id, "/Global/404Conv/QuickIdle", "Act/Conv/4_04.act")
    end
    PedAttack(gTablePeds[1].id, gPlayer, 1)
  end
  if not gTablePeds[2].bFight and (PedIsHit(gTablePeds[2].id, 2, 1000) or PlayerIsInTrigger(TRIGGER._4_04_MONITOR02)) then
    gTablePeds[2].bFight = true
    if PlayerIsInTrigger(TRIGGER._4_04_MONITOR02) then
      PedSetActionNode(gTablePeds[2].id, "/Global/404Conv/Idle", "Act/Conv/4_04.act")
    else
      PedSetActionNode(gTablePeds[2].id, "/Global/404Conv/QuickIdle", "Act/Conv/4_04.act")
    end
    PedAttack(gTablePeds[2].id, gPlayer, 1)
  end
  if not gTablePeds[3].bFight and (PedIsHit(gTablePeds[3].id, 2, 1000) or PlayerIsInTrigger(TRIGGER._4_04_MONITOR03)) then
    gTablePeds[3].bFight = true
    if PlayerIsInTrigger(TRIGGER._4_04_MONITOR03) then
      PedSetActionNode(gTablePeds[3].id, "/Global/404Conv/Idle", "Act/Conv/4_04.act")
    else
      PedSetActionNode(gTablePeds[3].id, "/Global/404Conv/QuickIdle", "Act/Conv/4_04.act")
    end
    PedAttack(gTablePeds[3].id, gPlayer, 1)
  end
  local x, y, z
  for i, entry in gMineBlips, nil, nil do
    if not entry.bDisabled then
      x, y, z = GetPointFromPointList(POINTLIST._4_04_MINEJOCKS, entry.nPoint)
      PlayerIsInAreaXYZ(x, y, z, 4, 7)
    end
  end
  if nMiner1Deactivated == 1 then
    nMiner1Deactivated = 2
    F_DoSwitchNIS(1)
    CameraDefaultFOV()
  end
  if nMiner2Deactivated == 1 then
    nMiner2Deactivated = 2
    F_DoSwitchNIS(2)
    CameraDefaultFOV()
  end
  if nMiner3Deactivated == 1 then
    nMiner3Deactivated = 2
    F_DoSwitchNIS(3)
    CameraDefaultFOV()
  end
  if nMiner1Deactivated == 0 then
    if gNerds[1].bReachedPathEnd then
      gNerds[1].bReachedPathEnd = false
      x, y, z = GetPointFromPointList(POINTLIST._4_04_FACEPOINTMINE, 1)
      PedFaceXYZ(gNerds[1].id, x, y, z, 1)
    end
    if gNerds[2].bReachedPathEnd then
      gNerds[2].bReachedPathEnd = false
      x, y, z = GetPointFromPointList(POINTLIST._4_04_FACEPOINTMINE, 1)
      PedFaceXYZ(gNerds[2].id, x, y, z, 1)
    end
  end
  if AreaIsDoorLocked(TRIGGER._IFUNHOUS_MINEEND) and nMiner1Deactivated == 2 and nMiner2Deactivated == 2 and nMiner3Deactivated == 2 then
    AreaSetDoorLocked(TRIGGER._IFUNHOUS_MINEEND, false)
    F_RemoveMissionObjective("4_04_DISABLELAST")
    F_AddMissionObjective("4_04_INSTRUC05A", false)
    F_CompleteMissionObjective("4_04_INSTRUC05A")
    F_AddMissionObjective("4_04_INSTRUC05B")
    TextPrint("4_04_INSTRUC05B", 4, 1)
    F_AddObjectiveBlip("POINT", POINTLIST._4_04_MINE_DEST_09_END, 1, 1)
  end
  if not AreaIsDoorLocked(TRIGGER._IFUNHOUS_MINEEND) then
    x, y, z = GetPointFromPointList(POINTLIST._4_04_MINE_DEST_09_END, 1)
    PlayerIsInAreaXYZ(x, y, z, 4, 0)
    if PlayerIsInTrigger(TRIGGER._4_04_ENDMINE) and PedIsPlaying(gPlayer, "/Global/Door/PedPropsActions", true) then
      PlayerSetControl(0)
      SoundFadeWithCamera(false)
      MusicFadeWithCamera(false)
      CameraFade(500, 0)
      Wait(500)
      gCurrentStage = F_SetupMoveToExit
    end
  end
end
function F_SetupMoveToExit()
  if bDebug then
    bDebug = false
    AreaTransitionPoint(37, POINTLIST._4_04_FINALROOMPLYR, 1, false)
  else
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERB, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX1, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERD, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX2, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX3, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERG, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERH, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERI, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX4, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PlayerSetPosPoint(POINTLIST._4_04_FINALROOMPLYR, 1)
  end
  F_RestoreDefaultCam()
  LoadPAnims({
    TRIGGER._FUNCURTN,
    TRIGGER._FUNCURTN01
  })
  PAnimSetActionNode(TRIGGER._FUNCURTN, "/Global/FunCurtn/Close", "Act/Prop/FunCurtn.act")
  PAnimSetActionNode(TRIGGER._FUNCURTN01, "/Global/FunCurtn/Close", "Act/Prop/FunCurtn.act")
  F_CleanupNerds(true)
  F_SetupNerds(POINTLIST._4_04_FINALROOMNERD1, POINTLIST._4_04_FINALROOMNERD2, false)
  F_RemoveMissionObjective("4_04_INSTRUC00A")
  F_RemoveMissionObjective("4_04_INSTRUC00B")
  F_RemoveMissionObjective("4_04_INSTRUC00")
  F_CompleteMissionObjective("4_04_INSTRUC05B")
  F_RemoveObjectiveBlip()
  AreaSetDoorLocked(TRIGGER._IFUNHOUS_ENDMINE, true)
  PlayerSetControl(1)
  CameraFade(500, 1)
  Wait(500)
  F_AddMissionObjective("4_04_FINDNERDS")
  TextPrint("4_04_FINDNERDS", 4, 1)
  gCurrentStage = F_MoveToExit
end
function F_MoveToExit()
  if not bNerd1Dance and PedCanSeeObject(gPlayer, gNerds[1].id, 2) then
    bNerd1Dance = true
    PedSetActionNode(gNerds[1].id, "/Global/404Conv/Nerds/Dance1", "Act/Conv/4_04.act")
    if bNerd2Dance then
      F_GetOut()
      PedRecruitAlly(gNerds[2].id, gNerds[1].id)
      PedShowHealthBar(gNerds[1].id, true, "4_04_THAD", false, gNerds[2].id, "4_04_FATTY")
    else
      PedRecruitAlly(gPlayer, gNerds[1].id)
      PedShowHealthBar(gNerds[2].id, true, "4_04_THAD", false)
    end
  end
  if not bNerd2Dance and PedCanSeeObject(gPlayer, gNerds[2].id, 2) then
    bNerd2Dance = true
    PedSetActionNode(gNerds[2].id, "/Global/404Conv/Nerds/Dance2", "Act/Conv/4_04.act")
    if bNerd1Dance then
      F_GetOut()
      PedRecruitAlly(gNerds[1].id, gNerds[2].id)
      PedShowHealthBar(gNerds[1].id, true, "4_04_THAD", false, gNerds[2].id, "4_04_FATTY")
    else
      PedRecruitAlly(gPlayer, gNerds[2].id)
      PedShowHealthBar(gNerds[2].id, true, "4_04_FATTY", false)
    end
  end
  if bNerd1Dance and bNerd2Dance and not bCurtainsOpen and PlayerIsInTrigger(TRIGGER._FUNHOUSE_CURTAIN_OPEN) then
    bCurtainsOpen = true
    PAnimSetActionNode(TRIGGER._FUNCURTN01, "/Global/FunCurtn/Open", "Act/Props/FunCurtn.act")
    PAnimSetActionNode(TRIGGER._FUNCURTN, "/Global/FunCurtn/Open", "Act/Props/FunCurtn.act")
  end
  if bNerd1Dance and bNerd2Dance then
    x, y, z = GetPointFromPointList(POINTLIST._4_04_ENDFUNHOUSE, 1)
    PlayerIsInAreaXYZ(x, y, z, 4, 0)
    if PedIsPlaying(gPlayer, "/Global/Door/PedPropsActions", true) and PlayerIsInTrigger(TRIGGER._4_04_EXIT) then
      Wait(1000)
      PlayerSetControl(0)
      SoundFadeWithCamera(false)
      MusicFadeWithCamera(false)
      CameraFade(500, 0)
      Wait(501)
      F_CleanupNerds(true)
      F_SetupNerds(POINTLIST._4_04_NERDSEND1, POINTLIST._4_04_NERDSEND2, false)
      AreaDisableCameraControlForTransition(true)
      AreaTransitionPoint(0, POINTLIST._4_04_PLAYEREND, 1, false)
      PlayerSetControl(0)
      DisablePOI(true, true)
      AreaClearAllPeds()
      CameraSetWidescreen(true)
      SoundDisableSpeech_ActionTree()
      F_MakePlayerSafeForNIS(true)
      gMissionState = "Completed"
    end
  end
end
function F_GetOut()
  F_AddObjectiveBlip("POINT", POINTLIST._4_04_ENDFUNHOUSE, 1, 1)
  F_CompleteMissionObjective("4_04_FINDNERDS")
  F_AddMissionObjective("4_04_INSTRUC05")
  TextPrint("4_04_INSTRUC05", 4, 1)
end
function F_MissionTimerOut()
  if MissionTimerHasFinished() then
    gMissionState = "RanOutOfTime"
  end
end
function F_NerdsStillAlive()
  if PedIsValid(gNerds[1].id) and PedGetHealth(gNerds[1].id) <= 0 then
    gMissionState = "Failed"
  end
  if PedIsValid(gNerds[2].id) and 0 >= PedGetHealth(gNerds[2].id) then
    gMissionState = "Failed"
  end
end
function F_JocksKilled()
  if (not PedIsValid(gTablePeds[1].id) or PedIsDead(gTablePeds[1].id)) and (not PedIsValid(gTablePeds[2].id) or PedIsDead(gTablePeds[2].id)) then
    return true
  end
  return false
end
local gObjectiveBlip
function F_RemoveObjectiveBlip()
  if gObjectiveBlip ~= nil then
    BlipRemove(gObjectiveBlip)
    Wait(100)
    gObjectiveBlip = nil
  end
end
function F_AddObjectiveBlip(blipType, point, index, blipEnum, xObj, yObj, zObj)
  F_RemoveObjectiveBlip()
  if gObjectiveBlip == nil then
    if blipType == "POINT" then
      Wait(100)
      if xObj == nil then
        xObj, yObj, zObj = GetPointFromPointList(point, index)
      end
      gObjectiveBlip = BlipAddXYZ(xObj, yObj, zObj + 0.1, 0, blipEnum)
    elseif blipType == "CHAR" and not PedIsDead(point) then
      Wait(100)
      gObjectiveBlip = AddBlipForChar(point, index, 0, blipEnum)
    end
  end
end
local tObjectiveTable = {}
function F_ObjectiveAlreadyGiven(reference)
  for i, objective in tObjectiveTable, nil, nil do
    if objective.ref == reference then
      return true
    end
  end
  return false
end
function F_ObjectiveAlreadyComplete(reference)
  for i, objective in tObjectiveTable, nil, nil do
    if objective.ref == reference then
      return objective.bComplete
    end
  end
  return false
end
function F_RemoveMissionObjective(reference)
  for i, objective in tObjectiveTable, nil, nil do
    if objective.ref == reference then
      MissionObjectiveRemove(objective.id)
      table.remove(tObjectiveTable, i)
    end
  end
end
function F_CompleteMissionObjective(reference)
  for i, objective in tObjectiveTable, nil, nil do
    if objective.ref == reference then
      MissionObjectiveComplete(objective.id)
      objective.bComplete = true
    end
  end
end
function F_AddMissionObjective(reference)
  if F_ObjectiveAlreadyGiven(reference) then
    for i, objective in tObjectiveTable, nil, nil do
      if objective.ref == reference then
        return objective.id
      end
    end
  end
  local objId = MissionObjectiveAdd(reference)
  table.insert(tObjectiveTable, {
    id = objId,
    ref = reference,
    bComplete = false
  })
  return objId
end
function F_RestoreDefaultCam()
  CameraAllowChange(true)
  CameraReturnToPlayer(true)
  Wait(0)
end
function F_SetupGraveyardCam()
  CameraAllowChange(true)
  CameraLookAtPlayer(true, 0.5)
  CameraSetRelativePath(PATH._GRAVE_RELATIVE_CAM, POINTLIST._GRAVE_RELATIVE, 350, true)
  CameraAllowChange(false)
end
function F_GraveExit()
  CameraAllowChange(true)
  CameraReturnToPlayer()
  CameraAllowChange(false)
end
function F_NerdsTalkToPlayer()
  PlayerSetControl(0)
  SoundFadeWithCamera(false)
  MusicFadeWithCamera(false)
  CameraFade(500, 0)
  Wait(501)
  F_RemoveObjectiveBlip()
  for i, jock in gTablePeds, nil, nil do
    if PedIsValid(jock.id) and (PedIsDead(jock.id) or 0 >= PedGetHealth(jock.id)) then
      PedDelete(jock.id)
    end
  end
  gTablePeds = {}
  PlayerSetPosPoint(POINTLIST._4_04_FIRSTROOMNIS, 3)
  PedSetPosPoint(gNerds[1].id, POINTLIST._4_04_FIRSTROOMNIS, 1)
  PedSetPosPoint(gNerds[2].id, POINTLIST._4_04_FIRSTROOMNIS, 2)
  PedSetStationary(gNerds[1].id, true)
  PedSetStationary(gNerds[2].id, true)
  PedFaceObject(gNerds[1].id, gPlayer, 3, 1, false)
  PedFaceObject(gNerds[2].id, gPlayer, 3, 1, false)
  PedSetActionNode(gPlayer, "/Global/404Conv/Idle", "Act/Conv/4_04.act")
  SoundDisableSpeech_ActionTree()
  CameraSetWidescreen(true)
  F_MakePlayerSafeForNIS(true)
  CameraSetXYZ(-751.4025, -537.356, 8.282816, -750.4518, -537.1463, 8.510356)
  CameraFade(500, 1)
  Wait(501)
  SoundPlayScriptedSpeechEvent(gNerds[1].id, "M_4_04", 69, "large")
  Wait(2500)
  CameraSetFOV(80)
  CameraSetXYZ(-744.9813, -532.78, 8.323483, -745.1747, -533.7269, 8.578918)
  while SoundSpeechPlaying(gNerds[1].id) do
    Wait(0)
  end
  PlayerSetControl(1)
  CameraSetWidescreen(false)
  F_MakePlayerSafeForNIS(false)
  SoundEnableSpeech_ActionTree()
  CameraDefaultFOV()
  CameraReset()
  CameraDefaultFOV()
  CameraReturnToPlayer()
  PedSetStationary(gNerds[1].id, false)
  PedSetStationary(gNerds[2].id, false)
  TextPrint("4_04_INSTRUC01", 4, 1)
  F_CompleteMissionObjective("4_04_INSTRUC00")
  F_AddMissionObjective("4_04_INSTRUC01")
  PedSetTetherToTrigger(gNerds[1].id, TRIGGER._4_04_NERDTRIG)
  PedSetTetherToTrigger(gNerds[2].id, TRIGGER._4_04_NERDTRIG)
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FLBBOOK, "/Global/FunBook/Inactive", "Act/Props/FunBook.act")
end
function F_DropLadder()
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FLBLADER, "/Global/Ladder/AnimatedLadder/NotUsed", "Act/Props/Ladder.act")
end
function F_RaiseLadder()
  PAnimSetActionNode(TRIGGER._IFUNHOUS_FLBLADER, "/Global/Ladder/AnimatedLadder/NotUseable", "Act/Props/Ladder.act")
end
function F_SetupReaper()
  local gCurrentReaper, gCurrentPath, gCurrentPoint
  local bUsedScythe = true
  local bKilledJock = false
  local gReapers = {}
  bDoneSendingJocks = false
  nNerdsCurrentNode = -1
  nJocksCurrentNode = -1
  SoundSetAudioFocusCamera()
  PlayerSetPosPoint(POINTLIST._4_04_DEBUGGRAVE, 1)
  F_RestoreDefaultCam()
  if gCurrentJock == 1 then
    CameraSetFOV(80)
    CameraSetXYZ(-746.4159, -537.977, 26.178759, -752.092, -537.977, 26.178759)
	gCurrentReaper = 1
    gCurrentPath = PATH._4_04_JOCKFULLPATH
    gCurrentPoint = POINTLIST._4_04_RPRPATH1
    gReapers = {
      {
        reaper = TRIGGER._IFUNHOUS_REEPER00,
        trigger = TRIGGER._4_04_REAPER01
      },
      {
        reaper = TRIGGER._IFUNHOUS_REEPER00B,
        trigger = TRIGGER._4_04_REAPER02
      },
      {
        reaper = TRIGGER._IFUNHOUS_REEPER01,
        trigger = TRIGGER._4_04_REAPER03
      },
      {
        reaper = TRIGGER._IFUNHOUS_REEPER01B,
        trigger = TRIGGER._4_04_REAPER04
      },
      {
        reaper = TRIGGER._IFUNHOUS_REEPER02,
        trigger = TRIGGER._4_04_REAPER05
      },
      {
        reaper = TRIGGER._IFUNHOUS_REEPER02B,
        trigger = TRIGGER._4_04_REAPER06
      }
    }
  end
  ToggleHUDComponentVisibility(39, true)
  ToggleHUDComponentVisibility(11, false)
  if nCurrentReaper == 1 then
    F_SetupNerds(POINTLIST._4_04_RPRPATH1, POINTLIST._4_04_RPRPATH1B, false)
    MonitorSetText(0, "4_04_USEPROP")
    MonitorSetText(1, "")
    MonitorSetText(2, "")
    MonitorSetText(3, "")
    LoadPAnims({
      TRIGGER._IFUNHOUS_REEPER00,
      TRIGGER._IFUNHOUS_REEPER00B,
      TRIGGER._IFUNHOUS_REEPER01,
      TRIGGER._IFUNHOUS_REEPER01B,
      TRIGGER._IFUNHOUS_REEPER02,
      TRIGGER._IFUNHOUS_REEPER02B
    })
    MonitorSetGreyed(0, true)
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER00, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER00B, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER01, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER01B, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER02, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_REEPER02B, "/Global/FunReapr/PowerDown", "Act/Props/FunReapr.act")
    AreaClearAllExplosions()
    F_CompleteMissionObjective("4_04_INSTRUC02")
    F_SetupReaperMazeJocks()
    CameraFade(500, 1)
    Wait(501)
    nNerdsCurrentNode = 0
    F_SendNerds()
    while true do
      if nNerdsCurrentNode == 1 then
      else
        Wait(0)
        while SoundSpeechPlaying(gNerds[1].id) do
          Wait(0)
        end
      end
    end
    SoundRemoveAllQueuedSpeech(gNerds[1].id, true)
    F_CleanupNerds(true)
    MonitorSetGreyed(0, false)
    nJocksCurrentNode = 0
    PedSetPosPoint(gTablePeds[gCurrentJock].id, gCurrentPoint, 1)
	do
    local x, y, z = -752.092, -537.977, 26.178759
      local x2, y2, z2 = -746.4159, -537.977, 26.178759
      while true do
        Wait(0)
        if y2 + 540.977 > 0.01 then
          y2 = y2 - 0.07
          y = y - 0.07
          CameraSetXYZ(-746.4159, y2, 26.178759, -752.092, y, 26.178759)
        else
          y2 = -540.977
          y = -540.977
          break
        end
      end
      Wait(10)
      local x, y, z = PedGetOffsetInWorldCoords(gTablePeds[gCurrentJock].id, 0, 2, 1.4)
      local x2, y2, z2 = PedGetOffsetInWorldCoords(gTablePeds[gCurrentJock].id, 5, 2, 1.4)
      CameraSetXYZ(-746.4159, y2, z2, x, y, z)
      PedSetActionNode(gTablePeds[gCurrentJock].id, "/Global/404Conv/Threaten", "Act/Conv/4_04.act")
      PedFollowPath(gTablePeds[gCurrentJock].id, gCurrentPath, 0, 1, CB_JockReaper)
      SoundPlayScriptedSpeechEvent(gTablePeds[gCurrentJock].id, "FIGHT_INITIATE", 0, "supersize", true)
    while true do
      Wait(0)
      if not bUsedScythe and IsButtonPressed(7, 0) and not PAnimIsPlaying(gReapers[gCurrentReaper].reaper, "/Global/FunReapr/Oneshot/Stay", false) and not PAnimIsPlaying(gReapers[gCurrentReaper].reaper, "/Global/FunReapr/Oneshot", false) then
	    bUsedScythe = true
        MonitorSetGreyed(0, true)
        PAnimSetActionNode(gReapers[gCurrentReaper].reaper, "/Global/FunReapr/Oneshot", "Act/Props/FunReapr.act")
	  end
	  if gCurrentReaper == 1 and not PAnimIsPlaying(gReapers[gCurrentReaper].reaper, "/Global/FunReapr/Oneshot/Stay", false) and not PAnimIsPlaying(gReapers[gCurrentReaper].reaper, "/Global/FunReapr/Oneshot", false) and PedIsInTrigger(gTablePeds[gCurrentJock].id, gReapers[gCurrentReaper].trigger) then
        bUsedScythe = false
      end
	  if gCurrentReaper < table.getn(gReapers) then
        if PedIsInTrigger(gTablePeds[gCurrentJock].id, gReapers[gCurrentReaper + 1].trigger) then
          gCurrentReaper = gCurrentReaper + 1
        elseif bUsedScythe or not PedIsInTrigger(gTablePeds[gCurrentJock].id, gReapers[gCurrentReaper].trigger) then
          MonitorSetGreyed(0, false)
          bUsedScythe = true
        end
        if not PAnimIsPlaying(gReapers[gCurrentReaper].reaper, "/Global/FunReapr/Oneshot/Stay", false) and not PAnimIsPlaying(gReapers[gCurrentReaper].reaper, "/Global/FunReapr/Oneshot", false) then
          MonitorSetGreyed(0, false)
          bUsedScythe = false
        end
      end
      if nJocksCurrentNode == PathGetLastNode(gCurrentPath) - 1 then
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        Wait(501)
        PedStop(gTablePeds[gCurrentJock].id)
        PedClearObjectives(gTablePeds[gCurrentJock].id)
        PedSetPosPoint(gTablePeds[gCurrentJock].id, POINTLIST._4_04_JOCKRESTARTPOINTS, gCurrentJock)
        gCurrentJock = gCurrentJock + 1
        gCurrentReaper = 1
        F_SendNextJock(gCurrentPath, POINTLIST._4_04_RPRPATH1)
        if bDoneSendingJocks then
          break
        end
      elseif PedIsValid(gTablePeds[gCurrentJock].id) and not PedIsDead(gTablePeds[gCurrentJock].id) and 0 < PedGetHealth(gTablePeds[gCurrentJock].id) then
        local x, y, z = PedGetOffsetInWorldCoords(gTablePeds[gCurrentJock].id, 0, 2, 1.4)
        local x2, y2, z2 = PedGetOffsetInWorldCoords(gTablePeds[gCurrentJock].id, 5, 2, 1.4)
        CameraSetXYZ(-746.4159, y2, 26.178759, x, y, 26.178759)
      end
      if not PedIsValid(gTablePeds[gCurrentJock].id) or PedIsDead(gTablePeds[gCurrentJock].id) then
        SoundPlayScriptedSpeechEvent(gTablePeds[gCurrentJock].id, "FIGHT_BEATEN", 0, "supersize", true)
        bKilledJock = true
        if gTablePeds[gCurrentJock].model == 20 then
          bJuriDead = true
        elseif gTablePeds[gCurrentJock].model == 15 then
          bDanDead = true
        elseif gTablePeds[gCurrentJock].model == 17 then
          bCaseyDead = true
        end
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        Wait(501)
        for i, jock in gTablePeds, nil, nil do
          if i == gCurrentJock and bKilledJock then
            SoundRemoveAllQueuedSpeech(jock.id, true)
            PedDelete(jock.id)
          end
        end
        if gCurrentJock + 1 <= table.getn(gTablePeds) then
          if gTablePeds[gCurrentJock].id and PedIsValid(gTablePeds[gCurrentJock].id) then
            PedStop(gTablePeds[gCurrentJock].id)
            PedClearObjectives(gTablePeds[gCurrentJock].id)
            PedSetPosPoint(gTablePeds[gCurrentJock].id, POINTLIST._4_04_JOCKRESTARTPOINTS, gCurrentJock)
          end
          gCurrentJock = gCurrentJock + 1
          gCurrentReaper = 1
          F_SendNextJock(gCurrentPath, gCurrentPoint)
        else
          bDoneSendingJocks = true
        end
      end
      if PAnimIsPlaying(TRIGGER._IFUNHOUS_REEPER00, "/Global/FunReapr/Oneshot/Stay", false) and PAnimIsPlaying(TRIGGER._IFUNHOUS_REEPER00B, "/Global/FunReapr/Oneshot/Stay", false) and PAnimIsPlaying(TRIGGER._IFUNHOUS_REEPER01, "/Global/FunReapr/Oneshot/Stay", false) and PAnimIsPlaying(TRIGGER._IFUNHOUS_REEPER01B, "/Global/FunReapr/Oneshot/Stay", false) and PAnimIsPlaying(TRIGGER._IFUNHOUS_REEPER02, "/Global/FunReapr/Oneshot/Stay", false) and PAnimIsPlaying(TRIGGER._IFUNHOUS_REEPER02B, "/Global/FunReapr/Oneshot/Stay", false) then
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        Wait(501)
      end
      else
      end
    end
  if table.getn(gTablePeds) == 0 then
    bAllJocksKilled = true
  end
  collectgarbage()
  PlayerSetPosPoint(POINTLIST._4_04_AFTERREAPER, 1)
  F_RestoreDefaultCam()
  SoundSetAudioFocusPlayer()
end
function F_SendNerds()
  PedFollowPath(gNerds[1].id, PATH._4_04_RPRPATH1B, 0, 2)
  PedFollowPath(gNerds[2].id, PATH._4_04_RPRPATH1, 0, 2, CB_NerdReaper)
  SoundPlayScriptedSpeechEvent(gNerds[1].id, "FIGHT_BEATEN", 0, "supersize", true)
end
function F_SendNextJock(path, point)
  local ped
  SoundSpeechPlaying()
  if gCurrentJock <= table.getn(gTablePeds) then
    ped = gTablePeds[gCurrentJock].id
  else
    bDoneSendingJocks = true
    return
  end
  nJocksCurrentNode = 0
  PedSetPosPoint(ped, point, 1)
  Wait(10)
  local x, y, z = PedGetOffsetInWorldCoords(gTablePeds[gCurrentJock].id, 0, 2, 1.4)
  local x2, y2, z2 = PedGetOffsetInWorldCoords(gTablePeds[gCurrentJock].id, 5, 2, 1.4)
  CameraSetXYZ(-746.4159, y2, z2, x, y, z)
  CameraFade(500, 1)
  Wait(501)
  PedFollowPath(ped, path, 0, 1, CB_JockReaper)
  SoundPlayScriptedSpeechEvent(ped, "FIGHT_INITIATE", 0, "supersize", true)
end
function CB_NerdReaper(pedId, pathId, nodeId)
  nNerdsCurrentNode = nodeId
end
function CB_JockReaper(pedId, pathId, nodeId)
  nJocksCurrentNode = nodeId
end
function F_CleanupNerds(bDeleteNerds)
  if table.getn(gNerds) > 0 then
    if PedIsValid(gNerds[1].id) then
      PedSetMissionCritical(gNerds[1].id, false, nil, false)
    end
    if PedIsValid(gNerds[2].id) then
      PedSetMissionCritical(gNerds[2].id, false, nil, false)
    end
    if PedIsValid(gNerds[1].id) then
      gNerds[1].health = PedGetHealth(gNerds[1].id)
      PedDismissAlly(gPlayer, gNerds[1].id)
      if bDeleteNerds then
        PedDelete(gNerds[1].id)
      end
    end
    if PedIsValid(gNerds[2].id) then
      gNerds[2].health = PedGetHealth(gNerds[2].id)
      PedDismissAlly(gPlayer, gNerds[2].id)
      if bDeleteNerds then
        PedDelete(gNerds[2].id)
      end
    end
  end
  gNerds = {}
end
function CB_NerdThadDied()
  bThadDied = true
end
function CB_NerdFattyDied()
  bFattyDied = true
end
function F_SetupNerds(pointlist1, pointlist2, bToggleHealth)
  gNerds[1] = {
    id = PedCreatePoint(8, pointlist1, 1),
    path = nil,
    bReachedPathEnd = false
  }
  gNerds[2] = {
    id = PedCreatePoint(5, pointlist2, 1),
    path = nil,
    bReachedPathEnd = false
  }
  PedClearAllWeapons(gNerds[1].id)
  PedClearAllWeapons(gNerds[2].id)
  if gNerds[1].health then
    PedSetHealth(gNerds[1].id, gNerds[1].health)
  else
    PedSetHealth(gNerds[1].id, PedGetHealth(gNerds[1].id) * 2.5)
  end
  if gNerds[2].health then
    PedSetHealth(gNerds[2].id, gNerds[2].health)
  else
    PedSetHealth(gNerds[2].id, PedGetHealth(gNerds[2].id) * 2.5)
  end
  PedSetMissionCritical(gNerds[1].id, true, CB_NerdThadDied)
  PedSetMissionCritical(gNerds[2].id, true, CB_NerdFattyDied)
  PedSetDamageTakenMultiplier(gNerds[1].id, 1, 0.5)
  PedSetDamageTakenMultiplier(gNerds[1].id, 0, 0.5)
  PedSetDamageTakenMultiplier(gNerds[1].id, 2, 0.5)
  PedSetDamageTakenMultiplier(gNerds[1].id, 3, 0.5)
  PedSetDamageTakenMultiplier(gNerds[2].id, 1, 0.5)
  PedSetDamageTakenMultiplier(gNerds[2].id, 0, 0.5)
  PedSetDamageTakenMultiplier(gNerds[2].id, 2, 0.5)
  PedSetDamageTakenMultiplier(gNerds[2].id, 3, 0.5)
  if bToggleHealth then
    PedShowHealthBar(gNerds[1].id, true, "4_04_THAD", false, gNerds[2].id, "4_04_FATTY")
  end
end
function F_ButtonWasActivated()
  if nMazeState == -1 then
    nMazeState = 1
  elseif nMazeState == -2 then
    nMazeState = 2
  end
end
function F_SetupReaperMazeJocks()
  for i, ped in gTablePeds, nil, nil do
    if PedIsValid(ped.id) then
      PedDelete(ped.id)
    end
  end
  gTablePeds = {}
  table.insert(gTablePeds, {
    id = PedCreatePoint(20, POINTLIST._4_04_JOCKRESTARTPOINTS, 1),
    model = 20
  })
  table.insert(gTablePeds, {
    id = PedCreatePoint(15, POINTLIST._4_04_JOCKRESTARTPOINTS, 2),
    model = 15
  })
  table.insert(gTablePeds, {
    id = PedCreatePoint(17, POINTLIST._4_04_JOCKRESTARTPOINTS, 3),
    model = 17
  })
end
function F_SetupJocksInTheMaze()
  if nJocksLeft == 0 then
    bJock1Fight = true
    bJock2Fight = true
    bJock3Fight = true
    return
  elseif nJocksLeft == 1 then
    table.insert(gTablePeds, {
      id = PedCreatePoint(F_GetAvailableJock(), POINTLIST._4_04_MAZEJOCKS, 2)
    })
    PedSetPedToTypeAttitude(gTablePeds[1].id, 13, 0)
    GameSetPedStat(gTablePeds[1].id, 0, 362)
    GameSetPedStat(gTablePeds[1].id, 1, 100)
    PedFollowPath(gTablePeds[1].id, PATH._4_04_MAZPATHJK1, 2, 0, CB_JockSearchingMaze1)
    bJock2Fight = true
    bJock3Fight = true
  elseif nJocksLeft == 2 then
    table.insert(gTablePeds, {
      id = PedCreatePoint(F_GetAvailableJock(), POINTLIST._4_04_MAZEJOCKS, 2)
    })
    table.insert(gTablePeds, {
      id = PedCreatePoint(F_GetAvailableJock(), POINTLIST._4_04_MAZEJOCKS, 1)
    })
    PedSetPedToTypeAttitude(gTablePeds[1].id, 13, 0)
    PedSetPedToTypeAttitude(gTablePeds[2].id, 13, 0)
    GameSetPedStat(gTablePeds[1].id, 0, 362)
    GameSetPedStat(gTablePeds[1].id, 1, 100)
    GameSetPedStat(gTablePeds[2].id, 0, 362)
    GameSetPedStat(gTablePeds[2].id, 1, 100)
    PedFollowPath(gTablePeds[1].id, PATH._4_04_MAZPATHJK1, 2, 0, CB_JockSearchingMaze1)
    PedFollowPath(gTablePeds[2].id, PATH._4_04_MAZPATHJK2, 2, 0, CB_JockSearchingMaze2)
    bJock3Fight = true
  elseif nJocksLeft == 3 then
    table.insert(gTablePeds, {
      id = PedCreatePoint(F_GetAvailableJock(), POINTLIST._4_04_MAZEJOCKS, 2)
    })
    table.insert(gTablePeds, {
      id = PedCreatePoint(F_GetAvailableJock(), POINTLIST._4_04_MAZEJOCKS, 1)
    })
    table.insert(gTablePeds, {
      id = PedCreatePoint(F_GetAvailableJock(), POINTLIST._4_04_MAZEJOCKS, 3)
    })
    PedSetPedToTypeAttitude(gTablePeds[1].id, 13, 0)
    PedSetPedToTypeAttitude(gTablePeds[2].id, 13, 0)
    PedSetPedToTypeAttitude(gTablePeds[3].id, 13, 0)
    GameSetPedStat(gTablePeds[1].id, 0, 362)
    GameSetPedStat(gTablePeds[1].id, 1, 100)
    GameSetPedStat(gTablePeds[2].id, 0, 362)
    GameSetPedStat(gTablePeds[2].id, 1, 100)
    GameSetPedStat(gTablePeds[3].id, 0, 362)
    GameSetPedStat(gTablePeds[3].id, 1, 100)
    PedFollowPath(gTablePeds[1].id, PATH._4_04_MAZPATHJK1, 2, 0, CB_JockSearchingMaze1)
    PedFollowPath(gTablePeds[2].id, PATH._4_04_MAZPATHJK2, 2, 0, CB_JockSearchingMaze2)
    PedFollowPath(gTablePeds[3].id, PATH._4_04_MAZPATHJK3, 2, 0, CB_JockSearchingMaze3)
  end
end
function CB_JockSearchingMaze1(pedId, pathId, nodeId)
  PedSetActionNode(gTablePeds[1].id, "/Global/404Conv/MazeLookAround", "Act/Conv/4_04.act")
end
function CB_JockSearchingMaze2(pedId, pathId, nodeId)
  PedSetActionNode(gTablePeds[2].id, "/Global/404Conv/MazeLookAround", "Act/Conv/4_04.act")
end
function CB_JockSearchingMaze3(pedId, pathId, nodeId)
  PedSetActionNode(gTablePeds[3].id, "/Global/404Conv/MazeLookAround", "Act/Conv/4_04.act")
end
function F_GetAvailableJock()
  if not bJuriDead then
    bJuriDead = true
    return 20
  elseif not bDanDead then
    bDanDead = true
    return 15
  elseif not bCaseyDead then
    bCaseyDead = true
    return 17
  end
end
function F_CleanMazeJocks()
  if table.getn(gTablePeds) > 2 and gTablePeds[3].id and PedIsValid(gTablePeds[3].id) then
    PedDelete(gTablePeds[3].id)
    gTablePeds[3].id = nil
  end
  if table.getn(gTablePeds) > 1 and gTablePeds[2].id and PedIsValid(gTablePeds[2].id) then
    PedDelete(gTablePeds[2].id)
    gTablePeds[2].id = nil
  end
  if table.getn(gTablePeds) > 0 and gTablePeds[1].id and PedIsValid(gTablePeds[1].id) then
    PedDelete(gTablePeds[1].id)
    gTablePeds[1].id = nil
  end
  gTablePeds = {}
end
function F_SetupMiningJocks()
  table.insert(gTablePeds, {
    id = PedCreatePoint(16, POINTLIST._4_04_MINEJOCKS, 1)
  })
  table.insert(gTablePeds, {
    id = PedCreatePoint(18, POINTLIST._4_04_MINEJOCKS, 2)
  })
  table.insert(gTablePeds, {
    id = PedCreatePoint(13, POINTLIST._4_04_MINEJOCKS, 3)
  })
  PedSetActionNode(gTablePeds[1].id, "/Global/404Conv/UseMonitor", "Act/Conv/4_04.act")
  PedSetActionNode(gTablePeds[2].id, "/Global/404Conv/UseMonitor", "Act/Conv/4_04.act")
  PedSetActionNode(gTablePeds[3].id, "/Global/404Conv/UseMonitor", "Act/Conv/4_04.act")
  GameSetPedStat(gTablePeds[1].id, 0, 362)
  GameSetPedStat(gTablePeds[1].id, 1, 100)
  GameSetPedStat(gTablePeds[2].id, 0, 362)
  GameSetPedStat(gTablePeds[2].id, 1, 100)
  GameSetPedStat(gTablePeds[3].id, 0, 362)
  GameSetPedStat(gTablePeds[3].id, 1, 100)
end
function F_SwitchMonitor01()
  if nMiner1Deactivated == 0 then
    nMiner1Deactivated = 1
  end
end
function F_SwitchMonitor02()
  if nMiner2Deactivated == 0 then
    nMiner2Deactivated = 1
  end
end
function F_SwitchMonitor03()
  if nMiner3Deactivated == 0 then
    nMiner3Deactivated = 1
  end
end
function F_DoSwitchNIS(nSetup)
  local nPedSpeech = math.random(1, 100)
  if nPedSpeech > 50 then
    nPedSpeech = 1
  else
    nPedSpeech = 2
  end
  if not bDoneNIS then
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    SoundSetAudioFocusCamera()
    for i, ped in gTablePeds, nil, nil do
      if ped.id and PedIsValid(ped.id) then
        PedSetAsleep(ped.id, true)
      end
    end
    CameraSetWidescreen(true)
    SoundDisableSpeech_ActionTree()
    if nSetup == 1 then
      PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERB, "/Global/FunMiner/HoldOpen", "Act/Props/FunMiner.act")
      PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX1, "/Global/FunMiner/HoldOpen", "Act/Props/FunMiner.act")
      PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERD, "/Global/FunMiner/HoldOpen", "Act/Props/FunMiner.act")
      CameraSetFOV(80)
      CameraSetXYZ(-757.7275, -445, 15.919205, -758.56744, -444.46576, 16.013308)
    elseif nSetup == 2 then
      PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX2, "/Global/FunMiner/HoldOpen", "Act/Props/FunMiner.act")
      PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX3, "/Global/FunMiner/HoldOpen", "Act/Props/FunMiner.act")
      PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERG, "/Global/FunMiner/HoldOpen", "Act/Props/FunMiner.act")
      CameraSetXYZ(-742.13306, -428.61383, 13.310422, -743.02075, -428.15454, 13.340721)
    elseif nSetup == 3 then
      PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERH, "/Global/FunMiner/HoldOpen", "Act/Props/FunMiner.act")
      PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERI, "/Global/FunMiner/HoldOpen", "Act/Props/FunMiner.act")
      PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX4, "/Global/FunMiner/HoldOpen", "Act/Props/FunMiner.act")
      CameraSetFOV(80)
      CameraSetXYZ(-742.4181, -394.3436, 16.10469, -742.1123, -395.10538, 15.533704)
    end
    Wait(500)
    PlayerSetControl(1)
    PedSetStationary(gPlayer, true)
    CameraFade(500, 1)
    Wait(1001)
  end
  if nSetup == 1 then
    BlipRemove(gMineBlips[1].blip)
    gMineBlips[1].bDisabled = true
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERB, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX1, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERD, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    Wait(1500)
    if PedIsInTrigger(gNerds[1].id, TRIGGER._4_04_MINENERDS1) then
      PedFollowPath(gNerds[1].id, PATH._4_04_MINEPATHR1, 0, 1)
      gNerds[1].path = PATH._4_04_MINEPATHR1
    end
    if PedIsInTrigger(gNerds[2].id, TRIGGER._4_04_MINENERDS1) then
      PedFollowPath(gNerds[2].id, PATH._4_04_MINEPATHL1, 0, 1)
      gNerds[2].path = PATH._4_04_MINEPATHR1
    end
    SoundPlayScriptedSpeechEvent(gNerds[2].id, "THANK_YOU", 0, "large", false)
  elseif nSetup == 2 then
    BlipRemove(gMineBlips[2].blip)
    gMineBlips[2].bDisabled = true
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX2, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX3, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERG, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    Wait(1500)
    if nMiner1Deactivated == 2 then
      if PedIsInTrigger(gNerds[1].id, TRIGGER._4_04_MINENERDS2) then
        PedFollowPath(gNerds[1].id, PATH._4_04_MINEPATHR2, 0, 1)
        gNerds[1].path = PATH._4_04_MINEPATHR2
      end
      if PedIsInTrigger(gNerds[2].id, TRIGGER._4_04_MINENERDS2) then
        PedFollowPath(gNerds[2].id, PATH._4_04_MINEPATHL2, 0, 1)
        gNerds[2].path = PATH._4_04_MINEPATHR2
      end
      SoundPlayScriptedSpeechEvent(gNerds[2].id, "THANK_YOU", 0, "large", false)
    end
  elseif nSetup == 3 then
    BlipRemove(gMineBlips[3].blip)
    gMineBlips[3].bDisabled = true
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERH, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERI, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    PAnimSetActionNode(TRIGGER._IFUNHOUS_FUNMINERX4, "/Global/FunMiner/ShutOff", "Act/Props/FunMiner.act")
    Wait(1500)
    if nMiner1Deactivated == 2 and nMiner2Deactivated == 2 then
      if PedIsInTrigger(gNerds[1].id, TRIGGER._4_04_MINENERDS3) then
        PedFollowPath(gNerds[1].id, PATH._4_04_MINEPATHR3, 0, 1)
        gNerds[1].path = PATH._4_04_MINEPATHR3
      end
      if PedIsInTrigger(gNerds[2].id, TRIGGER._4_04_MINENERDS3) then
        PedFollowPath(gNerds[2].id, PATH._4_04_MINEPATHL3, 0, 1)
        gNerds[2].path = PATH._4_04_MINEPATHR3
      end
      SoundPlayScriptedSpeechEvent(gNerds[nPedSpeech].id, "THANK_YOU", 0, "large", false)
    end
  end
  if not bDoneNIS then
    Wait(3000)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    CameraSetWidescreen(false)
    SoundEnableSpeech_ActionTree()
    CameraReset()
    CameraReturnToPlayer(true)
    if nMiner1Deactivated == 2 and nMiner2Deactivated == 2 and nMiner3Deactivated == 2 then
      F_CleanupNerds(true)
    end
    SoundSetAudioFocusPlayer()
    for i, ped in gTablePeds, nil, nil do
      if ped.id and PedIsValid(ped.id) then
        PedSetAsleep(ped.id, false)
      end
    end
    PedSetStationary(gPlayer, false)
    PlayerSetControl(1)
    CameraFade(500, 1)
    Wait(501)
    local numMiners = 0
    if nMiner1Deactivated == 2 then
      numMiners = numMiners + 1
    end
    if nMiner2Deactivated == 2 then
      numMiners = numMiners + 1
    end
    if nMiner3Deactivated == 2 then
      numMiners = numMiners + 1
    end
    if numMiners == 2 then
      F_RemoveMissionObjective("4_04_DISABLEREST")
      F_AddMissionObjective("4_04_DISABLELAST", false)
      TextPrint("4_04_DISABLELAST", 4, 1)
    elseif numMiners == 1 then
      F_RemoveMissionObjective("4_04_INSTRUC05A")
      F_AddMissionObjective("4_04_DISABLEREST", false)
      TextPrint("4_04_DISABLEREST", 4, 1)
    end
  end
  F_MakePlayerSafeForNIS(false)
end
function T_WitchMonitor()
  local i, Entry, x, y, z
  local curTime = GetTimer()
  local tblWitchSteam = {
    {
      point = POINTLIST._WITCH_STEAM_01,
      effect = nil,
      nextTime = 0
    },
    {
      point = POINTLIST._WITCH_STEAM_02,
      effect = nil,
      nextTime = 0
    }
  }
  x, y, z = GetPointList(tblWitchSteam[1].point)
  tblWitchSteam[1].effect = EffectCreate("steam_Shower", x, y, z)
  SoundPlay3D(x, y, z, "WitchCauldren")
  EffectSetDirection(tblWitchSteam[1].effect, -4, 0, 0)
  tblWitchSteam[1].nextTime = GetTimer() + math.random(5000, 8000)
  x, y, z = GetPointList(tblWitchSteam[2].point)
  tblWitchSteam[2].effect = EffectCreate("steam_Shower", x, y, z)
  SoundPlay3D(x, y, z, "WitchCauldren")
  EffectSetDirection(tblWitchSteam[2].effect, -4, 0, 0)
  tblWitchSteam[2].nextTime = GetTimer() + math.random(5000, 8000)
  while true do
    if bStopWitches then
      break
    end
    Wait(0)
  end
  EffectKill(tblWitchSteam[1].effect)
  EffectKill(tblWitchSteam[2].effect)
  collectgarbage()
end
function F_ControlRoom()
  gCurrentStage = F_ProcessMonitor
end
function F_InReaper()
  if not bGetToMines then
    return 1
  end
  return 0
end
function F_InMines()
  if bGetToMines then
    return 1
  end
  return 0
end
