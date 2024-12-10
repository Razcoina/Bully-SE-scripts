ImportScript("Library/LibClothing.lua")
rich_firework = nil
DT_general = nil
DT_bike = nil
DT_comics = nil
local isMission201 = false
local gCorona, gMovePoint, gConversation, gConversationNode, gClerk, gFWClerk
local clerk_smoking = false
local current_money
local storeAvailable = true
local gShopping = false
local eX, eY, eZ, eAreacode, eHeading
local gComicNodes = false
local csX, csY, csZ
local gPausedClock = false

function main()
	if shared.playerAggressedInStore then
		shared.playerAggressedInStore = nil
	end
	AreaDisableCameraControlForTransition(true)
	F_RequestWeapons()
	DATLoad("Store.DAT", 0)
	flagState = PedGetFlag(gPlayer, 108)
	PedSetFlag(gPlayer, 108, true)
	local area = AreaTransitionDestination()
	if area == 50 then
		DATLoad("SP_Souvenir.DAT", 0)
		DATLoad("CarnStore.DAT", 0)
	elseif area == 30 then
		DATLoad("SaveLocs.dat", 0)
		DATLoad("SP_Comic_Shop_Rich.dat", 0)
		if IsMissionCompleated("3_R09_N") then
			if IsMissionCompleated("3_B") then
				DATLoad("BDorm_Spud.DAT", 0)
			end
			if IsMissionCompleated("3_R09_N") then
				DATLoad("BDorm_RLauncher.DAT", 0)
			end
			if IsMissionCompleated("2_03") then
				DATLoad("BDorm_Eggs.DAT", 0)
			end
			gComicNodes = true
		else
			gComicNodes = false
			AreaSetNodesSwitchedOffInTrigger(TRIGGER._COMICPOPTRIG, true)
			POISetDisablePedProduction(POI._CNERD1, true)
			POISetDisablePedProduction(POI._CNERD2, true)
			POISetDisablePedProduction(POI._CNERD3, true)
		end
	end
	eX, eY, eZ, eAreacode, eHeading = AreaGetPlayerPositionBeforeStore()
	F_PreStoreSetup(area)
	F_PreDATInit()
	DATInit()
	local Area = AreaGetVisible()
	if Area == 30 and IsMissionCompleated("3_R09_N") then
		PAnimOpenDoor(TRIGGER._FMDOORN01)
		PAnimOpenDoor(TRIGGER._FMDOORN)
		PAnimOpenDoor(TRIGGER._ICOMSHP_BASEMENT)
		PAnimDoorStayOpen(TRIGGER._FMDOORN01)
		PAnimDoorStayOpen(TRIGGER._FMDOORN)
		PAnimDoorStayOpen(TRIGGER._ICOMSHP_BASEMENT)
		AreaSetNodesSwitchedOffInTrigger(TRIGGER._COMICPOPTRIG, false)
	end
	if Area == 50 then
		ShopStart(1)
	else
		ShopStart()
	end
	if MissionActiveSpecific("2_07") and Area == 29 and shared.gCutsceneRunning then
		--print("Don't do anything")
	else
		--print("Perform fade in")
		AreaDisableCameraControlForTransition(false)
		CameraFade(500, 1)
		Wait(501)
	end
	local instore = false
	local x, y, z = GetPointList(gCorona)
	gClerk = ShopGetClerkID()
	Wait(500)
	shared.vendettaClerk = gClerk
	PedLockTarget(gClerk, gPlayer)
	CreateThread("T_StopSpineTracking")
	PedMakeTargetable(gClerk, false)
	ConversationMovePeds(false)
	if Area == 50 then
		SoundPlayScriptedSpeechEvent(gClerk, "GREET", 0, "jumbo")
	else
		SoundPlayScriptedSpeechEvent(gClerk, "STORE_WELCOME", 0, "jumbo")
	end
	F_ToggleArcadeScreens()
	local current_money = 0
	local current_tickets = 0
	local m2g2Active = MissionActiveSpecific("2_G2")
	while not (AreaGetVisible() ~= Area or SystemShouldEndScript()) do
		if m2g2Active then
			if storeAvailable then
				if PlayerHasWeapon(363) then
					storeAvailable = false
				end
			elseif not PlayerHasWeapon(363) then
				storeAvailable = true
			end
		end
		if storeAvailable and F_CheckClock() and not PedInConversation(gPlayer) and PlayerIsInAreaXYZ(x, y, z, 0.5, 9) then
			if gWaitAfterQuit then
				MissionTimerPause(false)
				if Area == 50 then
					if current_tickets <= ItemGetCurrentNum(495) then
						SoundPlayScriptedSpeechEvent(gClerk, "BYE", 0, "jumbo")
					else
						SoundPlayScriptedSpeechEvent(gClerk, "CARNIE_TICKETS_TRADE", 0, "jumbo")
					end
				elseif current_money <= PlayerGetMoney() then
					SoundPlayScriptedSpeechEvent(gClerk, "STORE_BYE_NOBUY", 0, "jumbo")
				else
					SoundPlayScriptedSpeechEvent(gClerk, "STORE_BYE_BUY", 0, "jumbo")
				end
				F_MakePlayerSafeForNIS(false, true)
				Wait(500)
				gWaitAfterQuit = false
				if gPlayerBoughtBear then
					PedSetWeapon(gPlayer, 363, 1)
					gPlayerBoughtBear = nil
				end
				if gCreateMoped then
					TutorialShowMessage("TUT_VESPA", 5000)
				end
			end
			if not gShopping then
				TextPrint("BUT_STORE", 1, 3)
				if IsButtonBeingPressed(9, 0) then
					F_MakePlayerSafeForNIS(true, true)
					MissionTimerPause(true)
					current_money = PlayerGetMoney()
					shared.playerShopping = true
					PedSetFlag(gPlayer, 2, false)
					gShopping = true
					HUDSaveVisibility()
					HUDClearAllElements()
					ToggleHUDComponentLocked(40, true)
					ToggleHUDComponentVisibility(42, true)
					current_money = PlayerGetMoney()
					current_tickets = ItemGetCurrentNum(495)
					ConversationMovePeds(false)
					PedStartConversation(gConversationNode, gConversation, gPlayer, gClerk)
					ConversationMovePeds(false)
					TextPrintString("", 1, 2)
				end
			end
		end
		if Area == 30 then
			if storeAvailable then
				storeAvailable = not IsMissionAvailable("3_R09_N") and not MissionActiveSpecific("3_R09_N")
			elseif not gSkipAggression and IsButtonPressed(9, 0) and PlayerIsInAreaXYZ(csX, csY, csZ, 1, 0) then
				F_MakePlayerSafeForNIS(true)
				gSkipAggression = true
			elseif gSkipAggression then
				if not PlayerIsInAreaXYZ(csX, csY, csZ, 1, 0) then
					F_MakePlayerSafeForNIS(false)
				end
				gSkipAggression = false
			end
		end
		if not gSkipAggression then
			F_Aggression(gClerk)
		end
		if gFinishedShopping then
			--print("Exiting finished shopping")
			PlayerFaceHeadingNow(0)
			CameraReturnToPlayer()
			CameraReset()
			Wait(500)
			AreaTransitionPoint(0, POINTLIST._CARNSTOREEXIT)
			Wait(1000)
			CameraFade(500, 1)
		end
		if (gClothingUnlocked or shared.unlockedClothing) and not shared.lockClothingManager then
			if not cx then
				cx, cy, cz = GetPointList(POINTLIST._CM_CORONA)
			end
			if not gClothing and F_CheckPedNotInGrapple(gPlayer) and PlayerIsInAreaXYZ(cx, cy, cz, 1, 6) then
				TextPrint("BUT_CLOTH", 1, 3)
				if IsButtonBeingPressed(9, 0) then
					L_ClothingSetup(gClothingHeading, CbFinishClothing)
					gClothing = true
				end
			end
		end
		if Area == 30 then
			if not gPunishmentOff and (PlayerIsInTrigger(TRIGGER._NERDSMALLROOM) or PlayerIsInTrigger(TRIGGER._NERDMAINROOM) or PlayerIsInTrigger(TRIGGER._NERDCOMPUTERROOM)) then
				DisablePunishmentSystem(true)
				gPunishmentOff = true
			elseif gPunishmentOff and PlayerIsInTrigger(TRIGGER._COMICSHOP) then
				DisablePunishmentSystem(false)
				gPunishmentOff = false
			end
			if gComicNodes == false and IsMissionCompleated("3_R09_N") then
				gComicNodes = true
				AreaSetNodesSwitchedOffInTrigger(TRIGGER._COMICPOPTRIG, false)
				POISetDisablePedProduction(POI._CNERD1, false)
				POISetDisablePedProduction(POI._CNERD2, false)
				POISetDisablePedProduction(POI._CNERD3, false)
				PAnimOpenDoor(TRIGGER._FMDOORN01)
				PAnimOpenDoor(TRIGGER._FMDOORN)
				PAnimOpenDoor(TRIGGER._ICOMSHP_BASEMENT)
				PAnimDoorStayOpen(TRIGGER._FMDOORN01)
				PAnimDoorStayOpen(TRIGGER._FMDOORN)
				PAnimDoorStayOpen(TRIGGER._ICOMSHP_BASEMENT)
			end
		end
		Wait(0)
	end
	DisablePunishmentSystem(false)
	F_MakePlayerSafeForNIS(false, true)
	AreaClearDockers()
	AreaClearSpawners()
	AreaSetPopulationSexGeneration(true, true)
	ShopEnd()
	shared.minigameRunning = nil
	shared.finishedLoadingShop = nil
	shared.unlockedClothing = nil
	PedStop(gPlayer)
	if gPlayerBrokeStuff then
		PlayerSetControl(1)
	end
	PedSetFlag(gPlayer, 108, flagState)
	DATUnload(0)
	collectgarbage()
