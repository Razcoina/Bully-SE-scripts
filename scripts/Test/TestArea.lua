function main()
	--DebugPrint("*********************************************** testarea - main() start")
	DATLoad("ttest.DAT", 0)
	DATLoad("SP_Test_Area.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDataLoaded = true
	shared.gAreaDATFileLoaded[31] = true
	while not (AreaGetVisible() ~= 31 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[31] = false
	--DebugPrint("*********************************************** testarea - main() end")
end
