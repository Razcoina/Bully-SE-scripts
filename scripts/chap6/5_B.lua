ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
local edgar
local DropOutTable = {}
local PlayerEnters = true
local EdgarInElevator = false
local ELEVATOR_DOWN = false
local SetUpStage2 = true
local mission_running = true
local mission_passed = false
local STAGE_NUM = 1
local Progress_Check = 0
local camerashots = true
local FinalStage = 1
local gSetupEnded = false
local gFirstObj, gSecondObj, gThirdObj
local Debug = false
local gEdgarHealth = 0
local elevatorindex, gelevator = PAnimGetPoolIndex("CH_Elevator", -761.366, 92.5378, 46.8435, 5)
local ElevDoorCIndex, gElevDoorC = PAnimGetPoolIndex("CH_ElevDoorC", -761.79, 91.7649, 7.61579, 5)
local ElevDoorDIndex, gElevDoorD = PAnimGetPoolIndex("CH_ElevDoorD", -760.941, 91.7649, 7.6158, 5)

function MissionInit()
	CameraFade(500, 0)
	Wait(500)
	SoundEnableInteractiveMusic(false)
	SoundDisableSpeech_ActionTree()
	LoadAnimationGroup("DO_STRIKECOMBO")
	LoadAnimationGroup("BOXING")
	LoadAnimationGroup("C_Wrestling")
	DisablePunishmentSystem(true)
	LoadActionTree("Act/Anim/DO_Edgar.act")
	LoadActionTree("Act/AI/AI_EDGAR_5_B.act")
	LoadActionTree("Act/Conv/5_B.act")
	LoadModels({
		387,
		388,
		389,
		342,
		402,
		401,
		384
	}, true)
	AreaSetDoorLocked("5_B_CHEM_DOOR", true)
	AreaSetDoorLocked("5_B_CHEM_DOOR_2", true)
	AreaSetDoorLocked("DT_ChemPlant_DoorL", true)
	PedSaveWeaponInventorySnapshot(gPlayer)
	if PlayerGetHealth() < 200 then
		PlayerSetHealth(200)
	end
	PedSetFlag(gPlayer, 58, true)
	PAnimCreate(TRIGGER._5_B_SECDOOR1)
	PAnimCreate(TRIGGER._5_B_SECDOOR2)
	AreaSetDoorLocked(TRIGGER._5_B_SECDOOR1, true)
	AreaSetDoorLocked(TRIGGER._5_B_SECDOOR2, true)
	PlayerSetPosPoint(POINTLIST._5_B_START)
	while AreaIsLoading() do
		Wait(0)
	end
	PAnimResetAllDamageable(true)
	F_ResetStuff()
	if IsMissionFromDebug() then
		AreaForceLoadAreaByAreaTransition(true)
		AreaTransitionPoint(20, POINTLIST._5_B_START, nil, true)
		AreaForceLoadAreaByAreaTransition(false)
	end
end

function MissionSetup()
	gSetupEnded = false
	MissionDontFadeIn()
	DATLoad("5_Ba.DAT", 2)
	DATInit()
	gSetupEnded = true
end

function CreateDropOuts()
	while not PedRequestModel(91) do
		Wait(0)
	end
	edgar = PedCreatePoint(91, POINTLIST._5_B_EDGAR)
	PedSetInfiniteSprint(edgar, true)
	PedSetEffectedByGravity(edgar, false)
	PedSetActionTree(edgar, "/Global/DO_Edgar", "Act/Anim/DO_Edgar.act")
	PedOverrideStat(edgar, 34, 0)
	PedOverrideStat(edgar, 8, 85)
	PedSetPedToTypeAttitude(edgar, 13, 4)
	PedSetFlag(edgar, 107, true)
	PedSetDamageTakenMultiplier(edgar, 3, 0.2)
	PedSetDamageTakenMultiplier(edgar, 0, 0.3)
	gEdgarHealth = PedGetMaxHealth(edgar)
	--print("EDGARS HEALTH:", gEdgarHealth)
	PedIgnoreStimuli(edgar, true)
end

function MissionCleanup()
	if bSteamOn then
		F_SteamOff()
	end
	SoundEnableSpeech_ActionTree()
	CameraSetWidescreen(false)
	CameraReset()
	F_MakePlayerSafeForNIS(false, false)
	DisablePunishmentSystem(false)
	DATUnload(2)
	CameraAllowChange(true)
	SoundEnableInteractiveMusic(true)
	CameraReturnToPlayer()
	SoundFadeoutStream()
	PlayerIgnoreTargeting(false)
	PlayerSetControl(1)
	PedSetAIButes("Default")
	UnLoadAnimationGroup("DO_STRIKECOMBO")
	UnLoadAnimationGroup("BOXING")
	PedHideHealthBar()
	CameraAllowChange(true)
	CameraReturnToPlayer()
	FollowCamDefaultFightShot()
	PedSetFlag(gPlayer, 58, false)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	if PedHasWeapon(gPlayer, 342) then
		PedDestroyWeapon(gPlayer, 342)
	end