end

function CbNoMoney()
	SoundPlayScriptedSpeechEvent(gClerk, "CARNIE_TICKETS_NOT_ENOUGH", 0, "jumbo")
end

function CbFinishClothing()
	gClothing = false
end

function F_SetupDockers()
	local DTStoreSpawner = AreaAddAmbientSpawner(1, 1, 2000, 5000)
	DTStoreDocker = AreaAddDocker(1, 1)
	AreaAddSpawnLocation(DTStoreSpawner, gDockingPoint, gDockingDoor)
	AreaAddDockLocation(DTStoreDocker, gDockingPoint, gDockingDoor)
	AreaAddAmbientSpawnPeriod(DTStoreSpawner, 7, 0, 720)
	AreaAddDockPeriod(DTStoreDocker, 7, 0, 720)
	DockerSetMinimumRange(DTStoreDocker, 1)
	DockerSetMaximumRange(DTStoreDocker, 10)
	DockerSetUseFacingCheck(DTStoreDocker, false)
end

function DTGeneralStoreLoad()
	--print(" $$$$$$$$$ LOADING GENERAL STORE ")
	DATLoad("SP_GroceryStore.dat", 0)
	LoadAnimationGroup("NPC_Adult")
	LoadActionTree("Act/Conv/DTGeneral.act")
	LoadModels({
		502,
		490,
		321,
		316,
		528,
		312,
		156,
		89,
		478,
		475,
		528
	})
	tX = math.pow(eX - 494.028, 2)
	tY = math.pow(eY + 278.867, 2)
	tZ = math.pow(eZ - 2.34481, 2)
	tTotal = tX + tY + tZ
	if tTotal < 9 then
		ShopSetShopKeepInfo(156, POINTLIST._STORE_DT_GENERAL_CLERK)
		gInPoorArea = true
	else
		ShopSetShopKeepInfo(89, POINTLIST._STORE_DT_GENERAL_CLERK)
	end
	ShopAddItem(0, 478, POINTLIST._STORE_DT_GENERAL_ITEM1, 100, 100, CbGroceryStore, 1)
	ShopAddItem(0, 475, POINTLIST._STORE_DT_GENERAL_ITEM2, 100, 100, CbGroceryStore, 1)
	if MiniObjectiveGetIsComplete(1) then
		ShopAddItem(0, 502, POINTLIST._STORE_DT_GENERAL_ITEM3, 100, 0, CbGroceryStore, 1)
	else
		ShopAddItem(0, 502, POINTLIST._STORE_DT_GENERAL_ITEM3, 100, 100, CbGroceryStore, 1)
	end
	ShopAddItem(0, 312, POINTLIST._STORE_DT_GENERAL_ITEM4, 100, 150, CbGroceryStore, 12)
	if IsMissionCompleated("3_S10") or shared.bSprayUnlocked then
		ShopAddItem(0, 321, POINTLIST._STORE_DT_GENERAL_ITEM6, 100, 100, CbGroceryStore, 12)
	end
	if IsMissionCompleated("4_02") then
		ShopAddItem(0, 316, POINTLIST._STORE_DT_GENERAL_ITEM7, 100, 300, CbGroceryStore, 10)
	end
	ShopSetCameraPos(POINTLIST._STORE_DT_GENERAL_CAMERA)
	ShopSetCameraAngleOffset(8)
	ShopSetCameraZoomPercentage(0.5)
	ShopSetPlayerPos(POINTLIST._STORE_DT_GENERAL_CUSTOMER)
	ConversationMovePeds(false)
	ShopSetConversationTree("Act/Conv/DTGeneral.act", "DTGeneral", "Cancel", "Purchase", "Broke", "NoRoom", "Browse", "Stock")
	gConversation = "Act/Conv/DTGeneral.act"
	gConversationNode = "DTGeneral"
	gCorona = POINTLIST._STORE_DT_GENERAL_CORONA
	gMovePoint = POINTLIST._STORE_DT_GENERAL_CUSTOMER
	gDockingDoor = TRIGGER._DT_IGROCERY_DOOR
	gDockingPoint = POINTLIST._STORE_DT_GENERALDOORPOINT
	F_SetupDockers()
	exitX, exitY = -572.074, 384.244
	gDoorTrigger = TRIGGER._DT_IGROCERY_DOOR
	gExitPoint = POINTLIST._STORE_DT_GENERALEXITPOINT
	gCameraPath = PATH._STORE_DT_GENERALEXITPATH
	gAreaTrigger = TRIGGER._STORE_DT_GENERALAREA
	PedClearHasAggressed(gPlayer)
	if gInPoorArea and shared.g4S12Perfume then
		shared.g4S12Perfume = PickupCreateXYZ(490, -571.228, 390.646, 0.0667577, "PermanentMission")
	end
	--print(" $$$$$$$$$ FINISHED LOADING GENERAL STORE ")
