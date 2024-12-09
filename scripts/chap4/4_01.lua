local bDebugFlag = false
local gDebugLevel = 3
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bIsPlayerInsideGym = false
local bPicMandyGym = false
local bPicMandyShower = false
local bPicMandyBedroom = false
local bMandyShowering = false
local bShowerEffectLoaded = false
local bEarnestLeave = false
local bMandyIsInShower = false
local bMandyRoomDialogue = false
local bPlayerHitMandyInsideGym = false
local bChristySpeech = false
local bBustPlayer = false
local bPedEjected = false
local bLaunchedEunice = false
local bEuniceStealthSpeech = false
local bMonitorCheerleaders = false
local bPlayerEnteredDorm = false
local bClosingDialogue = false
local bShowerWarn = false
local bMandyRoomWarn = false
local bSkipFirstCutscene = false
local bTutLattice = false
local latticeX, latticeY, latticeZ = 0, 0, 0
local gMissionFailMessage = 0
local photohasbeentaken = false
local wasValid = false
local validGymTarget = false
local validShowerTarget = false
local validBedroomTarget = false
function MissionSetup()
  SoundPlayInteractiveStream("MS_FootStealthLow.rsm", MUSIC_DEFAULT_VOLUME)
  SoundSetMidIntensityStream("MS_FootStealthMid.rsm", MUSIC_DEFAULT_VOLUME)
  SoundSetHighIntensityStream("MS_FootStealthHigh.rsm", 0.7)
  PlayCutsceneWithLoad("4-01", true)
  MissionDontFadeIn()
  DATLoad("4_01.DAT", 2)
  DATInit()
end
function MissionCleanup()
  F_KillShowerSteam()
  F_HideCounter()
  PlayerSetControl(1)
  CameraSetWidescreen(false)
  F_MakePlayerSafeForNIS(false)
  SoundEnableSpeech_ActionTree()
  if F_PedExists(pedEarnest.id) then
    PedSetFlag(pedEarnest.id, 113, false)
    PedSetInvulnerable(pedEarnest.id, false)
    PedIgnoreStimuli(pedEarnest.id, false)
    PedSetStationary(pedEarnest.id, false)
    BlipRemoveFromChar(pedEarnest.id)
  end
  AreaSetDoorLocked("GDORM_UPPERDOOR", false)
  PedSetUniqueModelStatus(14, PedGetUniqueModelStatus(14))
  PedSetUniqueModelStatus(74, PedGetUniqueModelStatus(74))
  PedHideHealthBar()
  AreaRevertToDefaultPopulation()
  UnLoadAnimationGroup("F_Girls")
  UnLoadAnimationGroup("ChLead_Idle")
  UnLoadAnimationGroup("SHWR")
  UnLoadAnimationGroup("UBO")
  DATUnload(2)
  DATInit()
  ItemSetCurrentNum(526, 0)
  SoundStopInteractiveStream()
end
function main()
  F_SetupMission()
  if bDebugFlag then
    if gDebugLevel == 2 then
      F_StartAtStage2()
    elseif gDebugLevel == 3 then
      F_StartAtStage3()
    else
      F_Stage1()
    end
  else
    F_Stage1()
  end
  MissionDontFadeInAfterCompetion()
  if bMissionFailed then
    TextPrint("4_01_EMPTY", 1, 1)
    SoundPlayMissionEndMusic(false, 4)
    if gMissionFailMessage == 1 then
      MissionFail(false, true, "4_01_FAIL_01")
    elseif gMissionFailMessage == 2 then
      if bGoToStage2 then
        PlayerSetControl(0)
      end
      MissionFail(false, true, "4_01_FAIL_02")
    elseif gMissionFailMessage == 3 then
      MissionFail(false, true, "4_01_FAIL_03")
    else
      MissionFail(false)
    end
  elseif bMissionPassed then
    SetFactionRespect(2, GetFactionRespect(2) - 10)
    SetFactionRespect(1, GetFactionRespect(1) + 5)
    MinigameSetCompletion("M_PASS", true, 2500)
    MinigameAddCompletionMsg("MRESPECT_NP5", 2)
    MinigameAddCompletionMsg("MRESPECT_JM10", 1)
    SoundPlayMissionEndMusic(true, 4)
    while MinigameIsShowingCompletion() do
      Wait(0)
    end
    CameraFade(500, 0)
    Wait(501)
    CameraReset()
    CameraReturnToPlayer()
    MissionSucceed(false, false, false)
    Wait(500)
    CameraFade(500, 1)
    Wait(101)
    PlayerSetControl(1)
  end
end
function F_TableInit()
  pedMandyGym = {
    spawn = POINTLIST._4_01_SPAWNMANDYGYM,
    element = 1,
    model = 14
  }
  pedChristyGym = {
    spawn = POINTLIST._4_01_SPAWNCHRISTYGYM,
    element = 1,
    model = 181
  }
  pedAngieGym = {
    spawn = POINTLIST._4_01_SPAWNANGIEGYM,
    element = 1,
    model = 180
  }
  pedPinkyGym = {
    spawn = POINTLIST._4_01_SPAWNPINKYGYM,
    element = 1,
    model = 182
  }
  pedMandyShower = {
    spawn = POINTLIST._4_01_SPAWNMANDYSHOWER,
    element = 1,
    model = 230
  }
  pedMandyBedroom = {
    spawn = POINTLIST._4_01_SPAWNMANDYBEDROOM,
    element = 1,
    model = 93
  }
  pedChristyDorm = {
    spawn = POINTLIST._4_01_SPAWNCHRISTYDORM,
    element = 1,
    model = 67
  }
  pedEunice = {
    spawn = POINTLIST._4_01_SPAWNEUNICE,
    element = 1,
    model = 74
  }
  pedKaren = {
    spawn = POINTLIST._4_01_SPAWNKAREN,
    element = 1,
    model = 137
  }
  pedEarnest = {
    spawn = POINTLIST._4_01_SPAWNEARNEST,
    element = 1,
    model = 10
  }
