function main()
	DATLoad("SP_Bio_Lab.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDataLoaded = true
	shared.gAreaDATFileLoaded[6] = true
	while not (AreaGetVisible() ~= 6 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	collectgarbage()
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[6] = false
end
