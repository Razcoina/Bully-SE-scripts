local car = 0
local ped = 0
local mission_completed = false
local bCop = false
local bNewModel = false
local bPressLeft = false
local ped = -1
local bChangeCars = false
local bCopCar = true
local cInd = 1
local bPressDown = false
local bCopCars = false

function MissionSetup()
	DATLoad("ENTERCAR.DAT", 2)
	DATInit()
	AreaTransitionPoint(31, POINTLIST._ENTERCAR_PLAYER)
	PlayerSetPosSimple(142.9, 56.5, 14.5)
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	tblPeds = { 83, 79 }
	tblCars = {
		286,
		294,
		292,
		293,
		296,
		297
	}
	tblPCars = { 295, 297 }
	LoadPedModels(tblPeds)
	F_LoadCars(tblCars)
	F_LoadCars(tblPCars)
	ped = PedCreatePoint(79, POINTLIST._ENTERCAR_PLAYER)
	car = VehicleCreatePoint(286, POINTLIST._ENTERCAR_CAR)
	CameraReturnToPlayer()
	while MissionActive() do
		F_ChangeCars()
		F_EnterCar()
		F_SelectCar()
		F_PickPed()
		F_NewModel()
		F_Reset()
		Wait(0)
	end
	MissionSucceed(false, false, false)
	MissionCleanup()
end

function F_Reset()
end

function F_ChangeCars()
	if IsButtonPressed(1, 0) and bPressRight then
		if bCopCars then
			if bCopCar then
				VehicleDelete(car)
				car = VehicleCreatePoint(297, POINTLIST._ENTERCAR_CAR)
				bCopCar = false
			else
				VehicleDelete(car)
				car = VehicleCreatePoint(295, POINTLIST._ENTERCAR_CAR)
				bCopCar = true
			end
		else
			cInd = cInd + 1
			if cInd > table.getn(tblCars) then
				cInd = 1
			end
			VehicleDelete(car)
			car = VehicleCreatePoint(tblCars[cInd], POINTLIST._ENTERCAR_CAR)
		end
		bPressRight = false
	end
	if not IsButtonPressed(1, 0) and not bPressRight then
		bPressRight = true
	end
end

function F_SelectCar()
	if IsButtonPressed(3, 0) and bPressDown then
		if bCopCars then
			if bCopCar then
				VehicleDelete(car)
				car = VehicleCreatePoint(297, POINTLIST._ENTERCAR_CAR)
				bCopCar = false
			else
				VehicleDelete(car)
				car = VehicleCreatePoint(295, POINTLIST._ENTERCAR_CAR)
				bCopCar = true
			end
			bCopCars = false
		else
			VehicleDelete(car)
			car = VehicleCreatePoint(tblCars[cInd], POINTLIST._ENTERCAR_CAR)
			bCopCars = true
		end
		bPressDown = false
	end
	if not IsButtonPressed(3, 0) and not bPressDown then
		bPressDown = true
	end
end

local bPressX = true

function F_EnterCar()
	if IsButtonPressed(7, 0) and bPressX then
		if not PedIsInAnyVehicle(ped) then
			PedEnterVehicle(ped, car)
		else
			PedExitVehicle(ped)
		end
		bPressX = false
	end
	if not IsButtonPressed(7, 0) and not bPressX then
		bPressX = true
	end
end

function F_PickPed()
	if IsButtonPressed(0, 0) and bPressLeft then
		if bCop then
			bCop = false
			model = 79
		else
			bCop = true
			model = 83
		end
		bNewModel = true
		bPressLeft = false
	end
	if not IsButtonPressed(0, 0) and not bPressLeft then
		bPressLeft = true
	end
end

function F_NewModel()
	if bNewModel then
		PedDelete(ped)
		ped = PedCreatePoint(model, POINTLIST._ENTERCAR_PLAYER)
		bNewModel = false
	end
end

function F_LoadCars(tbl)
	for c, car in tbl do
		while not VehicleRequestModel(car) do
			Wait(0)
		end
	end
end
