--[[ Changes to this file:
	* Modified function MissionCleanup, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPlayer.lua")
local bStopNIS = false
local gJohnny, gBlockAOrderly01, gBlockAOrderly02, gSleepingOrderly, gBlockBOrderly01, gBlockBOrderly02, gControlOrderly, gDOThug03, gLola, gLolaUniqueNum
local bMissionCompleted = false
local gLroomBlip
local bFoundJohnny = false
local bPlayerHasOutfit = false
local bBlockAConvOver = false
local gBlipAsylum, bBlipControlRoom
local ground_orderlies = {}
local gOrderly01, gBlipJohnny, gFenwick
local bSleeperAwake = false
local gNorton, gNortonUniqueNum, bike
local bLook2_1 = false
local bLook2_5 = false
local bLook2_9 = false
local bFailedDueToViolence = false
local hitSpotter = -1
local bPlayerHitOrderly = false
local gFrontOrderly, gStationOrderly, gDropOutE01, gDropOutE02
local bEnteringAsylumNIS = false
local bJohnnyGoto01 = false
local bReadyForExit = false
local gBlipExit
local bFireCreated = false
local bPlayerHitOrderly = false
local fire01, fire02, fire03, fire04, fire05, gDropOut01, gDropOut02, gDropOut03, gDropOut04, gDropOut05, gDropOut06, gDropOut07, index_A, simpleObject_A, index_B, simpleObject_B, index_C, simpleObject_C, index_D, simpleObject_D, index_E, simpleObject_E, index_A2, simpleObject_A2, index_B2, simpleObject_B2, index_C2, simpleObject_C2, index_D2, simpleObject_D2, index_E2, simpleObject_E2
local controlX, controlY, controlZ = 0, 0, 0
local bControlSwitchCorona = false
local mis_obj01, mis_obj02, mis_obj03, mis_obj04, mis_obj05, mis_obj06, mis_obj07, mis_obj00
local bCanPressButton = false
local bJohnnyFree = false
local bUnlockLine = false
local gBlipControlRoom
local bLightSet2 = false
local VISIONRANGE_MIN = 6
local VISIONRANGE_MED = 8
local VISIONRANGE_MAX = 10
local bPlayerGreetsOrderly = false
local bJohnnyBlipped = false
local bFrontDeskSupport = false
local bOutOfBounds = false
local bSleeperCreated = false
local bOrderlyHasChatted = false
local bTalkedToControlDude = false
local bFirstEntrance = false
local bAlarmLoop = false
local bABlockSpeech = false
local bBBlockSetup = false
local bJohnnyYelling = false
local bGotOrderlyOutfit = false
local bIntoControlRoom = false
local spottingPed = -1
local gSwitch = -1
local b1stWaveDown = false
local bJohnnyGoto1 = false
local bCloseRecDoors = false
local b2ndWaveDown = false
local bDOWing1 = false
local bDOWing3 = false
local bOnGrounds = false
local bPlayerSpotted = false
local bInOutOfBoundsTrigger = false
local bOrderlyTalkSpotted = false
local bObjectiveOneComplete = false

function MissionSetup()
	MissionDontFadeIn()
	PlayerSetControl(0)
	AreaClearAllPeds()
	PlayCutsceneWithLoad("5-03", true, true, true)
	DATLoad("5_03.DAT", 2)
	DATInit()
	AreaTransitionPoint(0, POINTLIST._5_03_PLAYERSTART1, 1, true)
end

function F_MissionSetup()
	shared.bAsylumPatrols = false
	LoadPedModels({
		53,
		158,
		125,
		23,
		150,
		154,
		129,
		25,
		29,
		153
	})
	LoadActionTree("Act/Conv/5_03.act")
	LoadActionTree("Act/Anim/Crazy_Basic.act")
	LoadAnimationGroup("Hang_Talking")
	LoadAnimationGroup("AsyBars")
	LoadAnimationGroup("G_Striker")
	LoadAnimationGroup("F_CRAZY")
	AreaSetDoorLocked(TRIGGER._ASYLUM_FRONT_GATE_DOOR, true)
	DisablePOI()
	gLolaUniqueNum = PedGetUniqueModelStatus(25)
	gNortonUniqueNum = PedGetUniqueModelStatus(29)
	PedSetUniqueModelStatus(25, -1)
	PedSetUniqueModelStatus(29, -1)
end

function main()
	SoundPlayInteractiveStream("MS_RunningLow02.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetMidIntensityStream("MS_RunningMid.rsm", MUSIC_DEFAULT_VOLUME)
	F_MissionSetup()
	L_PlayerClothingBackup()
	gLola = PedCreatePoint(25, POINTLIST._5_03_LOLA)
	gNorton = PedCreatePoint(29, POINTLIST._5_03_NORTON)
	PedSetTypeToTypeAttitude(4, 13, 3)
	AreaClearAllPeds()
	PlayerSetControl(1)
	CameraFade(1000, 1)
	Wait(1000)
	mis_obj01 = MissionObjectiveAdd("5_03_94")
	TextPrint("5_03_94", 5, 1)
	gBlipAsylum = BlipAddPoint(POINTLIST._5_03_TREEBLIP, 0)
	F_GetToAsylum()
	F_GetInAsylum()
	F_GetToJohnny()
	F_GetOut()
end

function F_GetToAsylum()
	while not F_AsylumGroundsSetUp() do
		Wait(0)
	end
	F_AsylumGroundsSetUpAction()
end

function F_AsylumGroundsSetUp()
	return PlayerIsInTrigger(TRIGGER._5_03_ASYLUM_GROUNDS_SETUP)
end

function F_AsylumGroundsSetUpAction()
	if PedIsValid(gLola) then
		PedDelete(gLola)
	end
	if PedIsValid(gNorton) then
		PedDelete(gNorton)
	end
	AreaSetDoorLocked(TRIGGER._DT_ASYLUM_FRONT_DOOR, false)
	F_SetUp_Grounds_Orderlies()
end

function F_SetUp_Grounds_Orderlies()
	tblGroundOrderly = {
		{
			id = -1,
			model = 53,
			point = POINTLIST._5_03_GROUNDS_ORDERLY1
		},
		{
			id = -1,
			model = 158,
			point = POINTLIST._5_03_GROUNDS_ORDERLY2
		}
	}
	for p, ped in tblGroundOrderly do
		ped.id = PedCreatePoint(ped.model, ped.point)
		PedSetStealthBehavior(ped.id, 0, cbNull)
		PedOverrideStat(ped.id, 3, VISIONRANGE_MED)
	end
	gOrderly01 = tblGroundOrderly[1].id
	gOrderly02 = tblGroundOrderly[2].id
	PedFollowPath(gOrderly01, PATH._ASYLUMPATH1, 2, 0)
	PedFollowPath(gOrderly02, PATH._ASYLUMPATH2, 2, 0)
	RegisterGlobalEventHandler(7, nil)
	RegisterGlobalEventHandler(7, F_CheckOrderlyHit)
end

function F_GetInAsylum()
	while not F_PlayerInsideAsylum() do
		if not bOnGrounds and F_OnGrounds() then
			F_OnGroundsAction()
			bOnGrounds = true
		end
		if bPlayerSpotted and not bGotOrderlyOutfit and bOnGrounds then
			F_PlayerSpotted(spottingPed)
			F_EjectPlayerFromAsylum()
			bPlayerSpotted = false
		end
		Wait(0)
	end
	F_PlayerInsideAsylumAction()
end

function F_PlayerInsideAsylum()
	if AreaGetVisible() == 38 then
		bFirstEntrance = true
		return true
	else
		return false
	end
end

function F_PlayerInsideAsylumAction()
	SoundStopInteractiveStream(0)
	SoundPlayInteractiveStreamLocked("MS_SearchingLow.rsm", MUSIC_DEFAULT_VOLUME)
	PunishersRespondToPlayerOnly(true)
	if not bEnteringAsylumNIS then
		F_EnteringAsylumNIS()
		bEnteringAsylumNIS = true
	else
		CameraFade(500, 1)
	end
	if PedIsValid(gOrderly01) then
		PedDelete(gOrderly01)
	end
	if PedIsValid(gOrderly02) then
		PedDelete(gOrderly02)
	end
	local x, y, z = GetPointList(POINTLIST._5_03_PLAYERCROUCH)
	PlayerSetPosSimple(x, y, z)
	PedSetFlag(gPlayer, 2, true)
	PAnimSetActionNode(TRIGGER._ASYBARS, "/Global/AsyBars/Executes/Open", "Act/Props/AsyBars.act")
	PAnimSetActionNode(TRIGGER._ASYBARS01, "/Global/AsyBars/Executes/Open", "Act/Props/AsyBars.act")
	PAnimSetActionNode(TRIGGER._ASYBARS02, "/Global/AsyBars/Executes/Open", "Act/Props/AsyBars.act")
	BlipRemove(gBlipAsylum)
	Wait(500)
	if not bFoundJohnny then
		gBlipJohnny = BlipAddPoint(POINTLIST._5_03_JOHNNY_START, 0, 2, 1, 7)
		bJohnnyBlipped = true
	else
		gLroomBlip = BlipAddPoint(POINTLIST._5_03_LAUNDRY_RM_BLIP, 0)
	end
	AreaSetDoorLocked(TRIGGER._ESCDOORR, true)
	AreaSetDoorLockedToPeds(TRIGGER._ESCDOORR, true)
	AreaSetDoorLocked("ASYDOORB", true)
	AreaSetDoorLockedToPeds("ASYDOORB", true)
	AreaSetDoorLocked(TRIGGER._FMDOOR02, false)
	AreaSetDoorLockedToPeds("ASYDOORS11", true)
	AreaSetDoorLocked("ASYDOORS11", true)
	AreaSetDoorLockedToPeds("ASYDOORS12", false)
	AreaSetDoorLocked("ASYDOORS12", false)
	AreaSetDoorLockedToPeds("ASYDOORS14", false)
	AreaSetDoorLockedToPeds("ASYDOORS15", false)
	AreaSetDoorLocked("ASYDOORS14", false)
	AreaSetDoorLocked("ASYDOORS15", false)
	AreaSetDoorLocked("CELLDOOR", true)
	AreaSetDoorLockedToPeds("CELLDOOR", true)
	AreaSetDoorLocked("CELLDOOR12", true)
	AreaSetDoorLockedToPeds("CELLDOOR12", true)
	AreaSetDoorLocked("CELLDOOR13", true)
	AreaSetDoorLockedToPeds("CELLDOOR13", true)
	AreaSetDoorLocked("CELLDOOR14", true)
	AreaSetDoorLockedToPeds("CELLDOOR14", true)
	AreaSetDoorLocked("CELLDOOR15", true)
	AreaSetDoorLockedToPeds("CELLDOOR15", true)
	AreaSetDoorLocked("CELLDOOR16", true)
	AreaSetDoorLockedToPeds("CELLDOOR16", true)
	AreaSetDoorLocked("CELLDOOR17", true)
	AreaSetDoorLockedToPeds("CELLDOOR17", true)
	AreaSetDoorLocked("CELLDOOR18", true)
	AreaSetDoorLockedToPeds("CELLDOOR18", true)
	AreaSetDoorLocked("CELLDOOR19", true)
	AreaSetDoorLockedToPeds("CELLDOOR19", true)
	AreaSetDoorLocked("CELLDOOR21", true)
	AreaSetDoorLockedToPeds("CELLDOOR21", true)
	AreaSetDoorLocked("CELLDOOR20", true)
	AreaSetDoorLockedToPeds("CELLDOOR20", true)
	AreaSetDoorLocked("CELLDOOR21", true)
	AreaSetDoorLockedToPeds("CELLDOOR21", true)
	AreaSetDoorLocked("FMDoor02", true)
	AreaSetDoorLocked("FMDoor03", true)
	PedSetTypeToTypeAttitude(4, 13, 4)
	PedSetTypeToTypeAttitude(0, 3, 4)
	PedSetTypeToTypeAttitude(3, 0, 4)
	if bBustedPlayer then
		gFrontOrderly = PedCreatePoint(53, POINTLIST._5_03_CLERK_ORDERLY)
		PedFollowPath(gFrontOrderly, PATH._ASYLUM_PATROL_FRONTDESK, 2, 0)
		PedOverrideStat(gFrontOrderly, 3, VISIONRANGE_MED)
		PedOverrideStat(gFrontOrderly, 2, 70)
		PedSetStealthBehavior(gFrontOrderly, 0, cbNull)
	end
	gBlockAOrderly01 = PedCreatePoint(158, POINTLIST._5_03_1STFLOOR_ORDERLY1)
	PedOverrideStat(gBlockAOrderly01, 3, VISIONRANGE_MED)
	PedOverrideStat(gBlockAOrderly01, 2, 70)
	gBlockAOrderly02 = PedCreatePoint(53, POINTLIST._5_03_1STFLOOR_ORDERLY2)
	PedOverrideStat(gBlockAOrderly02, 3, VISIONRANGE_MED)
	PedOverrideStat(gBlockAOrderly02, 2, 70)
	PedSetStealthBehavior(gBlockAOrderly01, 0, cbNull)
	PedSetStealthBehavior(gBlockAOrderly02, 0, cbNull)
	if bBustedPlayer and bOrderlyHasChatted then
		AreaSetDoorLockedToPeds("ASYDOORS11", false)
		AreaSetDoorLocked("ASYDOORS11", false)
		PedSetActionTree(gBlockAOrderly01, "/Global/LE_Orderly_A", "Act/Anim/LE_Orderly_A.act")
		PedSetActionTree(gBlockAOrderly02, "/Global/LE_Orderly_A", "Act/Anim/LE_Orderly_A.act")
		PedMakeAmbient(gBlockAOrderly02)
		PedFollowPath(gBlockAOrderly02, PATH._5_03_1F_ORDERLY2_PATH1, 1, 1)
		Wait(1000)
		PedFollowPath(gBlockAOrderly01, PATH._ASYLUM_PATROL_ABLOCK, 1, 0, CB_F1_O1_Path)
		CreateThread("T_F1_O1_To_Look")
	elseif not bBustedPlayer or not bOrderlyHasChatted then
	end
	if not bBustedPlayer then
		MissionObjectiveComplete(mis_obj01)
		bObjectiveOneComplete = true
	else
		MissionObjectiveRemove(objGetIn)
	end
	if not bFoundJohnny then
		TextPrint("5_03_37", 5, 1)
		mis_obj02 = MissionObjectiveAdd("5_03_37")
	else
		TextPrint("5_03_39", 5, 1)
		mis_obj03 = MissionObjectiveAdd("5_03_39")
	end
	index_A, simpleObject_A = CreatePersistentEntity("ASY_AlarmLightA_OFF", -735.365, 433.852, 4.92833, 0, 38)
	index_B, simpleObject_B = CreatePersistentEntity("ASY_AlarmLightB_OFF", -735.359, 451.473, 4.92833, 0, 38)
	index_C, simpleObject_C = CreatePersistentEntity("ASY_AlarmLightC_OFF", -735.367, 476.785, 4.92833, 0, 38)
	index_D, simpleObject_D = CreatePersistentEntity("ASY_AlarmLightD_OFF", -707.27, 487.116, 4.92833, 0, 38)
	index_E, simpleObject_E = CreatePersistentEntity("ASY_AlarmLightE_OFF", -763.422, 487.116, 4.92833, 0, 38)
end

function F_EnteringAsylumNIS()
	F_MakePlayerSafeForNIS(true, true)
	CameraSetWidescreen(true)
	PlayerSetControl(0)
	AreaSetDoorOpen("FMDoor", true)
	AreaSetDoorLockedToPeds("FMDoor", false)
	local x, y, z = GetPointList(POINTLIST._5_03_PLAYERCROUCH)
	PlayerSetPosSimple(x, y, z)
	PedSetFlag(gPlayer, 2, true)
	gFrontOrderly = PedCreatePoint(53, POINTLIST._5_03_CLERK_ORDERLY)
	PedFollowPath(gFrontOrderly, PATH._ASYLUM_PATROL_FRONTDESK, 2, 0, cbNoPath, 1)
	PedOverrideStat(gFrontOrderly, 3, VISIONRANGE_MED)
	PedOverrideStat(gFrontOrderly, 2, 70)
	PedSetStealthBehavior(gFrontOrderly, 0, cbNull)
	CameraSetFOV(70)
	CameraSetXYZ(-734.67053, 422.53967, 2.5537, -733.9672, 423.22797, 2.73075)
	Wait(500)
	CameraFade(500, 1)
	Wait(500)
	TextPrint("5_03_37", 5, 1)
	while not bStopNIS do
		Wait(0)
	end
	Wait(2000)
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(500, 0)
	Wait(500)
	CameraReturnToPlayer()
	CameraFollowPed(gPlayer)
	CameraSetWidescreen(false)
	CameraFade(500, 1)
	Wait(500)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	F_MakePlayerSafeForNIS(false, true)
	PlayerSetControl(1)
	AreaDisableCameraControlForTransition(false)
end

function cbNoPath(pedID, pathID, nodeID)
	if nodeID == 1 then
		bStopNIS = true
	end
end

function cbNull(pedID)
	if bOnGrounds then
		--print("====== Spotting pedID ", pedID)
		spottingPed = pedID
		bPlayerSpotted = true
	end
end

function F_OutOfBounds()
	if F_OutOfBoundsTrigger() then
		F_OutOfBoundsAction()
		bInOutOfBoundsTrigger = true
	elseif bInOutOfBoundsTrigger and not F_OutOfBoundsTrigger() then
		bInOutOfBoundsTrigger = false
		TextClear()
	end
	if PlayerIsInTrigger(TRIGGER._5_03_GAMEOVER) or PlayerIsInTrigger(TRIGGER._5_03_LEFT) then
		TextClear()
		bOutOfBounds = true
		SoundPlayMissionEndMusic(false, 4)
		MissionFail(false, true, "5_03_AREAFAIL")
	end
end

function F_OutOfBoundsTrigger()
	return PlayerIsInTrigger(TRIGGER._5_03_LEAVING)
end

function F_OutOfBoundsAction()
	if not bOutOfBounds then
		TextPrint("5_03_GETBACK", 1, 1)
	end
end

function CB_Station_Orderlies()
	PedSetPunishmentPoints(gPlayer, 400, false)
end

function CB_Front_Orderly()
	PedSetPunishmentPoints(gPlayer, 400, false)
	if not bFrontDeskSupport then
		PedMoveToPoint(gBlockAOrderly01, 1, POINTLIST._5_03_FRONTDESKSUPPORT, 1)
		PedMoveToPoint(gBlockAOrderly02, 1, POINTLIST._5_03_FRONTDESKSUPPORT, 2)
		bFrontDeskSupport = true
	end
end

function F_GetToJohnny()
	local controlX, controlY, controlZ = GetPointList(POINTLIST._5_03_CONTROLSWITCH)
	while not bJohnnyFree do
		if bBustedPlayer then
			while not F_PlayerInsideAsylum() do
				if not bOnGrounds and F_OnGrounds() then
					BlipRemove(gBlipAsylum)
					gBlipAsylum = BlipAddPoint(POINTLIST._5_03_ASYLUM_BLIP, 0)
					bOnGrounds = true
				end
				if bPlayerSpotted and not bGotOrderlyOutfit and bOnGrounds then
					F_PlayerSpotted(spottingPed)
					F_EjectPlayerFromAsylum()
					bPlayerSpotted = false
				end
				Wait(0)
			end
			F_PlayerInsideAsylumAction()
			bBustedPlayer = false
		end
		if bPlayerSpotted and not bGotOrderlyOutfit and bOnGrounds then
			F_PlayerSpotted(spottingPed)
			F_EjectPlayerFromAsylum()
			bPlayerSpotted = false
		end
		if not bABlockSpeech and F_ABlockOrderlyConv() then
			F_ABlockOrderlyConvAction()
			bABlockSpeech = true
		end
		if not bSleeperCreated and bABlockSpeech and F_ABlockOrderlyConv() then
			F_CreateSleepingOrderly()
			bSleeperCreated = true
		end
		if not bBBlockSetup and F_BBlockSetup() then
			F_BBlockSetupAction()
			bBBlockSetup = true
		end
		if not bJohnnyYelling and F_JohnnyYelling() then
			F_JohnnyYellingAction()
			bJohnnyYelling = true
		end
		if not bFoundJohnny and F_FoundJohnny() then
			F_FoundJohnnyAction()
		end
		if not bGotOrderlyOutfit and F_GotOrderlyOutfit() then
			F_GotOrderlyOutfitAction()
			bGotOrderlyOutfit = true
		end
		if bGotOrderlyOutfit and not bTalkedToControlDude then
			bTalkedToControlDude = F_NearControlRoom()
		end
		if not bIntoControlRoom and F_IntoControlRoom() then
			F_IntoControlRoomAction()
			bIntoControlRoom = true
		end
		if not bCanPressButton and F_GreetOrderly() then
			F_GreetOrderlyAction()
		end
		if bControlSwitchCorona and PlayerIsInAreaXYZ(controlX, controlY, controlZ, 10, 7) and not bJohnnyFree then
			F_Open_Cell_Doors2()
		end
		Wait(0)
	end
end

function F_ABlockOrderlyConv()
	return PlayerIsInTrigger(TRIGGER._5_03_ORDERLY_CS1_1)
end

function F_ABlockOrderlyConvAction()
	if not bFrontDeskSupport and (not bBustedPlayer or not bOrderlyHasChatted) then
		PedStop(gBlockAOrderly01)
		PedStop(gBlockAOrderly02)
		PedFaceObject(gBlockAOrderly01, gBlockAOrderly02, 2, 0)
		PedFaceObject(gBlockAOrderly02, gBlockAOrderly01, 2, 0)
		PedSetActionTree(gBlockAOrderly01, "/Global/5_03/5_03_Stand_Talking", "Act/Conv/5_03.act")
		PedSetActionTree(gBlockAOrderly02, "/Global/5_03/5_03_Stand_Talking", "Act/Conv/5_03.act")
		PedSetStealthBehavior(gBlockAOrderly01, 0, cbNull)
		PedSetStealthBehavior(gBlockAOrderly02, 0, cbNull)
		SoundPlayScriptedSpeechEvent(gBlockAOrderly02, "M_5_03", 2, "genric", false, false)
		bOrderlyHasChatted = true
		while SoundSpeechPlaying(gBlockAOrderly02) do
			if bPlayerSpotted and not bGotOrderlyOutfit then
				SoundStopCurrentSpeechEvent(gBlockAOrderly02)
				F_PlayerSpotted(spottingPed)
				F_EjectPlayerFromAsylum()
				bPlayerSpotted = false
				bOrderlyTalkSpotted = true
				break
			end
			Wait(0)
		end
		if bOrderlyTalkSpotted then
			bOrderlyTalkSpotted = false
			return
		end
		SoundPlayScriptedSpeechEvent(gBlockAOrderly02, "M_5_03", 4, "genric", false, false)
		while SoundSpeechPlaying(gBlockAOrderly02) do
			SoundStopCurrentSpeechEvent(gBlockAOrderly02)
			if bPlayerSpotted and not bGotOrderlyOutfit then
				F_PlayerSpotted(spottingPed)
				F_EjectPlayerFromAsylum()
				bPlayerSpotted = false
				bOrderlyTalkSpotted = true
				break
			end
			Wait(0)
		end
		if bOrderlyTalkSpotted then
			bOrderlyTalkSpotted = false
			return
		end
		AreaSetDoorLockedToPeds("ASYDOORS11", false)
		AreaSetDoorLocked("ASYDOORS11", false)
		PedSetActionTree(gBlockAOrderly01, "/Global/LE_Orderly_A", "Act/Anim/LE_Orderly_A.act")
		PedSetActionTree(gBlockAOrderly02, "/Global/LE_Orderly_A", "Act/Anim/LE_Orderly_A.act")
		PedMakeAmbient(gBlockAOrderly02)
		PedFollowPath(gBlockAOrderly02, PATH._5_03_1F_ORDERLY2_PATH1, 1, 1)
		local timer = GetTimer() + 3000
		while timer >= GetTimer() do
			if bPlayerSpotted and not bGotOrderlyOutfit then
				F_PlayerSpotted(spottingPed)
				F_EjectPlayerFromAsylum()
				bPlayerSpotted = false
				bOrderlyTalkSpotted = true
				break
			end
			Wait(0)
		end
		if bOrderlyTalkSpotted then
			bOrderlyTalkSpotted = false
			return
		end
		PedFollowPath(gBlockAOrderly01, PATH._ASYLUM_PATROL_ABLOCK, 1, 0, CB_F1_O1_Path)
		CreateThread("T_F1_O1_To_Look")
		bBlockAConvOver = true
	end
end

function CB_Set_Normal1()
	ClearTextQueue()
	if not PedIsDead(gBlockAOrderly01) then
		PedSetActionTree(gBlockAOrderly01, "/Global/LE_Orderly_A", "Act/Anim/LE_Orderly_A.act")
	end
	if not PedIsDead(gBlockAOrderly02) then
		PedSetActionTree(gBlockAOrderly02, "/Global/LE_Orderly_A", "Act/Anim/LE_Orderly_A.act")
	end
end

function CB_F1_O1_Path(pedid, pathid, nodeid)
end

function T_F1_O1_To_Look()
	while not (not MissionActive() or bPlayerHasOutfit) do
		if PlayerIsInTrigger(TRIGGER._5_03_1ST_FLOOR_1ST_HALL) then
			if bLook2_1 then
				bLook2_1 = false
				PedStop(gBlockAOrderly01)
				local x1, y1, z1 = GetPointList(POINTLIST._5_03_PATIENT_ROOM1)
				PedFaceXYZ(gBlockAOrderly01, x1, y1, z1, 0)
				Wait(1000)
				PedFollowPath(gBlockAOrderly01, PATH._ASYLUM_PATROL_ABLOCK, 1, 0, CB_F1_O1_Path, 2)
			end
			if bLook2_5 then
				bLook2_5 = false
				PedStop(gBlockAOrderly01)
				local x1, y1, z1 = GetPointList(POINTLIST._5_03_1STFLOOR_DO3)
				PedFaceXYZ(gBlockAOrderly01, x1, y1, z1, 0)
				Wait(5000)
				PedFollowPath(gBlockAOrderly01, PATH._ASYLUM_PATROL_ABLOCK, 1, 0, CB_F1_O1_Path, 6)
			end
			if bLook2_9 then
				bLook2_9 = false
				PedStop(gBlockAOrderly01)
				local x1, y1, z1 = GetPointList(POINTLIST._5_03_1STFLOOR_DO4)
				PedFaceXYZ(gBlockAOrderly01, x1, y1, z1, 0)
				Wait(5000)
				PedFollowPath(gBlockAOrderly01, PATH._ASYLUM_PATROL_ABLOCK, 1, 0, CB_F1_O1_Path, 10)
			end
		end
		Wait(0)
	end
	collectgarbage()
end

function F_CreateSleepingOrderly()
	gSleepingOrderly = PedCreatePoint(53, POINTLIST._5_03_1F_RECRM_ORDERLY2)
	PedSetStealthBehavior(gSleepingOrderly, 0, cbNull)
	PedOverrideStat(gSleepingOrderly, 3, 0)
	PedSetActionNode(gSleepingOrderly, "/Global/5_03/5_03_Sleeping_Orderly/5_03_Sleeping_Orderly_To_Sleep", "Act/Conv/5_03.act")
	CreateThread("T_SleepingOrderly")
end

function F_BBlockSetup()
	return PlayerIsInTrigger(TRIGGER._5_03_GEN_JOHNNY)
end

function F_BBlockSetupAction()
	gBlockBOrderly01 = PedCreatePoint(53, POINTLIST._5_03_1F_BW_ORDERLY1)
	PedOverrideStat(gBlockBOrderly01, 3, VISIONRANGE_MED)
	PedOverrideStat(gBlockBOrderly01, 2, 70)
	PedFollowPath(gBlockBOrderly01, PATH._ASYLUM_PATROL_BBLOCK, 1, 0)
	PedSetStealthBehavior(gBlockBOrderly01, 0, cbNull)
	gJohnny = PedCreatePoint(23, POINTLIST._5_03_JOHNNY_START)
	PedSetActionTree(gJohnny, "/Global/5_03/5_03_Johnny_In_Cell", "Act/Conv/5_03.act")
	gFenwick = PedCreatePoint(125, POINTLIST._5_03_PATIENT01)
	PedClearAllWeapons(gFenwick)
	PedSetActionTree(gFenwick, "/Global/5_03/5_03_Johnny_In_Cell", "Act/Conv/5_03.act")
	PedSetCheap(gFenwick, true)
	PedSetFlag(gFenwick, 117, false)
	PedSetFlag(gFenwick, 108, true)
	gDOThug01 = PedCreatePoint(154, POINTLIST._5_03_PATIENT02)
	PedClearAllWeapons(gDOThug01)
	PedSetActionTree(gDOThug01, "/Global/5_03/5_03_Johnny_In_Cell", "Act/Conv/5_03.act")
	PedSetCheap(gDOThug01, true)
	PedSetFlag(gDOThug01, 117, false)
	PedSetFlag(gDOThug01, 108, true)
	gDOThug02 = PedCreatePoint(150, POINTLIST._5_03_DO_THUG02)
	PedClearAllWeapons(gDOThug02)
	PedSetActionTree(gDOThug02, "/Global/5_03/5_03_Johnny_In_Cell", "Act/Conv/5_03.act")
	PedSetCheap(gDOThug02, true)
	PedSetFlag(gDOThug02, 117, false)
	PedSetFlag(gDOThug02, 108, true)
	gDOThug03 = PedCreatePoint(153, POINTLIST._5_03_DO_THUG03)
	PedClearAllWeapons(gDOThug03)
	PedSetActionTree(gDOThug03, "/Global/5_03/5_03_Johnny_In_Cell", "Act/Conv/5_03.act")
	PedSetCheap(gDOThug03, true)
	PedSetFlag(gDOThug03, 117, false)
	PedSetFlag(gDOThug03, 108, true)
	gBlockBOrderly02 = PedCreatePoint(158, POINTLIST._5_03_1F_BW_ORDERLY3)
	PedOverrideStat(gBlockBOrderly02, 3, VISIONRANGE_MED)
	PedOverrideStat(gBlockBOrderly02, 2, 70)
	PedFollowPath(gBlockBOrderly02, PATH._ASYLUM_PATROL_SHOWER, 1, 0)
	PedSetStealthBehavior(gBlockBOrderly02, 0, cbNull)
	gStationOrderly = PedCreatePoint(158, POINTLIST._5_03_STATION1_ORDERLY)
	PedOverrideStat(gStationOrderly, 3, VISIONRANGE_MIN)
	PedOverrideStat(gStationOrderly, 2, 70)
	PedSetStealthBehavior(gStationOrderly, 0, cbNull)
	AreaSetDoorLocked(TRIGGER._FMDOOR03, true)
	gControlOrderly = PedCreatePoint(53, POINTLIST._5_03_CR_ORDERLY_1)
	PedOverrideStat(gControlOrderly, 3, VISIONRANGE_MIN)
	PedOverrideStat(gControlOrderly, 2, 70)
	PedSetStealthBehavior(gControlOrderly, 0, cbNull)
	PedSetStationary(gControlOrderly, true)
	PedAddPedToIgnoreList(gBlockBOrderly01, gJohnny)
	PedAddPedToIgnoreList(gBlockBOrderly02, gJohnny)
	PedAddPedToIgnoreList(gControlOrderly, gJohnny)
	PedAddPedToIgnoreList(gJohnny, gBlockBOrderly01)
	PedAddPedToIgnoreList(gJohnny, gBlockBOrderly02)
	PedAddPedToIgnoreList(gJohnny, gControlOrderly)
end

function F_JohnnyYelling()
	return PlayerIsInTrigger(TRIGGER._5_03_JOHNNY_YELLING)
end

function F_JohnnyYellingAction()
	CreateThread("T_Johnny_Yelling")
end

function T_Johnny_Yelling()
	while not (not MissionActive() or bFoundJohnny) and AreaGetVisible() == 38 do
		if not bFoundJohnny then
			Wait(15000)
			if AreaGetVisible() ~= 38 then
				break
			end
			if not bFoundJohnny then
				if not bJohnnyBlipped then
					gBlipJohnny = BlipAddPoint(POINTLIST._5_03_JOHNNY_START, 0, 2, 1, 7)
					bJohnnyBlipped = true
				end
				if PedIsValid(gJohnny) then
					SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 5, "genric", false, false)
				end
			end
		end
		Wait(0)
	end
	collectgarbage()
end

function F_FoundJohnny()
	return PlayerIsInTrigger(TRIGGER._5_03_JOHNNY_TRIG1)
end

function F_FoundJohnnyAction()
	bFoundJohnny = true
	F_MakePlayerSafeForNIS(true)
	MissionObjectiveComplete(mis_obj02)
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(500, 0)
	Wait(700)
	BlipRemove(gBlipJohnny)
	CameraFade(1000, 1)
	CameraSetWidescreen(true)
	PlayerSetControl(0)
	PedStop(gPlayer)
	PedStop(gJohnny)
	PedDelete(gBlockBOrderly01)
	CameraSetWidescreen(true)
	PlayerSetControl(0)
	CameraSetXYZ(-697.33417, 481.94528, 3.97798, -697.0906, 481.03473, 3.644237)
	SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 6, "genric", false, false)
	while SoundSpeechPlaying(gJohnny) do
		Wait(0)
	end
	SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 7, "genric", false, false)
	while SoundSpeechPlaying(gJohnny) do
		Wait(0)
	end
	SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 8, "genric", false, false)
	while SoundSpeechPlaying(gJohnny) do
		Wait(0)
	end
	SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 9, "genric", false, false)
	while SoundSpeechPlaying(gJohnny) do
		Wait(0)
	end
	SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 10, "genric", false, false)
	while SoundSpeechPlaying(gJohnny) do
		Wait(0)
	end
	CameraSetWidescreen(false)
	F_MakePlayerSafeForNIS(false)
	PlayerSetControl(1)
	CameraReturnToPlayer()
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	gBlockBOrderly01 = PedCreatePoint(53, POINTLIST._5_03_1F_BW_ORDERLY1)
	PedOverrideStat(gBlockBOrderly01, 3, VISIONRANGE_MED)
	PedOverrideStat(gBlockBOrderly01, 2, 70)
	PedFollowPath(gBlockBOrderly01, PATH._ASYLUM_PATROL_BBLOCK, 1, 0)
	PedSetStealthBehavior(gBlockBOrderly01, 0, cbNull)
	Wait(1000)
	if not bBustedPlayer then
		mis_obj03 = MissionObjectiveAdd("5_03_39")
	end
	TextPrint("5_03_39", 5, 1)
	Wait(500)
	if not bBustedPlayer then
		gLroomBlip = BlipAddPoint(POINTLIST._5_03_LAUNDRY_RM_BLIP, 0)
	end
	PickupCreatePoint(510, POINTLIST._5_03_LAUNDRY_RM_BLIP, 0, 360, "PermanentButes")
