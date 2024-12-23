local obj01 = 0
local obj02 = 0
local obj03 = 0
local obj04 = 0
local MsPhillipsBlip
local bNotGotEverything = true
local bGotDress = false
local bGotNecklace = false
local bGotPerfume = false
local bNecklaceSpawned = false
local bDressSpawned = false
local bPerfumeSpawned = false
local bPlayerGotIt = false
local bPeanutGotIt = false
local bDressChasers = false
local bPerfumeChasers = false
local bNecklaceChasers = false
local nodeToRemember = 0
local giftX, giftY, giftZ = 0, 0, 0
local playerBike = 0
local peanutBike = 0
local chaserSpawn = 0
local tblChasers = {}
local tblPeanutSays = {}
local tblPeanutTaunt = {}
local tblItem = {}
local tblDress = tblDress
local tblPerfume = tblPerfume
local tblNecklace = tblNecklace
local tblRace = tblRace
local tblGift = tblGift
local tblObjective = tblObjective
local tblPlayer = tblPlayer
local tblPeanut = tblPeanut
local tblMsPhillips = tblMsPhillips
local bPeanut01hit = false
local bPeanut02hit = false
local STATE_GET_GIFT = 1
local gItemsCollected = 0
local bMissionSuccess = true
local timeLimit = 450
local bMissionFinished = false
local gChaser01 = -1
local gChaser02 = -1
local gBikeStay01 = 0
local gBikeStay02 = 0
local bChaser01FollowedPlayer = false
local bChaser02FollowedPlayer = false
shared.g4S12Perfume = false

function MissionSetup()
	DATLoad("4_S12.DAT", 2)
	DATInit()
	PlayCutsceneWithLoad("4-S12", true, true)
	MissionDontFadeIn()
	AreaTransitionPoint(0, POINTLIST._4_S12_PLAYERSTART, 1, true)
end

function MissionCleanup()
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	PlayerSetInvulnerable(false)
	SoundEnableSpeech_ActionTree()
	MissionTimerStop()
	if bNotGotEverything then
		if bGotDress then
			ItemSetCurrentNum(492, 0)
		end
		if bGotPerfume then
			ItemSetCurrentNum(490, 0)
		end
		if bGotNecklace then
			ItemSetCurrentNum(491, 0)
		end
	else
		ItemSetCurrentNum(521, 0)
	end
	if AreaGetVisible() == 2 then
		AreaSetDoorLockedToPeds(TRIGGER._DT_ISCHOOL_ART, false)
	end
	CounterMakeHUDVisible(false)
	SoundStopInteractiveStream()
	DATUnload(2)
	PedResetTypeAttitudesToDefault()
end

function main()
	F_TableInit()
	F_CreateBikes()
	F_PeanutCreate()
	PlayerSetControl(1)
	CameraFade(1000, 1)
	Wait(500)
	TextPrint("4_S12_MAINOBJ", 4, 1)
	MissionTimerStart(timeLimit)
	obj01 = MissionObjectiveAdd("4_S12_OBJDRESS")
	obj02 = MissionObjectiveAdd("4_S12_OBJNECKLACE")
	obj03 = MissionObjectiveAdd("4_S12_OBJPERFUME")
	tblItem.tblDress.blip = BlipAddPoint(tblItem.tblDress.blippoint, 0, 1)
	tblItem.tblNecklace.blip = BlipAddPoint(tblItem.tblNecklace.blippoint, 0, 1)
	tblItem.tblPerfume.blip = BlipAddPoint(tblItem.tblPerfume.blippoint, 0, 1)
	CounterSetIcon("MsPhillips", "MsPhillips_x")
	CounterMakeHUDVisible(true)
	CounterSetCurrent(0)
	CounterSetMax(3)
	CreateThread("T_ChaserThreat")
	SoundPlayInteractiveStreamLocked("MS_SearchingHigh.rsm", 0.6)
	while not MissionTimerHasFinished() and bMissionSuccess do
		while MissionActive() do
			F_CheckForPeanutAttacked()
			if bPeanut01hit or bPeanut02hit then
				break
			end
			if PlayerIsInTrigger(TRIGGER._4_S12_PEANUTBIKE2) then
				bTrigger01 = false
				break
			elseif PlayerIsInTrigger(TRIGGER._4_S12_PEANUTBIKE) then
				bTrigger01 = true
				break
			end
			if MissionTimerHasFinished() then
				bMissionSuccess = false
				break
			end
			Wait(0)
		end
		if not bMissionSuccess then
			break
		end
		F_PeanutGoes()
		F_GetItems()
		F_GetBack()
		MissionTimerStop()
		if not bViolentFail then
			F_Outro()
		end
		if bMissionFinished or bViolentFail then
			break
		end
	end
	if bMissionSuccess then
		PlayerSetPosPoint(POINTLIST._4_S12_MSPHILLIPS, 2)
		CameraSetWidescreen(true)
		CameraSetXYZ(-668.70953, -295.54913, 6.614568, -669.6473, -295.2023, 6.617522)
		F_MakePlayerSafeForNIS(true)
		PlayerSetControl(0)
		Wait(500)
		CameraFade(500, 1)
		Wait(501)
		MinigameSetCompletion("M_PASS", true, 5000)
		SoundPlayMissionEndMusic(true, 10)
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		CameraFade(500, 0)
		Wait(501)
		CameraReset()
		CameraReturnToPlayer()
		CameraSetWidescreen(false)
		MissionSucceed(false, false, false)
		Wait(500)
		F_MakePlayerSafeForNIS(false)
		CameraFade(500, 1)
		Wait(101)
		PlayerSetControl(1)
	elseif bViolentFail then
		SoundPlayMissionEndMusic(false, 10)
		MissionFail(false, true, "4_S12_PHILIPS_HURT")
	else
		SoundPlayMissionEndMusic(false, 10)
		MissionFail(false, true, "AS_NO_TIME")
	end
