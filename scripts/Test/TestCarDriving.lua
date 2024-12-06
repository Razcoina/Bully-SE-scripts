local carTable = {
	{ name = "Truck",    model = 297 },
	{ name = "Mower",    model = 284 },
	{ name = "GoCart",   model = 289 },
	{ name = "Dlvtruck", model = 291 },
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
local car_loc = 1
local maxCars = 2
local carCount = table.getn(carTable)
local currentCars = {}

function F_CarSelect()
	while true do
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
				if car_loc < 1 then
					car_loc = carCount
				end
				TextPrintString(carTable[car_loc].name, 2, 2)
				Wait(200)
			elseif IsButtonPressed(2, 0) then
				if table.getn(currentCars) + 1 > maxCars then
					VehicleDelete(currentCars[1])
					table.remove(currentCars, 1)
				end
				local px, py, pz = PlayerGetPosXYZ()
				while not (VehicleRequestModel(carTable[car_loc].model) and PedRequestModel(64)) do
					Wait(0)
				end
				local vecId = VehicleCreateXYZ(carTable[car_loc].model, px, py + 4, pz)
				local pedId = PedCreateXYZ(64, px - 4, py, pz)
				PedWarpIntoCar(pedId, vecId)
				table.insert(currentCars, vecId)
				Wait(2000)
			end
		end
		Wait(0)
	end
end

function MissionSetup()
end

function MissionCleanup()
end

function main()
	CreateThread("F_CarSelect")
	TextPrintString("Hold L2 and press LEFT or right on the D-PAD to select a car", 4, 1)
	Wait(4000)
	TextPrintString("Press UP on the D-PAD to spawn said car and release L2", 4, 1)
end