end
function F_SetupMission()
  WeaponRequestModel(341)
  PedRequestModel(14)
  PedRequestModel(181)
  PedRequestModel(180)
  PedRequestModel(182)
  PedRequestModel(230)
  PedRequestModel(93)
  PedRequestModel(67)
  PedRequestModel(74)
  PedRequestModel(137)
  PedRequestModel(10)
  LoadAnimationGroup("F_Girls")
  LoadAnimationGroup("ChLead_Idle")
  LoadAnimationGroup("SHWR")
  LoadAnimationGroup("UBO")
  LoadAnimationGroup("POI_ChLead")
  F_TableInit()
  PedSetUniqueModelStatus(14, -1)
  LoadActionTree("Act/Conv/4_01.act")
end
function F_Stage1()
  F_Stage1_Setup()
  F_Stage1_Loop()
end
function F_Stage1_Setup()
  if IsMissionFromDebug() then
    AreaTransitionPoint(0, POINTLIST._4_01_SPAWNPLAYER)
  else
    PlayerSetPosPoint(POINTLIST._4_01_SPAWNPLAYER)
  end
  if bDebugFlag then
    AreaTransitionPoint(13, POINTLIST._4_01_DEBUGSPAWNPLAYERSTAGE1)
  end
  CameraReset()
  CameraReturnToPlayer()
  F_SetupGym()
  F_SetupCounter()
  CameraFade(500, 1)
  Wait(500)
  TextPrint("4_01_MOBJ_01", 4, 1)
  gObjective01 = MissionObjectiveAdd("4_01_MOBJ_01")
  PedSocialOverrideLoad(4, "Mission/4_01Follow.act")
  PlayerSocialOverrideLoad(32, "Mission/4_01PlayerGift.act")
  latticeX, latticeY, latticeZ = GetPointList(POINTLIST._4_01_BLIPLATTICE)
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
  PedSetUniqueModelStatus(74, -1)
  pedMandyShower.id = PedCreatePoint(pedMandyShower.model, pedMandyShower.spawn, pedMandyShower.element)
  PlayerSocialDisableActionAgainstPed(pedMandyShower.id, 28, true)
  PlayerSocialDisableActionAgainstPed(pedMandyShower.id, 29, true)
  PlayerSocialDisableActionAgainstPed(pedMandyShower.id, 35, true)
  PlayerSocialDisableActionAgainstPed(pedMandyShower.id, 23, true)
  pedMandyBedroom.id = PedCreatePoint(pedMandyBedroom.model, pedMandyBedroom.spawn, pedMandyBedroom.element)
  PlayerSocialDisableActionAgainstPed(pedMandyBedroom.id, 28, true)
  PlayerSocialDisableActionAgainstPed(pedMandyBedroom.id, 29, true)
  PlayerSocialDisableActionAgainstPed(pedMandyBedroom.id, 35, true)
  PlayerSocialDisableActionAgainstPed(pedMandyBedroom.id, 23, true)
  pickupCream = PickupCreatePoint(347, POINTLIST._4_01_BEDCREAM, 1, 0, "PermanentMission")
  pedChristyDorm.id = PedCreatePoint(pedChristyDorm.model, pedChristyDorm.spawn, pedChristyDorm.element)
  PedFollowPath(pedChristyDorm.id, PATH._4_01_CHRISTYLAUNDRY, 1, 0)
  pedKaren.id = PedCreatePoint(pedKaren.model, pedKaren.spawn, pedKaren.element)
  pedEunice.id = PedCreatePoint(pedEunice.model, pedEunice.spawn, pedEunice.element)
  bMandyIsInShower = true
  AreaSetDoorLocked("GDORM_UPPERDOOR", true)
  bBustPlayer = true
  MissionObjectiveComplete(gObjective01)
  gObjective01b = MissionObjectiveAdd("4_01_MOBJ_01B")
  TextPrint("4_01_MOBJ_01B", 3, 1)
  blipGdormAttic = BlipAddPoint(POINTLIST._4_01_BLIPGDORMATTIC, 0, 1, 1, 0)
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
  CameraReturnToPlayer()
  CameraReset()
  MissionObjectiveComplete(gObjective01)
  TextPrint("4_01_MOBJ_02", 4, 1)
  gObjective02 = MissionObjectiveAdd("4_01_MOBJ_02")
  F_HideCounter()
  GiveItemToPlayer(526)
  pedEarnest.id = PedCreatePoint(pedEarnest.model, pedEarnest.spawn, pedEarnest.element)
  pedEarnest.blip = AddBlipForChar(pedEarnest.id, 6, 0, 4)
  PlayerSocialDisableActionAgainstPed(pedEarnest.id, 35, true)
  PlayerSocialDisableActionAgainstPed(pedEarnest.id, 29, true)
  PlayerSocialDisableActionAgainstPed(pedEarnest.id, 28, true)
  PedSetFlag(pedEarnest.id, 113, true)
  PedIgnoreStimuli(pedEarnest.id, true)
  PedSetStationary(pedEarnest.id, true)
  PedSetRequiredGift(pedEarnest.id, 16, false, true)
  PedUseSocialOverride(pedEarnest.id, 4)
  PedSetMissionCritical(pedEarnest.id, true, F_MissionCriticalEarnest, true)
  PlayerSocialEnableOverrideAgainstPed(pedEarnest.id, 32, true)
  PedOverrideStat(pedEarnest.id, 3, 0)
  PedSetStationary(pedEarnest.id, true)
  bBustPlayer = false
  bGoToStage3 = true
  SoundStopInteractiveStream()
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
local L38 = false -- Couldn't recover original name
function Stage1_Objectives()
  if not bIsPlayerInsideGym and (PlayerIsInTrigger(TRIGGER._4_01_GYMINSIDEDOOR) or PlayerIsInTrigger(TRIGGER._4_01_GYMTUNNEL)) then
    F_StartCheerRoutine()
    bIsPlayerInsideGym = true
  end
  if not bPicMandyGym then
    validGymTarget = false
    if PhotoTargetInFrame(pedMandyGym.id, 2) then
      validGymTarget = true
    end
    bValidNowOrBefore = validGymTarget or L38
    L38 = validGymTarget
    PhotoSetValid(validGymTarget)
    photohasbeentaken, wasValid = PhotoHasBeenTaken()
    if photohasbeentaken and wasValid and bValidNowOrBefore then
      CounterSetCurrent(1)
      F_CutPhotoGym()
      bMonitorCheerleaders = false
      bPicMandyGym = true
      L38 = false
      bGoToStage2 = true
    end
  end
  if F_HasMandyBeenHit() or bPlayerHitMandyInsideGym then
    F_StopCheerRoutine()
    SoundPlayScriptedSpeechEventWrapper(pedMandyGym.id, "M_4_01", 7, "large")
    BlipRemoveFromChar(pedMandyGym.id)
    PedMakeAmbient(pedMandyGym.id)
    PedMakeAmbient(pedAngieGym.id)
    PedMakeAmbient(pedPinkyGym.id)
    PedMakeAmbient(pedChristyGym.id)
    gMissionFailMessage = 2
    bMissionFailed = true
    bPlayerHitMandyInsideGym = false
  end
