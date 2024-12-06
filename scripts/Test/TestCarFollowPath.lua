local carTable = {
	{ name = "Truck",     model = 297 },
	{
		name = "Peugeot",
		model = MODELENUM._PEUGEOT
	},
	{ name = "cargreen",  model = 293 },
	{ name = "70wagon",   model = 294 },
	{ name = "policecar", model = 295 },
	{
		name = "escort",
		model = MODELENUM._ESCORT
	},
	{
		name = "Jimmy",
		model = MODELENUM._JIMMY
	}
}
local car

function F_CarSelect()
	if IsButtonPressed(11, 0) then
		if IsButtonPressed(1, 0) then
			car_loc = car_loc + 1
			if car_loc > carCount then
				car_loc = 1
			end
			TextPrintString(carTable[car_loc].name, 2, 2)
			Wait(200)
		elseif IsButtonPressed(0, 0) then
			car_loc = car_loc - 1
			if 1 > car_loc then
				car_loc = carCount
			end
			TextPrintString(carTable[car_loc].name, 2, 2)
			Wait(200)
		elseif IsButtonPressed(2, 0) then
			if car and VehicleIsValid(car) then
				VehicleDelete(car)
			end
			local px, py, pz = GetPointFromPointList(POINTLIST._CARSTARTPOINT, 1)
			while not (VehicleRequestModel(carTable[car_loc].model) and PedRequestModel(64)) do
				Wait(0)
			end
			local car = VehicleCreatePoint(carTable[car_loc].model, POINTLIST._CARSTARTPOINT, 1)
			local pedId = PedCreateXYZ(64, px - 4, py, pz)
			PedWarpIntoCar(pedId, car)
			Wait(2000)
			VehicleFollowPath(car, PATH._CARPATH)
		end
	end
	Wait(0)
end

function MissionSetup()
end

function MissionCleanup()
end

function main()
	DATLoad("TestCarPath.DAT", 2)
	TextPrintString("Hold L2 and press LEFT or right on the D-PAD to select a car", 4, 1)
	Wait(4000)
	TextPrintString("Press UP on the D-PAD to spawn said car and release L2", 4, 1)
	while true do
		F_CarSelect()
	end
end
