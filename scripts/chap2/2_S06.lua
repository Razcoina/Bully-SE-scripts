--[[ Changes to this file:
	* Modified function MissionCleanup, may require testing
]]

local bDebugFlag = false
local gDebugLevel = 3
local bLoop = true
local bMissionPassed = false
local bMissionFailed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bLoadSchool = false
local bGirlBEvent = false
local gPantiesCollected = 0
local bPantiesBPickedUp = false
local bPantiesCPickedUp = false
local bPantiesDPickedUp = false
local bPantiesEPickedUp = false
local bPantiesFPickedUp = false
local bLaunchedStage2Trigger01 = false
local bLaunchedStage2Trigger02 = false
local bLaunchedStage2Trigger03 = false
local bShowerDialogue = false
local tableSprinklerNames
local tableSprinklerNames = {}
local bTutLattice = false
local bMakeGirlsStudy = false
local bBustPlayer = false
local bShowerEffectLoaded = false
local bJockBusted = false
local bCleanupBurton = false
local bCleanupBustedJock = false
local bCleanupBustedPref = false
local bRouteJimmyOutro = false
local bRouteBurtonOutro = false
local bSprinklersLoaded = false
local bBeatriceHitAlarm = false
local bUpdateStage3Objectives = false
local bAll5PantiesCollected = false
local bLockedStorageRoom = false
local bPlayerEjected = false
local bGirlBSetForEjected = false
local bGirlCSetForEjected = false
local bLockTheStorageRoom = false
local bPinkyStudying = false
local bBurtonReceivedPanties = false
local timerShowerTalk = 0
local bShowerTalkGirlFlag = false
local bEuniceSawJimmy = false
local bDeleteEunice = false
local bShowerChat = false
local bStage3TeacherSpawned = false
local bMandySpeak = false
local bFrontGirlsFacingDoor = true
local gTimerFireAlarm = 0
local bMonitorStage2Girls = false
local gLastPantyPickedUp = 0
local bSkipFirstCutscene = false
local bStartedAlarm = false
local gMissionFailMessage = 0
local bSpookedAngieChristy = false
local bSpookedMandy = false
local bPlayerGettingBusted = false

function MissionSetup()
	--print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
	MissionDontFadeIn()
	DATLoad("2_S06.DAT", 2)
	DATLoad("2_S06b.DAT", 2)
	DATInit()
	if IsMissionFromDebug() then
		AreaTransitionPoint(0, POINTLIST._2_S06_SPAWNPLAYER, nil, false)
	end
	PlayCutsceneWithLoad("2-S06", true)
	--print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup() -- ! Modified
	CameraSetWidescreen(false)
	SoundEnableSpeech_ActionTree()
	F_MakePlayerSafeForNIS(false)
	PlayerSetControl(1)
	--print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
	if pedBurtonStage3.id and PedIsValid(pedBurtonStage3.id) then
		PedSetFlag(pedBurtonStage3.id, 113, false)
		PedSetInvulnerable(pedBurtonStage3.id, false)
		PedIgnoreStimuli(pedBurtonStage3.id, false)
		PedSetStationary(pedBurtonStage3.id, false)
	end
	F_CleanupShowerSteam()
	F_CleanUpBlips()
	if bSprinklersLoaded then
		F_CleanupSprinklers()
	end
	UnLoadAnimationGroup("GEN_Social")
	UnLoadAnimationGroup("F_Girls")
	UnLoadAnimationGroup("Px_RedButton")
	UnLoadAnimationGroup("IDLE_SEXY_C")
	UnLoadAnimationGroup("NPC_Shopping")
	--UnLoadAnimationGroup("F_Pref")
	F_CleanupSprinklers()	-- Added this
	SoundStopFireAlarm()
	SoundStopInteractiveStream()
	CounterMakeHUDVisible(false)
	EnablePOI()
	CameraSetWidescreen(false)
	DATUnload(2)
	DATInit()
	ItemSetCurrentNum(484, 0)
	ItemSetCurrentNum(515, 0)
	PedSetFlag(gPlayer, 97, false)
	AreaSetDoorLocked("DT_TSCHOOL_GIRLSDORML", false)
	--print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
	--print("()xxxxx[:::::::::::::::> [start] main()")
	F_SetupMission()
	if bDebugFlag then
		if gDebugLevel == 2 then
			F_Stage2()
		elseif gDebugLevel == 3 then
			F_StartAtStage3()
		end
	else
		F_Stage1()
	end
	if bMissionFailed then
		PlayerSetControl(0)
		TextPrint("2_S06_EMPTY", 1, 1)
		SoundPlayMissionEndMusic(false, 7)
		if gMissionFailMessage == 1 then
			MissionFail(false, true, "2_S06_FAIL_01")
		elseif gMissionFailMessage == 2 then
			MissionFail(false, true, "2_S06_FAIL_02")
		else
			MissionFail(false)
		end
	end
	--print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
	--print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
	pedBurton = {
		spawn = POINTLIST._2_S06_SPAWNBURTON,
		element = 1,
		model = 229
	}
	pedBurtonStage3 = {
		spawn = POINTLIST._2_S06_STAGE3_SPAWNBURTON,
		element = 1,
		model = 229
	}
	pedStg1Pref = {
		spawn = POINTLIST._2_S06_STG1_PREFECT,
		element = 1,
		model = 51
	}
	pedStg1Jock = {
		spawn = POINTLIST._2_S06_STG1_JOCK,
		element = 1,
		model = 16
	}
	pedArtTeacher = {
		spawn = POINTLIST._2_S06B_SPAWNARTTEACHER,
		element = 1,
		model = 63
	}
	pedLibrarian = {
		spawn = POINTLIST._2_S06B_SPAWNLIBRARIAN,
		element = 1,
		model = 62
	}
	pedHeadmistress = {
		spawn = POINTLIST._2_S06_STG3_TEACHER,
		element = 1,
		model = 54
	}
	pedGirlsShower_01 = {
		spawn = POINTLIST._2_S06B_SPAWNSHOWER,
		element = 1,
		model = 96
	}
	pedGirlsShower_02 = {
		spawn = POINTLIST._2_S06B_SPAWNSHOWER,
		element = 2,
		model = 182
	}
	pedSexyGirl = {
		spawn = POINTLIST._2_S06B_SPAWNGIRLS_B,
		element = 1,
		model = 67
	}
	pedAsianGirl = {
		spawn = POINTLIST._2_S06B_SPAWNGIRLS_B,
		element = 2,
		model = 39
	}
	pedPinkyUW = {
		spawn = POINTLIST._2_S06B_SPAWNGIRLS_C,
		element = 2,
		model = 94
	}
	pedBeatrice = {
		spawn = POINTLIST._2_S06B_SPAWNGIRLS_D,
		element = 1,
		model = 137
	}
	tableSprinklers = {
		POINTLIST._2_S06B_FIRE_01,
		POINTLIST._2_S06B_FIRE_02,
		POINTLIST._2_S06B_FIRE_03,
		POINTLIST._2_S06B_FIRE_04,
		POINTLIST._2_S06B_FIRE_05,
		POINTLIST._2_S06B_FIRE_06,
		POINTLIST._2_S06B_FIRE_07,
		POINTLIST._2_S06B_FIRE_08,
		POINTLIST._2_S06B_FIRE_09,
		POINTLIST._2_S06B_FIRE_10,
		POINTLIST._2_S06B_FIRE_11,
		POINTLIST._2_S06B_FIRE_12,
		POINTLIST._2_S06B_FIRE_13
	}
	pedStg3Girl01 = {
		spawn = POINTLIST._2_S06_STG3_GIRL01,
		element = 1,
		model = 94
	}
	pedStg3Girl02 = {
		spawn = POINTLIST._2_S06_STG3_GIRL02,
		element = 1,
		model = 67
	}
	pedStg3Girl03 = {
		spawn = POINTLIST._2_S06_STG3_GIRL03,
		element = 1,
		model = 14
	}
	pedStg3Girl04 = {
		spawn = POINTLIST._2_S06_STG3_GIRL04,
		element = 1,
		model = 96
	}
	pedStg3Girl05 = {
		spawn = POINTLIST._2_S06_STG3_GIRL05,
		element = 1,
		model = 39
	}
	pedEunice = {
		spawn = POINTLIST._2_S06B_SPAWNEUNICEUPSTAIRS,
		element = 1,
		model = 74
	}
	--print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupMission()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
	LoadAnimationGroup("GEN_Social")
	LoadAnimationGroup("F_Girls")
	LoadAnimationGroup("Px_RedButton")
	F_TableInit()
	DisablePOI()
	WeaponRequestModel(430)
	AreaSetDoorLocked("GDORM_UPPERDOORSTORAGE", false)
	LoadPedModels({
		229,
		51,
		16,
		63,
		62,
		54,
		96,
		39,
		182,
		94,
		3,
		14,
		67,
		74
	})
	pedBurton.id = PedCreatePoint(pedBurton.model, pedBurton.spawn, pedBurton.element)
	PedSetFaction(pedBurton.id, 9)
	PedSetMissionCritical(pedBurton.id, true, F_MissionCriticalBurton, true)
	LoadActionTree("Act/Conv/2_S06.act")
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
end