end
function Stage2_Objectives()
  if not bTutLattice then
    PedIsInAreaXYZ(gPlayer, latticeX, latticeY, latticeZ, 1, 7)
    if PlayerIsInTrigger(TRIGGER._4_01_TUTLATTICE) and PedIsPlaying(gPlayer, "/Global/Trellis/Trellis_Actions/Climb_ON_BOT", true) then
      bTutLattice = true
    end
  end
  if not bPlayerEnteredDorm and AreaGetVisible() == 35 then
    MissionObjectiveComplete(gObjective01b)
    MissionObjectiveRemove(gObjective01)
    gObjective01 = MissionObjectiveAdd("4_01_MOBJ_01")
    TextPrint("4_01_MOBJ_01", 4, 1)
    BlipRemove(blipGdormAttic)
    pedMandyShower.blip = AddBlipForChar(pedMandyShower.id, 2, 0, 4)
    bPlayerEnteredDorm = true
  end
  if bMandyIsInShower then
    if not bMandyShowering then
      if PlayerIsInTrigger(TRIGGER._4_01_GIRLSDORMBATHROOM) then
        F_MandyStartWashing()
        F_CreateShowerSteam()
        bMandyShowering = true
      end
    elseif not PlayerIsInTrigger(TRIGGER._4_01_GIRLSDORMBATHROOM) then
      F_MandyStopWashing()
      F_KillShowerSteam()
      bMandyShowering = false
    end
    if not bShowerWarn and PlayerIsInTrigger(TRIGGER._4_01_SHOWERWARN) then
      TextPrint("4_01_WARN_01", 4, 1)
      bShowerWarn = true
    end
    if PlayerIsInTrigger(TRIGGER._4_01_SHOWERROOM) then
      F_MandySawPlayerFromShower()
    end
    if PedIsHit(pedMandyShower.id, 2, 500) and PedGetWhoHitMeLast(pedMandyShower.id) == gPlayer then
      F_MandySawPlayerFromShower()
    end
  end
  if not bPicMandyBedroom then
    if not bMandyRoomWarn and PlayerIsInTrigger(TRIGGER._4_01_MANDYROOMWARN) then
      TextPrint("4_01_WARN_01", 4, 1)
      bMandyRoomWarn = true
    end
    if PlayerIsInTrigger(TRIGGER._4_01_MANDYROOMBUSTED) then
      F_MandySawPlayerFromBedroom()
    end
    if PedIsHit(pedMandyBedroom.id, 2, 500) and PedGetWhoHitMeLast(pedMandyBedroom.id) == gPlayer then
      F_MandySawPlayerFromBedroom()
    end
    if not bMandyRoomDialogue and PlayerIsInTrigger(TRIGGER._4_01_MANDYROOM) then
      SoundPlayScriptedSpeechEventWrapper(pedMandyBedroom.id, "M_4_01", 90, "large")
      bMandyRoomDialogue = true
    end
  end
  if not bPicMandyShower then
    validShowerTarget = false
    if PhotoTargetInFrame(pedMandyShower.id, 2) then
      validShowerTarget = true
    end
    bValidNowOrBefore = validShowerTarget or L38
    L38 = validShowerTarget
    PhotoSetValid(validShowerTarget)
    photohasbeentaken, wasValid = PhotoHasBeenTaken()
    if photohasbeentaken and wasValid and bValidNowOrBefore then
      CounterSetCurrent(2)
      F_CutPhotoShower()
      F_LaunchEuniceUpstairs()
      MissionObjectiveComplete(gObjective01)
      gObjective01c = MissionObjectiveAdd("4_01_MOBJ_01C")
      TextPrint("4_01_MOBJ_01C", 3, 1)
      bMandyIsInShower = false
      L38 = false
      bPicMandyShower = true
    end
  end
  if bPicMandyShower and not bPicMandyBedroom then
    validBedroomTarget = false
    if PhotoTargetInFrame(pedMandyBedroom.id, 2) then
      validBedroomTarget = true
    end
    bValidNowOrBefore = validBedroomTarget or L38
    L38 = validBedroomTarget
    PhotoSetValid(validBedroomTarget)
    photohasbeentaken, wasValid = PhotoHasBeenTaken()
    if photohasbeentaken and wasValid and bValidNowOrBefore then
      if not bMandyRoomDialogue then
        SoundPlayScriptedSpeechEventWrapper(pedMandyBedroom.id, "M_4_01", 90, "large")
        bMandyRoomDialogue = true
      end
      MissionObjectiveComplete(gObjective01c)
      CounterSetCurrent(3)
      BlipRemove(pedMandyBedroom.blip)
      PedSetActionNode(pedMandyBedroom.id, "/Global/4_01/Anims/Empty", "Act/Conv/4_01.act")
      PedMakeAmbient(pedMandyBedroom.id)
      PedWander(pedMandyBedroom.id, 0)
      PAnimDoorStayOpen(TRIGGER._GDORM_UPPERDOORSTORAGE)
      bPicMandyBedroom = true
      bGoToStage3 = true
    end
  end
  if not bChristySpeech and PlayerIsInTrigger(TRIGGER._4_01_CHRISTYSPEECH) then
    PedSetActionNode(pedKaren.id, "/Global/WProps/PropInteract", "Act/WProps.act")
    CreateThread("T_SpeechChristyDorm")
    bChristySpeech = true
  end
  if not bLaunchedEunice and PlayerIsInTrigger(TRIGGER._4_01_LAUNCHEUNICE) then
    PedFollowPath(pedEunice.id, PATH._4_01_EUNICEDOWNSTAIRS, 0, 0, cbEuniceDownstairs)
    bLaunchedEunice = true
  end
  if bBustPlayer and AreaGetVisible() == 35 and PedIsValid(shared.gdormHeadID) and (PedCanSeeObject(shared.gdormHeadID, gPlayer, 3) or PedIsHit(shared.gdormHeadID, 2, 500)) then
    F_PlayerSpotted(shared.gdormHeadID)
    F_CutBootedOut()
    F_EjectPlayerFromDorm()
  end
  if not bDormFlaggedForReset and AreaGetVisible() ~= 35 then
    CreateThread("T_ResetGirlsDorm")
    bDormFlaggedForReset = true
  end
