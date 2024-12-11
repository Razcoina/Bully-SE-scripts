--[[ Changes to this file:
	* Modified function F_ShopLoop, may require testing
]]

local gPlayerBrokeStuff = false
local eX, eY, eZ, eAreacode, eHeading, cx, cy, cz, gClerk
local gPlayerInArea = false
local gEntranceDoorTrigger, gCoronaPointlist, gStoreOwnerModel, gStoreOwnerPoint, gDestroyAreaTrigger, gPlayerPositionInStore, gShoppingString, gShoppingCam, gHudComponent, gCamOffsetX, gCamOffsetY, gAddItems
local gInsidePopulation = true
local gCurrentCam = 0
local gCurrentCamNo = 0
local gLookAtPoint = -1
local gCanZoom = false
local gCoronaType = 6
local gCurrentSpecialStore = 0
local gTryingTime = 0
local gChangeAnimTime = 10000
local gChangingAnimNode
local gPlayerHeading = 90
local gPausedClock = false

function main()
	local gArea = AreaTransitionDestination()
	AreaClearAllPeds()
	LoadAnimationGroup("NPC_Adult")
	PedClearHasAggressed(gPlayer)
	shared.gAreaDATFileLoaded[gArea] = true
	shared.gAreaDataLoaded = true
	flagState = PedGetFlag(gPlayer, 108)
	PedSetFlag(gPlayer, 108, true)
	LoadAnimationGroup("Try_Clothes")
	LoadActionTree("Act/Conv/Store.act")
	if gArea == 33 then
		DATLoad("icloth_r.DAT", 0)
		DATLoad("SP_Rich_Cloth.DAT", 0)
		F_RichClothingSetup()
		cx, cy, cz = GetPointList(gCoronaPointlist)
		gClerk = PedCreatePoint(gStoreOwnerModel, gStoreOwnerPoint)
		shared.vendettaClerk = gClerk
		F_PreDATInit()
		DATInit()
	elseif gArea == 34 then
		DATLoad("icloth_p.DAT", 0)
		DATLoad("SP_Poor_Cloth.DAT", 0)
		F_PoorClothingSetup()
		cx, cy, cz = GetPointList(gCoronaPointlist)
		gClerk = PedCreatePoint(gStoreOwnerModel, gStoreOwnerPoint)
		shared.vendettaClerk = gClerk
		F_PreDATInit()
		DATInit()
	elseif gArea == 39 then
		DATLoad("ibarber.DAT", 0)
		DATLoad("SP_Barber.DAT", 0)
		F_BarberSetup()
		cx, cy, cz = GetPointList(gCoronaPointlist)
		gClerk = PedCreatePoint(gStoreOwnerModel, gStoreOwnerPoint)
		shared.vendettaClerk = gClerk
		F_PreDATInit()
		DATInit()
	elseif gArea == 46 then
		DATLoad("ibarber.DAT", 0)
		DATLoad("SP_Hair_Salon.DAT", 0)
		F_HairSalonSetup()
		cx, cy, cz = GetPointList(gCoronaPointlist)
		gClerk = PedCreatePoint(gStoreOwnerModel, gStoreOwnerPoint)
		shared.vendettaClerk = gClerk
		F_PreDATInit()
		DATInit()
		F_HairSalonSetup()
	elseif gArea == 56 then
		DATLoad("ibarber.DAT", 0)
		DATLoad("eventsPoorHair.DAT", 0)
		DATLoad("SP_Poor_Hair.DAT", 0)
		F_PoorBarberMainSetup()
		cx, cy, cz = GetPointList(gCoronaPointlist)
		gClerk = PedCreatePoint(gStoreOwnerModel, gStoreOwnerPoint)
		shared.vendettaClerk = gClerk
		F_PreDATInit()
		DATInit()
	end
	SoundFadeWithCamera(false)
	eX, eY, eZ, eAreacode, eHeading = AreaGetPlayerPositionBeforeStore()
	--print("[RAUL] ", eX, eY, eZ, eAreacode)
	if eAreacode == -1 or eAreacode == 0 then
		eX, eY, eZ = GetPointList(gEntranceDoorTrigger)
		eAreacode, eHeading = 0, 0
		--print("[RAUL] ", eX, eY, eZ, eAreacode)
	end
	PedFaceObject(gClerk, gPlayer, 3, 0)
	PedLockTarget(gClerk, gPlayer)
	CreateThread("T_StopSpineTracking")
	PedMakeTargetable(gClerk, false)
	if b2_03Speech then
		SoundPlayScriptedSpeechEvent(gClerk, "M_2_03", 6, "jumbo")
	else
		SoundPlayScriptedSpeechEvent(gClerk, "STORE_WELCOME", 0, "jumbo")
	end
	if gInsidePopulation then
		local DTStoreSpawner = AreaAddAmbientSpawner(1, 1, 2000, 5000)
		DTStoreDocker = AreaAddDocker(1, 1)
		AreaAddSpawnLocation(DTStoreSpawner, gDockingPoint, gDockingDoor)
		AreaAddDockLocation(DTStoreDocker, gDockingPoint, gDockingDoor)
		AreaAddAmbientSpawnPeriod(DTStoreSpawner, 7, 20, 720)
		AreaAddDockPeriod(DTStoreDocker, 7, 20, 720)
		DockerSetMinimumRange(DTStoreDocker, 1)
		DockerSetMaximumRange(DTStoreDocker, 10)
		DockerSetUseFacingCheck(DTStoreDocker, false)
	end
	while not (AreaGetVisible() ~= gArea or SystemShouldEndScript()) do
		F_Aggression(gClerk)
		F_ShopLoop()
		Wait(0)
	end
	DATUnload(0)
	UnLoadAnimationGroup("NPC_Adult")
	UnLoadAnimationGroup("Try_Clothes")
	SoundFadeWithCamera(true)
	PedSetFlag(gPlayer, 108, flagState)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[gArea] = false
	collectgarbage()
