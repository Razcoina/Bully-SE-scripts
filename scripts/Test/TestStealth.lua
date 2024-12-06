local tblPeds = {}
local bPedsMoving = false
local bStealth = true
local bToggle = true

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
			path = PATH._ST_COP,
			path2 = PATH._ST_COP2,
			path3 = PATH._ST_COP3
		}
	}
	ItemSetCurrentNum(370, 10)
end

function MissionCleanup()
	DATUnload(2)
	AreaRevertToDefaultPopulation()
end

function main()
	local StealthPedID
	local blip = BlipAddXYZ(-100, 56, 26, 0, 1)
	RadarSetIndoorRange(20)
	for i, Entry in tblPeds do
		Entry.id = PedCreatePoint(Entry.model, Entry.point)
		PedSetStealthBehavior(Entry.id, 1, F_OnSightCallback, F_OnHearCallback)
		PedSetStealthVisionHeight(Entry.id, 0.5)
		StealthPedID = Entry.id
	end
	while true do
		if bPedsMoving then
			TextPrintString("Press ~x~ to make cop stop.", 0.1, 2)
		else
			TextPrintString("Press ~x~ to make cop patrol, ~t~ to reset props, ~o~ to return to start.", 0.1, 2)
		end
		if IsButtonPressed(7, 0) then
			PedAttack(StealthPedID, gPlayer, 3)
			Wait(500)
		elseif IsButtonPressed(6, 0) then
			if bPedsMoving then
				F_StopPeds()
			else
				F_MovePeds(0)
			end
			Wait(500)
		elseif IsButtonPressed(8, 0) then
			Wait(500)
		elseif IsButtonPressed(9, 0) then
			Wait(500)
		end
		Wait(0)
	end
end

function F_OnHearCallback(pedId)
	--DebugPrint("The Following Ped Hears The Player: PedID(" .. pedId .. ")")
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
