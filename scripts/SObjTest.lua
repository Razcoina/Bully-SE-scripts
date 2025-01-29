--[[ Changes to this file:
    * Modified table ModelTable, may require testing
]]

LINEBREAK = 9999
TestX = 2
TestY = -15
TestZ = 14.51
FightX = -4.13
FightY = 21.43
FightZ = 26.08
LockerTestX = 24.66
LockerTestY = -1.2
LockerTestZ = 14.5
garbageCanTestX = -5.5
garbageCanTestY = -37
garbageCanTestZ = 14.5
offsetX = -2.5
offsetY = -2.5
g_TestMode = 0
g_TestModeLockerGarbage = 0
g_currentTestPed = 1
shared.g_currentCreatedPed = -1
PedLineupCreated = false
shared.PedLineupTable = {}

ModelTable = { -- ! Modified
    --[[
    MODELENUM._TE_GEOGRAPHY,
    MODELENUM._TE_MUSIC,
    MODELENUM._TO_SANTA,
    MODELENUM._TO_SANTA_NB,
    MODELENUM._TO_HOBOSANTA,
    MODELENUM._TO_ELFF,
    MODELENUM._TO_ELFM,
    MODELENUM._PETER_NUTCRACK,
    MODELENUM._GN_FATGIRL_FAIRY,
    MODELENUM._GN_LGIRL_2_FLOWER,
    MODELENUM._GN_HBOY_FLOWER,
    ]] -- Not present in original script
    MODELENUM._DOLEAD_RUSSELL,
    MODELENUM._DOLEAD_RUSSELL_BU,
    MODELENUM._GN_BULLY01,
    MODELENUM._GN_BULLY01_WEEN,
    MODELENUM._GN_BULLY02,
    MODELENUM._GN_BULLY03,
    MODELENUM._GN_BULLY04,
    MODELENUM._GN_BULLY05,
    MODELENUM._GN_BULLY06,
    LINEBREAK,
    MODELENUM._NDH1A_ALGERNON,
    MODELENUM._NDH1A_ALGERNON_GS,
    MODELENUM._NDH1_FATTY,
    MODELENUM._NDH1_FATTY_DM,
    MODELENUM._ND_FATTYWRESTLE,
    MODELENUM._ND2ND_MELVIN,
    MODELENUM._NDH2_THAD,
    MODELENUM._NDH2_THAD_WEEN,
    MODELENUM._NDH2_THAD_GS,
    MODELENUM._NDH2_THAD_PJ,
    MODELENUM._NDH3_BUCKY,
    MODELENUM._NDH3_BUCKY_GS,
    MODELENUM._NDH2A_CORNELIUS,
    MODELENUM._NDLEAD_EARNEST,
    MODELENUM._NDLEAD_EARNEST_EG,
    MODELENUM._NDH3A_DONALD,
    MODELENUM._NDH3A_DONALD_WEEN,
    MODELENUM._NDGIRL_BEATRICE,
    MODELENUM._NDGIRL_BEATRICEUW,
    LINEBREAK,
    MODELENUM._JKH1_DAMON,
    MODELENUM._JKH1_DAMON_GS,
    MODELENUM._JKH1_DAMON_WEEN,
    MODELENUM._JKDAMON_FB,
    MODELENUM._JKH1A_KIRBY,
    MODELENUM._JKH1A_KIRBY_GS,
    MODELENUM._JKKIRBY_FB,
    MODELENUM._JKH2_DAN,
    MODELENUM._JKDAN_FB,
    MODELENUM._JKH2A_LUIS,
    MODELENUM._JK_LUISWRESTLE,
    MODELENUM._JKH3_CASEY,
    MODELENUM._JK_CASEY_FB,
    MODELENUM._JKH3_CASEY_WEEN,
    MODELENUM._JKH3A_BO,
    MODELENUM._JK_BO_FB,
    MODELENUM._JKH3A_BO_GS,
    MODELENUM._JKLEAD_TED,
    MODELENUM._JKLEAD_TED_EG,
    MODELENUM._JKTED_FB,
    MODELENUM._JK2ND_JURI,
    MODELENUM._JK2ND_JURI_GS,
    MODELENUM._JKGIRL_MANDY,
    MODELENUM._JK_MANDY_TOWEL,
    MODELENUM._JKGIRL_MANDYUW,
    LINEBREAK,
    MODELENUM._GR2ND_PEANUT,
    MODELENUM._GR2ND_PEANUT_GS,
    MODELENUM._GRH2A_HAL,
    MODELENUM._GRH2A_HAL_GS,
    MODELENUM._GRLEAD_JOHNNY,
    MODELENUM._GRLEAD_JOHNNY_EG,
    MODELENUM._GRH1_LEFTY,
    MODELENUM._GRH3_LUCKY,
    MODELENUM._GRH3_LUCKY_WEEN,
    MODELENUM._GRH1A_VANCE,
    MODELENUM._GRH1A_VANCE_GS,
    MODELENUM._GRH1A_VANCE_WEEN,
    MODELENUM._GRH3A_RICKY,
    MODELENUM._GRH2_NORTON,
    MODELENUM._GRH2_NORTON_GS,
    MODELENUM._GRGIRL_LOLA,
    MODELENUM._GRGIRL_LOLAUW,
    LINEBREAK,
    MODELENUM._PRH1_GORD,
    MODELENUM._PRH1_GORD_GS,
    MODELENUM._PRH1A_TAD,
    MODELENUM._PRH1A_TAD_GS,
    MODELENUM._PRH1A_TAD_BW,
    MODELENUM._PR2ND_BIF,
    MODELENUM._PR2ND_BIF_OBOX,
    MODELENUM._PRH2A_CHAD,
    MODELENUM._PRH2A_CHAD_OBOX,
    MODELENUM._PRH3_JUSTIN,
    MODELENUM._PRH3_JUSTIN_GS,
    MODELENUM._PRH3_JUSTIN_OBOX,
    MODELENUM._PRH3_JUSTIN_BW,
    MODELENUM._PRH2_BRYCE,
    MODELENUM._PRH2_BRYCE_OBOX,
    MODELENUM._PRH2_BRYCE_BW,
    MODELENUM._PRLEAD_DARBY,
    MODELENUM._PRLEAD_DARBY_EG,
    MODELENUM._PRH3A_PARKER,
    MODELENUM._PRH3A_PARKER_GS,
    MODELENUM._PRH3A_PARKER_WEEN,
    MODELENUM._PRH3A_PARKER_OBOX,
    MODELENUM._PRGIRL_PINKY,
    MODELENUM._PRGIRL_PINKYUW,
    MODELENUM._PRGIRL_PINKY_WEEN,
    MODELENUM._PRGIRL_PINKY_BW,
    MODELENUM._PRGIRL_PINKY_CH,
    MODELENUM._PRH2A_CHAD_OBOX_D1,
    MODELENUM._PRH2A_CHAD_OBOX_D2,
    MODELENUM._PRH2_BRYCE_OBOX_D1,
    MODELENUM._PRH2_BRYCE_OBOX_D2,
    MODELENUM._PRH3_JUSTIN_OBOX_D1,
    MODELENUM._PRH3_JUSTIN_OBOX_D2,
    MODELENUM._PRH3A_PRKR_OBOX_D1,
    MODELENUM._PRH3A_PRKR_OBOX_D2,
    MODELENUM._PR2ND_BIF_OBOX_D1,
    MODELENUM._PR2ND_BIF_OBOX_D2,
    LINEBREAK,
    MODELENUM._DOH2_JERRY,
    MODELENUM._DOH2_JERRY_GS,
    MODELENUM._DOH1A_OTTO,
    MODELENUM._DO_OTTO_ASYLUM,
    MODELENUM._DOH2A_LEON,
    MODELENUM._DOH2A_LEON_GS,
    MODELENUM._DO_LEON_ASSYLUM,
    MODELENUM._DOH1_DUNCAN,
    MODELENUM._DOH3_HENRY,
    MODELENUM._DO_HENRY_ASSYLUM,
    MODELENUM._DOH3A_GURNEY,
    MODELENUM._DOH3A_GURNEY_GS,
    MODELENUM._DO2ND_OMAR,
    MODELENUM._DOLEAD_EDGAR,
    MODELENUM._DOLEAD_EDGAR_GS,
    MODELENUM._DOGIRL_ZOE,
    MODELENUM._DOGIRL_ZOE_EG,
    LINEBREAK,
    MODELENUM._PF2ND_MAX,
    MODELENUM._PFH1_SETH,
    MODELENUM._PFH2_EDWARD,
    MODELENUM._PFLEAD_KARL,
    LINEBREAK,
    MODELENUM._TE_HALLMONITOR,
    MODELENUM._TE_GYMTEACHER,
    MODELENUM._TE_GYM_INCOG,
    MODELENUM._TE_JANITOR,
    MODELENUM._TE_ENGLISH,
    MODELENUM._TE_ASSYLUM,
    MODELENUM._TE_CAFETERIA,
    MODELENUM._TE_CAFEMU_W,
    MODELENUM._TE_SECRETARY,
    MODELENUM._TE_NURSE,
    MODELENUM._TE_LIBRARIAN,
    MODELENUM._TE_ART,
    MODELENUM._TE_PRINCIPAL,
    MODELENUM._TE_MATHTEACHER,
    MODELENUM._TE_BIOLOGY,
    MODELENUM._TE_CHEMISTRY,
    MODELENUM._TE_HISTORY,
    MODELENUM._TE_AUTOSHOP,
    LINEBREAK,
    MODELENUM._PETER,
    MODELENUM._PETER_WEEN,
    MODELENUM._NEMESIS_GARY,
    MODELENUM._NEMESIS_WEEN,
    MODELENUM._GN_LITTLEBLKBOY,
    MODELENUM._GN_LBLKBOY_PJ,
    MODELENUM._GN_SEXYGIRL,
    MODELENUM._GN_SEXYGIRL_UW,
    MODELENUM._GN_SEXYGIRL_CH,
    MODELENUM._GN_LITTLEBLKGIRL,
    MODELENUM._GN_HISPANICBOY,
    MODELENUM._GN_HBOY_PJ,
    MODELENUM._GN_HBOY_WEEN,
    MODELENUM._GN_GREEKBOY,
    MODELENUM._GN_GREEKBOYUW,
    MODELENUM._GN_FATBOY,
    MODELENUM._GN_WHITEBOY,
    MODELENUM._GN_WHITEBOY_WEEN,
    MODELENUM._GN_SKINNYBBOY,
    MODELENUM._GN_BOY01,
    MODELENUM._GN_BOY01_PJ,
    MODELENUM._GN_BOY02,
    MODELENUM._GN_BOY02_PJ,
    MODELENUM._GN_BOY02_WEEN,
    MODELENUM._GN_FATGIRL,
    MODELENUM._GN_ASIANGIRL,
    MODELENUM._GN_ASIANGIRL_CH,
    MODELENUM._GN_ASIANGIRL_WEEN,
    MODELENUM._GN_LITTLEGIRL_2,
    MODELENUM._GN_LITTLEGIRL_3,
    LINEBREAK,
    MODELENUM._TO_BUSINESS1,
    MODELENUM._TO_BUSINESS2,
    MODELENUM._TO_BUSINESS3,
    MODELENUM._TO_BUSINESS4,
    MODELENUM._TO_BUSINESS5,
    MODELENUM._TO_BUSINESSW1,
    MODELENUM._TO_BUSINESSW2,
    MODELENUM._TO_RICHW1,
    MODELENUM._TO_RICHW2,
    MODELENUM._TO_RICHM1,
    MODELENUM._TO_RICHM2,
    MODELENUM._TO_RICHM3,
    MODELENUM._TO_OLDMAN2,
    MODELENUM._TO_POORMAN2,
    MODELENUM._TO_POORWOMAN,
    MODELENUM._TO_ASSOCIATE,
    MODELENUM._TO_ASYLUMPATIENT,
    MODELENUM._TO_FIREMAN,
    MODELENUM._TO_COMIC,
    MODELENUM._TO_BIKEOWNER,
    MODELENUM._TO_HOBO,
    MODELENUM._TO_HANDY,
    MODELENUM._TO_GROCERYOWNER,
    MODELENUM._TO_GROCERYCLERK,
    MODELENUM._TO_FIREOWNER,
    MODELENUM._TO_CSOWNER_2,
    MODELENUM._TO_CSOWNER_3,
    MODELENUM._TO_MOTELOWNER,
    MODELENUM._TO_BARBERPOOR,
    MODELENUM._TO_BARBERRICH,
    MODELENUM._TO_PUNKBARBER,
    MODELENUM._TO_TATTOOIST,
    MODELENUM._TO_MAILMAN,
    MODELENUM._TO_CARNY01,
    MODELENUM._TO_CARNY02,
    MODELENUM._TO_CARNIE_FEMALE,
    MODELENUM._TO_CARNYMIDGET,
    MODELENUM._TO_FMIDGET,
    MODELENUM._FIGHTINGMIDGET_01,
    MODELENUM._FIGHTINGMIDGET_02,
    MODELENUM._TO_SKELETONMAN,
    MODELENUM._TO_BEARDEDWOMAN,
    MODELENUM._TO_CARNIEMERMAID,
    MODELENUM._TO_SIAMESETWIN2,
    MODELENUM._TO_PAINTEDMAN,
    MODELENUM._TO_RECORD,
    MODELENUM._TO_INDUSTRIAL,
    MODELENUM._TO_GN_WORKMAN,
    MODELENUM._TO_MILLWORKER,
    MODELENUM._TO_DOCKWORKER,
    MODELENUM._TO_NH_RES_01,
    MODELENUM._TO_NH_RES_02,
    MODELENUM._TO_NH_RES_03,
    MODELENUM._TO_CONSTRUCT01,
    MODELENUM._TO_CONSTRUCT02,
    LINEBREAK,
    MODELENUM._TO_COP,
    MODELENUM._TO_COP2,
    MODELENUM._TO_COP3,
    MODELENUM._TO_COP4,
    MODELENUM._TO_ORDERLY,
    MODELENUM._TO_ORDERLY2,
    MODELENUM._RAT_PED,
    MODELENUM._DOG_PITBULL,
    MODELENUM._DOG_PITBULL2,
    MODELENUM._DOG_PITBULL3,
    MODELENUM._PUNCHBAG,
    LINEBREAK
}
EmotionTable = {}
EmotionIndex = 1
FactionTable = {}
FactionIndex = 1
PropFirstModelID = 9984
PropLastModelID = 10247