end

function F_Aggression(clerk)
	if not gPlayerBrokeStuff and (PAnimNumDestroyed(gDestroyAreaTrigger) > 0 or PedHasAggressed(gPlayer)) then
		AreaCancelStoredTransition()
		PedIgnoreStimuli(clerk, true)
		PedFaceObject(clerk, gPlayer, 3, 1)
		Wait(500)
		PedSetActionNode(clerk, "/Global/Welcome/ShakeFist", "Act/Conv/Store.act")
		SoundSetAudioFocusCamera()
		CameraSetWidescreen(true)
		F_PedSetCameraOffsetXYZ(clerk, 0.07666, 2.155277, 1.798232, 0.028458, 1.16996, 1.64126)
		CameraAllowChange(false)
		SoundPlayScriptedSpeechEvent(gClerk, "STORE_VIOLENCE_RESPONSE", 0, "jumbo")
		PlayerSetControl(0)
		Wait(2000)
		CameraFade(500, 0)
		Wait(500)
		SoundSetAudioFocusPlayer()
		CameraSetWidescreen(false)
		PedDelete(clerk)
		CameraAllowChange(true)
		CameraReset()
		CameraReturnToPlayer()
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

function F_InitShop()
	SoundDisableSpeech_ActionTree()
	gHACKClothesCam = true
	local lx, ly, lz = GetPointList(gPlayerPositionInStore)
	PlayerSetPosSimple(lx, ly, lz)
	PlayerFaceHeadingNow(gPlayerHeading)
	gFloatA = 0.8
	gFloatB = 0.6
end

local hour, minute

function F_ShopLoop() -- ! Modified
	if F_CheckClock() and PlayerIsInAreaXYZ(cx, cy, cz, 1, gCoronaType) then
		gPlayerInArea = true
		if gSpecialStore then
			F_PoorBarberSetup()
		end
	end
	if gSpecialStore and PlayerIsInAreaXYZ(clx, cly, clz, 1, gCoronaTypeA) then
		gPlayerInArea = true
		F_PoorBarberClothingSetup()
	end
	if gPlayerInArea and F_CheckPedNotInGrapple(gPlayer) then
		TextPrint(gShoppingString, 1, 3)
		if IsButtonBeingPressed(9, 0) then
			SoundPlay2D("ButtonUp")
			shared.playerShopping = true
			MissionTimerPause(true)
			PedSetFlag(gPlayer, 2, false)
			PlayerSetControl(0)
			CameraFade(100, 0)
			Wait(100)
			PedSetActionNode(gPlayer, "/Global/Welcome/Idle", "Act/Conv/Store.act")
			current_money = PlayerGetMoney()
			TextPrintString("", 1, 2)
			Wait(400)
			F_MakePlayerSafeForNIS(true, true)
			F_InitShop()
			local buttonPressed = false
			Wait(250)
			local bPlaySpeech = true
			local speechTime = GetTimer() + 1500
			local startingHeading = 5 -- Added this
			local clothingHeading = gPlayerHeading
			Wait(250)
			HUDSaveVisibility()
			HUDClearAllElements()
			ToggleHUDComponentLocked(40, true)
			local camPosX, camPosY, camPosZ = GetPointList(gShoppingCam)
			ToggleHUDComponentVisibility(gHudComponent, true)
			PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/TryingOn", "Act/Anim/Ambient.act")
			ClothingStoreRegisterFeedbackCallback(FeedbackCallback)
			gTryingTime = GetTimer()
			PlayerUnequip()
			if not MissionActive() and not ClockIsPaused() then
				PauseGameClock()
				gPausedClock = true
			end
			gCurrentCam = 0
			gCurrentCamNo = 0
			local size = table.getn(gCameraTransitions)
			if CameraGet169Mode() and gHudComponent == 14 then
				gInWidescreen = true
				lx, ly, lz = GetPointList(gLookAtPoint2)
				CameraSetFOV(75)
			else
				gInWidescreen = false
				lx, ly, lz = GetPointList(gLookAtPoint)
			end
			CameraLookAtXYZ(lx, ly, lz, true)
			CameraSetPath(gCameraTransitions[size].path, true)
			gCurrentCamNo = gCameraTransitions[size].camNo
			gAddItems()
			CameraFade(1000, 1)
			if shared.playerKOd then
				shared.playerKOd = nil
			end
			while not buttonPressed do
				if gInWidescreen and not CameraGet169Mode() then
					lx, ly, lz = GetPointList(gLookAtPoint)
					CameraLookAtXYZ(lx, ly, lz, true)
					CameraDefaultFOV()
					gInWidescreen = false
				elseif not gInWidescreen and CameraGet169Mode() and gHudComponent == 14 then
					lx, ly, lz = GetPointList(gLookAtPoint2)
					CameraSetFOV(75)
					CameraLookAtXYZ(lx, ly, lz, true)
					gInWidescreen = true
				end
				if IsButtonPressed(15, 0) then
					--[[
					clothingHeading = gPlayerHeading
					]]                                    -- Removed this
					startingHeading = startingHeading - 1 -- Added this
					if startingHeading == 0 then -- Added this if chunk
						clothingHeading = gPlayerHeading
						startingHeading = 1
					end
					--[[
				elseif IsButtonPressed(24, 0) then
				]] -- Changed to:
				elseif GetStickValue(18, 0) then
					--[[
					clothingHeading = clothingHeading - 5
					]] -- Changed to:
					startingHeading = 5
					--[[
				elseif IsButtonPressed(25, 0) then
					clothingHeading = clothingHeading + 5
				]] -- Removed this
					clothingHeading = clothingHeading + 5 * GetStickValue(18, 0)
				end
				if 360 < clothingHeading then
					clothingHeading = clothingHeading - 360
				elseif clothingHeading < 0 then
					clothingHeading = clothingHeading + 360
				end
				PlayerFaceHeadingNow(clothingHeading)
				if gCanZoom then
					if not gZoomed then
						if gCurrentCamNo ~= gCameraTransitions[size].camNo then
							CameraSetPath(gCameraTransitions[size].path, false)
							gCurrentCamNo = gCameraTransitions[size].camNo
						end
						if IsButtonPressed(12, 0) then
							local index = gCurrentCam + 1
							gZoomed = true
							if gCurrentCamNo ~= gCameraTransitions[index].camNo then
								CameraSetPath(gCameraTransitions[index].path, false)
								gCurrentCamNo = gCameraTransitions[index].camNo
							end
						end
					elseif gZoomed then
						if not IsButtonPressed(12, 0) then
							local size = table.getn(gCameraTransitions)
							if gCurrentCamNo ~= gCameraTransitions[size].camNo then
								CameraSetPath(gCameraTransitions[size].path, false)
								gCurrentCamNo = gCameraTransitions[size].camNo
							end
							gZoomed = false
						end
						if gCamChanged then
							local index = gCurrentCam + 1
							if gCurrentCamNo ~= gCameraTransitions[index].camNo then
								CameraSetPath(gCameraTransitions[index].path, false)
								gCurrentCamNo = gCameraTransitions[index].camNo
							end
							gCamChanged = false
						end
					end
				end
				if gCamChanged then
					gCamChanged = false
				end
				if gChangingAnimNode and GetTimer() - gTryingTime > gChangeAnimTime then
					PedSetActionNode(gPlayer, gChangingAnimNode, "Act/Anim/Ambient.act")
					gTryingTime = GetTimer()
				end
				if IsButtonBeingPressed(8, 0) or shared.playerKOd then
					SoundPlay2D("ButtonDown")
					CameraFade(1000, 0)
					PlayerSetControl(0)
					Wait(1000)
					F_CleanupShop()
					F_MakePlayerSafeForNIS(false, true)
					if not MissionActive() and gPausedClock then
						UnpauseGameClock()
					end
					Wait(500)
					PlayerSetControl(1)
					CameraDefaultFOV()
					CameraFade(1000, 1)
					buttonPressed = true
					if shared.g2_03_shirt then
						local shirtMI = ObjectNameToHashID("PreppyVest")
						local playerShirtMI = ClothingGetPlayer(1)
						if playerShirtMI == shirtMI then
							shared.g2_03_shirt = false
							TextPrint("CLT_JSHIRT", 3, 2)
							Wait(3000)
						end
					end
					if PlayerGetMoney() >= current_money then
						--print("Didn't buy Anything")
						SoundPlayScriptedSpeechEvent(gClerk, "STORE_BYE_NOBUY", 0, "jumbo")
					else
						SoundPlayScriptedSpeechEvent(gClerk, "STORE_BYE_BUY", 0, "jumbo")
						--print("Buy Something")
					end
					MissionTimerPause(false)
				end
				Wait(0)
			end
		end
	end
	shared.playerShopping = false
	gPlayerInArea = false
