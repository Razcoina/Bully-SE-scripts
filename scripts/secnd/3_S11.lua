local gGalloway, gGallowayBlip, gTheo, gOrderly01, gOrderly02, gOrderly03, gOrderly04, gInOrderly01, gCrazy01, nis_crazy
local mission_success = false
local gate_line = false
local bMetGalloway = false
local crazy_people = "A"
local ground_orderlies = "B"
local gBlipAsylumDoor
local bWatcherBurning = false
local gStatueLight, gStatueLightObject, gMsPhillips
local bTalkedToPhillips = true
local gMsPhillipsCar, gFrontDeskOrderly, fire01, fire02, fire03, fire04, fire05, fire06, fire07, gInPatient
local bNearGate = false
local bWasAtGate = false
local look5 = false
local look8 = false
local look11 = false
local look14 = false
local mis_obj00, mis_obj01, mis_obj02, mis_obj03, mis_obj04, mis_obj05, mis_obj06
local bMisObj00 = false
local bMisObj01 = false
local bMisObj02 = false
local bMisObj03 = false
local bMisObj04 = false
local bMisObj05 = false
local bMisObj06 = false
local gWatcherBox, gWatcherBoxObject
local reset_A = false
local reset_B = false
local ready = false
local gTreeBlip = 0
local gWatcherBlip = 0
local VISIONRANGE_MIN = 6
local VISIONRANGE_MED = 8
local VISIONRANGE_MAX = 10
local b
local bGetToAsylum = false
local bGetPastGate = false
local bGetOnAsylumGrounds = false
local bGetIntoAsylum = false
local bGetToGalloway = false
local bBustedPlayer = false
local bCleanedUpPhillips = false
local bLookThreadCreated = false
local bBustedPlayer = false
local bBustingPlayer = false
local bPlayerOnGrounds = false
local bFailedDueToViolence = false
local bEnteringAsylumNIS = false
local bDeletingTheo = false

