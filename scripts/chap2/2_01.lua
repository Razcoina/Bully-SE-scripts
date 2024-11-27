--[[ Changes to this file:
	* Modified function MissionSetup, may require testing
	* Altered declaration of local functions F_NIS_CinGrocery, F_NIS_CinBarber, F_NIS_CinCloth and F_NIS_CinEnding. May be broken
]]

local bDebugNIS = false
local Edna, EdnaBlip, idGenStoreBlip, Cop1, Cop2, idCopCar1, idCopCar2
local iMissionTime = 300
local currentBlip
local blipX = 209.032
local blipY = -73.2813
local blipZ = 8.6
local bMissionComplete = false
local bMissionFail = false
local bIngredientsCollected = false
local bShopKeepGetsAngry = true
local tCamera
local tblEdnaPaths = {}
local blipClothing, blipBarber, blipGrocery
local tblBlipCleanup = {}
local idGirlBike, idGirlBikeBlip, bEdnaShrug, shrugTimer, bPlayerReachedEnd
local nMaxUniqueEdna = PedGetUniqueModelStatus(58)
local szMissionFailReason, objectiveBike, objectiveGrocery, objectiveBarber, objectiveClothing, objectiveReturn
local tblPedModels = { 58 }
local tblPickupModels = {
	528,
	507,
	499,
	521
}
local tblVehicleModels = { 281 }
local factModels = {}
local tblIngredientLocations = {
	grocery = {
		got = false,
		x = 533.808,
		y = -81.2682,
		z = 4.67603
	},
	barber = {
		got = false,
		x = 543.011,
		y = -96.5151,
		z = 5.28908
	},
	clothing = {
		got = false,
		x = 543.745,
		y = -141.831,
		z = 5.87038
	}
}

function F_TableInit()
	tblEdnaPaths = {
		PATH._2_01_EDNACAF1,
		PATH._2_01_EDNACAF2,
		PATH._2_01_EDNACAF3
	}
end

function F_CameraDebug()
	while true do
		if IsButtonPressed(14, 0) then
			F_CameraTweak()
		end
		Wait(0)
	end
	Wait(0)
end

function F_Debug()
	CameraFade(1000, 1)
	AreaTransitionPoint(2, POINTLIST._2_01_PLAYERSTART)
	local ednax, ednay, ednaz
	--print("[JASON]===============> Got the Ingredients.")
	TextPrint("2_01_OBACKEDNA", 4, 1)
	EdnaBlip = nil
	Edna = PedCreatePoint(58, POINTLIST._2_01_EDNAFIN)
	PedSetFlag(Edna, 133, false)
	PedSetPosPoint(Edna, POINTLIST._2_01_EDNAFIN)
	TextPrintString("Move to Caf Entrance to ready NIS", 4, 1)
	EdnaBlip = AddBlipForChar(Edna, 12, 0, 4)
	PedSetInvulnerable(Edna, true)
	while not PlayerIsInTrigger(TRIGGER._2_01_EDNAFACEPLAYER) do
		Wait(0)
	end
	TextPrintString("NIS ready to fire", 4, 1)
	PedFaceObject(Edna, gPlayer, 3, 1)
	while not bMissionComplete do
		if PlayerIsInAreaObject(Edna, 2, 1, 0) then
			--print("EDNA 2 : " .. Edna)
			F_CinEnding()
			Wait(500)
			bMissionComplete = true
		end
		Wait(0)
	end
end

function MissionSetup() -- ! Modified
	PlayCutsceneWithLoad("2-01", true, true, true)
	shared.gEdnaOverride = true
	DATLoad("2_01.DAT", 2)
	DATInit()
	F_TableInit()
	SoundPlayInteractiveStream("MS_SearchingLow.rsm", 0.8)
	SoundSetMidIntensityStream("MS_SearchingMid.rsm", 0.8)
	SoundSetHighIntensityStream("MS_SearchingHigh.rsm", 0.8)
	MissionDontFadeIn()
	objectiveBike = MissionObjectiveAdd("2_01_O1")
	PedSetUniqueModelStatus(58, -1)
	LoadAnimationGroup("2_01LastMinuteShop")
	LoadAnimationGroup("NIS_2_01")
	shared.gOverrideSchoolGates = false
	--LoadAnimationGroup("POI_Telloff")
	--LoadAnimationGroup("LE_Officer")
	CreateThread("T_BikeMountTut")
