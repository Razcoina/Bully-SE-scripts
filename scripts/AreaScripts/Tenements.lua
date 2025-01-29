local bFixedCamera = false

function main()
    DATLoad("tenements.DAT", 0)
    DATLoad("SP_Tenement.DAT", 0)
    F_PreDATInit()
    DATInit()
    shared.gAreaDataLoaded = true
    shared.gAreaDATFileLoaded[36] = true
    while not (AreaGetVisible() ~= 36 or SystemShouldEndScript()) do
        Wait(0)
    end
    DATUnload(0)
    collectgarbage()
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[36] = false
end
