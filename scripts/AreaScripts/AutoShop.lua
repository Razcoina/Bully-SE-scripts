function main()
    DATLoad("eventsAutoShop.DAT", 1)
    DATLoad("SP_Auto_Shop.DAT", 0)
    F_PreDATInit()
    DATInit()
    --print("[JASON] =========================> Area Script Working: AutoShop")
    shared.gAreaDataLoaded = true
    shared.gAreaDATFileLoaded[18] = true
    while AreaGetVisible() == 18 and not SystemShouldEndScript() do
        Wait(0)
    end
    DATUnload(0)
    collectgarbage()
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[18] = false
end
