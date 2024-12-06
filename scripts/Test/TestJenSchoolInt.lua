function MissionSetup()
	DATLoad("TestJenSchool.DAT", 2)
	DATInit()
	AreaTransitionPoint(2, POINTLIST._TJS_INT_PSTART)
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	tblPeds = {
		{
			id = nil,
			point = POINTLIST._TJS_INT_01,
			model = 55,
			path = PATH._TJS_INT_01
		},
		{
			id = nil,
			point = POINTLIST._TJS_INT_02,
			model = 4,
			path = PATH._TJS_EIN_02
		},
		{
			id = nil,
			point = POINTLIST._TJS_INT_03,
			model = 49,
			path = PATH._TJS_INT_03
		},
		{
			id = nil,
			point = POINTLIST._TJS_INT_04,
			model = 63,
			path = PATH._TJS_INT_04
		},
		{
			id = nil,
			point = POINTLIST._TJS_INT_05,
			model = 64,
			path = PATH._TJS_INT_05
		},
		{
			id = nil,
			point = POINTLIST._TJS_INT_06,
			model = 3,
			path = PATH._TJS_INT_06
		}
	}
end

function MissionCleanup()
	DATUnload(2)
	AreaRevertToDefaultPopulation()
end

function main()
	for i, Entry in tblPeds do
		Entry.id = PedCreatePoint(Entry.model, Entry.point)
		PedSetInvulnerable(Entry.id, true)
		PedIgnoreStimuli(Entry.id, true)
	end
	while true do
		if bPedsMoving then
			TextPrintString("Press ~x~ to make peds stop.", 0.1, 2)
		else
			TextPrintString("Press ~x~ to make peds walk, ~s~ to run, ~t~ to sprint, ~o~ to return to start.", 0.1, 2)
		end
		if IsButtonPressed(7, 0) then
			--DebugPrint("************************************************ x pressed.")
			if bPedsMoving then
				--DebugPrint("************************************************ peds moving, telling to stop")
				F_StopPeds()
				Wait(500)
			else
				--DebugPrint("************************************************ peds stopped, telling to walk.")
				F_MovePeds(0)
				Wait(500)
			end
		elseif IsButtonPressed(6, 0) then
			--DebugPrint("************************************************ telling peds to run.")
			F_MovePeds(1)
			Wait(500)
		elseif IsButtonPressed(9, 0) then
			--DebugPrint("************************************************ telling peds to sprint.")
			F_MovePeds(2)
			Wait(500)
		elseif IsButtonPressed(8, 0) then
			--DebugPrint("************************************************ returning to start point.")
			F_ReturnToStart()
			Wait(500)
		end
		Wait(0)
	end
end

function F_MovePeds(idSpeed)
	--DebugPrint("************************************************ move peds called w/ speed = " .. tostring(idSpeed))
	for i, Entry in tblPeds do
		if Entry.id ~= nil then
			PedFollowPath(Entry.id, Entry.path, 1, idSpeed)
		end
	end
	bPedsMoving = true
end

function F_StopPeds()
	--DebugPrint("************************************************ stop peds called.")
	for i, Entry in tblPeds do
		if Entry.id ~= nil then
			PedStop(Entry.id)
		end
	end
	bPedsMoving = false
end

function F_ReturnToStart()
	--DebugPrint("************************************************ returning to start called.")
	for i, Entry in tblPeds do
		if Entry.id ~= nil then
			PedMoveToPoint(Entry.id, 0, Entry.point)
		end
	end
	bPedsMoving = false
end