end

function F_GotOrderlyOutfit()
	return ItemGetCurrentNum(510) == 1
end

function F_GotOrderlyOutfitAction()
	BlipRemove(gLroomBlip)
	PlayerSetControl(0)
	PedStop(gPlayer)
	CameraFade(1000, 0)
	Wait(1000)
	SoundPlayInteractiveStream("MS_ActionLow.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetMidIntensityStream("MS_ActionMid.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetHighIntensityStream("MS_ActionHigh.rsm", MUSIC_DEFAULT_VOLUME)
	L_PlayerClothingBackup()
	ClothingSetPlayerOutfit("Orderly")
	ClothingBuildPlayer()
	PlayerSetControl(1)
	PedSetPunishmentPoints(gPlayer, 0)
	PedSetTypeToTypeAttitude(0, 13, 4)
	PedSetTypeToTypeAttitude(0, 4, 3)
	PedSetIsStealthMissionPed(gBlockBOrderly01, false)
	PedSetIsStealthMissionPed(gBlockBOrderly02, false)
	if PedIsValid(gBlockAOrderly01) then
		PedSetIsStealthMissionPed(gBlockAOrderly01, false)
	end
	if PedIsValid(gBlockAOrderly02) then
		PedSetIsStealthMissionPed(gBlockAOrderly02, false)
	end
	if PedIsValid(gStationOrderly) then
		PedSetIsStealthMissionPed(gStationOrderly, false)
	end
	if PedIsValid(gFrontOrderly) then
		PedSetIsStealthMissionPed(gFrontOrderly, false)
	end
	if PedIsValid(gSleepingOrderly) then
		PedSetIsStealthMissionPed(gSleepingOrderly, false)
	end
	PedDelete(gControlOrderly)
	gControlOrderly = PedCreatePoint(53, POINTLIST._5_03_CR_ORDERLY_1)
	gBlipControlRoom = AddBlipForChar(gControlOrderly, 9, 0, 2)
	PedSetFaction(gControlOrderly, 9)
	PedSetFaction(gJohnny, 9)
	PedSocialOverrideLoad(18, "Mission/5_03_Greeting.act")
	PlayerSocialDisableActionAgainstPed(gControlOrderly, 27, true)
	PedOverrideSocialResponseToStimulus(gControlOrderly, 10, 18)
	PedUseSocialOverride(gControlOrderly, 18, true)
	PlayerRegisterSocialCallbackVsPed(gControlOrderly, 35, F_Player_Greets_1)
	RegisterGlobalEventHandler(7, nil)
	RegisterGlobalEventHandler(7, F_CheckHit)
	AreaSetDoorLocked(TRIGGER._FMDOOR03, false)
	Wait(1500)
	CameraFade(1000, 1)
	Wait(1000)
	bPlayerHasOutfit = true
	MissionObjectiveComplete(mis_obj03)
	mis_obj04 = MissionObjectiveAdd("5_03_TALK")
	TextPrint("5_03_TALK", 5, 1)
	bTalkZone = BlipAddPoint(POINTLIST._5_03_CR_ORDERLY_1, 0, 2, 1, 7)
end

function F_CheckOrderlyHit(pedID)
	if PedIsModel(pedID, 53) or PedIsModel(pedID, 158) and PedGetWhoHitMeLast(pedID) == gPlayer and not F_PedIsDead(pedID) and bOnGrounds then
		--print("===== Player hit a Orderly ====")
		spottingPed = pedID
		bPlayerSpotted = true
	end
end

function F_CheckHit(pedID)
	if PedIsValid(pedID) and (PedIsModel(pedID, 53) or PedIsModel(pedID, 158)) and PedGetHealth(pedID) > 1 and not bPlayerHitOrderly and PedGetWhoHitMeLast(pedID) == gPlayer then
		PedSetTypeToTypeAttitude(0, 13, 3)
		bPlayerHitOrderly = true
	end
end

function F_NearControlRoom()
	local x, y, z = GetPointFromPointList(POINTLIST._5_03_CR_ORDERLY_1, 2)
	if PlayerIsInAreaXYZ(x, y, z, 1, 0) then
		bPlayerGreetsOrderly = true
		return true
	else
		return false
	end
end

function F_GreetOrderly()
	return bPlayerGreetsOrderly
end

function F_GreetOrderlyAction()
	if not bCanPressButton then
		PedFaceObject(gPlayer, gControlOrderly, 2, 1)
		Wait(250)
		SoundPlayScriptedSpeechEvent(gPlayer, "M_5_03", 20, "genric", false, false)
		while SoundSpeechPlaying(gPlayer) do
			Wait(0)
		end
		SoundPlayScriptedSpeechEvent(gControlOrderly, "M_5_03", 18, "genric", false, false)
		BlipRemove(gBlipControlRoom)
		PedStopSocializing(gControlOrderly)
		PedClearObjectives(gControlOrderly)
		PedFollowPath(gControlOrderly, PATH._5_03_CONTROL_ORDERLY_PATH, 0, 0, cbControlRoomDoors)
		bCanPressButton = true
		bControlSwitchCorona = true
		BlipRemove(bTalkZone)
		bBlipControlRoom = BlipAddPoint(POINTLIST._5_03_CONTROLSWITCH, 0, 4)
		MissionObjectiveComplete(mis_obj04)
		mis_obj00 = MissionObjectiveAdd("5_03_OPENDOOR")
		TextPrint("5_03_OPENDOOR", 5, 1)
		AreaSetDoorLocked("FMDoor03", false)
		AreaSetDoorLocked("FMDoor02", false)
	end
end

local bInnerDoor = false
local bOuterDoor = false

function cbControlRoomDoors(pedID, pathID, nodeID)
	if pedID == gControlOrderly and nodeID == 4 then
		PedStop(pedID)
		PedFollowPath(gControlOrderly, PATH._5_03_CONTROL_ORDERLY_PATH, 0, 1, nil, 5)
	end
end

function F_Social_Greet_Orderly()
end

function F_Player_Greets_1()
	bPlayerGreetsOrderly = true
end

function T_SleepingOrderly()
	while not (not MissionActive() or gSleepingOrderly == nil or bPlayerSpotted) do
		if not bSleeperAwake and PedIsAlerted(gSleepingOrderly, 2000) and PedIsInAreaObject(gSleepingOrderly, gPlayer, 2, 8, 0) then
			bSleeperAwake = true
			PedOverrideStat(gSleepingOrderly, 3, VISIONRANGE_MED)
			PedOverrideStat(gSleepingOrderly, 2, 70)
			PedSetActionNode(gSleepingOrderly, "/Global/5_03/5_03_Sleeping_Orderly/5_03_Sleeping_Orderly_Wake_Up", "Act/Conv/5_03.act")
			PedSetActionTree(gSleepingOrderly, "/Global/LE_Orderly_A", "Act/Anim/LE_Orderly_A.act")
			PedClearObjectives(gSleepingOrderly)
			PedSetStealthBehavior(gSleepingOrderly, 0, cbNull)
			PedFollowPath(gSleepingOrderly, PATH._5_03_1F_RECRM_ORDERLY2_PATH1, 2, 0)
		end
		Wait(0)
	end
	collectgarbage()
end

function F_IntoControlRoom()
	return PlayerIsInTrigger(TRIGGER._5_03_PLAYER_IN_CR)
end

function F_IntoControlRoomAction()
end

function T_Open_Doors_Line()
	while not (not MissionActive() or bUnlockLine) do
		if PlayerIsInTrigger(TRIGGER._5_03_PLAYER_IN_CR) then
			TextPrint("5_03_032", 0.1, 3)
		end
		Wait(0)
	end
	collectgarbage()
end

function F_Open_Cell_Doors2()
	if PAnimIsPlaying("AsySwtch", -690.115, 493.604, 2.00141, 1, "/Global/AsySwtch/Active", true) then
		PedAddPedToIgnoreList(gBlockBOrderly01, gJohnny)
		PedAddPedToIgnoreList(gBlockBOrderly02, gJohnny)
		PedAddPedToIgnoreList(gControlOrderly, gJohnny)
		PedAddPedToIgnoreList(gJohnny, gBlockBOrderly01)
		PedAddPedToIgnoreList(gJohnny, gBlockBOrderly02)
		PedAddPedToIgnoreList(gJohnny, gControlOrderly)
		PedAddPedToIgnoreList(gControlOrderly, gJohnny)
		bControlSwitchCorona = false
		DisablePunishmentSystem(true)
		BlipRemove(bBlipControlRoom)
		bUnlockLine = true
		PedOverrideStat(gFenwick, 0, 362)
		PedOverrideStat(gFenwick, 1, 100)
		PedOverrideStat(gDOThug03, 0, 362)
		PedOverrideStat(gDOThug03, 1, 100)
		PedOverrideStat(gDOThug02, 0, 362)
		PedOverrideStat(gDOThug02, 1, 100)
		F_Lights()
		gJohnnyBlip = AddBlipForChar(gJohnny, 6, 27, 4)
		mis_obj05 = MissionObjectiveAdd("5_03_024")
		TextPrint("5_03_024", 5, 1)
		Wait(1000)
		PedSetTypeToTypeAttitude(4, 13, 4)
		PedSetTypeToTypeAttitude(4, 0, 4)
		PedSetPedToTypeAttitude(gJohnny, 13, 4)
		PedSetTypeToTypeAttitude(4, 3, 2)
		PedSetTypeToTypeAttitude(3, 4, 2)
		PedSetTypeToTypeAttitude(3, 13, 2)
		PedSetTypeToTypeAttitude(3, 0, 0)
		PedSetTypeToTypeAttitude(0, 4, 4)
		PedSetTypeToTypeAttitude(0, 3, 0)
		if not bAlarmLoop then
			SoundLoopPlay2D("AsyAlrm", true)
			bAlarmLoop = true
		end
		if F_PedExists(gControlOrderly) then
			PedSetPedToTypeAttitude(gControlOrderly, 3, 0)
		end
		if F_PedExists(gStationOrderly) then
			PedDelete(gStationOrderly)
		end
		PedSetPosPoint(gJohnny, POINTLIST._5_03_JOHNNY_MOVE_FREE)
		AreaSetDoorLocked("CELLDOOR19", false)
		F_RunFreeCrazies()
		PedSetFlag(gFenwick, 117, true)
		PedSetFlag(gFenwick, 108, false)
		PedSetFlag(gDOThug01, 117, true)
		PedSetFlag(gDOThug01, 108, false)
		PedSetFlag(gDOThug02, 117, true)
		PedSetFlag(gDOThug02, 108, false)
		PedSetFlag(gDOThug03, 117, true)
		PedSetFlag(gDOThug03, 108, false)
		PunishersRespondToPlayerOnly(false)
		PAnimOpenDoor(TRIGGER._CELLDOOR19)
		PAnimDoorStayOpen(TRIGGER._CELLDOOR19)
		PAnimOpenDoor(TRIGGER._ASYDOORS15)
		PAnimOpenDoor(TRIGGER._ASYDOORS14)
		PAnimDoorStayOpen(TRIGGER._ASYDOORS14)
		PAnimDoorStayOpen(TRIGGER._ASYDOORS15)
		AreaSetDoorLockedToPeds("CELLDOOR19", true)
		PedSetHealth(gJohnny, 500)
		PedSetActionTree(gJohnny, "/Global/G_Striker_A", "Act/Anim/G_Striker_A.act")
		PedMoveToPoint(gJohnny, 2, POINTLIST._5_03_JOHNNY_OUT1)
		SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 22, "genric", false, false)
		gBlipJohnny = AddBlipForChar(gJohnny, 6, 27, 1, 0)
		PedShowHealthBar(gJohnny, true, "5_03_025", false)
		PedMoveToPoint(gJohnny, 2, POINTLIST._5_03_JOHNNY_FREE1)
		while SoundSpeechPlaying(gJohnny) do
			Wait(0)
		end
		if PedIsValid(gBlockAOrderly01) then
			PedMakeAmbient(gBlockAOrderly01)
		end
		if PedIsValid(gBlockAOrderly02) then
			PedMakeAmbient(gBlockAOrderly02)
		end
		if PedIsValid(gFrontOrderly) then
			PedMakeAmbient(gFrontOrderly)
		end
		if PedIsValid(gSleepingOrderly) then
			PedMakeAmbient(gSleepingOrderly)
		end
		bJohnnyFree = true
		if mis_obj00 then
			MissionObjectiveComplete(mis_obj00)
		else
			--print(">>>[RUI]", "NO MIS_OBJ00")
		end
	end