end

function main()
	MissionInit()
	F_InitDoors()
	while not gSetupEnded do
		Wait(0)
	end
	CreateDropOuts()
	TextPrint("5_B_obj1", 3, 1)
	gFirstObj = MissionObjectiveAdd("5_B_obj1")
	CreateThread("T_ElevatorControl")
	CreateThread("T_CameraShots")
	CreateThread("T_SLUDGECHECK")
	SoundPlayStream("MS_ShowdownAtThePlantLow.rsm", 0.5, 500, 0)
	--print("ATTEMPTCOUNT", tostring(GetMissionCurrentAttemptCount()))
	while mission_running do
		if STAGE_NUM == 1 then
			StageOne()
		elseif STAGE_NUM == 2 then
			StageTwo()
		elseif STAGE_NUM == 3 then
			StageThree()
		elseif STAGE_NUM == 4 then
			StageFour()
		end
		if F_PlayerIsDead() then
			mission_running = false
		end
		Wait(0)
	end
	if mission_passed then
		UnLoadAnimationGroup("DO_STRIKECOMBO")
		UnLoadAnimationGroup("BOXING")
		UnLoadAnimationGroup("C_Wrestling")
		ModelNotNeeded(387)
		ModelNotNeeded(388)
		ModelNotNeeded(389)
		ModelNotNeeded(342)
		ModelNotNeeded(402)
		ModelNotNeeded(401)
		ModelNotNeeded(384)
		PlayCutsceneWithLoad("5-BC", true)
		SoundStopInteractiveStream(0)
		SoundEnableInteractiveMusic(false)
		F_MakePlayerSafeForNIS(true, false)
		if edgar and PedIsValid(edgar) then
			PedDelete(edgar)
		end
		PlayerSetControl(0)
		AreaTransitionPoint(0, POINTLIST._5_B_END, 1, true)
		CameraReset()
		CameraReturnToPlayer()
		edgar = PedCreatePoint(91, POINTLIST._5_B_END, 2)
		PedFaceObject(gPlayer, edgar, 2, 0)
		PedFaceObject(edgar, gPlayer, 3, 0)
		PedIgnoreStimuli(edgar, true)
		PedDeleteWeaponInventorySnapshot(gPlayer)
		CameraSetWidescreen(true)
		AreaClearAllPeds()
		CameraLookAtXYZ(113.09775, -513.05524, 4.421984, true)
		CameraSetXYZ(111.42491, -513.4068, 4.782094, 113.09775, -513.05524, 4.421984)
		CameraFade(-1, 1)
		F_PlaySpeechAndWait(edgar, "M_5_B", 20, "jumbo")
		PedMoveToPoint(edgar, 0, POINTLIST._5_B_END, 3)
		F_PlaySpeechAndWait(gPlayer, "M_5_B", 42)
		Wait(1000)
		PedDelete(edgar)
		SoundDisableSpeech_ActionTree()
		MinigameSetCompletion("M_PASS", true, 0)
		MinigameAddCompletionMsg("MRESPECT_DP100", 2)
		SoundPlayMissionEndMusic(true, 10)
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		SetFactionRespect(3, GetFactionRespect(3) + 100)
		UnlockYearbookPicture(91)
		F_UnlockYearbookReward()
		MissionSucceed(false, false, false)
	else
		gSetupEnded = false
		MinigameSetCompletion("M_FAIL", false)
		PedRestoreWeaponInventorySnapshot(gPlayer)
		SoundPlayMissionEndMusic(false, 10)
		MissionDontFadeInAfterCompetion()
		MissionFail(true, true, "M_FAIL_DEAD")
	end
end