end

function F_CleanupShop()
	SoundEnableSpeech_ActionTree()
	ToggleHUDComponentVisibility(gHudComponent, false)
	PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/Finished", "Act/Anim/Ambient.act")
	CameraSetActive(1)
	ToggleHUDComponentLocked(40, false)
	HUDRestoreVisibility()
	--print("[RAUL]", gCoronaPointlist)
	if shared.playerKOd then
		shared.playerKOd = nil
	else
		local x, y, z = GetPointList(gCoronaPointlist)
		PlayerSetPosSimple(x, y, z)
	end
	gHACKClothesCam = false
end

function FeedbackCallback(storeFeedbackType, relatedData)
	--print("*** SAJ *** FEEDBACK CALLBACK", storeFeedbackType, relatedData)
	if storeFeedbackType == 0 and gCurrentCam ~= relatedData then
		gCurrentCam = relatedData
		gCamChanged = true
	end
end

function F_PoorClothingSetup()
	gEntranceDoorTrigger = POINTLIST._DT_ICLOTHP_DOORL
	gCoronaPointlist = POINTLIST._PCLTH_START
	gStoreOwnerModel = 105
	gStoreOwnerPoint = POINTLIST._PCLTH_CLERKSTART
	gDockingPoint = POINTLIST._PCLTH_DOORSPAWN
	gDockingDoor = TRIGGER._DT_ICLOTHP_DOORL
	gDestroyAreaTrigger = TRIGGER._ICLOTH_P_TRIGGER
	gPlayerPositionInStore = POINTLIST._PCLTH_PLAYERSTART
	gShoppingString = "BUT_CLOTHSTR"
	gShoppingCam = POINTLIST._PCLTH_CAM
	gHudComponent = 14
	gCamOffsetX, gCamOffsetY = 0.87, 0.9
	gAddItems = F_PoorClothes
	gPlayerHeading = 260
	gCanZoom = true
	gLookAtPoint = POINTLIST._PCLTH_LOOKAT
	gLookAtPoint2 = POINTLIST._PCLTH_LOOKAT2
	gCameraTransitions = {
		{
			path = PATH._PCLTH_CAMPATH02,
			camNo = 0
		},
		{
			path = PATH._PCLTH_CAMPATH03,
			camNo = 1
		},
		{
			path = PATH._PCLTH_CAMPATH04,
			camNo = 2
		},
		{
			path = PATH._PCLTH_CAMPATH04,
			camNo = 2
		},
		{
			path = PATH._PCLTH_CAMPATH05,
			camNo = 3
		},
		{
			path = PATH._PCLTH_CAMPATH06,
			camNo = 4
		},
		{
			path = PATH._PCLTH_CAMPATH01,
			camNo = 5
		},
		{
			path = PATH._PCLTH_CAMPATH01,
			camNo = 5
		}
	}
	gChangingAnimNode = "/Global/Ambient/MissionSpec/Clothing/TryClothesAnims"
end