end

function F_RunFreeCrazies()
	PAnimOpenDoor(TRIGGER._CELLDOOR17)
	PAnimDoorStayOpen(TRIGGER._CELLDOOR17)
	AreaSetDoorLocked("CELLDOOR17", true)
	AreaSetDoorLockedToPeds("CELLDOOR17", true)
	PAnimOpenDoor(TRIGGER._CELLDOOR21)
	PAnimDoorStayOpen(TRIGGER._CELLDOOR21)
	AreaSetDoorLocked("CELLDOOR21", true)
	AreaSetDoorLockedToPeds("CELLDOOR21", true)
	PAnimOpenDoor(TRIGGER._CELLDOOR20)
	PAnimDoorStayOpen(TRIGGER._CELLDOOR20)
	AreaSetDoorLocked("CELLDOOR20", true)
	AreaSetDoorLockedToPeds("CELLDOOR20", true)
	PAnimOpenDoor(TRIGGER._CELLDOOR18)
	PAnimDoorStayOpen(TRIGGER._CELLDOOR18)
	AreaSetDoorLocked("CELLDOOR18", true)
	AreaSetDoorLockedToPeds("CELLDOOR18", true)
	SoundPlayScriptedSpeechEvent(gFenwick, "M_5_03", 39, "genric", false, false)
	PedSetCheap(gFenwick, false)
	PedSetCheap(gDOThug01, false)
	PedSetCheap(gDOThug02, false)
	PedSetCheap(gDOThug03, false)
	PedSetTetherToTrigger(gFenwick, TRIGGER._5_03_BLOCKB)
	PedSetTetherToTrigger(gDOThug03, TRIGGER._5_03_BLOCKB)
	PedSetTetherToTrigger(gDOThug02, TRIGGER._5_03_BLOCKB)
	PedSetTetherToTrigger(gDOThug01, TRIGGER._5_03_BLOCKB)
	PedSetActionTree(gFenwick, "/Global/Crazy_Basic", "Act/Anim/Crazy_Basic.act")
	PedSetActionTree(gDOThug01, "/Global/Crazy_Basic", "Act/Anim/Crazy_Basic.act")
	PedSetActionTree(gDOThug02, "/Global/Crazy_Basic", "Act/Anim/Crazy_Basic.act")
	PedSetActionTree(gDOThug03, "/Global/Crazy_Basic", "Act/Anim/Crazy_Basic.act")
	PedStop(gFenwick)
	PedStop(gDOThug01)
	PedStop(gDOThug02)
	PedStop(gDOThug03)
	PedSetInfiniteSprint(gFenwick, true)
	PedSetInfiniteSprint(gDOThug03, true)
	PedSetInfiniteSprint(gDOThug02, true)
	PedSetInfiniteSprint(gDOThug01, true)
	PedFollowPath(gFenwick, PATH._ASYLUM_PATROL_BBLOCK, 2, 2, nil, 3)
	PedFollowPath(gDOThug01, PATH._ASYLUM_PATROL_BBLOCK, 1, 0, nil, 4)
	PedFollowPath(gDOThug02, PATH._ASYLUM_PATROL_BBLOCK, 2, 2, nil, 7)
	PedFollowPath(gDOThug03, PATH._ASYLUM_PATROL_BBLOCK, 1, 1, nil, 1)
	PedSetTetherToTrigger(gBlockBOrderly01, TRIGGER._5_03_BLOCKB)
	PedSetTetherToTrigger(gBlockBOrderly02, TRIGGER._5_03_BLOCKB)
	PedSetTetherToTrigger(gControlOrderly, TRIGGER._5_03_BLOCKB)
