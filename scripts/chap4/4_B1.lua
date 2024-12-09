local bDebugFlag = false
local gDebugLevel = 3
local bombLocation = {}
local gun_points = {}
local bFollowCam = true
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bS1M1Destroyed = false
local bS1M2Destroyed = false
local bS2M1Destroyed = false
local bS2M2Destroyed = false
local bS3M1Destroyed = false
local bS3M2Destroyed = false
local bMonitorPlayersHealth = false
local gPlayersPreviousWeapon = 0
function MissionSetup()
  MissionDontFadeIn()
  DATLoad("4_B1.DAT", 2)
  DATInit()
  AreaTransitionPoint(40, POINTLIST._4_B1_PLAYER_STAGE01, 1, true)
  PlayCutsceneWithLoad("4-B1", true, true)
  PedSaveWeaponInventorySnapshot(gPlayer)
end
function MissionCleanup()
  PlayerSetControl(1)
  CameraSetWidescreen(false)
  F_MakePlayerSafeForNIS(false)
  SoundEnableSpeech_ActionTree()
  CameraAllowChange(true)
  FollowCamDefaultFightShot()
  CameraReset()
  CameraReturnToPlayer()
  DisablePunishmentSystem(false)
  PedSetFlag(gPlayer, 58, false)
  F_CleanPlatforms()
  UnLoadAnimationGroup("Earnest")
  DATUnload(2)
  SoundStopInteractiveStream()
end
function main()
  F_SetupMission()
  if bDebugFlag then
    if gDebugLevel == 2 then
      F_StartAtStage2()
    elseif gDebugLevel == 3 then
      F_StartAtStage3()
    end
  else
    F_Stage1()
  end
  if bMissionFailed then
    ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateSprayCan")
    PedRestoreWeaponInventorySnapshot(gPlayer)
    SoundPlayMissionEndMusic(false, 4)
    MissionFail()
  elseif bMissionPassed then
    F_MakePlayerSafeForNIS(true)
    SoundDisableSpeech_ActionTree()
    ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateBRockets")
    ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateBRockets")
    AreaTransitionPoint(0, POINTLIST._4_B1_PLAYER_END, 1, true)
    GiveWeaponToPlayer(305, false)
    GiveAmmoToPlayer(305, 10, false)
    PlayerSetWeapon(305, 10, false)
    CameraSetXYZ(43.568047, -133.70268, 3.926415, 44.52883, -133.90245, 4.118478)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    CameraFade(500, 1)
    Wait(500)
    SetFactionRespect(1, 50)
    MinigameSetCompletion("M_PASS", true, 0, "4_B1_UNLOCK")
    MinigameAddCompletionMsg("MRESPECT_NP50", 2)
    SoundPlayMissionEndMusic(true, 4)
    while MinigameIsShowingCompletion() do
      Wait(0)
    end
    UnlockYearbookPicture(10)
    F_UnlockYearbookReward()
    MissionSucceed(true, false, false)
  end
end
function F_TableInit()
  pedEarnest = {
    spawn = POINTLIST._4_B1_EARNEST_STAGE01,
    element = 1,
    model = 10
  }
  pedCamera = {
    spawn = POINTLIST._4_B1_CAMERA01,
    element = 1,
    model = 136
  }
end
function F_SetupMission()
  F_TableInit()
  DisablePunishmentSystem(true)
  LoadAnimationGroup("Earnest")
  WeaponRequestModel(301)
  WeaponRequestModel(305)
  if PlayerGetHealth() < 200 then
    PlayerSetHealth(200)
  end
  PedSetFlag(gPlayer, 58, true)
  PAnimResetAllDamageable()
  SoundPlayInteractiveStream("MS_NerdBossBattle.rsm", MUSIC_DEFAULT_VOLUME)
  PlayerSetControl(0)
  GeometryInstance("NorthPla_BROKEN", true, -696.467, 83.7462, 24.3831, false)
  GeometryInstance("WestPla_BROKEN", true, -705.123, 74.9948, 24.3831, false)
  GeometryInstance("SouthPla_BROKEN", true, -696.154, 66.8366, 24.4715, false)
  ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateHEALTH")
  LoadActionTree("Act/Conv/4_B1.act")