function F_RichClothingSetup()
	gEntranceDoorTrigger = POINTLIST._DT_ICLOTHR_DOORL
	gCoronaPointlist = POINTLIST._RICHSHOPSTART
	gStoreOwnerModel = 104
	gStoreOwnerPoint = POINTLIST._RCLTH_CLERKSTART
	gDockingPoint = POINTLIST._RCLTH_DOORSPAWN
	gDockingDoor = TRIGGER._DT_ICLOTHR_DOORL
	gDestroyAreaTrigger = TRIGGER._RCLTH_TRIGGER
	gPlayerPositionInStore = POINTLIST._RICHSHOPPLAYER
	gShoppingString = "BUT_CLOTHSTR"
	gShoppingCam = POINTLIST._RICHSHOPCAM
	gHudComponent = 14
	gCamOffsetX, gCamOffsetY = 0.87, 0.9
	gAddItems = F_RichClothes
	gPlayerHeading = 270
	gCanZoom = true
	gLookAtPoint = POINTLIST._RCLTH_LOOKAT
	gLookAtPoint2 = POINTLIST._RCLTH_LOOKAT2
	gCameraTransitions = {
		{
			path = PATH._RCLTH_CAMPATH02,
			camNo = 0
		},
		{
			path = PATH._RCLTH_CAMPATH03,
			camNo = 1
		},
		{
			path = PATH._RCLTH_CAMPATH04,
			camNo = 2
		},
		{
			path = PATH._RCLTH_CAMPATH04,
			camNo = 2
		},
		{
			path = PATH._RCLTH_CAMPATH05,
			camNo = 3
		},
		{
			path = PATH._RCLTH_CAMPATH06,
			camNo = 4
		},
		{
			path = PATH._RCLTH_CAMPATH01,
			camNo = 5
		},
		{
			path = PATH._RCLTH_CAMPATH01,
			camNo = 5
		}
	}
	gChangingAnimNode = "/Global/Ambient/MissionSpec/Clothing/TryClothesAnims"
	if not ClothingPlayerOwns("R_Sweater1", 1) then
		b2_03Speech = true
	else
	end
end

function F_BarberSetup()
	gEntranceDoorTrigger = POINTLIST._DT_BARBER_EXIT
	gCoronaPointlist = POINTLIST._BAR_LIST_TRIGGER
	--print("[RAUL]", gCoronaPointlist)
	gStoreOwnerModel = 132
	gStoreOwnerPoint = POINTLIST._BARBER_RBARBER
	gInsidePopulation = false
	gDestroyAreaTrigger = TRIGGER._STORE_BARBER_AREA
	gPlayerPositionInStore = POINTLIST._BAR_LIST_TRIGGER
	gShoppingString = "BUT_HAIR"
	gShoppingCam = POINTLIST._BARBER_RBARBERCUT
	gHudComponent = 18
	gCamOffsetX, gCamOffsetY = 1.55, 0.35
	gAddItems = F_BarberItems
	gCoronaType = 17
	gChangingAnimNode = nil
	gLookAtPoint = POINTLIST._BARBER_LOOKAT
	gPlayerHeading = 348
	gCameraTransitions = {
		{
			path = PATH._BARBER_CAMERA01,
			camNo = 0
		}
	}
end

function F_HairSalonSetup()
	gEntranceDoorTrigger = POINTLIST._DT_SALON_EXIT
	gCoronaPointlist = POINTLIST._HAIRSALON_CORONA
	gStoreOwnerModel = 120
	gStoreOwnerPoint = POINTLIST._HAIRSALON_BARBER01
	gInsidePopulation = false
	gDestroyAreaTrigger = TRIGGER._STORE_HAIRSALON_AREA
	gPlayerPositionInStore = POINTLIST._HAIRSALON_PLAYER
	gShoppingString = "BUT_HAIR"
	gShoppingCam = POINTLIST._HAIRSALON_BARBER02
	gHudComponent = 18
	gCamOffsetX, gCamOffsetY = 1.55, 0.35
	gAddItems = F_HairSalonItems
	gCoronaType = 17
	gPlayerHeading = 280
	gChangingAnimNode = nil
	gLookAtPoint = POINTLIST._HAIRSALON_LOOKAT
	gCameraTransitions = {
		{
			path = PATH._HAIRSALON_CAMERA01,
			camNo = 0
		}
	}
end

function F_PoorBarberMainSetup()
	gEntranceDoorTrigger = POINTLIST._DT_PHAIR_DOORL
	gCoronaPointlist = POINTLIST._POORBARBER_CORONA
	gCoronaPointlistA = POINTLIST._POORBARBERA_CORONA
	clx, cly, clz = GetPointList(gCoronaPointlistA)
	gStoreOwnerModel = 187
	gStoreOwnerPoint = POINTLIST._POORBARBER_BARBER01
	gInsidePopulation = false
	gDestroyAreaTrigger = TRIGGER._STORE_BARBERPOOR_AREA
	gSpecialStore = true
	gCoronaType = 17
	gCoronaTypeA = 6
	gSpecialSetupFunction = F_PoorBarberSetup
	gSpecialSetupFunctionA = F_PoorBarberClothingSetup
end

function F_PoorBarberSetup()
	if gCurrentSpecialStore ~= 1 then
		gCoronaPointlist = POINTLIST._POORBARBER_CORONA
		gPlayerPositionInStore = POINTLIST._POORBARBER_CORONA
		gShoppingString = "BUT_HAIR"
		gShoppingCam = POINTLIST._BARBER_RBARBERCUT
		gHudComponent = 18
		gCamOffsetX, gCamOffsetY = 1.55, 0.35
		gAddItems = F_PoorBarberItems
		gChangingAnimNode = nil
		gLookAtPoint = POINTLIST._POORBARBER_LOOKAT
		gPlayerHeading = 175.5
		gCameraTransitions = {
			{
				path = PATH._POORBARBER_CAMERA01,
				camNo = 0
			}
		}
		gCurrentSpecialStore = 1
	end
end