end

function DTRichComicStoreLoad()
	--print(" $$$$$$$$$ LOADING RICH COMIC STORE ")
	csX, csY, csZ = GetPointList(POINTLIST._3_R09_N)
	LoadAnimationGroup("NPC_Adult")
	LoadActionTree("Act/Conv/DTComics.act")
	LoadModels({
		84,
		394,
		MODELENUM._BIKERMAG,
		474,
		517
	})
	ShopSetShopKeepInfo(84, POINTLIST._STORE_DT_COMIC_CLERK)
	ShopAddItem(0, 394, POINTLIST._STORE_DT_COMIC_ITEM1, 100, 400, CbComicRich, 5)
	ShopAddItem(0, 309, POINTLIST._STORE_DT_COMIC_ITEM3, 100, 400, CbComicRich, 5)
	ShopAddItem(0, 349, POINTLIST._STORE_DT_COMIC_ITEM7, 30, 300, CbComicRich, 5)
	ShopSetCameraPos(POINTLIST._STORE_DT_COMIC_CAMERA)
	ShopSetCameraAngleOffset(8)
	ShopSetCameraZoomPercentage(0.5)
	ShopSetPlayerPos(POINTLIST._STORE_DT_COMIC_CUSTOMER)
	ConversationMovePeds(false)
	ShopSetConversationTree("Act/Conv/DTComics.act", "DTComics", "Cancel", "Purchase", "Broke", "NoRoom", "Browse", "Stock")
	gConversation = "Act/Conv/DTComics.act"
	gConversationNode = "DTComics"
	gCorona = POINTLIST._STORE_DT_COMIC_CORONA
	gMovePoint = POINTLIST._STORE_DT_COMIC_CUSTOMER
	gDockingDoor = TRIGGER._DT_ICOMSHP_DOOR
	gDockingPoint = POINTLIST._STORE_DT_COMICENTRANCE
	F_SetupDockers()
	exitX, exitY = -647.832, 387.51
	gDoorTrigger = TRIGGER._DT_ICOMSHP_DOOR
	gExitPoint = POINTLIST._STORE_DT_COMICEXITPOINT
	gCameraPath = PATH._STORE_DT_COMICEXITPATH
	gAreaTrigger = TRIGGER._STORE_DT_COMICAREA
	PedClearHasAggressed(gPlayer)
	shared.finishedLoadingShop = true
	--print(" $$$$$$$$$ FINISHED LOADING RICH COMIC STORE ")