end

function T_BikeMountTut()
	while not PlayerIsInTrigger(TRIGGER._2_01_TUTPLAY1) do
		Wait(0)
	end
	if not PlayerIsInAnyVehicle() then
		TutorialShowMessage("TUT_BIKE3", 5000, false)
	end
	collectgarbage()
end

function main()
	LoadModels(tblPedModels)
	LoadModels(tblPickupModels)
	LoadWeaponModels({ 370 })
	LoadVehicleModels(tblVehicleModels)
	LoadActionTree("Act/Conv/2_01.act")
	shared.gOverrideSchoolGates = false
	AreaSetDoorLocked("DT_ischool_Janitor", false)
	AreaSetDoorLocked("DT_ischool_Attic", false)
	local initialBlip
	if bDebugNIS then
		F_Debug()
	end
	CameraFade(500, 0)
	Wait(500)
	AreaTransitionPoint(2, POINTLIST._2_01_PLAYERSTART, nil, true)
	CameraFade(1000, 1)
	TextPrintString("Go Find Edna's Bike.", 6, 1)
	if PedIsValid(shared.gEdnaID) then
		PedDelete(shared.gEdnaID)
	end
	F_CreateMissionCharacters()
	CreateThread("T_FailCond")
	CreateThread("T_Timer")
	CameraFade(1000, 1)
	TextPrint("2_01_OFINDBIKE", 3, 1)
	F_tBikeManager()
	F_StartCounter()
	local x, y, z = GetPointList(POINTLIST._2_01_RAZORSPAWN)
	blipBarber = BlipAddXYZ(x, y, z, 0, 4)
	x, y, z = GetPointList(POINTLIST._2_01_PLAYERSTORE)
	blipGrocery = BlipAddXYZ(x, y, z + 0.1, 0, 4)
	x, y, z = GetPointList(POINTLIST._2_01_PANTYSPAWN)
	blipCloth = BlipAddXYZ(x, y, z, 0, 4)
	objectiveGrocery = MissionObjectiveAdd("2_01_O2")
	objectiveBarber = MissionObjectiveAdd("2_01_O3")
	objectiveClothing = MissionObjectiveAdd("2_01_O4")
	F_tIngredientsGet()
	while AreaGetVisible() ~= 0 do
		Wait(0)
	end
	objectiveReturn = MissionObjectiveAdd("2_01_GOTOBUS")
	TextPrint("2_01_GOTOBUS", 4, 1)
	EdnaBlip = BlipAddPoint(POINTLIST._2_01_busstoppoint, 0, 1, 2, 0)
	TutorialStart("BUS01")
	F_CheckBackToEdna()
end

function MissionCleanup()
	BlipRemove(EdnaBlip)
	SoundStopInteractiveStream()
	shared.gEdnaOverride = nil
	F_CleanBlip(blipClothing)
	F_CleanBlip(blipGrocery)
	F_CleanBlip(blipBarber)
	ItemSetCurrentNum(528, 0)
	ItemSetCurrentNum(507, 0)
	ItemSetCurrentNum(499, 0)
	PedSetUniqueModelStatus(58, nMaxUniqueEdna)
	if currentBlip ~= nil then
		BlipRemove(currentBlip)
	end
	if currentBlip ~= nil then
		BlipRemove(idGenStoreBlip)
	end
	CameraAllowChange(true)
	CameraReset()
	CameraReturnToPlayer()
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	PlayerSetPunishmentPoints(0)
	CounterMakeHUDVisible(false)
	UnLoadAnimationGroup("2_01LastMinuteShop")
	UnLoadAnimationGroup("NIS_2_01")
	DATUnload(2)
end

function F_CleanBlip(blipID)
	if blipID then
		BlipRemove(blipID)
		blipID = nil
	end
end

