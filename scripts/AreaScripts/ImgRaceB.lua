function main()
    DATLoad("SP_ImgRaceB.DAT", 0)
    F_PreDATInit()
    DATInit()
    shared.gAreaDATFileLoaded[52] = true
    shared.gAreaDataLoaded = true
    while not (AreaGetVisible() ~= 52 or SystemShouldEndScript()) do
        Wait(0)
    end
    DATUnload(0)
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[52] = false
    collectgarbage()
end
