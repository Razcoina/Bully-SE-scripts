local tblPeds = {}
local bPedsMoving = false
local bStealth = true

function MissionSetup()
	DATLoad("SpawnTest.DAT", 2)
	DATInit()
	AreaTransitionPoint(22, POINTLIST._ST_PLAYER)
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	tblPeds = {
		{
			id = nil,
			point = POINTLIST._ST_COP,
			model = 83,
			path = PATH._ST_COP
		}
	}
	MissionObjectiveAdd("TEST10")
	MissionObjectiveAdd("TEST9")
	MissionObjectiveAdd("TEST8")
	MissionObjectiveAdd("TEST7")
	MissionObjectiveAdd("TEST6")
	MissionObjectiveAdd("TEST5")
	MissionObjectiveAdd("TEST4")
	local c = MissionObjectiveAdd("TEST3", 2)
	MissionObjectiveUpdateParam(c, 1, 3.5)
	MissionObjectiveUpdateParam(c, 2, 7.5)
	local b = MissionObjectiveAdd("TEST2", 2)
	MissionObjectiveUpdateParam(b, 1, 3)
	MissionObjectiveUpdateParam(b, 2, 7)
	local a = MissionObjectiveAdd("TEST1", 2)
	MissionObjectiveUpdateParam(a, 1, "PARAM1")
	MissionObjectiveUpdateParam(a, 2, "PARAM2")
	MissionObjectiveComplete(a)
	MissionObjectiveComplete(c)
	CollectiblesSetTypeAvailable(0)
	ItemSetCurrentNum(385, 1000)
end

function MissionCleanup()
	DATUnload(2)
	AreaRevertToDefaultPopulation()
end

function main()
	for i, Entry in tblPeds do
		Entry.id = PedCreatePoint(Entry.model, Entry.point)
		PedSetStealthBehavior(Entry.id, 1, F_OnSightCallback)
	end
	while true do
		if bPedsMoving then
			TextPrintString("Press ~x~ to make cop stop.", 0.1, 2)
		else
			TextPrintString("Press ~x~ to make cop patrol, ~t~ to reset props, ~o~ to return to start.", 0.1, 2)
		end
		if IsButtonPressed(7, 1) then
			if bPedsMoving then
				F_StopPeds()
				Wait(500)
			else
				F_MovePeds(0)
				Wait(500)
			end
		elseif IsButtonPressed(9, 1) then
			F_RestoreProps()
			Wait(500)
		elseif IsButtonPressed(8, 1) then
			F_ReturnToStart()
			Wait(500)
		elseif IsButtonPressed(15, 1) then
			for i, Entry in tblPeds do
				if Entry.id ~= nil then
					bStealth = not bStealth
					PedSetIsStealthMissionPed(Entry.id, bStealth)
				end
			end
		end
		Wait(0)
	end
end

function F_OnSightCallback(pedId)
	--DebugPrint("The Following Ped Sees The Player: PedID(" .. pedId .. ")")
end

function F_MovePeds(idSpeed)
	for i, Entry in tblPeds do
		if Entry.id ~= nil then
			PedFollowPath(Entry.id, Entry.path, 2, idSpeed, F_T1, 0, F_T2, F_T3)
		end
	end
	bPedsMoving = true
end

function F_T1(pedId, pathId, pathNode)
	--DebugPrint("ENTERNODE: PedID(" .. pedId .. ") pathId(" .. pathId .. ") pathNode(" .. pathNode .. ")")
end

function F_T2(pedId, pathId, pathNode)
	--DebugPrint("EXITNODE: PedID(" .. pedId .. ") pathId(" .. pathId .. ") pathNode(" .. pathNode .. ")")
end

function F_T3(pedId, pathId, pathNode, pathPointAction)
	--DebugPrint("PATHPOINTACTION: PedID(" .. pedId .. ") pathId(" .. pathId .. ") pathNode(" .. pathNode .. ") pathPointAction(" .. pathPointAction .. ")")
end

function F_StopPeds()
	for i, Entry in tblPeds do
		if Entry.id ~= nil then
			PedStop(Entry.id)
		end
	end
	bPedsMoving = false
end

function F_ReturnToStart()
	for i, Entry in tblPeds do
		if Entry.id ~= nil then
			PedMoveToPoint(Entry.id, 0, Entry.point)
		end
	end
	bPedsMoving = false
end

function F_RestoreProps()
	if PAnimIsDestroyed(TRIGGER._ST_CRATE_01) then
		PAnimCreate(TRIGGER._ST_CRATE_01)
	end
	if PAnimIsDestroyed(TRIGGER._ST_CRATE_02) then
		PAnimCreate(TRIGGER._ST_CRATE_02)
	end
	if PAnimIsDestroyed(TRIGGER._ST_CRATE_03) then
		PAnimCreate(TRIGGER._ST_CRATE_03)
	end
end