function F_tIngredientsGet()
	local bGotGroceries, bGotRazor, bGotLingerie
	local playedClothCin = false
	local playedBarberCin = false
	local playedGroceryCin = false
	local ednaPanties = -1
	local ednaRazor = -1
	local ednaMeat = -1
	local tutGrocery, tutBarber, tutClothing
	while not bIngredientsCollected do
		if not tblIngredientLocations.grocery.got and AreaGetVisible() == 26 then
			while not PedIsValid(shared.vendettaClerk) do
				Wait(0)
			end
			if not playedGroceryCin then
				ednaMeat = PickupCreatePoint(528, POINTLIST._2_01_PLAYERSTORE, 1, 0, "PermanentButes")
				playedGroceryCin = true
			end
			if PlayerHasItem(528) then
				BlipRemove(blipGrocery)
				tblIngredientLocations.grocery.got = true
				CounterIncrementCurrent(1)
				if PedIsValid(shared.vendettaClerk) then
					SoundPlayScriptedSpeechEvent(shared.vendettaClerk, "M_2_01", 6, "SpeechX3")
				end
				--print("[JASON] =====> Grocery Collected" .. CounterGetCurrent())
				MissionObjectiveComplete(objectiveGrocery)
				bGotGroceries = true
			end
		end
		if bGotGroceries and AreaGetVisible() == 0 then
			if CounterGetCurrent() == CounterGetMax() - 1 then
				TextPrint("2_01_OGETREMAIN1", 2.5, 1)
				bGotGroceries = false
			else
				TextPrint("2_01_OGETREMAIN", 2.5, 1)
				bGotGroceries = false
			end
		end
		if not tblIngredientLocations.barber.got and AreaGetVisible() == 39 then
			if not playedBarberCin then
				ednaRazor = PickupCreatePoint(499, POINTLIST._2_01_RAZORSPAWN, 1, 0, "PermanentButes")
				playedBarberCin = true
			end
			if PickupIsPickedUp(ednaRazor) then
				BlipRemove(blipBarber)
				tblIngredientLocations.barber.got = true
				CounterIncrementCurrent(1)
				--print("[JASON] =====> Barber Collected" .. CounterGetCurrent())
				MissionObjectiveComplete(objectiveBarber)
				bGotRazor = true
			end
		end
		if bGotRazor then
			if PlayerIsInTrigger(TRIGGER._2_01_TUTOFF2) and IsButtonPressed(9, 0) then
				TutorialRemoveMessage()
			end
			if AreaGetVisible() == 0 then
				if CounterGetCurrent() == CounterGetMax() - 1 then
					TextPrint("2_01_OGETREMAIN1", 2.5, 1)
					bGotRazor = false
				else
					TextPrint("2_01_OGETREMAIN", 2.5, 1)
					bGotRazor = false
				end
			end
		end
		if not tblIngredientLocations.clothing.got and AreaGetVisible() == 34 then
			if not playedClothCin then
				ednaPanties = PickupCreatePoint(507, POINTLIST._2_01_PANTYSPAWN, 1, 0, "PermanentButes")
				playedClothCin = true
			end
			if PickupIsPickedUp(ednaPanties) then
				BlipRemove(blipCloth)
				tblIngredientLocations.clothing.got = true
				CounterIncrementCurrent(1)
				--print("[JASON] =====> Clothing Collected" .. CounterGetCurrent())
				MissionObjectiveComplete(objectiveClothing)
				bGotLingerie = true
			end
		end
		if bGotLingerie and AreaGetVisible() == 0 then
			if CounterGetCurrent() == CounterGetMax() - 1 then
				TextPrint("2_01_OGETREMAIN1", 2.5, 1)
				bGotRazor = false
			else
				TextPrint("2_01_OGETREMAIN", 2.5, 1)
				bGotLingerie = false
			end
		end
		if CounterGetCurrent() == CounterGetMax() then
			bIngredientsCollected = true
			CounterMakeHUDVisible(false)
			--print("[JASON] =====> Ingredients Collected")
		end
		Wait(0)
	end
	--print("[JASON]==========> IngredientsGet thread KILLED")
	collectgarbage()
end

