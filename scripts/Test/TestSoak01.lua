local paths = {}
local gCutscenes = {
	"1-01",
	"1-02B",
	"1-02D",
	"1-02E",
	"1-03",
	"1-04",
	"1-05",
	"1-06",
	"1-06B",
	"1-07",
	"1-08",
	"1-09",
	"1-10",
	"1-11",
	"1-B",
	"1-BB",
	"1-BC",
	"2-01",
	"2-02",
	"2-03",
	"2-03b",
	"2-04",
	"2-05",
	"2-06",
	"2-07",
	"2-08",
	"2-09",
	"2-09B",
	"3-01",
	"3-02",
	"3-03",
	"3-04",
	"3-04B",
	"3-05",
	"3-06",
	"4-01",
	"4-02",
	"4-03",
	"4-04",
	"4-05",
	"4-06",
	"5-01",
	"5-02",
	"5-02B",
	"5-03",
	"5-04",
	"5-05",
	"5-06",
	"5-07",
	"5-09",
	"5-09B",
	"6-02",
	"6-02B",
	"1-G1",
	"1-S01",
	"2-B",
	"2-BB",
	"2-0",
	"2-S02",
	"2-S04",
	"2-S05",
	"2-S05B",
	"2-S05C",
	"2-S06",
	"2-G2",
	"3-B",
	"3-BB",
	"3-BC",
	"3-0",
	"3-G3",
	"3-S03",
	"3-S10",
	"3-S11",
	"3-S11C",
	"4-B1",
	"4-B1B",
	"4-B1C",
	"4-B1D",
	"4-B2",
	"4-B2B",
	"4-G4",
	"4-S12",
	"4-S12B",
	"4-0",
	"5-0",
	"5-05B",
	"5-B",
	"5-G5",
	"6-0",
	"6-B",
	"6-BB",
	"6-BC"
}
local currentCutscene = math.random(1, 80)
local maxCutscenes = 99

function MissionSetup()
	DATLoad("TestPath.DAT", 2)
	DATInit()
	GeometryInstance("ScGate01Closed", true, 301.439, -72.5059, 8.04657, false)
	AreaSetPathableInRadius(303.1998, -72.23503, 5.583573, 0.5, 3, true)
	GeometryInstance("ScGate02Closed", true, 225.928, 5.79816, 8.39471, false)
	AreaSetPathableInRadius(226.3478, 5.853811, 5.758574, 0.5, 3, true)
end

function MissionCleanup()
	PedSetGlobalAttitude_Rumble(false)
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	missionRunning = false
	DATUnload(2)
end

function SetupPathData()
	paths = {
		{
			path = PATH._GLOBALTESTPATH,
			point = POINTLIST._GLOBALTESTPLAYER,
			area = 0
		},
		{
			path = PATH._GLOBALTESTPATH2,
			point = POINTLIST._GLOBALTESTPLAYER2,
			area = 2
		},
		{
			path = PATH._GLOBALTESTPATH3,
			point = POINTLIST._GLOBALTESTPLAYER3,
			area = 0
		},
		{
			path = PATH._GLOBALTESTPATH4,
			point = POINTLIST._GLOBALTESTPLAYER4,
			area = 35
		},
		{
			path = PATH._GLOBALTESTPATH5,
			point = POINTLIST._GLOBALTESTPLAYER5,
			area = 13
		},
		{
			path = PATH._GLOBALTESTPATH6,
			point = POINTLIST._GLOBALTESTPLAYER6,
			area = 0
		},
		{
			path = PATH._GLOBALTESTPATH7,
			point = POINTLIST._GLOBALTESTPLAYER7,
			area = 36
		}
	}
	totalPaths = table.getn(paths)
end

function SetupExtras()
	local factions = {
		11,
		3,
		4,
		2,
		1,
		5,
		6,
		8,
		9
	}
	for i, factionA in factions do
		--print("FACTION:", factionA)
		PedSetTypeToTypeAttitude(factionA, 13, 0)
		for j, factionB in factions do
			PedSetTypeToTypeAttitude(factionA, factionB, 0)
		end
	end
	PedSetGlobalAttitude_Rumble(true)
end

function main()
	SetupPathData()
	SetupExtras()
	local missionRunning = true
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	local outside = true
	local waiting = false
	local pathNumber = math.random(1, totalPaths)
	local x, y, z = GetPointList(paths[pathNumber].point)
	while missionRunning do
		if waiting then
			if PlayerIsInAreaXYZ(x, y, z, 5, 0) then
				waiting = false
				PedStop(gPlayer)
				PedClearObjectives(gPlayer)
				pathNumber = pathNumber + 1
				if pathNumber > totalPaths then
					pathNumber = 1
				end
				x, y, z = GetPointList(paths[pathNumber].point)
			end
		else
			if paths[pathNumber].area == 0 then
				currentCutscene = currentCutscene + 1
				if currentCutscene > maxCutscenes then
					currentCutscene = 1
				end
				PlayCutsceneWithLoad(gCutscenes[currentCutscene])
			end
			AreaTransitionPoint(paths[pathNumber].area, paths[pathNumber].point)
			while AreaIsLoading() do
				Wait(0)
			end
			PedFollowPath(gPlayer, paths[pathNumber].path, 0, 3)
			Wait(10000)
			waiting = true
		end
		Wait(0)
	end
end
