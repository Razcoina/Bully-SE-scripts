function main()
	DATLoad("eventsAuditorium.DAT", 0)
	DATLoad("SP_Auditorium.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDATFileLoaded[19] = true
	shared.gAreaDataLoaded = true
	while not (AreaGetVisible() ~= 19 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[19] = false
	collectgarbage()
end
