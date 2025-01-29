--[[ Changes to this file:
    * Added unused local variable
    * Modified function main, may require testing
]]

local gCurrentCam = -1
local L1_1 = 0 -- ! Cannot recover original name

function SetupTattooStore()
    TattooStoreAdd(0, 0, "black", 1000, 1)
    TattooStoreAdd(0, 0, "dagger", 1000, 2)
    TattooStoreAdd(0, 2, "fish", 1000, 3)
    TattooStoreAdd(0, 0, "loveand", 1000, 4)
    TattooStoreAdd(0, 2, "ship", 1000, 5)
    TattooStoreAdd(0, 2, "stitches", 1000, 6)
    TattooStoreAdd(0, 0, "skull", 1000, 7)
    TattooStoreAdd(1, 1, "band", 1000, 8)
    TattooStoreAdd(1, 2, "cards", 1000, 9)
    TattooStoreAdd(1, 0, "barbs", 1000, 10)
    TattooStoreAdd(1, 0, "snake", 1000, 11)
    TattooStoreAdd(1, 0, "mermaid", 1000, 12)
    TattooStoreAdd(1, 2, "star", 1000, 13)
    TattooStoreAdd(1, 0, "swallow", 1000, 14)
    --print("FINISHED ADDING ALL TATTOOS")
    TattooStoreRegisterFeedbackCallback(FeedbackCallback)
    --print("FINISHED REGISTERING CALLBACK ")
end

local camNumber = 0

function FeedbackCallback(storeFeedbackType, relatedData)
    --print("*** SAJ *** FEEDBACK CALLBACK", storeFeedbackType, relatedData)
    if storeFeedbackType == 5 or storeFeedbackType == 6 then
        if relatedData == 1 or relatedData == 4 then
            PedSetActionNode(gPlayer, "/Global/TattooShop/Animations/Idle", "Act/Anim/TattooShop.act")
        elseif relatedData == 2 then
            PedSetActionNode(gPlayer, "/Global/TattooShop/Animations/LeftArm/4ArmHi", "Act/Anim/TattooShop.act")
        elseif relatedData == 3 or relatedData == 5 or relatedData == 6 then
            PedSetActionNode(gPlayer, "/Global/TattooShop/Animations/LeftArm/Shoulder", "Act/Anim/TattooShop.act")
        elseif relatedData == 7 then
            PedSetActionNode(gPlayer, "/Global/TattooShop/Animations/LeftArm/4ArmLow", "Act/Anim/TattooShop.act")
        elseif relatedData == 8 or relatedData == 9 or relatedData == 13 or relatedData == 14 then
            PedSetActionNode(gPlayer, "/Global/TattooShop/Animations/RightArm/Shoulder", "Act/Anim/TattooShop.act")
        elseif relatedData == 10 then
            PedSetActionNode(gPlayer, "/Global/TattooShop/Animations/RightArm/4ArmHi", "Act/Anim/TattooShop.act")
        elseif relatedData == 11 then
            PedSetActionNode(gPlayer, "/Global/TattooShop/Animations/RightArm/4ArmLow", "Act/Anim/TattooShop.act")
        elseif relatedData == 12 then
            PedSetActionNode(gPlayer, "/Global/TattooShop/Animations/Idle", "Act/Anim/TattooShop.act")
        end
        if relatedData < 8 then
            camNumber = 1
        else
            camNumber = 2
        end
        if gCurrentCam ~= camNumber then
            gCurrentCam = camNumber
            if gCurrentCam == 2 then
                CameraLookAtXYZ(-656.2133, 82.9023, 1.4116743, false)
                CameraSetPath(PATH._TATTOO_CAMERA_01, false)
            elseif gCurrentCam == 1 then
                CameraLookAtXYZ(-656.0724, 82.43323, 1.4116743, false)
                CameraSetPath(PATH._TATTOO_CAMERA_02, false)
            end
        end
    end
end

function main() -- ! Modified
    AreaDisableCameraControlForTransition(true)
    local gArea = 16
    AreaClearAllPeds()
    PedClearHasAggressed(gPlayer)
    shared.gAreaDATFileLoaded[gArea] = true
    shared.gAreaDataLoaded = true
    DATLoad("SP_Trailer.dat", 0)
    DATLoad("Tattoos.dat", 0)
    LoadAnimationGroup("Try_Clothes")
    LoadActionTree("Act/Anim/TattooShop.act")
    PlayerSetPosSimple(-655.834, 82.6622, 0.239465)
    ClothingBackup()
    ClothingSetPlayerOutfit("Starting")
    ClothingSetPlayer(1, "P_SSleeves11")
    ClothingBuildPlayer()
    F_PreDATInit()
    DATInit()
    CameraFade(1, 0)
    local buttonPressed = false
    local tattooHeading = 180
    local startingHeading = 5
    local x, y, z = GetPointList(POINTLIST._TATTOO_PLAYER)
    PlayerSetPosSimple(x, y, z)
    gClothingHeading = 180
    clothingHeading = 180
    PlayerFaceHeadingNow(180)
    --print("FINISHED SETTING UP TATOO HUD")
    gCurrentCam = 2
    CameraLookAtXYZ(-656.0724, 82.43323, 1.4116743, false)
    CameraSetXYZ(-654.908, 81.575, 1.99168, -656.0724, 82.43323, 1.4116743)
    --print("SETTING UP TATOO STORE ")
    HUDSaveVisibility()
    ToggleHUDComponentVisibility(19, true)
    AreaClearAllPeds()
    SetupTattooStore()
    --print("FINISHED SETTING UP TATOO STORE ")
    FeedbackCallback(5, 1)
    Wait(1000)
    CameraFade(500, 1)
    while not buttonPressed do
        if IsButtonPressed(15, 0) then
            --[[
            clothingHeading = gClothingHeading
            ]]                                    -- Removed this
            startingHeading = startingHeading - 1 -- Added this
            if startingHeading == 0 then -- Added this
                clothingHeading = gClothingHeading
                startingHeading = 1
            end
            --[[
        elseif IsButtonPressed(24, 0) then
        ]] -- Changed to:
        elseif GetStickValue(18, 0) then
            --[[
            clothingHeading = clothingHeading - 5
            ]] -- Changed to:
            startingHeading = 5
            --[[
        elseif IsButtonPressed(25, 0) then
            clothingHeading = clothingHeading + 5
            ]] -- Removed this
            clothingHeading = clothingHeading + 5 * GetStickValue(18, 0)
        end
        if clothingHeading > 360 then
            clothingHeading = clothingHeading - 360
        elseif 0 > clothingHeading then
            clothingHeading = clothingHeading + 360
        end
        PlayerFaceHeadingNow(clothingHeading)
        if IsButtonBeingPressed(8, 0) then
            buttonPressed = true
        end
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(500)
    ToggleHUDComponentVisibility(19, false)
    HUDRestoreVisibility()
    ClothingRestore()
    ClothingBuildPlayer()
    AreaDisableCameraControlForTransition(false)
    local eX, eY, eZ = GetPointList(POINTLIST._BAR_LIST_TAT_TRIGGER)
    shared.storeTransition = {
        0,
        eX,
        eY,
        eZ
    }
    LaunchScript("AreaScripts/StoreTransition.lua")
    DATUnload(0)
    UnLoadAnimationGroup("NPC_Adult")
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[gArea] = false
    collectgarbage()
end