function F_StartAtStage3()
	--print("()xxxxx[:::::::::::::::> [start] F_StartAtStage3()")
	AreaTransitionPoint(35, POINTLIST._2_S06B_PANTIES)
	Wait(1000)
	pedLibrarian.id = PedCreatePoint(pedLibrarian.model, pedLibrarian.spawn, pedLibrarian.element)
	pedBeatrice.id = PedCreatePoint(pedBeatrice.model, pedBeatrice.spawn, pedBeatrice.element)
	pedAsianGirl.id = PedCreatePoint(pedAsianGirl.model, POINTLIST._2_S06B_PANICASIANGIRL, pedAsianGirl.element)
	pedSexyGirl.id = PedCreatePoint(pedSexyGirl.model, POINTLIST._2_S06B_PANICSEXYGIRL, pedSexyGirl.element)
	pedEunice.id = PedCreatePoint(pedEunice.model, POINTLIST._2_S06B_SPAWNEUNICEDOWNSTAIRS, pedEunice.element)
	gObjective01 = MissionObjectiveAdd("2_S06_MOBJ_01")
	MissionObjectiveComplete(gObjective01)
	gObjective02 = MissionObjectiveAdd("2_S06_MOBJ_02")
	MissionObjectiveComplete(gObjective02)
	gObjective03 = MissionObjectiveAdd("2_S06_MOBJ_03")
	AreaSetDoorLocked("GDORM_UPPERDOORSTORAGE", true)
	PedSocialOverrideLoad(4, "Mission/2_S06Follow.act")
	PlayerSocialOverrideLoad(32, "Mission/2_S06PlayerGift.act")
	GiveItemToPlayer(515)
	F_Stage3()
	--print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage3()")
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Setup()
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	finishX, finishY, finishZ = GetPointList(POINTLIST._2_S06_BLIPLATTICE)
	threadStage1Objectives = CreateThread("T_Stage1_Objectives")
	blipLattice = BlipAddPoint(POINTLIST._2_S06_TOPLATTICE, 0)
	AreaSetDoorLocked("DT_TSCHOOL_GIRLSDORML", true)
	PedSetPosPoint(gPlayer, POINTLIST._2_S06_SPAWNPLAYER)
	CameraFade(500, 1)
	Wait(500)
	TextPrint("2_S06_MOBJ_01", 3, 1)
	gObjective01 = MissionObjectiveAdd("2_S06_MOBJ_01")
	SoundPlayScriptedSpeechEventWrapper(pedBurton.id, "M_2_S06", 1, "large")
	PedFollowPath(pedBurton.id, PATH._2_S06_BURTONLEAVE, 0, 0, F_routeBurtonLeave)
	PedSocialOverrideLoad(4, "Mission/2_S06Follow.act")
	PlayerSocialOverrideLoad(32, "Mission/2_S06PlayerGift.act")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Loop()")
	while bLoop do
		F_Stage1Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage2 then
			F_Stage2()
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Loop()")
end

function F_Stage2()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2()")
	F_Stage2_Setup()
	F_Stage2_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
	if bDebugFlag then
		gObjective01 = MissionObjectiveAdd("2_S06_MOBJ_01")
	else
		F_CleanupStage1()
	end
	CameraReset()
	PlayerSetPunishmentPoints(0)
	F_SetupStage2Peds()
	F_SpawnPanties()
	threadMonitorPanties = CreateThread("T_MonitorPanties")
	threadMonitorStage2Triggers = CreateThread("T_MonitorStage2Triggers")
	F_SetupShowerSteam()
	CounterSetIcon("HUDIcon_undies", "HUDIcon_undies_x")
	CounterMakeHUDVisible(true)
	CounterSetCurrent(0)
	CounterSetMax(5)
	MissionObjectiveComplete(gObjective01)
	TextPrint("2_S06_MOBJ_02", 3, 1)
	gObjective02 = MissionObjectiveAdd("2_S06_MOBJ_02")
	LoadAnimationGroup("F_Pref")
	PAnimDoorStayOpen(TRIGGER._GDORM_UPPERDOOR)
	PAnimOpenDoor(TRIGGER._GDORM_UPPERDOOR)
	SoundPlayInteractiveStreamLocked("MS_StealthLow.rsm", 0.35)
	PedSetFlag(gPlayer, 97, true)
	bBustPlayer = true
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2_Loop()")
	while bLoop do
		F_Stage2Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage3 then
			F_Stage3()
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Loop()")
end

function F_Stage3()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3()")
	F_Stage3_Setup()
	F_Stage3_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3()")
end

function F_Stage3_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3_Setup()")
	bShowerChat = false
	F_NewStage3Cut()
	MissionObjectiveComplete(gObjective02)
	TextPrint("2_S06_MOBJ_03", 3, 1)
	gObjective03 = MissionObjectiveAdd("2_S06_MOBJ_03")
	SoundPlayInteractiveStreamLocked("MS_StealthHigh.rsm", 0.35)
	if F_PedExists(pedAsianGirl.id) then
		SoundPlayScriptedSpeechEvent(pedAsianGirl.id, "M_2_S06", 35, "large")
	end
	DeleteAPed(pedEunice.id)
	pedEunice.id = PedCreatePoint(pedEunice.model, POINTLIST._2_S06B_SPAWNEUNICEDOWNSTAIRS, pedEunice.element)
	pedBurtonStage3.id = PedCreatePoint(pedBurtonStage3.model, pedBurtonStage3.spawn, pedBurtonStage3.element)
	PedSetFlag(pedBurtonStage3.id, 113, true)
	PedIgnoreStimuli(pedBurtonStage3.id, true)
	PedSetStationary(pedBurtonStage3.id, true)
	PedSetFaction(pedBurtonStage3.id, 9)
	PlayerSocialDisableActionAgainstPed(pedBurtonStage3.id, 35, true)
	PlayerSocialDisableActionAgainstPed(pedBurtonStage3.id, 29, true)
	PlayerSocialDisableActionAgainstPed(pedBurtonStage3.id, 28, true)
	PedSetRequiredGift(pedBurtonStage3.id, 15, false, true)
	PedUseSocialOverride(pedBurtonStage3.id, 4)
	PedSetMissionCritical(pedBurtonStage3.id, true, F_MissionCriticalBurton, true)
	PlayerSocialEnableOverrideAgainstPed(pedBurtonStage3.id, 32, true)
	PedSetMissionCritical(pedBurton.id, true, F_MissionCriticalBurton, true)
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3_Setup()")
end

function F_Stage3_Loop()
	while bLoop do
		F_Stage3Objectives()
		if bMissionFailed then
			break
		end
		if bMissionPassed then
			break
		end
		Wait(0)
	end
end

