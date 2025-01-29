--[[ Changes to this file:
    * Removed some local variables, not present in original script
    * Removed function F_POIDriver, not present in original script
    * Removed function Validate, not present in original script
]]

GlobalImportScript("POI/EventFunc.lua")
ImportScript("AreaScripts/Scenarios.lua")
local gFunctionTable = {
    COUPLE = { F_CoupleKissing, F_CoupleKissing },
    BRAWL = { F_Brawl, F_GangBeat },
    HARASSMENT = {
        F_ReachItHumiliation,
        F_SocialHumiliation,
        F_TeacherHarassingKids
    },
    WALL = { F_WallSmoking },
    DORM = {
        F_ReachItHumiliation,
        F_HeldAgainstWall,
        F_SocialHumiliation,
        F_Criminal,
        F_Crying
    },
    BACK_ALLEY = {
        F_Arrest,
        F_CoupleCuddling,
        F_CoupleKissing,
        F_Brawl,
        F_GangBeat
    },
    SCHOOL_GROUNDS = {
        F_ReachItHumiliation,
        F_SocialHumiliation,
        F_TeacherHarassingKids,
        F_Brawl,
        F_GangBeat,
        F_Criminal
    },
    STORE = { F_StoreSweep },
    SPECIFIC_EVENT = {
        F_GuardDog,
        F_BullyDogs,
        F_HCriminal,
        F_HStudent,
        F_DogWalker,
        F_Biker,
        F_WorkerSmoking,
        F_BikeCheckout,
        F_WorkerHangout,
        F_CBarkerGame,
        F_ReachItHumiliation,
        F_CBarkerGame2,
        F_Russell,
        F_CBarkerHouse,
        F_Truck,
        F_ProjAttack,
        F_RoofSniper,
        F_SmokingFireman,
        F_Puker,
        F_SocialHumiliation,
        F_HeldAgainstWall,
        F_SocialHangout,
        F_Criminal,
        F_DrunkenBeggar,
        F_TrashStuff,
        F_LockerStuff,
        F_Catch,
        F_Swirlie,
        F_Cheerleading,
        F_Workout,
        F_Crying,
        F_OutsideClass,
        F_Industrial,
        F_DockWorker,
        F_MillWorker,
        F_CarnivalWalker,
        F_Brawl,
        F_PrincipalPOI,
        F_Fireman,
        F_RandomStudent,
        F_Rats,
        F_Straggler,
        F_DunkMidget
    }
}
--[[
local gButtonPressed = false
local gDriverFunctionTable = {
    F_HeldAgainstWall,
    F_DrunkenBeggar,
    F_Catch,
    F_Cheerleading,
    F_Workout,
    F_Crying,
    F_OutsideClass,
    F_DrunkenBeggar,
    F_WallSmoking,
    F_BullyDogs,
    F_BikeCheckout,
    F_Sweep,
    F_CoupleKissing,
    F_Brawl,
    F_GangBeat,
    F_ReachItHumiliation,
    F_TeacherHarassingKids,
    F_HeldAgainstWall,
    F_Arrest,
    F_CoupleCuddling
}
local gCallIndividual = true
local gCurrentFunction = 20
]] -- Not present in original script

function F_CheckPOI()
    gStores = {
        richBarber = {
            storePoint = POINTLIST._DT_IRICHBARBER_DOOR,
            storeModel = 120
        },
        bikeOwner = {
            storePoint = POINTLIST._DT_IBKSHOP_DOOR,
            storeModel = 86
        },
        richGroceryOwner = {
            storePoint = POINTLIST._DT_IGROCERY_DOOR,
            storeModel = 156
        },
        poorGroceryOwner = {
            storePoint = POINTLIST._DT_IPOORGROCERY_DOOR,
            storeModel = 132
        }
    }
    while true do
        Wait(0)
        local POIPoint
        if not MissionActive() and shared.gCurrentAmbientScenario == nil and not ClothingIsWearingOutfit("Mascot") then
            POIPoint = AreaGetScriptedPOIPointToActivate(3)
        end
        if POIPoint == -2 then
            F_ScenarioManager(POIPoint)
        end
        POIPoint = AreaGetScriptedPOIPointToActivate(nil)
        if 0 < POIPoint then
            if not MissionActive() or shared.gMissionEventFunction == nil then
                F_POIManager(POIPoint)
            elseif shared.gMissionEventFunction ~= nil then
                local override = shared.gMissionEventFunction(POIPoint)
                if override or override == nil then
                    F_POIManager(POIPoint, override)
                end
            end
        end
        if not MissionActive() and AreaGetVisible() == 0 and shared.gAreaDATFileLoaded[0] == true then
            UpdateAsylum()
        end
    end
