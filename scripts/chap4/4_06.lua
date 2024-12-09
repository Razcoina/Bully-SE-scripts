local playerBike
local bComplete_Operation = false
local bWaitingToTrigger = true
local bMissionIsActive = false
local bOutOfBoundsFail = false
local bFieldOpOver = false
local LacedDrink = false
local BenchesDone = false
local RiggedBallPlanted = false
local FieldTacked = false
local ScoreboardHacked = false
local bDagSeesYou = false
local bPlantingRiggedBall = false
local FieldLoaded = false
local boardGood01, boardGood02, boardBad01, boardBad02
local bGroupShower = false
local AllDone = false
local x1, y1, z1, x2, y2, z2, fx, fy, fz, CurrentMission, CurrentMissionNumber
local TotalMissionsComplete = 0
local ExitBlip, Target_B, SportsDrink, Melvin, Algernon, Bucky, Fatty, Cornelius, Benches, BenchTotal, FieldBlip, GameBallblip, Objectives
local Bucky = {}
local Algernon = {}
local Melvin = {}
local Fatty = {}
local SportsDrink = {}
local Target_B = {}
local Objectives = {}
local Benches = {}
local Scoreboard = {}
local charID = {}
local gSpeechTable = {}
local gMonitoringTable = {
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
}
local gMonitoringTableA = {
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
}
local gOutsidePoint = {
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
}
local gInsidePoint = {
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
}
local gFlagrantChecks = {
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
}
local gPlayerFlagrant = false
local gLostJocks = 0
local BURTONSPEAKTIME = 8000
local ATTACK_TIME = 12000
local INTRO = 0
local OUTRO = 1
local gTackedJocks = 0
function MissionSetup()
  F_MakePlayerSafeForNIS(false, false)
  PlayerSetControl(1)
  CameraSetWidescreen(false)
  shared.bFootBallFieldEnabled = false
  ClothingBackup()
  if ClothingIsWearingOutfit("Mascot") then
    ClothingSetPlayerOutfit("MascotNoHead")
    ClothingBuildPlayer()
  end
  PlayCutsceneWithLoad("4-06", true)
  SoundPlayInteractiveStream("MS_MisbehavingLow.rsm", 0.4)
  LoadActionTree("Act/Gifts/GiveWftbomb.act")
  LoadActionTree("Act/Gifts/GiveSuperGlue.act")
  LoadActionTree("Act/Gifts/GiveBagmrbls.act")
  DATLoad("4_06.DAT", 2)
  DATInit()
  PauseGameClock()
  MissionDontFadeIn()
end
function MissionCleanup()
  shared.g4_06OpAcomplete = false
  shared.g4_06OpCcomplete = false
  shared.g4_06OpDcomplete = false
  shared.g4_06OpEcomplete = false
  shared.g4_06OpFcomplete = false
  shared.g4_06GateTutComplete = false
  AreaSetPathableInRadius(34.57452, -139.21382, 4, 0.5, 6, true)
  shared.bFootBallFieldEnabled = true
  SoundUnLoadBank("MISSION\\4_06.bnk")
  shared.lockClothingManager = false
  if gTutShown then
    TutorialRemoveMessage()
  end
  SoundStopInteractiveStream()
  if bOutOfBoundsFail then
    PAnimOpenDoor(TRIGGER._SCGATE_OBSERVATORY)
    AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, false)
    AreaSetDoorLockedToPeds(TRIGGER._SCGATE_OBSERVATORY, false)
  end
  if ScoreboardHacked then
    DeletePersistentEntity(boardBad01, boardBad02)
  else
    DeletePersistentEntity(boardGood01, boardGood02)
    WeatherRelease()
  end
  if peeIndex then
    DeletePersistentEntity(peeIndex, peeEntity)
  end
  if coolerIndex then
    DeletePersistentEntity(coolerIndex, coolerEntity)
  end
  if gMissionOverCalled then
    PlayerSetPosPoint(POINTLIST._4_06_MISSIONFAIL)
  end
  if AreaGetVisible() == 13 then
    AreaSetDoorLocked(TRIGGER._DT_POOL_DOORL, false)
    AreaSetDoorLocked(TRIGGER._DT_GYM_DOORL, false)
  end
  UnpauseGameClock()
  EnablePOI(true, true)
  PedSetFlag(gPlayer, 13, false)
  AreaDeactivatePopulationTrigger(TRIGGER._4_06_LOAD_FIELD)
  UnLoadAnimationGroup("4_06BIGGAME")
  UnLoadAnimationGroup("Hang_Workout")
  UnLoadAnimationGroup("NPC_CHEERING")
  UnLoadAnimationGroup("GEN_SOCIAL")
  UnLoadAnimationGroup("PX_TLET")
  UnLoadAnimationGroup("POI_ChLead")
  UnLoadAnimationGroup("NIS_4_06")
  DATUnload(2)
  ClothingRestore()
  ClothingBuildPlayer()
  CameraSetWidescreen(false)
  F_MakePlayerSafeForNIS(false)
  AreaRevertToDefaultPopulation()
  CounterMakeHUDVisible(false)
  PlayerLockButtonInputsExcept(false)
end
function F_MissionSetUp()
  WeaponRequestModel(335)
  LoadAnimationGroup("4_06BIGGAME")
  LoadAnimationGroup("GEN_SOCIAL")
  LoadAnimationGroup("NPC_CHEERING")
  LoadAnimationGroup("PX_TLET")
  LoadAnimationGroup("NPC_MASCOT")
  LoadAnimationGroup("POI_ChLead")
  LoadAnimationGroup("NIS_4_06")
  LoadActionTree("Act/Conv/4_06.act")
  LoadActionTree("Act/Props/CtrlBx.act")
  WeaponRequestModel(331)
  WeaponRequestModel(400)
  WeaponRequestModel(349)
  SoundLoadBank("MISSION\\4_06.bnk")
  F_TableInit()
  PlayerSetControl(0)
  PedSetWeaponNow(gPlayer, -1, 0)
  AreaActivatePopulationTrigger(TRIGGER._4_06_LOAD_FIELD)
  shared.lockClothingManager = true
  AreaClearAllPeds()
  DisablePOI(true, true)
  PedSetTypeToTypeAttitude(1, 13, 4)
  PedSetTypeToTypeAttitude(5, 13, 1)
  PedSetTypeToTypeAttitude(2, 13, 2)
  PedSetTypeToTypeAttitude(4, 13, 1)
  PedSetTypeToTypeAttitude(9, 13, 0)
  boardGood01, boardGood02 = CreatePersistentEntity("SC_JocksLEDgood", -53.1448, -73.6493, 6.34204, 0, 0)
  ClothingSetPlayerOutfit("Mascot")
  ClothingBuildPlayer()
  PlayerSetControl(1)
  AreaTransitionPoint(0, POINTLIST._4_06_PLAYER_START, nil, true)
  GateNerd.id = PedCreatePoint(GateNerd.model, GateNerd.point)
  RegisterTriggerEventHandler(TRIGGER._4_06_OOB01, 1, F_OutOfBound)
  RegisterTriggerEventHandler(TRIGGER._4_06_OOB02, 1, F_OutOfBound)
  RegisterTriggerEventHandler(TRIGGER._4_06_OOB03, 1, F_OutOfBound)
  RegisterTriggerEventHandler(TRIGGER._4_06_BIB01, 1, F_BackInBound)
  RegisterTriggerEventHandler(TRIGGER._4_06_BIB02, 1, F_BackInBound)
  RegisterTriggerEventHandler(TRIGGER._4_06_BIB03, 1, F_BackInBound)
  CreateThread("T_FieldOps")
  CreateThread("T_DeletePeds")
  CreateThread("T_CheckToAttack")
end
function DeleteMissionPeds(opNo, forceDeletion)
  local enemies = gEnemiesPerMission[opNo]
  for i, ped in enemies, nil, nil do
    if PedIsValid(ped.id) then
      PedDelete(ped.id)
      if forceDeletion then
        gEnemiesPerMission[opNo][i].id = nil
      end
    end
  end
end
function F_TableInit()
  Algernon = {
    point = POINTLIST._4_06_DOSSIER_A,
    model = 4
  }
  Bucky = {
    point = POINTLIST._4_06_DOSSIER_C,
    model = 8
  }
  Fatty = {
    point = POINTLIST._4_06_DOSSIER_D,
    model = 5
  }
  Melvin = {
    point = POINTLIST._4_06_DOSSIER_E,
    model = 6
  }
  Cornelius = {
    point = POINTLIST._4_06_DOSSIER_F,
    model = 9
  }
  GateNerd = {
    point = POINTLIST._4_06_GATENERD,
    model = 7
  }
  CoachBurton = {
    id = nil,
    point = POINTLIST._4_06_COACH_BURTON,
    model = 55
  }
  gEnemiesPerMission = {
    {
      {
        distracted = false,
        id = nil,
        model = 13,
        point = POINTLIST._4_06_GYM_PATROL,
        pvalue = 1,
        group = 1,
        timeSeen = 0,
        speech = 7
      },
      {
        distracted = false,
        id = nil,
        model = 12,
        point = POINTLIST._4_06_GYM_PATROL,
        pvalue = 2,
        group = 1,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 14,
        point = POINTLIST._4_06_GYM_CHEERLEADER,
        path = "CHEER",
        pvalue = 1,
        group = 2,
        timeSeen = 0,
        speech = 3
      },
      {
        distracted = false,
        id = nil,
        model = 180,
        point = POINTLIST._4_06_GYM_CHEERLEADER,
        path = "CHEER",
        pvalue = 2,
        group = 2,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 181,
        point = POINTLIST._4_06_GYM_CHEERLEADER,
        path = "CHEER",
        pvalue = 3,
        group = 2,
        timeSeen = 0
      }
    },
    {
      {
        distracted = false,
        id = nil,
        model = 15,
        point = POINTLIST._4_06_BALLGUARDS,
        pvalue = 1,
        group = 1,
        timeSeen = 0,
        speech = 4
      },
      {
        distracted = false,
        id = nil,
        model = 180,
        point = POINTLIST._4_06_BALLGUARDS,
        pvalue = 2,
        group = 1,
        timeSeen = 0
      }
    },
    {
      {
        distracted = false,
        id = nil,
        model = 232,
        point = POINTLIST._4_06_BLEACHER_GUARDS,
        path = "WORKOUT",
        pvalue = 1,
        group = 1,
        timeSeen = 0,
        speech = 6
      },
      {
        distracted = false,
        id = nil,
        model = 109,
        point = POINTLIST._4_06_BLEACHER_GUARDS,
        path = "WORKOUT",
        pvalue = 2,
        group = 1,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 20,
        point = POINTLIST._4_06_BLEACHER_GUARDS,
        path = "WORKOUT",
        pvalue = 3,
        group = 1,
        timeSeen = 0
      }
    },
    {},
    {
      {
        distracted = false,
        id = nil,
        model = 182,
        point = POINTLIST._4_06_FIELD_WORKER,
        path = "CHEER",
        pvalue = 1,
        group = 1,
        timeSeen = 0,
        speech = 8
      },
      {
        distracted = false,
        id = nil,
        model = 14,
        point = POINTLIST._4_06_FIELD_WORKER,
        path = "CHEER",
        pvalue = 2,
        group = 1,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 180,
        point = POINTLIST._4_06_FIELD_WORKER,
        path = "CHEER",
        pvalue = 3,
        group = 1,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 232,
        point = POINTLIST._4_06_FIELD_RUNNERS,
        path = PATH._4_06_LONGRUNNER01,
        pvalue = 1,
        group = 2,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 111,
        point = POINTLIST._4_06_FIELD_RUNNERS,
        path = PATH._4_06_LONGRUNNER02,
        pvalue = 2,
        group = 2,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 109,
        point = POINTLIST._4_06_FIELD_RUNNERS,
        path = PATH._4_06_LONGRUNNER03,
        pvalue = 3,
        group = 2,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 231,
        point = POINTLIST._4_06_FIELD_RUNNERS,
        pvalue = 4,
        group = 3,
        timeSeen = 0,
        path = PATH._4_06_JOCKLAP
      },
      {
        distracted = false,
        id = nil,
        model = 112,
        point = POINTLIST._4_06_FIELD_RUNNERS,
        pvalue = 5,
        group = 3,
        timeSeen = 0,
        path = PATH._4_06_JOCKLAP
      }
    },
    {
      {
        distracted = false,
        id = nil,
        model = 20,
        pvalue = 1,
        point = POINTLIST._4_06_INITIAL_GUARDS,
        group = 1,
        timeSeen = 0,
        speech = 2
      },
      {
        distracted = false,
        id = nil,
        model = 16,
        pvalue = 2,
        point = POINTLIST._4_06_INITIAL_GUARDS,
        group = 1,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 17,
        pvalue = 3,
        point = POINTLIST._4_06_INITIAL_GUARDS,
        group = 1,
        timeSeen = 0
      },
      {
        distracted = false,
        id = nil,
        model = 231,
        pvalue = 4,
        point = POINTLIST._4_06_FIELD_RUNNERS,
        group = 2,
        timeSeen = 0,
        speech = 5,
        path = PATH._4_06_JOCKLAP
      },
      {
        distracted = false,
        id = nil,
        model = 112,
        pvalue = 5,
        point = POINTLIST._4_06_FIELD_RUNNERS,
        group = 2,
        timeSeen = 0,
        path = PATH._4_06_JOCKLAP
      }
    }
  }
  SportsDrink = {
    loc = POINTLIST._4_06_OBJECTIVE_A
  }
  Frisbee = {
    point = POINTLIST._4_06_DOSSIER_C,
    model = 237
  }
  Benches = {
    {
      IsGlued = false,
      loc = POINTLIST._4_06_OBJECTIVE_D,
      trigger = TRIGGER._4_06_BENCH_01,
      trigger2 = TRIGGER._4_06_BENCH_01A,
      blip = nil
    },
    {
      IsGlued = false,
      loc = POINTLIST._4_06_OBJECTIVE_D,
      trigger = TRIGGER._4_06_BENCH_02,
      trigger2 = TRIGGER._4_06_BENCH_02A,
      blip = nil
    },
    {
      IsGlued = false,
      loc = POINTLIST._4_06_OBJECTIVE_D,
      trigger = TRIGGER._4_06_BENCH_03,
      trigger2 = TRIGGER._4_06_BENCH_03A,
      blip = nil
    },
    {
      IsGlued = false,
      loc = POINTLIST._4_06_OBJECTIVE_D,
      trigger = TRIGGER._4_06_BENCH_04,
      trigger2 = TRIGGER._4_06_BENCH_04A,
      blip = nil
    }
  }
  Objectives = {
    {
      complete = shared.g4_06OpAcomplete,
      blip = nil,
      loc = POINTLIST._4_06_DOSSIER_A,
      func = F_OperationA,
      id = Algernon,
      model = Algernon.model
    },
    {
      complete = shared.g4_06OpCcomplete,
      blip = nil,
      loc = POINTLIST._4_06_DOSSIER_C,
      func = F_OperationC,
      id = Bucky,
      model = Bucky.model
    },
    {
      complete = shared.g4_06OpDcomplete,
      blip = nil,
      loc = POINTLIST._4_06_DOSSIER_D,
      func = F_OperationD,
      id = Fatty,
      model = Fatty.model
    },
    {
      complete = shared.g4_06OpEcomplete,
      blip = nil,
      loc = POINTLIST._4_06_DOSSIER_E,
      func = F_OperationE,
      id = Melvin,
      model = Melvin.model
    },
    {
      complete = shared.g4_06OpFcomplete,
      blip = nil,
      loc = POINTLIST._4_06_DOSSIER_F,
      func = F_OperationF,
      id = Cornelius,
      model = Cornelius.model
    }
  }
  gSpeechTable = {
    {
      active = true,
      seePlayer = 50,
      goodDance = 63,
      badDance = 74,
      leave = 66
    },
    {
      active = true,
      seePlayer = 46,
      goodDance = 54,
      badDance = 70,
      leave = 59
    },
    {
      active = true,
      seePlayer = 49,
      goodDance = 62,
      badDance = 73,
      leave = 65
    },
    {
      active = true,
      seePlayer = 54,
      goodDance = 60,
      badDance = 71,
      leave = 59
    },
    {
      active = true,
      seePlayer = 45,
      goodDance = 53,
      badDance = 69,
      leave = 58
    },
    {
      active = true,
      seePlayer = 44,
      goodDance = 52,
      badDance = 68,
      leave = 57
    },
    {
      active = true,
      seePlayer = 46,
      goodDance = 54,
      badDance = 70,
      leave = 59
    },
    {
      active = true,
      seePlayer = 51,
      goodDance = 64,
      badDance = 75,
      leave = 67
    }
  }
  gObjsTable = {}
  Scoreboard = {
    point = POINTLIST._4_06_OBJECTIVE_F
  }
  PedRequestModel(4)
  PedRequestModel(8)
  PedRequestModel(5)
  PedRequestModel(6)
  PedRequestModel(9)
  PedRequestModel(11)
  PedRequestModel(20)
  PedRequestModel(16)
  PedRequestModel(17)
  PedRequestModel(231)
  PedRequestModel(112)
  PedSocialOverrideLoad(18, "Mission/4_06Greeting.act")
