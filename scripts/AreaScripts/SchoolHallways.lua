--[[ Changes to this file:
	* Modified function F_ShopLoop, may require testing
]]

local SchoolSpawnTable = {}
local ExitDocker, ExitSpawner, SchoolDocker
local gExitDoors = {}
local tblSigns = {}
local FireAlarmFlag = false
local CherryBomb = false
local DispersePatrolPrefects = false
local PopTriggerEnabled = false
local gStoreInitiated = false
local sX, sY, sZ = 0, 0, 0
local gPatrolPath_1F_PREFECT01_disabled = false
local gPatrolPath_1F_PREFECT02_disabled = false
local gPatrolPath_1F_PREFECT03_disabled = false
local gPatrolPath_2F_PREFECT01_disabled = false
local gPatrolPath_2F_PREFECT02_disabled = false
local gPatrolPath_HALLSPATROL_1A_disabled = false
local gPatrolPath_HALLSPATROL_1B_disabled = false
local gPatrolPath_HALLSPATROL_2A_disabled = false
local gPatrolPath_HALLSPATROL_2B_disabled = false
local gCurrentCam = 0
local gateIndex, gateObject, doorAindex, gdoorA
local gPausedClock = false
GlobalImportScript("AreaScripts/PrincipalOffice.lua")
GlobalImportScript("AreaScripts/Cafeteria.lua")

function PatrolPathInit()
	if not MissionActiveSpecific("6_03") then
		AreaInitPatrolPath(PATH._1F_PREFECT01, 2, 0, 1)
		AreaInitPatrolPath(PATH._1F_PREFECT02, 2, 0, 1)
		AreaInitPatrolPath(PATH._1F_PREFECT03, 2, 0, 1)
		AreaInitPatrolPath(PATH._2F_PREFECT01, 2, 0, 1)
		AreaInitPatrolPath(PATH._2F_PREFECT02, 2, 0, 1)
		AreaInitPatrolPath(PATH._HALLSPATROL_1A, 0, 2, 1, false)
		AreaInitPatrolPath(PATH._HALLSPATROL_1B, 0, 2, 1, false)
		AreaInitPatrolPath(PATH._HALLSPATROL_2A, 0, 2, 1, false)
		AreaInitPatrolPath(PATH._HALLSPATROL_2B, 0, 2, 1, false)
	end
end

function F_SchoolAlarm()
	while not (AreaGetVisible() ~= 2 or SystemShouldEndScript()) do
		if FireAlarmFlag == true then
			--print("F_SCHOOLALARM!!!!")
			FireAlarmFlag = true
			local classHour, classMinute = ClockGet()
			SpawnerSetOverrideActiveSetting(ExitSpawner, false)
			DockerSetOverrideActiveSetting(SchoolDocker, false)
			DockerSetOverrideActiveSetting(ExitDocker, true)
			AreaSetDockerPatrolPedReception(ExitDocker, true)
			DockerSetUseHeightCheck(ExitDocker, false)
			DockerSetMinimumRange(ExitDocker, 0)
			DockerSetMaximumRange(ExitDocker, 200)
			DockerSetUseFacingCheck(ExitDocker, false)
			AreaSetDockerChanceToDock(ExitDocker, 80)
			AreaSetDockerRunPercentage(ExitDocker, 100)
			if 7 <= classHour and classHour < 19 then
				AreaSetAmbientSpawnerExclusive(shared.gSchoolSpawner, true)
				AreaOverridePopulation(12, 0, 2, 2, 0, 2, 2, 2, 0, 2, 0, 0, 0)
				SpawnerSetOverrideActiveSetting(shared.gSchoolSpawner, true)
			end
			PedAddBroadcastStimulus(59, shared.gSchoolFAlarmTime / 1000)
			local SpawnTime = GetTimer()
			local Spawnflag = false
			while shared.gSchoolFAlarmOn == true do
				local SpawnShut = GetTimer()
				Wait(0)
				if AreaGetVisible() ~= 2 or SystemShouldEndScript() then
					break
				end
				if 10000 <= SpawnShut - SpawnTime and Spawnflag == false then
					Spawnflag = true
					SpawnerClearOverrideActiveSetting(shared.gSchoolSpawner)
				end
			end
			PedRemoveBroadcastStimulus(59)
			AreaRevertToDefaultPopulation()
			if shared.gSchoolFAlarmOn == false and not SystemShouldEndScript() then
				SpawnerClearOverrideActiveSetting(ExitSpawner)
				DockerClearOverrideActiveSetting(SchoolDocker)
				DockerClearOverrideActiveSetting(ExitDocker)
				AreaSetDockerPatrolPedReception(ExitDocker, false)
				AreaSetAmbientSpawnerExclusive(shared.gSchoolSpawner, false)
				DockerSetMinimumRange(ExitDocker, 10)
				DockerSetMaximumRange(ExitDocker, 30)
				AreaSetDockerChanceToDock(ExitDocker, 10)
				DockerSetUseHeightCheck(ExitDocker, true)
				AreaSetDockerRunPercentage(ExitDocker, 0)
				DockerSetUseFacingCheck(ExitDocker, true)
				FireAlarmFlag = false
			end
		end
		Wait(0)
	end