function MissionSetup()
	MissionDontFadeIn()
	SoundPlayInteractiveStream("MS_RunningLow02.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetMidIntensityStream("MS_RunningMid.rsm", MUSIC_DEFAULT_VOLUME)
	PlayCutsceneWithLoad("3-S11", true)
	DATLoad("3_S11.DAT", 2)
	DATInit()
end

function F_MissionSetup()
	shared.bAsylumPatrols = false
	LoadActionTree("Act/Conv/3_S11.act")
	LoadActionTree("Act/Anim/Crazy_Basic.act")
	LoadAnimationGroup("Hang_Talking")
	LoadAnimationGroup("LE_ORDERLY")
	LoadAnimationGroup("F_CRAZY")
	LoadAnimationGroup("NIS_3_S11")
	AreaSetDoorLocked(TRIGGER._ASYLUM_FRONT_GATE_DOOR, true)
	LoadPedModels({
		53,
		158,
		125,
		153,
		154,
		129,
		150,
		63
	})
	while not VehicleRequestModel(293) do
		Wait(0)
	end
	DisablePOI()
	PedSetTypeToTypeAttitude(0, 6, 4)
end

function main()
	F_MissionSetup()
	AreaTransitionPoint(0, POINTLIST._3_S11_PLAYERSTART, 1, true)
	Wait(500)
	CameraFade(1000, 1)
	TextPrint("3_S11_SECRET", 5, 1)
	mis_obj00 = MissionObjectiveAdd("3_S11_SECRET")
	bMisObj00 = true
	gAsylumBlip = BlipAddPoint(POINTLIST._3_S11_SECRETPASSAGE, 0)
	AreaSetDoorLocked(TRIGGER._ASYLUM_FRONT_GATE_DOOR, true)
	AreaSetDoorLocked(TRIGGER._DT_ASYLUM_FRONT_DOOR, true)
	F_SecretPassageEntrance()
	F_SecretPassageTunnel2()
	while not PlayerIsInTrigger(TRIGGER._3_S11_PHILLIPS_CAR_STOP) do
		Wait(0)
	end
	CameraFade(1000, 0)
	Wait(1000)
	BlipRemove(gAsylumBlip)
	MissionObjectiveComplete(mis_obj01)
	F_IntroCut()
	TextPrint("3_S11_74", 5, 1)
	mis_obj02 = MissionObjectiveAdd("3_S11_74")
	bMisObj02 = true
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	gTreeBlip = BlipAddPoint(POINTLIST._3_S11_TREEBLIP, 0, 1, 1, 7)
	F_GetToAsylum()
	F_GetPastGate()
	F_GetOnAsylumGrounds()
	F_Overload()
	while not (not MissionActive() or bFailedDueToViolence) do
		F_GetIntoAsylum()
		F_GetToGalloway()
		Wait(0)
	end
	if bFailedDueToViolence then
		TextClear()
		F_MakePlayerSafeForNIS(true)
		Wait(1000)
		CameraSetWidescreen(true)
		MinigameSetCompletion("M_FAIL", false, 0, "3_S11_VOILENCE")
		SoundPlayMissionEndMusic(false, 7)
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		CameraFade(500, 0)
		Wait(501)
		MissionFail(true, false)
	else
		SoundPlayMissionEndMusic(true, 7)
		MissionSucceed(true)
	end
end

function F_NukeBike(bikes)
	for b, bike in bikes do
		if VehicleIsValid(bike) and not PlayerIsInVehicle(bike) then
			VehicleDelete(bike)
		end
	end
end

function F_IntroCut()
	F_MakePlayerSafeForNIS(true)
	PlayerSetControl(0)
	SoundDisableSpeech_ActionTree()
	PlayerClearLastVehicle()
	AreaClearAllVehicles()
	local x, y, z = PlayerGetPosXYZ()
	local bike = VehicleFindInAreaXYZ(x, y, z, 15, true)
	if bike ~= nil then
		F_NukeBike(bike)
	end
	gWatcherBox, gWatcherBoxObject = CreatePersistentEntity("SC_ObservTrans", -106.378, -344.652, 5.68995, -180, 0)
	gStatueLight, gStatueLightObject = CreatePersistentEntity("AS_statueLights", -108.125, -346.711, 10.0478, 0, 0)
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	DisablePOI()
	local pBike = 0
	pBike = VehicleFromDriver(gPlayer)
	if pBike ~= nil then
		PedStop(gPlayer)
		VehicleStop(pBike)
		Wait(100)
		PlayerDetachFromVehicle()
		while PlayerIsInAnyVehicle() do
			PlayerDetachFromVehicle()
			Wait(0)
		end
		VehicleSetPosPoint(pBike, POINTLIST._3_S11_PLAYER_AT_ASYLUM2)
	else
		AreaClearAllVehicles()
	end
	Wait(250)
	PlayerSetPosPoint(POINTLIST._3_S11_PLAYER_AT_ASYLUM)
	gMsPhillips = PedCreatePoint(63, POINTLIST._3_S11_PHILLIPS)
	gMsPhillipsCar = VehicleCreatePoint(293, POINTLIST._3_S11_PHILLIPS_CAR)
	bDeletingTheo = false
	gTheo = PedCreatePoint(53, POINTLIST._3_S11_GATE_ORDERLY)
	PedSetHealth(gTheo, PedGetHealth(gTheo) * 2)
	PedIgnoreStimuli(gMsPhillips, true)
	PedMakeTargetable(gMsPhillips, false)
	PedSetInvulnerableToPlayer(gMsPhillips, true)
	Wait(500)
	PedWarpIntoCar(gMsPhillips, gMsPhillipsCar)
	PedLockTarget(gMsPhillips, gPlayer, 3)
	PedLockTarget(gPlayer, gMsPhillipsCar, 3)
	Wait(1500)
	CameraSetFOV(80)
	CameraSetXYZ(-40.877243, -298.30627, 10.449337, -41.500557, -299.02374, 10.140832)
	VehicleSetCruiseSpeed(gMsPhillipsCar, 15)
	VehicleFollowPath(gMsPhillipsCar, PATH._3_S11_PHILLIPS_CAR_PATH, true)
	CameraFade(1000, 1)
	CameraSetWidescreen(true)
	while not VehicleIsInTrigger(gMsPhillipsCar, TRIGGER._3_S11_PHILLIPS_CAR_STOP) do
		Wait(0)
	end
	VehicleSetCruiseSpeed(gMsPhillipsCar, 0)
	VehicleStop(gMsPhillipsCar)
	VehicleEnableEngine(gMsPhillipsCar, false)
	Wait(1000)
	PedExitVehicle(gMsPhillips)
	Wait(700)
	PedLockTarget(gMsPhillips, gPlayer, 3)
	PedLockTarget(gPlayer, gMsPhillips, 3)
	PedFaceObject(gMsPhillips, gPlayer, 3, 1)
	PedFaceObject(gPlayer, gMsPhillips, 2, 1)
	PedLockTarget(gMsPhillips, gPlayer, 3)
	PedLockTarget(gPlayer, gMsPhillips, 3)
	Wait(1000)
	PedSetActionNode(gMsPhillips, "/Global/3_S11/NIS_Animations/Ms_Phillips/Ms_Phillips01", "Act/Conv/3_S11.act")
	F_PlaySpeechWait(gMsPhillips, "M_3_S11", 1, "large")
	while SoundSpeechPlaying() do
		Wait(0)
	end
	CameraSetFOV(40)
	CameraSetXYZ(-39.57438, -309.2853, 5.253273, -40.549435, -309.07697, 5.193034)
	PedSetActionNode(gMsPhillips, "/Global/3_S11/NIS_Animations/Ms_Phillips/Ms_Phillips02", "Act/Conv/3_S11.act")
	F_PlaySpeechWait(gMsPhillips, "M_3_S11", 2, "large")
	while SoundSpeechPlaying() do
		Wait(0)
	end
	CameraSetXYZ(-41.48274, -306.28537, 5.473546, -42.333817, -306.80527, 5.41899)
	PedSetActionNode(gPlayer, "/Global/3_S11/NIS_Animations/Player/Player01", "Act/Conv/3_S11.act")
	F_PlaySpeechWait(gPlayer, "M_3_S11", 3, "large")
	while SoundSpeechPlaying() do
		Wait(0)
	end
	CameraSetXYZ(-43.135685, -309.65784, 5.63587, -43.62665, -308.78952, 5.566609)
	PedSetActionNode(gMsPhillips, "/Global/3_S11/NIS_Animations/Ms_Phillips/Ms_Phillips03", "Act/Conv/3_S11.act")
	F_PlaySpeechWait(gMsPhillips, "M_3_S11", 4, "large")
	while SoundSpeechPlaying() do
		Wait(0)
	end
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(1000, 0)
	Wait(1500)
	CameraDefaultFOV()
	CameraReturnToPlayer()
	if pBike ~= nil then
		PedPutOnBike(gPlayer, pBike)
	else
		PlayerSetPosPoint(POINTLIST._3_S11_PLAYER_AT_ASYLUM2)
	end
	PedDelete(gMsPhillips)
	VehicleDelete(gMsPhillipsCar)
	F_MakePlayerSafeForNIS(false)
	Wait(1000)
	CameraFade(1000, 1)
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	SoundEnableSpeech_ActionTree()
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
	if not bSkipNIS then
		if bAmbient then
			SoundPlayAmbientSpeechEvent(pedId, strEvent)
			while SoundSpeechPlaying() do
				if WaitSkippable(1) then
					bSkipNIS = true
					return true
				end
			end
		else
			SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
			while SoundSpeechPlaying() do
				if WaitSkippable(1) then
					bSkipNIS = true
					return true
				end
			end
		end
	end
	return false
end

function F_CreatePed(tbl)
	for p, ped in tbl do
		ped.id = PedCreatePoint(ped.model, ped.point)
	end
end

function cbMissionCritical(pedID)
	--print("==== Violence Fail! ===")
	if PedGetWhoHitMeLast(pedID) == gPlayer then
		if pedID == gTheo and PedIsValid(gTheo) and not bDeletingTheo then
			bFailedDueToViolence = true
		end
		bFailedDueToViolence = true
	end
end

function F_SetUp_Crazies()
	tblCrazy = {
		{
			id = -1,
			model = 150,
			point = POINTLIST._3_S11_CRAZY01
		},
		{
			id = -1,
			model = 125,
			point = POINTLIST._3_S11_CRAZY04
		},
		{
			id = -1,
			model = 153,
			point = POINTLIST._3_S11_CRAZY05
		},
		{
			id = -1,
			model = 154,
			point = POINTLIST._3_S11_CRAZY06
		}
	}
	F_CreatePed(tblCrazy)
	for p, ped in tblCrazy do
		PedClearAllWeapons(ped.id)
		PedIgnoreStimuli(ped.id, true)
		PedSetFaction(ped.id, 6)
		PedSetActionTree(ped.id, "/Global/Crazy_Basic", "Act/Anim/Crazy_Basic.act")
	end
	gCrazy01 = tblCrazy[1].id
	gCrazy02 = tblCrazy[2].id
	gCrazy03 = tblCrazy[3].id
	gCrazy04 = tblCrazy[4].id
	PedFollowPath(gCrazy02, PATH._3_S11_CRAZY4_PATH1, 1, 0)
	PedFollowPath(gCrazy03, PATH._3_S11_CRAZY5_PATH1, 1, 0)
	PedFollowPath(gCrazy04, PATH._3_S11_CRAZY3_PATH1, 1, 0)
	PedSetPedToTypeAttitude(gCrazy01, 13, 3)
	PedSetPedToTypeAttitude(gCrazy02, 13, 3)
	PedSetPedToTypeAttitude(gCrazy03, 13, 3)
	PedSetPedToTypeAttitude(gCrazy04, 13, 3)
end

function F_SetUp_Orderlies()
	tblGroundOrderly = {
		{
			id = -1,
			model = 158,
			point = POINTLIST._3_S11_ODERLY01
		},
		{
			id = -1,
			model = 53,
			point = POINTLIST._3_S11_ODERLY02
		},
		{
			id = -1,
			model = 53,
			point = POINTLIST._3_S11_ODERLY03
		},
		{
			id = -1,
			model = 158,
			point = POINTLIST._3_S11_ODERLY04
		}
	}
	F_CreatePed(tblGroundOrderly)
end

function F_ResetCraziesAndOrderlies()
	AreaClearAllPeds()
	if PedIsValid(gCrazy01) and not PedIsDead(gCrazy01) then
		PedClearHitRecord(gCrazy01)
		PedStop(gCrazy01)
		PedClearObjectives(gCrazy01)
		PedSetPosPoint(gCrazy01, tblCrazy[1].point)
		PedSetPedToTypeAttitude(gCrazy01, 13, 3)
		PedFollowPath(gCrazy01, PATH._3_S11_CRAZY6_PATH1, 1, 0)
	end
	if PedIsValid(gCrazy02) and not PedIsDead(gCrazy02) then
		PedStop(gCrazy02)
		PedClearObjectives(gCrazy02)
		PedSetPosPoint(gCrazy02, tblCrazy[2].point)
		PedSetPedToTypeAttitude(gCrazy02, 13, 3)
		PedFollowPath(gCrazy02, PATH._3_S11_CRAZY4_PATH1, 1, 0)
	end
	if PedIsValid(gCrazy03) and not PedIsDead(gCrazy03) then
		PedStop(gCrazy03)
		PedClearObjectives(gCrazy03)
		PedSetPosPoint(gCrazy03, tblCrazy[3].point)
		PedSetPedToTypeAttitude(gCrazy03, 13, 3)
		PedFollowPath(gCrazy03, PATH._3_S11_CRAZY5_PATH1, 1, 0)
	end
	if PedIsValid(gCrazy04) and not PedIsDead(gCrazy04) then
		PedStop(gCrazy04)
		PedClearObjectives(gCrazy04)
		PedSetPosPoint(gCrazy04, tblCrazy[4].point)
		PedSetPedToTypeAttitude(gCrazy04, 13, 3)
		PedFollowPath(gCrazy04, PATH._3_S11_CRAZY3_PATH1, 1, 0)
	end
	if PedIsValid(gOrderly01) and not PedIsDead(gOrderly01) then
		PedSetStealthBehavior(gOrderly01, 0, cbNull)
		if PedIsValid(gOrderly02) then
			PedSetEmotionTowardsPed(gOrderly01, gOrderly02, 7, true)
			PedSetWantsToSocializeWithPed(gOrderly01, gOrderly02)
		end
	end
	if PedIsValid(gOrderly02) and not PedIsDead(gOrderly02) then
		PedSetStealthBehavior(gOrderly02, 0, cbNull)
		if PedIsValid(gOrderly01) then
			PedSetEmotionTowardsPed(gOrderly02, gOrderly01, 7, true)
			PedSetWantsToSocializeWithPed(gOrderly02, gOrderly01)
		end
	end
	if PedIsValid(gOrderly03) and not PedIsDead(gOrderly03) then
		PedSetStealthBehavior(gOrderly03, 0, cbNull)
		PedFollowPath(gOrderly03, PATH._3_S11_STATUE_PATH, 2, 0)
	end
	if PedIsValid(gOrderly04) and not PedIsDead(gOrderly04) then
		PedSetStealthBehavior(gOrderly04, 0, cbNull)
		PedFollowPath(gOrderly04, PATH._3_S11_ORDERLY_PATH1, 2, 0)
	end
end

function F_GetToAsylum()
	while not (not MissionActive() or bFailedDueToViolence) do
		if F_ApproachingAsylum() then
			F_ApproachingAsylumAction()
			break
		end
		Wait(0)
	end
end

local bNextCrumb = false
local gBlipCrumb = -1
local gCrumb = 1
local crumbX, crumbY, crumbZ = 0, 0, 0

function F_Crumbs()
	if not bNextCrumb and gCrumb <= 6 then
		gBlipCrumb = BlipAddPoint(POINTLIST._3_S11_CRUMBS, 0, gCrumb)
		crumbX, crumbY, crumbZ = GetPointFromPointList(POINTLIST._3_S11_CRUMBS, gCrumb)
		bNextCrumb = true
	elseif bNextCrumb and PlayerIsInAreaXYZ(crumbX, crumbY, crumbZ, 7.5, 7) then
		gCrumb = gCrumb + 1
		bNextCrumb = false
		BlipRemove(gBlipCrumb)
	end
end

local bSkipNextPassage = false

function F_SecretPassageEntrance()
	crumbX, crumbY, crumbZ = GetPointFromPointList(POINTLIST._3_S11_SECRETPASSAGE, 1)
	local x, y, z = GetPointFromPointList(POINTLIST._3_S11_CRUMBS, 6)
	while not PlayerIsInAreaXYZ(crumbX, crumbY, crumbZ, 2, 7) do
		if PlayerIsInAreaXYZ(x, y, z, 2, 0) or PlayerIsInTrigger(TRIGGER._3_S11_PHILLIPS_CAR_STOP) then
			BlipRemove(gAsylumBlip)
			MissionObjectiveRemove(mis_obj00)
			gAsylumBlip = BlipAddPoint(POINTLIST._3_S11_UNDERTHEBRIDGE, 0)
			mis_obj01 = MissionObjectiveAdd("3_S11_MEETP")
			bMisObj01 = true
			bSkipNextPassage = true
			break
		end
		Wait(0)
	end
	if not bSkipNextPassage then
		BlipRemove(gAsylumBlip)
		gAsylumBlip = BlipAddPoint(POINTLIST._3_S11_CRUMBS, 0, 6)
	end
end

function F_SecretPassageTunnel2()
	AreaSetDoorLocked(TRIGGER._ASYLUM_FRONT_GATE_DOOR, true)
	if not bSkipNextPassage then
		crumbX, crumbY, crumbZ = GetPointFromPointList(POINTLIST._3_S11_CRUMBS, 6)
		while not (PlayerIsInAreaXYZ(crumbX, crumbY, crumbZ, 2, 7) or PlayerIsInTrigger(TRIGGER._3_S11_PHILLIPS_CAR_STOP)) do
			Wait(0)
		end
		BlipRemove(gAsylumBlip)
		MissionObjectiveComplete(mis_obj00)
		mis_obj01 = MissionObjectiveAdd("3_S11_MEETP")
		bMisObj01 = true
		TextPrint("3_S11_MEETP", 5, 1)
		gAsylumBlip = BlipAddPoint(POINTLIST._3_S11_UNDERTHEBRIDGE, 0, 1, 1, 7)
	end
end

function F_ApproachingAsylum()
	return PlayerIsInTrigger(TRIGGER._3_S11_PHILLIPS_REUNION)
end

function F_ApproachingAsylumAction()
	RegisterGlobalEventHandler(7, cbMissionCritical)
	AreaClearAllPeds()
	F_SetUp_Crazies()
	Wait(500)
	F_SetUp_Orderlies()
	Wait(500)
	gOrderly01 = tblGroundOrderly[1].id
	gOrderly02 = tblGroundOrderly[2].id
	gOrderly03 = tblGroundOrderly[3].id
	gOrderly04 = tblGroundOrderly[4].id
	--print("== Order ==", gOrderly01, tblGroundOrderly[1].id)
	--print("== Order ==", gOrderly02, tblGroundOrderly[2].id)
	--print("== Order ==", gOrderly03, tblGroundOrderly[3].id)
	--print("== Order ==", gOrderly04, tblGroundOrderly[4].id)
	PedSetStealthBehavior(gOrderly01, 0, cbNull)
	PedSetStealthBehavior(gOrderly02, 0, cbNull)
	PedSetStealthBehavior(gOrderly03, 0, cbNull)
	PedSetStealthBehavior(gOrderly04, 0, cbNull)
	PedSetEmotionTowardsPed(gOrderly01, gOrderly02, 7, true)
	PedSetEmotionTowardsPed(gOrderly02, gOrderly01, 7, true)
	PedSetWantsToSocializeWithPed(gOrderly01, gOrderly02)
	PedSetWantsToSocializeWithPed(gOrderly02, gOrderly01)
	PedFollowPath(gOrderly04, PATH._3_S11_ORDERLY_PATH1, 2, 0)
	PedFollowPath(gOrderly03, PATH._3_S11_STATUE_PATH, 2, 0)
end

function F_GetPastGate()
	while not (not MissionActive() or bFailedDueToViolence) do
		if F_GateWarning() then
			F_GateWarningAction()
			break
		end
		if F_AroundGate() then
			F_AroundGateAction()
			break
		end
		if bFailedDueToViolence then
			break
		end
		Wait(0)
	end
end

function F_GateWarning()
	if bTalkedToPhillips and PlayerIsInTrigger(TRIGGER._3_S11_ASYLUM_GATE_WARNING2) and not bNearGate then
		return true
	elseif PedIsHit(gTheo, 2, 500) then
		return true
	end
	return false
end

function F_GateWarningAction()
	PedLockTarget(gTheo, gPlayer, 3)
	SoundPlayScriptedSpeechEvent(gTheo, "M_3_S11", 11, "genric", false, false)
	while SoundSpeechPlaying(gTheo) do
		Wait(0)
	end
	PedLockTarget(gTheo, -1)
	gate_line = true
	bWasAtGate = true
end

function F_AroundGate()
	if not bWasAtGate and PlayerIsInTrigger(TRIGGER._3_S11_ASYLUM_GATE_WARNING) then
		return true
	else
		return false
	end
end

function F_AroundGateAction()
	bWasAtGate = true
	bNearGate = true
	gate_line = true
end

function F_GetOnAsylumGrounds()
	while not (not MissionActive() or bFailedDueToViolence) do
		if bPlayerHitOrderly then
			F_PlayerSpotted(hitSpotter)
			F_EjectPlayerFromAsylum()
		end
		if F_PlayerOnGrounds() then
			local x, y, z = PlayerGetPosXYZ()
			if z < 5.5 then
				F_PlayerOnGroundsAction()
				break
			end
		end
		Wait(0)
	end
end

local bCrazyArrived = false

function F_CrazyOnTheRun(pedID)
	bCrazyArrived = true
end

function F_PlayerOnGrounds()
	return PlayerIsInTrigger(TRIGGER._3_S11_PLAYER_ON_A_GROUNDS)
end

function F_PlayerOnGroundsAction()
	if not PedIsDead(gCrazy01) then
		F_MakePlayerSafeForNIS(true)
		if PedIsValid(gTheo) then
			bDeletingTheo = true
			PedDelete(gTheo)
		end
		AreaSetDoorLocked(TRIGGER._DT_ASYLUM_FRONT_DOOR, true)
		Wait(750)
		gate_line = false
		BlipRemove(gTreeBlip)
		RadarSetMinMax(30, 75, 45)
		PlayerSetControl(0)
		local px, py, pz = PedGetPosXYZ(gPlayer)
		local tx, ty, tz = GetPointFromPointList(POINTLIST._3_S11_TREECAM, 2)
		PedFaceObjectNow(gPlayer, gCrazy01, 2)
		CameraSetXYZ(-143.52403, -376.5427, 5.991587, -142.5776, -376.2205, 5.974825)
		CameraSetWidescreen(true)
		CameraLookAtObject(gCrazy01, 2, false)
		PedMoveToObject(gCrazy01, gPlayer, 3, 2, F_CrazyOnTheRun, 2)
		Wait(2000)
		PedFaceObject(gCrazy01, gPlayer, 3, 0)
		while not bCrazyArrived do
			Wait(0)
		end
		PedFaceObject(gPlayer, gCrazy01, 2, 1)
		PedStop(gCrazy01)
		PedStop(gPlayer)
		PedFaceObject(gCrazy01, gPlayer, 3, 1)
		SoundPlayScriptedSpeechEvent(gCrazy01, "M_3_S11", 21, "genric", false, false)
		while SoundSpeechPlaying(gCrazy01) do
			Wait(0)
		end
		CameraSetFOV(80)
		CameraSetXYZ(-108.25994, -340.04675, 5.278171, -108.25006, -340.94998, 5.706887)
		SoundPlayScriptedSpeechEvent(gCrazy01, "M_3_S11", 60, "genric", false, false)
		while SoundSpeechPlaying(gCrazy01) do
			Wait(0)
		end
		Wait(1500)
		CameraDefaultFOV()
		F_MakePlayerSafeForNIS(false)
		CameraSetWidescreen(false)
		CameraReturnToPlayer(true)
		PlayerSetControl(1)
		PedFollowPath(gCrazy01, PATH._3_S11_CRAZY6_PATH1, 1, 1)
		PedClearObjectives(gCrazy01)
		PedFollowPath(gCrazy01, PATH._3_S11_CRAZY6_PATH1, 1, 0)
		MissionObjectiveComplete(mis_obj02)
		TextPrint("3_S11_94", 5, 1)
		mis_obj04 = MissionObjectiveAdd("3_S11_94")
		bMisObj04 = true
		gWatcherBlip = BlipAddPoint(POINTLIST._3_S11_WATCHERBOX, 0, 1, 4)
		Wait(1000)
		TutorialShowMessage("3_S11_SNEAK", 10000, false)
		bPlayerOnGrounds = true
	end
end

function F_Overload()
	--print("==== F_Overload Start ====")
	while not (not MissionActive() or bLightsOut or bFailedDueToViolence) do
		if not bBustingPlayer and bPlayerOnGrounds then
			if PedCanSeeObject(gOrderly01, gPlayer, 3) then
				F_PlayerSpotted(gOrderly01)
				F_EjectPlayerFromAsylum()
			elseif PedCanSeeObject(gOrderly02, gPlayer, 3) then
				F_PlayerSpotted(gOrderly02)
				F_EjectPlayerFromAsylum()
			elseif PedCanSeeObject(gOrderly03, gPlayer, 3) then
				F_PlayerSpotted(gOrderly03)
				F_EjectPlayerFromAsylum()
			elseif PedCanSeeObject(gOrderly04, gPlayer, 3) then
				F_PlayerSpotted(gOrderly04)
				F_EjectPlayerFromAsylum()
			end
			if bPlayerHitOrderly then
				F_PlayerSpotted(hitSpotter)
				F_EjectPlayerFromAsylum()
			end
		end
		if bFailedDueToViolence then
			break
		end
		if bBustedPlayer and not bPlayerOnGrounds and F_PlayerOnGrounds() then
			--print("==== Back in Grounds to attack statue ====")
			BlipRemove(gTreeBlip)
			bPlayerOnGrounds = true
			MissionObjectiveComplete(mis_obj02)
			TextPrint("3_S11_94", 5, 1)
			mis_obj04 = MissionObjectiveAdd("3_S11_94")
			bMisObj04 = true
			gWatcherBlip = BlipAddPoint(POINTLIST._3_S11_WATCHERBOX, 0, 1, 4)
			if PedIsValid(gTheo) then
				bDeletingTheo = true
				PedDelete(gTheo)
			end
			--print("==== Leaving Back in Grounds to attack statue ====")
		end
		if PAnimIsDestroyed(gWatcherBox, gWatcherBoxObject) and not bFailedDueToViolence then
			BlipRemove(gWatcherBlip)
			AreaSetDoorLocked(TRIGGER._DT_ASYLUM_FRONT_DOOR, false)
			AreaSetDoorLockedToPeds(TRIGGER._DT_ASYLUM_FRONT_DOOR, false)
			bLightsOut = true
			PedStopSocializing(gOrderly01)
			PedStopSocializing(gOrderly02)
			PedClearObjectives(gOrderly01)
			PedClearObjectives(gOrderly02)
			PedClearObjectives(gCrazy01)
			PedClearObjectives(gCrazy02)
			PedClearObjectives(gCrazy03)
			PedClearObjectives(gCrazy04)
			PedMoveToPoint(gOrderly01, 0, POINTLIST._3_S11_DOORGUARDTOWATCHER, 2)
			PedMoveToPoint(gOrderly02, 0, POINTLIST._3_S11_DOORGUARDTOWATCHER, 1)
			PedClearObjectives(gOrderly03)
			PedClearObjectives(gOrderly04)
			for p, ped in tblCrazy do
				PedClearObjectives(ped.id)
				PedStop(ped.id)
			end
			Wait(1000)
			if bFailedDueToViolence then
				break
			end
			local spx8, spy8, spz8 = GetPointList(POINTLIST._3_S11_SPARK08)
			PedFaceXYZ(gOrderly04, spx8, spy8, spz8, 1)
			for p, ped in tblCrazy do
				PedFaceXYZ(ped.id, spx8, spy8, spz8, 1)
			end
			local wait_random = math.random(250, 1000)
			Wait(wait_random)
			if bFailedDueToViolence then
				break
			end
			local spx9, spy9, spz9 = GetPointList(POINTLIST._3_S11_SPARK09)
			local spx10, spy10, spz10 = GetPointList(POINTLIST._3_S11_SPARK10)
			SoundPlay2D("ElectricSparks")
			EffectCreate("ElectricalSpark01", spx8, spy8, spz8)
			local wait_random = math.random(250, 1000)
			Wait(wait_random)
			if bFailedDueToViolence then
				break
			end
			EffectCreate("BottleRocketExplosion", spx10, spy10, spz10)
			SoundPlay2D("LiteBulbPop")
			local wait_random = math.random(250, 1000)
			Wait(wait_random)
			if bFailedDueToViolence then
				break
			end
			PedMoveToPoint(gCrazy01, 1, POINTLIST._3_S11_P_GOTO1, 1, CB_Face)
			PedMoveToPoint(gCrazy02, 1, POINTLIST._3_S11_P_GOTO2, 1, CB_Face)
			PedMoveToPoint(gCrazy03, 1, POINTLIST._3_S11_P_GOTO3, 1, CB_Face)
			PedMoveToPoint(gCrazy04, 1, POINTLIST._3_S11_P_GOTO4, 1, CB_Face)
			SoundPlay2D("ElectricSparks")
			EffectCreate("ElectricalSpark01", spx9, spy9, spz9)
			EffectCreate("BottleRocketExplosion", spx8, spy8, spz8)
			local wait_random = math.random(250, 1000)
			Wait(wait_random)
			if bFailedDueToViolence then
				break
			end
			SoundPlay2D("ElectricSparks")
			EffectCreate("ElectricalSpark01", spx10, spy10, spz10)
			local wait_random = math.random(250, 1000)
			Wait(wait_random)
			if bFailedDueToViolence then
				break
			end
			EffectCreate("BottleRocketExplosion", spx9, spy9, spz9)
			SoundPlay2D("LiteBulbPop")
			local wait_random = math.random(250, 1000)
			Wait(wait_random)
			if bFailedDueToViolence then
				break
			end
			SoundPlay2D("ElectricSparks")
			EffectCreate("ElectricalSpark01", spx8, spy8, spz8)
			EffectCreate("BottleRocketExplosion", spx10, spy10, spz10)
			local wait_random = math.random(250, 1000)
			Wait(wait_random)
			if bFailedDueToViolence then
				break
			end
			fire01 = FireCreate(TRIGGER._3_S11_FIRE01, 0, 0, 5, 5)
			fire02 = FireCreate(TRIGGER._3_S11_FIRE02, 0, 0, 5, 5)
			EffectCreate("BottleRocketExplosion", spx9, spy9, spz9)
			fire03 = FireCreate(TRIGGER._3_S11_FIRE03, 0, 0, 5, 5)
			fire04 = FireCreate(TRIGGER._3_S11_FIRE04, 0, 0, 5, 5)
			fire05 = FireCreate(TRIGGER._3_S11_FIRE05, 0, 0, 5, 5)
			fire06 = FireCreate(TRIGGER._3_S11_FIRE06, 0, 0, 5, 5)
			EffectCreate("BottleRocketExplosion", spx8, spy8, spz8)
			SoundPlay2D("LiteBulbPop")
			fire07 = FireCreate(TRIGGER._3_S11_FIRE07, 0, 0, 5, 5)
			bWatcherBurning = true
			DeletePersistentEntity(gStatueLight, gStatueLightObject)
			if mis_obj04 then
				MissionObjectiveComplete(mis_obj04)
			end
			gBlipAsylumDoor = BlipAddPoint(POINTLIST._3_S11_FDOOR_BLIP, 0)
			mis_obj05 = MissionObjectiveAdd("3_S11_92")
			bMisObj05 = true
			TextPrint("3_S11_92", 5, 1)
			for p, ped in tblCrazy do
				PedFaceXYZ(ped.id, spx8, spy8, spz8, 1)
			end
			Wait(1000)
			if bFailedDueToViolence then
				break
			end
			PedMoveToPoint(gOrderly03, 1, POINTLIST._3_S11_O_GOTO3, 1, CB_Face)
			SoundPlayScriptedSpeechEvent(gOrderly03, "M_3_S11", 32, "genric", false, false)
			for p, ped in tblCrazy do
				PedClearObjectives(ped.id)
			end
			PedMoveToPoint(gCrazy01, 1, POINTLIST._3_S11_CRAZYRUN, 1, cbCrazyWander)
			PedMoveToPoint(gCrazy02, 1, POINTLIST._3_S11_CRAZYRUN, 1, cbCrazyWander)
			PedMoveToPoint(gCrazy03, 1, POINTLIST._3_S11_CRAZYRUN, 2, cbCrazyWander)
			PedMoveToPoint(gCrazy04, 1, POINTLIST._3_S11_CRAZYRUN, 2, cbCrazyWander)
			PedAddPedToIgnoreList(gOrderly01, gPlayer)
			PedAddPedToIgnoreList(gOrderly02, gPlayer)
			PedAddPedToIgnoreList(gOrderly03, gPlayer)
			PedAddPedToIgnoreList(gOrderly04, gPlayer)
			PedClearObjectives(gOrderly01)
			PedClearObjectives(gOrderly02)
			PedClearObjectives(gOrderly03)
			PedClearObjectives(gOrderly04)
			PedSetStealthBehavior(gOrderly01, 1, cbNull)
			PedSetStealthBehavior(gOrderly02, 1, cbNull)
			PedSetStealthBehavior(gOrderly03, 1, cbNull)
			PedSetStealthBehavior(gOrderly04, 1, cbNull)
			PedAttack(gOrderly03, gCrazy03, 3)
			PedAttack(gOrderly04, gCrazy04, 3)
			PedMoveToPoint(gOrderly02, 1, POINTLIST._3_S11_CRAZYRUN, 1, cbCrazyWander)
			PedMoveToPoint(gOrderly01, 1, POINTLIST._3_S11_CRAZYRUN, 2, cbCrazyWander)
		end
		Wait(0)
	end
	--print("==== F_Overload End ====")
end

local hitSpotter = -1
local bPlayerHitOrderly = false

function F_CheckOrderlyHit(pedID)
	if PedIsModel(pedID, 53) or PedIsModel(pedID, 158) and PedGetWhoHitMeLast(pedID) == gPlayer then
		hitSpotter = pedID
		bPlayerHitOrderly = true
		bFailedDueToViolence = true
	end
end

function CB_Face(pedID)
	local spx8, spy8, spz8 = GetPointList(POINTLIST._3_S11_SPARK08)
	PedFaceXYZ(pedID, spx8, spy8, spz8, 1)
	PedSetCheering(pedID, true)
end

function cbCrazyWander(pedID)
	PedWander(pedID, 1)
end

function F_GetIntoAsylum()
	while not (not MissionActive() or bGetIntoAsylum or bFailedDueToViolence) do
		if bBustedPlayer and bWatcherBurning and not bPlayerOnGrounds and F_PlayerOnGrounds() then
			BlipRemove(gTreeBlip)
			bPlayerOnGrounds = true
			MissionObjectiveComplete(mis_obj02)
			mis_obj05 = MissionObjectiveAdd("3_S11_92")
			bMisObj05 = true
			TextPrint("3_S11_92", 5, 1)
			gBlipAsylumDoor = BlipAddPoint(POINTLIST._3_S11_FDOOR_BLIP, 0)
			if PedIsValid(gTheo) then
				bDeletingTheo = true
				PedDelete(gTheo)
			end
		elseif bBustedPlayer and not bWatcherBurning and not bPlayerOnGrounds and F_PlayerOnGrounds() then
			BlipRemove(gTreeBlip)
			bPlayerOnGrounds = true
			TextPrint("3_S11_94", 5, 1)
			gWatcherBlip = BlipAddPoint(POINTLIST._3_S11_WATCHERBOX, 0, 1, 4)
			if PedIsValid(gTheo) then
				bDeletingTheo = true
				PedDelete(gTheo)
			end
		end
		if F_InsideAsylum() then
			F_InsideAsylumAction()
			bGetIntoAsylum = true
		elseif not bBustingPlayer and bPlayerOnGrounds then
			if PedCanSeeObject(gOrderly01, gPlayer, 3) then
				F_PlayerSpotted(gOrderly01)
				F_EjectPlayerFromAsylum()
			elseif PedCanSeeObject(gOrderly02, gPlayer, 3) then
				F_PlayerSpotted(gOrderly02)
				F_EjectPlayerFromAsylum()
			elseif PedCanSeeObject(gOrderly03, gPlayer, 3) then
				F_PlayerSpotted(gOrderly03)
				F_EjectPlayerFromAsylum()
			elseif PedCanSeeObject(gOrderly04, gPlayer, 3) then
				F_PlayerSpotted(gOrderly04)
				F_EjectPlayerFromAsylum()
			end
			if bPlayerHitOrderly then
				F_PlayerSpotted(hitSpotter)
				F_EjectPlayerFromAsylum()
			end
		end
		Wait(0)
	end
end

function F_EnteringAsylumNIS()
	F_MakePlayerSafeForNIS(true, true)
	CameraSetWidescreen(true)
	PlayerSetControl(0)
	local x, y, z = GetPointList(POINTLIST._3_S11_PLAYERCROUCH)
	PlayerSetPosSimple(x, y, z)
	PedSetFlag(gPlayer, 2, true)
	AreaSetDoorOpen("FMDoor", true)
	AreaSetDoorLockedToPeds("FMDoor", false)
	gFrontDeskOrderly = PedCreatePoint(53, POINTLIST._3_S11_DOOR_GUARD1)
	PedFollowPath(gFrontDeskOrderly, PATH._ASYLUM_PATROL_FRONTDESK, 2, 0, cbNoPath, 1)
	PedOverrideStat(gFrontDeskOrderly, 3, 8)
	PedOverrideStat(gFrontDeskOrderly, 2, 70)
	PedSetStealthBehavior(gFrontDeskOrderly, 0, cbNull)
	CameraSetFOV(70)
	CameraSetXYZ(-734.67053, 422.53967, 2.5537, -733.9672, 423.22797, 2.73075)
	Wait(500)
	CameraFade(500, 1)
	Wait(500)
	TextPrint("3_S11_16", 5, 1)
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

function F_InsideAsylum()
	if PlayerIsInTrigger(TRIGGER._3_S11_INSIDE_ASYLUM) then
		return true
	else
		return false
	end
end

function F_InsideAsylumAction()
	while not ready do
		if AreaGetVisible() == 38 then
			ready = true
		end
		Wait(100)
	end
	if not bEnteringAsylumNIS then
		F_EnteringAsylumNIS()
		bEnteringAsylumNIS = true
	end
	local x, y, z = GetPointList(POINTLIST._3_S11_PLAYERCROUCH)
	PlayerSetPosSimple(x, y, z)
	PedSetFlag(gPlayer, 2, true)
	BlipRemove(gBlipAsylumDoor)
	AreaSetDoorLocked(TRIGGER._ASYDOORS12, true)
	AreaSetDoorLockedToPeds(TRIGGER._ASYDOORS12, true)
	AreaSetDoorLocked(TRIGGER._CELLDOOR13, false)
	AreaSetDoorLockedToPeds(TRIGGER._CELLDOOR13, false)
	PAnimOpenDoor(TRIGGER._CELLDOOR12)
	PAnimOpenDoor(TRIGGER._FMDOOR)
	AreaSetDoorLockedToPeds(TRIGGER._FMDOOR, true)
	AreaSetDoorPathableToPeds(TRIGGER._FMDOOR, true)
	gGalloway = PedCreatePoint(129, POINTLIST._3_S11_GALLOWAY)
	PedIgnoreStimuli(gGalloway, true)
	PedMakeTargetable(gGalloway, false)
	PedSetInvulnerableToPlayer(gGalloway, true)
	BlipRemoveFromChar(gGalloway)
	local x, y, z = GetAnchorPosition(TRIGGER._3_S11_GALLOWAY_TRIGGER)
	gGallowayBlip = BlipAddXYZ(x, y, z, 0, 1, 7)
	gInOrderly01 = PedCreatePoint(53, POINTLIST._3_S11_I_ORDERLY1)
	gInOrderly02 = PedCreatePoint(158, POINTLIST._3_S11_I_ORDERLY2)
	PedCanTeleportOnAreaTransition(gInOrderly01, false)
	PedCanTeleportOnAreaTransition(gInOrderly02, false)
	MissionObjectiveComplete(mis_obj05)
	mis_obj06 = MissionObjectiveAdd("3_S11_16")
	bMisObj06 = true
	TextPrint("3_S11_16", 5, 1)
	if not bOrderlyBreak then
		SoundPlayInteractiveStream("MS_StealthLow.rsm", MUSIC_DEFAULT_VOLUME)
		SoundSetMidIntensityStream("MS_StealthMid.rsm", MUSIC_DEFAULT_VOLUME)
		SoundSetHighIntensityStream("MS_StealthHigh.rsm", MUSIC_DEFAULT_VOLUME)
		gInPatient = PedCreatePoint(125, POINTLIST._3_S11_I_PATIENT)
		Wait(2000)
		PedSetActionNode(gInOrderly01, "/Global/3_S11/3_S11_O_P_Struggle/3_S11_O_Struggle_Idle", "Act/Conv/3_S11.act")
		PedSetActionNode(gInPatient, "/Global/3_S11/3_S11_O_P_Struggle/3_S11_P_Struggle_Idle", "Act/Conv/3_S11.act")
	elseif bOrderlyBreak then
		gFrontDeskOrderly = PedCreatePoint(53, POINTLIST._3_S11_DOOR_GUARD1)
		PedFollowPath(gFrontDeskOrderly, PATH._ASYLUM_PATROL_FRONTDESK, 2, 0, cbNoPath, 1)
		PedOverrideStat(gFrontDeskOrderly, 3, 8)
		PedOverrideStat(gFrontDeskOrderly, 2, 70)
		PedSetStealthBehavior(gFrontDeskOrderly, 0, cbNull)
		if PedIsValid(gInOrderly02) then
			PedDelete(gInOrderly02)
		end
		PedFollowPath(gInOrderly01, PATH._ASYLUM_PATROL_ABLOCK, 1, 0, CB_Orderly_Path2)
		PedSetStealthBehavior(gInOrderly01, 0, cbNull)
		if not bLookThreadCreated then
			CreateThread("T_O2_To_Look")
			bLookThreadCreated = true
		end
	end
end

function cbNull()
end

function F_GetToGalloway()
	while not (not MissionActive() or bGetToGalloway or bFailedDueToViolence) do
		if bBustedPlayer and bWatcherBurning and not bPlayerOnGrounds and F_PlayerOnGrounds() then
			BlipRemove(gTreeBlip)
			bPlayerOnGrounds = true
			MissionObjectiveComplete(mis_obj02)
			mis_obj05 = MissionObjectiveAdd("3_S11_92")
			bMisObj05 = true
			TextPrint("3_S11_92", 5, 1)
			gBlipAsylumDoor = BlipAddPoint(POINTLIST._3_S11_FDOOR_BLIP, 0)
		end
		if not bGetIntoAsylum and F_InsideAsylum() then
			F_InsideAsylumAction()
			bGetIntoAsylum = true
		end
		if not bOrderlyBreak and F_OrderlyBreak() then
			F_OrderlyBreakAction()
			bOrderlyBreak = true
		end
		if F_NearGalloway() then
			F_NearGallowayAction()
			bGetToGalloway = true
			break
		end
		Wait(0)
	end
end

function F_OrderlyBreak()
	return PlayerIsInTrigger(TRIGGER._3_S11_BREAK_OUT)
end

function F_OrderlyBreakAction()
	if not bOrderlyBreak then
		PedSetActionNode(gInOrderly01, "/Global/3_S11/3_S11_O_P_Struggle/3_S11_O_Struggle_Idle/3_S11_O_Struggle_Break", "Act/Conv/3_S11.act")
		PedSetActionNode(gInPatient, "/Global/3_S11/3_S11_O_P_Struggle/3_S11_P_Struggle_Idle/3_S11_P_Struggle_Break", "Act/Conv/3_S11.act")
		Wait(1000)
		PedDelete(gInPatient)
		PAnimCloseDoor(TRIGGER._CELLDOOR12)
		AreaSetDoorLocked("CELLDOOR12", true)
		PedSetActionTree(gInOrderly01, "/Global/LE_Orderly_A", "Act/Anim/LE_Orderly_A.act")
		Wait(2000)
		PedFollowPath(gInOrderly02, PATH._3_S11_I_ORDERLY1_PATH, 0, 0)
		PedSetStealthBehavior(gInOrderly02, 0, cbNull)
		PedFollowPath(gInOrderly01, PATH._ASYLUM_PATROL_ABLOCK, 1, 0, CB_Orderly_Path2, 5)
		PedSetStealthBehavior(gInOrderly01, 0, cbNull)
		if not bLookThreadCreated then
			CreateThread("T_O2_To_Look")
			bLookThreadCreated = true
		end
		gInPatient = PedCreatePoint(125, POINTLIST._3_S11_I_PATIENT2)
		PedFollowPath(gInPatient, PATH._3_S11_CRAZY_ROOM_PATH, 2, 0)
	end
end

function CB_Orderly_Path2(pedid, pathid, nodeid)
	if nodeid == 5 and PAnimIsOpen(TRIGGER._CELLDOOR) then
		look5 = true
	end
	if nodeid == 8 and PAnimIsOpen(TRIGGER._CELLDOOR16) then
		look8 = true
	end
	if nodeid == 11 and PAnimIsOpen(TRIGGER._CELLDOOR15) then
		look11 = true
	end
	if nodeid == 14 and PAnimIsOpen(TRIGGER._CELLDOOR14) then
		look14 = true
	end
end

function T_O2_To_Look()
	while not bMetGalloway do
		if look5 then
			look5 = false
			PedStop(gInOrderly02)
			local x2, y2, z2 = GetPointList(POINTLIST._3_S11_PATH2_DOOR1)
			PedFaceXYZ(gInOrderly02, x2, y2, z2, 0)
			Wait(5000)
			PedFollowPath(gInOrderly02, PATH._ASYLUM_PATROL_ABLOCK, 2, 0, CB_Orderly_Path2, 6)
		end
		if look8 then
			look8 = false
			PedStop(gInOrderly02)
			local x2, y2, z2 = GetPointList(POINTLIST._3_S11_PATH2_DOOR1)
			PedFaceXYZ(gInOrderly02, x2, y2, z2, 0)
			Wait(5000)
			PedFollowPath(gInOrderly02, PATH._ASYLUM_PATROL_ABLOCK, 2, 0, CB_Orderly_Path2, 9)
		end
		if look11 then
			look11 = false
			PedStop(gInOrderly02)
			local x2, y2, z2 = GetPointList(POINTLIST._3_S11_PATH2_DOOR1)
			PedFaceXYZ(gInOrderly02, x2, y2, z2, 0)
			Wait(5000)
			PedFollowPath(gInOrderly02, PATH._ASYLUM_PATROL_ABLOCK, 2, 0, CB_Orderly_Path2, 12)
		end
		if look14 then
			look14 = false
			PedStop(gInOrderly02)
			local x2, y2, z2 = GetPointList(POINTLIST._3_S11_PATH2_DOOR1)
			PedFaceXYZ(gInOrderly02, x2, y2, z2, 0)
			Wait(5000)
			PedFollowPath(gInOrderly02, PATH._ASYLUM_PATROL_ABLOCK, 2, 0, CB_Orderly_Path2, 15)
		end
		Wait(0)
	end
	collectgarbage()
end

function F_PlayerSpotted(buster)
	if AreaIsLoading() then
		--print("==== Area Is Loading in F_EjectPlayerFromAsylum ===")
		bPlayerSpotted = false
		return
	end
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	bBustingPlayer = true
	PedStop(buster)
	PedClearObjectives(buster)
	PedLockTarget(buster, gPlayer, 3)
	PedFaceObject(buster, gPlayer, 3, 1, false)
	PedFaceObjectNow(gPlayer, buster, 2)
	PedSetIsStealthMissionPed(buster, false)
	local spotX, spotY, spotZ = PedGetOffsetInWorldCoords(buster, 0, 1.5, 1.65)
	local bustX, bustY, bustZ = PedGetPosXYZ(buster)
	CameraSetFOV(70)
	CameraSetXYZ(spotX, spotY, spotZ, bustX, bustY, bustZ + 1.65)
	SoundSetAudioFocusCamera()
	PedSetActionNode(buster, "/Global/LE_Orderly_A/Busted", "Act/Anim/LE_Orderly_A.act")
	SoundPlayAmbientSpeechEvent(buster, "WARNING_TRESPASSING")
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
		return
	end
	CameraFade(500, 0)
	Wait(501)
	bBustedPlayer = true
	if PedIsValid(gGalloway) then
		PedDelete(gGalloway)
	end
	if PedIsValid(gFrontDeskOrderly) then
		PedDelete(gFrontDeskOrderly)
	end
	if PedIsValid(gInOrderly01) then
		PedDelete(gInOrderly01)
	end
	if PedIsValid(gInOrderly02) then
		PedDelete(gInOrderly02)
	end
	if PedIsValid(gInPatient) then
		PedDelete(gInPatient)
	end
	if bWatcherBurning then
		if PedIsValid(gCrazy01) then
			PedDelete(gCrazy01)
		end
		if PedIsValid(gCrazy02) then
			PedDelete(gCrazy02)
		end
		if PedIsValid(gCrazy03) then
			PedDelete(gCrazy03)
		end
		if PedIsValid(gCrazy04) then
			PedDelete(gCrazy04)
		end
		if PedIsValid(gOrderly01) then
			PedDelete(gOrderly01)
		end
		if PedIsValid(gOrderly02) then
			PedDelete(gOrderly02)
		end
		if PedIsValid(gOrderly03) then
			PedDelete(gOrderly03)
		end
		if PedIsValid(gOrderly04) then
			PedDelete(gOrderly04)
		end
	else
		F_ResetCraziesAndOrderlies()
	end
	if not PedIsValid(gTheo) then
		bDeletingTheo = false
		gTheo = PedCreatePoint(53, POINTLIST._3_S11_GATE_ORDERLY)
	end
	gTreeBlip = BlipAddPoint(POINTLIST._3_S11_TREEBLIP, 0, 1, 1, 7)
	bGetIntoAsylum = false
	bGetToGalloway = false
	bPlayerOnGrounds = false
	bPlayerHitOrderly = false
	bBustingPlayer = false
	if PlayerIsInStealthProp() then
		PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
	end
	AreaTransitionPoint(0, POINTLIST._3_S11_KICKEDOUT)
	Wait(100)
	PlayerSetPunishmentPoints(0)
	BlipRemove(gBlipAsylumDoor)
	BlipRemove(gWatcherBlip)
	BlipRemove(gGallowayBlip)
	PedSetFlag(gPlayer, 2, false)
	F_MakePlayerSafeForNIS(false)
	CameraFollowPed(gPlayer)
	CameraReset()
	CameraReturnToPlayer(true)
	CameraSetWidescreen(false)
	CameraFade(500, 1)
	Wait(501)
	if not bLightsOut and bMisObj04 == true then
		MissionObjectiveRemove(mis_obj04)
		bMisObj04 = false
	end
	if bMisObj06 == true then
		MissionObjectiveRemove(mis_obj06)
		bMisObj06 = false
	end
	if bMisObj05 == true then
		MissionObjectiveRemove(mis_obj05)
		bMisObj05 = false
	end
	if bMisObj02 == true then
		MissionObjectiveRemove(mis_obj02)
		bMisObj02 = false
	end
	mis_obj02 = MissionObjectiveAdd("3_S11_74")
	bMisObj02 = true
	TextPrint("3_S11_74", 5, 1)
	PlayerSetControl(1)
end

function F_NearGalloway()
	if PlayerIsInTrigger(TRIGGER._3_S11_GALLOWAY_TRIGGER) then
		return true
	else
		if PedCanSeeObject(gFrontDeskOrderly, gPlayer, 3) then
			F_PlayerSpotted(gFrontDeskOrderly)
			F_EjectPlayerFromAsylum()
		end
		if bOrderlyBreak then
			if PedCanSeeObject(gInOrderly01, gPlayer, 3) then
				F_PlayerSpotted(gInOrderly01)
				F_EjectPlayerFromAsylum()
			end
			if PedCanSeeObject(gInOrderly02, gPlayer, 3) then
				F_PlayerSpotted(gInOrderly02)
				F_EjectPlayerFromAsylum()
			end
		end
		return false
	end
end

function F_NearGallowayAction()
	bMetGalloway = true
	PlayerSetControl(0)
	BlipRemove(gGallowayBlip)
	CameraFade(500, 0)
	Wait(501)
	PAnimDelete(TRIGGER._CELLDOOR13)
	PlayerSetControl(0)
	PlayCutsceneWithLoad("3-S11C", true, true)
	CameraSetWidescreen(true)
	MissionObjectiveComplete(mis_obj06)
	PedDelete(gGalloway)
	F_NewEnding()
	F_CarDrivesAway()
end

function F_CarDrivesAway()
	CameraSetWidescreen(true)
	PedWarpIntoCar(gMsPhillips, gMsPhillipsCar)
	PedDelete(gGalloway)
	VehicleEnableEngine(gMsPhillipsCar, true)
	Wait(1000)
	VehicleFollowPath(gMsPhillipsCar, PATH._3_S11_NIS_CARLEAVE, true)
	VehicleSetCruiseSpeed(gMsPhillipsCar, 6)
	CameraSetFOV(80)
	CameraSetXYZ(-66.05141, -315.28906, 5.942597, -65.06237, -315.19977, 5.825277)
	SoundPlayMissionEndMusic(true, 7)
	MinigameSetCompletion("M_PASS", true, 6000)
	SoundEnableSpeech_ActionTree()
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	CameraFade(500, 0)
	Wait(501)
	PAnimCloseDoor(TRIGGER._ASYLUM_FRONT_GATE_DOOR)
	AreaSetDoorLocked(TRIGGER._ASYLUM_FRONT_GATE_DOOR, true)
	CameraReset()
	CameraReturnToPlayer()
	MissionSucceed(false, false, false)
	PedDelete(gMsPhillips)
	VehicleDelete(gMsPhillipsCar)
	Wait(500)
	CameraFade(500, 1)
	Wait(101)
	PlayerSetControl(1)
end

function F_NewEnding()
	CameraSetWidescreen(true)
	AreaTransitionPoint(0, POINTLIST._3_S11_OUTRONIS_WALK, 2, true)
	AreaSetDoorLocked(TRIGGER._ASYLUM_FRONT_GATE_DOOR, false)
	AreaSetDoorLockedToPeds(TRIGGER._ASYLUM_FRONT_GATE_DOOR, false)
	PlayerSetControl(0)
	gMsPhillipsCar = VehicleCreatePoint(293, POINTLIST._3_S11_CARLEAVING)
	gMsPhillips = PedCreatePoint(63, POINTLIST._3_S11_OUTRONIS, 1)
	gGalloway = PedCreatePoint(129, POINTLIST._3_S11_OUTRONIS_WALK, 1)
	SoundDisableSpeech_ActionTree()
	PedIgnoreStimuli(gMsPhillips, true)
	PedIgnoreStimuli(gGalloway, true)
	PedIgnoreStimuli(gPlayer, true)
	PedStop(gGalloway)
	PedLockTarget(gMsPhillips, gGalloway, 3)
	PedLockTarget(gGalloway, gMsPhillips, 3)
	CameraSetWidescreen(true)
	PedSetFlag(gPlayer, 2, false)
	PedFollowPath(gGalloway, PATH._3_S11_OUTRONIS_WALK, 0, 1)
	PedFollowPath(gPlayer, PATH._3_S11_OUTRONIS_WALK, 0, 1)
	Wait(50)
	CameraSetFOV(70)
	CameraSetXYZ(-67.12342, -327.37344, 6.833858, -67.045265, -326.3864, 6.693817)
	Wait(50)
	AreaSetDoorOpen(TRIGGER._ASYLUM_FRONT_GATE_DOOR, true)
	PAnimDoorStayOpen(TRIGGER._ASYLUM_FRONT_GATE_DOOR)
	CameraFade(500, 1)
	SoundPlayScriptedSpeechEvent(gGalloway, "LAUGH_CRUEL", 0, "large")
	Wait(1500)
	CameraSetXYZ(-58.75064, -314.0649, 5.572534, -59.61119, -314.57394, 5.583769)
	Wait(2000)
	CameraFade(500, 0)
	Wait(500)
	SoundDisableSpeech_ActionTree()
	PedStop(gGalloway)
	PedStop(gPlayer)
	PedSetPosPoint(gPlayer, POINTLIST._3_S11_PLAYER_ORDERLY, 1)
	PedSetPosPoint(gGalloway, POINTLIST._3_S11_OUTRONIS, 2)
	PedLockTarget(gMsPhillips, gPlayer, 3)
	PedLockTarget(gGalloway, gPlayer, 3)
	Wait(700)
	CameraFade(500, 1)
	CameraSetFOV(40)
	CameraSetXYZ(-64.0647, -317.29175, 5.873033, -63.09818, -317.03598, 5.855651)
	PedSetActionNode(gGalloway, "/Global/3_S11/NIS_Animations/OUTRO/Galloway/Galloway01", "Act/Conv/3_S11.act")
	F_PlaySpeechAndWait(gGalloway, "M_3_S11", 54, "large")
	PedSetActionNode(gMsPhillips, "/Global/3_S11/NIS_Animations/OUTRO/Phillips/Phillips01", "Act/Conv/3_S11.act")
	F_PlaySpeechAndWait(gMsPhillips, "M_3_S11", 55, "large")
	CameraSetFOV(40)
	CameraSetXYZ(-60.571716, -316.59418, 5.414894, -61.47991, -316.9889, 5.553716)
	PedSetActionNode(gPlayer, "/Global/3_S11/NIS_Animations/OUTRO/Player/Player01", "Act/Conv/3_S11.act")
	F_PlaySpeechAndWait(gPlayer, "M_3_S11", 56, "large")
end

function F_ENDIT()
	local x, y, z = GetPointList(POINTLIST._3_S11_PLAYER_ORDERLY)
	AreaLoadCollision(x, y)
	while AreaIsLoading() do
		Wait(0)
	end
	Wait(2000)
	F_NewEnding()
	F_CarDrivesAway()
end

function MissionCleanup()
	shared.bAsylumPatrols = true
	UnLoadAnimationGroup("NIS_3_S11")
	SoundStopInteractiveStream()
	PedSetFlag(gPlayer, 2, false)
	RegisterGlobalEventHandler(7, nil)
	if bFailedDueToViolence then
		AreaTransitionPoint(0, POINTLIST._3_S11_KICKEDOUT, 2, true)
		CameraSetWidescreen(false)
		PlayerSetControl(1)
		AreaSetDoorLocked(TRIGGER._DT_ASYLUM_FRONT_DOOR, false)
		F_MakePlayerSafeForNIS(false)
	end
	if bWatcherBurning then
		FireDestroy(fire01)
		FireDestroy(fire02)
		FireDestroy(fire03)
		FireDestroy(fire04)
		FireDestroy(fire05)
		FireDestroy(fire06)
		FireDestroy(fire07)
	end
	if not bWatcherBurning and gStatueLight ~= nil then
		DeletePersistentEntity(gStatueLight, gStatueLightObject)
		DeletePersistentEntity(gWatcherBox, gWatcherBoxObject)
	end
	UnLoadAnimationGroup("Hang_Talking")
	UnLoadAnimationGroup("LE_ORDERLY")
	UnLoadAnimationGroup("F_CRAZY")
	if gInOrderly01 ~= nil then
		PedMakeAmbient(gInOrderly01)
		PedMakeAmbient(gInOrderly02)
		PedMakeAmbient(gFrontDeskOrderly)
	end
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	PlayerSetControl(1)
	EnablePOI()
	AreaRevertToDefaultPopulation()
	DATUnload(2)
end
