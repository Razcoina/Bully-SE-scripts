function main()
    DATLoad("SP_TGOKart.DAT", 0)
    F_PreDATInit()
    DATInit()
    shared.gAreaDATFileLoaded[42] = true
    shared.gAreaDataLoaded = true
    while not (AreaGetVisible() ~= 42 or SystemShouldEndScript()) do
        Wait(0)
    end
    DATUnload(0)
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[42] = false
    collectgarbage()
end