end
function Stage3_Objectives()
  if not bChristySpeech and PlayerIsInTrigger(TRIGGER._4_01_CHRISTYSPEECH) then
    CreateThread("T_SpeechChristyDorm")
    bChristySpeech = true
  end
  if bGoToStage3 and PlayerIsInAreaObject(pedEarnest.id, 2, 3, 0) then
    PedSetInvulnerable(pedEarnest.id, true)
    PlayerSetInvulnerable(true)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    SoundDisableSpeech_ActionTree()
    F_PlayerDismountBike()
    PedSetFlag(pedEarnest.id, 113, false)
    PedSetInvulnerable(pedEarnest.id, false)
    PedIgnoreStimuli(pedEarnest.id, false)
    PedSetStationary(pedEarnest.id, false)
    PedStop(pedEarnest.id)
    PedSetStationary(pedEarnest.id, false)
    PedFaceObject(pedEarnest.id, gPlayer, 3, 1)
    PedFaceObject(gPlayer, pedEarnest.id, 2, 1)
    PedLockTarget(gPlayer, pedEarnest.id, 3)
    PedClearObjectives(pedEarnest.id)
    PedSetActionNode(gPlayer, "/Global/4_01/Anims/GIVE/GiveEarnest_4_01", "Act/Conv/4_01.act")
    while PedIsPlaying(gPlayer, "/Global/4_01/Anims/GIVE/GiveEarnest_4_01", true) do
      Wait(0)
    end
    Wait(2000)
    PedSetStationary(pedEarnest.id, false)
    PlayerSocialDisableActionAgainstPed(pedEarnest.id, 35, false)
    PlayerSocialDisableActionAgainstPed(pedEarnest.id, 29, false)
    PlayerSocialDisableActionAgainstPed(pedEarnest.id, 28, false)
    PedSetRequiredGift(pedEarnest.id, 0, false, true)
    PedMoveToPoint(pedEarnest.id, 0, POINTLIST._4_01_EARNESTLEAVE, 1)
    PedLockTarget(gPlayer, -1, 1)
    PedMakeAmbient(pedEarnest.id)
    bMissionPassed = true
    bEarnestLeave = false
  end
end
function F_StartAtStage2()
  AreaTransitionPoint(35, POINTLIST._4_01_DEBUGSPAWNPLAYERSTAGE2)
  gObjective01 = MissionObjectiveAdd("4_01_MOBJ_01")
  PedSocialOverrideLoad(4, "Mission/4_01Follow.act")
  PlayerSocialOverrideLoad(32, "Mission/4_01PlayerGift.act")
  F_SetupCounter()
  CounterSetCurrent(1)
  CameraFade(500, 1)
  Wait(500)
  F_Stage2()
end
function F_StartAtStage3()
  AreaTransitionPoint(0, POINTLIST._4_01_DEBUGSPAWNPLAYERSTAGE3)
  gObjective01 = MissionObjectiveAdd("4_01_MOBJ_01")
  MissionObjectiveComplete(gObjective01)
  gObjective02 = MissionObjectiveAdd("4_01_MOBJ_02")
  PedSocialOverrideLoad(4, "Mission/4_01Follow.act")
  PlayerSocialOverrideLoad(32, "Mission/4_01PlayerGift.act")
  CameraFade(500, 1)
  Wait(500)
  F_Stage3()
end
function F_SetupCounter()
  CounterSetCurrent(0)
  CounterSetMax(3)
  CounterMakeHUDVisible(true, true)
  CounterSetIcon("HUDIcon_photos", "HUDIcon_photos_x")
end
function F_HideCounter()
  CounterMakeHUDVisible(false)
end
function F_SetupGym()
  pedMandyGym.id = PedCreatePoint(pedMandyGym.model, pedMandyGym.spawn, pedMandyGym.element)
  pedMandyGym.blip = AddBlipForChar(pedMandyGym.id, 2, 0, 4)
  PedSetMissionCritical(pedMandyGym.id, true, F_MissionCriticalMandyGym, true)
  pedChristyGym.id = PedCreatePoint(pedChristyGym.model, pedChristyGym.spawn, pedChristyGym.element)
  pedAngieGym.id = PedCreatePoint(pedAngieGym.model, pedAngieGym.spawn, pedAngieGym.element)
  pedPinkyGym.id = PedCreatePoint(pedPinkyGym.model, pedPinkyGym.spawn, pedPinkyGym.element)
  PedIgnoreStimuli(pedMandyGym.id, true)
  PedIgnoreStimuli(pedChristyGym.id, true)
  PedIgnoreStimuli(pedAngieGym.id, true)
  PedIgnoreStimuli(pedPinkyGym.id, true)
  bMonitorCheerleaders = true
  CreateThread("T_MonitorCheerleaders")