function F_PedPrintName(ped)
    local outputString = "Selected Character: " .. GetModelName(shared.PedLineupTable[ped].model)
    TextPrintString(outputString, 2, 2)
end

function F_CreatePeds()
    TextPrintString("Creating Character Line-up", 2, 2)
    for i, entry in shared.PedLineupTable do
        F_CreateSinglePed(i, true)
    end
    PedLineupCreated = true
end

function F_CreateSinglePed(ped, asleep)
    local offX, offY, offZ = PedGetOffsetInWorldCoords(gPlayer, 0, 2, 0)
    shared.PedLineupTable[ped].handle = PedCreateXYZ(shared.PedLineupTable[ped].model, offX, offY, offZ, 2)
    PedSetAsleep(shared.PedLineupTable[ped].handle, asleep)
end

function F_DeleteSinglePed(ped)
    if shared.PedLineupTable[ped].handle ~= nil then
        PedDelete(shared.PedLineupTable[ped].handle)
        shared.PedLineupTable[ped].handle = nil
    end
end

function F_DeletePeds()
    TextPrintString("Removing Character Line-up", 2, 2)
    for i, entry in shared.PedLineupTable do
        F_DeleteSinglePed(i)
    end
    PedLineupCreated = false
end

PickupLineupCreated = false
PickupLineupTable = {}
PickupTable = {
    299,
    315,
    311,
    304,
    301,
    LINEBREAK,
    316,
    308,
    309,
    312,
    310,
    313,
    LINEBREAK,
    306,
    498,
    497,
    300,
    303,
    LINEBREAK,
    MODELENUM._RINGRED,
    MODELENUM._RINGBLUE,
    305,
    307,
    501,
    318
}