function F_Stage1Objectives()
	if not bLoadSchool and PlayerIsInTrigger(TRIGGER._2_S06_TRIGGERLOADSCHOOL) then
		F_LoadSchool()
		bLoadSchool = true
	end
	if not bTutLattice then
		PedIsInAreaXYZ(gPlayer, finishX, finishY, finishZ, 1, 7)
		if PlayerIsInTrigger(TRIGGER._2_S06_TUTLATTICE) and PedIsPlaying(gPlayer, "/Global/Trellis/Trellis_Actions/Climb_ON_BOT", true) then
			bTutLattice = true
		end
	end
	if not bJockBusted and PlayerIsInTrigger(TRIGGER._2_S06_STG1_BUSTED) then
		SoundPlayScriptedSpeechEventWrapper(pedStg1Pref.id, "M_2_S06", 2, "jumbo")
		PedFollowPath(pedStg1Jock.id, PATH._2_S06_STG1BUSTED, 0, 0, F_routeBusted)
		Wait(1000)
		PedFollowPath(pedStg1Pref.id, PATH._2_S06_STG1BUSTED, 0, 0, F_routeBusted)
		bJockBusted = true
	end
	if bCleanupBurton then
		PedSetMissionCritical(pedBurton.id, false)
		PedDelete(pedBurton.id)
		bCleanupBurton = false
	end
	if bCleanupBustedJock then
		PedDelete(pedStg1Jock.id)
		bCleanupBustedJock = false
	end
	if bCleanupBustedPref then
		PedDelete(pedStg1Pref.id)
		bCleanupBustedPref = false
	end
end

function F_Stage2Objectives()
	if not bGirlBEvent and PlayerIsInTrigger(TRIGGER._2_S06B_LAUNCHASIAN) then
		F_GirlBEvent()
		bGirlBEvent = true
		bGirlBSetForEjected = true
	end
	if not bMakeGirlsStudy and PlayerIsInTrigger(TRIGGER._2_S06B_MAKEGIRLSSTUDY) then
		F_MakeGirlsStudy()
		bMakeGirlsStudy = true
	end
	if AreaGetVisible() == 35 and PedIsValid(shared.gdormHeadID) then
		if bBustPlayer then
			if PedCanSeeObject(shared.gdormHeadID, gPlayer, 3) or PedIsHit(shared.gdormHeadID, 2, 500) then
				bPlayerGettingBusted = true
				F_PlayerSpotted(shared.gdormHeadID)
				F_CutBootedOut()
				F_EjectPlayerFromDorm()
			elseif PedCanSeeObject(pedLibrarian.id, gPlayer, 3) or PedIsHit(pedLibrarian.id, 2, 500) then
				bPlayerGettingBusted = true
				F_PlayerSpotted(pedLibrarian.id)
				F_CutBootedOut()
				F_EjectPlayerFromDorm()
			end
		end
		if PedIsPlaying(gPlayer, "/Global/FrAlrm/PedPropsActions/NotUsed/Idle", true) then
			Wait(3000)
			gMissionFailMessage = 2
			bMissionFailed = true
		end
	end
	if bAll5PantiesCollected then
		bBustPlayer = false
		F_LaunchAngryBeatrice()
		bGoToStage3 = true
	end
	if not bLockedStorageRoom and bLockTheStorageRoom then
		PAnimCloseDoor(TRIGGER._GDORM_UPPERDOORSTORAGE)
		AreaSetDoorLocked("GDORM_UPPERDOORSTORAGE", true)
		bLockedStorageRoom = true
	end
	if shared.gdormHeadSpottedPlayer then
		bBustPlayer = true
	end
	if bPlayerEjected and PlayerIsInTrigger(TRIGGER._2_S06B_ATTICENTRY) then
		F_ResetDorm()
		bPlayerEjected = false
	end
	if bDeleteEunice then
		DeleteAPed(pedEunice.id)
		bDeleteEunice = false
	end
end

function F_Stage3Objectives()
	if not bEuniceSawJimmy and PlayerIsInTrigger(TRIGGER._2_S06B_EUNICEFRONTDOOR) then
		SoundPlayScriptedSpeechEventWrapper(pedEunice.id, "M_2_S06", 33)
		PedAttackPlayer(pedEunice.id, 3)
		bEuniceSawJimmy = true
	end
	if not bUpdateStage3Objectives and AreaGetVisible() == 0 then
		PlayerSetPunishmentPoints(0)
		CameraReset()
		F_CleanupDorm()
		SoundStopInteractiveStream()
		MissionObjectiveComplete(gObjective03)
		gObjective04 = MissionObjectiveAdd("2_S06_MOBJ_04")
		TextPrint("2_S06_MOBJ_04", 7, 1)
		pedStg3Girl01.id = PedCreatePoint(pedStg3Girl01.model, pedStg3Girl01.spawn, pedStg3Girl01.element)
		PedSetActionNode(pedStg3Girl01.id, "/Global/2_S06/Anims/GirlsOutside/Entry1/Ambient_3", "Act/Conv/2_S06.act")
		pedStg3Girl02.id = PedCreatePoint(pedStg3Girl02.model, pedStg3Girl02.spawn, pedStg3Girl02.element)
		PedSetActionNode(pedStg3Girl02.id, "/Global/2_S06/Anims/GirlsOutside/Entry2/F_Freakout", "Act/Conv/2_S06.act")
		pedStg3Girl03.id = PedCreatePoint(pedStg3Girl03.model, pedStg3Girl03.spawn, pedStg3Girl03.element)
		PedSetActionNode(pedStg3Girl03.id, "/Global/2_S06/Anims/GirlsOutside/Entry3/Sxy_Impatient", "Act/Conv/2_S06.act")
		pedStg3Girl04.id = PedCreatePoint(pedStg3Girl04.model, pedStg3Girl04.spawn, pedStg3Girl04.element)
		PedFollowPath(pedStg3Girl04.id, PATH._2_S06_GIRLFREAK01, 2, 1)
		pedStg3Girl05.id = PedCreatePoint(pedStg3Girl05.model, pedStg3Girl05.spawn, pedStg3Girl05.element)
		PedFollowPath(pedStg3Girl05.id, PATH._2_S06_GIRLFREAK02, 2, 2)
		pedBurtonStage3.blip = AddBlipForChar(pedBurtonStage3.id, 8, 0, 4)
		CreateThread("T_PlayerLeftDorm")
		bUpdateStage3Objectives = true
	end
	if not bMandySpeak and PlayerIsInTrigger(TRIGGER._2_S06_MANDYSPEAK) then
		CreateThread("T_TextGirlsOutFront")
		bMandySpeak = true
	end
	if PlayerIsInTrigger(TRIGGER._2_S06_MANDYSPEAK) then
		if bFrontGirlsFacingDoor then
			if F_PedExists(pedStg3Girl01.id) then
				PedFaceObject(pedStg3Girl01.id, gPlayer, 3, 1)
			end
			if F_PedExists(pedStg3Girl02.id) then
				PedFaceObject(pedStg3Girl02.id, gPlayer, 3, 1)
			end
			if F_PedExists(pedStg3Girl03.id) then
				PedFaceObject(pedStg3Girl03.id, gPlayer, 3, 1)
			end
			bFrontGirlsFacingDoor = false
		end
	elseif not bFrontGirlsFacingDoor then
		if F_PedExists(pedStg3Girl01.id) then
			PedFaceHeading(pedStg3Girl01.id, 90, 1)
		end
		if F_PedExists(pedStg3Girl02.id) then
			PedFaceHeading(pedStg3Girl02.id, 90, 1)
		end
		if F_PedExists(pedStg3Girl03.id) then
			PedFaceHeading(pedStg3Girl03.id, 90, 1)
		end
		bFrontGirlsFacingDoor = true
	end
	if PlayerIsInAreaObject(pedBurtonStage3.id, 2, 3.5, 0) then
		PedSetInvulnerable(pedBurtonStage3.id, true)
		PlayerSetInvulnerable(true)
		CameraSetWidescreen(true)
		F_MakePlayerSafeForNIS(true)
		PlayerSetControl(0)
		F_PlayerDismountBike()
		PedSetMissionCritical(pedBurton.id, false)
		PedSetInvulnerable(pedBurtonStage3.id, false)
		PedIgnoreStimuli(pedBurtonStage3.id, false)
		PedSetStationary(pedBurtonStage3.id, false)
		PedSetFlag(pedBurtonStage3.id, 113, false)
		PedFaceObject(pedBurtonStage3.id, gPlayer, 3, 1)
		PedFaceObject(gPlayer, pedBurtonStage3.id, 2, 1)
		PedLockTarget(gPlayer, pedBurtonStage3.id, 3)
		PedMoveToObject(pedBurtonStage3.id, gPlayer, 2, 0)
		while not PlayerIsInAreaObject(pedBurtonStage3.id, 2, 0.8, 0) do
			Wait(0)
		end
		PedStop(pedBurtonStage3.id)
		PedClearObjectives(pedBurtonStage3.id)
		PedFaceObject(gPlayer, pedBurtonStage3.id, 2, 1)
		PedFaceObject(pedBurtonStage3.id, gPlayer, 3, 1)
		PedLockTarget(gPlayer, pedBurtonStage3.id, 3)
		PlayerSocialEnableOverrideAgainstPed(pedBurtonStage3.id, 32, true)
		Wait(500)
		SoundPlayScriptedSpeechEventWrapper(gPlayer, "M_2_S06", 50)
		PedSetActionNode(gPlayer, "/Global/Player/Social_Actions/Give/UseOverride", "Act/Player.act")
		Wait(200)
		while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/Give/UseOverride", true) do
			Wait(0)
		end
		BlipRemove(pedBurtonStage3.blip)
		PlayerSocialDisableActionAgainstPed(pedBurtonStage3.id, 35, false)
		PlayerSocialDisableActionAgainstPed(pedBurtonStage3.id, 29, false)
		PlayerSocialDisableActionAgainstPed(pedBurtonStage3.id, 28, false)
		PedSetRequiredGift(pedBurtonStage3.id, 0)
		PedSetMissionCritical(pedBurtonStage3.id, false)
		MinigameSetCompletion("M_PASS", true, 3000)
		SoundPlayMissionEndMusic(true, 7)
		F_WaitForSpeech(pedBurtonStage3.id)
		PedMoveToPoint(pedBurtonStage3.id, 1, POINTLIST._2_S06_BURTONLEAVE)
		Wait(1000)
		PedMakeAmbient(pedBurtonStage3.id)
		PedWander(pedBurtonStage3.id, 0)
		CameraReset()
		CameraReturnToPlayer()
		bMissionPassed = true
		bBurtonReceivedPanties = false
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		PlayerSetInvulnerable(false)
		PedSetInvulnerable(pedBurtonStage3.id, false)
		PedLockTarget(gPlayer, -1, 1)
		MissionSucceed(false, false, false)
	end