end

function F_CherryBombEffect()
	while not (AreaGetVisible() ~= 2 or SystemShouldEndScript()) do
		if CherryBomb == true then
			Wait(1000)
			local x, y, z = PlayerGetPosXYZ()
			local tblToiletEffects = {}
			SoundPlay3D(x, y, z, "Chrybmb_Exp")
			Wait(30)
			SoundPlay3D(x, y, z, "ToiletExp")
			if PlayerIsInTrigger(TRIGGER._BOYSBATHROOM1) or PlayerIsInTrigger(TRIGGER._BOYSBATHROOM2) then
				for i = 1, 5 do
					x, y, z = GetPointFromPointList(POINTLIST._SHALLWAYS_BR_BOYTOILET, i)
					local effect = EffectCreate("ToiletExplode", x, y, z)
					table.insert(tblToiletEffects, effect)
				end
			elseif PlayerIsInTrigger(TRIGGER._GIRLSBATHROOM1) or PlayerIsInTrigger(TRIGGER._GIRLSBATHROOM2) then
				for i = 1, 6 do
					x, y, z = GetPointFromPointList(POINTLIST._SHALLWAYS_GIRLTOILET, i)
					local effect = EffectCreate("ToiletExplode", x, y, z)
					table.insert(tblToiletEffects, effect)
				end
			end
			Wait(2000)
			for _, entry in tblToiletEffects do
				EffectKill(entry)
				table.remove(tblToiletEffects, entry)
			end
			CherryBomb = false
		end
		Wait(0)
	end
end

function main()
	if MissionActiveSpecific("6_03") then
		AreaDisableCameraControlForTransition(true)
	end
	DATLoad("SecTrig.DAT", 0)
	DATLoad("eventsSchoolHalls.DAT", 0)
	DATLoad("ischool_sitting.DAT", 0)
	DATLoad("ischool_doors.DAT", 0)
	DATLoad("ischool_lockers.DAT", 0)
	DATLoad("PrefectsMainBuilding.DAT", 0)
	DATLoad("SP_School_Hallways.DAT", 0)
	DATLoad("PriOffice.DAT", 0)
	DATLoad("eventsCafeteria.DAT", 0)
	DATLoad("tags_hallways.DAT", 0)
	DATLoad("Patrol_School.DAT", 0)
	PatrolPathInit()
	LoadModels({ 56 })
	F_PreDATInit()
	DATInit()
	if MissionActiveSpecific("3_08") then
		AreaClearAllPeds()
		AreaActivatePopulationTrigger(TRIGGER._3_08_SCHOOLPOP)
	end
	shared.gAreaDataLoaded = true
	shared.gAreaDATFileLoaded[2] = true
	F_CreateInteractiveSigns()
	F_SetupSchoolStore()
	F_SetupSchoolSpawners()
	F_RegisterPOEvents()
	F_RegisterCAFEvents()
	local TimeSet = false
	shared.gAreaLoadCompleted = 2
	CreateThread("F_SchoolAlarm")
	CreateThread("F_CherryBombEffect")
	while not (AreaGetVisible() ~= 2 or SystemShouldEndScript()) do
		Wait(0)
		if shared.passed1_02C == true and GetMissionAttemptCount("C_Chem_1") == 0 and not MissionActive() then
			ForceStartMission("C_Chem_1")
		end
		F_HandlePatrolPathOverrides()
		F_UpdateSpawnerTimer()
		F_UpdateSEC()
		F_UpdateLUNCH()
		if shared.gSchoolToilet == true then
			shared.gSchoolToilet = false
			CherryBomb = true
		end
		local classHour, classMinute = ClockGet()
		if classHour == 6 and classMinute < 45 and DispersePatrolPrefects == false then
			DispersePatrolPrefects = true
			F_DispersePatrolPrefects()
		elseif classHour == 6 and 45 <= classMinute and DispersePatrolPrefects == true then
			DispersePatrolPrefects = false
			F_RestoreSchoolSpawners()
		end
		if shared.gAlarmOn == true and FireAlarmFlag == false then
			local nHour, nMinute = ClockGet()
			--print("hour " .. nHour .. "." .. nMinute)
			if 7 <= nHour or nHour < 19 then
				FireAlarmFlag = true
			end
		end
		if IsMissionCompleated("1_02C") then
			F_ShopLoop()
		end
	end
	PedRemoveBroadcastStimulus(16)
	AreaClearPatrolPaths()
	AreaClearDockers()
	AreaClearSpawners()
	if shared.gAreaLoadCompleted == 2 then
		shared.gAreaLoadCompleted = nil
	end
	if gPlayerInStore then
		gPlayerInStore = false
	end
	if shared.gSchoolFAlarmOn == true then
		PedRemoveBroadcastStimulus(59)
	end
	AreaRevertToDefaultPopulation()
	F_CleanupSchoolStore()
	F_DeleteInteractiveSigns()
	tblSigns = nil
	DATUnload(0)
	DATUnload(5)
	F_KillCafTable()
	collectgarbage()
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[2] = false
end

