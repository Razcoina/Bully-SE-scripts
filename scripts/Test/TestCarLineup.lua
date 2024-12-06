ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPlayer.lua")
ImportScript("Library/LibCar.lua")
local tblPlayer, tblCar
local currentCarIndex = 2
local changeInterval = 2000
local scrollDelay = 500
local currentCar

function F_TableInit()
	tblPlayer = {
		startPosition = POINTLIST._TESTCARLINEUP_PLAYER
	}
	tblCar = {
		{
			name = "Van",
			spawnLocation = POINTLIST._TESTCARLINEUP_CAR,
			path = PATH._TESTCARLINEUP,
			model = MODELENUM._Van,
			speed = 0.5
		},
		{
			name = "Truck",
			spawnLocation = POINTLIST._TESTCARLINEUP_CAR,
			path = PATH._TESTCARLINEUP,
			model = MODELENUM._Truck,
			speed = 0.5
		},
		{
			name = "Taxicab",
			spawnLocation = POINTLIST._TESTCARLINEUP_CAR,
			path = PATH._TESTCARLINEUP,
			model = MODELENUM._Taxicab,
			speed = 1
		},
		{
			name = "GoCart",
			spawnLocation = POINTLIST._TESTCARLINEUP_CAR,
			path = PATH._TESTCARLINEUP,
			model = MODELENUM._GoCart,
			speed = 1
		},
		{
			name = "Mower",
			spawnLocation = POINTLIST._TESTCARLINEUP_CAR,
			path = PATH._TESTCARLINEUP,
			model = MODELENUM._Mower,
			speed = 1
		},
		{
			name = "Scooter",
			spawnLocation = POINTLIST._TESTCARLINEUP_CAR,
			path = PATH._TESTCARLINEUP,
			model = MODELENUM._Scooter,
			speed = 0.2
		},
		{
			name = "Dozer",
			spawnLocation = POINTLIST._TESTCARLINEUP_CAR,
			path = PATH._TESTCARLINEUP,
			model = MODELENUM._Dozer,
			speed = 1
		},
		{
			name = "policecar",
			spawnLocation = POINTLIST._TESTCARLINEUP_CAR,
			path = PATH._TESTCARLINEUP,
			model = 295,
			speed = 0.2
		}
	}
end

function MissionSetup()
	DATLoad("TestCarLineup.DAT", 2)
	DATInit()
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	VehicleOverrideAmbient(0, 0, 0, 0)
	F_TableInit()
	L_PlayerLoad(tblPlayer)
end

function MissionCleanup()
	AreaRevertToDefaultPopulation()
	VehicleRevertToDefaultAmbient()
	DATUnload(2)
end

function T_MonitorController()
	local indexChange = 1
	local lastChange = 0
	while true do
		--print("start loop")
		if IsButtonPressed(11, 1) and GetTimer() - lastChange > scrollDelay then
			--print("in L2")
			indexChange = indexChange - 1 > 0 and indexChange - 1 or table.getn(tblCar)
			--print("setting index change to " .. tostring(indexChange))
			TextPrintString("", 0, 2)
			TextPrintString(tblCar[indexChange].name, changeInterval / 1000, 2)
			lastChange = GetTimer()
		end
		if IsButtonPressed(13, 1) and GetTimer() - lastChange > scrollDelay then
			--print("in R2")
			indexChange = indexChange + 1 <= table.getn(tblCar) and indexChange + 1 or 1
			--print("setting index change to " .. tostring(indexChange))
			TextPrintString("", 0, 2)
			TextPrintString(tblCar[indexChange].name, changeInterval / 1000, 2)
			lastChange = GetTimer()
		end
		if currentCarIndex ~= indexChange and GetTimer() - lastChange > changeInterval then
			local currentCar = tblCar[currentCarIndex]
			if currentCar.id ~= nil then
				VehicleDelete(currentCar.id)
				currentCar.id = nil
			end
			currentCarIndex = indexChange
			currentCar = tblCar[currentCarIndex]
			currentCar.id = VehicleCreatePoint(currentCar.model, currentCar.spawnLocation)
			VehicleFollowPath(currentCar.id, currentCar.path)
		end
		Wait(0)
	end
end

function main()
	CreateThread("T_MonitorController")
	while true do
		Wait(0)
	end
end
