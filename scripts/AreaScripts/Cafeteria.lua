local LunchLadyModelLoad = false
local LunchLadyActive = true
local LunchCook1 = false
local LunchCook2 = false
local CafeLineLoad = false
local CafeLineActive = false
local CafLineTable = {}
local CafFactionTable = {
    5,
    6,
    4,
    1,
    2
}

function main()
end

function F_CafCook(ped, path, node)
    local CookChance = math.random(1, 100)
    if node == 2 and 20 < CookChance then
        LunchCook1 = true
    elseif node == 3 and 40 < CookChance then
        LunchCook2 = true
    end
end

function F_UpdateLUNCH()
    local CafTriggerOn = true
    local nEdnaModel
    if GetMissionSuccessCount("2_S05") >= 1 and 1 > GetMissionSuccessCount("2_S05B") and 1 > GetMissionSuccessCount("6_01") then
        nEdnaModel = 221
    else
        nEdnaModel = 58
    end
    if LunchLadyModelLoad == true then
        while not RequestModel(nEdnaModel, true) do
            Wait(0)
        end
        shared.gEdnaID = PedCreatePoint(nEdnaModel, POINTLIST._AMBLUNCHLADY)
        PedModelNotNeededAmbient(shared.gEdnaID)
        PedFollowPath(shared.gEdnaID, PATH._AMBLUNCHLADYPATH, 1, 0, F_CafCook)
        PedSetTetherToPoint(shared.gEdnaID, POINTLIST._AMBLUNCHLADY, 12)
        LunchLadyModelLoad = false
    end
    local hour, minute = ClockGet()
    if hour <= 19 and 7 <= hour and not MissionActive() then
        LunchLadyActive = true
    else
        LunchLadyActive = false
    end
    if not MissionActive() then
        if hour == 11 and 30 < minute or hour == 12 and minute < 59 then
            CafeLineActive = true
        else
            CafeLineActive = false
        end
    end
    if hour == 7 and minute == 0 then
        if CafTriggerOn == true then
            CafTriggerOn = false
            AreaDeactivatePopulationTrigger(TRIGGER._CAFTRIGGER)
        end
    elseif hour == 9 and minute == 0 then
        if CafTriggerOn == false then
            CafTriggerOn = true
            AreaActivatePopulationTrigger(TRIGGER._CAFTRIGGER)
        end
    elseif hour == 11 and minute == 30 then
        if CafTriggerOn == true then
            CafTriggerOn = false
            AreaDeactivatePopulationTrigger(TRIGGER._CAFTRIGGER)
        end
    elseif hour == 13 and minute == 0 then
        if CafTriggerOn == false then
            CafTriggerOn = true
            AreaActivatePopulationTrigger(TRIGGER._CAFTRIGGER)
        end
    elseif hour == 15 and minute == 30 then
        if CafTriggerOn == true then
            CafTriggerOn = false
            AreaDeactivatePopulationTrigger(TRIGGER._CAFTRIGGER)
        end
    elseif hour == 18 and minute == 30 and CafTriggerOn == false then
        CafTriggerOn = true
        AreaActivatePopulationTrigger(TRIGGER._CAFTRIGGER)
    end
    if LunchCook1 == true then
        LunchCook1 = false
        Wait(1000)
        ExecuteActionNode(shared.gEdnaID, "/Global/Ambient/Scripted/Cookin/Cook2", "Act/Anim/Ambient.act")
    end
    if LunchCook2 == true then
        LunchCook2 = false
        Wait(1000)
        ExecuteActionNode(shared.gEdnaID, "/Global/Ambient/Scripted/Cookin/Cook1", "Act/Anim/Ambient.act")
    end
    if CafeLineLoad == true then
        CafeLineLoad = false
        local ped1, student, weapon, faction, pathnode, x, y, z
        while not WeaponRequestModel(348) do
            Wait(0)
        end
        for i = 1, 6 do
            faction = RandomTableElement(CafFactionTable)
            ped1 = GetStudent(faction, 0, -1)
            if ped1 == -1 then
                return
            end
            while not RequestModel(ped1, true) do
                Wait(0)
            end
            x, y, z = GetPointFromPointList(POINTLIST._CAFELINEUP1, i)
            if not PlayerIsInAreaXYZ(x, y, z, 8, 0) then
                student = PedCreatePoint(ped1, POINTLIST._CAFELINEUP1, i)
                PedModelNotNeededAmbient(student)
                if student == -1 then
                    return
                end
                PedSetWeapon(student, 348, 1)
                PedWander(student, 0)
                pathnode = i - 1
                if pathnode == 4 or pathnode == 6 then
                    pathnode = pathnode + 1
                end
                PedFollowPath(student, PATH._CAFPATH1, 0, 0, F_CafAmb, pathnode)
                while not PedHasWeapon(student, 348) == true do
                    Wait(0)
                end
                weapon = PedGetWeapon(student)
                PedSetWeaponFlag(student, weapon, 0, true)
                PedMakeAmbient(student)
                table.insert(CafLineTable, student)
            end
        end
        i = nil
        for i = 1, 4 do
            faction = RandomTableElement({
                5,
                6,
                4,
                1,
                2
            })
            ped1 = GetStudent(faction, 0, -1)
            if ped1 == -1 then
                return
            end
            while not RequestModel(ped1, true) do
                Wait(0)
            end
            x, y, z = GetPointFromPointList(POINTLIST._CAFELINEUP2, i)
            if not PlayerIsInAreaXYZ(x, y, z, 8, 0) then
                student = PedCreatePoint(ped1, POINTLIST._CAFELINEUP2, i)
                PedModelNotNeededAmbient(student)
                if student == -1 then
                    return
                end
                PedSetWeapon(student, 348, 1)
                pathnode = i - 1
                if pathnode == 4 or pathnode == 6 then
                    pathnode = pathnode + 1
                end
                PedFollowPath(student, PATH._CAFPATH2, 0, 0, F_CafAmb2, pathnode)
                while not PedHasWeapon(student, 348) == true do
                    Wait(0)
                end
                weapon = PedGetWeapon(student)
                PedSetWeaponFlag(student, weapon, 0, true)
                PedMakeAmbient(student)
                table.insert(CafLineTable, student)
            end
        end
    end
