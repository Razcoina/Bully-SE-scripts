function main()
	CameraFade(1000, 0)

	Wait(1000)
	CameraFade(1000, 1)
	TextPrintString("TEST MISSION 3 : Just walk through the triggers!", 5)
	AreaTransitionPoint(0, POINTLIST._PLAYER_START)
	while true do
		Wait(0)
		local x, y, z = GetPointList(POINTLIST._TESTMIS3_SUCCESS)
		if PlayerIsInAreaXYZ(x, y, z, 1, CORONATYPE_NEXTCLASS) then
			TextPrintString("TEST MISSION 3 : Mission Success", 5)
			MissionSucceed()
			Wait(3000)
			break
		end
		x, y, z = GetPointList(POINTLIST._TESTMIS3_FAILURE)
		if PlayerIsInAreaXYZ(x, y, z, 1, CORONATYPE_NEXTCLASS) then
			TextPrintString("TEST MISSION 3 : Mission Fail", 5)
			MissionFail()
			Wait(3000)
			break
		end
	end
	CameraFade(1000, 0)
	Wait(3000)
	CameraFade(1000, 1)
	Wait(0)
end
