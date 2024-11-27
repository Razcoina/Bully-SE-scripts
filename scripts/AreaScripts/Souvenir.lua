function main()
	DATLoad("SP_Souvenir.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDATFileLoaded[50] = true
	shared.gAreaDataLoaded = true
	while not (AreaGetVisible() ~= 50 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[50] = false
	collectgarbage()
end