end

function F_CafAmb(ped, path, node)
    if node == 6 then
        PedSetTetherToPoint(ped, POINTLIST._CAFELINEUP1, 20)
    end
end

function F_CafAmb2(ped, path, node)
    if node == 5 then
        PedSetTetherToPoint(ped, POINTLIST._CAFELINEUP1, 20)
    end
end

function F_RegisterCAFEvents()
    RegisterTriggerEventHandler(TRIGGER._LUNCHLADYTRIGGER, 1, F_LunchLadyCreate, 0)
    RegisterTriggerEventHandler(TRIGGER._LUNCHLADYTRIGGER, 4, F_LunchLadyDestroy, 0)
    AreaSetTriggerMonitoringRules(TRIGGER._LUNCHLADYTRIGGER, true)
end

function F_LunchLadyCreate(triggerID, pedID)
    if LunchLadyActive == true then
        if shared.gEdnaOverride then
            --print(">>>[Cafeteria.lua]", "Edna Creation overidden")
            return
        elseif shared.gEdnaID == nil then
            --print(">>>[Cafeteria.lua]", "Edna Creation firing")
            LunchLadyModelLoad = true
        end
    end
    if CafeLineActive == true then
        CafeLineLoad = true
    end
end

function F_LunchLadyDestroy(triggerID, pedID)
    if shared.gEdnaID ~= nil then
        PedDelete(shared.gEdnaID)
        shared.gEdnaID = nil
    end
    for i, ped in CafLineTable do
        if PedIsValid(ped) and not PedIsOnScreen(ped) then
            PedDelete(ped)
        end
        table.remove(CafLineTable, i)
    end
end

function F_KillCafTable()
    CafLineTable = nil
end