local sHour, sMin

function F_SetupSchoolStore()
	--print("Setting up School Store <<<<<<<<<<<<")
	sHour, sMin = ClockGet()
	--print("Setting up School Store <<<<<<<<<<<<", sHour, sMin)
	gStoreItems = {}
	gateIndex, gateObject = CreatePersistentEntity("SCStoreGte_Closed", -611.652, -313.9, 2.00164, 0, 2)
	PAnimFollowPath(gateIndex, gateObject, PATH._CM_GATEPATH, false)
	table.insert(gStoreItems, { ind = gateIndex, obj = gateObject })
	sX, sY, sZ = GetPointList(POINTLIST._CM_CORONA)
	if 7 <= sHour and sHour <= 17 and IsMissionCompleated("1_02C") then
		--print("Setting up School Store IS OPEN<<<<<<<<<<<<")
		gStoreLocked = false
		gStoreOpen = true
		while not RequestModel(56, true) do
			Wait(0)
		end
		gClerk = PedCreatePoint(56, POINTLIST._CM_CLERK)
		PedModelNotNeededAmbient(gClerk)
		PedMakeTargetable(gClerk, false)
		PedClearAllWeapons(gClerk)
		PAnimSetPathFollowSpeed(gateIndex, gateObject, 1.2)
	else
		--print("Setting up School Store IS CLOSED<<<<<<<<<<<<")
		gStoreOpen = false
		gStoreLocked = true
		PAnimSetPathFollowSpeed(gateIndex, gateObject, -1.2)
	end
	gStoreInitiated = true
end

function F_CleanupSchoolStore()
	for i, element in gStoreItems do
		DeletePersistentEntity(element.ind, element.obj)
	end
end

function FeedbackCallback(storeFeedbackType, relatedData)
	--print("*** SAJ *** FEEDBACK CALLBACK", storeFeedbackType, relatedData)
	if storeFeedbackType == 0 and gCurrentCam ~= relatedData then
		gCurrentCam = relatedData
		gCamChanged = true
	end
end

function F_InitShop()
	SoundDisableSpeech_ActionTree()
	gHACKClothesCam = true
	local lx, ly, lz = GetPointList(POINTLIST._CM_PLAYERLOC)
	PlayerSetPosSimple(lx, ly, lz)
	PlayerFaceHeadingNow(220)
	gFloatA = 0.8
	gFloatB = 0.7
end

