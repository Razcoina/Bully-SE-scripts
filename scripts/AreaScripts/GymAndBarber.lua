function main()
	DATLoad("ibarber.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDATFileLoaded[13] = true
	shared.gAreaDataLoaded = true
	while not (AreaGetVisible() ~= 13 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[13] = false
	collectgarbage()
end
