function main()
    DATLoad("SP_JunkYard.DAT", 0)
    F_PreDATInit()
    DATInit()
    shared.gAreaDATFileLoaded[43] = true
    shared.gAreaDataLoaded = true
    while not (AreaGetVisible() ~= 43 or SystemShouldEndScript()) do
        Wait(0)
    end
    DATUnload(0)
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[43] = false
    collectgarbage()
end