function F_CreatePickups()
    TextPrintString("Creating Pikcup Line-up", 2, 2)
    for i, entry in PickupLineupTable do
        PickupLineupTable[i].handle = PickupCreateXYZ(PickupLineupTable[i].model, PickupLineupTable[i].x + TestX, PickupLineupTable[i].y + TestY, TestZ + 1)
    end
    PickupLineupCreated = true
end

function F_DeletePickups()
    TextPrintString("Removing Pickup Line-up", 2, 2)
    for i, entry in PickupLineupTable do
        PickupDelete(PickupLineupTable[i].handle)
        PickupLineupTable[i].handle = nil
    end
    PickupLineupCreated = false
end

BikeLineupCreated = false
BikeLineupTable = {}
BikeTable = {
    273,
    273,
    273
}

function F_CreateBikes()
    TextPrintString("Creating Bike Line-up", 2, 2)
    for i, entry in BikeLineupTable do
        BikeLineupTable[i].handle = VehicleCreateXYZ(BikeLineupTable[i].model, BikeLineupTable[i].x + TestX, BikeLineupTable[i].y + TestY, TestZ)
    end
    BikeLineupCreated = true
end

function F_DeleteBikes()
    TextPrintString("Removing Bike Line-up", 2, 2)
    for i, entry in BikeLineupTable do
        VehicleDelete(BikeLineupTable[i].handle)
        BikeLineupTable[i].handle = nil
    end
    BikeLineupCreated = false
