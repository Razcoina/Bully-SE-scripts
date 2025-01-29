function main()
    DATLoad("SP_ImgRaceA.DAT", 0)
    F_PreDATInit()
    DATInit()
    shared.gAreaDATFileLoaded[51] = true
    shared.gAreaDataLoaded = true
    while not (AreaGetVisible() ~= 51 or SystemShouldEndScript()) do
        Wait(0)
    end
    DATUnload(0)
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[51] = false
    collectgarbage()
end
