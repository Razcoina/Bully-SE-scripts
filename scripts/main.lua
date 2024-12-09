--[[ Changes in this file:
	* Removed global import of "LoadActionTrees.lua"
	* Removed 2 values from gAreaScripts: 2 test areas
	* Removed 1 local variable, not present in original script
	* Modified function gamemain, may require testing
	* Modified function F_AlarmThread, may require testing
	* Removed function F_TestObjectCreate, not present in original script
	* Removed function F_TestPrint, not present in original script
	* Removed function F_TestText, not present in original script
	* Modified function F_CreateHalloweenItems, may require testing
	* Modified function F_HandleLoadGame, may require testing
	* Modified function CB_CollectibleCollected, may require testing
	* Modified function F_CheckAllCollectibles, may require testing
	* Modified function CB_MiniObjectiveCompleted, may require testing
]]

--[[
GlobalImportScript("LoadActionTrees.lua")
]] -- Not present in original script
GlobalImportScript("POI/Events.lua")
gHACKClothesCam = false
local bBusStopsDisabled
local bArcadeMachinesON = false
gAreaScripts = {}
gAreaScripts[6] = "AreaScripts/Bio_Lab.lua"
gAreaScripts[50] = "SSTores.lua"
gAreaScripts[43] = "AreaScripts/Junkyard.lua"
gAreaScripts[45] = "AreaScripts/Midway.lua"
gAreaScripts[2] = "AreaScripts/SchoolHallways.lua"
gAreaScripts[0] = "AreaScripts/MainMap.lua"
gAreaScripts[26] = "SStores.lua"
gAreaScripts[16] = "AreaScripts/Tattoos.lua"
gAreaScripts[29] = "SStores.lua"
gAreaScripts[30] = "SStores.lua"
gAreaScripts[36] = "AreaScripts/Tenements.lua"
gAreaScripts[14] = "AreaScripts/Bdorm.lua"
gAreaScripts[35] = "AreaScripts/Gdorm.lua"
gAreaScripts[37] = "AreaScripts/Funhouse.lua"
gAreaScripts[27] = "AreaScripts/Boxing.lua"
gAreaScripts[32] = "AreaScripts/PrepHouse.lua"
gAreaScripts[8] = "AreaScripts/Janitors.lua"
gAreaScripts[13] = "AreaScripts/GymAndPool.lua"
gAreaScripts[39] = "AreaScripts/StyleStores.lua"
gAreaScripts[34] = "AreaScripts/StyleStores.lua"
gAreaScripts[38] = "AreaScripts/Asylum.lua"
gAreaScripts[9] = "AreaScripts/Library.lua"
gAreaScripts[54] = "AreaScripts/Warehouse.lua"
gAreaScripts[23] = "AreaScripts/StaffRoom.lua"
gAreaScripts[5] = "AreaScripts/PrincipalOffice.lua"
gAreaScripts[40] = "AreaScripts/Observatory.lua"
gAreaScripts[4] = "AreaScripts/Chem_Lab.lua"
gAreaScripts[20] = "AreaScripts/ChemPlant.lua"
gAreaScripts[17] = "AreaScripts/ArtRoom.lua"
gAreaScripts[18] = "AreaScripts/AutoShop.lua"
gAreaScripts[19] = "AreaScripts/Auditorium.lua"
gAreaScripts[33] = "AreaScripts/StyleStores.lua"
gAreaScripts[15] = "AreaScripts/Classroom.lua"
gAreaScripts[46] = "AreaScripts/StyleStores.lua"
gAreaScripts[56] = "AreaScripts/StyleStores.lua"
gAreaScripts[57] = "AreaScripts/SaveZones.lua"
gAreaScripts[60] = "AreaScripts/SaveZones.lua"
gAreaScripts[61] = "AreaScripts/SaveZones.lua"
gAreaScripts[59] = "AreaScripts/SaveZones.lua"
gAreaScripts[42] = "AreaScripts/TGokart.lua"
gAreaScripts[51] = "AreaScripts/ImgRaceA.lua"
gAreaScripts[52] = "AreaScripts/ImgRaceB.lua"
gAreaScripts[53] = "AreaScripts/ImgRaceC.lua"
gAreaScripts[17] = "AreaScripts/ArtRoom.lua"
gAreaScripts[55] = "AreaScripts/FreakShow.lua"
gAreaScripts[62] = "AreaScripts/BMXTrack.lua"
--[[
gAreaScripts[22] = "Test/Island3.lua"
gAreaScripts[31] = "Test/TestArea.lua"
]] -- Not present in original script

function F_RegisterAreaInfo(areaScriptTable)
	for i, element in areaScriptTable do
		AreaRegisterAreaScript(i, element)
	end
end

GlobalImportScript("SInitGl.lua")
GlobalImportScript("SGlFunc.lua")
GlobalImportScript("SMStat.lua")
GlobalImportScript("SScriptTracks.lua")
GlobalImportScript("SFaction.lua")
GlobalImportScript("SCutscenes.lua")
GlobalImportScript("SMissPass.lua")
bDanceThatCow = false
local bPrincipalWarning = false
local bLockSchoolGates = true
local bFrontGateOpen = false
local bSideGateOpen = false
local b106Complete = false
local gBoysDormSaveBlipID = -1
local gPreviousBustedCount = 0
local bLaunchPrincipalMission = false
local bPoliceDropPlayerOffNIS = false
local bAlarmOn = false
local gNumMissionsPassed = 0

--[[
local bIsNormalFlow = true
]] -- Not present in original script

local bDontFadeIn = false
local bWakingUp = false
local photoEntity, photoType
local photoTime = 0
local photoAmount, gSchoolSaveBlip, gCurrentHour, gCurrentMinute
local gBlipsAdded = false
local bSentToClass = false
local bIsInTitleScreen = true
local bHasStoryModeBeenSelected = false
local bIsNormalFlow = true