end

function F_Lights()
	DeletePersistentEntity(index_A, simpleObject_A)
	DeletePersistentEntity(index_B, simpleObject_B)
	DeletePersistentEntity(index_C, simpleObject_C)
	DeletePersistentEntity(index_D, simpleObject_D)
	DeletePersistentEntity(index_E, simpleObject_E)
	index_A2, simpleObject_A2 = CreatePersistentEntity("ASY_AlarmLightA_ON", -735.365, 433.852, 4.92833, 0, 38)
	index_B2, simpleObject_B2 = CreatePersistentEntity("ASY_AlarmLightB_ON", -735.359, 451.473, 4.92833, 0, 38)
	index_C2, simpleObject_C2 = CreatePersistentEntity("ASY_AlarmLightC_ON", -735.367, 476.785, 4.92833, 0, 38)
	index_D2, simpleObject_D2 = CreatePersistentEntity("ASY_AlarmLightD_ON", -707.27, 487.116, 4.92833, 0, 38)
	index_E2, simpleObject_E2 = CreatePersistentEntity("ASY_AlarmLightE_ON", -763.422, 487.116, 4.92833, 0, 38)
	bLightSet2 = true
end

function F_GetOut()
	while not (bExited or bFailedDueToViolence) do
		if F_JohnnyHealth() then
			F_JohnnyHealthAction()
		end
		if not b1stWaveDown and F_1stWaveDown() then
			F_1stWaveDownAction()
			b1stWaveDown = true
		end
		if not bJohnnyGoto1 and F_JohnnyGoto1() then
			F_JohnnyGoto1Action()
			bJohnnyGoto1 = true
		end
		if not bCloseRecDoors and F_CloseRecDoors() then
			F_CloseRecDoorsAction()
			bCloseRecDoors = true
		end
		if not b2ndWaveDown and F_2ndWaveDown() then
			F_2ndWaveDownAction()
			b2ndWaveDown = true
		end
		if not bDOWing1 and F_DOWing1() then
			F_DOWing1Action()
			bDOWing1 = true
		end
		if not bPlayerExit and F_PlayerExit() then
			F_PlayerExitAction()
			bPlayerExit = true
		end
		Wait(0)
	end
