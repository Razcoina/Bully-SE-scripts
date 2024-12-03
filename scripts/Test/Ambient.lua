local bRAPressed = false
local bLAPressed = false
local bDAPressed = false
local tblScenario = {}
local currentScen = 1
local printScen = 1
local launchScen = 1
local Y = 1
local N = 0

function MissionSetup()
	DATLoad("AS_SCEN.DAT", 2)
	DATInit()
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	F_Init()
	mission_completed = false
	while mission_completed == false do
		if IsButtonPressed(9, 0) then
			mission_completed = true
		end
		F_Scenarios()
		Wait(0)
	end
	MissionSucceed()
end

function F_Scenarios()
	if IsButtonPressed(1, 0) and not bRAPressed then
		currentScen = currentScen + 1
		F_PrintSelectedScenario()
		bRAPressed = true
	elseif not IsButtonPressed(1, 0) and bRAPressed then
		bRAPressed = false
	end
	if IsButtonPressed(0, 0) and not bLAPressed then
		currentScen = currentScen - 1
		F_PrintSelectedScenario()
		bLAPressed = true
	elseif not IsButtonPressed(0, 0) and bLAPressed then
		bLAPressed = false
	end
	if IsButtonPressed(3, 0) and not bDAPressed then
		F_SendPlayerToScenario()
		bDAPressed = true
	elseif not IsButtonPressed(3, 0) and bDAPressed then
		bDAPressed = false
	end
end

function F_SendPlayerToScenario()
	AreaTransitionPoint(tblScenario[currentScen][4], tblScenario[currentScen][8])
	ClockSet(tblScenario[currentScen][6], 0)
end

function F_PrintSelectedScenario()
	currentScen = F_CheckRange(currentScen)
	TextClear()
	TextPrintString(tblScenario[currentScen][2], 3, 1)
	--print("=====  currentScen print ====", currentScen, maxScen)
end

function F_CheckRange(currentScen)
	--print("=====  currentScen Before ====", currentScen, maxScen)
	if currentScen < 1 then
		currentScen = maxScen
	end
	if currentScen > maxScen then
		currentScen = 1
	end
	--print("=====  currentScen After ====", currentScen, maxScen)
	return currentScen
end

function F_Init()
	tblScenario = {
		{
			"1.17.3",
			"Egg Target",
			Y,
			0,
			21,
			9,
			17,
			POINTLIST._AS_EGG
		},
		{
			"1.17.4",
			"Fire Alarm",
			Y,
			2,
			21,
			9,
			15,
			POINTLIST._AS_FIREALARM
		},
		{
			"1.9.1",
			"Bike Jump",
			N,
			0,
			21,
			15,
			18,
			POINTLIST._AS_BIKEJUMP
		},
		{
			"1.9.2",
			"Algie lost his jacket",
			Y,
			0,
			31,
			18,
			21,
			POINTLIST._AS_ALGIEJACKET
		},
		{
			"1.9.3",
			"Lost Dog",
			N,
			0,
			21,
			12,
			15,
			POINTLIST._AS_LOSTDOG
		},
		{
			"1.9.4",
			"Strange Hobo",
			N,
			0,
			31,
			15,
			21,
			POINTLIST._AS_HOBO
		},
		{
			"1.9.5",
			"Detective Jimmy",
			N,
			0,
			41,
			19,
			0,
			POINTLIST._AS_DETECT
		},
		{
			"1.9.6",
			"Prank",
			N,
			0,
			31,
			0,
			0,
			POINTLIST._AS_PRANK
		},
		{
			"1.10.1",
			"Easy Drugs",
			Y,
			0,
			21,
			15,
			21,
			POINTLIST._AS_EASYD
		},
		{
			"1.12.1",
			"Homeless Help",
			N,
			0,
			51,
			19,
			0,
			POINTLIST._AS_HOMELESS
		},
		{
			"1.12.3",
			"Shipping & Receiving",
			N,
			0,
			21,
			0,
			0,
			POINTLIST._AS_SHIPRECV
		},
		{
			"1.0.0",
			"Construction Help",
			N,
			0,
			41,
			9,
			15,
			POINTLIST._AS_CONSTRUCT
		},
		{
			"1.18.1",
			"The Wizard",
			N,
			14,
			11,
			15,
			23,
			POINTLIST._AS_WIZ
		},
		{
			"1.20.1",
			"Crab Traps",
			N,
			0,
			2,
			9,
			3,
			POINTLIST._AS_CRABTRAP
		},
		{
			"1.21.1",
			"Burger Stand Advertising",
			N,
			0,
			2,
			15,
			18,
			POINTLIST._AS_BURGER
		},
		{
			"1.21.2",
			"The Foul Deed",
			N,
			0,
			2,
			15,
			18,
			POINTLIST._AS_FOULDEED
		},
		{
			"1.21.6",
			"Mystery Meat",
			N,
			0,
			2,
			20,
			3,
			POINTLIST._AS_MYSTERY
		}
	}
	maxScen = table.getn(tblScenario)
end