end

function DTBikeStoreLoad()
	DATLoad("SP_Bike_Shop.DAT", 0)
	LoadActionTree("Act/Conv/DTComics.act")
	LoadAnimationGroup("NPC_Adult")
	LoadModels({
		86,
		282,
		280,
		273,
		277,
		272,
		278
	})
	tX = math.pow(eX - 480.714, 2)
	tY = math.pow(eY + 78.2597, 2)
	tZ = math.pow(eZ - 5.58482, 2)
	tTotal = tX + tY + tZ
	if tTotal < 9 then
		--print("Now the spawn element is  1 -- FOR BUSINESS AREA STORE")
		gBikeSpawnElement = 1
	else
		gBikeSpawnElement = 2
	end
	gBikesPurchased = 0
	gBikesToSpawn = {}
	--print(" $$$$$$$$$ LOADING RICH BIKE STORE ")
	ShopSetShopKeepInfo(86, POINTLIST._STORE_DT_BIKE_CLERK)
	ShopAddItem(0, 280, POINTLIST._STORE_BIKE_ITEM1, 1, 3500, CbBikeRich, 1)
	ShopAddItem(0, 282, POINTLIST._STORE_BIKE_ITEM3, 1, 1500, CbBikeRich, 1)
	ShopAddItem(0, 283, POINTLIST._STORE_BIKE_ITEM5, 1, 2500, CbBikeRich, 1)
	ShopSetCameraPos(POINTLIST._STORE_BIKE_CAMERA)
	ShopSetCameraAngleOffset(15)
	ShopSetCameraZoomPercentage(0)
	ShopSetPlayerPos(POINTLIST._STORE_DT_BIKE_CUSTOMER)
	ConversationMovePeds(false)
	ShopSetConversationTree("Act/Conv/DTComics.act", "DTComics", "Cancel", "Purchase", "Broke", "NoRoom", "Browse", "Stock")
	gConversation = "Act/Conv/DTComics.act"
	gConversationNode = "DTComics"
	gCorona = POINTLIST._STORE_DT_BIKE_CUSTOMER
	gMovePoint = POINTLIST._STORE_DT_BIKE_CUSTOMER
	gDockingDoor = TRIGGER._DT_IBKSHOP_DOOR
	gDockingPoint = POINTLIST._STORE_DT_EXITBIKEPOINT
	F_SetupDockers()
	exitX, exitY = -785.666, 374.928
	gDoorTrigger = TRIGGER._DT_IBKSHOP_DOOR
	gExitPoint = POINTLIST._STORE_DT_EXITBIKEPOINT
	gCameraPath = PATH._STORE_DT_BIKEEXITPATH
	gAreaTrigger = TRIGGER._STORE_DT_BIKEAREA
	PedClearHasAggressed(gPlayer)
	shared.finishedLoadingShop = true
	--print(" $$$$$$$$$ FINISHED LOADING RICH BIKE STORE ")
