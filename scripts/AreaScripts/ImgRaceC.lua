function main()
	DATLoad("SP_ImgRaceC.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDATFileLoaded[53] = true
	shared.gAreaDataLoaded = true
	while not (AreaGetVisible() ~= 53 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[53] = false
	collectgarbage()
end