function F_tBike()
	local px, py, pz, bx, by, bz
	local bPlayerNotInMainmap = false
	local FinishedWithBike = false
	while not FinishedWithBike do
		if not PlayerIsInVehicle(idGirlBike) then
			if not idGirlBikeBlip then
				idGirlBikeBlip = AddBlipForCar(idGirlBike, 0, 4)
			end
		elseif PlayerIsInAnyVehicle() and idGirlBikeBlip then
			BlipRemove(idGirlBikeBlip)
			idGirlBikeBlip = nil
		end
		if bIngredientsCollected and PlayerIsInTrigger(TRIGGER._AMB_SCHOOL_AREA) then
			FinishedWithBike = true
			--print("[JASON] =====================> FINISHED WITH BIKE")
			if idGirlBikeBlip then
				BlipRemove(idGirlBikeBlip)
				idGirlBikeBlip = nil
			end
		end
		Wait(0)
	end
	collectgarbage()
end

function T_Timer()
	MissionTimerStart(325)
	while not bMissionComplete do
		if MissionTimerHasFinished() then
			szMissionFailReason = "2_01_FAILTIME"
			bMissionFail = true
		end
		Wait(0)
	end
end

function F_CinEnding()
	PlayerSetControl(0)
	PedSetPosXYZ(gPlayer, -638.7, -269.5, -1.7)
	CameraSetWidescreen(true)
	PedFaceObject(Edna, gPlayer, 3, 1)
	PedFaceObject(gPlayer, Edna, 2, 1)
	CameraSetXYZ(-638.61383, -271.38647, -0.082731, -638.43994, -270.4136, -0.235106)
	F_MakePlayerSafeForNIS(true, true, true)
	CameraAllowChange(false)
	PedLockTarget(gPlayer, Edna, 3)
	PedLockTarget(Edna, gPlayer, 3)
	while not RequestModel(370) do
		Wait(0)
	end
	PedLockTarget(gPlayer, Edna, 3)
	PedLockTarget(Edna, gPlayer, 3)
	SoundPlayScriptedSpeechEvent(gPlayer, "M_2_01", 19, "SpeechX3")
	while not PedIsPlaying(gPlayer, "/Global/2_01/Anim/Give/GiveEdna_2_01", true) do
		Wait(100)
		PedSetActionNode(gPlayer, "/Global/2_01/Anim/Give/GiveEdna_2_01", "Act/Conv/2_01.act")
	end
	while PedIsPlaying(gPlayer, "/Global/2_01/Anim/Give/GiveEdna_2_01", true) do
		Wait(0)
	end
	PedLockTarget(gPlayer, Edna, 3)
	PedLockTarget(Edna, gPlayer, 3)
	CameraSetXYZ(-638.68317, -270.42636, -0.356995, -638.3997, -269.47043, -0.281169)
	F_PlaySpeechWait(Edna, 20, "/Global/2_01/Anim/EndingNIS/20")
	shared.gEdnaID = Edna
	PedMakeAmbient(shared.gEdnaID)
	PedSetMissionCritical(Edna, false)
	PedMoveToXYZ(shared.gEdnaID, 0, -629.4033, -264.99234, -0.661088)
	Wait(100)
	CameraFade(500, 0)
	Wait(501)
	CameraAllowChange(true)
	PlayerSetPosPoint(POINTLIST._2_01_CAFENDPOS, 1)
	CameraSetWidescreen(true)
	Wait(10)
	CameraReset()
	Wait(1)
	CameraSetXYZ(-639.10657, -275.2649, -0.462724, -639.0882, -274.2652, -0.452183)
	Wait(10)
	Wait(500)
	CameraFade(500, 1)
	Wait(501)
	MinigameSetCompletion("M_PASS", true, 1500)
	SoundPlayMissionEndMusic(true, 10)
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	CameraFade(500, 0)
	Wait(501)
	CameraReset()
	CameraReturnToPlayer()
	MissionSucceed(false, false, false)
	CameraSetWidescreen(false)
	F_MakePlayerSafeForNIS(false)
	Wait(500)
	CameraFade(500, 1)
	Wait(101)
	PlayerSetControl(1)
end

function F_CBPlayerEndPath(pedid, pathid, nodeid)
	if nodeid == PathGetLastNode(pathid) then
		bPlayerReachedEnd = true
	end
end