end
function F_Stage1()
  F_Stage1_Setup()
  F_Stage1_Loop()
end
function F_Stage1_Setup()
  PAnimCreate(TRIGGER._PLAT_NORTH)
  PAnimSetPropFlag(TRIGGER._PLAT_NORTH, 2, true)
  PAnimCreate(TRIGGER._PLAT_SOUTH)
  PAnimSetPropFlag(TRIGGER._PLAT_SOUTH, 2, true)
  PAnimCreate(TRIGGER._PLAT_WEST)
  PAnimSetPropFlag(TRIGGER._PLAT_WEST, 2, true)
  PAnimCreate(TRIGGER._TURRET_TOP)
  PAnimSetPropFlag(TRIGGER._TURRET_TOP, 2, true)
  PAnimSetPropFlag("OBSMotor", -706.995, 79.206, 29.291, 2, true)
  PAnimSetPropFlag("OBSMotor", -706.986, 71.6268, 29.291, 2, true)
  PAnimSetPropFlag("OBSMotor", -692.507, 64.7766, 29.291, 2, true)
  PAnimSetPropFlag("OBSMotor", -700.087, 64.7677, 29.291, 2, true)
  PAnimMakeTargetable("OBSMotor", -706.995, 79.206, 29.291, false)
  PAnimMakeTargetable("OBSMotor", -706.986, 71.6268, 29.291, false)
  PAnimMakeTargetable("OBSMotor", -692.507, 64.7766, 29.291, false)
  PAnimMakeTargetable("OBSMotor", -700.087, 64.7677, 29.291, false)
  PAnimMakeTargetable("OBSMotor", -700.137, 86.2676, 29.2188, true)
  PAnimMakeTargetable("OBSMotor", -692.547, 86.2075, 29.2906, true)
  pedEarnest.id = PedCreatePoint(pedEarnest.model, pedEarnest.spawn, pedEarnest.element)
  PedSetActionTree(pedEarnest.id, "/Global/N_Earnest", "Act/Anim/N_Earnest.act")
  PedMakeTargetable(pedEarnest.id, false)
  PedSetInvulnerable(pedEarnest.id, true)
  PedSetInvulnerableToPlayer(pedEarnest.id, true)
  PedIgnoreStimuli(pedEarnest.id, true)
  pedCamera.id = PedCreatePoint(pedCamera.model, pedCamera.spawn, pedCamera.element)
  PedSetEffectedByGravity(pedCamera.id, false)
  PedSetStationary(pedCamera.id, true)
  PedSetAsleep(pedCamera.id, true)
  PedSetInvulnerable(pedCamera.id, true)
  PedSetPosPoint(pedCamera.id, pedCamera.spawn)
  F_SkupaCam()
  CameraSetWidescreen(true)
  PlayerSetControl(0)
  PedSetInvulnerable(gPlayer, true)
  CameraSetXYZ(-699.88855, 78.72663, 26.249279, -699.1361, 79.36582, 26.406363)
  CameraFade(500, 1)
  Wait(500)
  SoundPlayScriptedSpeechEvent(pedEarnest.id, "M_4_B1", 3, "jumbo", true)
  PedFollowPath(pedEarnest.id, PATH._4_B1_TURRETPATH, 0, 0)
  Wait(1600)
  while not PedIsPlaying(pedEarnest.id, "/Global/Ambient/MissionSpec/GetOnCannon", true) do
    PedSetActionNode(pedEarnest.id, "/Global/Ambient/MissionSpec/GetOnCannon", "Act/Anim/Ambient.act")
    Wait(0)
  end
  PedLockTarget(pedEarnest.id, gPlayer, 3)
  Wait(1500)
  CameraSetWidescreen(false)
  PlayerSetControl(1)
  PedSetInvulnerable(gPlayer, false)
  F_SkupaCam()
  blipMotor01 = BlipAddPoint(POINTLIST._4_B1_BLIPS1M1, 26, 1, 2, 0)
  blipMotor02 = BlipAddPoint(POINTLIST._4_B1_BLIPS1M2, 26, 1, 2, 0)
  Wait(2000)
  PedSetTaskNode(pedEarnest.id, "/Global/AI/GeneralObjectives/SpecificObjectives/UseSpudCannon", "Act/AI/AI.act")
  PedSetFlag(pedEarnest.id, 13, false)
  bMonitorPlayersHealth = true
  CreateThread("T_MonitorPlayerHealth")
  gObjective01 = MissionObjectiveAdd("4_B1_MOBJ_01")
  MissionObjectiveReminderTime(-1)
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
  F_Stage2_Setup()
  F_Stage2_Loop()