function gamemain() -- ! Modified
	F_RegisterAreaInfo(gAreaScripts)
	gAreaScripts = nil
	SystemMarkCollisionForExclusion("tGlobal")
	SystemMarkCollisionForExclusion("pAnimsE")
	SystemMarkCollisionForExclusion("pAnimsI")
	SystemMarkCollisionForExclusion("ppoor")
	SystemMarkCollisionForExclusion("psc_rich")
	SystemMarkCollisionForExclusion("psc_veg")
	SystemMarkCollisionForExclusion("psc_yard")
	SystemMarkCollisionForExclusion("pstreets")
	SystemMarkCollisionForExclusion("BikeGar")
	SystemMarkCollisionForExclusion("PortaPoo")
	AreaSetSavePointLocation(ObjectNameToHashID("SAVEBOOKBOYSDORM"), -491.6, 310.3, 31.4, 76.2, 14, -494.703, 312.915, 33.918)
	AreaSetSavePointLocation(ObjectNameToHashID("SAVEBOOKNERDS"), -733.8, 36.2, -2.3, -82.5, 30, -730.373, 34.04, 0.277)
	AreaSetSavePointLocation(ObjectNameToHashID("SAVEBOOKDROPOUTS"), -655, 248, 15.2, 82.4, 57, -658.078, 251.332, 17.823)
	AreaSetSavePointLocation(ObjectNameToHashID("SAVEBOOKGREASERS"), -696.8, 352.6, 3.3, -176.7, 61, -697.463, 348.687, 4.366)
	AreaSetSavePointLocation(ObjectNameToHashID("SAVEBOOKJOCKS"), -742.3, 348.3, 3.5, 70.1, 59, -746.004, 347.044, 5.191)
	AreaSetSavePointLocation(ObjectNameToHashID("SAVEBOOKPREPS"), -778, 357.6, 6.4, -160.3, 60, -775.002, 355.134, 8.7)
	AreaSetSavePointLocation(ObjectNameToHashID("SAVEBOOKSCHOOL"), -634.1, -289.3, 5.5, -170.9, 2, -636.276, -292.447, 7.498)
	--[[
	LogLoad("ACTION TREES")
	F_LoadAllActionTrees()
	LogLoad("ACTION TREES END")
	]] -- Not present in original script
	LogLoad("DAT FILES")
	DATLoad("tags.DAT", 5)
	DATLoad("tschool_hangouts.DAT", 1)
	DATLoad("Store.DAT", 1)
	DATLoad("Global.DAT", 1)
	DATLoad("Population.DAT", 1)
	DATLoad("School_Exterior.DAT", 1)
	DATLoad("SoundTriggers.DAT", 1)
	DATLoad("SoundBankTriggers.DAT", 1)
	DATLoad("SndBnkLoad.DAT", 1)
	DATLoad("Effect.DAT", 1)
	DATLoad("tbusines_doors.DAT", 5)
	DATLoad("tschool_doors.DAT", 5)
	DATLoad("tschool_maindoors.dat", 1)
	DATLoad("tindustrial.DAT", 1)
	DATLoad("tindustrial_doors.DAT", 5)
	DATLoad("mainmap_bricks.DAT", 1)
	DATLoad("MisTrig.DAT", 1)
	DATLoad("AreaTran.DAT", 1)
	DATLoad("MainMapZones.DAT", 1)
	DATLoad("PAn_Main.DAT", 5)
	DATLoad("sndpnt.DAT", 1)
	DATLoad("trich.DAT", 5)
	DATLoad("trich_doors.DAT", 5)
	DATLoad("MiniGameTrigger.DAT", 1)
	DATLoad("PAn_Rich.DAT", 5)
	--[[
	DATLoad("TestCharacters.DAT", 1)
	DATLoad("SpawnTest.DAT", 1)
	]] -- Not present in original script
	LogLoad("DAT FILES END")
	LogLoad("INIT PLAYER")
	--[[
	gPlayerStartX, gPlayerStartY, gPlayerStartZ, gPlayerStartH = -701.08, 213.482, 31.553, 90
	]] -- Modified to:
	gPlayerStartX, gPlayerStartY, gPlayerStartZ, gPlayerStartH = 272.68, -73.1309, 6.96913, 90
	F_LoadPlayer()
	collectgarbage()
	LogLoad("INIT PLAYER END")
	PlayerDoneLoading(true) -- Added this
	F_LoadTime()
	--[[
	CameraFade(0, 0)
	]] -- Not present in original script
	-- Added this loop:
	while bHasStoryModeBeenSelected == false do
		Wait(100)
		bHasStoryModeBeenSelected = HasStoryModeBeenSelected()
	end
	LogLoad("IMPORT SCRIPTS")
	ImportScript("SWinEff.lua")
	collectgarbage()
	ImportScript("SRoomEff.lua")
	collectgarbage()
	ImportScript("SLightEff.lua")
	collectgarbage()
	ImportScript("Garages.lua")
	collectgarbage()
	ImportScript("Bike_gen.lua")
	collectgarbage()
	LogLoad("IMPORT SCRIPTS END")
	LogLoad("INIT GARAGES")
	F_InitGarages()
	LogLoad("INIT GARAGES END")
	LogLoad("INIT CUTSCENES")
	F_BuildCutsceneTable()
	LogLoad("INIT CUTSCENES END")
	LogLoad("IMPORT MORE SCRIPTS")
	LaunchScript("STimeCycle.lua")
	ImportScript("SLvesEff.lua")
	HUDSetNumGlobeKeys(15)
	HUDSetNumFortuneTellerKeys(119)
	BulletinSetupTexture("BulletinChapter1_1")
	BulletinSetupMessage("NONE", "BB_00")
	BulletinSetupMessage("NONE", "BB_01")
	BulletinSetupMessage("1_02B", "BB_03")
	BulletinSetupMessage("1_04", "BB_02")
	BulletinSetupMessage("1_05", "BB_04")
	BulletinSetupMessage("1_07", "BB_05")
	BulletinSetupMessage("1_08", "BB_06")
	BulletinSetupMessage("1_09", "BB_07")
	BulletinSetupMessage("1_11x2", "BB_08")
	BulletinSetupMessage("1_G1", "BB_09")
	BulletinSetupMessage("1_B", "BB_10")
	BulletinSetupMessage("2_01", "BB_11")
	BulletinSetupMessage("3_R09_N", "BB_12")
	BulletinSetupMessage("2_G2", "BB_13")
	BulletinSetupMessage("2_07", "BB_14")
	BulletinSetupMessage("2_08", "BB_15")
	BulletinSetupMessage("2_S06", "BB_16")
	BulletinSetupMessage("2_B", "BB_17")
	BulletinSetupMessage("3_01", "BB_18")
	BulletinSetupMessage("3_S10", "BB_19")
	BulletinSetupMessage("3_05", "BB_20")
	BulletinSetupMessage("3_B", "BB_21")
	BulletinSetupMessage("4_B1", "BB_22")
	BulletinSetupMessage("4_05", "BB_23")
	BulletinSetupMessage("3_S11", "BB_24")
	BulletinSetupMessage("4_B2", "BB_25")
	BulletinSetupMessage("5_05", "BB_26")
	BulletinSetupMessage("6_B", "BB_27")
	BulletinSetupMessage("C_ART_1", "BB_28")
	BulletinSetupMessage("C_ENGLISH_1", "BB_29")
	--[[
	LaunchScript("SZone.lua")
	LaunchScript("RemoteDebug.lua")
	]] -- Not present in original script
	collectgarbage()
	LogLoad("IMPORT MORE SCRIPTS END")
	CollectiblesSetTypeAvailable(1, false) -- Added this
	CollectibleOnMapEnable(2, false)    -- Added this
	CollectibleOnMapEnable(3, false)    -- Added this
	CollectibleOnMapEnable(1, false)    -- Added this
	CollectibleOnMapEnable(0, false)    -- Added this
	StatResetAll()
	ImportScript("SStats.lua")
	ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListCrateHEALTH")
	ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateHEALTH")
	ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateHEALTH")
	--print("RESETTING ALL OF THE SPECIAL ENTITIES!")
	AreaLoadSpecialEntities("Halloween1", false)
	AreaLoadSpecialEntities("Halloween2", false)
	AreaLoadSpecialEntities("Halloween3", false)
	AreaLoadSpecialEntities("Christmas", false)
	AreaLoadSpecialEntities("TombstonePost", false)
	AreaLoadSpecialEntities("PumpkinPost", false)
	--print("RESETTING THE STATES!!!")
	SetFactionRespect(11, 0)
	SetFactionRespect(1, 0)
	SetFactionRespect(5, 0)
	SetFactionRespect(4, 0)
	SetFactionRespect(2, 0)
	SetFactionRespect(3, 0)
	--[[
	while bHasStoryModeBeenSelected == false do
		Wait(100)
		bHasStoryModeBeenSelected = HasStoryModeBeenSelected()
	end
	]]            -- Not present in original script
	LogLoad("WAIT FOR SYSTEM TO BE READY")
	ReadyToLoad() -- Added this
	while not SystemIsReady() do
		--print("...waiting for system to be ready...")
		Wait(0)
	end
	LogLoad("WAIT FOR SYSTEM TO BE READY END")
	F_LoadSprayCans()
	collectgarbage()
	math.randomseed(GetTimer())
	F_SetupKOPoints()
	--[[
	F_TestObjectCreate()
	]] -- Not present in original script
	ResetGiftRequirements()
	F_BuildAreaTable()
	F_MissionCompleteModelChanges()
	F_MissionFactionChanges()
	F_SetupGiftRequirements()
	bsMarkCheckPoint(1)
	bsDumpMemUsage()
	bsDumpRunTimeMetrics()
	CreateThread("F_CheckPOI")
	CreateThread("F_AlarmThread")
	CreateThread("T_PhotographyStimulus")
	RegisterCallbackOnYearbookPhoto(CB_YearbookPhotoMain)
	gPreviousBustedCount = PlayerGetScriptSavedData(24)
	RegisterCallbackOnBusted(F_PlayerBusted)
	CollectiblesOnCollectedCallback(CB_CollectibleCollected)
	MiniObjectiveOnCompletedCallback(CB_MiniObjectiveCompleted)
	ImportScript("CowDance.lua")
	CreateThread("F_DanceCowDance")
	F_BlipSavePoints()
	gNumMissionsPassed = GetTotalMissionSuccessCount()
	ClockSetEnableMission("1_02B") -- Added this
	LogLoad("END")
	SystemAllowMissionManagerToForceRunMissions()
	--[[
	ClockSetEnableMission("1_02B")
	]] -- Removed this
	-- Added this loop:
	while AreaIsLoading() do
		Wait(0)
	end
	F_HandleLoadGame() -- Added this
	if IsDemoBuildEnabled() == true then
		AreaTransitionXYZ(0, 272.68, -73.1309, 6.96913, true)
		PlayerFaceHeading(90, 0)
		CameraReset()
		ForceStartMission("1_05")
		while true do
			Wait(100)
		end
	end
	while bIsNormalFlow == true do
		local shouldMovePlayer = false
		local playerPositioningMechanism = 0
		shouldMovePlayer, playerPositioningMechanism = SystemShouldMovePlayer()
		F_BusPoints()
		F_SavePoints()
		F_SetupExtraKOPoints()
		F_GarageBlips()
		if bWakingUp == true then
			bWakingUp = false
			PlayerSetPunishmentPoints(0)
			while AreaIsLoading() do
				Wait(0)
			end
			if AreaGetVisible() == 0 then
				--print("EXECUTING ACTION NODE!!!!")
				ExecuteActionNode(gPlayer, "/Global/Ambient/MissionSpec/WakeUp/WakeUp_Anywhere/WakeUpBank/GetUp", "Act/Anim/Ambient.act")
			else
				CameraFade(500, 1)
			end
			shouldMovePlayer = false
		end
		if bArcadeMachinesON and not shared.ArcadeMachinesOn then
			F_ToggleArcadeScreens()
			bArcadeMachinesON = false
		elseif not bArcadeMachinesON and shared.ArcadeMachinesOn then
			F_ToggleArcadeScreens()
			bArcadeMachinesON = true
		end
		if shouldMovePlayer then
			if playerPositioningMechanism == 0 then
				--print("ALEX DEBUG: Positioning player with debug info")
				AreaTransitionXYZ(0, 272.68, -73.1309, 6.96913, true)
				PlayerFaceHeading(90, 0)
				CameraReset()
				CameraFade(500, 1)
				SoundFadeoutStream()
			elseif playerPositioningMechanism == 1 then
				--print("ALEX DEBUG: Positioning player with loaded info")
				local moveX, moveY, moveZ = 0, 0, 0
				local moveHeading = 0
				local moveAreaCode = -1
				local bRestartMission = false
				moveX, moveY, moveZ, moveHeading, moveAreaCode, bRestartMission = SystemGetSavedPositionInformation()
				AreaForceLoadAreaByAreaTransition(true)
				AreaTransitionXYZ(moveAreaCode, moveX, moveY, moveZ, true)
				AreaForceLoadAreaByAreaTransition(false)
				PlayerFaceHeadingNow(moveHeading)
				if IsMissionCompleated("1_11xp") and not IsMissionCompleated("1_11x2") and not IsMissionCompleated("1_11_Dummy") then
					LoadPedModels({ 165, 160 })
					if PedIsValid(shared.gGary) then
						PedDelete(shared.gGary)
					end
					if PedIsValid(shared.gPetey) then
						PedDelete(shared.gPetey)
					end
					local x1, y1, z1 = 0, 0, 0
					local x2, y2, z2 = 0, 0, 0
					if AreaGetVisible() == 0 then
						x1, y1, z1 = 211.995, -93.2388, 8.52597
						x2, y2, z2 = 212.162, -96.7299, 8.54881
					else
						x1, y1, z1 = -495.7, 311.9, 31.4
						x2, y2, z2 = -496.5, 309.6, 31.4
					end
					local hallHour, hallMinute = ClockGet()
					if hallHour <= 2 and hallHour >= 20 then
						shared.gGary = PedCreateXYZ(160, x1, y1, z1)
						PedRecruitAlly(gPlayer, shared.gGary)
						shared.gPetey = PedCreateXYZ(165, x2, y2, z2)
						PedRecruitAlly(shared.gGary, shared.gPetey)
						PedShowHealthBar(shared.gGary, true, "1_HALLOWEEN_GARY", false, shared.gPetey, "1_HALLOWEEN_PETE")
					end
				end
				if shared.playerKOd then
				end
				if not bDontFadeIn and not bRestartMission then
					CameraReturnToPlayer(true, true)
					CameraFade(500, 1)
				end
				bDontFadeIn = false
			else
				--print("ALEX DEBUG: Not Positioning player")
				CameraReturnToPlayer()
				bDontFadeIn = false
			end
			StatSetIsTrackingEnabled(true)
			SystemResetShouldMovePlayer()
		else
			Wait(0)
			if shared.gPlayerSlept == true then
				F_PlayerHasSleptInBed()
				shared.gPlayerSlept = false
			end
			if bLaunchPrincipalMission == true and not MissionActive() then
				--print("WTFFFF F_FireOffPrincipalCutscene")
				bLaunchPrincipalMission = false
				F_FireOffPrincipalCutscene()
			elseif bPoliceDropPlayerOffNIS and not MissionActive() then
				F_MakePlayerSafeForNIS(true)
				PlayerSetControl(0)
				PedSetEffectedByGravity(gPlayer, false)
				AreaForceLoadAreaByAreaTransition(true)
				AreaTransitionPoint(0, POINTLIST._BUS_POLICEDROPPLAYER, 1, true)
				AreaForceLoadAreaByAreaTransition(false)
				while not (PedRequestModel(83) and VehicleRequestModel(295)) do
					Wait(0)
				end
				PedSetEffectedByGravity(gPlayer, true)
				shared.veh1 = VehicleCreatePoint(295, POINTLIST._BUS_POLICEDROP, 1)
				shared.ped1 = PedCreateXYZ(97, 314.7, -74.2, 5.1)
				PedIgnoreStimuli(shared.ped1, true)
				PedSetAsleep(shared.ped1, true)
				PedSetCheap(shared.ped1, true)
				PedWarpIntoCar(shared.ped1, shared.veh1)
				CameraSetXYZ(319.469, -81.274, 7.435, 312.42, -78.77, 6.33)
				CameraSetWidescreen(true)
				Wait(1000)
				PedStop(gPlayer)
				CameraFade(1000, 1)
				Wait(1000)
				PedFollowPath(gPlayer, PATH._BUS_POLICEPATH, 0, 0)
				SoundPlayScriptedSpeechEvent(shared.ped1, "WARNING_MINOR_INFRACTION", 0, "supersize")
				Wait(2000)
				VehicleMoveToXYZ(shared.veh1, 326.7, -108.2, 6.2, 10)
				Wait(2000)
				PedStop(gPlayer)
				VehicleDelete(shared.veh1)
				CameraReturnToPlayer(false)
				CameraSetWidescreen(false)
				F_MakePlayerSafeForNIS(false)
				PlayerSetControl(1)
				bPoliceDropPlayerOffNIS = false
			end
			if bSentToClass == true and not MissionActive() then
				bSentToClass = false
				shared.bBustedClassLaunched = true
				PlayerSetPunishmentPoints(0)
				MissionStartNextClass(true)
				UnpauseGameClock()
			end
			if GetTotalMissionSuccessCount() > gNumMissionsPassed then
				--print("Checking if factions need to change.")
				--print("Reverting models")
				F_MissionFactionChanges()
				F_MissionCompleteModelChanges()
				gNumMissionsPassed = GetTotalMissionSuccessCount()
			end
		end
		F_BMXGarage()
	end