function F_PoorBarberClothingSetup()
	if gCurrentSpecialStore ~= 2 then
		gCoronaPointlist = POINTLIST._POORBARBERA_CORONA
		gPlayerPositionInStore = POINTLIST._POORBARBERA_CORONA
		gShoppingString = "BUT_CLOTHSTR"
		gShoppingCam = POINTLIST._RICHSHOPCAM
		gHudComponent = 14
		gCamOffsetX, gCamOffsetY = 0.87, 0.9
		gAddItems = F_PoorBarberClothes
		gChangingAnimNode = "/Global/Ambient/MissionSpec/Clothing/TryClothesAnims"
		gCanZoom = true
		gLookAtPoint = POINTLIST._POORBARBERA_LOOKAT
		gLookAtPoint2 = POINTLIST._POORBARBERA_LOOKAT2
		gCameraTransitions = {
			{
				path = PATH._POORBARBERA_CAMERA02,
				camNo = 0
			},
			{
				path = PATH._POORBARBERA_CAMERA03,
				camNo = 1
			},
			{
				path = PATH._POORBARBERA_CAMERA04,
				camNo = 2
			},
			{
				path = PATH._POORBARBERA_CAMERA04,
				camNo = 2
			},
			{
				path = PATH._POORBARBERA_CAMERA05,
				camNo = 3
			},
			{
				path = PATH._POORBARBERA_CAMERA06,
				camNo = 4
			},
			{
				path = PATH._POORBARBERA_CAMERA01,
				camNo = 5
			},
			{
				path = PATH._POORBARBERA_CAMERA01,
				camNo = 5
			}
		}
		gCurrentSpecialStore = 2
	end
end

function F_RichClothes()
	ClothingStoreAdd(1, "R_Sweater1", 1750)
	ClothingStoreAdd(1, "R_Sweater5", 1750)
	if IsMissionCompleated("2_03") then
		ClothingStoreAdd(1, "R_LSleeves1", 1750)
		ClothingStoreAdd(1, "R_SSleeves1", 1250)
		ClothingStoreAdd(1, "R_SSleeves2", 1250)
		ClothingStoreAdd(1, "R_SSleeves4", 1400)
		ClothingStoreAdd(1, "R_SSleeves5", 1400)
		ClothingStoreAdd(1, "R_SSleeves6", 1400)
		ClothingStoreAdd(1, "R_LSleeves2", 1750)
		ClothingStoreAdd(1, "R_LSleeves3", 1750)
		ClothingStoreAdd(1, "R_LSleeves4", 1750)
		ClothingStoreAdd(1, "R_LSleeves5", 1750)
		ClothingStoreAdd(1, "R_Sweater2", 2800)
		ClothingStoreAdd(1, "R_Sweater3", 2800)
		ClothingStoreAdd(1, "R_Sweater4", 2800)
		ClothingStoreAdd(1, "R_Jacket5", 2800)
		ClothingStoreAdd(1, "R_Jacket2", 5000)
		ClothingStoreAdd(1, "R_Jacket1", 10000)
		ClothingStoreAdd(0, "R_Hat1", 1400)
		ClothingStoreAdd(0, "R_Hat2", 1400)
		ClothingStoreAdd(0, "R_Hat3", 1400)
		ClothingStoreAdd(0, "R_Hat4", 2500)
		ClothingStoreAdd(0, "R_Hat5", 2500)
		ClothingStoreAdd(0, "R_Hat6", 5500)
		ClothingStoreAdd(4, "R_Pants2", 2000)
		ClothingStoreAdd(4, "R_Pants3", 2000)
		ClothingStoreAdd(4, "R_Pants4", 2800)
		ClothingStoreAdd(4, "R_Pants5", 2800)
		ClothingStoreAdd(4, "R_Shorts1", 1400)
		ClothingStoreAdd(4, "R_Shorts2", 1400)
		ClothingStoreAdd(4, "R_Shorts3", 1400)
		ClothingStoreAdd(4, "R_Shorts4", 1400)
		ClothingStoreAdd(4, "R_Shorts5", 1400)
		ClothingStoreAdd(4, "R_Pants1", 7000)
		ClothingStoreAdd(2, "R_Watch1", 3500)
		ClothingStoreAdd(2, "R_Watch2", 2500)
		ClothingStoreAdd(2, "R_Watch3", 3000)
		ClothingStoreAdd(2, "R_Watch4", 3500)
		ClothingStoreAdd(3, "R_Wristband1", 3500)
		ClothingStoreAdd(3, "R_Wristband2", 3000)
		ClothingStoreAdd(3, "R_Wristband3", 2500)
		ClothingStoreAdd(3, "R_Wristband4", 2500)
		ClothingStoreAdd(5, "R_Sneakers2", 1800)
		ClothingStoreAdd(5, "R_Sneakers3", 1800)
		ClothingStoreAdd(5, "R_Sneakers5", 1800)
		ClothingStoreAdd(5, "R_Sneakers4", 2250)
		ClothingStoreAdd(5, "R_Boots2", 2500)
		ClothingStoreAdd(5, "R_Boots3", 2500)
		ClothingStoreAdd(5, "R_Sneakers1", 3500)
	end
end