end
function F_Stage2_Setup()
  bMonitorPlayersHealth = false
  gPlayersPreviousWeapon = PedGetWeapon(gPlayer)
  PedSetTaskNode(pedEarnest.id, "/Global/AI", "Act/AI/AI.act")
  PedClearObjectives(pedEarnest.id)
  PlayerSetControl(0)
  CameraFade(250, 0)
  Wait(250)
  PAnimDelete(TRIGGER._TURRET_TOP)
  indexNorthB, simpleObjectNorthB = CreatePersistentEntity("NorthPla_BROKEN", -696.467, 83.7462, 24.3831, 0, 40)
  GeometryInstance("NorthPla_BROKEN", false, -696.467, 83.7462, 24.3831, true)
  GeometryInstance("WestPla_BROKEN", true, -705.123, 74.9948, 24.3831, false)
  GeometryInstance("SouthPla_BROKEN", true, -696.154, 66.8366, 24.4715, false)
  GeometryInstance("0iobserv01", true, -698.234, 78.8167, 27.3749, false)
  GeometryInstance("0iobserv06", true, -699.879, 75.488, 27.2307, false)
  GeometryInstance("0iobserv07", true, -694.439, 72.8225, 26.7451, false)
  GeometryInstance("0iobserv11", true, -698.386, 72.323, 25.6534, false)
  GeometryInstance("0iobserv13", true, -692.915, 78.3231, 28.2027, false)
  PAnimSetPropFlag("OBSMotor", -692.507, 64.7766, 29.291, 2, true)
  PAnimSetPropFlag("OBSMotor", -700.087, 64.7677, 29.291, 2, true)
  PAnimMakeTargetable("OBSMotor", -692.507, 64.7766, 29.291, false)
  PAnimMakeTargetable("OBSMotor", -700.087, 64.7677, 29.291, false)
  PAnimSetPropFlag("OBSMotor", -700.137, 86.2676, 29.2188, 2, true)
  PAnimSetPropFlag("OBSMotor", -692.547, 86.2075, 29.2906, 2, true)
  PAnimMakeTargetable("OBSMotor", -700.137, 86.2676, 29.2188, false)
  PAnimMakeTargetable("OBSMotor", -692.547, 86.2075, 29.2906, false)
  PAnimSetPropFlag("OBSMotor", -706.995, 79.206, 29.291, 2, false)
  PAnimSetPropFlag("OBSMotor", -706.986, 71.6268, 29.291, 2, false)
  PAnimMakeTargetable("OBSMotor", -706.995, 79.206, 29.291, true)
  PAnimMakeTargetable("OBSMotor", -706.986, 71.6268, 29.291, true)
  PedSetPosPoint(gPlayer, POINTLIST._4_B1_PLAYER_STAGE02, 1)
  PedSetPosPoint(pedEarnest.id, POINTLIST._4_B1_EARNEST_STAGE02)
  PedSetPosPoint(pedCamera.id, POINTLIST._4_B1_CAMERA02)
  F_SkupaCam()
  while not WeaponRequestModel(417) do
    Wait(0)
  end
  PedSetFlag(pedEarnest.id, 2, true)
  PedSetFlag(pedEarnest.id, 1, false)
  PedSetWeaponNow(gPlayer, gPlayersPreviousWeapon, PedGetAmmoCount(gPlayer, gPlayersPreviousWeapon))
  PedSetTetherToTrigger(pedEarnest.id, TRIGGER._4_B1_EARNEST_PATTERN02)
  CameraSetWidescreen(false)
  CameraFade(250, 1)
  Wait(250)
  PlayerSetControl(1)
  bMonitorPlayersHealth = true
  CreateThread("T_MonitorPlayerHealth")
  CreateThread("T_EarnestStage2")
  blipMotor03 = BlipAddPoint(POINTLIST._4_B1_BLIPS2M1, 26, 1, 2, 0)
  blipMotor04 = BlipAddPoint(POINTLIST._4_B1_BLIPS2M2, 26, 1, 2, 0)
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
  F_Stage3_Setup()
  F_Stage3_Loop()
