local gGeoTable = {}

function main()
	AreaDisableCameraControlForTransition(true)
	LoadAnimationGroup("Area_Funhouse")
	DATLoad("funhouse.DAT", 0)
	DATLoad("ifunhous.DAT", 0)
	DATLoad("SP_HouseOfMirrors.DAT", 0)
	LoadPAnims({
		TRIGGER._FUNCURTN,
		TRIGGER._FUNCURTN01,
		TRIGGER._IFUNHOUS_FMCNTRL01,
		TRIGGER._IFUNHOUS_FLBBOOK,
		TRIGGER._DT_IFUNHOUS_FMDOOR,
		TRIGGER._IFUNHOUS_FMTRAPDR03,
		TRIGGER._IFUNHOUS_FLBLADER
	})
	F_PreDATInit()
	F_SetupProps()
	DATInit()
	shared.gAreaDATFileLoaded[37] = true
	shared.gAreaDataLoaded = true
	AreaDisableCameraControlForTransition(false)
	CameraFade(500, 1)
	Wait(501)
	PauseGameClock()
	ToggleHUDComponentVisibility(0, false)
	while not (AreaGetVisible() ~= 37 or SystemShouldEndScript()) do
		Wait(0)
	end
	--print("System should end script?: ", tostring(SystemShouldEndScript()))
	ToggleHUDComponentVisibility(0, true)
	DATUnload(0)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[37] = false
	for i, geo in gGeoTable do
		if geo.id and geo.index then
			--print("i is: ", i)
			--print("geo.id is: ", geo.id)
			--print("geo.index is: ", geo.index)
			DeletePersistentEntity(geo.id, geo.index)
		end
	end
	UnpauseGameClock()
	UnLoadAnimationGroup("Area_Funhouse")
	collectgarbage()
end

function F_SetupProps()
	PAnimSetActionNode(TRIGGER._IFUNHOUS_FLBLADER, "/Global/Ladder/AnimatedLadder/NotUseable", "Act/Props/Ladder.act")
	AreaSetDoorLocked(TRIGGER._IFUNHOUS_MINEMZE, true)
	AreaSetDoorLocked(TRIGGER._FUN_MAZEENTRYDOOR, true)
	AreaSetDoorLocked(TRIGGER._FUN_MAZEENTRYDOOR, true)
	AreaSetDoorLocked(TRIGGER._IFUNHOUS_MZEMINE, true)
	AreaSetDoorLocked(TRIGGER._IFUNHOUS_MINEEND, true)
	local objId, objInd
	objId, objInd = CreatePersistentEntity("Ladder_3M", -761.738, -449.879, 15.109, 90, 37)
	table.insert(gGeoTable, { id = objId, index = objInd })
	objId, objInd = CreatePersistentEntity("Ladder_3M", -725.666, -400.03, 9.59487, 0, 37)
	table.insert(gGeoTable, { id = objId, index = objInd })
	PAnimSetActionNode("pxLad3M", -761.738, -449.879, 15.1089, 0.1, "/Global/Ladder/NotUseable", "Act/Props/Ladder.act")
	PAnimSetActionNode("pxLad3M", -725.666, -400.031, 9.59475, 0.1, "/Global/Ladder/NotUseable", "Act/Props/Ladder.act")
end
