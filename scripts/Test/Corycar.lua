function MissionSetup()
	DATLoad("CORYCAR.DAT", 2)
	DATInit()
	AreaTransitionPoint(0, POINTLIST._CORYCAR_PLAYER_START)
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	mission_completed = false
	for i = 262, 275 do
		VehicleRequestModel(i)
	end
	Wait(2000)
	j = 1
	for i = 262, 275 do
		if i == 263 or i == 264 then
		else
			VehicleCreatePoint(i, POINTLIST._CORYCAR_CARS, j)
		end
		j = j + 1
	end
	CameraReturnToPlayer()
	while mission_completed == false do
		if IsButtonPressed(9, 0) then
			mission_completed = true
		end
		Wait(0)
	end
	MissionSucceed()
end