end

function F_StartAlarm()
	if AreaGetVisible() == 14 and shared.gBDormFAlarmOn == false then
		shared.gBDormFAlarmOn = true
		shared.gAlarmOn = true
		SoundStartFireAlarm()
	end
	if AreaGetVisible() == 2 and shared.gSchoolFAlarmOn == false then
		shared.gSchoolFAlarmOn = true
		shared.gAlarmOn = true
		SoundStartFireAlarm()
	end
	if AreaGetVisible() == 35 and shared.gGDormFAlarmOn == false then
		shared.gGDormFAlarmOn = true
		shared.gAlarmOn = true
		SoundStartFireAlarm()
	end
end

function F_AlarmThread() -- ! Modified
	while true do
		if shared.gAlarmOn == true then
			local GameTime = GetTimer()
			--[[
			local AlarmTime = GetTimer()
			]] -- Modified to:
			local AlarmTime = 0
			while GetCutsceneRunning() == 0 and AlarmTime - GameTime < shared.gSchoolFAlarmTime do
				Wait(0)
				--DebugPrint("ALARM TIME: " .. AlarmTime - GameTime)
				AlarmTime = GetTimer()
			end
			--DebugPrint("ALARM OFF: " .. AlarmTime - GameTime)
			SoundStopFireAlarm()
			bAlarmOn = false
			shared.gAlarmOn = false
			shared.gBDormFAlarmOn = false
			shared.gSchoolFAlarmOn = false
			shared.gGDormFAlarmOn = false
		end
		Wait(0)
	end
end

function F_LoadPlayer()
	PlayerCreateXYZ(gPlayerStartX, gPlayerStartY, gPlayerStartZ)
	CameraReset()
	gPlayer = PlayerGetPedIndex()
	CameraSetHeading(180)
	PedSetMoney(gPlayer, 5000)
	ClothingOverlay(true)
	ImportScript("SCloth.lua")
	ClothingGivePlayerOutfit("Underwear", false)
	ClothingGivePlayerOutfit("Starting", false)
	ClothingGivePlayerOutfit("PJ")
	ClothingGivePlayerOutfit("Uniform")
	ClothingSetPlayersHair(shared.gDefaultHead)
	ClothingSetPlayerOutfit("Starting", true)
	ClothingBuildPlayer()
	ClothingOverlay(false)
end

function F_LoadTime()
	ClockSet(gGameStartHour, gGameStartMinute)
	WeatherSet(0)
	WeatherRelease()
	ClockSetTickRate(60, 30)
end