end
function F_Stage3_Setup()
  bMonitorPlayersHealth = false
  gPlayersPreviousWeapon = PedGetWeapon(gPlayer)
  PlayerSetControl(0)
  CameraFade(250, 0)
  Wait(250)
  indexWestB, simpleObjectWestB = CreatePersistentEntity("WestPla_BROKEN", -705.123, 74.9948, 24.3831, 0, 40)
  GeometryInstance("WestPla_BROKEN", false, -705.123, 74.9948, 24.3831, true)
  GeometryInstance("SouthPla_BROKEN", true, -696.154, 66.8366, 24.4715, false)
  PAnimSetPropFlag("OBSMotor", -700.137, 86.2676, 29.2188, 2, true)
  PAnimSetPropFlag("OBSMotor", -692.547, 86.2075, 29.2906, 2, true)
  PAnimMakeTargetable("OBSMotor", -700.137, 86.2676, 29.2188, false)
  PAnimMakeTargetable("OBSMotor", -692.547, 86.2075, 29.2906, false)
  PAnimSetPropFlag("OBSMotor", -706.995, 79.206, 29.291, 2, true)
  PAnimSetPropFlag("OBSMotor", -706.986, 71.6268, 29.291, 2, true)
  PAnimMakeTargetable("OBSMotor", -706.995, 79.206, 29.291, false)
  PAnimMakeTargetable("OBSMotor", -706.986, 71.6268, 29.291, false)
  PAnimSetPropFlag("OBSMotor", -692.507, 64.7766, 29.291, 2, false)
  PAnimSetPropFlag("OBSMotor", -700.087, 64.7677, 29.291, 2, false)
  PAnimMakeTargetable("OBSMotor", -692.507, 64.7766, 29.291, true)
  PAnimMakeTargetable("OBSMotor", -700.087, 64.7677, 29.291, true)
  PedSetPosPoint(gPlayer, POINTLIST._4_B1_PLAYER_STAGE03, 1)
  PedSetPosPoint(pedEarnest.id, POINTLIST._4_B1_STAGE03_GUN02)
  PedSetPosPoint(pedCamera.id, POINTLIST._4_B1_CAMERA03)
  F_SkupaCam()
  table.insert(gun_points, POINTLIST._4_B1_STAGE03_GUN01)
  table.insert(gun_points, POINTLIST._4_B1_STAGE03_GUN02)
  table.insert(gun_points)
  PedSetWeaponNow(pedEarnest.id, 305, 100)
  PedSetWeaponNow(gPlayer, gPlayersPreviousWeapon, PedGetAmmoCount(gPlayer, gPlayersPreviousWeapon))
  CameraSetWidescreen(false)
  CameraFade(250, 1)
  Wait(250)
  PlayerSetControl(1)
  bMonitorPlayersHealth = true
  CreateThread("T_MonitorPlayerHealth")
  CreateThread("T_EarnestStage3")
  blipMotor05 = BlipAddPoint(POINTLIST._4_B1_BLIPS3M1, 26, 1, 2, 0)
  blipMotor06 = BlipAddPoint(POINTLIST._4_B1_BLIPS3M2, 26, 1, 2, 0)
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
  if not bS1M1Destroyed and PAnimIsDestroyed("OBSMotor", -700.137, 86.2676, 29.2188) then
    PAnimBreakLight("JanMotorLight02", -698.497, 86.012, 29.031)
    BlipRemove(blipMotor01)
    SoundPlay2D("MotorDamge03")
    bS1M1Destroyed = true
  end
  if not bS1M2Destroyed and PAnimIsDestroyed("OBSMotor", -692.547, 86.2075, 29.2906) then
    PAnimBreakLight("JanMotorLight02", -694.166, 86.012, 29.031)
    BlipRemove(blipMotor02)
    SoundPlay2D("MotorDamge03")
    bS1M2Destroyed = true
  end
  if bS1M1Destroyed and bS1M2Destroyed then
    F_NIS_01()
    bGoToStage2 = true
  end