end

function F_JohnnyHealth()
	return bJohnnyFree and PedGetHealth(gJohnny) <= 0
end

function F_JohnnyHealthAction()
	if PedIsValid(gJohnny) then
		SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 26, "genric", false, false)
		while SoundSpeechPlaying(gJohnny) do
			Wait(0)
		end
		TextClear()
		F_MakePlayerSafeForNIS(true)
		Wait(1000)
		CameraSetWidescreen(true)
		MinigameSetCompletion("M_FAIL", false, 0, "5_03_JOHNNYKO")
		SoundPlayMissionEndMusic(false, 4)
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		CameraFade(500, 0)
		Wait(501)
		MissionFail(true, false)
		bFailedDueToViolence = true
	end
end

function F_1stWaveDown()
	if bJohnnyFree and PedIsInAreaObject(gPlayer, gJohnny, 2, 4, 0) then
		return true
	else
		return false
	end
end

function F_1stWaveDownAction()
	Wait(500)
	BlipRemove(gJohnnyBlip)
	gJohnnyBlip = AddBlipForChar(gJohnny, 6, 27, 1)
	PedFaceObject(gJohnny, gPlayer, 3, 1)
	SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 24, "genric", false, false)
	b_rec_room = BlipAddPoint(POINTLIST._5_03_FAKE_EXIT, 0)
	PedMoveToPoint(gJohnny, 1, POINTLIST._5_03_JOHNNY_GOTO1)
	while SoundSpeechPlaying(gJohnny) do
		Wait(0)
	end
	PedAttack(gBlockBOrderly01, gDOThug03, 1, true)
	PedAttack(gBlockBOrderly02, gDOThug01, 1, true)
	PedAttack(gControlOrderly, gDOThug02, 1, true)