end

function DeleteAPed(pedID)
	if not PedIsDead(pedID) then
		PedDelete(pedID)
	end
end

function F_NewStage3Cut()
	--print("()xxxxx[:::::::::::::::> [start] F_NewStage3Cut()")
	PlayerSetControl(0)
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(500, 0)
	Wait(500)
	CounterClearIcon()
	CounterMakeHUDVisible(false)
	CameraSetXYZ(-448.54468, 310.62537, -1.656643, -447.6013, 310.95612, -1.634508)
	CameraSetWidescreen(true)
	if F_PedExists(pedBeatrice.id) then
		PedDelete(pedBeatrice.id)
	end
	pedBeatrice.id = PedCreatePoint(pedBeatrice.model, POINTLIST._2_S06B_CUTBEATRICE, pedBeatrice.element)
	PedPathNodeReachedDistance(pedBeatrice.id, 0.5)
	PedStop(pedBeatrice.id)
	PedClearObjectives(pedBeatrice.id)
	PedSetPosPoint(pedBeatrice.id, POINTLIST._2_S06B_CUTBEATRICE)
	pedPinkyUW.id = PedCreatePoint(pedPinkyUW.model, POINTLIST._2_S06B_PANICPINKYUW, pedPinkyUW.element)
	if F_PedExists(pedAsianGirl.id) then
		PedSetPosPoint(pedAsianGirl.id, POINTLIST._2_S06B_PANICASIANGIRL)
	else
		pedAsianGirl.id = PedCreatePoint(pedAsianGirl.model, POINTLIST._2_S06B_PANICASIANGIRL, pedAsianGirl.element)
	end
	if F_PedExists(pedSexyGirl.id) then
		PedSetPosPoint(pedSexyGirl.id, POINTLIST._2_S06B_PANICSEXYGIRL)
	else
		pedSexyGirl.id = PedCreatePoint(pedSexyGirl.model, POINTLIST._2_S06B_PANICSEXYGIRL, pedSexyGirl.element)
	end
	pedArtTeacher.id = PedCreatePoint(pedArtTeacher.model, pedArtTeacher.spawn, pedArtTeacher.element)
	PedSetIsStealthMissionPed(pedArtTeacher.id, false)
	PedSetPosPoint(pedArtTeacher.id, POINTLIST._2_S06B_PANICARTTEACHER)
	shared.gdormHeadStop = true
	PedSetInvulnerable(pedBeatrice.id, true)
	DeleteAPed(pedGirlsShower_01.id)
	DeleteAPed(pedGirlsShower_02.id)
	PedWander(pedPinkyUW.id, 1)
	PedSetActionNode(pedAsianGirl.id, "/Global/2_S06/Anims/Empty", "Act/Conv/2_S06.act")
	PedWander(pedAsianGirl.id, 1)
	PedSetActionNode(pedSexyGirl.id, "/Global/2_S06/Anims/Empty", "Act/Conv/2_S06.act")
	PedWander(pedSexyGirl.id, 1)
	PedMoveToPoint(pedArtTeacher.id, 1, POINTLIST._2_S06B_ARTTEACHERYELL)
	LoadModels({ 340 }, true)
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
	if not bStartedAlarm then
		SoundStartFireAlarm()
		SoundPlay2D("Sprinklers")
		PedWander(pedBeatrice.id, 1)
		F_CreateSprinklers()
	end
	LoadAnimationGroup("IDLE_SEXY_C")
	LoadAnimationGroup("NPC_Shopping")
	CameraReturnToPlayer()
	CameraReset()
	PedSetFlag(gPlayer, 2, false)
	PedSetActionNode(pedLibrarian.id, "/Global/2_S06/Anims/Empty", "Act/Conv/2_S06.act")
	PedMakeAmbient(pedBeatrice.id)
	PedMakeAmbient(pedArtTeacher.id)
	PedSetInvulnerable(pedBeatrice.id, false)
	F_MakePlayerSafeForNIS(false)
	CameraFade(500, 1)
	Wait(500)
	shared.gdormHeadStart = true
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	TextPrint("2_S06_MOBJ_03", 3, 1)
	--print("()xxxxx[:::::::::::::::> [finish] F_NewStage3Cut()")
end

function F_LoadSchool()
	--print("()xxxxx[:::::::::::::::> [start] F_LoadSchool()")
	pedStg1Pref.id = PedCreatePoint(pedStg1Pref.model, pedStg1Pref.spawn, pedStg1Pref.element)
	pedStg1Jock.id = PedCreatePoint(pedStg1Jock.model, pedStg1Jock.spawn, pedStg1Jock.element)
	--print("()xxxxx[:::::::::::::::> [finish] F_LoadSchool()")
end

function F_CleanupStage1()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupStage1()")
	DeleteAPed(pedStg1Pref.id)
	DeleteAPed(pedStg1Jock.id)
	BlipRemove(blipLattice)
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupStage1()")
end

function F_SetupStage2Peds()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupStage2Peds()")
	pedLibrarian.id = PedCreatePoint(pedLibrarian.model, pedLibrarian.spawn, pedLibrarian.element)
	PedSetActionNode(pedLibrarian.id, "/Global/2_S06/Anims/TE_Sitting/SitLoop", "Act/Conv/2_S06.act")
	PedSetStealthBehavior(pedLibrarian.id, 1, F_BustPlayer)
	PedCanTeleportOnAreaTransition(pedLibrarian.id, false)
	pedGirlsShower_01.id = PedCreatePoint(pedGirlsShower_01.model, pedGirlsShower_01.spawn, pedGirlsShower_01.element)
	PedSetStationary(pedGirlsShower_01.id, true)
	PedMakeTargetable(pedGirlsShower_01.id, false)
	PedSetInvulnerable(pedGirlsShower_01.id, true)
	PedSetActionNode(pedGirlsShower_01.id, "/Global/2_S06/Anims/SHOWERING/LoadAnims", "Act/Conv/2_S06.act")
	pedGirlsShower_02.id = PedCreatePoint(pedGirlsShower_02.model, pedGirlsShower_02.spawn, pedGirlsShower_02.element)
	PedSetStationary(pedGirlsShower_02.id, true)
	PedMakeTargetable(pedGirlsShower_02.id, false)
	PedSetInvulnerable(pedGirlsShower_02.id, true)
	PedSetActionNode(pedGirlsShower_02.id, "/Global/2_S06/Anims/SHOWERING/LoadAnims", "Act/Conv/2_S06.act")
	pedSexyGirl.id = PedCreatePoint(pedSexyGirl.model, pedSexyGirl.spawn, pedSexyGirl.element)
	PedAlwaysUpdateAnimation(pedSexyGirl.id, true)
	PedSetWantsToSocializeWithPed(pedSexyGirl.id, gPlayer)
	pedAsianGirl.id = PedCreatePoint(pedAsianGirl.model, pedAsianGirl.spawn, pedAsianGirl.element)
	PedSetWantsToSocializeWithPed(pedAsianGirl.id, gPlayer)
	if not bLaunchedStage2Trigger03 then
		pedEunice.id = PedCreatePoint(pedEunice.model, pedEunice.spawn, pedEunice.element)
		PedSetWantsToSocializeWithPed(pedEunice.id, gPlayer)
	end
	bMonitorStage2Girls = true
	threadMonitorStage2Girls = CreateThread("T_MonitorStage2Girls")
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupStage2Peds()")
end