end

function BeefupPlayer()
end

function F_AddToTable(modelsTable, objectsTable)
    local currentX = 0
    local currentY = 0
    for currentModel = 1, table.getn(modelsTable) do
        if modelsTable[currentModel] ~= LINEBREAK then
            table.insert(objectsTable, {
                handle = nil,
                model = modelsTable[currentModel],
                x = currentX,
                y = currentY
            })
            local tempX = currentX + offsetX
            currentX = tempX
        else
            local tempY = currentY + offsetY
            currentY = tempY
            currentX = 0
        end
    end
end

function ToggleFightTestMode()
    if g_TestMode == 0 then
        g_TestMode = 1
        TextPrintString("PlayNPC Test Mode", 2, 2)
        if 0 <= shared.g_currentCreatedPed then
            shared.gControllerPed = shared.PedLineupTable[shared.g_currentCreatedPed].handle
            PedSetControllerID(shared.gControllerPed, 0)
            CameraFollowPed(shared.gControllerPed)
        end
        return
    else
        g_TestMode = 0
        TextPrintString("Fight Test Mode", 2, 2)
        PedSetControllerID(gPlayer, 0)
        CameraFollowPed(gPlayer)
        PedSetAITree(shared.gControllerPed, "/Global/AI", "Act/AI/AI.act")
        shared.gControllerPed = gPlayer
        return
    end
