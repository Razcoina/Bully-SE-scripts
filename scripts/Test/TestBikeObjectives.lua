ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPlayer.lua")
ImportScript("Library/LibPed.lua")
local testPed, tblPlayer, objectiveTable, objectiveCount
local obj_loc = 1
local testAuthority

function F_TableInit()
	tblPlayer = {
		startPosition = POINTLIST._TESTBIKEPLAYER,
		bike = {
			model = 273,
			location = POINTLIST._TESTBIKEPLAYERBIKE,
			startOnBike = false
		}
	}
	testPed = {
		{
			model = 12,
			point = POINTLIST._TESTBIKEPED1,
			blipStyle = 1,
			radarIcon = 2,
			weapon = { model = 357, ammo = 1 },
			destination1 = POINTLIST._TESTBIKEPOINT1,
			destination2 = POINTLIST._TESTBIKEPOINT2,
			pathCircular = PATH._TESTBIKECIRCULAR,
			pathToAndFro = PATH._TESTBIKELINEAR,
			pathToEnd = PATH._TESTBIKECIRCULAR,
			pathFlee = PATH._TESTBIKECIRCULAR,
			angle = 90,
			startOnBike = false,
			ignoreStimuli = true,
			bike = {
				model = 273,
				point = POINTLIST._TESTBIKEBIKE1
			},
			stat = {
				{ name = 15, value = 100 },
				{ name = 9,  value = 100 }
			}
		},
		{
			model = 164,
			point = POINTLIST._TESTBIKEPED2,
			blipStyle = 1,
			radarIcon = 2,
			startOnBike = true,
			ignoreStimuli = true,
			bike = {
				model = 273,
				point = POINTLIST._TESTBIKEBIKE2
			}
		},
		{
			model = 168,
			point = POINTLIST._TESTBIKEPED3,
			blipStyle = 1,
			radarIcon = 2,
			startOnBike = true,
			ignoreStimuli = true,
			bike = {
				model = 273,
				point = POINTLIST._TESTBIKEBIKE3
			}
		}
	}
	testAuthority = {
		model = 50,
		point = POINTLIST._TESTBIKEAUTHORITY,
		path = PATH._TESTBIKEAUTHORITY
	}
	object1 = {
		model = 95,
		point = POINTLIST._TESTBIKEOBJECT1
	}
	object2 = {
		model = 94,
		point = POINTLIST._TESTBIKEOBJECT2
	}
	objectiveTable = {
		{
			name = "PedClearObjectives",
			exec = F_PedClearObjectives
		},
		{
			name = "PedEnterVehicle",
			exec = F_PedEnterVehicle
		},
		{
			name = "PedExitVehicle",
			exec = F_PedExitVehicle
		},
		{
			name = "PedAttackPlayer",
			exec = F_PedAttackPlayer
		},
		{
			name = "PedMoveToPoint1",
			exec = F_PedMoveToPoint1
		},
		{
			name = "PedMoveToPoint2",
			exec = F_PedMoveToPoint2
		},
		{
			name = "PedMoveToObject1",
			exec = F_PedMoveToObject1
		},
		{
			name = "PedMoveToObject2",
			exec = F_PedMoveToObject2
		},
		{
			name = "PedFaceHeading",
			exec = F_PedFaceHeading
		},
		{
			name = "PedFleeOnPathOnBike",
			exec = F_PedFleeOnPathOnBike
		},
		{
			name = "PedFleeOnRoadOnBike",
			exec = F_PedFleeOnRoadOnBike
		},
		{ name = "PedFlee",   exec = F_PedFlee },
		{
			name = "PedFollowPath (to and fro)",
			exec = F_PedFollowPathToAndFro
		},
		{
			name = "PedFollowPath (circular)",
			exec = F_PedFollowPathCircular
		},
		{
			name = "PedFollowPath (to end)",
			exec = F_PedFollowPathToEnd
		},
		{
			name = "PedFollowFocus",
			exec = F_PedFollowFocus
		},
		{ name = "PedStop",   exec = F_PedStop },
		{ name = "PedWander", exec = F_PedWander },
		{
			name = "PedLockTarget",
			exec = F_PedLockTarget
		},
		{
			name = "PedGroupCombat",
			exec = F_PedGroupCombat
		}
	}
end

function F_PedClearObjectives()
	PedClearObjectives(testPed[1].id)
end

function F_PedEnterVehicle()
	PedEnterVehicle(testPed[1].id, testPed[1].bike.id)
end

function F_PedExitVehicle()
	PedExitVehicle(testPed[1].id)
end

function F_PedAttackPlayer()
	PedSetFocus(testPed[1].id, gPlayer)
	PedAttack(testPed[1].id, gPlayer, true, false)
end

function F_PedMoveToPoint1()
	PedMoveToPoint(testPed[1].id, 2, testPed[1].destination1)
end

function F_PedMoveToPoint2()
	PedMoveToPoint(testPed[1].id, 2, testPed[1].destination2)
end

function F_PedMoveToObject1()
	PedMoveToObject(testPed[1].id, object1.id, 2, 2)
end

function F_PedMoveToObject2()
	PedMoveToObject(testPed[1].id, object2.id, 2, 2)
end

function F_PedFaceHeading()
	PedFaceHeading(testPed[1].id, testPed[1].angle, 1)
end

function F_PedFleeOnPathOnBike()
	PedSetFocus(testPed[1].id, gPlayer)
	PedFleeOnPathOnBike(testPed[1].id, testPed[1].pathFlee, 1)
end

function F_PedFleeOnRoadOnBike()
	PedSetFocus(testPed[1].id, gPlayer)
	PedFleeOnRoadOnBike(testPed[1].id)
end

function F_PedFlee()
	PedFlee(testPed[1].id, gPlayer)
end

function F_PedFollowPathToAndFro()
	PedFollowPath(testPed[1].id, testPed[1].pathToAndFro, 2, 2)
end

function F_PedFollowPathCircular()
	PedFollowPath(testPed[1].id, testPed[1].pathCircular, 1, 2)
end

function F_PedFollowPathToEnd()
	PedFollowPath(testPed[1].id, testPed[1].pathToEnd, 0, 2)
end

function F_PedFollowFocus()
	PedFollowFocus(testPed[1].id, gPlayer)
end

function F_PedStop()
	PedStop(testPed[1].id)
end

function F_PedWander()
	PedWander(testPed[1].id, 0)
end

function F_PedLockTarget()
	PedLockTarget(testPed[1].id, gPlayer)
end

function F_PedGroupCombat()
	for i, ped in testPed do
		PedAttack(ped.id, gPlayer, 3)
	end
end

function MissionSetup_visible()
	DATLoad("tags.DAT", 2)
	DATLoad("TestBikeObjectives.DAT", 2)
	DATInit()
	F_TableInit()
	objectiveCount = table.getn(objectiveTable)
	L_PlayerLoad(tblPlayer)
	--print("loaded player")
	L_PedLoadPoint("testPed", testPed)
	L_PedCreate(object1)
	L_PedCreate(object2)
	L_PedCreate(testAuthority)
	PedFollowPath(testAuthority.id, testAuthority.path, 2, 0)
end

function MissionSetup()
end

function MissionCleanup()
	MissionFail()
	DATUnload(2)
end

function main()
	MissionSetup_visible()
	PedIgnoreAttacks(testPed[1].id, true)
	PedIgnoreAttacks(testPed[2].id, true)
	PedIgnoreAttacks(testPed[3].id, true)
	PedSetHealth(testPed[1].id, 10000)
	PedSetHealth(testPed[2].id, 10000)
	PedSetHealth(testPed[3].id, 10000)
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