function F_SpawnPanties()
	--print("()xxxxx[:::::::::::::::> [start] F_SpawnPanties()")
	pantiesB = PickupCreatePoint(484, POINTLIST._2_S06B_PANTIES, 1, 0, "PermanentMission")
	pantiesC = PickupCreatePoint(484, POINTLIST._2_S06B_PANTIES, 2, 0, "PermanentMission")
	pantiesD = PickupCreatePoint(484, POINTLIST._2_S06B_PANTIES, 3, 0, "PermanentMission")
	pantiesE = PickupCreatePoint(484, POINTLIST._2_S06B_PANTIES, 4, 0, "PermanentMission")
	pantiesF = PickupCreatePoint(484, POINTLIST._2_S06B_PANTIES, 5, 0, "PermanentMission")
	blipPanties_B = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 1)
	blipPanties_C = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 2)
	blipPanties_D = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 3)
	blipPanties_E = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 4)
	blipPanties_F = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 5)
	--print("()xxxxx[:::::::::::::::> [finish] F_SpawnPanties()")
end

function F_CleanupDorm()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupDorm()")
	bMonitorStage2Girls = false
	DeleteAPed(pedLibrarian.id)
	DeleteAPed(pedArtTeacher.id)
	DeleteAPed(pedGirlsShower_01.id)
	DeleteAPed(pedGirlsShower_02.id)
	DeleteAPed(pedSexyGirl.id)
	DeleteAPed(pedAsianGirl.id)
	DeleteAPed(pedPinkyUW.id)
	DeleteAPed(pedBeatrice.id)
	DeleteAPed(pedEunice.id)
	if effectShower2a then
		EffectKill(effectShower2a)
		EffectKill(effectShower2b)
		EffectKill(effectShower3)
		bShowerEffectLoaded = false
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupDorm()")
end

function F_GirlFlee(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_GirlFlee()")
	if not bBustPlayer then
		PedSetPunishmentPoints(gPlayer, 5)
		PedSetInfiniteSprint(shared.gdormHeadID, true)
		PedOverrideStat(shared.gdormHeadID, 3, 12)
		PedAttack(shared.gdormHeadID, gPlayer, 3, true)
		PedSetIsStealthMissionPed(pedID, false)
		PedMoveToPoint(pedID, 1, POINTLIST._2_S06B_POINTFLEE)
		--print("()xxxxx[:::::::::::::::> [test] F_GirlFlee()")
		bBustPlayer = true
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_GirlFlee()")
end

function F_GirlsAttack(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_GirlsAttack()")
	PedAttack(pedID, gPlayer, 2, true)
	--print("()xxxxx[:::::::::::::::> [finish] F_GirlsAttack()")
end

function F_GirlBEvent()
	--print("()xxxxx[:::::::::::::::> [start] F_GirlBEvent()")
	PedFollowPath(pedAsianGirl.id, PATH._2_S06B_ROUTEGIRLS_B, 0, 0)
	CreateThread("T_SpeechChristyAngie")
	TutorialShowMessage("TUT_GIRLD1", 5000)
	--print("()xxxxx[:::::::::::::::> [finish] F_GirlBEvent()")
end

function F_CreateSprinklers()
	--print("()xxxxx[:::::::::::::::> [start] F_CreateSprinklers()")
	local sprinklerX, sprinklerY, sprinklerZ = 0, 0, 0
	local iSprinklers = table.getn(tableSprinklers)
	for i = 1, iSprinklers do
		sprinklerX, sprinklerY, sprinklerZ = GetPointList(tableSprinklers[i])
		tableSprinklerNames[i] = EffectCreate("FireSprinkler", sprinklerX, sprinklerY, sprinklerZ)
		Wait(0)
	end
	bSprinklersLoaded = true
	--print("()xxxxx[:::::::::::::::> [finish] F_CreateSprinklers()")
end

function F_CleanupSprinklers()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupSprinklers()")
	local iSprinklers = table.getn(tableSprinklerNames)
	for i = 1, iSprinklers do
		EffectKill(tableSprinklerNames[i])
	end
	bSprinklersLoaded = false
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupSprinklers()")
end

function F_MakeGirlsStudy()
	--print("()xxxxx[:::::::::::::::> [start] F_MakeGirlsStudy()")
	PedSetActionNode(pedSexyGirl.id, "/Global/WProps/PropInteract", "Act/WProps.act")
	--print("()xxxxx[:::::::::::::::> [finish] F_MakeGirlsStudy()")
end

function F_BustPlayer(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_BustPlayer()")
	bBustPlayer = true
	--print("()xxxxx[:::::::::::::::> [finish] F_BustPlayer()")
end

function F_CleanUpBlips()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanUpBlips()")
	if blipLattice ~= nil then
		BlipRemove(blipLattice)
	end
	if blipRealExit ~= nil then
		BlipRemove(blipRealExit)
	end
	if pedBurtonStage3.blip ~= nil then
		BlipRemove(pedBurtonStage3.blip)
	end
	if blipPanties_B ~= nil then
		BlipRemove(blipPanties_B)
	end
	if blipPanties_C ~= nil then
		BlipRemove(blipPanties_C)
	end
	if blipPanties_D ~= nil then
		BlipRemove(blipPanties_D)
	end
	if blipPanties_E ~= nil then
		BlipRemove(blipPanties_E)
	end
	if blipPanties_F ~= nil then
		BlipRemove(blipPanties_F)
	end
	if blipExit ~= nil then
		BlipRemove(blipExit)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanUpBlips()")
end

function F_EjectPlayerFromDorm()
	--print("()xxxxx[:::::::::::::::> [start] F_EjectPlayerFromDorm()")
	CameraFade(500, 0)
	Wait(500)
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	bBustPlayer = false
	F_CleanupShowerSteam()
	AreaSetDoorLocked("GDORM_UPPERDOORSTORAGE", false)
	bLockedStorageRoom = false
	CameraReset()
	AreaTransitionPoint(0, POINTLIST._2_S06_EJECTPLAYER)
	AreaSetDoorLocked("DT_TSCHOOL_GIRLSDORML", true)
	PlayerSetPunishmentPoints(0)
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	CameraFade(500, 1)
	Wait(500)
	F_RemovePantyBlips()
	shared.gdormHeadSpottedPlayer = false
	bPinkyStudying = false
	bLockTheStorageRoom = false
	bMakeGirlsStudy = false
	bPlayerEjected = true
	bShowerChat = false
	--print("()xxxxx[:::::::::::::::> [finish] F_EjectPlayerFromDorm()")
end

function F_ResetDorm()
	--print("()xxxxx[:::::::::::::::> [start] F_ResetDorm()")
	PlayerSetPunishmentPoints(0)
	CameraReset()
	F_CleanupDorm()
	Wait(0)
	F_SetupStage2Peds()
	Wait(0)
	F_ReblipPanties()
	F_SetupShowerSteam()
	if bGirlBSetForEjected then
		PedSetPosPoint(pedAsianGirl.id, POINTLIST._2_S06B_EJECTEDGIRLSB, 1)
	end
	bShowerDialogue = false
	bLaunchedStage2Trigger02 = false
	bBustPlayer = true
	bSpookedAngieChristy = false
	bSpookedMandy = false
	bPlayerGettingBusted = false
	--print("()xxxxx[:::::::::::::::> [finish] F_ResetDorm()")
end

function F_RemovePantyBlips()
	--print("()xxxxx[:::::::::::::::> [start] F_RemovePantyBlips()")
	if not bPantiesBPickedUp then
		BlipRemove(blipPanties_B)
	end
	if not bPantiesCPickedUp then
		BlipRemove(blipPanties_C)
	end
	if not bPantiesDPickedUp then
		BlipRemove(blipPanties_D)
	end
	if not bPantiesEPickedUp then
		BlipRemove(blipPanties_E)
	end
	if not bPantiesFPickedUp then
		BlipRemove(blipPanties_F)
	end
	blipLattice = BlipAddPoint(POINTLIST._2_S06_TOPLATTICE, 0)
	MissionObjectiveRemove(gObjective01)
	MissionObjectiveRemove(gObjective02)
	gObjective01 = MissionObjectiveAdd("2_S06_MOBJ_01")
	TextPrint("2_S06_MOBJ_01", 4, 1)
	--print("()xxxxx[:::::::::::::::> [finish] F_RemovePantyBlips()")
end

function F_ReblipPanties()
	--print("()xxxxx[:::::::::::::::> [start] F_ReblipPanties()")
	if not bPantiesBPickedUp then
		blipPanties_B = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 1)
	end
	if not bPantiesCPickedUp then
		blipPanties_C = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 2)
	end
	if not bPantiesDPickedUp then
		blipPanties_D = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 3)
	end
	if not bPantiesEPickedUp then
		blipPanties_E = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 4)
	end
	if not bPantiesFPickedUp then
		blipPanties_F = BlipAddPoint(POINTLIST._2_S06B_PANTIES, 0, 5)
	end
	BlipRemove(blipLattice)
	MissionObjectiveComplete(gObjective01)
	gObjective02 = MissionObjectiveAdd("2_S06_MOBJ_02")
	TextPrint("2_S06_MOBJ_02", 4, 1)
	--print("()xxxxx[:::::::::::::::> [finish] F_ReblipPanties()")
