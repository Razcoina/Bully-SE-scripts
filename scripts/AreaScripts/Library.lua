local BExitDoor, BEntranceDoor

function main()
	if MissionActiveSpecific("6_03") and shared.g6_03_JocksAlive == true then
		AreaDisableCameraControlForTransition(true)
	end
	LoadAnimationGroup("POI_Cafeteria")
	DATLoad("isc_lib.DAT", 0)
	DATLoad("SP_Library.DAT", 0)
	DATLoad("eventsLibrary.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDATFileLoaded[9] = true
	shared.gAreaDataLoaded = true
	SetupSpawnerAndDocker()
	if MissionActiveSpecific("6_03") and shared.g6_03_JocksAlive == true then
		shared.g6_03_JocksAlive = false
		shared.g6_03_AreaReady = true
	end
	local hour, minute = ClockGet()
	if not MissionActive() and 7 <= hour and hour < 9 then
		F_CreateLibrarian()
	end
	while not (AreaGetVisible() ~= 9 or SystemShouldEndScript()) do
		Wait(0)
		UpdateSpawnerAndDocker()
	end
	AreaClearDockers()
	AreaClearSpawners()
	UnLoadAnimationGroup("POI_Cafeteria")
	DATUnload(0)
	DATUnload(5)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[9] = false
	collectgarbage()
end

function SetupSpawnerAndDocker()
	BExitDoor = AreaAddDocker(2, 3)
	BEntranceDoor = AreaAddAmbientSpawner(2, 3, 0, 1000)
	AreaAddSpawnLocation(BEntranceDoor, POINTLIST._DT_LIBRARYSPAWNER, TRIGGER._ESCDOORL)
	AreaAddDockLocation(BExitDoor, POINTLIST._DT_LIBRARYDOCKER, TRIGGER._DT_LIBRARYEXITR)
	AreaSpawnerSetSexGeneration(BEntranceDoor, true, true)
	AreaSetDockerSexReception(BExitDoor, true, true)
	AreaAddAmbientSpawnPeriod(BEntranceDoor, 11, 30, 80)
	AreaAddAmbientSpawnPeriod(BEntranceDoor, 15, 30, 180)
	AreaAddDockPeriod(BExitDoor, 12, 45, 30)
	AreaAddDockPeriod(BExitDoor, 15, 30, 180)
	DockerSetMinimumRange(BExitDoor, 0)
	DockerSetMaximumRange(BExitDoor, 3)
end

function UpdateSpawnerAndDocker()
	local hour, minutes = ClockGet()
	if hour == 11 and minutes == 30 then
		AreaSetAmbientSpawnerExclusive(BEntranceDoor, true)
	elseif hour == 11 and minutes == 35 then
		AreaSetAmbientSpawnerExclusive(BEntranceDoor, false)
	elseif hour == 12 and minutes == 45 then
		AreaSetDockerRunPercentage(BExitDoor, 100)
		DockerSetMaximumRange(BExitDoor, 30)
	elseif hour == 13 and minutes == 15 then
		AreaSetDockerRunPercentage(BExitDoor, 3)
		DockerSetMaximumRange(BExitDoor, 10)
	elseif hour == 15 and minutes == 30 then
		AreaSetAmbientSpawnerExclusive(BEntranceDoor, true)
	elseif hour == 15 and minutes == 35 then
		AreaSetAmbientSpawnerExclusive(BEntranceDoor, false)
	end
end

function F_CreateLibrarian()
	while not RequestModel(62, true) do
		Wait(0)
	end
	Librarian = PedCreatePoint(62, POINTLIST._LIBRARIANPOINT)
	PedModelNotNeededAmbient(Librarian)
	PedFollowPath(Librarian, PATH._LIBRARIANPATH, 2, 0)
	shared.LibrarianID = Librarian
end
