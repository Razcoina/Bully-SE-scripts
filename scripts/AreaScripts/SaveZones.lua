ImportScript("Library/LibClothing.lua")

function main()
    local currentArea = AreaTransitionDestination()
    local bAreaPassed = false
    DATLoad("iSaveZones.DAT", 0)
    DATLoad("SaveLocs.dat", 0)
    local gClothingUnlocked = false
    if shared.unlockedClothing then
        gClothingUnlocked = true
    end
    if currentArea == 57 then
        if IsMissionCompleated("3_R09_D3") then
            gClothingUnlocked = true
            bAreaPassed = true
        end
        gClothingHeading = 180
        DATLoad("SP_iDropS.DAT", 0)
    elseif currentArea == 60 then
        if IsMissionCompleated("3_R09_P3") then
            gClothingUnlocked = true
            bAreaPassed = true
        end
        gClothingHeading = 270
        DATLoad("SP_iPrepS.DAT", 0)
    elseif currentArea == 61 then
        if IsMissionCompleated("3_R09_G3") then
            gClothingUnlocked = true
            bAreaPassed = true
        end
        gClothingHeading = 90
        DATLoad("SP_iGrsrS.DAT", 0)
    elseif currentArea == 59 then
        if IsMissionCompleated("3_R09_J3") then
            bAreaPassed = true
        end
        DATLoad("SP_iJockS.DAT", 0)
    end
    if bAreaPassed then
        --print("Current area is: ", currentArea)
        if IsMissionCompleated("4_B1") then
            DATLoad("BDorm_Spud.DAT", 0)
        end
        if IsMissionCompleated("3_R09_N") then
            DATLoad("BDorm_RLauncher.DAT", 0)
        end
        if IsMissionCompleated("2_03") then
            DATLoad("BDorm_Eggs.DAT", 0)
        end
    end
    F_PreDATInit()
    DATInit()
    shared.gAreaDataLoaded = true
    shared.gAreaDATFileLoaded[currentArea] = true
    WeaponRequestModel(309)
    local cx, cy, cz
    DisablePunishmentSystem(true)
    F_ToggleArcadeScreens()
    while not (AreaGetVisible() ~= currentArea or SystemShouldEndScript()) do
        Wait(0)
        if (gClothingUnlocked or shared.unlockedClothing) and not shared.lockClothingManager then
            if not cx then
                cx, cy, cz = GetPointList(POINTLIST._CM_CORONA)
            end
            if not gClothing and PlayerIsInAreaXYZ(cx, cy, cz, 1, 6) then
                TextPrint("BUT_CLOTH", 1, 3)
                if IsButtonPressed(9, 0) then
                    L_ClothingSetup(gClothingHeading, CbFinishClothing)
                    gClothing = true
                end
            end
        end
    end
    DisablePunishmentSystem(false)
    shared.unlockedClothing = nil
    DATUnload(0)
    collectgarbage()
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[currentArea] = false
end

function CbFinishClothing()
    gClothing = false
end