end

function CarnStoreLoad()
	LoadActionTree("Act/Conv/DTCarnie.act")
	LoadModels({
		124,
		469,
		468,
		512,
		472,
		465,
		473,
		466,
		473,
		511,
		464,
		513,
		471,
		363,
		470
	})
	LoadAnimationGroup("NPC_Adult")
	if MissionActiveSpecific("2_G2") then
		ShopAddItem(0, 363, POINTLIST._STORECARN_ITEM01, -1, 10, CbCarnieStore, 1)
	end
	if not ClothingPlayerOwns("C_DevilHorns", 0) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 470, POINTLIST._STORECARN_ITEM04, 0, 15, CbCarnieStore, 1)
		else
			ShopAddItem(0, 470, POINTLIST._STORECARN_ITEM04, 1, 15, CbCarnieStore, 1)
		end
	end
	if PlayerGetScriptSavedData(11) == 0 then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 513, POINTLIST._STORECARN_ITEM11, 0, 10, CbCarnieStore, 1)
		else
			ShopAddItem(0, 513, POINTLIST._STORECARN_ITEM11, 1, 10, CbCarnieStore, 1)
		end
	end
	if not ClothingPlayerOwns("C_StrangeHat", 0) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 471, POINTLIST._STORECARN_ITEM03, 0, 40, CbCarnieStore, 1)
		else
			ShopAddItem(0, 471, POINTLIST._STORECARN_ITEM03, 1, 40, CbCarnieStore, 1)
		end
	end
	if not ClothingPlayerOwns("C_ClownPants", 4) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 464, POINTLIST._STORECARN_ITEM09, 0, 40, CbCarnieStore, 1)
		else
			ShopAddItem(0, 464, POINTLIST._STORECARN_ITEM09, 1, 40, CbCarnieStore, 1)
		end
	end
	if PlayerGetScriptSavedData(13) == 0 then
		vespaPrice = 75
	else
		vespaPrice = 0
	end
	if MissionActiveSpecific("2_G2") then
		ShopAddItem(0, 276, POINTLIST._STORECARN_ITEM14, 0, vespaPrice, CbCarnieStore, 1)
	else
		ShopAddItem(0, 276, POINTLIST._STORECARN_ITEM14, 1, vespaPrice, CbCarnieStore, 1)
	end
	if not ClothingPlayerOwns("C_ClownShoes", 5) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 465, POINTLIST._STORECARN_ITEM10, 0, 40, CbCarnieStore, 1)
		else
			ShopAddItem(0, 465, POINTLIST._STORECARN_ITEM10, 1, 40, CbCarnieStore, 1)
		end
	end
	if not ClothingPlayerOwns("C_StpdShrt", 1) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 466, POINTLIST._STORECARN_ITEM08, 0, 20, CbCarnieStore, 1)
		else
			ShopAddItem(0, 466, POINTLIST._STORECARN_ITEM08, 1, 20, CbCarnieStore, 1)
		end
	end
	if not ClothingPlayerOwns("C_PinkWatch", 2) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 473, POINTLIST._STORECARN_ITEM05, 0, 10, CbCarnieStore, 1)
		else
			ShopAddItem(0, 473, POINTLIST._STORECARN_ITEM05, 1, 10, CbCarnieStore, 1)
		end
	end
	if not ClothingPlayerOwns("C_ClownWig", 0) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 472, POINTLIST._STORECARN_ITEM02, 0, 40, CbCarnieStore, 1)
		else
			ShopAddItem(0, 472, POINTLIST._STORECARN_ITEM02, 1, 40, CbCarnieStore, 1)
		end
	end
	if PlayerGetScriptSavedData(12) == 0 then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 512, POINTLIST._STORECARN_ITEM06, 0, 10, CbCarnieStore, 1)
		else
			ShopAddItem(0, 512, POINTLIST._STORECARN_ITEM06, 1, 10, CbCarnieStore, 1)
		end
	end
	if not ClothingPlayerOwns("C_BBracelets", 3) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 468, POINTLIST._STORECARN_ITEM07, 0, 15, CbCarnieStore, 1)
		else
			ShopAddItem(0, 468, POINTLIST._STORECARN_ITEM07, 1, 15, CbCarnieStore, 1)
		end
	end
	if not ClothingPlayerOwns("C_CanadaHat", 0) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 467, POINTLIST._STORECARN_ITEM13, 0, 20, CbCarnieStore, 1)
		else
			ShopAddItem(0, 467, POINTLIST._STORECARN_ITEM13, 1, 20, CbCarnieStore, 1)
		end
	end
	if not ClothingPlayerOwns("C_AngelHalo", 0) then
		if MissionActiveSpecific("2_G2") then
			ShopAddItem(0, 469, POINTLIST._STORECARN_ITEM12, 0, 15, CbCarnieStore, 1)
		else
			ShopAddItem(0, 469, POINTLIST._STORECARN_ITEM12, 1, 15, CbCarnieStore, 1)
		end
	end
	ShopSetShopKeepInfo(114, POINTLIST._STORECARN_CLERK)
	ShopSetCameraPos(POINTLIST._STORECARN_CAMERA)
	ShopSetCameraAngleOffset(11)
	ShopSetCameraZoomPercentage(0.4)
	ShopSetPlayerPos(POINTLIST._STORECARN_PLAYERPOSITION)
	ShopSetConversationTree("Act/Conv/DTCarnie.act", "DTCarnie", "Cancel", "Purchase", "Broke", "NoRoom", "Browse", "Stock")
	gConversation = "Act/Conv/DTCarnie.act"
	gConversationNode = "DTCarnie"
	gMovePoint = POINTLIST._STORECARN_PLAYERPOSITION
	gCorona = POINTLIST._STORECARN_CORONA
	gAreaTrigger = TRIGGER._STORECARN_AREA
	PedClearHasAggressed(gPlayer)