end

function F_TableInit()
	local nx, ny, nz = GetPointList(POINTLIST._4_S12_NECKLACE)
	local dx, dy, dz = GetPointList(POINTLIST._4_S12_SEXYDRESS)
	local px, py, pz = GetPointList(POINTLIST._4_S12_PERFUME)
	tblPeanutSays = {
		"4_S12_PEANUT04",
		"4_S12_PEANUT05",
		"4_S12_PEANUT06"
	}
	tblPeanutTaunt = {
		"4_S12_PEANUT01",
		"4_S12_PEANUT02",
		"4_S12_PEANUT03"
	}
	tblItem = {
		tblPerfume = {
			model = 490,
			point = POINTLIST._4_S12_PERFUME,
			blippoint = POINTLIST._4_S12_PERFUME_BLIP,
			cleanup = false,
			butes = "PermanentMission",
			blipStyle = 1,
			radarIcon = 0,
			blip = 0,
			x = px,
			y = py,
			z = pz,
			id = 0,
			blip = 0
		},
		tblDress = {
			model = 492,
			point = POINTLIST._4_S12_SEXYDRESS,
			blippoint = POINTLIST._4_S12_DRESS_BLIP,
			cleanup = false,
			butes = "PermanentMission",
			blipStyle = 1,
			radarIcon = 0,
			blip = 0,
			x = dx,
			y = dy,
			z = dz,
			id = 0,
			blip = 0
		},
		tblNecklace = {
			model = 491,
			point = POINTLIST._4_S12_NECKLACE,
			blippoint = POINTLIST._4_S12_NECKLACE_BLIP,
			cleanup = false,
			butes = "PermanentMission",
			blipStyle = 1,
			radarIcon = 0,
			blip = 0,
			x = nx,
			y = ny,
			z = nz,
			id = 0,
			blip = 0
		}
	}
	nx, ny, nz = nil, nil, nil
	dx, dy, dz = nil, nil, nil
	px, py, pz = nil, nil, nil
	tblGift = tblItem.tblPerfume
	tblPlayer = {
		startPosition = POINTLIST._4_S12_PLAYERSTART,
		startOnBike = false,
		bike = {
			model = 282,
			point = POINTLIST._4_S12_PLAYERBIKE
		}
	}
	tblPeanut = {
		id = 0,
		id2 = 0,
		point = POINTLIST._4_S12_PEANUTSTART,
		bike = {
			model = 282,
			point = POINTLIST._4_S12_PEANUTBIKE
		},
		model = 21,
		blipStyle = 4,
		radarIcon = 2,
		state = STATE_GET_GIFT,
		getGift = true,
		deliveryRadius = 4
	}
	tblChasers = {
		{
			bike = 0,
			bikemodel = 282,
			model = 26,
			id = -1,
			pos = 1
		},
		{
			bike = 0,
			bikemodel = 282,
			model = 28,
			id = -1,
			pos = 2
		}
	}
	stat = {
		{ name = 10, value = 50 },
		{ name = 11, value = 60 }
	}
	tblMsPhillips = {
		model = 63,
		point = POINTLIST._4_S12_MSPHILLIPS,
		x,
		y,
		z = GetPointList(POINTLIST._4_S12_MSPHILLIPS),
		blip = 0
	}
	LoadPedModels({
		26,
		28,
		21,
		63
	})
	LoadVehicleModels({
		tblPlayer.bike.model,
		tblPeanut.bike.model
	})
	LoadWeaponModels({ 312, 301 })
	while not PickupRequestModel(tblItem.tblNecklace.model) do
		Wait(0)
	end
	while not PickupRequestModel(tblItem.tblDress.model) do
		Wait(0)
	end
	while not PickupRequestModel(tblItem.tblPerfume.model) do
		Wait(0)
	end
	while not PickupRequestModel(521) do
		Wait(0)
	end
	--print("==== Loaded all models ====")