function F_KillCars()
	local bLoop = true
	while bLoop do
		if PlayerIsInTrigger(TRIGGER._AMB_BUSINESS_AREA) then
			bLoop = false
		end
	end
end

function F_tBikeManager()
	local msgMountBikeTutorial
	idGirlBike = VehicleCreatePoint(281, POINTLIST._2_01_BIKESPAWN)
	idGirlBikeBlip = AddBlipForCar(idGirlBike, 0, 4)
	VehicleSetOwner(idGirlBike, gPlayer)
	while not (PlayerIsInAnyVehicle() or PlayerIsInTrigger(TRIGGER._AMB_BUSINESS_AREA)) do
		if not msgMountBikeTutorial and PlayerIsInTrigger(TRIGGER._2_01_MOUNTBIKE) then
			msgMountBikeTutorial = true
		end
		Wait(0)
	end
	MissionObjectiveComplete(objectiveBike)
	TextPrint("2_01_OFINDITEMS", 3, 1)
	BlipRemove(idGirlBikeBlip)
	idGirlBikeBlip = nil
end

function F_CreateMissionCharacters()
	Edna = PedCreatePoint(58, POINTLIST._2_01_EDNA)
	PedSetFlag(Edna, 133, false)
	PedSetMissionCritical(Edna, true, cbFail, true)
	--print("Creating Edna")
	--print("Created Edna")
	PedIgnoreStimuli(Edna, true)
end

function F_CreatePedTable(tblOfPeds)
	for i, entry in tblOfPeds do
		entry.id = PedCreatePoint(entry.model, entry.point, entry.element)
		if entry.animation then
			Wait(0)
		end
	end
end

function F_tEdnaWalk()
	bEdnaShrug = true
	local randomi
	local randomlast = 1
	local hungerTimer = GetTimer()
	shrugTimer = GetTimer()
	while not bIngredientsCollected do
		if bEdnaShrug and GetTimer() > shrugTimer + 1000 then
			PedSetActionNode(Edna, "/Global/2_01/Anim/EdnaShrug", "Act/Conv/2_01.act")
			randomi = math.random(1, table.getn(tblEdnaPaths))
			while randomi == randomlast do
				randomi = math.random(1, table.getn(tblEdnaPaths))
				--print("RANDOMI/RANDOMLAST == " .. randomi .. " / " .. randomlast)
				Wait(0)
			end
			PedFollowPath(Edna, tblEdnaPaths[randomi], 3, 0, F_CBShrug)
			bEdnaShrug = false
			randomlast = randomi
		end
		Wait(0)
	end
	PedStop(Edna)
	PedClearObjectives(Edna)
end

function cbFail()
	--print(">>>[JASON]", "cbFail ")
	szMissionFailReason = "2_01_HITEDNA"
	bMissionFail = true
end

function T_FailCond()
	while not bMissionComplete do
		Wait(0)
		if PedIsValid(Edna) and PedGetWhoHitMeLast(Edna) == gPlayer then
			szMissionFailReason = "2_01_HITEDNA"
			bMissionFail = true
		end
		if bMissionFail then
			if Edna then
				shared.gEdnaID = Edna
				PedMakeAmbient(shared.gEdnaID)
			end
			SoundPlayMissionEndMusic(false, 10)
			MissionFail(false, true, szMissionFailReason)
			Wait(50000)
		end
	end
end

function F_CBShrug()
	bEdnaShrug = true
	shrugTimer = GetTimer()
end