function F_ShopLoop() -- ! Modified
	sHour, sMin = ClockGet()
	if not gStoreInitiated then
		F_SetupSchoolStore()
	end
	if 7 <= sHour and sHour <= 17 then
		if not gStoreLocked and F_CheckPedNotInGrapple(gPlayer) and PlayerGetPunishmentPoints() <= 0 and PlayerIsInAreaXYZ(sX, sY, sZ, 1, 6, 225) then
			TextPrint("BUT_CLOTHSTR", 1, 3)
			if IsButtonBeingPressed(9, 0) then
				SoundPlay2D("ButtonUp")
				MusicFadeWithCamera(false)
				SoundFadeWithCamera(false)
				PlayerSetControl(0)
				CameraFade(100, 0)
				AreaClearAllPeds()
				Wait(400)
				F_MakePlayerSafeForNIS(true, true)
				PedSetActionNode(gPlayer, "/Global/Welcome/Idle", "Act/Conv/Store.act")
				TextPrintString("", 1, 2)
				LoadAnimationGroup("Try_Clothes")
				F_InitShop()
				local buttonPressed = false
				Wait(250)
				local bPlaySpeech = true
				local speechTime = GetTimer() + 1500
				--[[
				local startingHeading = 220
				local clothingHeading = startingHeading
				]] -- Changed to:
				local startingHeading = 5
				local clothingHeading = 220
				Wait(250)
				local gTryingTime = GetTimer()
				local gChangeAnimTime = 10000
				ClothingLock("HEAD", false)
				ClothingLock("LEFT_WRIST", false)
				ClothingLock("RIGHT_WRIST", false)
				ClothingLock("LEGS", false)
				ClothingLock("FEET", false)
				ClothingLock("OUTFIT", false)
				gLookAtPoint = POINTLIST._CM_LOOKAT
				gLookAtPoint2 = POINTLIST._CM_LOOKAT2
				gCameraTransitions = {
					{
						path = PATH._CM_CAMERA02,
						camNo = 0
					},
					{
						path = PATH._CM_CAMERA03,
						camNo = 1
					},
					{
						path = PATH._CM_CAMERA04,
						camNo = 2
					},
					{
						path = PATH._CM_CAMERA04,
						camNo = 2
					},
					{
						path = PATH._CM_CAMERA05,
						camNo = 3
					},
					{
						path = PATH._CM_CAMERA06,
						camNo = 4
					},
					{
						path = PATH._CM_CAMERA01,
						camNo = 5
					},
					{
						path = PATH._CM_CAMERA01,
						camNo = 5
					}
				}
				Wait(250)
				HUDSaveVisibility()
				HUDClearAllElements()
				ToggleHUDComponentLocked(40, true)
				ToggleHUDComponentVisibility(14, true)
				PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/TryingOn", "Act/Anim/Ambient.act")
				ClothingStoreRegisterFeedbackCallback(FeedbackCallback)
				PlayerUnequip()
				if not MissionActive() and not ClockIsPaused() then
					PauseGameClock()
					gPausedClock = true
				end
				MissionTimerPause(true)
				local size = table.getn(gCameraTransitions)
				if CameraGet169Mode() then
					gInWidescreen = true
					lx, ly, lz = GetPointList(gLookAtPoint2)
					CameraSetFOV(75)
				else
					gInWidescreen = false
					lx, ly, lz = GetPointList(gLookAtPoint)
				end
				CameraLookAtXYZ(lx, ly, lz, true)
				CameraSetPath(gCameraTransitions[size].path, true)
				CameraSetSpeed(15, 15, 15)
				gCurrentCamNo = gCameraTransitions[size].camNo
				F_AddClothes()
				CameraFade(1000, 1)
				SoundDisableSpeech_ActionTree()
				local plx, ply, plz = GetPointList(POINTLIST._CM_PLAYERLOC)
				PlayerSetPosSimple(plx, ply, plz)
				PlayerFaceHeadingNow(clothingHeading)
				if shared.playerKOd then
					shared.playerKOd = nil
				end
				while not buttonPressed do
					if gInWidescreen and not CameraGet169Mode() then
						lx, ly, lz = GetPointList(gLookAtPoint)
						CameraLookAtXYZ(lx, ly, lz, true)
						CameraDefaultFOV()
						gInWidescreen = false
					elseif not gInWidescreen and CameraGet169Mode() then
						lx, ly, lz = GetPointList(gLookAtPoint2)
						CameraSetFOV(75)
						CameraLookAtXYZ(lx, ly, lz, true)
						gInWidescreen = true
					end
					if IsButtonPressed(15, 0) then
						--[[
						clothingHeading = startingHeading
						]]                           -- Changed to:
						startingHeading = startingHeading - 1
						if startingHeading == 0 then -- Added this
							clothingHeading = 0
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
					if not gZoomed and IsButtonPressed(12, 0) then
						local index = gCurrentCam + 1
						gZoomed = true
						if gCurrentCamNo ~= gCameraTransitions[index].camNo then
							CameraSetPath(gCameraTransitions[index].path, false)
							gCurrentCamNo = gCameraTransitions[index].camNo
						end
					elseif gZoomed then
						if not IsButtonPressed(12, 0) then
							local size = table.getn(gCameraTransitions)
							if gCurrentCamNo ~= gCameraTransitions[size].camNo then
								CameraSetPath(gCameraTransitions[size].path, false)
								gCurrentCamNo = gCameraTransitions[size].camNo
								Wait(1000)
							end
							gZoomed = false
						end
						if gCamChanged then
							local index = gCurrentCam + 1
							if gCurrentCamNo ~= gCameraTransitions[index].camNo then
								CameraSetPath(gCameraTransitions[index].path, false)
								gCurrentCamNo = gCameraTransitions[index].camNo
								Wait(100)
							end
							gCamChanged = false
						end
					end
					if gCamChanged then
						gCamChanged = false
					end
					if gChangeAnimTime < GetTimer() - gTryingTime then
						PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/TryClothesAnims", "Act/Anim/Ambient.act")
						gTryingTime = GetTimer()
					end
					if IsButtonPressed(8, 0) or shared.playerKOd then
						SoundPlay2D("ButtonDown")
						CameraFade(1000, 0)
						PlayerSetControl(0)
						Wait(1000)
						UnLoadAnimationGroup("Try_Clothes")
						F_CleanupShop()
						CameraDefaultFOV()
						if not MissionActive() and gPausedClock then
							UnpauseGameClock()
						end
						Wait(500)
						F_MakePlayerSafeForNIS(false, true)
						CameraSetXYZ(-608.95917, -319.6243, 0.908202, -609.3722, -318.7236, 1.042619)
						Wait(1)
						CameraReturnToPlayer(false)
						Wait(500)
						CameraFade(500, 1)
						Wait(500)
						MusicFadeWithCamera(true)
						SoundFadeWithCamera(true)
						PlayerSetControl(1)
						buttonPressed = true
						MissionTimerPause(false)
					end
					Wait(0)
				end
			end
		elseif gStoreLocked then
			gStoreLocked = false
			gStoreOpen = true
			if not gClerk then
				gClerk = PedCreatePoint(56, POINTLIST._CM_CLERK)
				PedModelNotNeededAmbient(gClerk)
				PedMakeTargetable(gClerk, false)
				PedClearAllWeapons(gClerk)
			end
			Wait(1000)
			PAnimSetPathFollowSpeed(gateIndex, gateObject, 1.2)
			--print("STORE UNLOCKED NOW")
		end
		if not gStoreLocked and gClerk and PedIsHit(gClerk, 2, 1000) and PedGetWhoHitMeLast(gClerk) == gPlayer then
			PlayerIncPunishmentPoints(155)
			PedMakeAmbient(gClerk)
			gStoreLocked = true
		end
		if not gPlayerInStore and PlayerIsInTrigger(TRIGGER._ISCHOOL_STOREAREA) then
			ShopSetIsPlayerInShop(true)
			gPlayerInStore = true
		elseif gPlayerInStore and not PlayerIsInTrigger(TRIGGER._ISCHOOL_STOREAREA) then
			ShopSetIsPlayerInShop(false)
			gPlayerInStore = false
		end
	else
		gStoreLocked = true
		if gStoreInitiated and gClerk and not PedIsDead(gClerk) then
			PAnimSetPathFollowSpeed(gateIndex, gateObject, -1.2)
			Wait(1500)
			PedDelete(gClerk)
			gClerk = nil
		end
	end
