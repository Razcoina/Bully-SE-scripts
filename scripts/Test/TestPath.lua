local testPed

function MissionSetup()
	DATLoad("test_path.DAT", 2)
	DATInit()
	AreaTransitionPoint(37, POINTLIST._PSTART)
	testPed = PedCreatePoint(18, POINTLIST._JSTART)
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	local x, y, z = GetPointList(POINTLIST._JDEST)
	PedMoveToXYZ(testPed, 0, x, y)
	AreaSetDoorLockedToPeds(TRIGGER._IFUNHOUS_FMTRAPDR, true)
	AreaSetDoorLockedToPeds(TRIGGER._IFUNHOUS_FMTRAPDR01, true)
	while not PedIsInAreaXYZ(testPed, x, y, z, 0.5, 1) do
		Wait(0)
	end
	MissionFail()
end
