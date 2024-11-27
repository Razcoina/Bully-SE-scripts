function main()
	DATLoad("eventsClassroom.DAT", 1)
	DATLoad("SP_ClassRoom.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDataLoaded = true
	shared.gAreaDATFileLoaded[15] = true
	while not (AreaGetVisible() ~= 15 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	collectgarbage()
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[15] = false
end