end

function F_PartialCleanupShop()
	SoundEnableSpeech_ActionTree()
	gHACKClothesCam = false
	CameraSetActive(1, 100, false)
end

function F_CleanupShop()
	F_PartialCleanupShop()
	ToggleHUDComponentLocked(40, false)
	ToggleHUDComponentVisibility(14, false)
	HUDRestoreVisibility()
	PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/Finished", "Act/Anim/Ambient.act")
end

function F_AddClothes()
	ClothingStoreAdd(0, "S_Bhat2", 350)
	ClothingStoreAdd(0, "S_Bhat3", 350)
	ClothingStoreAdd(0, "S_Sunvisor1", 350)
	ClothingStoreAdd(0, "S_Sunvisor2", 350)
	ClothingStoreAdd(0, "S_Sunvisor3", 350)
	ClothingStoreAdd(1, "S_SSleeves1", 350)
	ClothingStoreAdd(1, "S_SSleeves2", 350)
	ClothingStoreAdd(1, "S_SSleeves3", 350)
	ClothingStoreAdd(1, "S_SSleeves4", 350)
	ClothingStoreAdd(1, "S_SSleeves5", 350)
	ClothingStoreAdd(1, "S_SSleeves6", 350)
	ClothingStoreAdd(1, "S_SSleeves7", 350)
	ClothingStoreAdd(1, "S_SSleeves8", 350)
	ClothingStoreAdd(1, "S_LSleeves1", 600)
	ClothingStoreAdd(1, "S_LSleeves2", 600)
	ClothingStoreAdd(1, "S_LSleeves3", 800)
	ClothingStoreAdd(1, "S_LSleeves4", 800)
	ClothingStoreAdd(1, "S_Sweater1", 700)
	ClothingStoreAdd(1, "S_Sweater2", 700)
	ClothingStoreAdd(1, "S_Jacket3", 1100)
	ClothingStoreAdd(1, "S_Jacket4", 1100)
	ClothingStoreAdd(4, "S_Pants3", 700)
	ClothingStoreAdd(4, "S_Shorts1", 500)
	ClothingStoreAdd(4, "S_Shorts4", 500)
	ClothingStoreAdd(4, "S_Shorts5", 500)
	ClothingStoreAdd(4, "S_Shorts6", 500)
	ClothingStoreAdd(2, "S_Wristband1", 200)
	ClothingStoreAdd(3, "S_Wristband2", 200)
	ClothingStoreAdd(3, "S_Wristband3", 200)
	ClothingStoreAdd(2, "S_Wristband4", 200)
	ClothingStoreAdd(3, "S_Wristband5", 200)
	ClothingStoreAdd(2, "S_Wristband6", 200)
	ClothingStoreAdd(5, "S_Sneakers1", 600)
	ClothingStoreAdd(5, "S_Sneakers2", 1000)