end

function F_JohnnyGoto1()
	return bJohnnyFree and PedIsInTrigger(gJohnny, TRIGGER._5_03_JOHNNY_GOTO1)
end

function F_JohnnyGoto1Action()
	bJohnnyGoto01 = true
	AreaSetDoorLockedToPeds("AsyDoors13", true)
	AreaSetDoorPathableToPeds(TRIGGER._ASYDOORS13, true)
	AreaSetDoorPathableToPeds(TRIGGER._ASYDOORS13, true)
	AreaSetDoorPathableToPeds(TRIGGER._ASYDOORS14, true)
	AreaSetDoorPathableToPeds(TRIGGER._ASYBARS01, true)
	AreaSetDoorPathableToPeds(TRIGGER._ASYBARS, true)
	AreaSetDoorPathableToPeds(TRIGGER._ASYDOORB, true)
end

function F_NukeBlockB()
	if PedIsValid(gFenwick) then
		PedDelete(gFenwick)
	end
	if PedIsValid(gDOThug03) then
		PedDelete(gDOThug03)
	end
	if PedIsValid(gDOThug02) then
		PedDelete(gDOThug02)
	end
	if PedIsValid(gDOThug01) then
		PedDelete(gDOThug01)
	end
	if PedIsValid(gBlockBOrderly01) then
		PedDelete(gBlockBOrderly01)
	end
	if PedIsValid(gControlOrderly) then
		PedDelete(gControlOrderly)
	end
	if PedIsValid(gBlockBOrderly02) then
		PedDelete(gBlockBOrderly02)
	end
end

function F_CloseRecDoors()
	return bJohnnyFree and PlayerIsInTrigger(TRIGGER._5_03_REC_ROOM)
end