end
function main()
  gInsidePool = false
  F_MissionSetUp()
  AreaSetPathableInRadius(34.57452, -139.21382, 4, 0.5, 6, false)
  F_GateNerd()
  if not gMissionOverCalled then
    F_CheckAllMissions()
    if shared.g4_06OpAcomplete and shared.g4_06OpCcomplete and shared.g4_06OpDcomplete and shared.g4_06OpEcomplete then
      TextPrint("4_06_NEXT_OP_2", 5, 1)
    elseif TotalMissionsComplete < 3 then
      TextPrint("4_06_NEXT_OP", 5, 1)
    else
      TextPrint("4_06_NEXT_OP3", 5, 1)
    end
    F_ChooseYourOwnAdventure()
    if bOutOfBoundsFail then
      MissionOver()
    end
  end
  if not gMissionOverCalled then
    F_OperationF()
    if bOutOfBoundsFail then
      MissionOver()
    end
    SetFactionRespect(2, GetFactionRespect(2) - 10)
    MinigameSetCompletion("M_PASS", true, 2500)
    MinigameAddCompletionMsg("MRESPECT_JM10", 1)
    SoundPlayMissionEndMusic(true, 10)
    while MinigameIsShowingCompletion() do
      Wait(0)
    end
    MissionSucceed(true, false, false)
  end
end
function F_GateNerd()
  if not shared.g4_06GateTutComplete then
    PedSetFaction(GateNerd.id, 2)
    LoadAnimationGroup("MINI_Lock")
    PAnimCloseDoor(TRIGGER._SCGATE_OBSERVATORY)
    AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, true)
    AreaSetDoorLockedToPeds(TRIGGER._SCGATE_OBSERVATORY, true)
    TextPrint("4_06_GATENERD", 5, 1)
	local bWaitingOnDance = true
    PedSetMissionCritical(GateNerd.id, true, CbPlayerAggressed, true)
    CameraFade(1000, 1)
    Wait(1000)
    gObjsTable.firstObj = MissionObjectiveAdd("4_06_GATENERD")
    SoundPlayAmbientSpeechEvent(GateNerd.id, "HELP_EXPLANATION")
    gTutShown = true
    TutorialShowMessage("TUT_BULL1")
    while bWaitingOnDance do
      if PlayerIsInTrigger(TRIGGER._4_06_OUTSIDEGATE) then
	    bWaitingOnDance = false
      end
      if not gDanceForThad and F_PlayerIsDancing() then
        TutorialRemoveMessage()
        gDanceForThad = true
      end
      if PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/Failure", true) then
        PedSetFaction(GateNerd.id, 1)
        PedStop(GateNerd.id)
        PedClearObjectives(GateNerd.id)
        PedIgnoreStimuli(GateNerd.id, true)
        if math.random(1, 100) < 50 then
          SoundPlayAmbientSpeechEvent(GateNerd.id, "ALLY_ORDER_REJECT")
        else
          SoundPlayAmbientSpeechEvent(GateNerd.id, "BUMP_RUDE")
          while PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/Failure", true) do
            Wait(0)
          end
        end
        Wait(2000)
        PedSetFaction(GateNerd.id, 2)
        PedIgnoreStimuli(GateNerd.id, false)
        gDanceForThad = false
      end
      if PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/Success", true) then
        TutorialRemoveMessage()
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        CameraSetXYZ(36.18411, -132.22598, 3.949842, 35.242622, -132.5613, 3.982883)
        PedStop(GateNerd.id)
        PedClearObjectives(GateNerd.id)
        PedIgnoreStimuli(GateNerd.id, true)
        Wait(1000)
        PedFollowPath(GateNerd.id, PATH._4_06_GATEPATH, 0, 0, CbGateNerdPath)
        while not gateNerdFinished do
          Wait(0)
        end
        PedFaceHeading(GateNerd.id, 90, 1)
        Wait(1500)
        PedSetActionNode(GateNerd.id, "/Global/4_06/GateNerd/Picklock", "Act/Conv/4_06.act")
        while PedIsPlaying(GateNerd.id, "/Global/4_06/GateNerd/Picklock", true) do
          Wait(0)
        end
        PedIgnoreStimuli(GateNerd.id, false)
        AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, false)
        AreaSetDoorLockedToPeds(TRIGGER._SCGATE_OBSERVATORY, false)
        PAnimOpenDoor(TRIGGER._SCGATE_OBSERVATORY)
        PAnimDoorStayOpen(TRIGGER._SCGATE_OBSERVATORY)
		bWaitingOnDance = false
        Wait(2000)
        PedFaceObject(gPlayer, GateNerd.id, 2, 0)
        CameraReturnToPlayer()
        CameraReset()
        PlayerSetControl(1)
        CameraSetWidescreen(false)
        SoundPlayAmbientSpeechEvent(GateNerd.id, "CONGRATULATIONS")
        PedSetMissionCritical(GateNerd.id, false)
        PedMakeAmbient(GateNerd.id)
        PedSetFaction(GateNerd.id, 1)
        TutorialRemoveMessage()
        gTutShown = false
        MissionObjectiveRemove(gObjsTable.firstObj)
        UnLoadAnimationGroup("MINI_Lock")
      end
      if bOutOfBoundsFail then
        bWaitingOnDance = false
        MissionOver()
      end
      Wait(0)
    end
  else
    CameraFade(1000, 1)
    Wait(1000)
    PedMakeAmbient(GateNerd.id)
    AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, false)
    PAnimOpenDoor(TRIGGER._SCGATE_OBSERVATORY)
    PAnimDoorStayOpen(TRIGGER._SCGATE_OBSERVATORY)
    TutorialStart("WRESTCHANGE")
  end
end
local timeoutGlobal = 0
function TimeOut()
  if GetTimer() > timeoutGlobal then
    return true
  end
  return false
end
function F_OPAGreet()
  bWaitingToTrigger = false
end
function F_OPCGreet()
  bWaitingToTrigger = false
end
function F_OPDGreet()
  bWaitingToTrigger = false
end
function F_OPEGreet()
  bWaitingToTrigger = false
end
function F_OPFGreet()
  bWaitingToTrigger = false