end

function F_POIManager(POIInfo, override)
    local POIPointType = AreaPOIGetInterestType(POIInfo)
    local POIPointFaction = AreaPOIGetFaction(POIInfo)
    local POIPointNum = AreaPOIGetMaxNumber(POIInfo)
    local POIGender = AreaPOIGetGender(POIInfo)
    local functionPicked, ped1, ped2, ped3, ped4
    AreaPOISetActivation(POIInfo, true)
    if ShouldEventInitiate(POIInfo) then
        if override or POIClearForPeds(POIInfo, 0.5) then
            if POIPointType == 5 then
                functionPicked = F_GetEventFunction(gFunctionTable.COUPLE)
            elseif POIPointType == 4 then
                if POIPointFaction == 9 or POIPointFaction == 10 then
                    functionPicked = F_Brawl
                else
                    functionPicked = F_GetEventFunction(gFunctionTable.BRAWL)
                end
            elseif POIPointType == 6 then
                if POIPointFaction == 8 or POIPointFaction == 7 or POIPointFaction == 0 or POIPointFaction == 9 then
                    functionPicked = F_TeacherHarassingKids
                else
                    functionPicked = F_GetEventFunction(gFunctionTable.HARASSMENT)
                end
                if POIPointFaction == 12 then
                    POIPointFaction = RandomElement4(11, 5, 2, 4)
                end
            elseif POIPointType == 7 then
                functionPicked = F_GetEventFunction(gFunctionTable.WALL)
            elseif POIPointType == 8 then
                functionPicked = F_GetEventFunction(gFunctionTable.DORM)
            elseif POIPointType == 9 then
                functionPicked = F_GetEventFunction(gFunctionTable.BACK_ALLEY)
            elseif POIPointType == 10 then
                functionPicked = F_GetEventFunction(gFunctionTable.SCHOOL_GROUNDS)
            elseif POIPointType == 11 then
                functionPicked = F_GetEventFunction(gFunctionTable.BATHROOM)
            elseif POIPointType == 12 then
                functionPicked = F_GetEventFunction(gFunctionTable.VANDALISM)
            elseif POIPointType == 13 then
                functionPicked = F_GetEventFunction(gFunctionTable.SITTING_EVENT)
            elseif POIPointType == 14 then
                functionPicked = F_GetEventFunction(gFunctionTable.STORE)
            elseif POIPointType == 15 then
                if AreaPOICompareName(POIInfo, "F_HeldAgainstWall") then
                    functionPicked = F_HeldAgainstWall
                elseif AreaPOICompareName(POIInfo, "F_DrunkenBeggar") then
                    functionPicked = F_DrunkenBeggar
                elseif AreaPOICompareName(POIInfo, "F_Catch") then
                    functionPicked = F_Catch
                elseif AreaPOICompareName(POIInfo, "F_Cheerleading") then
                    functionPicked = F_Cheerleading
                elseif AreaPOICompareName(POIInfo, "F_Workout") then
                    functionPicked = F_Workout
                elseif AreaPOICompareName(POIInfo, "F_Crying") then
                    functionPicked = F_Crying
                elseif AreaPOICompareName(POIInfo, "F_OutsideClass") then
                    functionPicked = F_OutsideClass
                elseif AreaPOICompareName(POIInfo, "F_DrunkenBeggar") then
                    functionPicked = F_DrunkenBeggar
                elseif AreaPOICompareName(POIInfo, "F_WallSmoking") then
                    functionPicked = F_WallSmoking
                elseif AreaPOICompareName(POIInfo, "F_BullyDogs") then
                    functionPicked = F_BullyDogs
                elseif AreaPOICompareName(POIInfo, "F_BikeCheckout") then
                    functionPicked = F_BikeCheckout
                elseif AreaPOICompareName(POIInfo, "F_Sweep") then
                    functionPicked = F_Sweep
                elseif AreaPOICompareName(POIInfo, "F_CarnivalWalker") then
                    functionPicked = F_CarnivalWalker
                elseif AreaPOICompareName(POIInfo, "F_Industrial") then
                    functionPicked = F_Industrial
                elseif AreaPOICompareName(POIInfo, "F_DockWorker") then
                    functionPicked = F_DockWorker
                elseif AreaPOICompareName(POIInfo, "F_MillWorker") then
                    functionPicked = F_MillWorker
                elseif AreaPOICompareName(POIInfo, "F_WallHangout") then
                    functionPicked = F_WallHangout
                elseif AreaPOICompareName(POIInfo, "F_Rats") then
                    functionPicked = F_Rats
                elseif AreaPOICompareName(POIInfo, "F_ClassSmokers") then
                    functionPicked = F_ClassSmokers
                elseif AreaPOICompareName(POIInfo, "F_CreateMentalPatient") then
                    functionPicked = F_CreateMentalPatient
                elseif AreaPOICompareName(POIInfo, "F_Pirate") then
                    functionPicked = F_Pirate
                elseif AreaPOICompareName(POIInfo, "F_Brawl") then
                    functionPicked = F_Brawl
                elseif AreaPOICompareName(POIInfo, "F_WorkerHangout") then
                    functionPicked = F_WorkerHangout
                elseif AreaPOICompareName(POIInfo, "F_Straggler") then
                    functionPicked = F_Straggler
                elseif AreaPOICompareName(POIInfo, "F_PreppyStraggler") then
                    functionPicked = F_PreppyStraggler
                elseif AreaPOICompareName(POIInfo, "F_Fireman") then
                    functionPicked = F_Fireman
                elseif AreaPOICompareName(POIInfo, "F_SmokingFireman") then
                    functionPicked = F_SmokingFireman
                elseif AreaPOICompareName(POIInfo, "F_SocialHumiliation") then
                    functionPicked = F_SocialHumiliation
                elseif AreaPOICompareName(POIInfo, "F_ReachItHumiliation") then
                    functionPicked = F_ReachItHumiliation
                elseif AreaPOICompareName(POIInfo, "F_PrincipalPOI") then
                    functionPicked = F_PrincipalPOI
                elseif AreaPOICompareName(POIInfo, "F_InstantBully") then
                    functionPicked = F_InstantBully
                elseif AreaPOICompareName(POIInfo, "F_RandomStudent") then
                    functionPicked = F_RandomStudent
                elseif AreaPOICompareName(POIInfo, "F_LockerStuff") then
                    functionPicked = F_LockerStuff
                elseif AreaPOICompareName(POIInfo, "F_TrashStuff") then
                    functionPicked = F_TrashStuff
                elseif AreaPOICompareName(POIInfo, "F_Swirlie") then
                    functionPicked = F_Swirlie
                elseif AreaPOICompareName(POIInfo, "F_Criminal") then
                    functionPicked = F_Criminal
                elseif AreaPOICompareName(POIInfo, "F_HCriminal") then
                    functionPicked = F_HCriminal
                elseif AreaPOICompareName(POIInfo, "F_Puker") then
                    functionPicked = F_Puker
                elseif AreaPOICompareName(POIInfo, "F_ProjAttack") then
                    functionPicked = F_ProjAttack
                elseif AreaPOICompareName(POIInfo, "F_Russell") then
                    functionPicked = F_Russell
                elseif AreaPOICompareName(POIInfo, "F_RoofSniper") then
                    functionPicked = F_RoofSniper
                elseif AreaPOICompareName(POIInfo, "F_GuardDog") then
                    functionPicked = F_GuardDog
                elseif AreaPOICompareName(POIInfo, "F_Truck") then
                    functionPicked = F_Truck
                elseif AreaPOICompareName(POIInfo, "F_HStudent") then
                    functionPicked = F_HStudent
                elseif AreaPOICompareName(POIInfo, "F_CBarkerGame") then
                    functionPicked = F_CBarkerGame
                elseif AreaPOICompareName(POIInfo, "F_CBarkerGame2") then
                    functionPicked = F_CBarkerGame2
                elseif AreaPOICompareName(POIInfo, "F_CBarkerHouse") then
                    functionPicked = F_CBarkerHouse
                elseif AreaPOICompareName(POIInfo, "F_WorkerSmoking") then
                    functionPicked = F_WorkerSmoking
                elseif AreaPOICompareName(POIInfo, "F_Biker") then
                    functionPicked = F_Biker
                elseif AreaPOICompareName(POIInfo, "F_SocialHangout") then
                    functionPicked = F_SocialHangout
                elseif AreaPOICompareName(POIInfo, "F_DogWalker") then
                    functionPicked = F_DogWalker
                elseif AreaPOICompareName(POIInfo, "F_Arrest") then
                    functionPicked = F_Arrest
                elseif AreaPOICompareName(POIInfo, "F_DunkMidget") then
                    functionPicked = F_DunkMidget
                end
            end
        end
        if functionPicked ~= nil then
            functionPicked(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, nil)
        end
    end