end

function F_RemoveOtherBlips(blip)
	if blip == tblItem.tblDress.blip then
		BlipRemove(tblItem.tblNecklace.blip)
		BlipRemove(tblItem.tblPerfume.blip)
	elseif blip == tblItem.tblNecklace.blip then
		BlipRemove(tblItem.tblPerfume.blip)
		BlipRemove(tblItem.tblDress.blip)
	elseif blip == tblItem.tblPerfume.blip then
		BlipRemove(tblItem.tblDress.blip)
		BlipRemove(tblItem.tblNecklace.blip)
	end
end

function F_RestoreBlips()
	if not bGotDress then
		tblItem.tblDress.blip = BlipAddPoint(tblItem.tblDress.blippoint, 0, 1)
	end
	if not bGotNecklace then
		tblItem.tblNecklace.blip = BlipAddPoint(tblItem.tblNecklace.blippoint, 0, 1)
	end
	if not bGotPerfume then
		tblItem.tblPerfume.blip = BlipAddPoint(tblItem.tblPerfume.blippoint, 0, 1)
	end
end

function F_GetItems()
	while MissionActive() and bNotGotEverything do
		if MissionTimerHasFinished() then
			bMissionSuccess = false
			return
		end
		if not bGotDress then
			if AreaGetVisible() == 34 and not bDressSpawned then
				BlipRemove(tblItem.tblDress.blip)
				tblItem.tblDress.id = PickupCreatePoint(tblItem.tblDress.model, tblItem.tblDress.point, 1, 0, tblItem.tblDress.butes)
				Wait(250)
				tblItem.tblDress.blip = AddBlipForPickup(tblItem.tblDress.id, 0, 4)
				F_RemoveOtherBlips(tblItem.tblDress.blip)
				bDressSpawned = true
			elseif AreaGetVisible() == 0 and bDressSpawned then
				PickupDelete(tblItem.tblDress.id)
				BlipRemove(tblItem.tblDress.blip)
				bDressSpawned = false
				F_RestoreBlips()
			end
			if bDressSpawned and PickupIsPickedUp(tblItem.tblDress.id) then
				MissionObjectiveComplete(obj01)
				BlipRemove(tblItem.tblDress.blip)
				bDressChasers = true
				bGotDress = true
				gItemsCollected = gItemsCollected + 1
				CounterSetCurrent(gItemsCollected)
				--print("==== Got Dress ====")
				F_FixChasers()
				F_RestoreBlips()
			end
		elseif bGotDress and bDressChasers and AreaGetVisible() == 0 then
			F_CreateChasers(1)
			bDressChasers = false
		end
		if not bGotNecklace then
			if AreaGetVisible() == 33 and not bNecklaceSpawned then
				BlipRemove(tblItem.tblNecklace.blip)
				tblItem.tblNecklace.id = PickupCreatePoint(tblItem.tblNecklace.model, tblItem.tblNecklace.point, 1, 0, tblItem.tblNecklace.butes)
				Wait(250)
				tblItem.tblNecklace.blip = AddBlipForPickup(tblItem.tblNecklace.id, 0, 4)
				F_RemoveOtherBlips(tblItem.tblNecklace.blip)
				bNecklaceSpawned = true
			elseif AreaGetVisible() == 0 and bNecklaceSpawned then
				PickupDelete(tblItem.tblNecklace.id)
				BlipRemove(tblItem.tblNecklace.blip)
				bNecklaceSpawned = false
				F_RestoreBlips()
			end
			if bNecklaceSpawned and PickupIsPickedUp(tblItem.tblNecklace.id) then
				MissionObjectiveComplete(obj02)
				BlipRemove(tblItem.tblNecklace.blip)
				bGotNecklace = true
				bNecklaceChasers = true
				gItemsCollected = gItemsCollected + 1
				CounterSetCurrent(gItemsCollected)
				--print("==== Got Necklace ====")
				F_FixChasers()
				F_RestoreBlips()
			end
		elseif bGotNecklace and bNecklaceChasers and AreaGetVisible() == 0 then
			F_CreateChasers(2)
			bNecklaceChasers = false
		end
		if not bGotPerfume then
			if AreaGetVisible() == 46 and not bPerfumeSpawned then
				BlipRemove(tblItem.tblPerfume.blip)
				tblItem.tblPerfume.id = PickupCreatePoint(tblItem.tblPerfume.model, tblItem.tblPerfume.point, 1, 0, tblItem.tblPerfume.butes)
				Wait(250)
				tblItem.tblPerfume.blip = AddBlipForPickup(tblItem.tblPerfume.id, 0, 4)
				bPerfumeSpawned = true
				F_RemoveOtherBlips(tblItem.tblPerfume.blip)
			elseif AreaGetVisible() == 0 and bPerfumeSpawned then
				PickupDelete(tblItem.tblPerfume.id)
				BlipRemove(tblItem.tblPerfume.blip)
				F_RestoreBlips()
				bPerfumeSpawned = false
			end
			if bPerfumeSpawned and PickupIsPickedUp(tblItem.tblPerfume.id) then
				MissionObjectiveComplete(obj03)
				BlipRemove(tblItem.tblPerfume.blip)
				bGotPerfume = true
				bPerfumeChasers = true
				gItemsCollected = gItemsCollected + 1
				CounterSetCurrent(gItemsCollected)
				--print("==== Got Perfume ====")
				F_FixChasers()
				F_RestoreBlips()
			end
		elseif bGotPerfume and bPerfumeChasers and AreaGetVisible() == 0 then
			F_CreateChasers(3)
			bPerfumeChasers = false
		end
		if bGotDress and bGotNecklace and bGotPerfume then
			bNotGotEverything = false
		end
		Wait(0)
	end
	while not PickupRequestModel(521) do
		Wait(0)
	end
	while AreaGetVisible() ~= 0 do
		if not bMissionSuccess then
			return
		end
		Wait(0)
	end
	if not MissionTimerHasFinished() then
		TextPrint("4_S12_RETURN_ITEMS", 5, 1)
		obj04 = MissionObjectiveAdd("4_S12_RETURN_ITEMS")
		tblMsPhillips.blip = BlipAddPoint(tblMsPhillips.point, 0, 1)
		if bGotDress then
			ItemSetCurrentNum(492, 0)
		end
		if bGotPerfume then
			ItemSetCurrentNum(490, 0)
		end
		if bGotNecklace then
			ItemSetCurrentNum(491, 0)
		end
		CounterMakeHUDVisible(false)
		GiveItemToPlayer(521)
	end
