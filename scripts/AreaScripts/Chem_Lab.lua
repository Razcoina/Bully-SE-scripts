function main()
	DATLoad("SP_Chem_Lab.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDataLoaded = true
	shared.gAreaDATFileLoaded[4] = true
	while not (AreaGetVisible() ~= 4 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	collectgarbage()
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[4] = false
end