end
function F_OPA_NIS(nisType)
  if nisType == INTRO then
    CameraSetWidescreen(true)
    SoundPlayStream("MS_Misbehaving_NISPrankInfo.rsm", 0.35, 0, 500)
    PedStopSocializing(Objectives[1].id)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    PlayerLockButtonInputsExcept(true, 9)
    playerBike = F_PlayerDismountBikeBG()
    PedLockTarget(gPlayer, -1)
    PedMoveToPoint(gPlayer, 0, Objectives[1].loc, 2)
    PedFaceObject(Objectives[1].id, gPlayer, 3, 1)
    Wait(1000)
    CameraFade(250, 0)
    Wait(251)
    DeleteMissionPeds(6)
    F_DeleteAllBikes(playerBike, POINTLIST._4_06_BIKES, 1)
    PedRemoveStimulus(Objectives[1].id)
    PedSetPosPoint(Objectives[1].id, Objectives[1].loc, 1)
    PedRemoveStimulus(Objectives[1].id)
    PedIgnoreStimuli(Objectives[1].id, true)
    local x, y, z = GetPointFromPointList(Objectives[1].loc, 2)
    PlayerSetPosSimple(x, y, z)
    PedFaceObject(Objectives[1].id, gPlayer, 3, 1)
    PedFaceObject(gPlayer, Objectives[1].id, 2, 1)
    PedLockTarget(Objectives[1].id, gPlayer)
    PedLockTarget(gPlayer, Objectives[1].id)
    Wait(500)
    PedFaceObject(Objectives[1].id, gPlayer, 3, 1)
    Wait(500)
    PedSetActionNode(Objectives[1].id, "/Global/4_06/NISs/Nerds/Algie/Algie01", "Act/Conv/4_06.act")
    CameraFade(250, 1)
    F_PlaySpeechAndWait(Objectives[1].id, "M_4_06", 1, "supersize")
    PedSetActionNode(gPlayer, "/Global/4_06/NISs/Player/PlayerAlgie", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(gPlayer, "M_4_06", 2, "supersize")
    PedSetActionNode(Objectives[1].id, "/Global/4_06/NISs/Nerds/Algie/Algie02", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(Objectives[1].id, "M_4_06", 3, "supersize")
    PedSetActionNode(Objectives[1].id, "/Global/4_06/NISs/Nerds/Algie/Algie03", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(Objectives[1].id, "M_4_06", 4, "supersize")
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    LoadAnimationGroup("W_PRANK")
    LoadAnimationGroup("Player_VTired")
    LoadAnimationGroup("MINI_React")
    PedRequestModel(13)
    PedRequestModel(12)
    PedRequestModel(14)
    PedRequestModel(180)
    PedRequestModel(181)
    LoadModels({341}, true)
    PAnimCreate(TRIGGER._4_06_COOLER)
    CameraSetWidescreen(false)
    CameraReturnToPlayer(true)
    PedLockTarget(Objectives[1].id, -1)
    PedLockTarget(gPlayer, -1)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PlayerSetPosPoint(Objectives[1].loc, 3)
    TutorialRemoveMessage()
    PedIgnoreStimuli(Objectives[1].id, false)
    CameraFade(-1, 1)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    PlayerLockButtonInputsExcept(false)
    SoundStopInteractiveStream()
    SoundPlayInteractiveStream("MS_MisbehavingHigh.rsm", 0.5, 0, 250)
  elseif nisType == OUTRO then
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    PlayerSetControl(0)
    TutorialRemoveMessage()
    Wait(FADE_OUT_TIME)
    F_MakePlayerSafeForNIS(true)
    CameraSetWidescreen(true)
    local outroPedA = PedCreatePoint(13, POINTLIST._4_06_OPAEND_PED, 1)
    local outroPedB = PedCreatePoint(12, POINTLIST._4_06_OPAEND_PED, 2)
    local outroPedC = PedCreatePoint(14, POINTLIST._4_06_OPAEND_PED, 3)
    PedClearAllWeapons(outroPedA)
    PedClearAllWeapons(outroPedB)
    PedClearAllWeapons(outroPedC)
    local x, y, z = GetPointList(POINTLIST._4_06_OPAEND_PLAYER)
    DeleteMissionPeds(1)
    PlayerSetPosSimple(x, y, z)
    PedRecruitAlly(outroPedB, outroPedC)
    CameraSetFOV(50)
    CameraSetXYZ(-639.59235, -57.310722, 55.428665, -640.5626, -57.525276, 55.540195)
    AreaClearAllPeds()
    PedClearObjectives(outroPedA)
    SoundSetAudioFocusCamera()
    LoadModels({428}, true)
    CameraFade(-1, 1)
    SoundPlayStream("MS_Misbehaving_NISPrankSucess.rsm", 0.5, 0, 1000)
    PedFollowPath(outroPedA, PATH._4_06_OPAEND_PATHA, 0, 0)
    SoundPlayScriptedSpeechEvent(outroPedA, "M_4_06", 90, "jumbo", true)
    PedMoveToPoint(outroPedB, 0, POINTLIST._4_06_OPAEND_PED, 4)
    Wait(5500)
    SoundPlayScriptedSpeechEvent(outroPedB, "M_4_06", 92, "jumbo", true)
    PedSetActionNode(outroPedA, "/Global/4_06/4_06_Wizz/Puke", "Act/Conv/4_06.act")
    PedFaceObject(outroPedB, outroPedA, 2, 1)
    Wait(6000)
    SoundPlayScriptedSpeechEvent(outroPedC, "M_4_06", 94, "jumbo", true)
    PedSetActionNode(outroPedB, "/Global/Ambient/Reactions/HumiliationReact/Laughing", "Act/Anim/Ambient.act")
    SoundPlayScriptedSpeechEvent(outroPedB, "LAUGH_CRUEL", 93, "jumbo", true)
    Wait(2000)
    PedSetActionNode(outroPedB, "/Global/Ambient/Reactions/HumiliationReact/Laughing", "Act/Anim/Ambient.act")
    SoundPlayScriptedSpeechEvent(outroPedB, "M_4_06", 93, "jumbo", true)
    SoundPlayScriptedSpeechEvent(outroPedC, "M_4_06", 94, "jumbo", true)
    PedSetActionNode(outroPedA, "/Global/4_06/4_06_Wizz/Disappoint", "Act/Conv/4_06.act")
    PedDismissAlly(outroPedB, outroPedC)
    PedFlee(outroPedC, outroPedA)
    while PedIsPlaying(outroPedA, "/Global/4_06/4_06_Wizz/Disappoint", true) do
      Wait(0)
    end
    WaitSkippable(2000)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    TutorialRemoveMessage()
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    CameraReturnToPlayer()
    SoundPlayInteractiveStream("MS_MisbehavingLow.rsm", 0.4)
    UnLoadAnimationGroup("W_PRANK")
    UnLoadAnimationGroup("Player_VTired")
    UnLoadAnimationGroup("MINI_React")
    PedDelete(outroPedA)
    PedDelete(outroPedB)
    PedDelete(outroPedC)
    CameraSetWidescreen(false)
    SoundSetAudioFocusPlayer()
  end
end
function F_OPC_NIS(nisType)
  if nisType == INTRO then
    SoundPlayStream("MS_Misbehaving_NISPrankInfo.rsm", 0.35, 0, 500)
    CameraSetWidescreen(true)
    PedStopSocializing(Objectives[2].id)
    PlayerSetControl(0)
    PlayerLockButtonInputsExcept(true, 9)
    playerBike = F_PlayerDismountBikeBG()
    PedLockTarget(gPlayer, -1)
    F_MakePlayerSafeForNIS(true)
    PedMoveToPoint(gPlayer, 1, Objectives[2].loc, 2)
    PedFaceObject(Objectives[2].id, gPlayer, 3, 1)
    Wait(1000)
    CameraFade(250, 0)
    Wait(251)
    F_DeleteAllBikes(playerBike, POINTLIST._4_06_BIKES, 2)
    PedRemoveStimulus(Objectives[2].id)
    PedSetPosPoint(Objectives[2].id, Objectives[2].loc, 1)
    PedRemoveStimulus(Objectives[2].id)
    PedIgnoreStimuli(Objectives[2].id, true)
    local x, y, z = GetPointFromPointList(Objectives[2].loc, 2)
    PlayerSetPosSimple(x, y, z)
    PedFaceObject(Objectives[2].id, gPlayer, 3, 1)
    PedFaceObject(gPlayer, Objectives[2].id, 2, 1)
    PedLockTarget(Objectives[2].id, gPlayer)
    PedLockTarget(gPlayer, Objectives[2].id)
    DeleteMissionPeds(6, true)
    PedSetActionNode(Objectives[2].id, "/Global/4_06/NISs/Nerds/Bucky/Bucky01", "Act/Conv/4_06.act")
    CameraFade(250, 1)
    F_PlaySpeechAndWait(Objectives[2].id, "M_4_06", 32, "supersize")
    PedSetActionNode(Objectives[2].id, "/Global/4_06/ReceiveIdle", "Act/Conv/4_06.act")
    PedStop(Objectives[2].id)
    PedSetActionNode(gPlayer, "/Global/4_06/NISs/Player/PlayerBucky", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(gPlayer, "M_4_06", 33, "supersize")
    PedSetActionNode(gPlayer, "/Global/GiveWftbomb/Give_Attempt", "Act/Gifts/GiveWftbomb.act")
    while PedIsPlaying(gPlayer, "/Global/GiveWftbomb", true) do
      Wait(0)
    end
    Wait(4000)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    PAnimRequest(TRIGGER._4_06_DUFFLE_BAG)
    PedRequestModel(15)
    PedRequestModel(180)
    PedRequestModel(141)
    PedRequestModel(13)
    PedRequestModel(232)
    PAnimCreate(TRIGGER._4_06_DUFFLE_BAG)
    CameraReturnToPlayer(true)
    CameraSetWidescreen(false)
    PlayerSetPosPoint(Objectives[2].loc, 3)
    PedIgnoreStimuli(Objectives[2].id, false)
    TutorialRemoveMessage()
    F_CreateMissionSpecPeds(6)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    CameraFade(-1, 1)
    PedLockTarget(Objectives[2].id, -1)
    PedLockTarget(gPlayer, -1)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    PlayerLockButtonInputsExcept(false)
    SoundStopInteractiveStream()
    SoundPlayInteractiveStream("MS_MisbehavingHigh_NIS01.rsm", 0.5, 0, 250)
  elseif nisType == OUTRO then
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    DeleteMissionPeds(2)
    CameraFade(500, 0)
    PlayerSetControl(0)
    Wait(500)
    TutorialRemoveMessage()
    F_MakePlayerSafeForNIS(true)
    local outroPedB = PedCreatePoint(15, POINTLIST._4_06_JOCKSPAWN, 1)
    CameraSetWidescreen(true)
    CameraSetFOV(80)
    CameraSetXYZ(-19.169231, -25.89341, 2.92458, -19.795395, -25.11858, 3.009784)
    SoundSetAudioFocusCamera()
    CameraFade(-1, 1)
    SoundPlayStream("MS_Misbehaving_NISPrankSucess.rsm", 0.5, 250, 250)
    PedMoveToPoint(gPlayer, 1, POINTLIST._4_06_OPCEND_PLAYER)
    Wait(1000)
    CameraSetFOV(80)
    CameraSetXYZ(-19.07855, -20.086308, 4.401656, -19.557585, -20.927404, 4.151165)
    PedClearAllWeapons(outroPedB)
    PedSetWeaponNow(outroPedB, -1, 0)
    PedMoveToPoint(outroPedB, 1, POINTLIST._4_06_BALLGUARDS, 3)
    Wait(500)
    local outroPedA = PedCreatePoint(13, POINTLIST._4_06_JOCKSPAWN, 1)
    PedMoveToPoint(outroPedA, 1, POINTLIST._4_06_MOVETOJOCK, 1)
    PedClearAllWeapons(outroPedA)
    PedSetWeaponNow(outroPedA, -1, 0)
    Wait(1500)
    Wait(1000)
    CameraSetFOV(40)
    CameraSetXYZ(-17.777225, -23.27374, 4.316599, -18.680893, -23.363947, 3.898098)
    PedSetPosPoint(outroPedA, POINTLIST._4_06_MOVETOJOCK, 2)
    PedSetActionNode(outroPedA, "/Global/4_06/NISs/Pranks/Football/KirbyGetsBall", "Act/Conv/4_06.act")
    Wait(2500)
    CameraSetFOV(40)
    CameraSetXYZ(-8.095899, -63.381435, 9.425729, -8.595063, -62.571785, 9.117247)
    PedSetPosXYZ(outroPedA, -21.348404, -24.205833, 2.0409005)
    PedSetWeapon(outroPedA, 400, 1)
    x, y, z = GetPointList(POINTLIST._4_06_OBJECTIVE_C)
    timeoutGlobal = GetTimer() + 5000
    while not PedIsInAreaXYZ(outroPedA, x, y, z, 0.5, 0) do
      if TimeOut() then
        break
      end
      Wait(0)
    end
    PedMoveToPoint(outroPedA, 1, POINTLIST._4_06_BALLGUARDS, 1)
    x, y, z = GetPointFromPointList(POINTLIST._4_06_BALLGUARDS, 1)
    local x2, y2, z2 = GetPointFromPointList(POINTLIST._4_06_BALLGUARDS, 3)
    SoundPlayScriptedSpeechEvent(outroPedB, "M_4_06", 96, "jumbo", true)
    timeoutGlobal = GetTimer() + 5000
    while not PedIsInAreaXYZ(outroPedA, x, y, z, 0.5, 0) or not PedIsInAreaXYZ(outroPedB, x2, y2, z2, 0.5, 0) do
      if TimeOut() then
        break
      end
      Wait(0)
    end
    PedStop(outroPedA)
    PedStop(outroPedB)
    PedFaceObject(outroPedA, outroPedB, 2, 1)
    PedFaceObject(outroPedB, outroPedA, 2, 1)
    SoundPlayScriptedSpeechEvent(outroPedA, "M_4_06", 80, "jumbo", true)
    Wait(500)
    CameraSetFOV(30)
    CameraSetXYZ(-16.510925, -57.829197, 2.410211, -16.898472, -56.90985, 2.34741)
    PedOverrideStat(outroPedA, 10, 100)
    PedPassBall(outroPedA, outroPedB, 8000)
    Wait(2500)
    SoundPlayScriptedSpeechEvent(outroPedB, "M_4_06", 23, "jumbo", true)
    PedStop(outroPedA)
    PedClearObjectives(outroPedA)
    PedMoveToPoint(outroPedA, 1, POINTLIST._4_06_JOCKSPAWN, 1)
    WaitSkippable(2000)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    PlayerSetPosSimple(0.2, -40.7, 1.1)
    PlayerFaceHeadingNow(102.7)
    PedDelete(outroPedA)
    PedDelete(outroPedB)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    PAnimDelete(TRIGGER._4_06_DUFFLE_BAG)
    CameraReturnToPlayer()
    CameraReset()
    PedDestroyWeapon(gPlayer, 400)
    CameraSetWidescreen(false)
    SoundSetAudioFocusPlayer()
    CameraFade(-1, 1)
    SoundPlayInteractiveStream("MS_MisbehavingLow.rsm", 0.4)
  end
end
function F_OPD_NIS(nisType)
  if nisType == INTRO then
    SoundPlayStream("MS_Misbehaving_NISPrankInfo.rsm", 0.35, 0, 500)
    CameraSetWidescreen(true)
    PedStopSocializing(Objectives[3].id)
    TutorialRemoveMessage()
    PlayerSetControl(0)
    playerBike = F_PlayerDismountBikeBG()
    PlayerLockButtonInputsExcept(true, 9)
    F_MakePlayerSafeForNIS(true)
    PedLockTarget(gPlayer, -1)
    PedMoveToPoint(gPlayer, 0, Objectives[3].loc, 2)
    PedFaceObject(Objectives[3].id, gPlayer, 3, 1)
    Wait(1000)
    CameraFade(250, 0)
    Wait(251)
    F_DeleteAllBikes(playerBike, POINTLIST._4_06_BIKES, 3)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedRemoveStimulus(Objectives[3].id)
    PedSetPosPoint(Objectives[3].id, Objectives[3].loc, 1)
    PedRemoveStimulus(Objectives[3].id)
    PedIgnoreStimuli(Objectives[3].id, true)
    local x, y, z = GetPointFromPointList(Objectives[2].loc, 2)
    PlayerSetPosSimple(x, y, z)
    PedFaceObject(Objectives[3].id, gPlayer, 3, 1)
    PedFaceObject(gPlayer, Objectives[3].id, 2, 1)
    PedLockTarget(Objectives[3].id, gPlayer)
    PedLockTarget(gPlayer, Objectives[3].id)
    DeleteMissionPeds(6, true)
    Wait(500)
    PedSetActionNode(gPlayer, "/Global/GiveSuperGlue/Give_Attempt", "Act/Gifts/GiveSuperGlue.act")
    CameraFade(250, 1)
    while PedIsPlaying(gPlayer, "/Global/GiveSuperGlue", true) do
      Wait(0)
    end
    PedSetActionNode(Objectives[3].id, "/Global/4_06/NISs/Nerds/Fatty/Fatty02", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(Objectives[3].id, "M_4_06", 20, "supersize")
    CameraSetXYZ(5.177861, -57.770424, 2.518823, 5.51866, -56.837563, 2.40243)
    PedLockTarget(gPlayer, -1)
    PedMoveToPoint(gPlayer, 0, POINTLIST._4_06_DOSSIER_D, 4)
    F_PlaySpeechAndWait(gPlayer, "M_4_06", 21, "supersize")
    Wait(1000)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    PedStop(gPlayer)
    PAnimCreate(TRIGGER._4_06_BENCH_01)
    PAnimCreate(TRIGGER._4_06_BENCH_02)
    PAnimCreate(TRIGGER._4_06_BENCH_03)
    PAnimCreate(TRIGGER._4_06_BENCH_04)
    PAnimCreate(TRIGGER._4_06_BENCH_01A)
    PAnimCreate(TRIGGER._4_06_BENCH_02A)
    PAnimCreate(TRIGGER._4_06_BENCH_03A)
    PAnimCreate(TRIGGER._4_06_BENCH_04A)
    PedRequestModel(232)
    PedRequestModel(109)
    PedRequestModel(20)
    LoadModels({347})
    LoadAnimationGroup("Hang_Workout")
    CameraReturnToPlayer(true)
    CameraSetWidescreen(false)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedIgnoreStimuli(Objectives[3].id, false)
    F_CreateMissionSpecPeds(6)
    CameraFade(-1, 1)
    PedLockTarget(Objectives[3].id, -1)
    PedLockTarget(gPlayer, -1)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    PlayerLockButtonInputsExcept(false)
    SoundStopInteractiveStream()
    SoundPlayInteractiveStream("MS_MisbehavingHigh_NIS02.rsm", 0.5, 0, 250)
  elseif nisType == OUTRO then
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    TutorialRemoveMessage()
    PlayerSetControl(0)
    Wait(FADE_OUT_TIME)
    SoundSetAudioFocusCamera()
    SoundDisableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(true)
    CameraSetWidescreen(true)
    DeleteMissionPeds(3)
    local outroPedA = PedCreatePoint(20, POINTLIST._4_06_OPDENDPED, 1)
    local outroPedB = PedCreatePoint(109, POINTLIST._4_06_OPDENDPED, 2)
    local outroPedC = PedCreatePoint(232, POINTLIST._4_06_OPDENDPED, 3)
    PedClearAllWeapons(outroPedA)
    PedClearAllWeapons(outroPedB)
    PedClearAllWeapons(outroPedC)
    local x, y, z = GetPointList(POINTLIST._4_06_OPEND_PLAYER)
    PlayerSetPosSimple(x, y, z)
    PedRecruitAlly(outroPedA, outroPedB)
    PedRecruitAlly(outroPedB, outroPedC)
    AreaClearAllPeds()
    CameraSetFOV(80)
    CameraSetXYZ(-11.253895, -65.6897, 1.666455, -10.703083, -64.871445, 1.828651)
    CameraFade(-1, 1)
    SoundPlayStream("MS_Misbehaving_NISPrankSucess.rsm", 0.5, 0, 250)
    PedMoveToPoint(outroPedA, 0, POINTLIST._4_06_OPDENDPED, 4)
    SoundPlayScriptedSpeechEvent(outroPedA, "M_4_06", 96, "jumbo", true)
    Wait(2500)
    CameraSetFOV(80)
    CameraSetXYZ(-6.345839, -64.1826, 1.362268, -7.031287, -63.48373, 1.565413)
    PedSetPosPoint(outroPedA, POINTLIST._4_06_OPDENDPED, 5)
    PedSetActionNode(outroPedA, "/Global/4_06/4_06_Glue/Sit_Start", "Act/Conv/4_06.act")
    Wait(1500)
    Wait(1000)
    PedSetActionNode(outroPedB, "/Global/4_06/NISs/Jocks/Laughing/Guy_Laugh/Laugh01", "Act/Conv/4_06.act")
    SoundPlayScriptedSpeechEvent(outroPedB, "M_4_06", 91, "supersize")
    Wait(500)
    PedSetActionNode(outroPedC, "/Global/4_06/NISs/Jocks/Laughing/Guy_Laugh/Laugh02", "Act/Conv/4_06.act")
    SoundPlayScriptedSpeechEvent(outroPedC, "M_4_06", 98, "supersize")
    SoundPlayScriptedSpeechEvent(outroPedA, "M_4_06", 97, "supersize")
    WaitSkippable(5000)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    PlayerFaceHeadingNow(270)
    SoundEnableSpeech_ActionTree()
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    UnLoadAnimationGroup("Hang_Workout")
    CameraReturnToPlayer()
    CameraReset()
    PedDelete(outroPedA)
    PedDelete(outroPedB)
    PedDelete(outroPedC)
    CameraSetWidescreen(false)
    SoundSetAudioFocusPlayer()
    CameraFade(-1, 1)
    SoundPlayInteractiveStream("MS_MisbehavingLow.rsm", 0.4)
  end
end
function F_OPE_NIS(nisType)
  if nisType == INTRO then
    SoundPlayStream("MS_Misbehaving_NISPrankInfo.rsm", 0.35, 0, 500)
    CameraSetWidescreen(true)
    TutorialRemoveMessage()
    PedStopSocializing(Objectives[4].id)
    PlayerSetControl(0)
    PlayerLockButtonInputsExcept(true, 9)
    playerBike = F_PlayerDismountBikeBG()
    F_MakePlayerSafeForNIS(true)
    PedLockTarget(gPlayer, -1)
    PedMoveToPoint(gPlayer, 0, Objectives[4].loc, 2)
    PedFaceObject(Objectives[4].id, gPlayer, 3, 1)
    Wait(1000)
    CameraFade(250, 0)
    Wait(251)
    F_DeleteAllBikes(playerBike, POINTLIST._4_06_BIKES, 4)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedRemoveStimulus(Objectives[4].id)
    PedSetPosPoint(Objectives[4].id, Objectives[4].loc, 1)
    PedRemoveStimulus(Objectives[4].id)
    PedIgnoreStimuli(Objectives[4].id, true)
    local x, y, z = GetPointFromPointList(Objectives[4].loc, 2)
    PlayerSetPosSimple(x, y, z)
    PedFaceObject(Objectives[4].id, gPlayer, 3, 1)
    PedFaceObject(gPlayer, Objectives[4].id, 2, 1)
    PedLockTarget(Objectives[4].id, gPlayer)
    PedLockTarget(gPlayer, Objectives[4].id)
    DeleteMissionPeds(6)
    PedSetActionNode(Objectives[4].id, "/Global/4_06/NISs/Nerds/Melvin/Melvin01", "Act/Conv/4_06.act")
    CameraFade(250, 1)
    F_PlaySpeechAndWait(Objectives[4].id, "M_4_06", 38, "supersize")
    PedSetActionNode(gPlayer, "/Global/4_06/NISs/Player/PlayerMelvin", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(gPlayer, "M_4_06", 39, "supersize")
    PedSetActionNode(gPlayer, "/Global/GiveBagmrbls/Give_Attempt", "Act/Gifts/GiveBagmrbls.act")
    while PedIsPlaying(gPlayer, "/Global/GiveBagmrbls", true) do
      Wait(0)
    end
    Wait(1500)
    CameraSetXYZ(102.7899, -58.00623, 7.478976, 103.739136, -57.718952, 7.351126)
    PedLockTarget(gPlayer, -1)
    PedMoveToPoint(gPlayer, 0, POINTLIST._4_06_DOSSIER_E, 4)
    F_PlaySpeechAndWait(gPlayer, "M_4_06", 41, "supersize")
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    PedRequestModel(232)
    PedRequestModel(111)
    PedRequestModel(109)
    CameraSetWidescreen(false)
    PedLockTarget(Objectives[4].id, -1)
    PedIgnoreStimuli(Objectives[4].id, false)
    PedLockTarget(gPlayer, -1)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PlayerSetPosPoint(Objectives[4].loc, 3)
    CameraReturnToPlayer(true)
    CameraFade(-1, 1)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    PlayerLockButtonInputsExcept(false)
    SoundStopInteractiveStream()
    SoundPlayInteractiveStream("MS_MisbehavingHigh_NIS03.rsm", 0.5, 0, 250)
  elseif nisType == OUTRO then
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    SoundLoadBank("weapons\\Marbles.bnk")
    CameraFade(-1, 0)
    PlayerSetControl(0)
    Wait(FADE_OUT_TIME)
    TutorialRemoveMessage()
    DeleteMissionPeds(4)
    F_MakePlayerSafeForNIS(true)
    local outroPedA = PedCreatePoint(232, POINTLIST._4_06_JOCKSPAWN, 1)
    PedClearAllWeapons(outroPedA)
    CameraSetWidescreen(true)
    local x, y, z = GetPointList(POINTLIST._4_06_OPEND_PLAYER)
    PlayerSetPosSimple(x, y, z)
    PlayerFaceHeadingNow(102.7)
    CameraLookAtXYZ(-19.009794, -50.68135, 2.857111, true)
    CameraSetFOV(80)
    CameraSetXYZ(-17.72731, -24.05262, 5.156742, -18.000452, -24.998327, 4.980834)
    CameraFade(-1, 1)
    SoundSetAudioFocusCamera()
    SoundPlayStream("MS_Misbehaving_NISPrankSucess.rsm", 0.5, 0, 250)
    PedMoveToPoint(outroPedA, 1, POINTLIST._4_06_OPEENDPED, 1)
    Wait(500)
    local outroPedB = PedCreatePoint(232, POINTLIST._4_06_JOCKSPAWN, 1)
    PedClearAllWeapons(outroPedB)
    PedMoveToPoint(outroPedB, 1, POINTLIST._4_06_OPEENDPED, 2)
    Wait(500)
    local outroPedC = PedCreatePoint(232, POINTLIST._4_06_JOCKSPAWN, 1)
    SoundPlayScriptedSpeechEvent(outroPedC, "M_4_06", 99, "supersize")
    PedClearAllWeapons(outroPedC)
    PedMoveToPoint(outroPedC, 1, POINTLIST._4_06_OPEENDPED, 3)
    Wait(500)
    x, y, z = GetPointFromPointList(POINTLIST._4_06_OPEENDPED, 3)
    timeoutGlobal = GetTimer() + 5000
    while not PedIsInAreaXYZ(outroPedC, x, y, z, 0.5, 0) do
      if TimeOut() then
        break
      end
      Wait(0)
    end
    PedMoveToPoint(outroPedA, 1, POINTLIST._4_06_OPEENDPED, 4)
    PedMoveToPoint(outroPedB, 1, POINTLIST._4_06_OPEENDPED, 5)
    PedMoveToPoint(outroPedC, 1, POINTLIST._4_06_OPEENDPED, 6)
    Wait(1000)
    Wait(100)
    PedSetActionNode(outroPedC, "/Global/4_06/NISs/Marbles/HIT_LEG_FRONT_L_FALL", "Act/Conv/4_06.act")
    Wait(800)
    CameraSetFOV(80)
    CameraSetXYZ(-18.473286, -51.920918, 1.534011, -18.980827, -51.05963, 1.555421)
    PedSetActionNode(outroPedA, "/Global/4_06/NISs/Marbles/HIT_LEG_FRONT_R_FALL", "Act/Conv/4_06.act")
    Wait(800)
    CameraSetXYZ(-39.08377, -53.393654, 1.364971, -38.456585, -52.61921, 1.447281)
    PedSetActionNode(outroPedB, "/Global/4_06/NISs/Marbles/HIT_LEG_FRONT_L_FALL", "Act/Conv/4_06.act")
    PedSetActionNode(outroPedC, "/Global/4_06/NISs/Marbles/HIT_LEG_FRONT_R_FALL", "Act/Conv/4_06.act")
    Wait(1500)
    PedSetActionNode(outroPedB, "/Global/4_06/NISs/Marbles/HIT_LEG_FRONT_L_FALL", "Act/Conv/4_06.act")
    PedSetActionNode(outroPedA, "/Global/4_06/NISs/Marbles/HIT_LEG_FRONT_R_FALL", "Act/Conv/4_06.act")
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    SoundUnLoadBank("weapons\\Marbles.bnk")
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    PedDelete(outroPedA)
    PedDelete(outroPedB)
    PedDelete(outroPedC)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    PlayerFaceHeadingNow(270)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    SoundSetAudioFocusPlayer()
    CameraReset()
    CameraFade(-1, 1)
    SoundPlayInteractiveStream("MS_MisbehavingLow.rsm", 0.4)
  end
end
function F_OPF_NIS(nisType)
  if nisType == INTRO then
    SoundPlayStream("MS_Misbehaving_NISPrankInfo.rsm", 0.35, 0, 500)
    CameraSetWidescreen(true)
    PedStopSocializing(Objectives[5].id)
    TutorialRemoveMessage()
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    PlayerLockButtonInputsExcept(true, 9)
    playerBike = F_PlayerDismountBikeBG()
    PedLockTarget(gPlayer, -1)
    PedMoveToPoint(gPlayer, 0, Objectives[5].loc, 2, nil, 0.5)
    PedFaceObject(Objectives[5].id, gPlayer, 3, 1)
    Wait(1000)
    CameraFade(250, 0)
    Wait(251)
    F_DeleteAllBikes(playerBike, POINTLIST._4_06_BIKES, 5)
    PedRemoveStimulus(Objectives[5].id)
    PedSetPosPoint(Objectives[5].id, Objectives[5].loc, 1)
    PedRemoveStimulus(Objectives[5].id)
    PedIgnoreStimuli(Objectives[5].id, true)
    local x, y, z = GetPointFromPointList(Objectives[5].loc, 2)
    PlayerSetPosSimple(x, y, z)
    PedFaceObject(Objectives[5].id, gPlayer, 3, 1)
    PedFaceObject(gPlayer, Objectives[5].id, 2, 1)
    PedLockTarget(Objectives[5].id, gPlayer)
    PedLockTarget(gPlayer, Objectives[5].id)
    DeleteMissionPeds(6, true)
    CameraSetXYZ(95.59912, -72.31499, 8.497162, 96.34237, -72.977295, 8.402911)
    CameraFade(250, 1)
    PedSetActionNode(Objectives[5].id, "/Global/4_06/NISs/Nerds/Cornelius/Cornelius01", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(Objectives[5].id, "M_4_06", 22, "supersize")
    CameraSetXYZ(98.855415, -70.865875, 8.390983, 98.488884, -71.79569, 8.360713)
    PedSetActionNode(gPlayer, "/Global/4_06/NISs/Player/PlayerCornelius", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(gPlayer, "M_4_06", 23, "supersize")
    CameraSetXYZ(97.18688, -72.70781, 8.466475, 97.57633, -73.62578, 8.540709)
    PedSetActionNode(Objectives[5].id, "/Global/4_06/NISs/Nerds/Cornelius/Cornelius02", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(Objectives[5].id, "M_4_06", 24, "supersize")
    CameraSetXYZ(98.855415, -70.865875, 8.390983, 98.488884, -71.79569, 8.360713)
    PedSetActionNode(gPlayer, "/Global/4_06/NISs/Player/PlayerCornelius02", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(gPlayer, "M_4_06", 25, "supersize")
    CameraSetXYZ(95.59912, -72.31499, 8.497162, 96.34237, -72.977295, 8.402911)
    PedSetActionNode(Objectives[5].id, "/Global/4_06/NISs/Nerds/Cornelius/Cornelius03", "Act/Conv/4_06.act")
    F_PlaySpeechAndWait(Objectives[5].id, "M_4_06", 26, "supersize")
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    SoundPlayInteractiveStream("MS_MisbehavingHigh.rsm", 0.5, 0, 250)
    CameraReturnToPlayer(true)
    PAnimRequest(TRIGGER._4_06_HACK_SWITCH)
    PedRequestModel(180)
    PedRequestModel(14)
    PedRequestModel(182)
    PedRequestModel(232)
    PedRequestModel(109)
    PedRequestModel(111)
    PedRequestModel(231)
    PedRequestModel(112)
    PedRequestModel(55)
    LoadModels({341}, true)
    PAnimCreate(TRIGGER._4_06_HACK_SWITCH)
    PedStop(gPlayer)
    PedIgnoreStimuli(Objectives[5].id, false)
    PedClearObjectives(gPlayer)
    AreaForceLoadAreaByAreaTransition(true)
    AreaTransitionPoint(0, Objectives[5].loc, 3, true)
    AreaForceLoadAreaByAreaTransition(false)
    CameraSetWidescreen(false)
    LoadActionTree("Act/Props/CtrlBx.act")
    CameraFade(-1, 1)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    PlayerLockButtonInputsExcept(false)
  elseif nisType == OUTRO then
  end
end
function F_OperationA()
  while bWaitingToTrigger do
    Wait(0)
  end
  F_OPA_NIS(INTRO)
  Wait(3000)
  PedSetMissionCritical(Objectives[CurrentMissionNumber].id, false)
  PedMakeAmbient(Objectives[CurrentMissionNumber].id)
  PedWander(Objectives[CurrentMissionNumber].id, 0)
  bComplete_Operation = false
  while not bComplete_Operation do
    SportsDrink.blip = BlipAddPoint(POINTLIST._4_06_OBJECTIVE_A, 0)
    TextPrint("4_06_OPA_01", 4, 1)
    gObjsTable.opA_01 = MissionObjectiveAdd("4_06_OPA_01")
    while AreaGetVisible() ~= 13 do
      if bOutOfBoundsFail then
        break
      end
      Wait(0)
    end
    if bOutOfBoundsFail then
      break
    end
    MissionObjectiveComplete(gObjsTable.opA_01)
    gObjsTable.opA_02 = MissionObjectiveAdd("4_06_OPA_02")
    gInsidePool = true
    coolerIndex, coolerEntity = CreatePersistentEntity("PCaf_GatCooler", -642.028, -57.5198, 55.515, 0, 13)
    NonMissionPedGenerationDisable()
    if bMissionIsActive and CurrentMissionNumber == 1 then
      F_CreateMissionSpecPeds(1)
      while not PlayerIsInTrigger(TRIGGER._4_06_GATOBJECTIVE) do
        if bOutOfBoundsFail then
          break
        end
        Wait(0)
      end
    end
    if bOutOfBoundsFail then
      break
    end
    if SportsDrink.blip then
      BlipRemove(SportsDrink.blip)
    end
    x1, y1, z1 = GetPointList(POINTLIST._4_06_OBJECTIVE_A)
    SportsDrink.blip = BlipAddXYZ(x1, y1, z1, 0, 1, 7)
    LacedDrink = false
    while not LacedDrink do
      if PlayerIsInAreaXYZ(x1, y1, z1, 1, 0) then
        if SportsDrink.blip then
          BlipRemove(SportsDrink.blip)
          SportsDrink.blip = nil
        end
        if not gPlayerFlagrant then
          gPlayerFlagrant = true
        end
        if not LacedDrink and PAnimIsPlaying(TRIGGER._4_06_COOLER, "/Global/GatClr/NotUseable", true) then
          LacedDrink = true
          peeIndex, peeEntity = CreatePersistentEntity("PCafGat_piss", -641.912, -57.7193, 55.4563, 0, 13)
        end
      elseif not SportsDrink.blip then
        SportsDrink.blip = BlipAddXYZ(x1, y1, z1, 0, 1, 7)
      end
      if bOutOfBoundsFail then
        break
      end
      Wait(0)
    end
    MissionObjectiveComplete(gObjsTable.opA_02)
    if SportsDrink.blip then
      BlipRemove(SportsDrink.blip)
      SportsDrink.blip = nil
    end
    Wait(2000)
    TextPrint("4_06_OPA_05", 4, 1)
    gObjsTable.opA_03 = MissionObjectiveAdd("4_06_OPA_05")
    ExitBlip = BlipAddPoint(POINTLIST._4_06_DOSSIER_A, 0, 1)
	local waiting = true
    AreaSetDoorLocked(TRIGGER._DT_POOL_DOORL, true)
    AreaSetDoorLocked(TRIGGER._DT_GYM_DOORL, true)
    while waiting do
        if PlayerIsInAreaXYZ(-622.796, -74.4177, 59.6111, 1, 7) or PlayerIsInAreaXYZ(-672.281, -77.3737, 59.6111, 1, 7) then
          waiting = nil
        end
        Wait(0)
    end
    F_OPA_NIS(OUTRO)
    AreaSetDoorLocked(TRIGGER._DT_POOL_DOORL, false)
    AreaSetDoorLocked(TRIGGER._DT_GYM_DOORL, false)
    AreaTransitionPoint(0, POINTLIST._4_06_OPAOUTSIDE)
    while AreaGetVisible() ~= 0 do
      if gPlayerFlagrant and not PlayerIsInAreaXYZ(x1, y1, z1, 3, 0) then
          gPlayerFlagrant = false
      elseif not gPlayerFlagrant and PlayerIsInAreaXYZ(x1, y1, z1, 3, 0) then
        gPlayerFlagrant = true
      end
      if bOutOfBoundsFail then
        break
      end
      Wait(0)
    end
    MissionObjectiveComplete(gObjsTable.opA_03)
    gInsidePool = false
    NonMissionPedGenerationEnable()
    BlipRemove(ExitBlip)
    bComplete_Operation = true
    bMissionIsActive = false
    gPlayerFlagrant = false
    shared.g4_06OpAcomplete = true
    Objectives[CurrentMissionNumber].complete = shared.g4_06OpAcomplete
    MissionObjectiveRemove(gObjsTable.opA_01)
    MissionObjectiveRemove(gObjsTable.opA_02)
    MissionObjectiveRemove(gObjsTable.opA_03)
    F_NextOpPrint(1)
    Wait(0)
  end
end
function F_OperationC()
  while bWaitingToTrigger do
    Wait(0)
  end
  F_OPC_NIS(INTRO)
  TextPrint("4_06_OPC_06", 5, 1)
  PedSetActionNode(Objectives[CurrentMissionNumber].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
  PedSetMissionCritical(Objectives[CurrentMissionNumber].id, false)
  PedMakeAmbient(Objectives[CurrentMissionNumber].id)
  PedWander(Objectives[CurrentMissionNumber].id, 0)
  PlayerSetWeapon(400, 1)
  gPlayerHasBall = true
  GameBallblip = BlipAddPoint(POINTLIST._4_06_OBJECTIVE_C, 0, 1)
  F_FieldDelete()
  FieldLoaded = false
  F_ZoomRadar()
  PlayerSetControl(1)
  Frisbee.id = PickupCreatePoint(335, POINTLIST._4_06_OBJECTIVE_C, 4, 0, "PermanentMission")
  bComplete_Operation = false
  gObjsTable.opC_01 = MissionObjectiveAdd("4_06_OPC_01")
  PAnimSetActionNode(TRIGGER._4_06_DUFFLE_BAG, "/Global/DuffBag/NotUseable", "Act/Props/DuffBag.act")
  while not bComplete_Operation do
    F_PlantRiggedBall()
    if bOutOfBoundsFail then
      break
    end
    bMissionIsActive = false
    shared.g4_06OpCcomplete = true
    Objectives[CurrentMissionNumber].complete = true
    MissionObjectiveRemove(gObjsTable.opC_01)
    bComplete_Operation = true
    F_NextOpPrint(0)
    Wait(0)
  end
end
function F_OperationD()
  while bWaitingToTrigger do
    Wait(0)
  end
  F_OPD_NIS(INTRO)
  PedSetActionNode(Objectives[CurrentMissionNumber].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
  PedSetMissionCritical(Objectives[CurrentMissionNumber].id, false)
  PedMakeAmbient(Objectives[CurrentMissionNumber].id)
  PedWander(Objectives[CurrentMissionNumber].id, 0)
  bComplete_Operation = false
  FieldLoaded = false
  TextPrint("4_06_OP_D_01", 4, 1)
  gObjsTable.opD_01 = MissionObjectiveAdd("4_06_OP_D_01")
  while not bComplete_Operation do
    if bOutOfBoundsFail then
      break
    end
    FieldBlip = BlipAddPoint(POINTLIST._4_06_OBJECTIVE_E, 0, 1)
    x1, y1, z1 = GetPointFromPointList(POINTLIST._4_06_OBJECTIVE_E, 1)
    while not PlayerIsInAreaXYZ(x1, y1, z1, 50, 7) do
      Wait(0)
    end
    F_ZoomRadar()
    BlipRemove(FieldBlip)
    for i, bench in Benches, nil, nil do
      Benches[i].blip = BlipAddPoint(Benches[i].loc, 0, i, 1, 7, 0, 0.5)
    end
    F_GlueIt()
    if bOutOfBoundsFail then
      break
    end
    bComplete_Operation = true
    bMissionIsActive = false
    shared.g4_06OpDcomplete = true
    Objectives[CurrentMissionNumber].complete = true
    MissionObjectiveRemove(gObjsTable.opD_01)
    F_NextOpPrint(0)
    Wait(0)
  end
end
function F_OperationE()
  while bWaitingToTrigger do
    Wait(0)
  end
  F_OPE_NIS(INTRO)
  PedSetActionNode(Objectives[CurrentMissionNumber].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
  PedSetWeapon(gPlayer, 349, 5)
  PedSetMissionCritical(Objectives[CurrentMissionNumber].id, false)
  PedMakeAmbient(Objectives[CurrentMissionNumber].id)
  PedWander(Objectives[CurrentMissionNumber].id, 0)
  bComplete_Operation = false
  FieldBlip = BlipAddPoint(POINTLIST._4_06_OBJECTIVE_E, 0, 1)
  TextPrint("4_06_OP_E_01", 4, 1)
  gObjsTable.opE_01 = MissionObjectiveAdd("4_06_OP_E_01")
  while not bComplete_Operation do
    x1, y1, z1 = GetPointFromPointList(POINTLIST._4_06_OBJECTIVE_E, 1)
    while not PlayerIsInAreaXYZ(x1, y1, z1, 50, 7) do
      F_GetMoreMarbles()
      if bOutOfBoundsFail then
        break
      end
      Wait(0)
    end
    F_ZoomRadar()
    BlipRemove(FieldBlip)
    F_TackIt()
    if bOutOfBoundsFail then
      break
    end
    bMissionIsActive = false
    MissionObjectiveRemove(gObjsTable.opE_01)
    if marbleObjective then
      MissionObjectiveRemove(gObjsTable.opE_02)
      marbleObjective = nil
    end
    if not (gLostJocks >= 2) then
      shared.g4_06OpEcomplete = true
      Objectives[CurrentMissionNumber].complete = true
      F_NextOpPrint(0)
    end
    bComplete_Operation = true
    Wait(0)
  end
end
function F_OperationF()
  bMissionIsActive = false
  x1, y1, z1 = GetPointList(Objectives[5].loc)
  CharID = PedCreatePoint(Objectives[5].model, Objectives[5].loc)
  Objectives[5].id = CharID
  x1, y1, z1 = GetPointList(Objectives[5].loc)
  PedSetMissionCritical(CharID, true)
  Objectives[5].blip = AddBlipForChar(CharID, 1, 17, 4)
  F_HookUpAgent(CharID)
  gObjsTable.opDos = MissionObjectiveAdd("4_06_NEXT_OP_2")
  WeatherSet(1)
  while not bMissionIsActive do
    if bOutOfBoundsFail then
      break
    end
    if PlayerIsInAreaXYZ(x1, y1, z1 + 1.5, 6.75, 0) then
      bWaitingToTrigger = true
      local bBail = false
      PedSetActionNode(Objectives[5].id, "/Global/4_06/4_06_WaitForJim/ScenGreetBoyAnim", "Act/Conv/4_06.act")
      while bWaitingToTrigger do
        if not PlayerIsInAreaXYZ(x1, y1, z1, 7, 0) then
          bWaitingToTrigger = false
          bBail = true
        end
        if PlayerIsInAreaXYZ(x1, y1, z1, 3, 0) then
          bWaitingToTrigger = false
        end
        Wait(0)
      end
      if not bBail then
        bMissionIsActive = true
        CurrentMissionNumber = 5
        MissionObjectiveRemove(gObjsTable.opDos)
        break
      else
        bMissionActive = false
      end
    end
    Wait(0)
  end
  F_OPF_NIS(INTRO)
  BlipRemove(Objectives[5].blip)
  Wait(4000)
  PedSetMissionCritical(Objectives[5].id, false)
  PedMakeAmbient(Objectives[5].id)
  PedWander(Objectives[5].id, 0)
  PAnimSetActionNode(TRIGGER._4_06_HACK_SWITCH, "/Global/CtrlBx/Useable", "Act/Props/CtrlBx.act")
  bComplete_Operation = false
  TextPrint("4_06_OP_F_01", 4, 1)
  gObjsTable.opF_01 = MissionObjectiveAdd("4_06_OP_F_01")
  while not bComplete_Operation do
    Scoreboard.blip = BlipAddPoint(Scoreboard.point, 0, 1)
    while not ScoreboardHacked do
      F_HackScoreboard()
      if bOutOfBoundsFail then
        break
      end
      Wait(0)
    end
    bMissionIsActive = false
    shared.g4_06OpFcomplete = true
    Objectives[5].complete = true
    MissionObjectiveRemove(gObjsTable.opF_01)
    Wait(0)
    bComplete_Operation = true
  end
end
function F_ZoomRadar()
  RadarSetMinMax(30, 60, 30)
end
function F_GlueIt()
  while not BenchesDone do
    if not madeThemWorkout and gEnemiesPerMission[3][1].id and PedIsValid(gEnemiesPerMission[3][1].id) then
      PedSetActionNode(gEnemiesPerMission[3][1].id, "/Global/4_06/Workout/Workout_Child", "Act/Conv/4_06.act")
      PedSetActionNode(gEnemiesPerMission[3][2].id, "/Global/4_06/Workout/Workout_Child", "Act/Conv/4_06.act")
      PedSetActionNode(gEnemiesPerMission[3][3].id, "/Global/4_06/Workout/Workout_Child", "Act/Conv/4_06.act")
      madeThemWorkout = true
    end
    if bOutOfBoundsFail then
      break
    end
    for i = 1, 4 do
      if not Benches[i].IsGlued then
        x1, y1, z1 = GetPointFromPointList(POINTLIST._4_06_OBJECTIVE_D, i)
        if PlayerIsInAreaXYZ(x1, y1, z1, 0.95, 0) then
          if Benches[i].blip then
            BlipRemove(Benches[i].blip)
            Benches[i].blip = nil
          end
          if PedIsPlaying(gPlayer, "/Global/GlueBench/PedPropsActions/Use", true) then
            gPlayerFlagrant = true
            while PedIsPlaying(gPlayer, "/Global/GlueBench/PedPropsActions/Use", true) do
              Wait(0)
            end
            gPlayerFlagrant = false
          end
        elseif not PedIsPlaying(gPlayer, "/Global/GlueBench/PedPropsActions/Use", false) and not Benches[i].blip then
          Benches[i].blip = BlipAddPoint(Benches[i].loc, 0, i, 1, 7, 0, 0.5)
        end
        if PAnimIsPlaying(Benches[i].trigger, "/Global/GlueBench/NotUseable", true) or PAnimIsPlaying(Benches[i].trigger2, "/Global/GlueBench/NotUseable", true) then
          if PAnimIsPlaying(Benches[i].trigger2, "/Global/GlueBench/NotUseable", true) then
            PAnimSetActionNode(Benches[i].trigger, "/Global/GlueBench/NotUseable/NoEffect", "Act/Prop/GlueBnch.act")
          elseif PAnimIsPlaying(Benches[i].trigger, "/Global/GlueBench/NotUseable", true) then
            PAnimSetActionNode(Benches[i].trigger2, "/Global/GlueBench/NotUseable/NoEffect", "Act/Prop/GlueBnch.act")
          end
          Benches[i].IsGlued = true
          PAnimMakeTargetable(Benches[i].trigger, false)
          PAnimMakeTargetable(Benches[i].trigger2, false)
          TextPrint("4_06_OP_D_05", 4, 1)
          if Benches[i].blip then
            BlipRemove(Benches[i].blip)
            Benches[i].blip = nil
          end
        end
      end
      if Benches[i].IsGlued then
        BenchTotal = BenchTotal + 1
      end
      if i == 4 and BenchTotal == 4 then
        F_OPD_NIS(OUTRO)
        MissionObjectiveComplete(gObjsTable.opD_01)
        BenchesDone = true
      elseif i == 4 and BenchTotal ~= 4 then
        BenchTotal = 0
      end
    end
    Wait(0)
  end
end
function F_PlantRiggedBall()
  x1, y1, z1 = GetPointFromPointList(POINTLIST._4_06_OBJECTIVE_C, 1)
  fx, fy, fz = PickupGetXYZ(Frisbee.id)
  local gRunnerId = PedCreatePoint(232, POINTLIST._4_06_BALL_GUARD, 2)
  PedIgnoreStimuli(gRunnerId, true)
  RiggedBallPlanted = false
  PAnimSetActionNode(TRIGGER._4_06_DUFFLE_BAG, "/Global/DuffBag/Useable", "Act/Props/DuffBag.act")
  Wait(1000)
  while not RiggedBallPlanted do
    if bOutOfBoundsFail then
      break
    end
    if not gPlayerNearDog and PlayerIsInAreaXYZ(x1, y1, z1, 18, 0) then
      if gRunnerId and PedIsValid(gRunnerId) then
        PedFollowPath(gRunnerId, PATH._4_06_DUFFELGUY, 0, 1)
        PedSetActionNode(gRunnerId, "/Global/4_06/GuardDog/Planting", "Act/Conv/4_06.act")
      end
      gPlayerNearDog = true
    elseif gPlayerNearDog and gRunnerId and PedIsValid(gRunnerId) and PedIsInAreaXYZ(gRunnerId, -21.8766, -16.5356, 2.55495, 1, 0) then
      PedDelete(gRunnerId)
      gRunnerId = nil
    end
    if gPlayerHasBall and not PlayerHasWeapon(400) and not PlayerIsInAreaXYZ(x1, y1, z1, 0.75, 0) then
      gPlayerHasBall = false
      TextPrint("4_06_OPC_04", 3, 1)
      gObjsTable.opC_03 = MissionObjectiveAdd("4_06_OPC_04")
      MissionTimerStart(6)
      gTimerIsOn = true
    elseif not gPlayerHasBall and PlayerHasWeapon(400) then
      MissionObjectiveRemove(gObjsTable.opC_03)
      gPlayerHasBall = true
      MissionTimerStop()
      gTimerIsOn = false
    end
    if gTimerIsOn and MissionTimerHasFinished() then
      MissionTimerStop()
      gFailingMessage = "4_06_OPC_03"
      bOutOfBoundsFail = true
      shared.forceCowDanceEnd = true
    end
    if gPlayerHasBall then
      if PAnimIsPlaying(TRIGGER._4_06_DUFFLE_BAG, "/Global/DuffBag/NotUseable", true) then
        PAnimSetActionNode(TRIGGER._4_06_DUFFLE_BAG, "/Global/DuffBag/Useable", "Act/Props/DuffBag.act")
      end
    elseif PAnimIsPlaying(TRIGGER._4_06_DUFFLE_BAG, "/Global/DuffBag/Useable", true) then
      PAnimSetActionNode(TRIGGER._4_06_DUFFLE_BAG, "/Global/DuffBag/NotUseable", "Act/Props/DuffBag.act")
    end
    if not gPlayerNearBag and PlayerIsInAreaXYZ(x1, y1, z1, 1.5, 0) then
      PlayerSetControl(0)
      CameraFade(500, 0)
      Wait(501)
      CameraSetWidescreen(true)
      gPlayerNearBag = true
      PedSetActionNode(gPlayer, "/Global/4_06/Break", "Act/Conv/4_06.act")
      PlayerSetPosSimple(-21.7, -24, 2)
      PlayerFaceHeadingNow(85.5)
      CameraSetFOV(40)
      CameraSetXYZ(-19.67809, -25.873928, 4.134796, -20.392143, -25.27204, 3.777333)
      PedDestroyWeapon(gPlayer, 400)
      PedSetActionNode(gPlayer, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
      Wait(250)
      CameraFade(-1, 1)
      Wait(500)
    end
    if gPlayerHasBall and PlayerIsInAreaXYZ(x1, y1, z1, 0.5, 7) then
      PedSetFlag(gPlayer, 21, false)
      if not RiggedBallPlanted and PAnimIsPlaying(TRIGGER._4_06_DUFFLE_BAG, "/Global/DuffBag/NotUseable", true) then
        PAnimSetActionNode(TRIGGER._4_06_DUFFLE_BAG, "/Global/DuffBag/Useable", "Act/Props/DuffBag.act")
      end
      if PedIsPlaying(gPlayer, "/Global/DuffBag/PedPropsActions/RummageInDuffel", true) then
        PedDestroyWeapon(gPlayer, 400)
        ObjectRemovePickupsInTrigger(TRIGGER._4_06_DUFFLE_BAG)
        PedSetFlag(gPlayer, 21, false)
        PickupDestroyTypeInAreaXYZ(x1, y1, z1, 3, 400)
        CameraSetWidescreen(true)
        bPlantingRiggedBall = true
        MissionObjectiveComplete(gObjsTable.opC_01)
        ObjectRemovePickupsInTrigger(TRIGGER._4_06_DUFFLE_BAG)
        while PedIsPlaying(gPlayer, "/Global/DuffBag/PedPropsActions/RummageInDuffel", true) do
          Wait(0)
        end
        RiggedBallPlanted = true
        BlipRemove(GameBallblip)
        CameraSetWidescreen(false)
        F_OPC_NIS(OUTRO)
        bPlantingRiggedBall = false
      end
    end
    Wait(0)
  end
  PedSetFlag(gPlayer, 21, true)
  PAnimSetActionNode(TRIGGER._4_06_DUFFLE_BAG, "/Global/DuffBag/NotUseable", "Act/Props/DuffBag.act")
  gPlayerFlagrant = false
end
function F_TackIt()
  gTackedJocks = 0
  gLostJocks = 0
  gMarblePath = "/Global/HitTree/Standing/Ranged/Bomb/Marbles"
  if not marbleObjective then
    fieldBlip01 = BlipAddPoint(POINTLIST._4_06_FIELDBLIPS, 0, 1, 1, 7)
    fieldBlip02 = BlipAddPoint(POINTLIST._4_06_FIELDBLIPS, 0, 2, 1, 7)
    fieldBlip03 = BlipAddPoint(POINTLIST._4_06_FIELDBLIPS, 0, 3, 1, 7)
    while not FieldTacked do
      if bOutOfBoundsFail then
        break
      end
      if not gMarblesTutorial and (PlayerIsInTrigger(TRIGGER._4_06_FIELD01) or PlayerIsInTrigger(TRIGGER._4_06_FIELD02) or PlayerIsInTrigger(TRIGGER._4_06_FIELD03)) then
        gMarblesTutorial = true
        TutorialShowMessage("TUT_MARBX1", 6000)
      end
      if not marblesField01 and 0 < ObjectTypeIsInTrigger(349, TRIGGER._4_06_FIELD01) then
        marblesField01 = true
        gTackedJocks = gTackedJocks + 1
        if fieldBlip01 then
          BlipRemove(fieldBlip01)
          fieldBlip01 = nil
        end
      end
      if not marblesField02 and 0 < ObjectTypeIsInTrigger(349, TRIGGER._4_06_FIELD02) then
        marblesField02 = true
        gTackedJocks = gTackedJocks + 1
        if fieldBlip02 then
          BlipRemove(fieldBlip02)
          fieldBlip02 = nil
        end
      end
      if not marblesField03 and 0 < ObjectTypeIsInTrigger(349, TRIGGER._4_06_FIELD03) then
        marblesField03 = true
        gTackedJocks = gTackedJocks + 1
        if fieldBlip03 then
          BlipRemove(fieldBlip03)
          fieldBlip03 = nil
        end
      end
      if gTackedJocks >= 3 then
        FieldTacked = true
        if gMarblesBlip then
          MissionObjectiveComplete(gObjsTable.opE_01)
          BlipRemove(gMarblesBlip)
          gMarblesBlip = nil
        end
        F_OPE_NIS(OUTRO)
      else
        F_GetMoreMarbles(true)
      end
      Wait(0)
    end
  end
end
function F_GetMoreMarbles(param)
  if not gOutOfMarbles and PedGetAmmoCount(gPlayer, 349) <= 0 then
    if not gMarbleTimer then
      gMarbleTimer = GetTimer()
    elseif GetTimer() - gMarbleTimer > 2000 and gTackedJocks < 3 then
      gMarbleTimer = nil
      TextPrint("4_06_OP_E_10", 4, 1)
      gObjsTable.opE_02 = MissionObjectiveAdd("4_06_OP_E_10")
      marbleObjective = true
      gOutOfMarbles = PickupCreatePoint(349, POINTLIST._4_06_DOSSIER_D, 1, 0, "PermanentMission")
      gMarblesBlip = BlipAddPoint(POINTLIST._4_06_DOSSIER_D, 0)
      mrx, mry, mrz = GetPointList(POINTLIST._4_06_DOSSIER_D)
      if param then
        if fieldBlip01 then
          BlipRemove(fieldBlip01)
          fieldBlip01 = true
        end
        if fieldBlip02 then
          BlipRemove(fieldBlip02)
          fieldBlip02 = true
        end
        if fieldBlip03 then
          BlipRemove(fieldBlip03)
          fieldBlip03 = true
        end
      elseif FieldBlip then
        BlipRemove(FieldBlip)
        fieldBlip01 = true
        fieldBlip02 = true
        fieldBlip03 = true
      end
    end
  elseif gOutOfMarbles and (PlayerIsInAreaXYZ(mrx, mry, mrz, 1, 0) or PedGetAmmoCount(gPlayer, 349) > 0) then
    if not PlayerIsInAreaXYZ(mrx, mry, mrz, 1, 0) and not PickupIsPickedUp(gOutOfMarbles) then
      PickupDelete(gOutOfMarbles)
    end
    MissionObjectiveRemove(gObjsTable.opE_02)
    marbleObjective = nil
    gOutOfMarbles = nil
    if param then
      if fieldBlip01 then
        fieldBlip01 = BlipAddPoint(POINTLIST._4_06_FIELDBLIPS, 0, 1, 1, 7)
      end
      if fieldBlip02 then
        fieldBlip02 = BlipAddPoint(POINTLIST._4_06_FIELDBLIPS, 0, 2, 1, 7)
      end
      if fieldBlip03 then
        fieldBlip03 = BlipAddPoint(POINTLIST._4_06_FIELDBLIPS, 0, 3, 1, 7)
      end
    else
      TextPrint("4_06_OP_E_01", 4, 1)
      FieldBlip = BlipAddPoint(POINTLIST._4_06_OBJECTIVE_E, 0, 1)
    end
    BlipRemove(gMarblesBlip)
    Wait(500)
    PedSetWeapon(gPlayer, 349, 5)
    gMarblesBlip = nil
  end
end
function F_TackedJockDown(ped)
  local ran = math.random(1, 2)
  if ran == 1 then
    play = "/Global/4_06/4_06_MarbledL"
  else
    play = "/Global/4_06/4_06_MarbledR"
  end
  PedSetActionNode(ped, play, "Act/Conv/4_06.act")
end
local bCoachDistracted = true
function F_HackScoreboard()
  x1, y1, z1 = GetPointList(POINTLIST._4_06_OBJECTIVE_F)
  while not bCoachDistracted do
    Wait(0)
  end
  while not ScoreboardHacked and bCoachDistracted do
    if bOutOfBoundsFail then
      break
    end
    if PlayerIsInAreaXYZ(x1, y1, z1, 1, 7) then
      if not ScoreboardHacked then
      end
      if PAnimIsPlaying(TRIGGER._4_06_HACK_SWITCH, "/Global/CtrlBx/NotUseable", false) then
        ScoreboardHacked = true
        bFieldOpOver = true
      end
    elseif not gPlayerFlagrant or not PlayerIsInAreaXYZ(x1, y1, z1, 1, 7) then
    end
    Wait(0)
  end
  gPlayerFlagrant = false
  PlayerSetControl(0)
  SoundSetAudioFocusCamera()
  F_MakePlayerSafeForNIS(true)
  BlipRemove(Scoreboard.blip)
  SoundPlayStream("MS_Misbehaving_NISPrankSucess.rsm", 0.5, 250, 250)
  SoundLoopPlay2D("PanelLoop", true)
  CameraSetWidescreen(true)
  CameraLookAtXYZ(-52.7216, -73.6623, 6.2646, false)
  CameraSetPath(PATH._4_06_SCOREBOARD_PATH, false)
  CameraSetSpeed(12.7, 12.7, 12.7)
  Wait(4000)
  DeletePersistentEntity(boardGood01, boardGood02)
  boardBad01, boardBad02 = CreatePersistentEntity("SC_JocksLEDbad", -53.1448, -73.6493, 6.34204, 0, 0)
  Wait(4000)
  F_MakePlayerSafeForNIS(false)
  SoundLoopPlay2D("PanelLoop", false)
  PlayerSetControl(1)
  SoundSetAudioFocusPlayer()
end
function F_NextOpPrint(val)
  F_CheckAllMissions()
  if shared.g4_06OpAcomplete and shared.g4_06OpCcomplete and shared.g4_06OpDcomplete and shared.g4_06OpEcomplete then
    TextPrint("4_06_NEXT_OP_2", 4, 1)
  elseif TotalMissionsComplete < 3 then
    TextPrint("4_06_NEXT_OP", 5, 1)
  else
    TextPrint("4_06_NEXT_OP3", 5, 1)
  end
end
function F_Init_Dossiers()
  RadarRestoreMinMax()
  for i = 1, 4 do
    if Objectives[i].complete == false then
      CharID = PedCreatePoint(Objectives[i].model, Objectives[i].loc)
      Objectives[i].id = CharID
      x1, y1, z1 = GetPointList(Objectives[i].loc)
      PedSetMissionCritical(CharID, true, CbPlayerAggressed, true)
      Objectives[i].blip = AddBlipForChar(CharID, 1, 17, 4)
      F_HookUpAgent(CharID)
    end
  end
  gObjsTable.opDos = MissionObjectiveAdd("4_06_NEXT_OP")
end
function F_WaitForChoice()
  while not bMissionIsActive do
    if AreaGetVisible() ~= 0 then
      F_StripDossiers()
    end
    if AllDone then
      break
    end
    for i = 1, 4 do
      if Objectives[i].complete == false then
        x1, y1, z1 = PedGetHeadPos(Objectives[i].id)
        x1, y1, z = GetPointFromPointList(Objectives[i].loc, 2)
        if PlayerIsInAreaXYZ(x1, y1, z1, 6, 0) then
          bWaitingToTrigger = true
		  local bBail = false
          PedSetActionNode(Objectives[i].id, "/Global/4_06/4_06_WaitForJim/ScenGreetBoyAnim", "Act/Conv/4_06.act")
          while bWaitingToTrigger do
            if not PlayerIsInAreaXYZ(x1, y1, z1, 7, 0) then
              bWaitingToTrigger = false
            end
            if PlayerIsInAreaXYZ(x1, y1, z1, 2, 0) then
              bWaitingToTrigger = false
            end
            Wait(0)
          end
          if not bBail then
            bMissionIsActive = true
            CurrentMission = Objectives[i].func
            CurrentMissionNumber = i
            MissionObjectiveRemove(gObjsTable.opDos)
            break
          else
            bMissionActive = false
          end
        end
      end
    end
    if bOutOfBoundsFail then
      break
    end
    Wait(0)
  end
end
function F_CleanNonActiveMissions()
  for i = 1, 4 do
    if Objectives[i].complete == false then
      if i ~= CurrentMissionNumber and PedIsValid(Objectives[i].id) then
        PedSetMissionCritical(Objectives[i].id, false)
        PedMakeAmbient(Objectives[i].id)
      end
      BlipRemove(Objectives[i].blip)
    end
  end
end
function F_CheckAllMissions()
  TotalMissionsComplete = 0
  for i = 1, 4 do
    if Objectives[i].complete then
      TotalMissionsComplete = TotalMissionsComplete + 1
    end
  end
  if TotalMissionsComplete == 4 then
    AllDone = true
    bMissionIsActive = true
  end
end
function F_StripDossiers()
  F_CleanNonActiveMissions()
  while AreaGetVisible() ~= 0 do
    Wait(0)
  end
  F_Init_Dossiers()
  return
end
function F_ChooseYourOwnAdventure()
  while not AllDone do
    F_CheckAllMissions()
    F_Init_Dossiers()
    F_WaitForChoice()
    if bOutOfBoundsFail then
      break
    end
    F_CleanNonActiveMissions()
    if not AllDone then
      CurrentMission()
    end
    if bOutOfBoundsFail then
      break
    end
    F_CheckAllMissions()
    Wait(0)
  end
end
function F_FieldDelete()
  if CoachBurton.id and PedIsValid(CoachBurton.id) then
    PedDelete(CoachBurton.id)
    CoachBurton.id = nil
  end
  for i, missionTable in gEnemiesPerMission, nil, nil do
    for j, enemy in missionTable, nil, nil do
      if PedIsValid(enemy.id) then
        PedMakeAmbient(enemy.id)
        PedSetIsStealthMissionPed(enemy.id, false)
        enemy.id = nil
      end
    end
  end
end
function F_CreateMissionSpecPeds(mNo)
  for i, tableEntry in gEnemiesPerMission[mNo], nil, nil do
    if not tableEntry.distracted and not tableEntry.id then
      tableEntry.id = PedCreatePoint(tableEntry.model, tableEntry.point, tableEntry.pvalue)
      PedSetIsStealthMissionPed(tableEntry.id, true)
      PedSetStealthBehavior(tableEntry.id, 0, CbSeePlayer)
      PedSetFaction(tableEntry.id, 2)
      PedOverrideStat(tableEntry.id, 2, 100)
      PedOverrideStat(tableEntry.id, 3, 15)
      PedClearAllWeapons(tableEntry.id)
      if tableEntry.path then
        if tableEntry.path == "CHEER" then
          PedSetActionNode(tableEntry.id, "/Global/Ambient/Scripted/Cheerleading", "Act/Anim/Ambient.act")
        elseif tableEntry.path == "WORKOUT" then
          PedSetActionNode(tableEntry.id, "/Global/4_06/Workout/Workout_Child", "Act/Conv/4_06.act")
        else
          PedFollowPath(tableEntry.id, tableEntry.path, 1, 1)
        end
      end
    end
  end
end
function CbGateNerdPath(pedId, pathId, pathNode)
  if pathNode == 2 then
    gateNerdFinished = true
  end
end
function F_PlayerIsDancing()
  if PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/CustomIdle", true) or PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/CustomIdleX", true) or PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/CustomIdleC", true) or PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/CustomIdleS", true) or PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/CustomIdleO", true) or PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/Circle", true) or PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/Cross", true) or PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/Square", true) or PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/Animation/Triangle", true) then
    return true
  end
  return false
end
function F_FieldSpawn()
  if bMissionIsActive then
    if CurrentMissionNumber == 2 then
      bDagSeesYou = false
      F_CreateMissionSpecPeds(2)
    elseif CurrentMissionNumber == 3 then
      F_CreateMissionSpecPeds(3)
    elseif CurrentMissionNumber == 4 then
      F_CreateMissionSpecPeds(4)
    elseif CurrentMissionNumber == 5 then
      if not CoachBurton.id then
        CoachBurton.id = PedCreatePoint(CoachBurton.model, CoachBurton.point)
        PedSetIsStealthMissionPed(CoachBurton.id, true)
        PedSetStealthBehavior(CoachBurton.id, 0, CbBurtonSteath)
      end
      F_CreateMissionSpecPeds(5)
    end
  end
  if CurrentMissionNumber ~= 5 then
    F_CreateMissionSpecPeds(6)
  end
end
local bJustLeft = true
function F_OutOfBound(triggerId, charId)
  if bJustLeft then
    bJustLeft = false
    TextPrint("4_06_OUTOFBOUNDS", 4, 1)
    MissionTimerStart(10)
  elseif not bJustLeft then
  end
end
function F_BackInBound(triggerId, charId)
  if not bJustLeft then
    bJustLeft = true
    MissionTimerStop()
  end
end
function T_DeletePeds()
  while not bFieldOpOver do
    if table.getn(gInsidePoint) > 0 then
      for i, entity in gInsidePoint, nil, nil do
        if entity and PedIsValid(entity) and PedIsInTrigger(entity, TRIGGER._4_06_INSIDEDOCKINGTRIGGER) then
          PedDelete(entity)
          gInsidePoint[nil] = false
        end
      end
    end
    if table.getn(gOutsidePoint) > 0 then
      for i, entity in gOutsidePoint, nil, nil do
        if entity and PedIsValid(entity) and PedIsInTrigger(entity, TRIGGER._4_06_DOCKINGTRIGGER) then
          PedDelete(entity)
          gOutsidePoint[nil] = false
        end
      end
    end
    Wait(500)
  end
end
function MissionOver()
  gMissionOverCalled = true
  if not bOutOfBoundsFail then
    Wait(4000)
  end
  Wait(3000)
  shared.forceCowDanceEnd = true
  SoundPlayMissionEndMusic(false, 10)
  if gFailingMessage then
    MissionFail(true, true, gFailingMessage)
  else
    MissionFail()
  end
end
function F_HookUpAgent(charID)
  PedSetEmotionTowardsPed(charID, gPlayer, 7)
  PedUseSocialOverride(v, 18)
  PedOverrideSocialResponseToStimulus(charID, 10, 18)
  F_Socialize(charID, true)
  PedClearAllWeapons(charID)
end
function CbBurtonSteath(pedId)
  if gBurtonSpeakTimer and GetTimer() - gBurtonSpeakTimer > BURTONSPEAKTIME then
    gSpoken = false
    gBurtonSpeakTimer = false
  end
  if not gSpoken then
    SoundPlayScriptedSpeechEvent(pedId, "M_4_06", 42, "supersize")
    gSpoken = true
    gBurtonSpeakTimer = GetTimer()
  end
end
function CbPlayerAggressed()
  bOutOfBoundsFail = true
  gFailingMessage = "4_06_AGRSV"
end
function CbSeePlayer(pedId)
  PedStop(pedId)
  PedClearObjectives(pedId)
  PedSetIsStealthMissionPed(pedId, false)
  if PedHasPOI(pedId) then
    PedClearPOI(pedId)
  end
  PedSetActionNode(pedId, "/Global/4_06/Break", "Act/Conv/4_06.act")
  if bMissionIsActive then
    for i, tableEntry in gEnemiesPerMission[CurrentMissionNumber], nil, nil do
      if not tableEntry.distracted and PedIsValid(tableEntry.id) and tableEntry.id == pedId then
        tableEntry.timeSeen = GetTimer()
        F_InsertIntoTable(CurrentMissionNumber, gMonitoringTable)
        F_InsertIntoTable(i, gMonitoringTableA)
        F_FacePlayerPerGroup(CurrentMissionNumber, tableEntry.group)
        TutorialShowMessage("4_06_OBJDANCE", 5000)
        F_InsertIntoTable(pedId, gFlagrantChecks)
        if tableEntry.speech then
          SoundPlayScriptedSpeechEvent(tableEntry.id, "M_4_06", gSpeechTable[tableEntry.speech].seePlayer, "supersize")
        end
      end
    end
  end
  for i, tableEntry in gEnemiesPerMission[6], nil, nil do
    if not tableEntry.distracted and PedIsValid(tableEntry.id) and tableEntry.id == pedId then
      tableEntry.timeSeen = GetTimer()
      F_InsertIntoTable(6, gMonitoringTable)
      F_InsertIntoTable(i, gMonitoringTableA)
      F_InsertIntoTable(pedId, gFlagrantChecks)
      F_FacePlayerPerGroup(6, tableEntry.group)
      TutorialShowMessage("4_06_OBJDANCE", 5000)
      if not tableEntry.distracted and tableEntry.speech then
        SoundPlayScriptedSpeechEvent(tableEntry.id, "M_4_06", gSpeechTable[tableEntry.speech].seePlayer, "supersize")
      end
    end
  end
end
function F_FacePlayerPerGroup(missionNo, groupNo)
  for i, tableEntry in gEnemiesPerMission[missionNo], nil, nil do
    if PedIsValid(tableEntry.id) and tableEntry.group == groupNo then
      PedStop(tableEntry.id)
      PedClearObjectives(tableEntry.id)
      PedFaceObject(tableEntry.id, gPlayer, 3, 1)
    end
  end
end
function F_AttackAndForget(pedId)
  PedSetIsStealthMissionPed(pedId, false)
  PedStop(pedId)
  PedClearObjectives(pedId)
  Wait(10)
  PedAttackPlayer(pedId, 0)
end
function T_CheckToAttack()
  while not bFieldOpOver do
    if gPlayerFlagrant then
      for i, enemy in gFlagrantChecks, nil, nil do
        if enemy then
          if PedIsValid(enemy) then
            if PedCanSeeObject(enemy, gPlayer, 3) then
              if gInsidePool then
                SoundPlayAmbientSpeechEvent(enemy, "DISGUST")
              else
                SoundPlayAmbientSpeechEvent(enemy, "FIGHT_INITIATE")
              end
              F_AttackAndForget(enemy)
              gFlagrantChecks[i] = false
            end
          else
            gFlagrantChecks[i] = false
          end
        end
      end
    end
    Wait(10)
  end
end
local currentPed
local checkTime = 0
function T_FieldOps()
  local fcX, fcY, fcZ = GetPointList(POINTLIST._4_06_INITIAL_GUARDS)
  local tableAindex = 0
  local playerStimulus, stimtype = 0, 0
  while not bFieldOpOver do
    if not gBurtonChased and gPedsFled and PedIsValid(CoachBurton.id) and GetTimer() - gPedsFled > 4000 then
      PedSetIsStealthMissionPed(CoachBurton.id, false)
      PedIgnoreStimuli(CoachBurton.id, true)
      PedStop(CoachBurton.id)
      PedClearObjectives(CoachBurton.id)
      PedSetActionNode(CoachBurton.id, "/Global/4_06/Break", "Act/Conv/4_06.act")
      SoundPlayScriptedSpeechEvent(CoachBurton.id, "M_4_06", 30, "supersize")
      Wait(10)
      PedMoveToPoint(CoachBurton.id, 1, POINTLIST._4_06_INSIDEDOCKINGPOINT)
      F_InsertIntoTable(CoachBurton.id, gOutsidePoint)
      gBurtonChased = true
    end
    checkTime = GetTimer()
    for i, entity in gMonitoringTable, nil, nil do
      if entity then
        tableAindex = gMonitoringTableA[i]
        currentPed = gEnemiesPerMission[entity][tableAindex]
        if PedIsValid(currentPed.id) then
          if not currentPed.attack and checkTime - currentPed.timeSeen > ATTACK_TIME then
            if PedIsDoingTask(currentPed.id, "/Global/AI/Reactions/Stimuli/CowDance", true) or F_PlayerIsDancing() then
              currentPed.timeSeen = GetTimer()
            elseif not currentPed.distracted then
              currentPed.attack = true
              PedAttackPlayer(currentPed.id, 0)
              if currentPed.speech then
                SoundPlayScriptedSpeechEvent(currentPed.id, "M_4_06", gSpeechTable[currentPed.speech].badDance, "supersize")
              end
            end
          end
          playerStimulus, stimtype = PedHasGeneratedStimulusOfType(gPlayer, 24)
          if PedIsDoingTask(currentPed.id, "/Global/AI/Reactions/Stimuli/CowDanceSuccess", true) or PedHasGeneratedStimulusOfType(gPlayer, 24) then
            PedClearObjectives(currentPed.id)
            PedStop(currentPed.id)
            PedIgnoreStimuli(currentPed.id, true)
            if currentPed.speech then
              SoundPlayScriptedSpeechEvent(currentPed.id, "M_4_06", gSpeechTable[currentPed.speech].goodDance, "supersize")
            end
            gEnemiesPerMission[entity][tableAindex].distracted = true
            if gInsidePool then
              PedMoveToPoint(currentPed.id, 1, POINTLIST._4_06_INSIDEDOCKINGPOINT)
              F_InsertIntoTable(currentPed.id, gInsidePoint)
            else
              if CurrentMissionNumber == 5 and (currentPed.group == 3 or currentPed.group == 2) then
                gPedsFled = GetTimer()
              end
              PedMoveToPoint(currentPed.id, 1, POINTLIST._4_06_DOCKINGPOINT)
              F_InsertIntoTable(currentPed.id, gOutsidePoint)
            end
            gMonitoringTable[i] = false
            gMonitoringTableA[i] = false
          elseif PedIsDoingTask(currentPed.id, "/Global/AI/Reactions/Stimuli/CowDanceFail", true) and currentPed.speech then
            SoundPlayScriptedSpeechEvent(currentPed.id, "M_4_06", gSpeechTable[currentPed.speech].badDance, "supersize")
          end
        end
      end
    end
    if PlayerIsInTrigger(TRIGGER._4_06_LOAD_FIELD) and not FieldLoaded then
      DisablePOI(true, true)
      AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
      F_FieldSpawn()
      FieldLoaded = true
    elseif not PlayerIsInTrigger(TRIGGER._4_06_LOAD_FIELD) and FieldLoaded then
      EnablePOI(true, true)
      AreaRevertToDefaultPopulation()
      if not bMissionIsActive then
        F_FieldDelete()
      end
      FieldLoaded = false
    end
    if not bJustLeft and MissionTimerHasFinished() then
      gFailingMessage = "4_06_LEFT"
      bOutOfBoundsFail = true
    end
    Wait(0)
  end
end
function F_InsertIntoTable(item, table)
  for i, val in table, nil, nil do
    if not val then
      table[i] = item
      break
    end
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
function F_PlayerDismountBikeBG()
  pBike = false
  if PlayerIsInAnyVehicle() then
    pBike = PlayerGetLastBikeId()
    PedSetTaskNode(gPlayer, "/Global/PlayerAI/Objectives/ComeToStopInVehicle/Brake", "Act/PlayerAI.act")
    Wait(1400)
    PedSetTaskNode(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
    PlayerDismountBike()
  end
  if PlayerIsInAnyVehicle() then
    Wait(1000)
  end
  if PlayerIsInAnyVehicle() then
    Wait(1000)
  end
  if PlayerIsInAnyVehicle() then
    Wait(1000)
  end
  if PlayerIsInAnyVehicle() then
    Wait(1000)
  end
  if PlayerIsInAnyVehicle() then
    Wait(1000)
  end
  if PlayerIsInAnyVehicle() then
    PlayerDetachFromVehicle()
  end
  return pBike
end
function F_DeleteAllBikes(pBike, point, element)
  local x, y, z = PlayerGetPosXYZ()
  if pBike then
    VehicleSetPosPoint(pBike, point, element)
  end
  bikes = VehicleFindInAreaXYZ(x, y, z, 10, false)
  if not bikes then
    return
  end
  for _, bike in bikes, nil, nil do
    if bike ~= pBike then
      VehicleDelete(bike)
    end
  end
end
