local mission_completed = false
local car, ped
local pedmodel = 100
local pedpoint
local carmodel = MODELENUM._PEUGEOT
local carpoint
local pedchoice = 1
local carchoice = 1
local bCirclePressed = false
local bSquarePressed = false
local bLeftArrowPressed = false
local bRightArrowPressed = false
local bUpArrowPressed = false
local bDownArrowPressed = false
local bTrianglePressed = false
local tblCar = {}
local tblPed = {}

function F_TableInit()
	pedpoint = POINTLIST._CARTEST_PED
	carpoint = POINTLIST._CARTEST_CAR
	tblCar = {
		186,
		187,
		188,
		190,
		193,
		194,
		195,
		196,
		197,
		198,
		199
	}
	tblPed = {
		107,
		123,
		123,
		123,
		123,
		143,
		120,
		107,
		83,
		107,
		107
	}
end

function MissionSetup()
	DATLoad("CARTEST.DAT", 2)
	DATInit()
	F_TableInit()
	AreaTransitionPoint(31, POINTLIST._CARTEST_PLAYERSTART)
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	CameraReturnToPlayer()
	while mission_completed == false do
		F_CreateThings()
		Wait(0)
	end
end

function F_CreateThings()
	if IsButtonPressed(8, 0) and ped == nil and not bCirclePressed then
		TextPrintString("New Ped Spawned", 3, 1)
		PedRequestModel(tblPed[pedchoice])
		ped = PedCreatePoint(tblPed[pedchoice], pedpoint, 1)
		bCirclePressed = true
	elseif IsButtonPressed(8, 0) and ped ~= nil and not bCirclePressed then
		TextPrintString("New Ped Spawned", 3, 1)
		PedRequestModel(tblPed[pedchoice])
		if PedIsValid(ped) then
			PedDelete(ped)
		end
		ped = PedCreatePoint(tblPed[pedchoice], pedpoint, 1)
		bCirclePressed = true
	end
	if IsButtonPressed(6, 0) and car == nil and not bSquarePressed then
		TextPrintString("New Car Spawned", 3, 1)
		bSquarePressed = true
		for i = 1, table.getn(tblCar) do
			PedRequestModel(tblPed[i])
			car = VehicleCreatePoint(tblCar[i], carpoint, i)
			ped = PedCreatePoint(tblPed[i], pedpoint, 1)
			PedWarpIntoCar(ped, car)
			VehicleSetCruiseSpeed(car, 0)
			VehicleStop(car)
		end
	end
	if not IsButtonPressed(9, 0) or ped == nil or not bTrianglePressed then
	end
	if IsButtonPressed(1, 0) and not bLeftArrowPressed then
		TextPrintString("Car Model Increased", 3, 1)
		if carchoice < table.getn(tblCar) then
			carchoice = carchoice + 1
		else
			carchoice = 1
		end
		bLeftArrowPressed = true
	end
	if IsButtonPressed(0, 0) and not bRightArrowPressed then
		TextPrintString("Car Model Decreased", 3, 1)
		if carchoice ~= 1 then
			carchoice = carchoice - 1
		else
			carchoice = table.getn(tblCar)
		end
		bRightArrowPressed = true
	end
	if IsButtonPressed(2, 0) and not bUpArrowPressed then
		TextPrintString("Ped Model Increased", 3, 1)
		if pedchoice < table.getn(tblPed) then
			pedchoice = pedchoice + 1
		else
			pedchoice = 1
		end
		bUpArrowPressed = true
	end
	if IsButtonPressed(3, 0) and not bDownArrowPressed then
		TextPrintString("Ped Model Decreased", 3, 1)
		if pedchoice ~= 1 then
			pedchoice = pedchoice - 1
		else
			pedchoice = table.getn(tblPed)
		end
		bDownArrowPressed = true
	end
	if not IsButtonPressed(8, 0) and bCirclePressed then
		bCirclePressed = false
	end
	if not IsButtonPressed(6, 0) and bSquarePressed then
		bSquarePressed = false
	end
	if not IsButtonPressed(0, 0) and bLeftArrowPressed then
		bLeftArrowPressed = false
	end
	if not IsButtonPressed(1, 0) and bRightArrowPressed then
		bRightArrowPressed = false
	end
	if not IsButtonPressed(2, 0) and bUpArrowPressed then
		bUpArrowPressed = false
	end
	if not IsButtonPressed(3, 0) and bDownArrowPressed then
		bDownArrowPressed = false
	end
	if not IsButtonPressed(9, 0) and bTrianglePressed then
		bTrianglePressed = false
	end
end
