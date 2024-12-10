function main()
	DATLoad("eventsObservatory.DAT", 0)
	DATLoad("SP_Observatory.DAT", 0)
	F_PreDATInit()
	DATInit()
	--print("[JASON] =========================> Area Script Working: Observatory")
	shared.gAreaDataLoaded = true
	shared.gAreaDATFileLoaded[40] = true
	while not (AreaGetVisible() ~= 40 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	collectgarbage()
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[40] = false
end