function F_CloseRecDoorsAction()
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(500, 0)
	Wait(1000)
	PlayerSetControl(0)
	PedStop(gPlayer)
	PedStop(gJohnny)
	PedDismissAlly(gPlayer, gJohnny)
	F_NukeBlockB()
	PedSetPosPoint(gPlayer, POINTLIST._5_03_NIS_DOORS, 1)
	PedSetPosPoint(gJohnny, POINTLIST._5_03_NIS_DOORS, 2)
	Wait(1000)
	BlipRemove(b_rec_room)
	PAnimCloseDoor(TRIGGER._ASYDOORS12)
	AreaSetDoorLockedToPeds("ASYDOORS12", true)
	AreaSetDoorLocked(TRIGGER._ASYDOORS12, true)
	PAnimCloseDoor(TRIGGER._ASYDOORS14)
	AreaSetDoorLockedToPeds("ASYDOORS14", true)
	AreaSetDoorLocked(TRIGGER._ASYDOORS14, true)
	CameraFade(1000, 1)
	CameraSetWidescreen(true)
	CameraSetFOV(75)
	CameraSetXYZ(-738.8009, 484.96503, 2.589849, -737.88794, 485.32837, 2.774806)
	PedSetActionNode(gPlayer, "/Global/5_03/5_03_NIS_Gateclose/Jimmy/Jimmy01", "Act/Conv/5_03.act")
	PedSetActionNode(gJohnny, "/Global/5_03/5_03_NIS_Gateclose/Johnny/Johnny01", "Act/Conv/5_03.act")
	Wait(1750)
	CameraSetFOV(70)
	CameraSetXYZ(-733.4917, 485.34534, 3.120918, -732.5328, 485.61057, 3.21997)
	PAnimSetActionNode(TRIGGER._ASYBARS01, "/Global/AsyBars/Executes/Close5_03", "Act/Props/AsyBars.act")
	Wait(750)
	CameraSetXYZ(-734.07837, 478.5458, 3.351803, -734.2828, 477.56732, 3.363241)
	Wait(750)
	PAnimOpenDoor(TRIGGER._ASYDOORS13)
	PAnimSetActionNode(TRIGGER._ASYBARS02, "/Global/AsyBars/Executes/Close5_03", "Act/Props/AsyBars.act")
	Wait(500)
	CameraSetXYZ(-738.05365, 483.88562, 3.625614, -738.93335, 484.3598, 3.590502)
	Wait(500)
	PAnimSetActionNode(TRIGGER._ASYBARS, "/Global/AsyBars/Executes/CloseBreak", "Act/Props/AsyBars.act")
	while PAnimIsPlaying(TRIGGER._ASYBARS, "/Global/AsyBars/Executes/CloseBreak", false) do
		Wait(0)
	end
	PAnimSetActionNode(TRIGGER._ASYDOORB, "/Global/5_03/5_03_Crazy_Door/Door/Door_Open", "Act/Conv/5_03.act")
	AreaSetDoorPathableToPeds(TRIGGER._ASYDOORB, true)
	Wait(1000)
	CameraFade(500, 0)
	Wait(700)
	CameraSetWidescreen(false)
	CameraDefaultFOV()
	CameraReturnToPlayer()
	PlayerSetControl(1)
	CameraFade(1000, 1)
	Wait(1000)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	MissionObjectiveComplete(mis_obj05)
	mis_obj07 = MissionObjectiveAdd("5_03_039")
	TextPrint("5_03_039", 5, 1)
	gBlipExit = BlipAddPoint(POINTLIST._5_03_EXIT_BLIP, 0, 1)
	PedHideHealthBar(gJohnny)
	BlipRemove(gBlipJohnny)
	PedRecruitAlly(gPlayer, gJohnny)
	PedShowHealthBar(gJohnny, true, "5_03_025", false)
	PAnimOpenDoor(TRIGGER._FMDOOR07)
	AreaSetDoorLockedToPeds("FMDOOR07", true)
	AreaSetDoorPathableToPeds(TRIGGER._FMDOOR07, true)
	PAnimOpenDoor(TRIGGER._FMDOOR08)
	AreaSetDoorLockedToPeds("FMDOOR08", true)
	AreaSetDoorPathableToPeds(TRIGGER._FMDOOR08, true)
	PedSetTypeToTypeAttitude(4, 3, 0)
	PedSetTypeToTypeAttitude(3, 4, 0)
	PedSetTypeToTypeAttitude(3, 13, 0)
end

function F_2ndWaveDown()
	return bJohnnyFree and bJohnnyGoto01
end

function F_2ndWaveDownAction()
	PedFollowPath(gJohnny, PATH._5_03_JOHNNY_GOTO_PATH2, 0, 1)
	AreaSetDoorLocked(TRIGGER._DT_ASYLUM_BACK_EXIT, true)
end

function F_DOWing1()
	return PlayerIsInTrigger(TRIGGER._5_03_DOW_1)
end

function F_DOWing1Action()
end

function F_PlayerExit()
	local ex, ey, ez = GetPointList(POINTLIST._5_03_EXIT_BLIP)
	if bJohnnyFree and PlayerIsInAreaXYZ(ex, ey, ez, 1, 7) then
		return true
	else
		return false
	end
end

function F_PlayerExitAction()
	F_MakePlayerSafeForNIS(true)
	SoundLoopPlay2D("AsyAlrm", false)
	bAlarmLoop = false
	CameraFade(500, 0)
	PlayerSetControl(0)
	PedStop(gPlayer)
	BlipRemove(gBlipExit)
	PedLockTarget(gJohnny, -1)
	PedStop(gJohnny)
	PedClearObjectives(gJohnny)
	Wait(1000)
	CameraSetWidescreen(true)
	SoundStopInteractiveStream(0)
	SoundEnableInteractiveMusic(false)
	LoadAnimationGroup("NIS_5_03")
	Wait(1000)
	PedDismissAlly(gPlayer, gJohnny)
	AreaTransitionPoint(0, POINTLIST._5_03_PLAYER_END, nil, true)
	PedDelete(gJohnny)
	gJohnny = PedCreatePoint(23, POINTLIST._5_03_JOHNNY_END)
	SoundDisableSpeech_ActionTree()
	PedSetFlag(gJohnny, 129, true)
	Wait(1000)
	PedFaceObject(gJohnny, gPlayer, 3, 0)
	PedFaceObject(gPlayer, gJohnny, 2, 0)
	CameraSetWidescreen(true)
	CameraSetFOV(90)
	CameraSetXYZ(-51.77619, -308.2334, 9.321401, -52.60806, -308.75537, 9.133162)
	Wait(100)
	CameraFade(500, 1)
	Wait(501)
	PedSetActionNode(gJohnny, "/Global/5_03/5_03_NIS_Outro/Johnny/Johnny01", "Act/Conv/5_03.act")
	SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 32, "genric", false, false)
	while SoundSpeechPlaying(gJohnny) do
		Wait(0)
	end
	CameraSetFOV(40)
	CameraSetXYZ(-58.950195, -307.74258, 5.764244, -59.948635, -307.6889, 5.769963)
	PedSetActionNode(gPlayer, "/Global/5_03/5_03_NIS_Outro/Jimmy/Jimmy01", "Act/Conv/5_03.act")
	SoundPlayScriptedSpeechEvent(gPlayer, "M_5_03", 33, "genric", false, false)
	while SoundSpeechPlaying(gPlayer) do
		Wait(0)
	end
	CameraSetFOV(40)
	CameraSetXYZ(-62.13924, -304.61145, 5.414496, -62.076637, -305.60486, 5.510118)
	PedSetActionNode(gJohnny, "/Global/5_03/5_03_NIS_Outro/Johnny/Johnny02", "Act/Conv/5_03.act")
	SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 34, "genric", false, false)
	while SoundSpeechPlaying(gJohnny) do
		Wait(0)
	end
	PedSetActionNode(gPlayer, "/Global/5_03/5_03_NIS_Outro/Jimmy/Jimmy02", "Act/Conv/5_03.act")
	SoundPlayScriptedSpeechEvent(gPlayer, "M_5_03", 35, "genric", false, false)
	while SoundSpeechPlaying(gPlayer) do
		Wait(0)
	end
	PedSetActionNode(gJohnny, "/Global/5_03/5_03_NIS_Outro/Johnny/Johnny03", "Act/Conv/5_03.act")
	SoundPlayScriptedSpeechEvent(gJohnny, "M_5_03", 36, "genric", false, false)
	while SoundSpeechPlaying(gJohnny) do
		Wait(0)
	end
	CameraSetXYZ(-58.950195, -307.74258, 5.764244, -59.948635, -307.6889, 5.769963)
	PedSetActionNode(gPlayer, "/Global/5_03/5_03_NIS_Outro/Jimmy/Jimmy03", "Act/Conv/5_03.act")
	SoundPlayScriptedSpeechEvent(gPlayer, "M_5_03", 37, "genric", false, false)
	while SoundSpeechPlaying(gPlayer) do
		Wait(0)
	end
	PedSetAITree(gJohnny, "/Global/AI", "Act/AI/AI.act")
	PedSetTaskNode(gJohnny, "/Global/AI", "Act/AI/AI.act")
	PedSetActionNode(gJohnny, "/Global/5_03/5_03_Reset", "Act/Conv/5_03.act")
	PedIgnoreStimuli(gJohnny, true)
	PedStop(gJohnny)
	PedClearObjectives(gJohnny)
	PedSetInfiniteSprint(gJohnny, true)
	PedMakeAmbient(gJohnny)
	PedMoveToXYZ(gJohnny, 2, -61.9635, -315.673, 4.2595)
	if mis_obj05 ~= nil then
		MissionObjectiveComplete(mis_obj05)
	end
	if mis_obj07 ~= nil then
		MissionObjectiveComplete(mis_obj07)
	end
	PedSetFlag(gJohnny, 129, false)
	MinigameSetCompletion("M_PASS", true, 3000)
	MinigameAddCompletionMsg("MRESPECT_GP25", 2)
	ClothingGivePlayerOutfit("Orderly")
	SoundPlayMissionEndMusic(true, 4)
	SoundEnableSpeech_ActionTree()
	SetFactionRespect(4, GetFactionRespect(4) + 25)
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	F_MakePlayerSafeForNIS(false)
	CameraFade(500, 0)
	Wait(501)
	CameraReturnToPlayer(true)
	bReadyForExit = true
	MissionSucceed(true, false, false)
	SoundEnableInteractiveMusic(true)