function StageOne()
	if PlayerEnters then
		if shared.edgarFightStarted then
			PedSetInvulnerable(edgar, true)
			SoundPlayScriptedSpeechEvent(edgar, "M_5_B", 21, "supersize")
			gEdgarBlip = AddBlipForChar(edgar, 2, 26, 4)
			GeometryInstance("CH_ElevShaft", false, -761.366, 92.6547, 13.0598, true)
			elevatorindex, gelevator = PAnimGetPoolIndex("CH_Elevator", -761.366, 92.5378, 46.8435, 5)
			PAnimFollowPath(elevatorindex, gelevator, PATH._5_B_ELEVATOR_DOWN, false, CB_ElevatorDone)
			PAnimSetPathFollowSpeed(elevatorindex, gelevator, 5.55)
			PedSetEffectedByGravity(edgar, true)
			EdgarInElevator = true
			MissionObjectiveComplete(gFirstObj)
			gSecondObj = MissionObjectiveAdd("5_B_obj2")
			Wait(500)
			PedStop(edgar)
			PedClearObjectives(edgar)
			PedFaceObject(edgar, gPlayer, 3, 1)
			gEdgarInElevatorTime = GetTimer()
			local x, y, z = GetPointFromPointList(POINTLIST._5_B_DEBUG_STAGE3, 2)
			PlayerSetPosSimple(x, y, z)
			PlayerEnters = false
		else
			if not cameraFadedIn then
				CameraFade(500, 1)
				Wait(500)
				cameraFadedIn = true
			end
			if PlayerIsInTrigger(TRIGGER._5_B_ENTRANCE) or F_PedIsHitByPlayer(edgar) then
				PedSetInvulnerable(edgar, true)
				SoundPlayScriptedSpeechEvent(edgar, "M_5_B", 21, "supersize")
				gEdgarBlip = AddBlipForChar(edgar, 2, 26, 4)
				if not EdgarInElevator then
					GeometryInstance("CH_ElevShaft", false, -761.366, 92.6547, 13.0598, true)
					elevatorindex, gelevator = PAnimGetPoolIndex("CH_Elevator", -761.366, 92.5378, 46.8435, 5)
					PAnimFollowPath(elevatorindex, gelevator, PATH._5_B_ELEVATOR_DOWN, false, CB_ElevatorDone)
					PAnimSetPathFollowSpeed(elevatorindex, gelevator, 1)
					SoundLoopPlayOnPed(edgar, "ChemElevator", true, "large")
					PedSetEffectedByGravity(edgar, true)
					EdgarInElevator = true
					MissionObjectiveComplete(gFirstObj)
					TextPrint("5_B_obj2", 3, 1)
					gSecondObj = MissionObjectiveAdd("5_B_obj2")
					Wait(500)
					PedStop(edgar)
					PedClearObjectives(edgar)
					PedFaceObject(edgar, gPlayer, 3, 1)
					gEdgarInElevatorTime = GetTimer()
					PlayerEnters = false
				end
			end
		end
	end
	if ELEVATOR_DOWN then
		--print("==Start Stage 2==")
		SoundLoopPlayOnPed(edgar, "ChemElevator", false)
		F_OpenElevatorDoors()
		Wait(1000)
		if not shared.edgarFightStarted then
			BlipRemove(gEdgarBlip)
			local x, y, z = PedGetPosXYZ(edgar)
			gEdgarBlip = BlipAddXYZ(x, y, z, 26, 1)
			PedMoveToXYZ(edgar, 2, -768.036, 64.8435, 6.19969)
		end
		STAGE_NUM = 2
	elseif EdgarInElevator and GetTimer() - gEdgarInElevatorTime > 3000 then
		SoundPlayScriptedSpeechEvent(edgar, "M_5_B", 23)
		gEdgarInElevatorTime = GetTimer()
	end
end

function Stage2SetUp()
end

function StageTwo()
	if SetUpStage2 then
		Stage2SetUp()
		SetUpStage2 = false
	end
	if not gEdgarMoved and PedIsInAreaXYZ(edgar, -768.036, 64.8435, 6.19969, 2, 0) then
		PedSetPosPoint(edgar, POINTLIST._5_B_PLAYERENDNIS)
		gEdgarMoved = true
	end
	if PlayerIsInTrigger(TRIGGER._5_B_STAGE2_START) and 0 < PlayerGetHealth() then
		--print("==Start Stage 3==")
		Wait(2000)
		if 0 < PlayerGetHealth() then
			SoundFadeoutStream()
			SoundPlayStream("MS_ShowdownAtThePlantHigh.rsm", 0.6, 500, 0)
			CS_EDGAR_PIPE()
			STAGE_NUM = 3
		end
	end
end