function F_CheckBackToEdna()
	local ednax, ednay, ednaz
	--print("[JASON]===============> Got the Ingredients.")
	while not PlayerIsInTrigger(TRIGGER._ZONESCHOOL) or shared.gBusTransition do
		Wait(0)
	end
	MissionObjectiveComplete(objectiveReturn)
	objectiveReturn = MissionObjectiveAdd("2_01_OBACKEDNA")
	TextPrint("2_01_OBACKEDNA", 4, 1)
	BlipRemove(EdnaBlip)
	EdnaBlip = nil
	PedSetPosPoint(Edna, POINTLIST._2_01_EDNAFIN)
	EdnaBlip = AddBlipForChar(Edna, 12, 0, 4)
	while not PlayerIsInTrigger(TRIGGER._2_01_EDNAFACEPLAYER) do
		Wait(0)
	end
	PedFaceObject(Edna, gPlayer, 3, 1)
	while not bMissionComplete do
		if not bMissionFail and PlayerIsInAreaObject(Edna, 2, 1, 0) then
			--print("EDNA 2 : " .. Edna)
			if PedIsValid(Edna) then
				PedSetInvulnerable(Edna, true)
			end
			MissionTimerStop()
			MissionObjectiveComplete(objectiveReturn)
			F_CinEnding()
			if PedIsValid(Edna) then
				PedAddPedToIgnoreList(Edna, gPlayer)
				PedSetInvulnerable(Edna, false)
				BlipRemove(EdnaBlip)
			end
		end
		Wait(0)
	end
end

function F_StartCinematic(pedFocus, actionNode, actionFile)
	CameraSetWidescreen(true)
	PlayerSetControl(0)
	PedStop(pedFocus)
	PedStop(gPlayer)
	PedFaceObject(pedFocus, gPlayer, 2, 0)
	PedFaceObject(gPlayer, pedFocus, 2, 0)
	PedStartConversation(actionNode, actionFile, gPlayer, pedFocus)
	while PedInConversation(pedFocus) or PedInConversation(gPlayer) do
		Wait(100)
	end
	CameraSetWidescreen(false)
	PlayerSetControl(1)
end

function F_StartCounter()
	CounterSetIcon("caflady", "caflady_x")
	CounterMakeHUDVisible(true)
	CounterSetCurrent(0)
	CounterSetMax(3)
end

function F_BlipCreateXYZ(xx, yy, zz)
	local blipID
	blipID = BlipAddXYZ(xx, yy, zz, 0)
	table.insert(tblBlipCleanup, { blip = blipID })
	return blipID
end

function F_BlipCleanup()
	for i, entry in tblBlipCleanup do
		if entry.blip ~= nil then
			BlipRemove(entry.blip)
		end
	end
	tblBlipCleanup = nil
end

function F_FindClosestPed()
	local targets = {}
	targets = {
		{ target = -1 },
		{ target = -1 },
		{ target = -1 },
		{ target = -1 },
		{ target = -1 },
		{ target = -1 },
		{ target = -1 }
	}
	local x2, y2, z2 = PlayerGetPosXYZ()
	target, targets[1].target, targets[2].target, targets[3].target, targets[4].target, targets[5].target, targets[6].target = PedFindInAreaXYZ(x2, y2, z2, 19)
	--print("===== Peds =", targets[1].target, targets[2].target, targets[3].target, targets[4].target, targets[5].target, targets[6].target)
	for i = table.getn(targets), 1, -1 do
		if PedIsValid(targets[i].target) then
			--print("RETURNING: " .. targets[i].target)
			return targets[i].target
		end
	end
end

local gNIS = 1
local b_DebuggingNIS = false
local NISTotal = 4

local function F_NIS_CinGrocery()
	AreaTransitionPoint(26, POINTLIST._2_01_PLAYERSTORE)
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	CameraLookAtXYZ(-574.80206, 391.85327, 1.5672069, true)
	CameraSetXYZ(-571.7021, 392.68326, 2.0672066, -574.80206, 391.85327, 1.5672069)
	CameraAllowChange(false)
	PedFollowPath(gPlayer, PATH._2_01_CINGROCPATH, 0, 0, F_CBPlayerEndPath)
	while not bPlayerReachedEnd do
		Wait(0)
	end
	bPlayerReachedEnd = false
	local shopkeep = F_FindClosestPed()
	--print("shopkeep = " .. shopkeep)
	TextPrint("2_01_GROC1", 4, 2)
	CameraLookAtObject(gPlayer, 3, false, 0.5)
	WaitSkippable(4000)
	TextPrint("2_01_GROC2", 4, 2)
	CameraLookAtObject(shopkeep, 2, false, 0.5)
	WaitSkippable(4000)
	CameraLookAtObject(gPlayer, 3, false, 0.5)
	TextPrint("2_01_GROC3", 4, 2)
	WaitSkippable(4000)
	CameraLookAtObject(shopkeep, 2, false, 0.5)
	TextPrint("2_01_GROC4", 4, 2)
	WaitSkippable(4000)
	PedFaceObject(gPlayer, shopkeep, 2, 1)
	PedFaceObject(shopkeep, gPlayer, 2, 1)
	Wait(250)
	PedSetActionNode(shopkeep, "/Global/2_01/Anim/GiveItem/Give", "Act/Conv/2_01.act")
	PedSetActionNode(gPlayer, "/Global/2_01/Anim/GiveItem/Receive", "Act/Conv/2_01.act")
	while PedIsPlaying(gPlayer, "/Global/2_01/Anim/GiveItem", true) do
		Wait(0)
	end
	Wait(500)
	CameraAllowChange(true)
	CameraReturnToPlayer()
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	AreaRevertToDefaultPopulation()
end

