function main()
	DATLoad("SP_Art_Room.DAT", 0)
	F_PreDATInit()
	DATInit()
	shared.gAreaDATFileLoaded[17] = true
	shared.gAreaDataLoaded = true
	while not (AreaGetVisible() ~= 17 or SystemShouldEndScript()) do
		Wait(0)
	end
	DATUnload(0)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[17] = false
	collectgarbage()
end
