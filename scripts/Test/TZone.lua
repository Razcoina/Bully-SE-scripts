local mission_started = false

function MissionSetup()
	--DebugPrint("**************************************************** mission setup called")
	local area, x, y, z
	if AreaGetVisible() == 0 then
		x, y, z = GetPointList(POINTLIST._NEXT_TO_BED)
		area = 14
		--DebugPrint("**************************************************** going to send you to boys dorm")
	elseif AreaGetVisible() == 14 then
		x, y, z = GetPointList(POINTLIST._PLAYER_START)
		area = 0
		--DebugPrint("**************************************************** going to send you to main map")
	elseif AreaGetVisible() == 22 then
		x = 0
		y = 0
		z = 15
		area = 31
		--DebugPrint("**************************************************** going to send you to test area")
	elseif AreaGetVisible() == 31 then
		x = -9.988
		y = 21.42
		z = 30
		area = 22
		--DebugPrint("**************************************************** going to send you to fight area")
	end
	--DebugPrint("**************************************************** doing the area transition")
	AreaTransitionXYZ(area, x, y, z)
	mission_started = true
	--DebugPrint("**************************************************** done with MissionSetup")
end

function MissionCleanup()
	mission_started = false
	--DebugPrint("**************************************************** mission cleanup called")
end

function main()
	--DebugPrint("**************************************************** main called")
	while mission_started do
		Wait(0)
	end
end