local function F_NIS_CinBarber()
	AreaTransitionPoint(39, POINTLIST._2_01_CINBARBERSTART)
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	CameraLookAtXYZ(-654.28815, 128.9068, 3.989501, true)
	CameraSetXYZ(-656.28815, 131.4068, 4.989501, -654.28815, 128.9068, 3.989501)
	CameraAllowChange(false)
	PedFollowPath(gPlayer, PATH._2_01_CINBARBPATH, 0, 0, F_CBPlayerEndPath)
	while not bPlayerReachedEnd do
		Wait(0)
	end
	bPlayerReachedEnd = false
	local shopkeep = F_FindClosestPed()
	--print("shopkeep = " .. shopkeep)
	CameraLookAtXYZ(-654.78815, 128.9068, 4.489501, false)
	TextPrint("2_01_BARB1", 4, 2)
	WaitSkippable(4000)
	CameraLookAtXYZ(-652.78815, 128.9068, 4.489501, false)
	TextPrint("2_01_BARB2", 4, 2)
	WaitSkippable(4000)
	CameraLookAtXYZ(-654.78815, 128.9068, 4.489501, false)
	TextPrint("2_01_BARB3", 4, 2)
	WaitSkippable(4000)
	CameraLookAtXYZ(-652.78815, 128.9068, 4.489501, false)
	TextPrint("2_01_BARB4", 4, 2)
	WaitSkippable(4000)
	PedFaceObject(gPlayer, shopkeep, 2, 1)
	PedFaceObject(shopkeep, gPlayer, 2, 1)
	Wait(250)
	PedSetActionNode(shopkeep, "/Global/2_01/Anim/GiveItem/Give", "Act/Conv/2_01.act")
	PedSetActionNode(gPlayer, "/Global/2_01/Anim/GiveItem/Receive", "Act/Conv/2_01.act")
	while PedIsPlaying(gPlayer, "/Global/2_01/Anim/GiveItem", true) do
		Wait(0)
	end
	Wait(500)
	CameraAllowChange(true)
	CameraReturnToPlayer()
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	AreaRevertToDefaultPopulation()
end

local function F_NIS_CinCloth()
	AreaTransitionPoint(34, POINTLIST._2_01_CINCLOTHSTART)
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	CameraLookAtXYZ(-649.44366, 258.90173, 2.4264703, false)
	CameraSetXYZ(-645.44366, 259.90173, 2.9264703, -649.44366, 258.90173, 2.4264703)
	CameraAllowChange(false)
	PedFollowPath(gPlayer, PATH._2_01_CINCLOTHPATH, 0, 0, F_CBPlayerEndPath)
	while not bPlayerReachedEnd do
		Wait(0)
	end
	bPlayerReachedEnd = false
	local shopkeep = F_FindClosestPed()
	--print("shopkeep = " .. shopkeep)
	WaitSkippable(1000)
	CameraLookAtXYZ(-650.4531, 260.8984, 2.4264703, false)
	TextPrint("2_01_CLOTH1", 4, 2)
	WaitSkippable(4000)
	CameraLookAtXYZ(-649.44366, 258.90173, 2.4264703, false)
	TextPrint("2_01_CLOTH2", 4, 2)
	WaitSkippable(4000)
	CameraLookAtXYZ(-650.4531, 260.8984, 2.4264703, false)
	TextPrint("2_01_CLOTH3", 4, 2)
	WaitSkippable(4000)
	TextPrint("2_01_CLOTH4", 4, 2)
	WaitSkippable(4000)
	PedFaceObject(gPlayer, shopkeep, 2, 1)
	PedFaceObject(shopkeep, gPlayer, 2, 1)
	Wait(250)
	PedSetActionNode(shopkeep, "/Global/2_01/Anim/GiveItem/Give", "Act/Conv/2_01.act")
	PedSetActionNode(gPlayer, "/Global/2_01/Anim/GiveItem/Receive", "Act/Conv/2_01.act")
	while PedIsPlaying(gPlayer, "/Global/2_01/Anim/GiveItem", true) do
		Wait(0)
	end
	Wait(500)
	CameraAllowChange(true)
	CameraReturnToPlayer()
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	AreaRevertToDefaultPopulation()
end