end

function F_PlayerGavePanties()
	--print("()xxxxx[:::::::::::::::> [start] F_PlayerGavePanties()")
	SoundStopCurrentSpeechEvent(pedBurtonStage3.id)
	SoundPlayScriptedSpeechEventWrapper(pedBurtonStage3.id, "M_2_S06", 51)
	--print("()xxxxx[:::::::::::::::> [finish] F_PlayerGavePanties()")
end

function F_BurtonReceivedPanties()
	--print("()xxxxx[:::::::::::::::> [start] F_BurtonReceivedPanties()")
	bBurtonReceivedPanties = true
	--print("()xxxxx[:::::::::::::::> [finish] F_BurtonReceivedPanties()")
end

function F_MissionCritical()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCritical()")
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCritical()")
end

function F_SetupShowerSteam()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupShowerSteam()")
	local shower1X, shower1Y, shower1Z = GetPointFromPointList(POINTLIST._2_S06B_SPAWNSHOWER, 3)
	effectShower2a = EffectCreate("ShowerSteam2", shower1X, shower1Y, shower1Z)
	shower1X, shower1Y, shower1Z = GetPointFromPointList(POINTLIST._2_S06B_SPAWNSHOWER, 4)
	effectShower2b = EffectCreate("ShowerSteam2", shower1X, shower1Y, shower1Z)
	shower1X, shower1Y, shower1Z = GetPointFromPointList(POINTLIST._2_S06B_STEAMROOM, 1)
	effectShower3 = EffectCreate("SteamRoom", shower1X, shower1Y, shower1Z)
	bShowerEffectLoaded = true
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupShowerSteam()")
end

function F_CleanupShowerSteam()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupShowerSteam()")
	if bShowerEffectLoaded then
		EffectKill(effectShower2a)
		EffectKill(effectShower2b)
		EffectKill(effectShower3)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupShowerSteam()")
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

function F_PlayerSpotted(buster)
	--print("()xxxxx[:::::::::::::::> [start] F_PlayerSpotted()")
	CameraSetWidescreen(true)
	PedSetFlag(buster, 129, true)
	PlayerSetControl(0)
	PedStop(buster)
	PedClearObjectives(buster)
	PedSetStationary(buster, true)
	PedFaceObject(buster, gPlayer, 3, 1, false)
	PedLockTarget(buster, gPlayer, 3)
	PedSetIsStealthMissionPed(buster, false)
	SoundSetAudioFocusCamera()
	shared.gdormHeadCanMove = false
	Wait(200)
	if buster == shared.gdormHeadID then
		--print("()xxxxx[:::::::::::::::> HEADMISTRESS CAN SEE PLAYER")
		F_BustCam(shared.gdormHeadID)
		SoundStopCurrentSpeechEvent(shared.gdormHeadID)
		SoundPlayScriptedSpeechEventWrapper(shared.gdormHeadID, "M_2_S06", 45, "large")
		F_WaitForSpeech(shared.gdormHeadID)
	else
		--print("()xxxxx[:::::::::::::::> LIBRARIAN CAN SEE PLAYER")
		PedSetActionNode(pedLibrarian.id, "/Global/2_S06/Anims/Empty", "Act/Conv/2_S06.act")
		F_BustCam(pedLibrarian.id)
		SoundStopCurrentSpeechEvent(pedLibrarian.id)
		SoundPlayAmbientSpeechEvent(pedLibrarian.id, "WARNING_TRESPASSING")
		F_WaitForSpeech(pedLibrarian.id)
	end
	SoundSetAudioFocusPlayer()
	PedSetStationary(buster, false)
	--print("()xxxxx[:::::::::::::::> [finish] F_PlayerSpotted()")
end

function F_LaunchAngryBeatrice()
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchAngryBeatrice()")
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	F_MakePlayerSafeForNIS(true)
	CameraFade(250, 0)
	Wait(250)
	if gLastPantyPickedUp == 1 then
		CameraSetXYZ(-416.2549, 300.66162, -1.100896, -416.73825, 301.53687, -1.087145)
		pedBeatrice.id = PedCreatePoint(pedBeatrice.model, POINTLIST._2_S06B_BEATRICERUNIN, 1)
	elseif gLastPantyPickedUp == 2 then
		CameraSetXYZ(-427.5277, 322.27975, -0.379881, -427.18954, 321.34195, -0.457095)
		pedBeatrice.id = PedCreatePoint(pedBeatrice.model, POINTLIST._2_S06B_BEATRICERUNIN, 2)
	elseif gLastPantyPickedUp == 3 then
		CameraSetXYZ(-434.75098, 300.51764, -0.607479, -434.40085, 301.4465, -0.727287)
		pedBeatrice.id = PedCreatePoint(pedBeatrice.model, POINTLIST._2_S06B_BEATRICERUNIN, 3)
	elseif gLastPantyPickedUp == 4 then
		CameraSetXYZ(-437.08615, 321.37802, -0.761353, -436.73032, 320.44827, -0.854267)
		pedBeatrice.id = PedCreatePoint(pedBeatrice.model, POINTLIST._2_S06B_BEATRICERUNIN, 4)
	elseif gLastPantyPickedUp == 5 then
		CameraSetXYZ(-445.0503, 321.92926, -0.639116, -445.0488, 320.9335, -0.729048)
		pedBeatrice.id = PedCreatePoint(pedBeatrice.model, POINTLIST._2_S06B_BEATRICERUNIN, 5)
	end
	PedFaceObject(gPlayer, pedBeatrice.id, 2, 0)
	CameraFade(250, 1)
	Wait(250)
	SoundPlayAmbientSpeechEvent(pedBeatrice.id, "FREAK_OUT_GIRL_DORM")
	PedSetActionNode(pedBeatrice.id, "/Global/2_S06/Anims/BeatriceFreakOut/freakout", "Act/Conv/2_S06.act")
	F_WaitForSpeech(pedBeatrice.id)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchAngryBeatrice()")
end

function F_BustCam(pedID)
	PedFaceObject(pedID, gPlayer, 3, 0)
	local x1, y1, z1 = PedGetOffsetInWorldCoords(pedID, 0.5, 1, 1.7)
	local x2, y2, z2 = PedGetOffsetInWorldCoords(pedID, -0.5, -0.7, 1.7)
	CameraSetXYZ(x1, y1, z1, x2, y2, z2)
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