end

function F_Aggression(clerk)
	if not shared.g3_R09_N and not gPlayerBrokeStuff and (PAnimNumDestroyed(gAreaTrigger) > 0 or PedHasAggressed(gPlayer)) then
		PlayerSetControl(0)
		shared.playerAggressedInStore = true
		AreaCancelStoredTransition()
		SoundStopCurrentSpeechEvent(clerk)
		PedIgnoreStimuli(clerk, true)
		PedFaceObject(clerk, gPlayer, 3, 1)
		CameraSetWidescreen(true)
		Wait(500)
		SoundSetAudioFocusCamera()
		F_PedSetCameraOffsetXYZ(clerk, 0.07666, 2.155277, 1.798232, 0.028458, 1.16996, 1.64126)
		CameraAllowChange(false)
		PedSetActionNode(clerk, "/Global/Welcome/ShakeFist", "Act/Conv/Store.act")
		F_PlaySpeechAndWait(clerk, "STORE_VIOLENCE_RESPONSE", 0, "supersize")
		CameraFade(500, 0)
		Wait(500)
		CameraAllowChange(true)
		SoundSetAudioFocusPlayer()
		CameraReturnToPlayer()
		CameraReset()
		CameraSetWidescreen(false)
		shared.storeTransition = {
			eAreacode,
			eX,
			eY,
			eZ
		}
		LaunchScript("AreaScripts/StoreTransition.lua")
		Wait(100)
		gPlayerBrokeStuff = true
		PedClearHasAggressed(gPlayer)
	end