end

function F_BuildEmotionTable()
    --print("BUILDING TABLE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    table.insert(EmotionTable, {
        Emotion = 0,
        EString = "AGGRESSIVE",
        ELock = false
    })
    table.insert(EmotionTable, {
        Emotion = 0,
        EString = "AGGRESSIVE LOCKED",
        ELock = true
    })
    table.insert(EmotionTable, {
        Emotion = 1,
        EString = "ANNOYED",
        ELock = false
    })
    table.insert(EmotionTable, {
        Emotion = 1,
        EString = "ANNOYED LOCKED",
        ELock = true
    })
    table.insert(EmotionTable, {
        Emotion = 2,
        EString = "UNFRIENDLY",
        ELock = false
    })
    table.insert(EmotionTable, {
        Emotion = 2,
        EString = "UNFRIENDLY LOCKED",
        ELock = true
    })
    table.insert(EmotionTable, {
        Emotion = 3,
        EString = "DISMISSIVE",
        ELock = false
    })
    table.insert(EmotionTable, {
        Emotion = 3,
        EString = "DISMISSIVE LOCKED",
        ELock = true
    })
    table.insert(EmotionTable, {
        Emotion = 4,
        EString = "VERY SCARED",
        ELock = false
    })
    table.insert(EmotionTable, {
        Emotion = 4,
        EString = "VERY SCARED LOCKED",
        ELock = true
    })
    table.insert(EmotionTable, {
        Emotion = 5,
        EString = "SCARED",
        ELock = false
    })
    table.insert(EmotionTable, {
        Emotion = 5,
        EString = "SCARED LOCKED",
        ELock = true
    })
    table.insert(EmotionTable, {
        Emotion = 6,
        EString = "INTIMIDATED",
        ELock = false
    })
    table.insert(EmotionTable, {
        Emotion = 6,
        EString = "INTIMIDATED LOCKED",
        ELock = true
    })
    table.insert(EmotionTable, {
        Emotion = 7,
        EString = "FRIENDLY",
        ELock = false
    })
    table.insert(EmotionTable, {
        Emotion = 7,
        EString = "FRIENDLY LOCKED",
        ELock = true
    })
    table.insert(EmotionTable, {
        Emotion = 8,
        EString = "VERY FRIENDLY",
        ELock = false
    })
    table.insert(EmotionTable, {
        Emotion = 8,
        EString = "VERY FRIENDLY LOCKED",
        ELock = true
    })
end