end

function F_DispersePatrolPrefects()
	--print("DISPERSING_________(#*^$(*^")
	DockerSetOverrideActiveSetting(SchoolDocker, true)
	AreaSetDockerPatrolPedReception(SchoolDocker, true)
	DockerSetMaximumRange(SchoolDocker, 100)
	DockerSetUseFacingCheck(SchoolDocker, false)
	AreaSetDockerRunPercentage(SchoolDocker, 100)
	DockerSetOverrideActiveSetting(ExitDocker, true)
	AreaSetDockerPatrolPedReception(ExitDocker, true)
	DockerSetMaximumRange(ExitDocker, 100)
	DockerSetUseFacingCheck(ExitDocker, false)
	AreaSetDockerRunPercentage(ExitDocker, 100)
end

function F_RestoreSchoolSpawners()
	DockerClearOverrideActiveSetting(SchoolDocker)
	AreaSetDockerPatrolPedReception(SchoolDocker, false)
	DockerSetMaximumRange(SchoolDocker, 30)
	AreaSetDockerRunPercentage(SchoolDocker, 70)
	DockerSetUseFacingCheck(SchoolDocker, false)
	DockerClearOverrideActiveSetting(ExitDocker)
	AreaSetDockerPatrolPedReception(ExitDocker, false)
	DockerSetMaximumRange(ExitDocker, 15)
	AreaSetDockerRunPercentage(ExitDocker, 0)
	DockerSetUseFacingCheck(ExitDocker, false)
end

function F_GetBoardTwo()
	local signObj = "BulletinChapter1_2"
	if IsMissionCompleated("6_B") then
		signObj = "BulletinChapter6_2"
	elseif IsMissionCompleated("5_09") then
		signObj = "BulletinChapter5_1"
	elseif IsMissionCompleated("3_B") then
		signObj = "BulletinChapter4_2"
	elseif IsMissionCompleated("2_05") then
		signObj = "BulletinChapter2_4"
	elseif IsMissionCompleated("1_09") then
		signObj = "BulletinChapter1_11"
	end
	return signObj
end

function F_GetBoardFour()
	local signObj = "BulletinChapter1_4"
	if IsMissionCompleated("6_B") then
		signObj = "BulletinChapter6_4"
	elseif IsMissionCompleated("4_S11") then
		signObj = "BulletinChapter4_3"
	elseif IsMissionCompleated("2_08") then
		signObj = "BulletinChapter2_7"
	elseif IsMissionCompleated("1_B") then
		signObj = "BulletinChapter2_1"
	elseif IsMissionCompleated("1_G1") then
		signObj = "BulletinChapter1_8"
	end
	return signObj
end

function F_GetBoardFive()
	local signObj = "BulletinChapter1_5"
	if IsMissionCompleated("6_B") then
		signObj = "BulletinChapter6_5"
	elseif IsMissionCompleated("5_02") then
		signObj = "BulletinChapter5_3"
	elseif IsMissionCompleated("4_B1") then
		signObj = "BulletinChapter4_2"
	elseif IsMissionCompleated("2_B") then
		signObj = "BulletinChapter3_2"
	elseif IsMissionCompleated("1_B") then
		signObj = "BulletinChapter2_2"
	elseif IsMissionCompleated("1_G1") then
		signObj = "BulletinChapter1_7"
	end
	return signObj
end

function F_CreateInteractiveSigns()
	local idSignTexture = "BulletinChapter1_1"
	local idSignObject = F_GetBoardTwo()
	local objID, objPool = CreatePersistentEntity(idSignObject, -616.471, -314.335, 1.64721, 180, 2)
	table.insert(tblSigns, {
		id = objID,
		bPool = objPool,
		signx = -616.412,
		signy = -314.379,
		signz = -9.0E-4,
		tex = idSignTexture
	})
	idSignObject = F_GetBoardFour()
	objID, objPool = CreatePersistentEntity(idSignObject, -667.379, -292.602, 1.64721, -90, 2)
	table.insert(tblSigns, {
		id = objID,
		bPool = objPool,
		signx = -667.349,
		signy = -292.543,
		signz = -0.00512,
		tex = idSignTexture
	})
	idSignObject = F_GetBoardFive()
	objID, objPool = CreatePersistentEntity(idSignObject, -585.709, -305.701, 7.14888, -90, 2)
	table.insert(tblSigns, {
		id = objID,
		bPool = objPool,
		signx = -585.635,
		signy = -305.656,
		signz = 5.49999,
		tex = idSignTexture
	})
end

function F_DeleteInteractiveSigns()
	local i, Entry
	for i, Entry in tblSigns do
		if Entry.id ~= nil and Entry.id ~= -1 then
			DeletePersistentEntity(Entry.id, Entry.bPool)
		end
	end
	tblSigns = {}
