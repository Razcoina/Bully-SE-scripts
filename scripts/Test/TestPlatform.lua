local gMissionRunning = true
local gCrate

function MissionSetup()
	DATLoad("TestPlatform.DAT", 2)
	DATInit()
	AreaTransitionPoint(62, POINTLIST._TP_PLAYERSPAWN)
	gCrate = PAnimCreate(TRIGGER._TP_CRATE)
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	TextPrintString(" press ~t~ to Set crate on path going up", 3, 1)
	WaitSkippable(3000)
	TextPrintString(" press ~s~ to set crate on path sideways", 3, 1)
	WaitSkippable(3000)
	TextPrintString("press ~x~ to quit", 3, 1)
	while gMissionRunning do
		F_StartMission()
		Wait(0)
	end
	MissionSucceed()
end

function F_StartMission()
	if IsButtonPressed(9, 0) then
		--print("=========Elevator Up===============")
		PAnimFollowPath(TRIGGER._TP_CRATE, PATH._TP_UP_DIRECTION, false)
		PAnimSetPathFollowSpeed(TRIGGER._TP_CRATE, 1)
	elseif IsButtonPressed(6, 0) then
		--print("=========Elevator SideWays===============")
		PAnimFollowPath(TRIGGER._TP_CRATE, PATH._TP_SIDEWAYS, false)
		PAnimSetPathFollowSpeed(TRIGGER._TP_CRATE, 1)
	elseif IsButtonPressed(7, 0) then
		PAnimFollowPathReset(TRIGGER._TP_CRATE)
		gMissionRunning = false
	end
end