function CS_EDGAR_PIPE()
	shared.edgarFightStarted = true
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(500, 0)
	Wait(500)
	PlayerSetControl(0)
	PedStop(edgar)
	PedClearObjectives(edgar)
	PedSetPosPoint(edgar, POINTLIST._5_B_EDGARINNIS)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	CameraSetXYZ(-763.0238, 72.357956, 8.178526, -763.2157, 73.30806, 7.932799)
	PedSetPosPoint(gPlayer, POINTLIST._5_B_DEBUG_STAGE3, 2)
	gShield = PickupCreatePoint(387, POINTLIST._5_B_FALLEN_SHIELD, 1, 360, "PermanentMission")
	Wait(500)
	CameraFade(500, 1)
	Wait(500)
	SoundPlayScriptedSpeechEvent(edgar, "M_5_B", 22, "jumbo")
	BlipRemove(gEdgarBlip)
	gEdgarBlip = AddBlipForChar(edgar, 2, 26, 4)
	PedMoveToPoint(edgar, 2, POINTLIST._5_B_DEBUG_STAGE3, 1)
	local x, y, z = GetPointList(POINTLIST._5_B_FALLEN_SHIELD)
	local waitEdgar = GetTimer()
	while not PedIsInTrigger(edgar, TRIGGER._5_B_GRAB_GOOD) do
		if GetTimer() - waitEdgar > 5000 then
			PedSetPosPoint(edgar, POINTLIST._5_B_DEBUG_STAGE3, 1)
		end
		Wait(0)
	end
	F_CloseElevatorDoors()
	PedMoveToXYZ(gPlayer, 1, x, y, z)
	PedSetActionNode(edgar, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
	while not PedHasWeapon(edgar, 342) do
		Wait(0)
	end
	while not PedIsInAreaXYZ(gPlayer, x, y, z, 1, 0) do
		Wait(0)
	end
	CameraLookAtXYZ(-769.623, 81.1636, 7.4702454, true)
	CameraSetXYZ(-772.4813, 82.236694, 8.010293, -769.623, 81.1636, 7.4702454)
	F_MakePlayerSafeForNIS(false)
	Wait(500)
	PedSetActionNode(gPlayer, "/Global/Weapons/PickUpActions/Pickup", "Act/Weapons.act")
	PedFaceObject(gPlayer, edgar, 2, 1)
	TutorialShowMessage("5_B_Tut1", 5000, true)
	Wait(500)
	SoundPlayScriptedSpeechEvent(edgar, "M_5_B", 2, "jumbo")
	CreateThread("T_ShieldBlips")
end

function StageThree()
	Stage3Setup()
	PedSetInvulnerable(edgar, false)
	PedSetAITree(edgar, "/Global/AI_EDGAR_5_B", "Act/AI/AI_EDGAR_5_B.act")
	PedSetPedToTypeAttitude(edgar, 13, 0)
	PedOverrideStat(edgar, 13, 90)
	Wait(500)
	CameraSetWidescreen(false)
	CameraReturnToPlayer(false)
	Wait(100)
	SoundSetAudioFocusPlayer()
	PlayerSetControl(1)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	PedAttack(edgar, gPlayer, true, false)
	MissionObjectiveComplete(gSecondObj)
	TextPrint("MEN_BLANK", 1, 1)
	gThirdObj = MissionObjectiveAdd("5_B_obj3", 0, -1)
	NoShieldYet = true
	SoundPlayScriptedSpeechEvent(edgar, "M_5_B", 1, "jumbo")
	while not EdgarShieldDestroyed() do
		if F_PlayerIsDead() then
			break
		end
		if not secondTutorial and not PlayerHasWeapon(387) and not PlayerHasWeapon(388) then
			secondTutorial = true
			TutorialShowMessage("5_B_Tut2", 5000, true)
		end
		if not PlayerHasWeapon(387) then
			if 1 >= DistanceBetweenPeds2D(gPlayer, edgar) and PedIsPlaying(edgar, "/Global/DO_Edgar/Default_KEY/CustomLoco", true) and (not PedIsPlaying(gPlayer, "/Global/HitTree/Standing/PostHit", true) or PedIsPlaying(gPlayer, "/Global/WProps/PropInteract/PropInteractLoco", true)) then
				--print("==Hit the player==")
				if NoShieldYet then
					SoundPlayScriptedSpeechEvent(edgar, "M_5_B", 1, "jumbo")
				end
			end
		elseif not gSpokeNo2 and (PedIsPlaying(gPlayer, "/Global/pxCshld/PedPropsActions", true) or PlayerHasWeapon(387)) then
			gSpokeNo2 = true
			NoShieldYet = false
		end
		Wait(0)
	end
	PedSetInvulnerable(edgar, true)
	PedStop(edgar)
	PedClearObjectives(edgar)
	PedIgnoreStimuli(edgar, true)
	--print("==Start Stage 4==")
	STAGE_NUM = 4
	SoundFadeoutStream()
	SoundPlayStream("MS_ShowdownAtThePlantLow.rsm", 0.5, 500, 0)
end

function Stage3Setup()
	if Debug then
		PedSetPosPoint(edgar, POINTLIST._5_B_DEBUG_STAGE3, 1)
		PedSetPosPoint(gPlayer, POINTLIST._5_B_DEBUG_STAGE3, 2)
		Debug = false
	end
	camerashots = false
	PedSetAIButes("5_B")
	PedShowHealthBar(edgar, true, "5_B_01", true)
	Wait(500)
end

function StageFour()
	if Debug then
		PedSetPosPoint(edgar, POINTLIST._5_B_DEBUG_STAGE4, 1)
		PedSetPosPoint(gPlayer, POINTLIST._5_B_DEBUG_STAGE4, 2)
		Debug = false
	elseif FinalStage == 1 then
		PedSetWeapon(edgar, -1, 0)
		PedStop(edgar)
		PedClearObjectives(edgar)
		PedFollowPath(edgar, PATH._5_B_EDGARTOSTAIRS, 0, 2)
		PedSetFlag(edgar, 13, true)
		PedStop(edgar)
		PedClearObjectives(edgar)
		PedIgnoreStimuli(edgar, true)
		--print("===follow the path damn you===")
		AreaSetDoorLocked(TRIGGER._5_B_CHEM_DOOR_2, true)
		AreaSetDoorLockedToPeds(TRIGGER._5_B_CHEM_DOOR_2, false)
		AreaSetDoorLocked(TRIGGER._5_B_CHEM_DOOR, true)
		AreaSetDoorLockedToPeds(TRIGGER._5_B_CHEM_DOOR, false)
		PedStop(edgar)
		PedClearObjectives(edgar)
		Wait(200)
		PedFollowPath(edgar, PATH._5_B_EDGARTOSTAIRS, 0, 2, CbEdgarToStairs)
		FinalStage = 2
	elseif FinalStage == 2 then
		F_CheckSteamDamage()
		if gReachedFirstNode then
			F_SteamOn()
			gReachedFirstNode = nil
		end
		if PlayerIsInTrigger(TRIGGER._5_B_LOWSTAIRCASE) then
			CameraFade(-1, 0)
			PlayerSetControl(0)
			F_MakePlayerSafeForNIS(true)
			Wait(FADE_OUT_TIME)
			SoundPlayStream("MS_RussellInTheHole.rsm", 0.7, 500, 0)
			local x, y, z = GetPointList(POINTLIST._5_B_PLAYERENDNIS)
			PlayerSetPosSimple(x, y, z)
			CameraSetWidescreen(true)
			PAnimCloseDoor(TRIGGER._5_B_CHEM_DOOR_2)
			AreaSetDoorLocked(TRIGGER._5_B_CHEM_DOOR_2, true)
			PAnimCloseDoor(TRIGGER._5_B_CHEM_DOOR)
			PedFaceObject(gPlayer, edgar, 2, 0)
			PedFaceObject(edgar, gPlayer, 3, 0)
			CameraLookAtXYZ(-760.4742, 78.22133, 1.4042269, true)
			CameraSetXYZ(-764.6866, 78.42735, 1.9094418, -760.4742, 78.22133, 1.4042269)
			CameraFade(-1, 1)
			PedSetActionNode(edgar, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
			Wait(2000)
			SoundPlayScriptedSpeechEvent(edgar, "M_5_B", 24, "large")
			PedStop(edgar)
			PedClearObjectives(edgar)
			PedMoveToPoint(edgar, 0, POINTLIST._5_B_EDGARMOVETO)
			Wait(2000)
			F_SetUpEdgarFinal()
			CameraReturnToPlayer()
			CameraReset()
			TutorialShowMessage("5_B_Tut3", 5000, true)
			F_MakePlayerSafeForNIS(false)
			PlayerSetControl(1)
			CameraSetWidescreen(false)
			CreateThread("T_PipeBlips")
			PedSetStationary(edgar, true)
			gTimeFinalStart = GetTimer()
			FinalStage = 3
		end
	elseif FinalStage == 3 then
		if not gStartingUp and (PlayerHasWeapon(342) or PlayerHasWeapon(402) or PlayerHasWeapon(401) or PlayerHasWeapon(384) or PedIsHit(edgar, 2, 1000) or GetTimer() - gTimeFinalStart > 8000) then
			gStartingUp = true
			PedSetStationary(edgar, false)
			PedAttackPlayer(edgar)
		end
		if not gWeaponRemark and PlayerHasWeapon(342) then
			gWeaponRemark = true
			SoundPlayScriptedSpeechEvent(edgar, "M_5_B", 4, "jumbo")
		end
		if PedIsDead(edgar) then
			--print("==Mission Passed==")
			MissionObjectiveComplete(gThirdObj)
			CameraAllowChange(true)
			FollowCamDefaultFightShot()
			CameraReturnToPlayer()
			Wait(1500)
			mission_running = false
			mission_passed = true
		end
	end
end

function F_SetUpEdgarFinal()
	Wait(1000)
	PedSetFlag(edgar, 13, false)
	PedIgnoreStimuli(edgar, false)
	PedSetInvulnerable(edgar, false)
	PedOverrideStat(edgar, 13, 70)
	PedAttack(edgar, gPlayer, 3)
end

function EdgarShieldDestroyed()
	if not PedHasWeapon(edgar, 342) and PedHasWeapon(edgar, 402) == false and PedHasWeapon(edgar, 401) == false and PedHasWeapon(edgar, 384) == false then
		Wait(2000)
		return true
	elseif PedGetHealth(edgar) <= gEdgarHealth * 2 / 3 then
		PedSetWeapon(edgar, -1, 0)
		--print("========hellloooo===========")
		return true
	else
		return false
	end
end

function T_RUNEDGAR()
	--print("Start Thread===")
	PedSetWeaponNow(edgar, -1, 0)
	PedStop(edgar)
	PedClearObjectives(edgar)
	PedFollowPath(edgar, PATH._5_B_EDGARTOSTAIRS, 0, 2)
	PedSetFlag(edgar, 13, true)
	PedIgnoreStimuli(edgar, true)
	PAnimOpenDoor(TRIGGER._5_B_CHEM_DOOR_2)
	PAnimOpenDoor(TRIGGER._5_B_CHEM_DOOR)
	PAnimDoorStayOpen(TRIGGER._5_B_CHEM_DOOR_2)
	PAnimDoorStayOpen(TRIGGER._5_B_CHEM_DOOR)
	FinalStage = 2
	--print("====try number 2=====")
	Wait(1000)
	PedStop(edgar)
	PedClearObjectives(edgar)
	PedFollowPath(edgar, PATH._5_B_EDGARTOSTAIRS, 0, 2)
	Wait(1000)
	--print("========try 3==")
	PedStop(edgar)
	PedClearObjectives(edgar)
	PedFollowPath(edgar, PATH._5_B_EDGARTOSTAIRS, 0, 2, CbEdgarToStairs)
end

function F_OpenElevatorDoors()
	ElevDoorCIndex, gElevDoorC = PAnimGetPoolIndex("CH_ElevDoorC", -761.79, 91.7649, 7.61579, 5)
	ElevDoorDIndex, gElevDoorD = PAnimGetPoolIndex("CH_ElevDoorD", -760.941, 91.7649, 7.6158, 5)
	PAnimFollowPath(ElevDoorCIndex, gElevDoorC, PATH._5_B_ELEVATOR_C, false)
	PAnimSetPathFollowSpeed(ElevDoorCIndex, gElevDoorC, 0.5)
	PAnimFollowPath(ElevDoorDIndex, gElevDoorD, PATH._5_B_ELEVATOR_D, false)
	PAnimSetPathFollowSpeed(ElevDoorDIndex, gElevDoorD, 0.5)
end

function F_CloseElevatorDoors()
	ElevDoorCIndex, gElevDoorC = PAnimGetPoolIndex("CH_ElevDoorC", -761.79, 91.7649, 7.61579, 5)
	ElevDoorDIndex, gElevDoorD = PAnimGetPoolIndex("CH_ElevDoorD", -760.941, 91.7649, 7.6158, 5)
	PAnimFollowPath(ElevDoorCIndex, gElevDoorC, PATH._5_B_EC_CLOSE, false)
	PAnimSetPathFollowSpeed(ElevDoorCIndex, gElevDoorC, 0.5)
	PAnimFollowPath(ElevDoorDIndex, gElevDoorD, PATH._5_B_ED_CLOSE, false)
	PAnimSetPathFollowSpeed(ElevDoorDIndex, gElevDoorD, 0.5)
end

function F_InitDoors()
	PAnimFollowPath(TRIGGER._5_B_SECDOOR1, PATH._5_B_DOORA_OPEN, false, F_DoorsOpenClosed_Callback)
	PAnimFollowPath(TRIGGER._5_B_SECDOOR2, PATH._5_B_DOORB_OPEN, false, F_DoorsOpenClosed_Callback)
	PAnimSetPathFollowSpeed(TRIGGER._5_B_SECDOOR1, 0)
	PAnimSetPathFollowSpeed(TRIGGER._5_B_SECDOOR2, 0)
	gClosingDoor = false
	SoundLoopPlay2D("ChemDoorClose", false)
	gOpeningDoor = false
	SoundLoopPlay2D("ChemDoorOpen", false)
end

function F_OpenDoors()
	--print("Opening Doors")
	gDoorEnded = false
	if gClosingDoor then
		gClosingDoor = false
		SoundLoopPlay2D("ChemDoorClose", false)
	end
	gOpeningDoor = true
	SoundLoopPlay2D("ChemDoorOpen", true)
	PAnimSetPathFollowSpeed(TRIGGER._5_B_SECDOOR1, 0.5)
	PAnimSetPathFollowSpeed(TRIGGER._5_B_SECDOOR2, 0.5)
end

function F_CloseDoors()
	--print("Closing Doors")
	gDoorEnded = false
	if gOpeningDoor then
		gOpeningDoor = false
		SoundLoopPlay2D("ChemDoorOpen", false)
	end
	gClosingDoor = true
	if gSetupEnded then
		SoundLoopPlay2D("ChemDoorClose", true)
	end
	PAnimSetPathFollowSpeed(TRIGGER._5_B_SECDOOR1, -0.5)
	PAnimSetPathFollowSpeed(TRIGGER._5_B_SECDOOR2, -0.5)
end

function F_DoorsOpenClosed_Callback(propId, pathId, pathNode)
	--print("CALLBACK FOR DOORS ", propId)
	if pathNode == 0 then
		gDoorEnded = true
	elseif pathNode == 1 then
		gDoorEnded = true
	end
	if gDoorEnded then
		if gOpeningDoor then
			SoundLoopPlay2D("ChemDoorOpen", false)
		elseif gClosingDoor then
			SoundLoopPlay2D("ChemDoorClose", false)
		end
		SoundPlay2D("ChemDoorClunk")
	end
end

function T_ShieldBlips()
	local shieldBlips = {}
	local bx, by, bz = 0, 0, 0
	for i = 1, 5 do
		bx, by, bz = GetPointFromPointList(POINTLIST._5_B_SHIELDBLIPS, i)
		shieldBlips[i] = BlipAddXYZ(bx, by, bz, 0, 2)
	end
	local playerHasShield = false
	while mission_running do
		if playerHasShield then
			if not PlayerHasWeapon(387) then
				playerHasShield = false
			end
		elseif PlayerHasWeapon(387) then
			for i = 1, 5 do
				if shieldBlips[i] then
					bx, by, bz = GetPointFromPointList(POINTLIST._5_B_SHIELDBLIPS, i)
					if PlayerIsInAreaXYZ(bx, by, 6.46825, 1, 0) then
						BlipRemove(shieldBlips[i])
						shieldBlips[i] = nil
						break
					end
				end
			end
			playerHasShield = true
		end
		if STAGE_NUM == 4 then
			break
		end
		Wait(0)
	end
	for i = 1, 5 do
		if shieldBlips[i] then
			BlipRemove(shieldBlips[i])
			shieldBlips[i] = nil
		end
	end
end

function T_PipeBlips()
	local pipeBlips = {}
	local bx, by, bz = 0, 0, 0
	for i = 1, 2 do
		bx, by, bz = GetPointFromPointList(POINTLIST._5_B_PIPEBLIPS, i)
		pipeBlips[i] = BlipAddXYZ(bx, by, bz, 0, 2)
	end
	local playerHasPipe = false
	while mission_running do
		if playerHasPipe then
			if not PlayerHasWeapon(342) then
				playerHasPipe = false
			end
		elseif PlayerHasWeapon(342) then
			for i = 1, 2 do
				if pipeBlips[i] then
					bx, by, bz = GetPointFromPointList(POINTLIST._5_B_PIPEBLIPS, i)
					if PlayerIsInAreaXYZ(bx, by, 0.289442, 1, 0) then
						BlipRemove(pipeBlips[i])
						pipeBlips[i] = nil
						break
					end
				end
			end
			playerHasPipe = true
		end
		Wait(0)
	end
	for i = 1, 2 do
		if pipeBlips[i] then
			BlipRemove(pipeBlips[i])
			pipeBlips[i] = nil
		end
	end
end

function T_ElevatorControl()
	while mission_running do
		if PlayerIsInTrigger(TRIGGER._5_B_LIFTUP) then
			if IsButtonPressed(9, 0) then
				--print("=========Elevator down===============")
				PAnimFollowPath(elevatorindex, gelevator, PATH._5_B_ELEVATOR_DOWN, false)
				PAnimSetPathFollowSpeed(elevatorindex, gelevator, 1)
			end
		elseif PlayerIsInTrigger(TRIGGER._5_B_LIFTDOWN) and IsButtonPressed(9, 0) then
			--print("=========Elevator down===============")
			PAnimFollowPath(elevatorindex, gelevator, PATH._5_B_ELEVATOR_UP, false)
			PAnimSetPathFollowSpeed(elevatorindex, gelevator, 1)
		end
		Wait(0)
	end
end

function F_SteamOn()
	gSteam = {}
	local n = GetPointListSize(POINTLIST._5_B_STEAM)
	for i = 1, n do
		gSteam[i] = FXCreateWithDirection("steam_pipe", POINTLIST._5_B_STEAM, i, 0.01, 0.02, 0.1)
	end
	gSteamOnTimer = GetTimer()
	bSteamOn = true
end

function F_SteamOff()
	if bSteamOn then
		for _, steam in gSteam do
			EffectSlowKill(steam)
		end
	end
	bSteamOn = false
end

function FXCreateWithDirection(effect, point, e, dx, dy, dz)
	local x, y, z = GetPointFromPointList(point, e)
	local fx = EffectCreate(effect, x, y, z)
	if dx and dy and dz then
		EffectSetDirection(fx, dx, dy, dz)
	end
	return fx
end

function F_CheckSteamDamage()
	if bSteamOn then
		if PlayerIsInTrigger(TRIGGER._5_B_STEAMAREA) and PlayerGetHealth() > 0 and not PedIsPlaying(gPlayer, "/Global/5_B/Reactions/SteamReaction", false) then
			PedSetActionNode(gPlayer, "/Global/5_B/Reactions/SteamReaction", "Act/Conv/5_B.act")
		end
		if GetTimer() - gSteamOnTimer > 5000 then
			F_SteamOff()
		end
	end
end

function CbEdgarToStairs(pedId, path, node)
	if node == 1 then
		--print("[RAUL] - Edgar Node 1")
		gReachedFirstNode = true
		PAnimOpenDoor(TRIGGER._5_B_CHEM_DOOR_2)
		PAnimOpenDoor(TRIGGER._5_B_CHEM_DOOR)
		PAnimDoorStayOpen(TRIGGER._5_B_CHEM_DOOR_2)
		PAnimDoorStayOpen(TRIGGER._5_B_CHEM_DOOR)
		AreaSetDoorLocked(TRIGGER._5_B_CHEM_DOOR_2, false)
		AreaSetDoorLocked(TRIGGER._5_B_CHEM_DOOR, false)
		PedSetActionNode(edgar, "/Global/5_B/Reactions/RunShoulder", "Act/Conv/5_B.act")
		SoundPlay3D(-769.089, 63.4668, 7.6697, "PipeSteam", "jumbo")
	elseif node == 14 then
		--print("[RAUL] - Edgar Node 14")
		gEdgarInLastNode = true
	end
end

function CB_ElevatorDone(ped, path, node)
	if node == 1 then
		--print("==Elevator Completed==")
		ELEVATOR_DOWN = true
	end
end

function F_ResetStuff()
	PAnimFollowPath(elevatorindex, gelevator, PATH._5_B_ELEVATOR_DOWN, false)
	PAnimFollowPathReset(elevatorindex, gelevator)
	F_InitDoors()
	PAnimFollowPath(ElevDoorCIndex, gElevDoorC, PATH._5_B_ELEVATOR_C, false)
	PAnimFollowPathReset(ElevDoorCIndex, gElevDoorC)
	PAnimFollowPath(ElevDoorDIndex, gElevDoorD, PATH._5_B_ELEVATOR_D, false)
	PAnimFollowPathReset(ElevDoorDIndex, gElevDoorD)
end

function F_InvulnerableFlag()
	--print("=======Edgar Invulnerable!=========")
end

function T_CameraShots()
	SetShot = true
	while camerashots do
		if PlayerIsInTrigger(TRIGGER._5_B_LADDERCAMSHOT) then
			if SetShot and PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions", true) then
				--print("==Setting Laddershot==")
				CameraAllowChange(true)
				CameraReset()
				SetShot = false
				Progress_Check = 1
			end
		elseif PlayerIsInTrigger(TRIGGER._5_B_CHEMCAMSHOT) then
			if SetShot then
				--print("==Setting Chemshot==")
				CameraSetXYZ(-754.5251, 86.886566, 29.066439, -753.9485, 86.495895, 28.349194)
				CameraAllowChange(false)
				SetShot = false
				Progress_Check = 2
			end
		elseif PlayerIsInTrigger(TRIGGER._5_B_LADDERCAMSHOT02) then
			if SetShot and PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions", true) then
				--print("==Setting Laddershot02==")
				CameraAllowChange(true)
				CameraReset()
				SetShot = false
				Progress_Check = 3
			end
		elseif PlayerIsInTrigger(TRIGGER._5_B_LADDERCAMSHOT03) then
			if SetShot and PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions", true) then
				--print("==Setting Laddershot03==")
				CameraAllowChange(true)
				CameraReset()
				SetShot = false
				Progress_Check = 4
			end
		elseif PlayerIsInTrigger(TRIGGER._5_B_CHEMCAMSHOT02) then
			if SetShot or Progress_Check == 2 then
				--print("==Setting CamShot03==")
				CameraSetXYZ(-747.0648, 77.41318, 23.738522, -747.3322, 77.96439, 22.948328)
				CameraAllowChange(false)
				SetShot = false
				Progress_Check = 5
			end
		elseif not SetShot then
			--print("== shot now try reset==")
			if Progress_Check ~= 2 or not PlayerIsInTrigger(TRIGGER._5_B_CHEMCAMSHOT) and not PlayerIsInTrigger(TRIGGER._5_B_CHEMCAMSHOT02) then
				--print("== shot now reset==")
				CameraAllowChange(true)
				CameraReset()
				CameraReturnToPlayer(true)
			end
			SetShot = true
		end
		if PlayerIsInTrigger(TRIGGER._5_B_CRAWL) then
			TextPrint("5_B_Crawl", 1, 3)
		end
		Wait(0)
	end
end

function T_SLUDGECHECK()
	while mission_running do
		if PlayerIsInTrigger(TRIGGER._5_B_FALL_INTO_SLUDGE) then
			--print("========IN THE SLUDGE================")
			mission_running = false
		end
		Wait(0)
	end
end

function F_EdgarThirdStage()
	if STAGE_NUM == 3 then
		return 1
	else
		return 0
	end
end

function F_NextStageSet()
	--print("EDGAR SHOULD BE RUNNING AWAY NOW")
end

function F_EdgarSecondStage()
	if STAGE_NUM == 4 then
		return 1
	else
		return 0
	end
end