end

function F_SetupSchoolSpawners()
	--print("SETTING UP SPAWNERS")
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR00,
		Point = POINTLIST._ISCHOOL_DOOR00
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._DT_ISCHOOL_DOOR01,
		Point = POINTLIST._ISCHOOL_DOOR01
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR02,
		Point = POINTLIST._ISCHOOL_CHEM
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR05,
		Point = POINTLIST._ISCHOOL_DOOR05
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR06,
		Point = POINTLIST._ISCHOOL_DOOR06
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR09,
		Point = POINTLIST._ISCHOOL_DOOR09
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._DT_ISCHOOL_ART,
		Point = POINTLIST._ISCHOOL_DOOR12
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._DT_ISCHOOL_BIO,
		Point = POINTLIST._ISCHOOL_DOOR13
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._DT_ISCHOOL_CLASSROOM,
		Point = POINTLIST._ISCHOOL_DOOR14
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR19,
		Point = POINTLIST._ISCHOOL_DOOR19
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR21,
		Point = POINTLIST._ISCHOOL_DOOR21
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR23,
		Point = POINTLIST._ISCHOOL_DOOR23
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR24,
		Point = POINTLIST._ISCHOOL_DOOR24
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR28,
		Point = POINTLIST._ISCHOOL_DOOR28
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._DT_ISCHOOL_CHEM,
		Point = POINTLIST._ISCHOOL_DOOR29
	})
	table.insert(SchoolSpawnTable, {
		Trigger = TRIGGER._ISCHOOL_DOOR30,
		Point = POINTLIST._ISCHOOL_DOOR30
	})
	shared.gSchoolSpawner = AreaAddAmbientSpawner(33, 2, 50, 400)
	AreaAddAmbientSpawnPeriod(shared.gSchoolSpawner, 11, 30, 30)
	AreaAddAmbientSpawnPeriod(shared.gSchoolSpawner, 15, 30, 30)
	SchoolDocker = AreaAddDocker(33, 2)
	AreaAddDockPeriod(SchoolDocker, 8, 45, 20)
	AreaAddDockPeriod(SchoolDocker, 12, 45, 20)
	for i, key in SchoolSpawnTable do
		AreaAddSpawnLocation(shared.gSchoolSpawner, SchoolSpawnTable[i].Point, SchoolSpawnTable[i].Trigger)
		AreaAddDockLocation(SchoolDocker, SchoolSpawnTable[i].Point, SchoolSpawnTable[i].Trigger)
	end
	DockerSetMinimumRange(SchoolDocker, 0)
	DockerSetMaximumRange(SchoolDocker, 30)
	AreaSetDockerRunPercentage(SchoolDocker, 80)
	DockerSetUseFacingCheck(SchoolDocker, false)
	local Spawner = 0
	local Docker = 1
	local Both = 2
	table.insert(gExitDoors, {
		Trigger = TRIGGER.DT_ISCHOOL_FRONTDOORL,
		Point = POINTLIST.ISCHOOL_FRONTDOORL,
		Type = Docker
	})
	table.insert(gExitDoors, {
		Trigger = TRIGGER.ISCHOOL_FRONTDOORR,
		Point = POINTLIST.ISCHOOL_FRONTDOORR,
		Type = Spawner
	})
	table.insert(gExitDoors, {
		Trigger = TRIGGER.DT_ISCHOOL_BACKDOORLEFT,
		Point = POINTLIST.ISCHOOL_BACKDOORLEFT,
		Type = Both
	})
	table.insert(gExitDoors, {
		Trigger = TRIGGER.DT_ISCHOOL_FRONTDOORRIGHT,
		Point = POINTLIST.ISCHOOL_FRONTDOORRIGHT,
		Type = Both
	})
	ExitDocker = AreaAddDocker(5, 3)
	ExitSpawner = AreaAddAmbientSpawner(5, 2, 100, 2500)
	DockerSetUseFacingCheck(ExitDocker, false)
	DockerSetMinimumRange(ExitDocker, 0)
	DockerSetMaximumRange(ExitDocker, 15)
	for i, key in gExitDoors do
		if key.Type == Both then
			AreaAddDockLocation(ExitDocker, key.Point, key.Trigger)
			--print(key.Point, key.Trigger)
			AreaAddSpawnLocation(ExitSpawner, key.Point, key.Trigger)
		elseif key.Type == Spawner then
			AreaAddSpawnLocation(ExitSpawner, key.Point, key.Trigger)
		elseif key.Type == Docker then
			AreaAddDockLocation(ExitDocker, key.Point, key.Trigger)
			--print(key.Point, key.Trigger)
		end
	end
	AreaAddDockPeriod(ExitDocker, 11, 30, 30)
	AreaAddDockPeriod(ExitDocker, 15, 30, 240)
	AreaAddAmbientSpawnPeriod(ExitSpawner, 7, 0, 120)
	AreaAddAmbientSpawnPeriod(ExitSpawner, 11, 30, 90)
