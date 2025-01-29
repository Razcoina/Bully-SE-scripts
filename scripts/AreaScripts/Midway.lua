function main()
    DATLoad("SP_Midway.DAT", 0)
    F_PreDATInit()
    DATInit()
    shared.gAreaDATFileLoaded[45] = true
    shared.gAreaDataLoaded = true
    while not (AreaGetVisible() ~= 45 or SystemShouldEndScript()) do
        Wait(0)
    end
    DATUnload(0)
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[45] = false
    collectgarbage()
end