function F_BuildFactionTable()
    table.insert(FactionTable, {
        Attitude = 4,
        FString = "Faction: Adore"
    })
    table.insert(FactionTable, {
        Attitude = 3,
        FString = "Faction: Dig"
    })
    table.insert(FactionTable, {
        Attitude = 2,
        FString = "Faction: Dispassionate"
    })
    table.insert(FactionTable, {
        Attitude = 1,
        FString = "Faction: Averse"
    })
    table.insert(FactionTable, {
        Attitude = 0,
        FString = "Faction: Abhor"
    })
end

local f_numberOnPage = 0
local f_myPage

function doAddPropMenuItems(k, propModelName)
    if f_numberOnPage == 29 then
        f_myPage = DebugMenuAddPage("Spawn Props")
        f_numberOnPage = 0
    end
    local prop = GetModelIndex(propModelName)
    DebugMenuAddItem(f_myPage, propModelName, function()
        F_PAnimForceCreateInfrontofPlayer(prop)
    end)
    f_numberOnPage = f_numberOnPage + 1
end

function doAddPedMenuItems(k, pedName)
    if f_numberOnPage == 29 then
        f_myPage = DebugMenuAddPage("Spawn Character")
        f_numberOnPage = 0
    end
    local tempPed = 1
    for ped = 1, table.getn(shared.PedLineupTable) do
        if shared.PedLineupTable[ped] ~= LINEBREAK and GetModelName(shared.PedLineupTable[ped].model) == pedName then
            tempPed = ped
            break
        end
    end
    DebugMenuAddItem(f_myPage, pedName, function()
        g_currentTestPed = tempPed
        if shared.g_currentCreatedPed >= 0 then
            F_DeleteSinglePed(shared.g_currentCreatedPed)
        end
        F_CreateSinglePed(g_currentTestPed, false)
        shared.g_currentCreatedPed = g_currentTestPed
    end)
    f_numberOnPage = f_numberOnPage + 1
end

function OpenDoor()
    local x, y, z
    x, y, z = PlayerGetPosXYZ()
    PAnimOpenDoors(x, y, z, 2)
end

function CloseDoor()
end

function F_SetupDebugMenuSObjTest()
    local myPage, numberOnPage
    local sorted_names = {}
    f_myPage = DebugMenuAddPage("Spawn Character")
    f_numberOnPage = 0
    for ped = 1, table.getn(shared.PedLineupTable) do
        if shared.PedLineupTable[ped] ~= LINEBREAK then
            table.insert(sorted_names, GetModelName(shared.PedLineupTable[ped].model))
        end
    end
    table.sort(sorted_names)
    table.foreach(sorted_names, doAddPedMenuItems)
    for ped = 1, table.getn(shared.PedLineupTable) do
        if shared.PedLineupTable[ped] ~= LINEBREAK then
            table.remove(sorted_names, ped)
        end
    end
    f_myPage = DebugMenuAddPage("Spawn Props")
    f_numberOnPage = 0
    for propModelID = PropFirstModelID, PropLastModelID do
        propModelName = GetModelName(propModelID)
        if propModelName ~= NIL then
            table.insert(sorted_names, propModelName)
        end
    end
    table.sort(sorted_names)
    table.foreach(sorted_names, doAddPropMenuItems)
    myPage = DebugMenuAddPage("Set Character Emotion/Faction")
    numberOnPage = 0
    for emotion = 1, table.getn(EmotionTable) do
        if numberOnPage == 29 then
            myPage = DebugMenuAddPage("Set Character Emotion/Faction")
            numberOnPage = 0
        end
        local tempEmotion = emotion
        DebugMenuAddItem(myPage, "Set Emotion " .. EmotionTable[emotion].EString, function()
            F_SetEmotion(tempEmotion)
        end)
    end
    for faction = 1, table.getn(FactionTable) do
        if numberOnPage == 29 then
            myPage = DebugMenuAddPage("Set Character Emotion/Faction")
            numberOnPage = 0
        end
        local tempFaction = faction
        DebugMenuAddItem(myPage, "Set " .. FactionTable[faction].FString, function()
            F_SetFaction(tempFaction)
        end)
    end
end