end

function CbGroceryStore(modelID)
	--DebugPrint("OnBuyCB: Model: " .. modelID)
	if modelID == 502 then
		GiveItemToPlayer(502, 1)
		ItemSetCurrentNum(502, 0)
		local playerHealth = PlayerGetHealth()
		local playerMax = PedGetMaxHealth(gPlayer)
		playerHealth = playerHealth + 75
		if playerMax <= playerHealth then
			PlayerSetHealth(playerMax)
		else
			PlayerSetHealth(playerHealth)
		end
	elseif modelID == 312 then
		GiveAmmoToPlayer(312, 12)
	elseif modelID == 321 then
		GiveWeaponToPlayer(321)
		GiveAmmoToPlayer(321, 12)
	elseif modelID == 316 then
		GiveAmmoToPlayer(316, 10)
	elseif modelID == 528 then
		GiveItemToPlayer(528)
	elseif modelID == 475 then
		GiveItemToPlayer(475)
	elseif modelID == 478 then
		GiveItemToPlayer(478)
	end
end

function CbBikeRich(modelID)
	GarageSetStoredVehicle(1, modelID)
	if not IsMissionCompleated("BIKEPARK4X") and not MissionActiveSpecific("BIKEPARK4X") then
		TutorialStart("BIKEPARK4X")
	end
end

function CbComicRich(modelID)
	if modelID == 394 then
		PlayerSetWeapon(394, 5)
	elseif modelID == 349 then
		PlayerSetWeapon(349, 5)
	elseif modelID == 309 then
		PlayerSetWeapon(309, 5)
	end
end