end
function F_StartCheerRoutine()
  PedSetActionNode(pedMandyGym.id, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
  PedSetActionNode(pedChristyGym.id, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
  PedSetActionNode(pedAngieGym.id, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
  PedSetActionNode(pedPinkyGym.id, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
end
function F_StopCheerRoutine()
  PedSetActionNode(pedMandyGym.id, "/Global/4_01/Anims/Empty", "Act/Conv/4_01.act")
  PedSetActionNode(pedAngieGym.id, "/Global/4_01/Anims/Empty", "Act/Conv/4_01.act")
  PedSetActionNode(pedPinkyGym.id, "/Global/4_01/Anims/Empty", "Act/Conv/4_01.act")
  PedSetActionNode(pedChristyGym.id, "/Global/4_01/Anims/Empty", "Act/Conv/4_01.act")
end
function F_EarnestReceivedPhotos()
  bEarnestLeave = true
end
function F_PlayerGavePhotos()
  bClosingDialogue = true
end
function F_MandyStartWashing()
  PedSetActionNode(pedMandyShower.id, "/Global/4_01/Anims/Showering/Wash01", "Act/Conv/4_01.act")
end
function F_MandyStopWashing()
  PedSetActionNode(pedMandyShower.id, "/Global/4_01/Anims/Empty", "Act/Conv/4_01.act")
end
function F_CreateShowerSteam()
  local effectX, effectY, effectZ = GetPointFromPointList(POINTLIST._4_01_SPAWNMANDYSHOWER, 1)
  effectShower01 = EffectCreate("ShowerSteam2", effectX, effectY, effectZ)
  effectX, effectY, effectZ = GetPointFromPointList(POINTLIST._4_01_EFFECTSTEAMSHOWER, 1)
  effectShower02 = EffectCreate("ShowerSteam2", effectX, effectY, effectZ)
  effectX, effectY, effectZ = GetPointFromPointList(POINTLIST._4_01_EFFECTSTEAMROOM, 1)
  effectSteam = EffectCreate("SteamRoom", effectX, effectY, effectZ)
  bShowerEffectLoaded = true
end
function F_KillShowerSteam()
  if bShowerEffectLoaded then
    EffectSlowKill(effectShower01, 5, true)
    EffectSlowKill(effectShower02, 5, true)
    EffectSlowKill(effectSteam, 5, true)
  end
end
function F_MandySawPlayerFromShower()
  SoundFadeWithCamera(false)
  MusicFadeWithCamera(false)
  PlayerSetControl(0)
  CameraFade(500, 0)
  Wait(500)
  shared.gdormHeadStop = true
  PedSetPosPoint(pedMandyShower.id, POINTLIST._4_01_BUSTEDSHOWER)
  PedSetStationary(pedMandyBedroom.id, true)
  TextPrint("4_01_EMPTY", 1, 1)
  F_MakePlayerSafeForNIS(true)
  CameraSetWidescreen(true)
  CameraFade(500, 1)
  SoundStopCurrentSpeechEvent(pedMandyShower.id)
  CameraSetXYZ(-423.55948, 303.97916, -0.162787, -424.46786, 303.89954, -0.573111)
  PedSetActionNode(pedMandyShower.id, "/Global/4_01/Anims/FreakOut/FreakOut", "Act/Conv/4_01.act")
  SoundPlayScriptedSpeechEvent(pedMandyShower.id, "M_4_01", 10, "jumbo")
  F_WaitForSpeech(pedMandyShower.id)
  PedSetActionNode(pedMandyShower.id, "/Global/4_01/Anims/FreakOut/FreakOut/CoverUp", "Act/Conv/4_01.act")
  SoundPlayScriptedSpeechEvent(pedMandyShower.id, "M_4_01", 11, "jumbo")
  F_WaitForSpeech(pedMandyShower.id)
  CameraFade(500, 0)
  Wait(500)
  F_MakePlayerSafeForNIS(false)
  CameraSetWidescreen(false)
  CameraReturnToPlayer()
  CameraReset()
  PlayerSetControl(1)
  PedSetStationary(pedMandyShower.id, false)
  PedSetPosPoint(pedMandyShower.id, POINTLIST._4_01_MANDYOUTOFSHOWER)
  PedFaceObject(pedMandyShower.id, gPlayer, 3, 0)
  BlipRemoveFromChar(pedMandyShower.id)
  CameraFade(500, 1)
  Wait(500)
  PedFlee(pedMandyShower.id, gPlayer)
  PedMakeAmbient(pedMandyShower.id)
  PlayerSetPunishmentPoints(PlayerGetPunishmentPoints() + 200)
  shared.gdormHeadStart = true
  gMissionFailMessage = 2
  bMissionFailed = true
  SoundFadeWithCamera(true)
  MusicFadeWithCamera(true)
end
function F_MandySawPlayerFromBedroom()
  SoundFadeWithCamera(false)
  MusicFadeWithCamera(false)
  PlayerSetControl(0)
  CameraFade(500, 0)
  Wait(500)
  shared.gdormHeadStop = true
  PedSetActionNode(pedMandyBedroom.id, "/Global/4_01/Anims/Empty", "Act/Conv/4_01.act")
  PedFaceObject(pedMandyBedroom.id, gPlayer, 3, 0)
  PedSetStationary(pedMandyBedroom.id, true)
  TextPrint("4_01_EMPTY", 1, 1)
  F_MakePlayerSafeForNIS(true)
  CameraSetWidescreen(true)
  CameraReturnToPlayer()
  CameraReset()
  CameraSetXYZ(-415.19568, 304.4951, -1.265636, -414.42007, 303.89496, -1.070755)
  CameraFade(500, 1)
  Wait(1000)
  SoundFadeWithCamera(true)
  MusicFadeWithCamera(true)
  SoundStopCurrentSpeechEvent(pedMandyBedroom.id)
  SoundPlayScriptedSpeechEventWrapper(pedMandyBedroom.id, "M_4_01", 10, "large")
  PedSetActionNode(pedMandyBedroom.id, "/Global/4_01/Anims/FreakOut/FreakOut", "Act/Conv/4_01.act")
  Wait(1000)
  SoundPlayScriptedSpeechEventWrapper(pedMandyBedroom.id, "M_4_01", 11, "large")
  Wait(5000)
  F_MakePlayerSafeForNIS(false)
  CameraSetWidescreen(false)
  CameraReturnToPlayer()
  CameraReset()
  PlayerSetControl(1)
  PedSetStationary(pedMandyBedroom.id, false)
  PedFlee(pedMandyBedroom.id, gPlayer)
  PedMakeAmbient(pedMandyBedroom.id)
  BlipRemoveFromChar(pedMandyBedroom.id)
  PlayerSetPunishmentPoints(PlayerGetPunishmentPoints() + 200)
  shared.gdormHeadStart = true
  gMissionFailMessage = 2
  bMissionFailed = true
end
function F_MandyBustedPlayerInGym()
  SoundFadeWithCamera(false)
  MusicFadeWithCamera(false)
  PlayerSetControl(0)
  CameraFade(500, 0)
  Wait(500)
  PedSetActionNode(pedMandyBedroom.id, "/Global/4_01/Anims/Empty", "Act/Conv/4_01.act")
  PedFaceObject(pedMandyBedroom.id, gPlayer, 3, 0)
  PedSetStationary(pedMandyBedroom.id, true)
  F_MakePlayerSafeForNIS(true)
  CameraSetWidescreen(true)
  CameraReturnToPlayer()
  CameraReset()
  CameraSetXYZ(-415.19568, 304.4951, -1.265636, -414.42007, 303.89496, -1.070755)
  CameraFade(500, 1)
  Wait(1000)
  SoundFadeWithCamera(true)
  MusicFadeWithCamera(true)
  SoundPlayScriptedSpeechEventWrapper(pedMandyBedroom.id, "M_4_01", 10, "large")
  PedSetActionNode(pedMandyBedroom.id, "/Global/4_01/Anims/FreakOut/FreakOut", "Act/Conv/4_01.act")
  Wait(1000)
  SoundPlayScriptedSpeechEventWrapper(pedMandyBedroom.id, "M_4_01", 11, "large")
  Wait(5000)
  F_MakePlayerSafeForNIS(false)
  CameraSetWidescreen(false)
  CameraReturnToPlayer()
  CameraReset()
  PlayerSetControl(1)
  PedSetStationary(pedMandyBedroom.id, false)
  PedFlee(pedMandyBedroom.id, gPlayer)
  PedMakeAmbient(pedMandyBedroom.id)
  PlayerSetPunishmentPoints(PlayerGetPunishmentPoints() + 200)
  bMissionFailed = true
end
function F_HasMandyBeenHit()
  if PedIsHit(pedMandyGym.id, 2, 500) then
    if PedGetWhoHitMeLast(pedMandyGym.id) == gPlayer then
      return true
    end
  else
    return false
  end
end
function F_EjectPlayerFromDorm()
  CameraFade(500, 0)
  Wait(500)
  PedStop(gPlayer)
  PedClearObjectives(gPlayer)
  if bLaunchedEunice and F_PedExists(pedEunice.id) then
    if CounterGetCurrent() <= 2 then
      PedSetPosPoint(pedEunice.id, POINTLIST._4_01_SPAWNEUNICERESETDOWN)
    else
      PedSetPosPoint(pedEunice.id, POINTLIST._4_01_SPAWNEUNICERESETUP)
    end
  end
  AreaTransitionPoint(0, POINTLIST._4_01_PLAYERBOOTED)
  PlayerSetPunishmentPoints(0)
  CameraSetWidescreen(false)
  PlayerSetControl(1)
  CameraFade(500, 1)
  Wait(500)
  shared.gdormHeadSpottedPlayer = false
  bEuniceStealthSpeech = false
  bPedEjected = true
end
function F_LaunchEuniceUpstairs()
  if F_PedExists(pedEunice.id) then
    PedFollowPath(pedEunice.id, PATH._4_01_EUNICEUPSTAIRS, 0, 0, cbEuniceUpstairs)
  end
end
function F_WaitForSpeech(pedID)
  if pedID == nil then
    while SoundSpeechPlaying() do
      Wait(0)
    end
  else
    while SoundSpeechPlaying(pedID) do
      Wait(0)
    end
  end
end
function F_ClosingDialogue()
  CameraSetWidescreen(true)
  PlayerSetControl(0)
  F_MakePlayerSafeForNIS(true)
  SoundDisableSpeech_ActionTree()
  SoundPlayScriptedSpeechEventWrapper(gPlayer, "M_4_01", 25)
  F_WaitForSpeech(gPlayer)
  SoundPlayScriptedSpeechEventWrapper(pedEarnest.id, "M_4_01", 26)
end
function T_CheerSpeech()
  local gGirlFlag = 0
  while bCheerSpeech do
    if not SoundSpeechPlaying(pedAngieGym.id) and not SoundSpeechPlaying(pedMandyGym.id) then
      gGirlFlag = math.random(1, 2)
      if gGirlFlag == 1 then
        SoundPlayAmbientSpeechEvent(pedAngieGym.id, "CHEERLEADING")
        F_WaitForSpeech(pedAngieGym.id)
      elseif gGirlFlag == 2 then
        SoundPlayAmbientSpeechEvent(pedMandyGym.id, "CHEERLEADING")
        F_WaitForSpeech(pedMandyGym.id)
      end
    end
    Wait(0)
  end
end
function F_ResetCamera()
  if PlayerHasItem(426) then
    PedSetWeaponNow(gPlayer, 426, 1)
  elseif PlayerHasItem(328) then
    PedSetWeaponNow(gPlayer, 328, 1)
  end
end
function F_PlayerSpotted(buster)
  PlayerSetControl(0)
  CameraSetWidescreen(true)
  PedSetFlag(buster, 129, true)
  PedStop(buster)
  PedClearObjectives(buster)
  PedSetStationary(buster, true)
  PedFaceObject(buster, gPlayer, 3, 1, false)
  PedFaceObject(gPlayer, buster, 2, 1)
  PedSetIsStealthMissionPed(buster, false)
  shared.gdormHeadCanMove = false
  if buster == shared.gdormHeadID then
    F_BustCam(shared.gdormHeadID)
    SoundStopCurrentSpeechEvent(shared.gdormHeadID)
    SoundPlayScriptedSpeechEventWrapper(shared.gdormHeadID, "M_4_01", 45, "large")
    F_WaitForSpeech(shared.gdormHeadID)
  end
  PedSetStationary(buster, false)
end
function F_BustCam(pedID)
  local x1, y1, z1 = PedGetOffsetInWorldCoords(pedID, 0.5, 1, 1.7)
  local x2, y2, z2 = PedGetOffsetInWorldCoords(pedID, -0.5, -0.7, 1.7)
  CameraSetXYZ(x1, y1, z1, x2, y2, z2)
end
function F_WaitForSpeechCutscene01(pedID)
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
end
function F_CutBootedOut()
  CameraFade(500, 0)
  Wait(500)
  PedSetWeaponNow(gPlayer, -1, 0)
  PedSetFlag(gPlayer, 2, false)
  PedSetPosPoint(gPlayer, POINTLIST._4_01_CUTBOOTJIMMY, 1)
  Wait(50)
  PedFaceHeading(gPlayer, 1, 0)
  PedSetPosPoint(shared.gdormHeadID, POINTLIST._4_01_CUTBOOTHEAD, 1)
  CameraSetXYZ(-437.95193, 313.57703, -5.994447, -438.2697, 314.51898, -6.101623)
  CameraFade(500, 1)
  Wait(250)
  PedFollowPath(gPlayer, PATH._4_01_ROUTECUTBOOT, 0, 0)
  SoundStopCurrentSpeechEvent(shared.gdormHeadID)
  SoundPlayScriptedSpeechEventWrapper(shared.gdormHeadID, "M_4_01", 40, "medium")
  F_WaitForSpeech(shared.gdormHeadID)
end
function T_MonitorCheerleaders()
  while bMonitorCheerleaders do
    if PedIsHit(pedAngieGym.id, 2, 500) and PedGetWhoHitMeLast(pedAngieGym.id) == gPlayer then
      bPlayerHitMandyInsideGym = true
      bMonitorCheerleaders = false
    end
    if PedIsHit(pedPinkyGym.id, 2, 500) and PedGetWhoHitMeLast(pedPinkyGym.id) == gPlayer then
      bPlayerHitMandyInsideGym = true
      bMonitorCheerleaders = false
    end
    if PedIsHit(pedChristyGym.id, 2, 500) and PedGetWhoHitMeLast(pedChristyGym.id) == gPlayer then
      bPlayerHitMandyInsideGym = true
      bMonitorCheerleaders = false
    end
    tempStimBool, tempStimTarget = PedHasGeneratedStimulusOfType(gPlayer, 55)
    if tempStimBool and (tempStimTarget == pedAngieGym.id or tempStimTarget == pedPinkyGym.id or tempStimTarget == pedChristyGym.id) then
      bPlayerHitMandyInsideGym = true
      bMonitorCheerleaders = false
    end
    Wait(0)
  end
end
function T_SpeechChristyDorm()
  SoundPlayScriptedSpeechEventWrapper(pedChristyDorm.id, "M_4_01", 18, "large")
  Wait(1000)
  SoundPlayScriptedSpeechEventWrapper(pedChristyDorm.id, "M_4_01", 19, "large")
end
function T_ResetGirlsDorm()
  while AreaGetVisible() ~= 35 do
    Wait(0)
  end
  bLaunchedEunice = false
  bDormFlaggedForReset = true
end
function T_Cutscene01()
  if not bSkipFirstCutscene then
    PedSetActionNode(pedMandyGym.id, "/Global/4_01/Anims/GymCut/Mandy/Mandy01", "Act/Conv/4_01.act")
    PedSetActionNode(pedAngieGym.id, "/Global/4_01/Anims/GymCut/FallDownGetUp/Jump", "Act/Conv/4_01.act")
    PedSetActionNode(pedPinkyGym.id, "/Global/4_01/Anims/GymCut/ChLeadIdle05/Animation", "Act/Conv/4_01.act")
    PedSetActionNode(pedChristyGym.id, "/Global/4_01/Anims/GymCut/ChLeadIdle04/Animation", "Act/Conv/4_01.act")
  end
  if not bSkipFirstCutscene then
    WaitSkippable(2000)
  end
  if not bSkipFirstCutscene then
    SoundPlayScriptedSpeechEventWrapper(pedMandyGym.id, "M_4_01", 91, "large")
  end
  if not bSkipFirstCutscene then
    F_WaitForSpeechCutscene01(pedMandyGym.id)
  end
  if not bSkipFirstCutscene then
    WaitSkippable(1500)
  end
  if not bSkipFirstCutscene then
    CameraSetFOV(80)
    CameraSetXYZ(-619.71204, -60.446346, 60.86252, -619.4415, -61.40244, 60.973927)
    PedSetActionNode(pedMandyGym.id, "/Global/4_01/Anims/GymCut/SmellSelf/Smell_Pits", "Act/Conv/4_01.act")
    SoundPlayScriptedSpeechEventWrapper(pedMandyGym.id, "M_4_01", 5, "large")
  end
  if not bSkipFirstCutscene then
    F_WaitForSpeechCutscene01(pedMandyGym.id)
  end
  if not bSkipFirstCutscene then
    SoundPlayScriptedSpeechEventWrapper(pedMandyGym.id, "M_4_01", 92, "large")
  end
  if not bSkipFirstCutscene then
    WaitSkippable(1500)
  end
  if not bSkipFirstCutscene then
    PedIgnoreStimuli(pedMandyGym.id, true)
    PedFollowPath(pedMandyGym.id, PATH._4_01_MANDYEXITGYM, 0, 1, cbMandyExitGym)
  end
  if not bSkipFirstCutscene then
    WaitSkippable(300)
  end
  if not bSkipFirstCutscene then
    CameraSetFOV(80)
    CameraSetXYZ(-622.16016, -56.709454, 62.056435, -621.8153, -57.587994, 61.726772)
  end
  if not bSkipFirstCutscene then
    WaitSkippable(3200)
  end
  bSkipFirstCutscene = true
end
function F_CutPhotoGym()
  PlayerSetControl(0)
  F_MakePlayerSafeForNIS(true)
  SoundFadeWithCamera(false)
  MusicFadeWithCamera(false)
  CameraFade(500, 0)
  Wait(500)
  LoadAnimationGroup("NIS_4_01")
  CameraReturnToPlayer()
  CameraReset()
  Wait(50)
  PlayerSetPosPoint(POINTLIST._4_01_GYMMOVEJIMMY)
  Wait(50)
  CameraSetWidescreen(true)
  StopAmbientPedAttacks()
  SoundSetAudioFocusCamera()
  CameraSetFOV(80)
  CameraSetXYZ(-621.41943, -56.90906, 60.160484, -620.9529, -57.78902, 60.248596)
  F_StopCheerRoutine()
  CameraFade(500, 1)
  Wait(500)
  CreateThread("T_Cutscene01")
  while not bSkipFirstCutscene do
    if IsButtonPressed(7, 0) then
      bSkipFirstCutscene = true
    end
    Wait(0)
  end
  CameraFade(500, 0)
  Wait(500)
  SoundSetAudioFocusPlayer()
  CameraDefaultFOV()
  PedSetMissionCritical(pedMandyGym.id, false)
  PedDelete(pedMandyGym.id)
  PedFollowPath(pedAngieGym.id, PATH._4_01_GIRLSTOGYMLOCKERROOM, 0, 0, cbGirlsToGymLockerRoom)
  PedFollowPath(pedPinkyGym.id, PATH._4_01_GIRLSTOGYMLOCKERROOM, 0, 1, cbGirlsToGymLockerRoom)
  PedFollowPath(pedChristyGym.id, PATH._4_01_GIRLSTOGYMLOCKERROOM, 0, 0, cbGirlsToGymLockerRoom)
  PedMakeAmbient(pedAngieGym.id)
  PedMakeAmbient(pedPinkyGym.id)
  PedMakeAmbient(pedChristyGym.id)
  UnLoadAnimationGroup("POI_ChLead")
  F_MakePlayerSafeForNIS(false)
  CameraSetWidescreen(false)
  CameraReturnToPlayer()
  CameraReset()
  F_ResetCamera()
  CameraFade(500, 1)
  Wait(500)
  PlayerSetControl(1)
  SoundFadeWithCamera(true)
  MusicFadeWithCamera(true)
  UnLoadAnimationGroup("NIS_4_01")
end
function F_CutPhotoShower()
  PlayerSetControl(0)
  F_MakePlayerSafeForNIS(true)
  SoundFadeWithCamera(false)
  MusicFadeWithCamera(false)
  CameraFade(500, 0)
  Wait(500)
  shared.gdormHeadStop = true
  CameraSetWidescreen(true)
  CameraReturnToPlayer()
  CameraReset()
  StopAmbientPedAttacks()
  LoadWeaponModels({361})
  CameraSetXYZ(-428.81247, 301.20825, -1.147998, -428.39355, 300.30655, -1.04191)
  F_MandyStopWashing()
  F_KillShowerSteam()
  local effectX, effectY, effectZ = GetPointFromPointList(POINTLIST._4_01_EFFECTSTEAMROOM, 1)
  effectSteam = EffectCreate("SteamRoom", effectX, effectY, effectZ)
  PedSetPosPoint(pedMandyShower.id, POINTLIST._4_01_CUTSHOWERMANDY)
  PedFaceHeading(pedMandyShower.id, 45, 0)
  PlayerSetPosPoint(POINTLIST._4_01_CUTSHOWERPLAYER)
  TextPrint("4_01_EMPTY", 1, 1)
  CameraFade(500, 1)
  Wait(500)
  PedSetActionNode(pedMandyShower.id, "/Global/4_01/Anims/Showering/FinishedShower", "Act/Conv/4_01.act")
  SoundPlayScriptedSpeechEventWrapper(pedMandyShower.id, "M_4_01", 9, "large")
  Wait(5000)
  PedFollowPath(pedMandyShower.id, PATH._4_01_MANDYEXITSHOWER, 0, 0)
  Wait(700)
  CameraSetFOV(80)
  CameraSetXYZ(-428.15848, 307.2929, -0.870865, -428.40262, 306.33188, -1.000271)
  Wait(4000)
  CameraFade(500, 0)
  Wait(500)
  F_MakePlayerSafeForNIS(false)
  CameraSetWidescreen(false)
  CameraReturnToPlayer()
  CameraReset()
  CameraDefaultFOV()
  AreaSetDoorLocked("GDORM_UPPERDOOR", false)
  PAnimDoorStayOpen(TRIGGER._GDORM_UPPERDOOR)
  PAnimOpenDoor(TRIGGER._GDORM_UPPERDOOR)
  PedDelete(pedMandyShower.id)
  pedMandyBedroom.blip = AddBlipForChar(pedMandyBedroom.id, 2, 0, 4)
  PedSetActionNode(pedMandyBedroom.id, "/Global/4_01/Anims/MassagingLeg/LegIn", "Act/Conv/4_01.act")
  EffectSlowKill(effectSteam, 5, true)
  shared.gdormHeadStart = true
  F_ResetCamera()
  CameraFade(500, 1)
  Wait(500)
  PlayerSetControl(1)
  SoundFadeWithCamera(true)
  MusicFadeWithCamera(true)
end
function F_MissionCriticalMandyGym()
  bPlayerHitMandyInsideGym = true
end
function F_MissionCriticalEarnest()
  PedOverrideStat(pedEarnest.id, 3, 12)
  PedSetStationary(pedEarnest.id, false)
  PedMakeAmbient(pedEarnest.id)
  gMissionFailMessage = 3
  bMissionFailed = true
end
function F_MissionCritical()
  bMissionFailed = true
end
function cbMandyExitGym(pedID, pathID, nodeID)
end
function cbGirlsToGymLockerRoom(pedID, pathID, nodeID)
end
function cbEuniceDownstairs(pedID, pathID, nodeID)
  if nodeID == 5 then
    SoundPlayScriptedSpeechEventWrapper(pedEunice.id, "M_4_01", 15)
    SoundPlayScriptedSpeechEventWrapper(pedEunice.id, "M_4_01", 17)
  end
end
function cbEuniceUpstairs(pedID, pathID, nodeID)
  if nodeID == 21 then
    PedSetActionNode(pedEunice.id, "/Global/WProps/PropInteract", "Act/WProps.act")
  end
end