function main()
    Wait(0)
    F_BuildEmotionTable()
    F_BuildFactionTable()
    F_AddToTable(ModelTable, shared.PedLineupTable)
    F_AddToTable(PickupTable, PickupLineupTable)
    F_AddToTable(BikeTable, BikeLineupTable)
    BeefupPlayer()
    local npcTestMode = false
    F_SetupDebugMenuSObjTest()
    while true do
        Wait(0)
        npcTestMode = true
        if CameraDebugActive() then
            npcTestMode = false
        end
        if AreaGetVisible() == 31 and F_IsButtonPressedWithDelayCheck(15, 1) then
            if g_TestModeLockerGarbage == 0 then
                g_TestModeLockerGarbage = 1
            else
                g_TestModeLockerGarbage = 0
            end
        end
        if npcTestMode then
            if not IsButtonPressed(15, 1) then
                if F_IsButtonPressedWithDelayCheck(10, 1) and not CameraDebugActive() then
                    ToggleFightTestMode()
                    Wait(500)
                end
                if F_IsButtonPressedWithDelayCheck(13, 1) then
                    g_currentTestPed = g_currentTestPed + 1
                    if g_currentTestPed > table.getn(shared.PedLineupTable) then
                        g_currentTestPed = 1
                    end
                    F_PedPrintName(g_currentTestPed)
                    Wait(250)
                end
                if F_IsButtonPressedWithDelayCheck(11, 1) then
                    g_currentTestPed = g_currentTestPed - 1
                    if 1 > g_currentTestPed then
                        g_currentTestPed = table.getn(shared.PedLineupTable)
                    end
                    F_PedPrintName(g_currentTestPed)
                    Wait(250)
                end
                if IsButtonPressed(2, 1) then
                    if 0 <= shared.g_currentCreatedPed then
                        F_DeleteSinglePed(shared.g_currentCreatedPed)
                    end
                    F_CreateSinglePed(g_currentTestPed, false)
                    shared.g_currentCreatedPed = g_currentTestPed
                    if npcTestMode and g_TestMode == 1 then
                        PedSetControllerID(shared.PedLineupTable[shared.g_currentCreatedPed].handle, 0)
                        CameraFollowPed(shared.PedLineupTable[shared.g_currentCreatedPed].handle)
                    end
                    Wait(500)
                end
            end
            if 0 <= shared.g_currentCreatedPed and IsButtonPressed(15, 1) then
                if IsButtonPressed(10, 1) then
                    EmotionIndex = EmotionIndex + 1
                    if EmotionIndex > table.getn(EmotionTable) then
                        EmotionIndex = 1
                    end
                    --print(EmotionIndex)
                    --print(EmotionTable[EmotionIndex].EString)
                    TextPrintString(EmotionTable[EmotionIndex].EString, 2, 2)
                    Wait(200)
                elseif IsButtonPressed(11, 1) then
                    EmotionIndex = EmotionIndex - 1
                    if 1 > EmotionIndex then
                        EmotionIndex = table.getn(EmotionTable)
                    end
                    --print(EmotionIndex)
                    --print(EmotionTable[EmotionIndex].EString)
                    TextPrintString(EmotionTable[EmotionIndex].EString, 2, 2)
                    Wait(200)
                elseif IsButtonPressed(13, 1) then
                    F_SetEmotion(EmotionIndex)
                elseif IsButtonPressed(2, 1) then
                    FactionIndex = FactionIndex + 1
                    if FactionIndex > table.getn(FactionTable) then
                        FactionIndex = 1
                    end
                    TextPrintString(FactionTable[FactionIndex].FString, 2, 2)
                    F_SetFaction(FactionIndex)
                end
            end
        end
    end
end

function F_PAnimForceCreateInfrontofPlayer(prop)
    local offx, offy, offz = PedGetOffsetInWorldCoords(gPlayer, 0, 2, 0)
    PAnimForceCreate(prop, offx, offy, offz, 0, AreaGetVisible())
end

function F_SetEmotion(EmotionIndex)
    --print(shared.PedLineupTable[shared.g_currentCreatedPed].handle)
    --print(gPlayer)
    PedSetEmotionTowardsPed(shared.PedLineupTable[shared.g_currentCreatedPed].handle, gPlayer, EmotionTable[EmotionIndex].Emotion, EmotionTable[EmotionIndex].ELock)
    PedSetWantsToSocializeWithPed(shared.PedLineupTable[shared.g_currentCreatedPed].handle, gPlayer)
    PedWander(shared.PedLineupTable[shared.g_currentCreatedPed].handle, 0)
end

function F_SetFaction(FactionIndex)
    PedSetPedToTypeAttitude(shared.PedLineupTable[shared.g_currentCreatedPed].handle, 13, FactionTable[FactionIndex].Attitude)
end