end

function F_GetBack()
	while MissionActive() and AreaGetVisible() ~= 2 do
		if MissionTimerHasFinished() then
			bMissionSuccess = false
			return
		end
		if bDressChasers and AreaGetVisible() == 0 then
			F_CreateChasers(1)
			bDressChasers = false
		end
		if bNecklaceChasers and AreaGetVisible() == 0 then
			F_CreateChasers(2)
			bNecklaceChasers = false
		end
		if bPerfumeChasers and AreaGetVisible() == 0 then
			F_CreateChasers(3)
			bPerfumeChasers = false
		end
		Wait(0)
	end
	if not bMissionSuccess then
		return
	end
	F_CreateMsPhillips()
	AreaSetDoorLockedToPeds(TRIGGER._DT_ISCHOOL_ART, true)
	while not (not MissionActive() or PlayerIsInTrigger(TRIGGER._4_S12_MSPHILLIPS)) do
		if MissionTimerHasFinished() then
			bMissionSuccess = false
			return
		end
		if bViolentFail then
			return
		end
		Wait(0)
	end
end

function F_PeanutGoes()
	if bTrigger01 then
		PedSetAsleep(tblPeanut.id, false)
		PedSetFocus(tblPeanut.id, gPlayer)
		PedAttackPlayer(tblPeanut.id, 3)
		PedDelete(tblPeanut.id2)
		VehicleDelete(peanutBike2)
	elseif not bTrigger01 then
		PedSetAsleep(tblPeanut.id2, false)
		PedSetFocus(tblPeanut.id2, gPlayer)
		PedAttackPlayer(tblPeanut.id2, 3)
		PedDelete(tblPeanut.id)
		VehicleDelete(peanutBike)
	end