end
function Stage2_Objectives()
  if not bS2M1Destroyed and PAnimIsDestroyed("OBSMotor", -706.995, 79.206, 29.291) then
    PAnimBreakLight("JanMotorLight02", -706.751, 77.592, 29.031)
    BlipRemove(blipMotor04)
    SoundPlay2D("MotorDamge03")
    bS2M1Destroyed = true
  end
  if not bS2M2Destroyed and PAnimIsDestroyed("OBSMotor", -706.986, 71.6268, 29.291) then
    PAnimBreakLight("JanMotorLight02", -706.751, 73.261, 29.031)
    BlipRemove(blipMotor03)
    SoundPlay2D("MotorDamge03")
    bS2M2Destroyed = true
  end
  if bS2M1Destroyed and bS2M2Destroyed then
    F_NIS_02()
    bGoToStage3 = true
  end
end
function Stage3_Objectives()
  if not bS3M1Destroyed and PAnimIsDestroyed("OBSMotor", -692.507, 64.7766, 29.291) then
    PAnimBreakLight("JanMotorLight02", -694.123, 64.948, 29.031)
    BlipRemove(blipMotor05)
    SoundPlay2D("MotorDamge03")
    bS3M1Destroyed = true
  end
  if not bS3M2Destroyed and PAnimIsDestroyed("OBSMotor", -700.087, 64.7677, 29.291) then
    PAnimBreakLight("JanMotorLight02", -698.455, 64.948, 29.031)
    BlipRemove(blipMotor06)
    SoundPlay2D("MotorDamge03")
    bS3M2Destroyed = true
  end
  if bS3M1Destroyed and bS3M2Destroyed then
    CameraFade(500, 0)
    Wait(500)
    CameraAllowChange(true)
    CameraReturnToPlayer()
    CameraReset()
    PlayerSetControl(0)
    AreaClearAllExplosions()
    AreaClearAllProjectiles()
    GeometryInstance("SouthPla_BROKEN", false, -696.154, 66.8366, 24.4715, true)
    PAnimDelete(TRIGGER._PLAT_SOUTH)
    indexSouthB, simpleObjectSouthB = CreatePersistentEntity("SouthPla_BROKEN", -696.178, 66.762, 24.4715, 0, 40)
    UnLoadAnimationGroup("Earnest")
    PlayCutsceneWithLoad("4-B1D", true, false)
    bMissionPassed = true
  end