end

function F_UpdateSpawnerTimer()
	if FireAlarmFlag == false then
		local TimeHours, TimeMinutes = ClockGet()
		if TimeHours == 11 and TimeMinutes == 30 then
			AreaSetDockerRunPercentage(ExitDocker, 50)
			DockerSetMinimumRange(ExitDocker, 0)
			DockerSetMaximumRange(ExitDocker, 30)
			AreaSetAmbientSpawnerExclusive(shared.gSchoolSpawner, true)
		elseif TimeHours == 11 and TimeMinutes == 45 then
			AreaSetDockerRunPercentage(ExitDocker, 3)
			DockerSetMinimumRange(ExitDocker, 0)
			DockerSetMaximumRange(ExitDocker, 15)
			AreaSetAmbientSpawnerExclusive(shared.gSchoolSpawner, false)
		elseif TimeHours == 15 and TimeMinutes == 30 then
			AreaSetDockerRunPercentage(ExitDocker, 50)
			AreaSetAmbientSpawnerExclusive(shared.gSchoolSpawner, true)
			DockerSetMinimumRange(ExitDocker, 0)
			DockerSetMaximumRange(ExitDocker, 30)
		elseif TimeHours == 16 and TimeMinutes == 0 then
			AreaSetDockerRunPercentage(ExitDocker, 3)
			DockerSetMinimumRange(ExitDocker, 0)
			DockerSetMaximumRange(ExitDocker, 15)
			AreaSetAmbientSpawnerExclusive(shared.gSchoolSpawner, false)
		elseif TimeHours == 18 and TimeMinutes == 45 then
			AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
			AreaSetDockerRunPercentage(ExitDocker, 100)
			DockerSetMinimumRange(ExitDocker, 0)
			DockerSetMaximumRange(ExitDocker, 100)
			PedAddBroadcastStimulus(16)
		elseif TimeHours == 19 and TimeMinutes == 15 then
			PedRemoveBroadcastStimulus(16)
			AreaRevertToDefaultPopulation()
			AreaSetDockerRunPercentage(ExitDocker, 3)
			DockerSetMinimumRange(ExitDocker, 0)
			DockerSetMaximumRange(ExitDocker, 15)
			AreaSetAmbientSpawnerExclusive(shared.gSchoolSpawner, false)
		end
	end
end

function F_HandlePatrolPathOverridesHelper(isDisabled, shouldDisable, pathID)
	if isDisabled == true then
		if shouldDisable == false then
			AreaEnablePatrolPath(pathID)
			return false
		end
	elseif shouldDisable == true then
		AreaDisablePatrolPath(pathID)
		return true
	end
end

function F_HandlePatrolPathOverrides()
	gPatrolPath_1F_PREFECT01_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_1F_PREFECT01_disabled, shared.gTurnOff_1F_PREFECT01, PATH._1F_PREFECT01)
	gPatrolPath_1F_PREFECT02_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_1F_PREFECT02_disabled, shared.gTurnOff_1F_PREFECT02, PATH._1F_PREFECT02)
	gPatrolPath_1F_PREFECT03_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_1F_PREFECT03_disabled, shared.gTurnOff_1F_PREFECT03, PATH._1F_PREFECT03)
	gPatrolPath_2F_PREFECT01_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_2F_PREFECT01_disabled, shared.gTurnOff_2F_PREFECT01, PATH._2F_PREFECT01)
	gPatrolPath_2F_PREFECT02_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_2F_PREFECT02_disabled, shared.gTurnOff_2F_PREFECT02, PATH._2F_PREFECT02)
	gPatrolPath_HALLSPATROL_1A_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_HALLSPATROL_1A_disabled, shared.gTurnOff_HALLSPATROL_1A, PATH._HALLSPATROL_1A)
	gPatrolPath_HALLSPATROL_1B_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_HALLSPATROL_1B_disabled, shared.gTurnOff_HALLSPATROL_1B, PATH._HALLSPATROL_1B)
	gPatrolPath_HALLSPATROL_2A_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_HALLSPATROL_2A_disabled, shared.gTurnOff_HALLSPATROL_2A, PATH._HALLSPATROL_2A)
	gPatrolPath_HALLSPATROL_2B_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_HALLSPATROL_2B_disabled, shared.gTurnOff_HALLSPATROL_2B, PATH._HALLSPATROL_2B)
end

function F_CheckPedNotInGrapple(PedID)
	pGrapplePed = PedGetGrappleTargetPed(PedID)
	if pGrapplePed == -1 then
		return true
	end
	return false
end