end

function F_Outro()
	if not bMissionSuccess then
		return
	end
	CameraFade(500, 0)
	Wait(501)
	PAnimCloseDoor(TRIGGER._DT_ISCHOOL_ART)
	bMissionFinished = true
	BlipRemove(tblMsPhillips.blip)
	if PedIsValid(gChaser01) and not PedIsDead(gChaser01) then
		PedDelete(gChaser01)
	end
	if PedIsValid(gChaser02) and not PedIsDead(gChaser02) then
		PedDelete(gChaser02)
	end
	if PedIsValid(tblPeanut.id) and not PedIsDead(tblPeanut.id) then
		PedDelete(tblPeanut.id)
	end
	if PedIsValid(tblMsPhillips.id) then
		PedSetMissionCritical(tblMsPhillips.id, false)
		PedDelete(tblMsPhillips.id)
	end
	MissionObjectiveComplete(obj04)
	UnloadModels({
		26,
		28,
		21
	})
	ModelNotNeeded(282)
	ModelNotNeeded(491)
	ModelNotNeeded(492)
	ModelNotNeeded(490)
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(501)
	PlayCutsceneWithLoad("4-S12B", true, true)
	bMissionSuccess = true
end

function F_CreateMsPhillips()
	BlipRemove(tblMsPhillips.blip)
	tblMsPhillips.id = PedCreatePoint(tblMsPhillips.model, POINTLIST._4_S12_MSPHILLIPS)
	tblMsPhillips.blip = AddBlipForChar(tblMsPhillips.id, 8, 17, 4)
	PedSetStationary(tblMsPhillips.id, true)
	PedSetMissionCritical(tblMsPhillips.id, true, cbHitHer, true)
end

function cbHitHer(pedID)
	if PedGetWhoHitMeLast(pedID) == gPlayer then
		PedSetStationary(tblMsPhillips.id, false)
		PedMakeAmbient(tblMsPhillips.id)
		bMissionSuccess = false
		bViolentFail = true
	end
end

function F_CreateBikes()
	peanutBike = VehicleCreatePoint(tblPeanut.bike.model, tblPeanut.bike.point)
	peanutBike2 = VehicleCreatePoint(tblPeanut.bike.model, tblPeanut.bike.point, 2)
end

function F_FixChasers()
	local x, y, z = PedGetPosXYZ(gPlayer)
	if PedIsValid(gChaser01) then
		if not PedIsDead(gChaser01) then
			if PedIsInAreaXYZ(gChaser01, x, y, z, 10, 0) then
				bChaser01FollowedPlayer = true
			else
				bChaser01FollowedPlayer = false
			end
		end
	else
		bChaser01FollowedPlayer = false
	end
	if PedIsValid(gChaser02) then
		if not PedIsDead(gChaser02) then
			if PedIsInAreaXYZ(gChaser02, x, y, z, 10, 0) then
				bChaser02FollowedPlayer = true
			else
				bChaser02FollowedPlayer = false
			end
		end
	else
		bChaser02FollowedPlayer = false
	end
end