function F_PoorClothes()
	ClothingStoreAdd(0, "B_BHat1", 600)
	ClothingStoreAdd(0, "B_BHat2", 600)
	ClothingStoreAdd(0, "B_BHat3", 600)
	ClothingStoreAdd(0, "B_BHat4", 600)
	ClothingStoreAdd(0, "B_BHat5", 600)
	ClothingStoreAdd(0, "B_BHat6", 600)
	ClothingStoreAdd(0, "B_Various3", 750)
	ClothingStoreAdd(0, "B_Various4", 750)
	ClothingStoreAdd(0, "B_Toque1", 750)
	ClothingStoreAdd(0, "B_Toque2", 750)
	ClothingStoreAdd(0, "B_Bucket1", 850)
	ClothingStoreAdd(0, "B_Bucket2", 850)
	ClothingStoreAdd(0, "B_Hunter1", 850)
	ClothingStoreAdd(0, "B_Hunter2", 1000)
	ClothingStoreAdd(0, "B_Various2", 850)
	ClothingStoreAdd(0, "B_Hunter3", 1000)
	ClothingStoreAdd(0, "B_Various1", 1000)
	ClothingStoreAdd(0, "B_Various5", 1400)
	ClothingStoreAdd(1, "B_Jersey3", 700)
	ClothingStoreAdd(1, "B_Jersey4", 700)
	ClothingStoreAdd(1, "B_Jersey5", 700)
	ClothingStoreAdd(1, "B_Jersey6", 700)
	ClothingStoreAdd(1, "B_Jersey7", 700)
	ClothingStoreAdd(1, "B_Jersey8", 700)
	ClothingStoreAdd(1, "B_Jersey9", 700)
	ClothingStoreAdd(1, "B_Jersey10", 700)
	ClothingStoreAdd(1, "B_SSleeves1", 700)
	ClothingStoreAdd(1, "B_Jersey1", 700)
	ClothingStoreAdd(1, "B_SSleeves2", 900)
	ClothingStoreAdd(1, "B_SSleeves3", 900)
	ClothingStoreAdd(1, "B_LSleeves2", 900)
	ClothingStoreAdd(1, "B_LSleeves3", 900)
	ClothingStoreAdd(1, "B_LSleeves4", 900)
	ClothingStoreAdd(1, "B_Sweater2", 1000)
	ClothingStoreAdd(1, "B_Sweater3", 1000)
	ClothingStoreAdd(1, "B_Sweater4", 1000)
	ClothingStoreAdd(1, "B_Jacket1", 1200)
	ClothingStoreAdd(1, "B_Jacket2", 1200)
	ClothingStoreAdd(1, "B_Jacket3", 1200)
	ClothingStoreAdd(4, "B_Pants6", 1000)
	ClothingStoreAdd(4, "B_Pants7", 1000)
	ClothingStoreAdd(4, "B_Pants1", 1200)
	ClothingStoreAdd(4, "B_Pants8", 1200)
	ClothingStoreAdd(4, "B_Pants3", 1400)
	ClothingStoreAdd(4, "B_Shorts4", 900)
	ClothingStoreAdd(4, "B_Shorts5", 900)
	ClothingStoreAdd(4, "B_Shorts2", 1100)
	ClothingStoreAdd(4, "B_Shorts6", 1100)
	ClothingStoreAdd(4, "B_Shorts7", 1100)
	ClothingStoreAdd(4, "B_Shorts1", 900)
	ClothingStoreAdd(4, "B_Shorts3", 1100)
	ClothingStoreAdd(4, "B_Pants4", 1400)
	ClothingStoreAdd(5, "B_Sneakers4", 900)
	ClothingStoreAdd(5, "B_Sneakers5", 900)
	ClothingStoreAdd(5, "B_Boots3", 1250)
	ClothingStoreAdd(5, "B_Boots4", 1250)
	ClothingStoreAdd(5, "B_Sneakers1", 900)
	ClothingStoreAdd(5, "B_Sneakers11", 700)
	ClothingStoreAdd(5, "B_Sneakers13", 700)
	ClothingStoreAdd(5, "B_Sneakers6", 700)
	ClothingStoreAdd(5, "B_Sneakers8", 700)
	ClothingStoreAdd(5, "B_Sneakers9", 700)
	ClothingStoreAdd(5, "B_Sneakers10", 700)
	ClothingStoreAdd(5, "B_Sneakers12", 700)
	ClothingStoreAdd(5, "B_Boots5", 1000)
	ClothingStoreAdd(5, "B_Sneakers3", 1700)
	ClothingStoreAdd(5, "B_Sneakers2", 2000)
	ClothingStoreAdd(5, "B_Boots2", 2250)
	ClothingStoreAdd(2, "B_Watch1", 1300)
	ClothingStoreAdd(2, "B_Watch2", 1300)
	ClothingStoreAdd(2, "B_Watch3", 1300)
	ClothingStoreAdd(2, "B_Watch4", 1300)
	ClothingStoreAdd(2, "B_Watch5", 1300)
	ClothingStoreAdd(3, "B_Wristband1", 650)
	ClothingStoreAdd(3, "B_Wristband4", 1000)
	ClothingStoreAdd(3, "B_Wristband5", 1000)
	ClothingStoreAdd(3, "B_Wristband2", 1100)
	ClothingStoreAdd(3, "B_Wristband3", 1100)
end

function F_BarberItems()
	local nGroupID = 0
	BarberShopSetGroupName(nGroupID, "B_FlatTop")
	BarberShopAdd(nGroupID, "B_FlatTop_01", 600)
	BarberShopAdd(nGroupID, "B_FlatTop_02", 900)
	BarberShopAdd(nGroupID, "B_FlatTop_03", 900)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "B_MFade")
	BarberShopAdd(nGroupID, "B_MFade_01", 600)
	BarberShopAdd(nGroupID, "B_MFade_02", 900)
	BarberShopAdd(nGroupID, "B_MFade_03", 900)
	BarberShopAdd(nGroupID, "B_MFade_04", 900)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "B_CrewCut")
	BarberShopAdd(nGroupID, "B_CrewCut_01", 600)
	BarberShopAdd(nGroupID, "B_CrewCut_02", 900)
	BarberShopAdd(nGroupID, "B_CrewCut_03", 900)
	BarberShopAdd(nGroupID, "B_CrewCut_04", 900)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "B_Caesar")
	BarberShopAdd(nGroupID, "B_Caesar_01", 800)
	BarberShopAdd(nGroupID, "B_Caesar_02", 1200)
	BarberShopAdd(nGroupID, "B_Caesar_03", 1200)
	BarberShopAdd(nGroupID, "B_Caesar_04", 1200)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "B_Bald")
	BarberShopAdd(nGroupID, "B_Bald", 500)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "B_Buzz")
	BarberShopAdd(nGroupID, "B_Buzz", 500)