end
function F_StartAtStage2()
  pedEarnest.id = PedCreatePoint(pedEarnest.model, pedEarnest.spawn, pedEarnest.element)
  PedSetActionTree(pedEarnest.id, "/Global/N_Earnest", "Act/Anim/N_Earnest.act")
  PedMakeTargetable(pedEarnest.id, false)
  PedSetInvulnerable(pedEarnest.id, true)
  PedSetInvulnerableToPlayer(pedEarnest.id, true)
  PedIgnoreStimuli(pedEarnest.id, true)
  pedCamera.id = PedCreatePoint(pedCamera.model, pedCamera.spawn, pedCamera.element)
  PedSetEffectedByGravity(pedCamera.id, false)
  PedSetStationary(pedCamera.id, true)
  PedSetAsleep(pedCamera.id, true)
  PedSetInvulnerable(pedCamera.id, true)
  PedSetPosPoint(pedCamera.id, pedCamera.spawn)
  F_Stage2()
end
function F_StartAtStage3()
  pedEarnest.id = PedCreatePoint(pedEarnest.model, pedEarnest.spawn, pedEarnest.element)
  PedSetActionTree(pedEarnest.id, "/Global/N_Earnest", "Act/Anim/N_Earnest.act")
  PedMakeTargetable(pedEarnest.id, false)
  PedSetInvulnerable(pedEarnest.id, true)
  PedSetInvulnerableToPlayer(pedEarnest.id, true)
  PedIgnoreStimuli(pedEarnest.id, true)
  pedCamera.id = PedCreatePoint(pedCamera.model, pedCamera.spawn, pedCamera.element)
  PedSetEffectedByGravity(pedCamera.id, false)
  PedSetStationary(pedCamera.id, true)
  PedSetAsleep(pedCamera.id, true)
  PedSetInvulnerable(pedCamera.id, true)
  PedSetPosPoint(pedCamera.id, pedCamera.spawn)
  PAnimCreate(TRIGGER._PLAT_SOUTH)
  PAnimSetPropFlag(TRIGGER._PLAT_SOUTH, 2, true)
  indexNorthB, simpleObjectNorthB = CreatePersistentEntity("NorthPla_BROKEN", -696.467, 83.7462, 24.3831, 0, 40)
  PAnimSetPropFlag("OBSMotor", -700.137, 86.2676, 29.2188, 2, false)
  PAnimSetPropFlag("OBSMotor", -692.547, 86.2075, 29.2906, 2, false)
  PAnimMakeTargetable("OBSMotor", -700.137, 86.2676, 29.2188, true)
  PAnimMakeTargetable("OBSMotor", -692.547, 86.2075, 29.2906, true)
  PAnimSetPropFlag("OBSMotor", -706.995, 79.206, 29.291, 2, false)
  PAnimSetPropFlag("OBSMotor", -706.986, 71.6268, 29.291, 2, false)
  PAnimMakeTargetable("OBSMotor", -706.995, 79.206, 29.291, true)
  PAnimMakeTargetable("OBSMotor", -706.986, 71.6268, 29.291, true)
  F_Stage3()
end
function BombRandomizeLocations()
  local noBomb = math.random(1, 9)
  bombLocation = {}
  if noBomb ~= 1 then
    table.insert(bombLocation, POINTLIST._4_B1_STAGE02_BOMB01)
  end
  if noBomb ~= 2 then
    table.insert(bombLocation, POINTLIST._4_B1_STAGE02_BOMB02)
  end
  if noBomb ~= 3 then
    table.insert(bombLocation, POINTLIST._4_B1_STAGE02_BOMB03)
  end
  if noBomb ~= 4 then
    table.insert(bombLocation, POINTLIST._4_B1_STAGE02_BOMB04)
  end
  if noBomb ~= 5 then
    table.insert(bombLocation, POINTLIST._4_B1_STAGE02_BOMB05)
  end
  if noBomb ~= 6 then
    table.insert(bombLocation, POINTLIST._4_B1_STAGE02_BOMB06)
  end
  if noBomb ~= 7 then
    table.insert(bombLocation, POINTLIST._4_B1_STAGE02_BOMB07)
  end
  if noBomb ~= 8 then
    table.insert(bombLocation, POINTLIST._4_B1_STAGE02_BOMB08)
  end
  if noBomb ~= 9 then
    table.insert(bombLocation, POINTLIST._4_B1_STAGE02_BOMB09)
  end