function F_MissionCriticalBurton()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalBurton()")
	if F_PedExists(pedBurton.id) then
		PedMakeAmbient(pedBurton.id)
	end
	if F_PedExists(pedBurtonStage3.id) then
		PedSetInvulnerable(pedBurtonStage3.id, false)
		PedSetFlag(pedBurtonStage3.id, 113, false)
		PedSetStationary(pedBurtonStage3.id, false)
		PedIgnoreStimuli(pedBurtonStage3.id, false)
		PedMakeAmbient(pedBurtonStage3.id)
	end
	gMissionFailMessage = 1
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalBurton()")
end

function F_CutBootedOut()
	--print("()xxxxx[:::::::::::::::> [start] F_CutBootedOut()")
	CameraFade(500, 0)
	Wait(500)
	PedSetWeaponNow(gPlayer, -1, 0)
	PedSetFlag(gPlayer, 2, false)
	PedSetPosPoint(gPlayer, POINTLIST._2_S06B_CUTBOOTJIMMY, 1)
	Wait(50)
	PedFaceHeading(gPlayer, 1, 0)
	PedSetPosPoint(shared.gdormHeadID, POINTLIST._2_S06B_CUTBOOTHEAD, 1)
	CameraSetXYZ(-437.95193, 313.57703, -5.994447, -438.2697, 314.51898, -6.101623)
	CameraFade(500, 1)
	Wait(250)
	PedFollowPath(gPlayer, PATH._2_S06B_ROUTECUTBOOT, 0, 0)
	SoundStopCurrentSpeechEvent(shared.gdormHeadID)
	SoundPlayScriptedSpeechEventWrapper(shared.gdormHeadID, "M_2_S06", 40, "medium")
	F_WaitForSpeech(shared.gdormHeadID)
	--print("()xxxxx[:::::::::::::::> [finish] F_CutBootedOut()")
end

function T_Stage1_Objectives()
	--print("()xxxxx[:::::::::::::::> [start] T_Stage1_Objectives()")
	while bLoop do
		if PlayerIsInTrigger(TRIGGER._2_S06B_ATTICENTRY) then
			bGoToStage2 = true
		end
		if bGoToStage2 then
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_Stage1_Objectives()")
end

function T_MonitorPanties()
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorPanties()")
	while bLoop do
		if not bPantiesBPickedUp and PickupIsPickedUp(pantiesB) then
			gPantiesCollected = gPantiesCollected + 1
			CounterIncrementCurrent(1)
			BlipRemove(blipPanties_B)
			blipPanties_B = nil
			bPantiesBPickedUp = true
			bLockTheStorageRoom = true
			gLastPantyPickedUp = 1
			--print("()xxxxx[:::::::::::::::> PANTY B PICKED UP")
		end
		if not bPantiesCPickedUp and PickupIsPickedUp(pantiesC) then
			gPantiesCollected = gPantiesCollected + 1
			CounterIncrementCurrent(1)
			BlipRemove(blipPanties_C)
			blipPanties_C = nil
			bPantiesCPickedUp = true
			bLockTheStorageRoom = true
			gLastPantyPickedUp = 2
			--print("()xxxxx[:::::::::::::::> PANTY C PICKED UP")
		end
		if not bPantiesDPickedUp and PickupIsPickedUp(pantiesD) then
			gPantiesCollected = gPantiesCollected + 1
			CounterIncrementCurrent(1)
			BlipRemove(blipPanties_D)
			blipPanties_D = nil
			bPantiesDPickedUp = true
			bLockTheStorageRoom = true
			gLastPantyPickedUp = 3
			--print("()xxxxx[:::::::::::::::> PANTY D PICKED UP")
		end
		if not bPantiesEPickedUp and PickupIsPickedUp(pantiesE) then
			gPantiesCollected = gPantiesCollected + 1
			CounterIncrementCurrent(1)
			BlipRemove(blipPanties_E)
			blipPanties_E = nil
			bPantiesEPickedUp = true
			bLockTheStorageRoom = true
			gLastPantyPickedUp = 4
			--print("()xxxxx[:::::::::::::::> PANTY E PICKED UP")
		end
		if not bPantiesFPickedUp and PickupIsPickedUp(pantiesF) then
			gPantiesCollected = gPantiesCollected + 1
			CounterIncrementCurrent(1)
			BlipRemove(blipPanties_F)
			blipPanties_F = nil
			bPantiesFPickedUp = true
			bLockTheStorageRoom = true
			gLastPantyPickedUp = 5
			--print("()xxxxx[:::::::::::::::> PANTY F PICKED UP")
		end
		if gPantiesCollected == 5 then
			--print("()xxxxx[:::::::::::::::> 5 Panties Collected")
			ItemSetCurrentNum(484, 0)
			GiveItemToPlayer(515)
			bAll5PantiesCollected = true
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorPanties()")
end

function T_MonitorStage2Triggers()
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorStage2Triggers()")
	while bLoop do
		if not bLaunchedStage2Trigger02 and PlayerIsInTrigger(TRIGGER._2_S06B_TRIGGER02) then
			F_LaunchStage2Trigger02()
			bLaunchedStage2Trigger02 = true
		end
		if not bLaunchedStage2Trigger03 and PlayerIsInTrigger(TRIGGER._2_S06B_TRIGGER03) then
			F_LaunchStage2Trigger03()
			bLaunchedStage2Trigger03 = true
		end
		if not bShowerDialogue and PlayerIsInTrigger(TRIGGER._2_S06B_TRIGGERSHOWERDIALOGUE) then
			bShowerChat = true
			timerShowerTalk = GetTimer()
			threadShowerTalk = CreateThread("T_ShowerTalk")
			bShowerDialogue = true
		end
		if not bSpookedAngieChristy and PlayerIsInTrigger(TRIGGER._2_S06B_ANGIECHRISTYROOM) then
			PedMakeAmbient(pedSexyGirl.id)
			PedMakeAmbient(pedAsianGirl.id)
			bSpookedAngieChristy = true
		end
		if not bSpookedMandy and PlayerIsInTrigger(TRIGGER._2_S06B_MANDYROOM) then
			bSpookedMandy = true
		end
		if PlayerIsInTrigger(TRIGGER._2_S06B_SHOWERWARN) then
			TextPrint("2_S06_WARN", 0.1, 1)
		end
		if bGoToStage3 then
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorStage2Triggers()")
end

function T_MonitorStage2Girls()
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorStage2Girls()")
	local tableGirlsToCheck = {
		pedGirlsShower_01.id,
		pedGirlsShower_02.id,
		pedSexyGirl.id,
		pedEunice.id,
		pedAsianGirl.id
	}
	local gNumber = table.getn(tableGirlsToCheck)
	while bMonitorStage2Girls do
		for i = 1, gNumber do
			if PedIsValid(tableGirlsToCheck[i]) and PedIsHit(tableGirlsToCheck[i], 2, 1000) and PedGetWhoHitMeLast(tableGirlsToCheck[i]) == gPlayer then
				F_GirlFlee(tableGirlsToCheck[i])
			end
		end
		if bGoToStage3 then
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorStage2Girls()")
end

function T_SpeechChristyAngie()
	--print("()xxxxx[:::::::::::::::> [start] T_SpeechChristyAngie()")
	if PedIsValid(pedSexyGirl.id) then
		SoundPlayScriptedSpeechEventWrapper(pedSexyGirl.id, "M_2_S06", 15)
	end
	if PedIsValid(pedSexyGirl.id) then
		F_WaitForSpeech(pedSexyGirl.id)
	end
	if PedIsValid(pedAsianGirl.id) then
		SoundPlayScriptedSpeechEventWrapper(pedAsianGirl.id, "M_2_S06", 16)
	end
	if PedIsValid(pedAsianGirl.id) then
		F_WaitForSpeech(pedAsianGirl.id)
	end
	if PedIsValid(pedSexyGirl.id) then
		SoundPlayScriptedSpeechEventWrapper(pedSexyGirl.id, "M_2_S06", 17)
	end
	if PedIsValid(pedSexyGirl.id) then
		F_WaitForSpeech(pedSexyGirl.id)
	end
	if PedIsValid(pedAsianGirl.id) then
		SoundPlayScriptedSpeechEventWrapper(pedAsianGirl.id, "M_2_S06", 18)
	end
	if PedIsValid(pedAsianGirl.id) then
		F_WaitForSpeech(pedAsianGirl.id)
	end
	if PedIsValid(pedSexyGirl.id) then
		SoundPlayScriptedSpeechEventWrapper(pedSexyGirl.id, "M_2_S06", 19)
	end
	if PedIsValid(pedSexyGirl.id) then
		F_WaitForSpeech(pedSexyGirl.id)
	end
	if PedIsValid(pedAsianGirl.id) then
		SoundPlayScriptedSpeechEventWrapper(pedAsianGirl.id, "M_2_S06", 20)
	end
	if PedIsValid(pedAsianGirl.id) then
		F_WaitForSpeech(pedAsianGirl.id)
	end
	if PedIsValid(pedSexyGirl.id) then
		SoundPlayScriptedSpeechEventWrapper(pedSexyGirl.id, "M_2_S06", 21)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_SpeechChristyAngie()")