function CbCarnieStore(modelID)
	if modelID == 512 then
		PlayerSetScriptSavedData(12, 1)
	elseif modelID == 513 then
		PlayerSetScriptSavedData(11, 1)
	elseif modelID == 472 then
		ClothingGivePlayer("C_ClownWig", 0)
		StatAddToInt(66)
	elseif modelID == 470 then
		ClothingGivePlayer("C_DevilHorns", 0)
		StatAddToInt(66)
	elseif modelID == 464 then
		ClothingGivePlayer("C_ClownPants", 4)
		StatAddToInt(66)
	elseif modelID == 465 then
		ClothingGivePlayer("C_ClownShoes", 5)
		StatAddToInt(66)
	elseif modelID == 469 then
		ClothingGivePlayer("C_AngelHalo", 0)
		StatAddToInt(66)
	elseif modelID == 471 then
		ClothingGivePlayer("C_StrangeHat", 0)
		StatAddToInt(66)
	elseif modelID == 473 then
		ClothingGivePlayer("C_PinkWatch", 2)
		StatAddToInt(66)
	elseif modelID == 468 then
		ClothingGivePlayer("C_BBracelets", 3)
		StatAddToInt(66)
	elseif modelID == 466 then
		ClothingGivePlayer("C_StpdShrt", 1)
		StatAddToInt(66)
	elseif modelID == 467 then
		ClothingGivePlayer("C_CanadaHat", 0)
		StatAddToInt(66)
	elseif modelID == 276 then
		PlayerSetScriptSavedData(13, 1)
		GarageSetStoredVehicle(1, 276)
		if not IsMissionCompleated("TRESPASSX") and not MissionActiveSpecific("TRESPASSX") then
			TutorialStart("TRESPASSX")
		end
	elseif modelID == 363 then
		gPlayerBoughtBear = true
	end
end

function CbCarnieStopShopping()
	gFinishedShopping = true
	CameraFade(500, 0)
end

function Cb201StopShopping()
	if isMission201 and PlayerHasItem(528) then
		shared.g2_01 = false
		isMission201 = false
	end
end

function F_StopTimeWhilePurchasing()
	if IsMissionCompleated("1_02C") and not MissionActive() and not ClockIsPaused() then
		PauseGameClock()
		gPausedClock = true
	end
end

function F_StartUpTime()
	HUDRestoreVisibility()
	ToggleHUDComponentLocked(40, false)
	if IsMissionCompleated("1_02C") and not MissionActive() and gPausedClock then
		UnpauseGameClock()
	end
	gShopping = false
	shared.playerShopping = false
	gWaitAfterQuit = true
end

function F_RequestWeapons()
	WeaponRequestModel(309)
	WeaponRequestModel(308)
	WeaponRequestModel(397)
	WeaponRequestModel(312)
	WeaponRequestModel(316)
	WeaponRequestModel(321)
	WeaponRequestModel(394)
	WeaponRequestModel(393)
	WeaponRequestModel(528)
	WeaponRequestModel(517)
	WeaponRequestModel(349)
end

function F_PreStoreSetup(Area)
	LoadActionTree("Act/Conv/Store.act")
	if Area == 26 then
		if eAreacode == -1 then
			eX, eY, eZ = GetPointList(POINTLIST._DT_IGROCERY_DOOR)
			eAreacode, eHeading = 0, 0
		end
		if shared.g2_01 then
			isMission201 = true
		end
		DTGeneralStoreLoad()
		if shared.g2_03 then
		end
	elseif Area == 30 then
		eX, eY, eZ = GetPointList(POINTLIST._DT_ICOMSHP_DOOR)
		eAreacode, eHeading = 0, 0
		if IsMissionCompleated("3_R09_N") or shared.unlockedClothing then
			gClothingUnlocked = true
		end
		storeAvailable = not IsMissionAvailable("3_R09_N") and not MissionActiveSpecific("3_R09_N")
		gClothingHeading = 130
		DTRichComicStoreLoad()
	elseif Area == 29 then
		if eAreacode == -1 then
			eX, eY, eZ = GetPointList(POINTLIST._DT_IBKSHOP_DOOR)
			eAreacode, eHeading = 0, 0
		end
		DTBikeStoreLoad()
	elseif Area == 50 then
		eX, eY, eZ = 183.51755, 436.8038, 5.558654
		eAreacode, eHeading = 0, 0
		CarnStoreLoad()
	end
end

function F_CheckClock()
	hour, minute = ClockGet()
	if hour == 1 and minute > 55 or hour == 2 or PlayerFellAsleep() or AreaIsLoading() then
		return false
	end
	return true
end

function T_StopSpineTracking()
	Wait(5000)
	PedLockTarget(gClerk, -1)
end