end
function BombSetLocation01()
  local x, y, z = GetPointList(bombLocation[1])
  PedSetProjDest(pedEarnest.id, x, y, z)
end
function BombSetLocation02()
  local x, y, z = GetPointList(bombLocation[2])
  PedSetProjDest(pedEarnest.id, x, y, z)
end
function BombSetLocation03()
  local x, y, z = GetPointList(bombLocation[3])
  PedSetProjDest(pedEarnest.id, x, y, z)
end
function BombSetLocation04()
  local x, y, z = GetPointList(bombLocation[4])
  PedSetProjDest(pedEarnest.id, x, y, z)
end
function BombSetLocation05()
  local x, y, z = GetPointList(bombLocation[5])
  PedSetProjDest(pedEarnest.id, x, y, z)
end
function BombSetLocation06()
  local x, y, z = GetPointList(bombLocation[6])
  PedSetProjDest(pedEarnest.id, x, y, z)
end
function BombSetLocation07()
  local x, y, z = GetPointList(bombLocation[7])
  PedSetProjDest(pedEarnest.id, x, y, z)
end
function BombSetLocation08()
  local x, y, z = GetPointList(bombLocation[8])
  PedSetProjDest(pedEarnest.id, x, y, z)
end
function Stage01Speech()
  SoundPlayScriptedSpeechEvent(pedEarnest.id, "M_4_B1", 1, "jumbo", true)
end
function Stage02Speech()
  SoundPlayScriptedSpeechEvent(pedEarnest.id, "M_4_B1", 2, "jumbo", true)
end
function Stage03Speech()
  SoundPlayScriptedSpeechEvent(pedEarnest.id, "M_4_B1", 3, "jumbo", true)
end
function F_CleanPlatforms()
  if indexNorthB ~= nil then
    DeletePersistentEntity(indexNorthB, simpleObjectNorthB)
  end
  if indexWestB ~= nil then
    DeletePersistentEntity(indexWestB, simpleObjectWestB)
  end
  if indexSouthB ~= nil then
    DeletePersistentEntity(indexSouthB, simpleObjectSouthB)
  end
end
function F_SkupaCam()
  if bFollowCam then
    CameraSetSecondTarget(pedCamera.id)
    FollowCamSetFightShot("4B1")
    CameraSetShot(1, "4B1", true)
  else
    CameraSetSecondTarget(pedCamera.id)
    FollowCamSetFightShot("4B1")
    CameraSetShot(9, "4B1", true)
    CameraAllowChange(true)
  end
end
function F_NIS_01()
  CameraSetWidescreen(true)
  PlayerSetControl(0)
  CameraSetXYZ(-702.5636, 73.67932, 24.113953, -702.0189, 74.47134, 24.387157)
  CameraAllowChange(false)
  AreaClearAllExplosions()
  AreaClearAllProjectiles()
  PedSetActionNode(pedEarnest.id, "/Global/4_B1/Empty", "Act/Conv/4_B1.act")
  PedStop(pedEarnest.id)
  PedClearObjectives(pedEarnest.id)
  PedFollowPath(pedEarnest.id, PATH._4_B1_NIS_01, 0, 1)
  PAnimSetActionNode(TRIGGER._TURRET_TOP, "/Global/4_B1/Cannon/Fall", "Act/Conv/4_B1.act")
  PAnimSetActionNode(TRIGGER._PLAT_NORTH, "/Global/4_B1/Platform/RumbleNorth", "Act/Conv/4_B1.act")
  SoundLoopPlay2D("Balcony Rumble", true)
  Wait(2500)
  SoundLoopPlay2D("Balcony Rumble", false)
  PAnimSetActionNode(TRIGGER._PLAT_NORTH, "/Global/4_B1/Platform/CollapseNorth", "Act/Conv/4_B1.act")
  SoundPlay2D("BalconeyFall01")
  Wait(1500)
  CameraAllowChange(true)