end

function F_HairSalonItems()
	local nGroupID = 0
	BarberShopSetGroupName(nGroupID, "R_GoodBoy")
	BarberShopAdd(nGroupID, "R_GoodBoy_01", 1200)
	BarberShopAdd(nGroupID, "R_GoodBoy_02", 1500)
	BarberShopAdd(nGroupID, "R_GoodBoy_03", 1500)
	BarberShopAdd(nGroupID, "R_GoodBoy_04", 1500)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "R_Hwood")
	BarberShopAdd(nGroupID, "R_Hwood_01", 1200)
	BarberShopAdd(nGroupID, "R_Hwood_02", 1500)
	BarberShopAdd(nGroupID, "R_Hwood_03", 1500)
	BarberShopAdd(nGroupID, "R_Hwood_04", 1500)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "R_HThrob")
	BarberShopAdd(nGroupID, "R_HThrob_01", 1200)
	BarberShopAdd(nGroupID, "R_HThrob_02", 1500)
	BarberShopAdd(nGroupID, "R_HThrob_03", 1500)
	BarberShopAdd(nGroupID, "R_HThrob_04", 1500)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "R_SShag")
	BarberShopAdd(nGroupID, "R_SShag_01", 1200)
	BarberShopAdd(nGroupID, "R_SShag_02", 1500)
	BarberShopAdd(nGroupID, "R_SShag_03", 1500)
	BarberShopAdd(nGroupID, "R_SShag_04", 1500)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "R_SSmart")
	BarberShopAdd(nGroupID, "R_SSmart_01", 1200)
	BarberShopAdd(nGroupID, "R_SSmart_02", 1500)
	BarberShopAdd(nGroupID, "R_SSmart_03", 1500)
	BarberShopAdd(nGroupID, "R_SSmart_04", 1500)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "R_ILeague")
	BarberShopAdd(nGroupID, "R_ILeague_01", 1500)
	BarberShopAdd(nGroupID, "R_ILeague_02", 1800)
	BarberShopAdd(nGroupID, "R_ILeague_03", 1800)
	BarberShopAdd(nGroupID, "R_ILeague_04", 1800)
end

function F_PoorBarberItems()
	local nGroupID = 0
	BarberShopSetGroupName(nGroupID, "P_Details2")
	BarberShopAdd(nGroupID, "P_Details2_01", 1000)
	BarberShopAdd(nGroupID, "P_Details2_02", 1200)
	BarberShopAdd(nGroupID, "P_Details2_03", 1200)
	BarberShopAdd(nGroupID, "P_Details2_04", 1200)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "P_Mh_Spike")
	BarberShopAdd(nGroupID, "P_Mh_Spike_01", 1000)
	BarberShopAdd(nGroupID, "P_Mh_Spike_02", 1200)
	BarberShopAdd(nGroupID, "P_Mh_Spike_03", 1200)
	BarberShopAdd(nGroupID, "P_Mh_Spike_04", 1200)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "P_Details1")
	BarberShopAdd(nGroupID, "P_Details1_01", 1000)
	BarberShopAdd(nGroupID, "P_Details1_02", 1200)
	BarberShopAdd(nGroupID, "P_Details1_03", 1200)
	BarberShopAdd(nGroupID, "P_Details1_04", 1200)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "P_Fauhawk")
	BarberShopAdd(nGroupID, "P_Fauhawk_01", 1000)
	BarberShopAdd(nGroupID, "P_Fauhawk_02", 1200)
	BarberShopAdd(nGroupID, "P_Fauhawk_03", 1200)
	BarberShopAdd(nGroupID, "P_Fauhawk_04", 1200)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "P_Mh_Flat")
	BarberShopAdd(nGroupID, "P_Mh_Flat_01", 1000)
	BarberShopAdd(nGroupID, "P_Mh_Flat_02", 1200)
	BarberShopAdd(nGroupID, "P_Mh_Flat_03", 1200)
	BarberShopAdd(nGroupID, "P_Mh_Flat_04", 1200)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "P_Spiky")
	BarberShopAdd(nGroupID, "P_Spiky_01", 1000)
	BarberShopAdd(nGroupID, "P_Spiky_02", 1200)
	BarberShopAdd(nGroupID, "P_Spiky_03", 1200)
	BarberShopAdd(nGroupID, "P_Spiky_04", 1200)
	nGroupID = nGroupID + 1
	BarberShopSetGroupName(nGroupID, "P_Taper")
	BarberShopAdd(nGroupID, "P_Taper_01", 1200)
	BarberShopAdd(nGroupID, "P_Taper_02", 1500)
	BarberShopAdd(nGroupID, "P_Taper_03", 1500)
	BarberShopAdd(nGroupID, "P_Taper_04", 1500)
end