function F_CreateChasers(val)
	if val == 1 then
		chaserSpawn = POINTLIST._4_S12_DRESS_CHASER
	elseif val == 2 then
		chaserSpawn = POINTLIST._4_S12_NECKLACE_CHASER
	elseif val == 3 then
		chaserSpawn = POINTLIST._4_S12_PERFUME_CHASER
	end
	for i, guy in tblChasers do
		if guy.id == -1 then
			guy.id = PedCreatePoint(guy.model, chaserSpawn, guy.pos)
			PedSetPedToTypeAttitude(guy.id, 13, 0)
			PedSetFocus(guy.id, gPlayer)
			PedAttackPlayer(guy.id, 3)
		elseif not (i ~= 1 or bChaser01FollowedPlayer) or i == 2 and not bChaser02FollowedPlayer then
			if PedIsValid(guy.id) and not F_PedIsDead(guy.id) then
				local x, y, z = PedGetPosXYZ(guy.id)
				local px, py, pz = PedGetPosXYZ(gPlayer)
				if DistanceBetweenCoords2d(x, y, px, pz) >= 30 then
					PedSetPosPoint(guy.id, chaserSpawn, guy.pos)
					PedSetFocus(guy.id, gPlayer)
					PedAttackPlayer(guy.id, 3)
				end
			else
				if PedIsValid(guy.id) then
					PedDelete(guy.id)
				end
				guy.id = PedCreatePoint(guy.model, chaserSpawn, guy.pos)
				PedSetPedToTypeAttitude(guy.id, 13, 0)
				PedSetFocus(guy.id, gPlayer)
				PedAttackPlayer(guy.id, 3)
			end
		end
	end
	PedSetWeaponNow(tblChasers[1].id, 312, 12, false)
	PedSetWeaponNow(tblChasers[2].id, 312, 12, false)
	F_ChaserStats(tblChasers[1].id)
	F_ChaserStats(tblChasers[2].id)
	gChaser01 = tblChasers[1].id
	gChaser02 = tblChasers[2].id
	bWarnPlayer01 = true
	bWarnPlayer02 = true
end

function F_ChaserStats(ped)
	for s, stats in stat do
		PedOverrideStat(ped, stats.name, stats.value)
	end
end

function T_ChaserThreat()
	while MissionActive() do
		if bWarnPlayer01 and PedIsInAreaObject(gChaser01, gPlayer, 3, 3, 0) then
			SoundPlayAmbientSpeechEvent(gChaser01, "FIGHT_INITIATE")
			bWarnPlayer01 = false
		end
		if bWarnPlayer02 and PedIsInAreaObject(gChaser02, gPlayer, 3, 3, 0) then
			SoundPlayAmbientSpeechEvent(gChaser02, "FIGHT_INITIATE")
			bWarnPlayer02 = false
		end
		Wait(0)
	end
end

function F_PeanutCreate()
	tblPeanut.id = PedCreatePoint(tblPeanut.model, POINTLIST._4_S12_PEANUTSTART, 1)
	PedOverrideStat(tblPeanut.id, 36, 70)
	PedOverrideStat(tblPeanut.id, 25, 70)
	PedOverrideStat(tblPeanut.id, 33, 40)
	PedPutOnBike(tblPeanut.id, peanutBike)
	PedSetAsleep(tblPeanut.id, true)
	VehicleSetOwner(peanutBike, tblPeanut.id)
	PedSetPedToTypeAttitude(tblPeanut.id, 13, 0)
	tblPeanut.id2 = PedCreatePoint(tblPeanut.model, POINTLIST._4_S12_PEANUTSTART, 2)
	PedOverrideStat(tblPeanut.id2, 36, 70)
	PedOverrideStat(tblPeanut.id2, 25, 70)
	PedOverrideStat(tblPeanut.id2, 33, 40)
	PedPutOnBike(tblPeanut.id2, peanutBike2)
	PedSetAsleep(tblPeanut.id2, true)
	VehicleSetOwner(peanutBike2, tblPeanut.id)
	PedSetPedToTypeAttitude(tblPeanut.id2, 13, 0)
	F_ChaserStats(tblPeanut.id)
	F_ChaserStats(tblPeanut.id2)
end

function F_CheckForPeanutAttacked()
	if PedGetWhoHitMeLast(tblPeanut.id) == gPlayer then
		bPeanut01hit = true
		bTrigger01 = true
	elseif PedGetWhoHitMeLast(tblPeanut.id2) == gPlayer then
		bPeanut02hit = true
		bTrigger01 = false
	end
end

function cbPeanutAway(ped, path, node)
	if ped == tblPeanut.id and node ~= -1 and not bPlayerGotIt and not bPeanutGotIt and PedIsInAnyVehicle(tblPeanut.id) then
		nodeToRemember = node
	end
end

function F_GiftInit(tbl)
	for i, tbl in tblItem do
		if i ~= 1 then
			tbl.id = PickupCreatePoint(tbl.model, tbl.point, 1, 0, tbl.butes)
		end
	end
end
