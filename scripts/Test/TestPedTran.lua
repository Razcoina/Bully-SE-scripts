ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
local testPeds

function F_TableInit()
	testPeds = {
		{
			model = 33,
			point = POINTLIST._TESTPEDTRANPED1
		},
		{
			model = 38,
			point = POINTLIST._TESTPEDTRANPED2
		},
		{
			model = 30,
			point = POINTLIST._TESTPEDTRANPED3
		},
		{
			model = 31,
			point = POINTLIST._TESTPEDTRANPED4
		},
		{
			model = 64,
			point = POINTLIST._TESTPEDTRANPED5
		},
		{
			model = 57,
			point = POINTLIST._TESTPEDTRANPED6
		},
		{
			model = 61,
			point = POINTLIST._TESTPEDTRANPED7
		},
		{
			model = 23,
			point = POINTLIST._TESTPEDTRANPED8
		}
	}
end

function MissionSetup()
	DATLoad("TestPedTran.DAT", 2)
	DATInit()
	F_TableInit()
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	AreaTransitionPoint(14, POINTLIST._TESTPEDTRANPLAYERDORM)
	L_PedLoadPoint("testPeds", testPeds)
	TextPrintString("Press R3 to transition player to Main Map", 4)
	while not IsButtonPressed(15, 0) do
		Wait(0)
	end
	AreaTransitionPoint(0, POINTLIST._TESTPEDTRANPLAYERMAIN)
	CameraSetPath(PATH._TESTPEDTRANCAM, true)
	local x, y, z = GetPointList(POINTLIST._TESTPEDTRANPED3)
	CameraLookAtXYZ(x, y, z, true)
	TextPrintString("Press R3 end script", 4)
	while not IsButtonPressed(15, 0) do
		Wait(0)
	end
	MissionFail()
end
