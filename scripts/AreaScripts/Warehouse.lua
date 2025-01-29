function main()
    DATLoad("iwarehouse.DAT", 0)
    DATLoad("SP_Warehouse.DAT", 0)
    F_PreDATInit()
    DATInit()
    shared.gAreaDATFileLoaded[54] = true
    shared.gAreaDataLoaded = true
    while not (AreaGetVisible() ~= 54 or SystemShouldEndScript()) do
        Wait(0)
    end
    DATUnload(0)
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[54] = false
    collectgarbage()
end
