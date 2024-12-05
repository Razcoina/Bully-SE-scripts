ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
local testPed, objectiveTable, objectiveCount
local obj_loc = 1

function F_TableInit()
	testPed = {
		{
			startOnBike = true,
			model = 32,
			point = POINTLIST._TBUH_BACKWARDBIKE,
			bike = {
				model = 273,
				point = POINTLIST._TBUH_BACKWARDPED
			},
			path = PATH._TBUH_UPHILLFORWARD,
			followType = 2
		},
		{
			startOnBike = true,
			model = 30,
			point = POINTLIST._TBUH_FORWARDBIKE,
			bike = {
				model = 273,
				point = POINTLIST._TBUH_FORWARDPED
			},
			path = PATH._TBUH_UPHILLBACKWARD,
			followType = 2
		}
	}
	objectiveTable = {
		{
			name = "Turn and Go Up Hill (slow)",
			exec = F_PedTurnAndGoUpHillSlow
		},
		{
			name = "Turn and Go Up Hill (normal)",
			exec = F_PedTurnAndGoUpHillNormal
		},
		{
			name = "Turn and Go Up Hill (fast)",
			exec = F_PedTurnAndGoUpHillFast
		},
		{
			name = "Go Up Hill (slow)",
			exec = F_PedGoUpHillSlow
		},
		{
			name = "Go Up Hill (normal)",
			exec = F_PedGoUpHillNormal
		},
		{
			name = "Go Up Hill (fast)",
			exec = F_PedGoUpHillFast
		}
	}
end

function F_PedTurnAndGoUpHillSlow()
	PedFollowPath(testPed[1].id, testPed[1].path, testPed[1].followType, 0)
end

function F_PedTurnAndGoUpHillNormal()
	PedFollowPath(testPed[1].id, testPed[1].path, testPed[1].followType, 1)
end

function F_PedTurnAndGoUpHillFast()
	PedFollowPath(testPed[1].id, testPed[1].path, testPed[1].followType, 2)
end

function F_PedGoUpHillSlow()
	PedFollowPath(testPed[2].id, testPed[1].path, testPed[1].followType, 0)
end

function F_PedGoUpHillNormal()
	PedFollowPath(testPed[2].id, testPed[1].path, testPed[1].followType, 1)
end

function F_PedGoUpHillFast()
	PedFollowPath(testPed[2].id, testPed[1].path, testPed[1].followType, 2)
end

function MissionSetup()
	DATLoad("tags.DAT", 2)
	DATLoad("TestBikeObjectives.DAT", 2)
	DATInit()
	F_TableInit()
	objectiveCount = table.getn(objectiveTable)
	AreaTransitionPoint(22, POINTLIST._TBUH_PLAYER)
	L_PedLoadPoint("testPed", testPed)
end

function MissionCleanup()
	MissionFail()
	DATUnload(2)
end

function main()
	while true do
		if IsButtonPressed(11, 0) then
			if IsButtonPressed(1, 0) then
				obj_loc = obj_loc + 1
				if obj_loc > objectiveCount then
					obj_loc = 1
				end
				TextPrintString(objectiveTable[obj_loc].name, 2, 2)
				Wait(200)
			elseif IsButtonPressed(0, 0) then
				obj_loc = obj_loc - 1
				if obj_loc < 1 then
					obj_loc = objectiveCount
				end
				TextPrintString(objectiveTable[obj_loc].name, 2, 2)
				Wait(200)
			elseif IsButtonPressed(2, 0) then
				objectiveTable[obj_loc].exec()
			end
		end
		Wait(0)
	end
end