end
function F_NIS_02()
  CameraSetWidescreen(true)
  PlayerSetControl(0)
  CameraSetXYZ(-696.9778, 80.348434, 23.647238, -697.8573, 80.00399, 23.975384)
  CameraAllowChange(false)
  AreaClearAllExplosions()
  AreaClearAllProjectiles()
  PedSetActionNode(pedEarnest.id, "/Global/4_B1/Empty", "Act/Conv/4_B1.act")
  PedSetFlag(pedEarnest.id, 2, false)
  PedClearTether(pedEarnest.id)
  PedStop(pedEarnest.id)
  PedClearObjectives(pedEarnest.id)
  PedFollowPath(pedEarnest.id, PATH._4_B1_NIS_02, 0, 1)
  PAnimSetActionNode(TRIGGER._PLAT_WEST, "/Global/4_B1/Platform/RumbleWest", "Act/Conv/4_B1.act")
  SoundLoopPlay2D("Balcony Rumble", true)
  Wait(2500)
  SoundLoopPlay2D("Balcony Rumble", false)
  PAnimSetActionNode(TRIGGER._PLAT_WEST, "/Global/4_B1/Platform/CollapseWest", "Act/Conv/4_B1.act")
  SoundPlay2D("BalconeyFall02")
  Wait(1000)
  CameraAllowChange(true)
end
local bEarnestStage2Timer = false
local gEarnestStage2Timer = 0
function T_EarnestStage2()
  while MissionActive() and (not bS2M1Destroyed or not bS2M2Destroyed) do
    if not bEarnestStage2Timer then
      PedSetWeaponNow(pedEarnest.id, 417, 8)
      PedSetActionNode(pedEarnest.id, "/Global/N_Earnest/Offense/ThrowBombs", "Act/Anim/N_Earnest.act")
      Wait(2000)
      PedSetFlag(pedEarnest.id, 2, true)
      PedSetFlag(pedEarnest.id, 1, false)
      bEarnestStage2Timer = true
      gEarnestStage2Timer = GetTimer() + 6000
    elseif bEarnestStage2Timer and GetTimer() >= gEarnestStage2Timer then
      bEarnestStage2Timer = false
    end
    Wait(0)
  end
  collectgarbage()
end
local bEarnestStage3Timer = false
local gEarnestStage3Timer = 0
function T_EarnestStage3()
  while MissionActive() and (not bS3M1Destroyed or not bS3M2Destroyed) do
    if not bEarnestStage3Timer then
	  local index = math.random(1, 3)
      PedSetActionNode(pedEarnest.id, "/Global/4_B1/Empty", "Act/Conv/4_B1.act")
      PedMoveToPoint(pedEarnest.id, 2, gun_points[index], 1, nil, 2)
      Wait(2000)
      PedFaceObject(pedEarnest.id, gPlayer, 3, 0)
      Wait(2000)
      PedSetWeaponNow(pedEarnest.id, 305, 20)
      PedSetActionNode(pedEarnest.id, "/Global/N_Earnest/Offense/FireSpudGun", "Act/Anim/N_Earnest.act")
      gEarnestStage3Timer = GetTimer() + 3000
      bEarnestStage3Timer = true
    elseif bEarnestStage3Timer and GetTimer() >= gEarnestStage3Timer then
      bEarnestStage3Timer = false
    end
    Wait(0)
  end
  collectgarbage()
end
function T_MonitorPlayerHealth()
  while MissionActive() and bMonitorPlayersHealth do
    if F_PlayerIsDead() then
      bMissionFailed = true
      break
    end
    Wait(0)
  end
  collectgarbage()
end