--[[
function F_TestObjectCreate()
	local x, y, z, yaw, pitch, roll
end

function F_TestPrint()
	TextPrintString("I'm Alive!!!", 4)
end

function F_TestText()
	TextAddParamNum(102)
	TextAddParamNum(1.5)
	TextAddParamNum(2.3)
	TextAddParamNum(2)
	TextAddParamNum(3)
	TextAddParamNum(1)
	TextAddParamString("TEST_04")
	TextAddParamString("TEST_05")
	TextPrintF("TEST_03", 60)
end
]] -- Not present in original script

function FadeIn()
	while MissionFadeIn() do
		Wait(0)
	end
end

function FadeOut()
	while MissionFadeOut() do
		Wait(0)
	end
end

function F_CherryBomb()
	if AreaGetVisible() == 2 then
		shared.gSchoolToilet = true
	elseif AreaGetVisible() == 13 then
		shared.gGymToilet = true
	elseif AreaGetVisible() == 35 then
		shared.gGDormToilet = true
	end
end

function F_CowDance()
	if not MinigameIsShowingCompletion() then
		bDanceThatCow = true
	end
end

function F_SetupGiftRequirements()
	PedModelCreateGiftRequirement(67, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(181, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(90, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(39, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(180, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(166, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(74, 1, "1_02B", 0, true, 100)
	PedModelCreateGiftRequirement(3, 2, "1_08", 0, true, 100)
	PedModelCreateGiftRequirement(95, 2, "1_08", 0, true, 100)
	PedModelCreateGiftRequirement(25, 2, "3_G3", 0, true, 100)
	PedModelCreateGiftRequirement(96, 2, "3_G3", 0, true, 100)
	PedModelCreateGiftRequirement(14, 2, "4_G4", 0, true, 100)
	PedModelCreateGiftRequirement(93, 2, "4_G4", 0, true, 100)
	PedModelCreateGiftRequirement(38, 2, "2_G2", 0, true, 100)
	PedModelCreateGiftRequirement(182, 2, "2_G2", 0, true, 100)
	PedModelCreateGiftRequirement(167, 2, "2_G2", 0, true, 100)
	PedModelCreateGiftRequirement(2, 2, "5_G5", 0, true, 100)
	PedModelCreateGiftRequirement(9, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(13, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(44, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(30, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(27, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(85, 2, "C_Art_1", 0, true, 100)
	PedModelCreateGiftRequirement(75, 22, "1_B", 0, true, 100)
	PedModelCreateGiftRequirement(22, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(24, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(29, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(26, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(28, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(31, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(35, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(32, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(34, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(40, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(5, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(4, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(7, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(224, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(8, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(11, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(15, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(16, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(17, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(18, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(20, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(102, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(99, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(145, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(146, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(147, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(44, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(42, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(41, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(43, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(45, 22, 0, 0, true, 30)
	PedModelCreateGiftRequirement(46, 22, 0, 0, true, 30)
end

function F_SetupExtraKOPoints()
	if not shared.extraKOPointsAdded and shared.extraKOPoints then
		shared.extraKOPointsAdded = true
		shared.extraKOPoints = false
		SetDefaultArrestPoint(POINTLIST._RESTART_B_PS, 0)
		SetDefaultArrestRestartCameraPos(POINTLIST._RESTART_B_PS_CAM)
		AddArrestRestartPoint(POINTLIST._KO_SCHOOL_INFIRMOUT, 0, 8, 19, POINTLIST._ARREST_RESTART_1, 2)
		AddArrestRestartPoint(POINTLIST._KO_SCHOOL_INFIRMOUT, 0, 19, 8, POINTLIST._BOYSDORM_BEDWAKEUP, 14)
		AddInteriorArrestRestartPoint(2, POINTLIST._ARREST_RESTART_1, 2, 8, 19)
		AddInteriorArrestRestartPoint(2, POINTLIST._BOYSDORM_BEDWAKEUP, 14, 19, 8)
		local schoolTrans = {
			9,
			35,
			13,
			59,
			15,
			8,
			40,
			32,
			23
		}
		for i, lArea in schoolTrans do
			AddInteriorArrestRestartPoint(lArea, POINTLIST._ARREST_RESTART_1, 2, 8, 19)
			AddInteriorArrestRestartPoint(lArea, POINTLIST._BOYSDORM_BEDWAKEUP, 14, 19, 8)
		end
	end
	if shared.updateDefaultKOPoint then
		shared.updateDefaultKOPoint = false
		SetDefaultKOPoint(POINTLIST._RESTART_B_HS, 0)
		SetDefaultKORestartCameraPos(POINTLIST._RESTART_B_HS_CAM)
	end
end

function F_SetupKOPoints()
	if ChapterGet() == 0 then
		SetDefaultKOPoint(POINTLIST._KO_SCHOOL_INFIRMOUT, 0)
		SetDefaultKORestartCameraPos(POINTLIST._KO_SCHOOL_INFIRMOUT_CAM)
	else
		SetDefaultKOPoint(POINTLIST._RESTART_B_HS, 0)
		SetDefaultKORestartCameraPos(POINTLIST._RESTART_B_HS_CAM)
	end
	if IsMissionCompleated("1_02C") then
		SetDefaultArrestPoint(POINTLIST._RESTART_B_PS, 0)
		SetDefaultArrestRestartCameraPos(POINTLIST._RESTART_B_PS_CAM)
		AddArrestRestartPoint(POINTLIST._KO_SCHOOL_INFIRMOUT, 0, 8, 19, POINTLIST._ARREST_RESTART_1, 2)
		AddArrestRestartPoint(POINTLIST._KO_SCHOOL_INFIRMOUT, 0, 19, 8, POINTLIST._BOYSDORM_BEDWAKEUP, 14)
	else
		SetDefaultArrestPoint(POINTLIST._KO_SCHOOL_INFIRMOUT, 0)
		SetDefaultArrestRestartCameraPos(POINTLIST._KO_SCHOOL_INFIRMOUT_CAM)
	end
	AddKORestartPoint(POINTLIST._KO_SCHOOL_INFIRMOUT, 0)
	AddKORestartPoint(POINTLIST._RESTART_RC_HS, 0)
	AddKORestartPoint(POINTLIST._RESTART_R_HS, 0)
	AddKORestartPoint(POINTLIST._RESTART_B_HS, 0)
	AddKORestartPoint(POINTLIST._RESTART_P_HS, 0)
	AddArrestRestartPoint(POINTLIST._RESTART_R_PS, 0)
	AddArrestRestartPoint(POINTLIST._RESTART_B_PS, 0)
	AddArrestRestartPoint(POINTLIST._RESTART_P_PS, 0)
	local schoolTrans = {
		9,
		35,
		13,
		59,
		15,
		8,
		40,
		32,
		23
	}
	for i, lArea in schoolTrans do
		AddInteriorKORestartPoint(lArea, POINTLIST._KO_SCHOOL_INFIRMOUT, 0)
		if IsMissionCompleated("1_02C") then
			AddInteriorArrestRestartPoint(lArea, POINTLIST._ARREST_RESTART_1, 2, 8, 19)
			AddInteriorArrestRestartPoint(lArea, POINTLIST._BOYSDORM_BEDWAKEUP, 14, 19, 8)
		end
		if lArea ~= 59 then
			AddInteriorAsleepRestartPoint(lArea, POINTLIST._KO_SCHOOL_INFIRMOUT, 0)
		end
	end
	if IsMissionCompleated("1_02C") then
		AddInteriorArrestRestartPoint(2, POINTLIST._ARREST_RESTART_1, 2, 8, 19)
		AddInteriorArrestRestartPoint(2, POINTLIST._BOYSDORM_BEDWAKEUP, 14, 19, 8)
	end
	AddInteriorKORestartPoint(14, POINTLIST._BOYSDORM_BEDWAKEUP, 14)
	AddInteriorKORestartPoint(2, POINTLIST._KO_RESTART_1, 2, 8, 19)
	AddInteriorKORestartPoint(2, POINTLIST._KO_SCHOOL_INFIRMOUT, 0, 19, 8)
	AddInteriorAsleepRestartPoint(14, POINTLIST._BOYSDORM_BEDWAKEUP, 14)
	AddInteriorAsleepRestartPoint(2, POINTLIST._KO_SCHOOL_INFIRMOUT, 0)
	SetAsleepRestartPointCameraPos(POINTLIST._KO_SCHOOL_INFIRMOUT, POINTLIST._KO_SCHOOL_INFIRMOUT_CAM)
	SetAsleepRestartPointCameraPos(POINTLIST._BOYSDORM_BEDWAKEUP, POINTLIST._BOYSDORM_BEDWAKEUP_CAM)
	local richAreaInteriors = {
		46,
		28,
		33,
		50,
		45,
		27
	}
	for i, lArea in richAreaInteriors do
		AddInteriorKORestartPoint(lArea, POINTLIST._RESTART_R_HS, 0)
		AddInteriorArrestRestartPoint(lArea, POINTLIST._RESTART_R_PS, 0)
		AddInteriorAsleepRestartPoint(lArea, POINTLIST._RESTART_R_HS, 0)
	end
	local carnivalInteriors = { 55, 37 }
	for i, lArea in carnivalInteriors do
		AddInteriorKORestartPoint(lArea, POINTLIST._RESTART_RC_HS, 0)
		AddInteriorArrestRestartPoint(lArea, POINTLIST._RESTART_R_PS, 0)
		AddInteriorAsleepRestartPoint(lArea, POINTLIST._RESTART_RC_HS, 0)
	end
	SetAsleepRestartPointCameraPos(POINTLIST._RESTART_R_HS, POINTLIST._RESTART_R_HS_CAM)
	local businessAreaInteriors = {
		39,
		29,
		26,
		34,
		56
	}
	for i, lArea in businessAreaInteriors do
		AddInteriorKORestartPoint(lArea, POINTLIST._RESTART_B_HS, 0)
		AddInteriorArrestRestartPoint(lArea, POINTLIST._RESTART_B_PS, 0)
		AddInteriorAsleepRestartPoint(lArea, POINTLIST._RESTART_B_HS, 0)
	end
	SetAsleepRestartPointCameraPos(POINTLIST._RESTART_B_HS, POINTLIST._RESTART_B_HS_CAM)
	if IsMissionCompleated("4_B2") then
		shared.indusrtialRestartPointsAdded = true
		AddKORestartPoint(POINTLIST._RESTART_I_HS, 0)
		AddArrestRestartPoint(POINTLIST._RESTART_I_PS, 0)
		local industrialAreaInteriors = {
			20,
			16,
			54
		}
		for i, lArea in industrialAreaInteriors do
			AddInteriorKORestartPoint(lArea, POINTLIST._RESTART_I_HS, 0)
			AddInteriorArrestRestartPoint(lArea, POINTLIST._RESTART_I_PS, 0)
			AddInteriorAsleepRestartPoint(lArea, POINTLIST._RESTART_I_HS, 0)
		end
		SetAsleepRestartPointCameraPos(POINTLIST._RESTART_I_HS, POINTLIST._RESTART_I_HS_CAM)
		SetKORestartPointCameraPos(POINTLIST._RESTART_I_HS, POINTLIST._RESTART_I_HS_CAM)
		SetArrestRestartPointCameraPos(POINTLIST._RESTART_I_PS, POINTLIST._RESTART_I_PS_CAM)
	end
	local poorAreaInteriors = {
		43,
		36,
		62
	}
	for i, lArea in poorAreaInteriors do
		AddInteriorKORestartPoint(lArea, POINTLIST._RESTART_P_HS, 0)
		AddInteriorArrestRestartPoint(lArea, POINTLIST._RESTART_P_PS, 0)
		AddInteriorAsleepRestartPoint(lArea, POINTLIST._RESTART_P_HS, 0)
	end
	SetAsleepRestartPointCameraPos(POINTLIST._RESTART_P_HS, POINTLIST._RESTART_P_HS_CAM)
	AddInteriorArrestRestartPoint(38, POINTLIST._ARREST_ASYLUM, 0)
	AddInteriorKORestartPoint(38, POINTLIST._ARREST_ASYLUM, 0)
	AddInteriorAsleepRestartPoint(61, POINTLIST._WAKE_GRSR, 61)
	AddInteriorAsleepRestartPoint(60, POINTLIST._WAKE_PREP, 60)
	AddInteriorAsleepRestartPoint(59, POINTLIST._WAKE_JOCK, 59)
	AddInteriorAsleepRestartPoint(57, POINTLIST._WAKE_DROP, 57)
	AddInteriorAsleepRestartPoint(30, POINTLIST._WAKE_NERD, 30)
	SetKORestartPointCameraPos(POINTLIST._BOYSDORM_BEDWAKEUP, POINTLIST._BOYSDORM_BEDWAKEUP_CAM)
	SetKORestartPointCameraPos(POINTLIST._KO_RESTART_1, POINTLIST._KO_RESTART_1_CAM)
	SetKORestartPointCameraPos(POINTLIST._KO_SCHOOL_INFIRMOUT, POINTLIST._KO_SCHOOL_INFIRMOUT_CAM)
	SetKORestartPointCameraPos(POINTLIST._RESTART_B_HS, POINTLIST._RESTART_B_HS_CAM)
	SetKORestartPointCameraPos(POINTLIST._RESTART_P_HS, POINTLIST._RESTART_P_HS_CAM)
	SetKORestartPointCameraPos(POINTLIST._RESTART_R_HS, POINTLIST._RESTART_R_HS_CAM)
	SetKORestartPointCameraPos(POINTLIST._RESTART_RC_HS, POINTLIST._RESTART_RC_HS_CAM)
	SetArrestRestartPointCameraPos(POINTLIST._ARREST_RESTART_1, POINTLIST._ARREST_RESTART_1_CAM)
	SetArrestRestartPointCameraPos(POINTLIST._KO_SCHOOL_INFIRMOUT, POINTLIST._KO_SCHOOL_INFIRMOUT_CAM)
	SetArrestRestartPointCameraPos(POINTLIST._BOYSDORM_BEDWAKEUP, POINTLIST._BOYSDORM_BEDWAKEUP_CAM)
	SetArrestRestartPointCameraPos(POINTLIST._RESTART_B_PS, POINTLIST._RESTART_B_PS_CAM)
	SetArrestRestartPointCameraPos(POINTLIST._RESTART_P_PS, POINTLIST._RESTART_P_PS_CAM)
	SetArrestRestartPointCameraPos(POINTLIST._RESTART_R_PS, POINTLIST._RESTART_R_PS_CAM)
end

function F_CoasterEndCameraReset()
	CameraResetToPosition(137.13, 477.81, 9.44, false)
end

local gBusBlips = {
	{
		587.42194,
		-47.2647,
		5.93573
	},
	{
		515.269,
		-286.39398,
		2.57543
	},
	{
		493.59296,
		-458.051,
		3.3167498
	},
	{
		460.68997,
		244.34598,
		10.624599
	},
	{
		304.5496,
		269.875,
		5.4026966
	},
	{
		397.561,
		498.682,
		22.243998
	},
	{
		536.534,
		418.006,
		17.1165
	},
	{
		257.24396,
		-418.91998,
		2.55686
	},
	{
		125.67199,
		-376.405,
		2.2665598
	}
}

function F_BusPoints()
	if shared.addBusPoints then
		for _, busBlip in gBusBlips do
			busBlip.id = BlipAddXYZ(busBlip[1], busBlip[2], busBlip[3], 28)
			--print(">>>[RUI]", "++bus blip add " .. tostring(busBlip.id))
		end
		RadarBusBlipSetVisible(true)
		shared.addBusPoints = nil
		bBusStopsDisabled = false
	end
	if shared.gDisableBusStops then
		if not bBusStopsDisabled then
			RadarBusBlipSetVisible(false)
			--print(">>>[RUI]", "Kill bus blips")
			shared.addBusPoints = nil
			bBusStopsDisabled = true
		end
	elseif bBusStopsDisabled then
		--print(">>>[RUI]", "recreate Bus Blips")
		RadarBusBlipSetVisible(true)
		shared.addBusPoints = nil
		bBusStopsDisabled = false
	end
end

function F_GarageBlips()
	if not gBlipsAdded and GarageHasStoredVehicle() then
		gBlipsAdded = true
		local b1 = BlipAddXYZ(153.704, -14.1309, 6.25, 9)
		local b2 = BlipAddXYZ(475.653, -74.7202, 5.53, 9)
		local b3 = BlipAddXYZ(343.649, 275.255, 6.368, 9)
		local b4 = BlipAddXYZ(458.54, -453.336, 2.89, 9)
		local b5 = BlipAddXYZ(-779.257, 726.342, 20.6265, 9)
		BlipSetShortRanged(b1, true)
		BlipSetShortRanged(b2, true)
		BlipSetShortRanged(b3, true)
		BlipSetShortRanged(b4, true)
		BlipSetShortRanged(b5, true)
	end
end

function F_SavePoints()
	if shared.nerdsSave then
		BlipAddSave(-734.541, 36.0908, -1.27256)
		shared.nerdsSave = nil
	end
	if shared.prepsSave then
		BlipAddSave(-778.246, 359.016, 7.586)
		shared.prepsSave = nil
	end
	if shared.jocksSave then
		BlipAddSave(-740.92, 348.823, 4.4936)
		shared.jocksSave = nil
	end
	if shared.greasersSave then
		BlipAddSave(-697.063, 353.672, 4.499)
		shared.greasersSave = nil
	end
	if shared.dropoutsSave then
		BlipAddSave(-653.805, 247.713, 16.223)
		shared.dropoutsSave = nil
	end
	if shared.schoolSave then
		if not gSchoolSaveBlip then
			gSchoolSaveBlip = BlipAddSave(-633.252, -291.458, 5.52505)
		end
		shared.schoolSave = nil
	end
	gCurrentHour, gCurrentMinute = ClockGet()
	if gSchoolSaveBlip then
		if 19 <= gCurrentHour or gCurrentHour < 8 then
			BlipRemove(gSchoolSaveBlip)
			gSchoolSaveBlip = nil
		end
	elseif gCurrentHour < 19 and (8 <= gCurrentHour or gCurrentHour == 8 and 0 < gCurrentMinute) then
		shared.schoolSave = true
	end
end

function F_BlipSavePoints()
	local x, y, z = GetPointFromPointList(POINTLIST._SAVEPOINTBDORM, 1)
	gBoysDormSaveBlipID = BlipAddSave(x, y, z)
	if IsMissionCompleated("3_R09_N") then
		shared.nerdsSave = true
	end
	if IsMissionCompleated("3_R09_P3") then
		shared.prepsSave = true
	end
	if IsMissionCompleated("3_R09_J3") then
		shared.jocksSave = true
	end
	if IsMissionCompleated("3_R09_G3") then
		shared.greasersSave = true
	end
	if IsMissionCompleated("3_R09_D3") then
		shared.dropoutsSave = true
	end
	if IsMissionCompleated("1_02A") then
		shared.schoolSave = true
	end
end

function F_CreateHalloweenItems() -- ! Modified
	if IsMissionCompleated("1_11_Dummy") or not IsMissionCompleated("1_05") then
		--print("Halloween is not active, cancelling everything.")
		if shared.gHCriminalsActive == true then
			--print("HALLOWEEN CRIMINALS DEACTIVATED")
			shared.gHCriminalsActive = false
		end
		return
	end
	if IsMissionCompleated("1_07") and IsMissionCompleated("1_08") then
		AreaLoadSpecialEntities("Halloween1", true)
	end
	if IsMissionCompleated("1_09") then
		AreaLoadSpecialEntities("Halloween2", true)
		if not IsMissionCompleated("1_11xp") then
			PauseGameClock()
		end
	end
	if IsMissionCompleated("1_11x1") then
		--print("Setting up the halloween models.")
		shared.gHalloweenActive = true
		AreaLoadSpecialEntities("Halloween3", true)
		AreaDisableAllPatrolPaths()
		F_SetupHallowenPeds(true)
	end
	--[[
	if IsMissionCompleated("1_11xP") and IsMissionAvailable("1_11x2") == false then
		AreaEnableAllPatrolPaths()
	end
	]] -- Not present in original script
end

function F_CreateChristmasItems()
	if IsMissionCompleated("3_08") or not IsMissionCompleated("Chapt2Trans") and not MissionActiveSpecific("Chapt2Trans") then
		return
	end
	AreaLoadSpecialEntities("Christmas", true)
end

function F_HandleLoadGame() -- ! Modified
	--[[
	CollectiblesSetTypeAvailable(1, false)
	CollectiblesSetTypeAvailable(0, false)
	]] -- Removed this
	if IsMissionCompleated("4_03") then
		ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBoxSprayCan")
		ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateSpudGuns")
		ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateSpudGuns")
	elseif IsMissionCompleated("4_B1") then
		ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBoxSprayCan")
		ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateBRockets")
		ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateBRockets")
	elseif IsMissionCompleated("3_S10") then
		ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBoxSprayCan")
		ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateSprayCan")
		ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateSprayCan")
	elseif IsMissionCompleated("1_02C") then
		ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBox")
		ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrate")
		ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrate")
	end
	if IsMissionCompleated("1_02C") then
		DATLoad("Pickups.DAT", 1)
	end
	if IsMissionCompleated("C_Geography_2") then
		CollectibleOnMapEnable(2, true)
	end
	if IsMissionCompleated("C_Geography_3") then
		CollectibleOnMapEnable(3, true)
	end
	if IsMissionCompleated("C_Geography_4") then
		CollectibleOnMapEnable(1, true)
	end
	if IsMissionCompleated("C_Geography_5") then
		CollectibleOnMapEnable(0, true)
	end
	if IsMissionCompleated("1_10") then
		--print("pumpkins and tombstones are being created!!!")
		AreaLoadSpecialEntities("TombstonePost", true)
		AreaLoadSpecialEntities("PumpkinPost", true)
	end
	if IsMissionCompleated("1_06_01") then
		--print("1_06_01 DATA LOADING!!")
		CollectiblesSetTypeAvailable(1, true)
	end
	--[[
	if IsMissionCompleated("2_GN") then
		--print("2_S07 DATA LOADING!!")
		CollectiblesSetTypeAvailable(0, true)
	end
	]] -- Removed this
	if IsMissionCompleated("5_02") and IsMissionCompleated("6_01_Launch") and not IsMissionCompleated("6_01") then
		--print("Creating Expelled thread!")
		CreateThread("T_ExpelledLogic")
	end
	if IsMissionCompleated("Chapt2Trans") and IsMissionCompleated("3_08_Launch") and not IsMissionCompleated("3_08") then
		--print("Creating Christmas thread!")
		CreateThread("T_ChristmasdLogic")
	end
	F_CreateHalloweenItems()
	F_CreateChristmasItems()
	if IsMissionCompleated("1_B") then
		--print("1_B Passed")
		shared.addBusPoints = true
	end
	if IsMissionCompleated("2_09") and not IsMissionCompleated("2_B") then
		--print("Should be snowing!")
		WeatherForceSnow(true)
		WeatherSet(2)
	elseif IsMissionCompleated("6_B") then
		--print("Should be sunny!!")
		WeatherSet(4)
	end
	if IsMissionCompleated("1_02C") then
		--print("Ambient pickups need to be loaded...")
		DATLoad("Pickups.DAT", 1)
	end
end

function F_FireOffPrincipalCutscene()
	SoundStopPA()
	StatAddToInt(155)
	if not IsMissionAvailable("6_01") then
		ForceStartMission("PriOff")
	else
		ForceStartMission("6_01")
	end
end

function F_PlayerBusted(bBusted)
	AreaCancelStoredTransition()
	if bBusted then
		StatAddToInt(3)
		if PlayerIsInTrigger(TRIGGER._AMB_SCHOOL_AREA) or AreaGetVisible() == 14 or AreaGetVisible() == 9 or AreaGetVisible() == 35 or AreaGetVisible() == 2 or AreaGetVisible() == 13 then
			if IsMissionCompleated("1_02C") then
				if not bLaunchPrincipalMission then
					bDontFadeIn = false
				end
				local hour, minute = ClockGet()
				local timesBusted = PlayerGetScriptSavedData(3) + 1
				local bExecPrincipalCutscene = false
				local bClassAvailable = F_ClassIsAvailable()
				--print("bClassAvailable: ", tostring(bClassAvailable))
				if not bClassAvailable then
					PlayerSetScriptSavedData(3, timesBusted)
					if 7 <= hour and hour < 19 and (2 < timesBusted - gPreviousBustedCount or timesBusted == 1) then
						if not IsMissionCompleated("BUSTPREFNOCLASS") then
							TutorialStart("BUSTPREFNOCLASS")
						end
						--print("+========================== SEND TO PRINCIPAL ==========================+")
						gPreviousBustedCount = timesBusted
						bLaunchPrincipalMission = true
						SystemBustedAreaTransitionHandled()
						PlayerSetScriptSavedData(24, timesBusted)
						return
					end
					--print("+========================== NOT SENT TO PRINCIPALS ==========================+")
					return
				elseif bClassAvailable then
					if not IsMissionCompleated("BUSTPREFCLASS") then
						TutorialStart("BUSTPREFCLASS")
					end
					--print("+========================== SENT TO CLASS ==========================+")
					PauseGameClock()
					bSentToClass = true
					SystemBustedAreaTransitionHandled()
					return
				end
			else
				--print("+========================== 1_02C!! ==========================+")
				return
			end
		else
			if not IsMissionCompleated("LOSEWEAPONS") and (PedGetFlag(gPlayer, 103) or PedGetFlag(gPlayer, 104)) then
				TutorialStart("LOSEWEAPONS")
			end
			if not IsMissionCompleated("BUSTCOPS") and not PedGetFlag(gPlayer, 103) and not PedGetFlag(gPlayer, 104) then
				TutorialStart("BUSTCOPS")
			end
			if PedGetFlag(gPlayer, 103) or PedGetFlag(gPlayer, 104) then
				SystemBustedAreaTransitionHandled()
				bPoliceDropPlayerOffNIS = true
				--print("")
			end
			--print("+========================== PLAYER WAS BUSTED OUTSIDE OF SCHOOL!! ==========================+")
			return
		end
	else
		--print("Player has been knocked out!")
		if PlayerFellAsleep() then
			PedDismissAllAllies(gPlayer)
			if AreaGetVisible() == 0 then
				if not IsMissionCompleated("PASSEDOUT") then
					TutorialStart("PASSEDOUT")
				end
			elseif not IsMissionCompleated("CLOCKTUTX") then
				TutorialStart("CLOCKTUTX")
			end
			--print("+========================== PLAYER FELL ASLEEP!! ==========================+")
		else
			if AreaGetVisible() ~= 14 then
				if IsMissionCompleated("1_02C") then
					if MissionActive() then
						if not IsMissionCompleated("KNOCKEDOUT") then
							TutorialStart("KNOCKEDOUT")
						end
					elseif not IsMissionCompleated("REDX1") then
						TutorialStart("REDX1")
					end
				end
			elseif IsMissionCompleated("1_02C") and not IsMissionCompleated("ART2X") then
				TutorialStart("ART2X")
			end
			shared.playerKOd = true
			--print("+========================== PLAYER WAS KNOCKED OUT!! ==========================+")
		end
		return
	end
end

function F_CheckForOutfit()
	if ClothingIsWearingAnyOutfit() then
		return 1
	end
	return 0
end

function F_WakeupInStreet()
	--print("YOUR ASS IN THE STREET")
	local ClockFlag = false
	local ClockHour, ClockHour, ClockMinute
	F_ProcessWakeUpMissionBasedLogic()
	if ClothingIsWearingAnyOutfit() == false and AreaGetVisible() == 0 and not MissionActive() then
		shared.gStreetWakeCount = shared.gStreetWakeCount + 1
		if shared.gStreetWakeCount < 3 or shared.gStreetWakeCount > 3 and 3 > math.random(1, 3) then
			ClothingSetPlayer(5, "SP_Socks")
		else
			ClothingSetPlayerOutfit("Underwear")
		end
		ClothingBuildPlayer()
	end
	bWakingUp = true
end

function CB_YearbookPhotoMain(pedId)
	if GetTimer() - photoTime < 10 then
		photoAmount = photoAmount + 1
	else
		photoAmount = 1
	end
	photoTime = GetTimer()
	if (not PhotoIsSetValid() or shared.photoClass01) and not shared.inPhotoMission then
		if 2 <= photoAmount then
			PhotoSetValid(true, "PHO_MYEARBK", PedGetName(pedId))
		else
			PhotoSetValid(true, "PHO_YEARBK", PedGetName(pedId))
		end
	end
	F_UnlockYearbookReward()
end

function T_PhotographyStimulus()
	local CameraTarget
	while true do
		if WeaponEquipped(328) or WeaponEquipped(426) then
			if CameraGetActive() == 2 then
				PhotoGetEntityStart()
				repeat
					photoEntity, photoType = PhotoGetEntityNext()
					if photoType == 2 then
						PedCreateStimulus(gPlayer, photoEntity, 65)
					end
					Wait(500)
				until photoEntity == -1
				Wait(1500)
			elseif IsButtonPressed(10, 0) then
				CameraTarget = PedGetTargetPed(gPlayer)
				if PedIsValid(CameraTarget) and not PedIsSocializing(gPlayer) and not PedIsWantingToSocialize(CameraTarget) then
					PedCreateStimulus(gPlayer, CameraTarget, 65)
					Wait(2000)
				end
			end
		end
		Wait(0)
	end
end

function CB_CollectibleCollected(CollectibleType, NumOfCollectedOfType, MaxNumCollectableOfType, UID, PickupID, CollectibleIndex) -- ! Modified
	if CollectibleType == 4 and not shared.bUnlockPumpkinMask and NumOfCollectedOfType == MaxNumCollectableOfType then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_ALL_PUMPKINS")
		MinigameSetUberCompletion()
		ClothingGivePlayer("SP_Pumpkin_head", 0)
		shared.bUnlockPumpkinMask = true
		MiniObjectiveSetIsComplete(3)
	end
	if CollectibleType == 5 and not shared.bUnlockEdnaMask and NumOfCollectedOfType == MaxNumCollectableOfType then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_ALL_TOMBSTONES")
		MinigameSetUberCompletion()
		ClothingGivePlayer("SP_EdnaMask", 0)
		MiniObjectiveSetIsComplete(4)
		shared.bUnlockEdnaMask = true
	end
	if CollectibleType == 0 and not shared.bUnlockGnomeOutfit and NumOfCollectedOfType == MaxNumCollectableOfType then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_GNOMES_REWARD")
		MinigameSetUberCompletion()
		ClothingGivePlayerOutfit("Gnome")
		MiniObjectiveSetIsComplete(5)
		shared.bUnlockGnomeOutfit = true
	end
	if CollectibleType == 2 and not shared.bRubberBandsCollected and NumOfCollectedOfType == MaxNumCollectableOfType then
		GiveWeaponToPlayer(325)
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_ALL_RUBBERBANDS")
		MinigameSetUberCompletion()
		--[[
		MiniObjectiveSetIsComplete(17)
		]] -- Modified to:
		MiniObjectiveSetIsComplete(18)
		shared.bRubberBandsCollected = true
	end
	if CollectibleType == 3 and not shared.bUnlockGGOutfit and NumOfCollectedOfType == MaxNumCollectableOfType then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_CARDS_REWARD")
		MinigameSetUberCompletion()
		ClothingGivePlayerOutfit("Grotto Master")
		shared.bUnlockGGOutfit = true
		MiniObjectiveSetIsComplete(6)
	end
	F_CheckAllCollectibles()
end

function F_CheckAllCollectibles() -- ! Modified
	--[[
	if not MiniObjectiveGetIsComplete(12) and CollectiblesGetNumCollectable(3) == CollectiblesGetNumCollected(3) and CollectiblesGetNumCollectable(0) == CollectiblesGetNumCollected(0) and CollectiblesGetNumCollectable(2) == CollectiblesGetNumCollected(2) and CollectiblesGetNumCollectable(5) == CollectiblesGetNumCollected(5) and CollectiblesGetNumCollectable(4) == CollectiblesGetNumCollected(4) and CollectiblesGetNumCollectable(1) == CollectiblesGetNumCollected(1) then
	]] -- Modified to:
	if not MiniObjectiveGetIsComplete(13) and CollectiblesGetNumCollectable(3) == CollectiblesGetNumCollected(3) and CollectiblesGetNumCollectable(0) == CollectiblesGetNumCollected(0) and CollectiblesGetNumCollectable(2) == CollectiblesGetNumCollected(2) and CollectiblesGetNumCollectable(5) == CollectiblesGetNumCollected(5) and CollectiblesGetNumCollectable(4) == CollectiblesGetNumCollected(4) and CollectiblesGetNumCollectable(1) == CollectiblesGetNumCollected(1) then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_CONQUEROR")
		MinigameSetUberCompletion()
		--[[
		MiniObjectiveSetIsComplete(12)
		]] -- Modified to:
		MiniObjectiveSetIsComplete(13)
	end
end

function CB_MiniObjectiveCompleted(MiniObjectiveType) -- ! Modified
	--print("Mini Objective Completed ", tostring(MiniObjectiveType))
	if MiniObjectiveType == 0 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_ARCADE_MASTER")
		MinigameSetUberCompletion()
	elseif MiniObjectiveType == 1 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_POP_JUNKY")
		MinigameSetUberCompletion()
	elseif MiniObjectiveType == 2 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_POP_FRENZY")
		MinigameSetUberCompletion()
		ClothingGivePlayer("SP_Pophat", 0)
		--[[
	elseif MiniObjectiveType == 7 then
	]] -- Modified to:
	elseif MiniObjectiveType == 8 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_FIRE_CHIEF")
		MinigameSetUberCompletion()
		ClothingGivePlayer("SP_Firehat", 0)
		--[[
	elseif MiniObjectiveType == 8 then
	]] -- Modified to:
	elseif MiniObjectiveType == 9 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_BIKE_TREK")
		MinigameSetUberCompletion()
		ClothingGivePlayer("SP_BikeShorts", 4)
		--[[
	elseif MiniObjectiveType == 9 then
	]] -- Modified to:
	elseif MiniObjectiveType == 10 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_MARATHON_BOY")
		MinigameSetUberCompletion()
		ClothingGivePlayer("SP_Shorts", 4)
		--[[
	elseif MiniObjectiveType == 10 then
	]] -- Modified to:
	elseif MiniObjectiveType == 11 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_BOY_GENIUS")
		MinigameSetUberCompletion()
		ClothingGivePlayer("SP_MortarBhat", 0)
		--[[
	elseif MiniObjectiveType == 11 then
	]] -- Modified to:
	elseif MiniObjectiveType == 12 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_JIMMY_SLOW")
		MinigameSetUberCompletion()
		ClothingGivePlayer("SP_Duncehat", 0)
		--[[
	elseif MiniObjectiveType == 12 then
	]] -- Modified to:
	elseif MiniObjectiveType == 13 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_CONQUEROR")
		MinigameSetUberCompletion()
		ClothingGivePlayer("SP_VHelmet", 0)
		--[[
	elseif MiniObjectiveType == 16 then
	]] -- Modified to:
	elseif MiniObjectiveType == 17 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_FASHION_VIC")
		MinigameSetUberCompletion()
		ClothingGivePlayerOutfit("Gold Suit")
		--[[
	elseif MiniObjectiveType == 19 then
	]] -- Modified to:
	elseif MiniObjectiveType == 20 then
		MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_PROJ_REWARD")
		MinigameSetUberCompletion()
		ClothingGivePlayerOutfit("Ninja_WHT")
	end
end

local bTransferIntoBMXPark = false
local bTransferOutOfBMXPark = false
local bOpenBMXParkDoor = false
local bCloseBMXParkDoor = false
local bBMXParkDoorOpen = false
local bBMXParkDoorClosed = false
local gBMXPlayerBike = -1
local bBMXParkAvailable = false
local bBMXGateCam = false

function F_BMXGarage()
	if not shared.bBMXGatesInit then
		if AreaGetVisible() == 0 then
			if IsMissionCompleated("3_02") then
				RegisterTriggerEventHandler(TRIGGER._BA_BMXGARAGE, 1, cbOpenBMXGarage)
				RegisterTriggerEventHandler(TRIGGER._DT_BMXGARAGE, 1, cbTransToBMX)
				RegisterTriggerEventHandler(TRIGGER._BA_BMXGARAGE, 4, cbCloseBMXGarage)
				AreaSetDoorLockedToPeds(TRIGGER._BA_BMXGARAGE, true)
				AreaSetDoorLocked(TRIGGER._BA_BMXGARAGE, true)
			elseif not IsMissionCompleated("3_02") then
				AreaSetDoorLockedToPeds(TRIGGER._BA_BMXGARAGE, true)
				AreaSetDoorLocked(TRIGGER._BA_BMXGARAGE, true)
			end
			shared.bBMXGatesInit = true
		end
	elseif shared.bBMXGatesInit and AreaGetVisible() ~= 0 then
		shared.bBMXGatesInit = false
		RegisterTriggerEventHandler(TRIGGER._BA_BMXGARAGE, 1, nil)
		RegisterTriggerEventHandler(TRIGGER._DT_BMXGARAGE, 1, nil)
		RegisterTriggerEventHandler(TRIGGER._BA_BMXGARAGE, 4, nil)
	end
	if not shared.bBMXWarehouseInit then
		if AreaGetVisible() == 62 then
			if IsMissionCompleated("3_02") then
				RegisterTriggerEventHandler(TRIGGER._BMX_GARAGEDOOR, 1, cbOpenBMXGarage)
				RegisterTriggerEventHandler(TRIGGER._DT_BMXGARAGEDOOR, 1, cbTransToBMX)
				RegisterTriggerEventHandler(TRIGGER._BMX_GARAGEDOOR, 4, cbCloseBMXGarage)
				AreaSetDoorLockedToPeds(TRIGGER._BMX_GARAGEDOOR, true)
				AreaSetDoorLocked(TRIGGER._BMX_GARAGEDOOR, true)
			elseif not IsMissionCompleated("3_02") then
				AreaSetDoorLockedToPeds(TRIGGER._BMX_GARAGEDOOR, true)
				AreaSetDoorLocked(TRIGGER._BMX_GARAGEDOOR, true)
			end
			shared.bBMXWarehouseInit = true
		end
	elseif shared.bBMXWarehouseInit and AreaGetVisible() ~= 62 then
		shared.bBMXWarehouseInit = false
		RegisterTriggerEventHandler(TRIGGER._BMX_GARAGEDOOR, 1, nil)
		RegisterTriggerEventHandler(TRIGGER._DT_BMXGARAGEDOOR, 1, nil)
		RegisterTriggerEventHandler(TRIGGER._BMX_GARAGEDOOR, 4, nil)
	end
	if bTransferIntoBMXPark and F_OnABike() then
		bTransferIntoBMXPark = false
		PlayerSetControl(0)
		CameraFade(250, 0)
		Wait(251)
		local areaToWaitFor = 0
		if AreaGetVisible() == 0 then
			AreaTransitionPoint(62, POINTLIST._BMXPARKINSIDE, 2, true)
			areaToWaitFor = 62
			if VehicleIsValid(gBMXPlayerBike) then
				VehicleSetPosPoint(gBMXPlayerBike, POINTLIST._BMXPARKINSIDE, 1)
				PedPutOnBike(gPlayer, gBMXPlayerBike)
				gBMXPlayerBike = -1
			end
		elseif AreaGetVisible() == 62 then
			AreaTransitionPoint(0, POINTLIST._BMXPARKOUTSIDE, 1, true)
			areaToWaitFor = 0
		end
		while not AreaGetVisible() == areaToWaitFor do
			Wait(0)
		end
		while AreaIsLoading() do
			Wait(0)
		end
		CameraReturnToPlayer()
		bBMXParkDoorOpen = false
		CameraFade(250, 1)
		Wait(251)
		PlayerSetControl(1)
	end
end

function F_OnABike()
	if PlayerIsInAnyVehicle() then
		local vehicle = VehicleFromDriver(gPlayer)
		if VehicleIsModel(vehicle, 289) or VehicleIsModel(vehicle, 284) then
			return false
		else
			return true
		end
	else
		return false
	end
end

function cbCloseBMXGarage(triggerID, pedID)
	if pedID == gPlayer and (triggerID == TRIGGER._BA_BMXGARAGE or triggerID == TRIGGER._BMX_GARAGEDOOR) and F_OnABike() then
		if AreaGetVisible() == 0 and bBMXParkDoorOpen then
			PAnimSetActionNode(TRIGGER._BA_BMXGARAGE, "/Global/Door/DoorFunctions/Closing/BIKEGAR", "Act/Props/Door.act")
			bBMXParkDoorOpen = false
		elseif AreaGetVisible() == 62 and bBMXParkDoorOpen then
			PAnimSetActionNode(TRIGGER._BMX_GARAGEDOOR, "/Global/Door/DoorFunctions/Closing/BIKEGAR", "Act/Props/Door.act")
			bBMXParkDoorOpen = false
		end
	end
end

function cbOpenBMXGarage(triggerID, pedID)
	if pedID == gPlayer and (triggerID == TRIGGER._BA_BMXGARAGE or triggerID == TRIGGER._BMX_GARAGEDOOR) and F_OnABike() then
		if AreaGetVisible() == 0 and not bBMXParkDoorOpen then
			PAnimSetActionNode(TRIGGER._BA_BMXGARAGE, "/Global/Door/DoorFunctions/Opening/BIKEGAR", "Act/Props/Door.act")
			bBMXParkDoorOpen = true
		elseif AreaGetVisible() == 62 and not bBMXParkDoorOpen then
			PAnimSetActionNode(TRIGGER._BMX_GARAGEDOOR, "/Global/Door/DoorFunctions/Opening/BIKEGAR", "Act/Props/Door.act")
			bBMXParkDoorOpen = true
		end
	end
end

function cbTransToBMX(triggerID, pedID)
	if pedID == gPlayer and (triggerID == TRIGGER._DT_BMXGARAGE or triggerID == TRIGGER._DT_BMXGARAGEDOOR) then
		bTransferIntoBMXPark = true
		if PlayerIsInAnyVehicle() then
			gBMXPlayerBike = VehicleFromDriver(gPlayer)
		end
	end
end

function cbMainTagDone(triggerID)
	--print("TAGGING CALLBACK CALLED")
	if shared.gMonitorTags then
		shared.gMonitoredTag = triggerID
	end
end

function F_KickMe(ped)
	local kicker
	--print("F_KICKME!!!!")
	if PedIsValid(ped) then
		for COUNT = 1, 5 do
			kicker = PedFindRandomPed(-1, -1, -1, 40)
			if kicker == ped then
				kicker = nil
				COUNT = COUNT + 1
			elseif not PedIsValid(kicker) then
				kicker = nil
				COUNT = COUNT + 1
			else
				COUNT = 6
			end
		end
	end
	if PedIsValid(kicker) then
		PedLockTarget(kicker, ped, 0)
		PedSetTaskNode(kicker, "/Global/AI/Reactions/Stimuli/KickMeSign/KickMeReactions/Scripted/KickScript", "Act/AI/AI.act")
		--print("MADE KICKER")
	end
end

NS_ON()
