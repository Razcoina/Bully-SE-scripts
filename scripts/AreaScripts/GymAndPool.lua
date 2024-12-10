ImportScript("Library/LibClothing.lua")
local index, simpleObject
gGymDoors = {}
local GymSpawner, GymDocker
local CherryBomb = false

function main()
	if MissionActiveSpecific("6_03") and shared.g6_03_NerdsAlive == true then
		AreaDisableCameraControlForTransition(true)
	end
	DATLoad("eventsGymAndPool.DAT", 0)
	DATLoad("ibarber.DAT", 0)
	DATLoad("isc_pool.DAT", 0)
	DATLoad("SP_Pool.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDATFileLoaded[13] = true
	shared.gAreaDataLoaded = true
	if MissionActiveSpecific("4_06") or MissionActiveSpecific("6_03") then
		--print("IS THIS BEING FIRED OFF!??!?!?!")
		AreaClearAllPeds()
		AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		DisablePOI(true, true)
	else
		AreaDeactivatePopulationTrigger(TRIGGER._GYMPOOL_POPOVERRIDE)
	end
	F_SetupGymSpawners()
	AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._INPOOLAREA, 2)
	gClothingHeading = 0
	local inTrigger = false
	CreateThread("F_CherryBombEffect")
	if MissionActiveSpecific("6_03") and shared.g6_03_NerdsAlive == true then
		shared.g6_03_AreaReady = true
		shared.g6_03_NerdsAlive = false
	end
	while not (AreaGetVisible() ~= 13 or SystemShouldEndScript()) do
		if not gClothingUnlocked and (IsMissionCompleated("C_Wrestling_1") or shared.unlockedClothing) then
			gClothingUnlocked = true
		end
		if IsMissionAvailable("C_Wrestling_1") or IsMissionAvailable("C_Wrestling_3") then
			gClassIsAvailable = true
			gClothingUnlocked = false
		elseif IsMissionAvailable("C_Wrestling_2") or IsMissionAvailable("C_Wrestling_4") or IsMissionAvailable("C_Wrestling_5") then
			gClassIsAvailable = true
			gClothingUnlocked = false
		else
			gClassIsAvailable = false
		end
		if (gClothingUnlocked or shared.unlockedClothing) and not shared.lockClothingManager then
			if not cx then
				cx, cy, cz = GetPointList(POINTLIST._CM_CORONA)
			end
			if gClassIsAvailable then
				gCoronaType = 9
			else
				gCoronaType = 6
			end
			if not gClothing and not gClassIsAvailable and PlayerIsInAreaXYZ(cx, cy, cz, 1, gCoronaType, 180) then
				if gClassIsAvailable then
					TextPrint("BUT_CLASS_GYM", 1, 3)
				else
					TextPrint("BUT_CLOTH", 1, 3)
				end
				if IsButtonBeingPressed(9, 0) then
					L_ClothingSetup(gClothingHeading, CbFinishClothing, true)
					gClothing = true
				end
			end
			if gRunMission then
				--print("RUNNING MISSION FROM GYM AND POOL")
				ForceStartMission(gRunMission, true)
				gRunMission = false
			end
		end
		if shared.gGymToilet == true then
			shared.gGymToilet = false
			CherryBomb = true
		end
		Wait(0)
	end
	AreaRevertToDefaultPopulation()
	EnablePOI(true, true)
	AreaClearDockers()
	AreaClearSpawners()
	DATUnload(0)
	DATUnload(5)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[13] = false
	collectgarbage()
end

function CbFinishClothing()
	--print("[RAUL] CALLBACK FOR FINISHING CLOTHING")
	gClothing = false
	if ClothingIsWearingOutfit("Wrestling") then
		if IsMissionAvailable("Dummy_Wrestling_1") then
			gRunMission = "C_Wrestling_1"
			gClassIsAvailable = false
		elseif IsMissionAvailable("Dummy_Wrestling_3") then
			gRunMission = "C_Wrestling_3"
			gClassIsAvailable = false
		end
	elseif ClothingIsWearingOutfit("Gym Strip") then
		if IsMissionAvailable("Dummy_Wrestling_2") then
			gRunMission = "C_Wrestling_2"
			gClassIsAvailable = false
		elseif IsMissionAvailable("Dummy_Wrestling_4") then
			gRunMission = "C_Wrestling_4"
			gClassIsAvailable = false
		elseif IsMissionAvailable("Dummy_Wrestling_5") then
			gRunMission = "C_Wrestling_5"
			gClassIsAvailable = false
		end
	else
		CameraFade(500, 1)
	end
end

function F_CanStartMission()
	local CanStart = true
	local Response = 0
	if MissionAskUserToStart() then
		while Response == 0 do
			Wait(100)
			Response = MissionGetUserStartResponse()
		end
		if Response == -1 then
			CanStart = false
		end
	end
	return CanStart
end

function F_SetupGymSpawners()
	GymSpawner = AreaAddAmbientSpawner(2, 3, 50, 1000)
	GymDocker = AreaAddDocker(2, 3)
	AreaAddSpawnLocation(GymSpawner, POINTLIST.SPAWNGYM_DOORR, TRIGGER._GYML_DOORR)
	AreaAddSpawnLocation(GymSpawner, POINTLIST.SPAWNPOOL_DOORR, TRIGGER._POOL_DOORR)
	AreaAddDockLocation(GymDocker, POINTLIST.DOCKGYM_DOORL, TRIGGER._DT_GYM_DOORL)
	AreaAddDockLocation(GymDocker, POINTLIST.DOCKPOOL_DOORL, TRIGGER._DT_POOL_DOORL)
	AreaAddAmbientSpawnPeriod(GymSpawner, 7, 0, 105)
	AreaAddAmbientSpawnPeriod(GymSpawner, 11, 30, 75)
	AreaAddAmbientSpawnPeriod(GymSpawner, 15, 30, 420)
	AreaAddDockPeriod(GymDocker, 7, 0, 130)
	AreaAddDockPeriod(GymDocker, 11, 30, 100)
	AreaAddDockPeriod(GymDocker, 15, 0, 420)
	DockerSetMinimumRange(GymDocker, 3)
	DockerSetMaximumRange(GymDocker, 8)
	DockerSetUseFacingCheck(GymDocker, true)
end

function F_CherryBombEffect()
	while not (AreaGetVisible() ~= 13 or SystemShouldEndScript()) do
		if CherryBomb == true then
			Wait(1000)
			local x, y, z = PlayerGetPosXYZ()
			local tblToiletEffects = {}
			SoundPlay3D(x, y, z, "Chrybmb_Exp")
			Wait(30)
			SoundPlay3D(x, y, z, "ToiletExp")
			for i = 1, 5 do
				x, y, z = GetPointFromPointList(POINTLIST._GYM_TOILETS, i)
				local effect = EffectCreate("ToiletExplode", x, y, z)
				table.insert(tblToiletEffects, effect)
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