function F_PoorBarberClothes()
	ClothingStoreAdd(0, "P_Bhat1", 500)
	ClothingStoreAdd(0, "P_Bhat2", 500)
	ClothingStoreAdd(0, "P_Bhat3", 500)
	ClothingStoreAdd(0, "P_Bhat4", 500)
	ClothingStoreAdd(0, "P_Bhat5", 500)
	ClothingStoreAdd(0, "P_Bhat6", 500)
	ClothingStoreAdd(0, "P_Army1", 500)
	ClothingStoreAdd(0, "P_Army2", 500)
	ClothingStoreAdd(0, "P_Army3", 500)
	ClothingStoreAdd(0, "P_Bandana1", 350)
	ClothingStoreAdd(0, "P_Bandana2", 350)
	ClothingStoreAdd(0, "P_Bandana3", 350)
	ClothingStoreAdd(0, "P_Toque1", 500)
	ClothingStoreAdd(0, "P_Toque2", 500)
	ClothingStoreAdd(0, "P_Toque3", 500)
	ClothingStoreAdd(1, "P_SSleeves3", 500)
	ClothingStoreAdd(1, "P_SSleeves4", 500)
	ClothingStoreAdd(1, "P_SSleeves6", 500)
	ClothingStoreAdd(1, "P_SSleeves7", 500)
	ClothingStoreAdd(1, "P_SSleeves8", 500)
	ClothingStoreAdd(1, "P_SSleeves9", 500)
	ClothingStoreAdd(1, "P_SSleeves10", 500)
	ClothingStoreAdd(1, "P_SSleeves12", 300)
	ClothingStoreAdd(1, "P_SSleeves13", 300)
	ClothingStoreAdd(1, "P_SSleeves14", 300)
	ClothingStoreAdd(1, "P_LSleeves1", 900)
	ClothingStoreAdd(1, "P_LSleeves2", 900)
	ClothingStoreAdd(1, "P_LSleeves5", 900)
	ClothingStoreAdd(1, "P_LSleeves3", 900)
	ClothingStoreAdd(1, "P_LSleeves4", 900)
	ClothingStoreAdd(1, "P_LSleeves6", 900)
	ClothingStoreAdd(1, "P_LSleeves7", 900)
	ClothingStoreAdd(1, "P_LSleeves8", 900)
	ClothingStoreAdd(1, "P_SSleeves1", 900)
	ClothingStoreAdd(1, "P_SSleeves2", 900)
	ClothingStoreAdd(1, "P_SSleeves5", 900)
	ClothingStoreAdd(1, "P_LSleeves9", 900)
	ClothingStoreAdd(1, "P_LSleeves10", 900)
	ClothingStoreAdd(1, "P_Sweater1", 1100)
	ClothingStoreAdd(1, "P_Sweater2", 1100)
	ClothingStoreAdd(1, "P_Sweater3", 1100)
	ClothingStoreAdd(1, "P_Sweater4", 900)
	ClothingStoreAdd(1, "P_Sweater5", 900)
	ClothingStoreAdd(1, "P_Sweater6", 900)
	ClothingStoreAdd(1, "P_Sweater7", 700)
	ClothingStoreAdd(1, "P_Sweater8", 900)
	ClothingStoreAdd(1, "P_Jacket4", 1300)
	ClothingStoreAdd(1, "P_Jacket5", 1300)
	ClothingStoreAdd(1, "P_Jacket6", 1300)
	ClothingStoreAdd(1, "P_Jacket1", 1300)
	ClothingStoreAdd(1, "P_Jacket3", 2250)
	ClothingStoreAdd(1, "P_Jacket2", 3000)
	ClothingStoreAdd(4, "P_Pants7", 600)
	ClothingStoreAdd(4, "P_Pants2", 1250)
	ClothingStoreAdd(4, "P_Pants3", 1000)
	ClothingStoreAdd(4, "P_Pants5", 1000)
	ClothingStoreAdd(4, "P_Shorts3", 800)
	ClothingStoreAdd(4, "P_Shorts4", 800)
	ClothingStoreAdd(4, "P_Pants6", 800)
	ClothingStoreAdd(4, "P_Shorts2", 600)
	ClothingStoreAdd(4, "P_Shorts1", 600)
	ClothingStoreAdd(4, "P_Pants1", 1500)
	ClothingStoreAdd(4, "P_Pants4", 2000)
	ClothingStoreAdd(5, "P_Sneakers3", 600)
	ClothingStoreAdd(5, "P_Sneakers4", 600)
	ClothingStoreAdd(5, "P_Sneakers5", 600)
	ClothingStoreAdd(5, "P_Sneakers6", 600)
	ClothingStoreAdd(5, "P_Sneakers7", 600)
	ClothingStoreAdd(5, "P_Sneakers11", 900)
	ClothingStoreAdd(5, "P_Sneakers12", 900)
	ClothingStoreAdd(5, "P_Sneakers13", 900)
	ClothingStoreAdd(5, "P_Sneakers19", 900)
	ClothingStoreAdd(5, "P_Sneakers9", 1200)
	ClothingStoreAdd(5, "P_Sneakers10", 1200)
	ClothingStoreAdd(5, "P_Sneakers14", 1200)
	ClothingStoreAdd(5, "P_Sneakers15", 1200)
	ClothingStoreAdd(5, "P_Sneakers17", 1200)
	ClothingStoreAdd(5, "P_Sneakers16", 1000)
	ClothingStoreAdd(5, "P_Sneakers18", 1000)
	ClothingStoreAdd(5, "P_Sneakers1", 1300)
	ClothingStoreAdd(5, "P_Sneakers8", 1600)
	ClothingStoreAdd(5, "P_Boots1", 1200)
	ClothingStoreAdd(5, "P_Boots4", 1200)
	ClothingStoreAdd(5, "P_Boots3", 2000)
	ClothingStoreAdd(2, "P_Watch1", 900)
	ClothingStoreAdd(3, "P_Wristband1", 300)
	ClothingStoreAdd(3, "P_Wristband2", 700)
	ClothingStoreAdd(3, "P_Wristband3", 700)
	ClothingStoreAdd(3, "P_Wristband4", 900)
	ClothingStoreAdd(3, "P_Wristband5", 900)
	ClothingStoreAdd(3, "P_Wristband6", 1100)
	ClothingStoreAdd(3, "P_Wristband7", 1300)
	ClothingStoreAdd(3, "P_Wristband8", 1200)
end

function F_CheckClock()
	hour, minute = ClockGet()
	if hour == 1 and 55 < minute or hour == 2 or PlayerFellAsleep() or AreaIsLoading() then
		return false
	end
	return true
end

function T_StopSpineTracking()
	Wait(5000)
	PedLockTarget(gClerk, -1)
end

function F_CheckPedNotInGrapple(PedID)
	pGrapplePed = PedGetGrappleTargetPed(PedID)
	if pGrapplePed == -1 then
		return true
	end
	return false
end