end

function T_ShowerTalk()
	--print("()xxxxx[:::::::::::::::> [start] T_ShowerTalk()")
	while bShowerChat do
		if timerShowerTalk + 10000 <= GetTimer() then
			if bShowerTalkGirlFlag then
				SoundPlayScriptedSpeechEventWrapper(pedGirlsShower_01.id, "M_2_S06", 12)
				bShowerTalkGirlFlag = false
			else
				SoundPlayScriptedSpeechEventWrapper(pedGirlsShower_02.id, "M_2_S06", 11)
				bShowerTalkGirlFlag = true
			end
			timerShowerTalk = GetTimer()
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_ShowerTalk()")
end

function T_PlayerLeftDorm()
	--print("()xxxxx[:::::::::::::::> [start] T_PlayerLeftDorm()")
	Wait(8000)
	pedHeadmistress.id = PedCreatePoint(pedHeadmistress.model, pedHeadmistress.spawn, 1)
	PedMoveToPoint(pedHeadmistress.id, 1, POINTLIST._2_S06_STG3_PREFECT, 1)
	bStage3TeacherSpawned = true
	while bStage3TeacherSpawned do
		if PlayerIsInTrigger(TRIGGER._2_S06_STG3LEFTDORM) then
			SoundPlayScriptedSpeechEvent(pedHeadmistress.id, "M_2_S06", 45, "large")
			PedAttackPlayer(pedHeadmistress.id, 3)
			--print("()xxxxx[:::::::::::::::> Current Punishment is at: " .. PlayerGetPunishmentPoints())
			PlayerSetPunishmentPoints(PlayerGetPunishmentPoints() + 200)
			bStage3TeacherSpawned = false
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_PlayerLeftDorm()")
end

function T_TextGirlsOutFront()
	--print("()xxxxx[:::::::::::::::> [start] T_TextGirlsOutFront()")
	SoundPlayScriptedSpeechEventWrapper(pedStg3Girl03.id, "M_2_S06", 32, "large")
	F_WaitForSpeech(pedStg3Girl03.id)
	SoundPlayScriptedSpeechEventWrapper(pedStg3Girl02.id, "M_2_S06", 34, "large")
	--print("()xxxxx[:::::::::::::::> [finish] T_TextGirlsOutFront()")
end

function T_Cutscene01()
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEventWrapper(pedBeatrice.id, "M_2_S06", 29, "jumbo")
		PedFollowPath(pedBeatrice.id, PATH._2_S06B_BEATRICEPANIC, 0, 2, F_routeBeatricePanic)
	end
	if not bSkipFirstCutscene then
		WaitSkippable(1000)
	end
	if not bSkipFirstCutscene then
		CameraSetXYZ(-447.16583, 309.03235, -1.584784, -448.12115, 309.32724, -1.601944)
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(pedBeatrice.id)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEventWrapper(pedPinkyUW.id, "M_2_S06", 30, "jumbo")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(500)
	end
	if not bSkipFirstCutscene then
		PedFaceObject(pedArtTeacher.id, gPlayer, 3, 1)
	end
	if not bSkipFirstCutscene then
		WaitSkippable(500)
	end
	if not bSkipFirstCutscene then
		CameraSetXYZ(-455.10358, 307.92566, -1.245505, -455.94086, 308.46814, -1.313119)
	end
	if not bSkipFirstCutscene then
		WaitSkippable(500)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEventWrapper(pedArtTeacher.id, "M_2_S06", 42, "jumbo")
	end
	if not bSkipFirstCutscene then
		gTimerFireAlarm = GetTimer()
		while not bBeatriceHitAlarm do
			if gTimerFireAlarm + 4000 <= GetTimer() then
				bBeatriceHitAlarm = true
			end
			if bSkipFirstCutscene then
				break
			end
			WaitSkippable(1)
		end
	end
	if not bSkipFirstCutscene then
		SoundStartFireAlarm()
		SoundPlay2D("Sprinklers")
		PedWander(pedBeatrice.id, 1)
		F_CreateSprinklers()
		bStartedAlarm = true
		CameraSetXYZ(-446.59872, 298.48163, 0.678324, -446.94153, 299.3774, 0.39566)
	end
	if not bSkipFirstCutscene then
		WaitSkippable(2500)
	end
	bSkipFirstCutscene = true
end

function T_ShowerScream()
	SoundPlayScriptedSpeechEventWrapper(pedGirlsShower_02.id, "M_2_S06", 75, "large")
	Wait(250)
	SoundPlayScriptedSpeechEventWrapper(pedGirlsShower_01.id, "M_2_S06", 75, "large")
	F_WaitForSpeech(pedGirlsShower_01.id)
	SoundPlayScriptedSpeechEventWrapper(pedGirlsShower_02.id, "M_2_S06", 76, "large")
end

function F_LaunchStage2Trigger02()
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchStage2Trigger02()")
	local bustX, bustY, bustZ = GetPointList(POINTLIST._2_S06B_BUSTPLAYER)
	bBustPlayer = false
	CreateThread("T_ShowerScream")
	Wait(500)
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(500)
	PlayerSetPosSimple(bustX, bustY, bustZ)
	PedSetPosPoint(shared.gdormHeadID, POINTLIST._2_S06B_HEADWARP, 1)
	PedStop(shared.gdormHeadID)
	PedClearObjectives(shared.gdormHeadID)
	PedSetStationary(shared.gdormHeadID, true)
	PedLockTarget(shared.gdormHeadID, gPlayer, 3)
	PedFaceObject(gPlayer, shared.gdormHeadID, 2, 0)
	CameraSetXYZ(-433.60767, 302.2722, -1.009889, -432.98334, 303.05325, -1.010671)
	CameraSetWidescreen(true)
	CameraFade(500, 1)
	Wait(1000)
	F_PlayerSpotted(shared.gdormHeadID)
	F_CutBootedOut()
	F_EjectPlayerFromDorm()
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchStage2Trigger02()")
end

function F_LaunchStage2Trigger03()
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchStage2Trigger03()")
	PedFollowPath(pedEunice.id, PATH._2_S06B_ROUTEGIRLS_E, 0, 0, F_routeGirls_E, 4)
	SoundPlayScriptedSpeechEventWrapper(pedEunice.id, "M_2_S06", 22)
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchStage2Trigger03()")
end

function F_routeGirls_E(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeGirls_E() @ node: " .. nodeID)
	if nodeID == 14 then
		bDeleteEunice = true
	end
end

function F_routeCutHead(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeCutHead() @ node: " .. nodeID)
end

function F_routeCutFlee(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeCutFlee() @ node: " .. nodeID)
end

function F_routeBusted(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBusted() @ node: " .. nodeID)
	if nodeID == 4 then
		if pedID == pedStg1Pref.id then
			bCleanupBustedPref = true
		else
			bCleanupBustedJock = true
		end
	end
end

function F_routeBurtonLeave(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBurtonLeave() @ node: " .. nodeID)
	if nodeID == 2 then
		bCleanupBurton = true
	end
end

function F_routeJimmyOutro(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeJimmyOutro() @ node: " .. nodeID)
	if nodeID == 1 then
		bRouteJimmyOutro = true
	end
end

function F_routeBurtonOutro(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBurtonOutro() @ node: " .. nodeID)
	if nodeID == 3 then
		bRouteBurtonOutro = true
	end
end

function F_routeBeatricePanic(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBeatricePanic() @ node: " .. nodeID)
	if nodeID == 4 then
		PedSetActionNode(pedID, "/Global/2_S06/Anims/HitFireAlarm02", "Act/Conv/2_S06.act")
		bBeatriceHitAlarm = true
	end
end