end

function F_PlayerSpotted(buster)
	if AreaIsLoading() then
		--print("==== Area Is Loading in F_PlayerSpotted ===")
		bPlayerSpotted = false
		PlayerSetControl(1)
		return
	end
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	PedStop(buster)
	PedClearObjectives(buster)
	PedLockTarget(buster, gPlayer, 3)
	PedFaceObject(buster, gPlayer, 3, 1, false)
	PedFaceObject(gPlayer, buster, 2, 1)
	PedSetIsStealthMissionPed(buster, false)
	PedSetFlag(gPlayer, 2, false)
	local yOff = 1.5
	local zOff = 1.65
	local bzOff = 1.65
	local czOff = 0
	if (buster == gBlockAOrderly01 or buster == gBlockAOrderly02) and not bBlockAConvOver then
		--print("======= Block A Orderlies ======")
		bzOff = 1.55
		czOff = 0.85
	end
	local spotX, spotY, spotZ = PedGetOffsetInWorldCoords(buster, 0, yOff, zOff)
	local bustX, bustY, bustZ = PedGetPosXYZ(buster)
	CameraSetFOV(70)
	CameraSetXYZ(spotX, spotY, spotZ + czOff, bustX, bustY, bustZ + bzOff)
	SoundSetAudioFocusCamera()
	while SoundSpeechPlaying(buster) do
		Wait(0)
	end
	Wait(250)
	if PedIsModel(buster, 53) then
		PedSetActionNode(buster, "/Global/LE_Orderly_A/Busted", "Act/Anim/LE_Orderly_A.act")
		SoundPlayScriptedSpeechEventWrapper(buster, "M_5_03", 38, "genric", false, true)
	else
		PedSetActionNode(buster, "/Global/LE_Orderly_A/Busted", "Act/Anim/LE_Orderly_A.act")
		SoundPlayScriptedSpeechEventWrapper(buster, "M_5_03", 99, "genric", false, true)
	end
	PlayerSetControl(0)
	while SoundSpeechPlaying(buster) do
		Wait(0)
	end
	PedLockTarget(buster, -1)
	CameraFade(500, 0)
	Wait(501)
	CameraDefaultFOV()
	CameraReturnToPlayer(false)
	Wait(1000)
	SoundSetAudioFocusPlayer()
end

function F_EjectPlayerFromAsylum()
	if AreaIsLoading() then
		--print("==== Area Is Loading in F_EjectPlayerFromAsylum ===")
		bPlayerSpotted = false
		PlayerSetControl(1)
		return
	end
	CameraFade(500, 0)
	Wait(500)
	BlipRemove(gBlipAsylum)
	BlipRemove(gBlipJohnny)
	BlipRemove(gLroomBlip)
	bBustedPlayer = true
	SoundStopInteractiveStream(0)
	gBlipAsylum = BlipAddPoint(POINTLIST._5_03_TREEBLIP, 0)
	bOnGrounds = false
	bSleeperCreated = false
	bBBlockSetup = false
	bJohnnyYelling = false
	bFrontDeskSupport = false
	if bOrderlyHasChatted then
		bBlockAConvOver = true
	end
	if not bFoundJohnny then
		if mis_obj02 ~= nil then
			MissionObjectiveRemove(mis_obj02)
		end
	elseif not bPlayerHasOutfit and mis_obj03 ~= nil then
		MissionObjectiveRemove(mis_obj03)
	end
	F_DeletePeds()
	local bFromInside = false
	if AreaGetVisible() == 38 then
		bFromInside = true
	end
	if not bFirstEntrance then
		bBustedPlayer = false
	end
	if PlayerIsInStealthProp() then
		PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
	end
	AreaTransitionPoint(0, POINTLIST._5_03_FAILURE)
	F_SetUp_Grounds_Orderlies()
	PlayerSetPunishmentPoints(0)
	CameraFollowPed(gPlayer)
	CameraReset()
	CameraReturnToPlayer(true)
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	CameraFade(500, 1)
	Wait(500)
	if not bObjectiveOneComplete then
		TextPrint("5_03_94", 5, 1)
	else
		TextPrint("5_03_GETIN", 5, 1)
		objGetIn = MissionObjectiveAdd("5_03_GETIN")
	end
end

function F_Create_Fire()
	fire01 = FireCreate(TRIGGER._5_03_FIRE01, 0, 0, 5, 5)
	fire02 = FireCreate(TRIGGER._5_03_FIRE02, 0, 0, 5, 5)
	fire03 = FireCreate(TRIGGER._5_03_FIRE03, 0, 0, 5, 5)
	fire04 = FireCreate(TRIGGER._5_03_FIRE04, 0, 0, 5, 5)
	fire05 = FireCreate(TRIGGER._5_03_FIRE05, 0, 0, 5, 5)
	bFireCreated = true
end

function F_OnGrounds()
	return PlayerIsInTrigger(TRIGGER._5_03_ONGROUNDS)
end

function F_OnGroundsAction()
	BlipRemove(gBlipAsylum)
	gBlipAsylum = BlipAddPoint(POINTLIST._5_03_ASYLUM_BLIP, 0)
end

function F_DeletePeds()
	if PedIsValid(gBlockAOrderly01) then
		PedDelete(gBlockAOrderly01)
	end
	if PedIsValid(gBlockAOrderly02) then
		PedDelete(gBlockAOrderly02)
	end
	if PedIsValid(gFrontOrderly) then
		PedDelete(gFrontOrderly)
	end
	if PedIsValid(gStationOrderly) then
		PedDelete(gStationOrderly)
	end
	if PedIsValid(gBlockBOrderly01) then
		PedDelete(gBlockBOrderly01)
	end
	if PedIsValid(gBlockBOrderly02) then
		PedDelete(gBlockBOrderly02)
	end
	if PedIsValid(gSleepingOrderly) then
		PedDelete(gSleepingOrderly)
	end
	if PedIsValid(gControlOrderly) then
		PedDelete(gControlOrderly)
	end
	if PedIsValid(gJohnny) then
		PedDelete(gJohnny)
	end
	if PedIsValid(gFenwick) then
		PedDelete(gFenwick)
	end
	if PedIsValid(gDOThug03) then
		PedDelete(gDOThug03)
	end
	if PedIsValid(gDOThug02) then
		PedDelete(gDOThug02)
	end
	if PedIsValid(gDOThug01) then
		PedDelete(gDOThug01)
	end
	if PedIsValid(gOrderly01) then
		PedDelete(gOrderly01)
	end
	if PedIsValid(gOrderly02) then
		PedDelete(gOrderly02)
	end
end

function MissionCleanup() -- ! Modified
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	CameraReturnToPlayer()
	AreaDisableCameraControlForTransition(false)
	shared.bAsylumPatrols = true
	DisablePunishmentSystem(false)
	SoundStopInteractiveStream()
	if bPlayerHasOutfit and not bReadyForExit then
		--[[
		ItemSetCurrentNum(476, 0)
		]] -- Changed this to:
		ItemSetCurrentNum(510, 0)
		L_PlayerClothingRestore()
	end
	if bAlarmLoop then
		SoundLoopPlay2D("AsyAlrm", false)
	end
	MissionResetRespawnOverrides()
	if bJohnnyFree and bLightSet2 then
		DeletePersistentEntity(index_A2, simpleObject_A2)
		DeletePersistentEntity(index_B2, simpleObject_B2)
		DeletePersistentEntity(index_C2, simpleObject_C2)
		DeletePersistentEntity(index_D2, simpleObject_D2)
		DeletePersistentEntity(index_E2, simpleObject_E2)
	end
	if PedIsValid(gOrderly01) then
		PedDelete(gOrderly01)
	end
	if PedIsValid(gOrderly02) then
		PedDelete(gOrderly02)
	end
	if bJohnnyFree and PedIsValid(gJohnny) then
		PedDelete(gJohnny)
	end
	F_DeletePeds()
	if bFailedDueToViolence then
		AreaTransitionPoint(0, POINTLIST._5_03_FAILURE, 1, true)
		CameraSetWidescreen(false)
		PlayerSetControl(1)
		F_MakePlayerSafeForNIS(false)
		CameraFade(501, 1)
	end
	UnLoadAnimationGroup("NIS_5_03")
	UnLoadAnimationGroup("Hang_Talking")
	UnLoadAnimationGroup("AsyBars")
	UnLoadAnimationGroup("G_Striker")
	UnLoadAnimationGroup("F_CRAZY")
	ClearTextQueue()
	RadarRestoreMinMax()
	CameraReturnToPlayer()
	PedSetUniqueModelStatus(25, gLolaUniqueNum)
	PedSetUniqueModelStatus(29, gNortonUniqueNum)
	RegisterGlobalEventHandler(7, nil)
	DATUnload(2)
	EnablePOI()
end

function F_HackToGates()
	AreaTransitionPoint(38, POINTLIST._5_03_JOHNNY_GOTO1, 1, true)
	PAnimOpenDoor(TRIGGER._ASYDOORS15)
	PAnimOpenDoor(TRIGGER._ASYDOORS14)
	PAnimOpenDoor(TRIGGER._ASYDOORS12)
	F_BBlockSetupAction()
	PedSetPosPoint(gJohnny, POINTLIST._5_03_1F_BW_ORDERLY1)
	PedSetActionTree(gJohnny, "/Global/G_Striker_A", "Act/Anim/G_Striker_A.act")
	mis_obj03 = MissionObjectiveAdd("5_03_39")
	mis_obj05 = MissionObjectiveAdd("5_03_024")
	F_GotOrderlyOutfitAction()
	PedRecruitAlly(gPlayer, gJohnny)
	bJohnnyFree = true
	b1stWaveDown = true
end