end

function F_GetEventFunction(pTable)
    if pTable ~= nil and table.getn(pTable) > 0 then
        return RandomTableElement(pTable)
    end
    return nil
end

--[[
function F_POIDriver(POIInfo)
    local POIPointType = AreaPOIGetInterestType(POIInfo)
    local POIPointFaction = AreaPOIGetFaction(POIInfo)
    local POIPointNum = AreaPOIGetMaxNumber(POIInfo)
    local POIGender = AreaPOIGetGender(POIInfo)
    local functionPicked
    AreaPOISetActivation(POIInfo, true)
    if not gCallIndividual then
        for i, event in gDriverFunctionTable do
            if i == gCurrentFunction then
                functionPicked = event
                break
            end
        end
        functionPicked(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender, ped1, ped2, ped3, ped4)
    elseif gCallIndividual then
        local ped1, ped2, ped3, ped4
        F_Sweep(POIInfo, POIPointType, POIPointFaction, POIPointNum, POIGender)
    end
end
]] -- Not present in original script

function ShouldEventInitiate(info)
    local POIPointType = AreaPOIGetInterestType(info)
    local gShouldCreate = false
    local roll = 0
    if shared.gRunPOITest == false then
        return true
    end
    roll = math.random(1, 100)
    if POIPointType == 15 then
        if shared.gMissionPhoto4 == true and (AreaPOICompareName(info, "F_DrunkenBeggar") or AreaPOICompareName(info, "F_BullyDogs")) then
            --print("Drunken beggar trying to activate: ", roll)
            if 10 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_ClassSmokers") or AreaPOICompareName(info, "F_SmokingFireman") then
            if 40 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_InstantBully") then
            if 30 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_DrunkenBeggar") then
            if 30 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_Russell") then
            if 0 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_Truck") then
            if 0 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_Biker") then
            if 5 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_GuardDog") or AreaPOICompareName(info, "F_BullyDogs") then
            if 25 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_LockerStuff") or AreaPOICompareName(info, "F_SocialHumiliation") or AreaPOICompareName(info, "F_TrashStuff") or AreaPOICompareName(info, "F_Swirlie") then
            if 30 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_WorkerHangout") or AreaPOICompareName(info, "F_WorkerSmoking") then
            if 0 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_Criminal") then
            if AreaGetVisible() == 9 then
                if 75 <= roll then
                    gShouldCreate = true
                else
                    gShouldCreate = false
                end
            elseif 20 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_HCriminal") or AreaPOICompareName(info, "F_HStudent") then
            if 5 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_CarnivalWalker") or AreaPOICompareName(info, "F_Industrial") or AreaPOICompareName(info, "F_DockWorker") or AreaPOICompareName(info, "F_MillWorker") or AreaPOICompareName(info, "F_PrincipalPOI") or AreaPOICompareName(info, "F_DockWorker") or AreaPOICompareName(info, "F_MillWorker") or AreaPOICompareName(info, "F_Fireman") or AreaPOICompareName(info, "F_RandomStudent") or AreaPOICompareName(info, "F_SocialHangout") then
            if 0 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_CBarkerGame") or AreaPOICompareName(info, "F_CBarkerGame2") or AreaPOICompareName(info, "F_DunkMidget") or AreaPOICompareName(info, "F_CBarkerHouse") then
            gShouldCreate = truethen
            gShouldCreate = true
        elseif AreaPOICompareName(info, "F_Rats") then
            if 30 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_RoofSniper") then
            if 75 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_Puker") then
            if 50 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_ProjAttack") then
            if 30 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_Crying") then
            if 50 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_Workout") or AreaPOICompareName(info, "F_Cheerleading") then
            if 50 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_DogWalker") then
            if 40 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_Catch") then
            if 25 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaPOICompareName(info, "F_Straggler") then
            if 70 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif AreaGetVisible == 13 then
            if 25 <= roll then
                gShouldCreate = true
            else
                gShouldCreate = false
            end
        elseif 50 <= roll then
            gShouldCreate = true
        else
            gShouldCreate = false
        end
    elseif POIPointType == 8 then
        if 60 <= roll then
            gShouldCreate = true
        else
            gShouldCreate = false
        end
    elseif 55 <= roll then
        gShouldCreate = true
    else
        gShouldCreate = false
    end
    if gShouldCreate == true then
        return true
    end
    return false
end

--[[
function Validate(itemsTable)
    local failedValidation = false
    for i, item in itemsTable do
        if item == -1 or item == nil then
            item = nil
            failedValidation = true
        end
    end
    return failedValidation
end
]] -- Not present in original script
