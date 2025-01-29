--[[ Changes to this file:
    * Modified function main, may require testing
    * Modified function F_CheckConditions, may require testing
]]

POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local model = { 173 }
local bActive = false
local bOnMission = true
local ObjFlag = false
local bReturn = false
local MissionScenarioComplete = false

function main() -- ! Modified
    --[[
    if MiniObjectiveGetIsComplete(15) ~= true then
    ]] -- Changed to:
    if MiniObjectiveGetIsComplete(16) ~= true then
        --print("LAUNCHING PIRATE")
        PedSetUniqueModelStatus(173, 1)
        while SetupComplete == false do
            if OutOfRange == true or POIInfo == nil then
                SetupComplete = true
            else
                SetupComplete = F_ScenarioSetup()
            end
            Wait(0)
        end
        while F_CheckConditions() == true do
            Wait(0)
        end
        --print("CLEANING UP")
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    OutOfRange = F_PlayerOutOfRange()
    if ScenarioPed == -1 then
        LoadPedModels(model)
        LoadWeaponModels({ 299 })
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(173, POIInfo)
    end
    if PedIsValid(ScenarioPed) then
        PedClearPOI(ScenarioPed)
        PedStop(ScenarioPed)
        PedSetWeaponNow(ScenarioPed, 299, 1)
        PedSetPedToTypeAttitude(ScenarioPed, 13, 0)
        PedOverrideStat(ScenarioPed, 8, 100)
        PedOverrideStat(ScenarioPed, 6, 0)
        PedOverrideStat(ScenarioPed, 63, 0)
        PedEnableGiftRequirement(ScenarioPed, false)
        return true
    else
        return false
    end
end

function F_PlayerOutOfRange()
    local x1, y1, z1 = POIGetPosXYZ(POIInfo)
    local x2, y2, z2 = PlayerGetPosXYZ()
    if bOnMission then
        if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > AreaGetPopulationCullDistance() then
            return true
        else
            return false
        end
    end
end

function F_CheckConditions() -- ! Modified
    if PedIsValid(ScenarioPed) then
        if PedIsDead(ScenarioPed) and PedGetWhoHitMeLast(ScenarioPed) == gPlayer then
            MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_PIRATE")
            MinigameSetUberCompletion()
            ClothingGivePlayer("SP_PirateHat", 0)
            shared.gCurrentAmbientScenarioObject.completed = true
            --[[
            MiniObjectiveSetIsComplete(15)
            ]] -- Changed to:
            MiniObjectiveSetIsComplete(16)
            return false
        end
        return true
    else
        return false
    end
end

function F_ScenarioCleanup()
    PedSetUniqueModelStatus(173, -1)
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
