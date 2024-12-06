local test = 0

function MissionSetup()
	--DebugPrint("enter MissionSetup()")
	test = 1
	PrintTest()
	AreaTransitionPoint(0, POINTLIST._PLAYER_START)
	TextPrintString("TEST MISSION 1 : SETUP", 5)
	test = 2
	PrintTest()
	--DebugPrint("leave MissionSetup()")
end

function PrintTest()
	if test == 0 then
		--DebugPrint("test is 0")
	end
	if test == 1 then
		--DebugPrint("test is 1")
	end
	if test == 2 then
		--DebugPrint("test is 2")
	end
end

function main()
	--DebugPrint("enter main()")
	PrintTest()
	TextPrintString("TEST MISSION 1 : MAIN", 5)
	while true do
		Wait(0)
		local x, y, z = GetPointList(POINTLIST._TESTMIS1_SUCCESS)
		if PlayerIsInAreaXYZ(x, y, z, 1, CORONATYPE_NEXTCLASS) then
			TextPrintString("TEST MISSION 1 : Mission Success", 5)
			--DebugPrint("call MissionSucceed()")
			MissionSucceed()
			--DebugPrint("retfrom MissionSucceed()")
		end
		x, y, z = GetPointList(POINTLIST._TESTMIS1_FAILURE)
		if PlayerIsInAreaXYZ(x, y, z, 1, CORONATYPE_NEXTCLASS) then
			TextPrintString("TEST MISSION 1 : Mission Fail", 5)
			--DebugPrint("call MissionFail()")
			MissionFail()
			--DebugPrint("retfrom MissionFail()")
		end
	end
	--DebugPrint("leave main()")
end

function MissionCleanup()
	--DebugPrint("enter MissionCleanup()")
	PrintTest()
	TextPrintString("TEST MISSION 1 : CLEANUP", 5)
	test = 0
	PrintTest()
	--DebugPrint("leave MissionCleanup()")
end