local function F_NIS_CinEnding()
	AreaTransitionPoint(2, POINTLIST._2_01_CINENDINGSTART)
	Edna = PedCreatePoint(58, POINTLIST._2_01_EDNAFIN)
	PedSetFlag(Edna, 133, false)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	CameraLookAtObject(Edna, 2, true, 0.6)
	CameraSetPath(PATH._2_01_CAMENDING, true)
	CameraAllowChange(false)
	Wait(500)
	PedFaceObject(Edna, gPlayer, 3, 1)
	PedFaceObject(gPlayer, Edna, 2, 1)
	F_PlaySpeechWait(Edna, 18)
	F_PlaySpeechWait(gPlayer, 19)
	F_PlaySpeechWait(Edna, 20)
	F_PlaySpeechWait(gPlayer, 21)
end

local NISTable = {
	F_NIS_CinGrocery,
	F_NIS_CinBarber,
	F_NIS_CinCloth,
	F_NIS_CinEnding
}

function F_PlaySpeechWait(ped, line, node)
	SoundPlayScriptedSpeechEvent(ped, "M_2_01", line, "SpeechX3")
	if node then
		PedSetActionNode(ped, node, "Act/Conv/2_01.act")
	end
	while SoundSpeechPlaying(ped) do
		Wait(0)
	end
end

function T_NIS_Loop()
	while true do
		if not b_DebuggingNIS and F_IsButtonPressedWithDelayCheck(6, 1) then
			if AreaIsDoorLocked("DT_tbusines_BikeShopDoor") then
				AreaSetDoorLocked("DT_tbusines_BikeShopDoor", false)
				TextPrintString("Unlocking Bikeshopdoor", 4, 1)
			else
				AreaSetDoorLocked("DT_tbusines_BikeShopDoor", true)
				TextPrintString("Locking Bikeshopdoor", 4, 1)
			end
		end
		Wait(0)
	end
end

function F_Clamp(j, total)
	--print("()xxxxx[:::::::::::::::> [start] F_Clamp()")
	--DebugPrint("F_Clamp() j: " .. j .. " total: " .. total)
	if j <= 0 then
		j = total
	else
		if total < j then
			j = 1
		else
		end
	end
	--DebugPrint("F_Clamp() final j: " .. j)
	--print("()xxxxx[:::::::::::::::> [finish] F_Clamp()")
	return j
end

function F_NISSelect()
	--print("()xxxxx[:::::::::::::::> [start] F_NISSelect()")
	if F_IsButtonPressedWithDelayCheck(11, 1) then
		gNIS = gNIS - 1
		gNIS = F_Clamp(gNIS, NISTotal)
		TextPrintString("NIS: " .. gNIS, 3, 1)
	elseif F_IsButtonPressedWithDelayCheck(13, 1) then
		gNIS = gNIS + 1
		gNIS = F_Clamp(gNIS, NISTotal)
		TextPrintString("NIS: " .. gNIS, 3, 1)
	elseif F_IsButtonPressedWithDelayCheck(6, 1) then
		TextPrintString("run NIS", 3, 1)
		F_RunNIS = NISTable[gNIS]
		F_RunNIS()
		TextPrintString("Finished NIS", 4, 1)
		Wait(1000)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_NISSelect()")
end
