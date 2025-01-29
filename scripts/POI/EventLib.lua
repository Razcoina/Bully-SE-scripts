local BullyChoices = {
    11,
    4,
    5,
    2
}
report_level = 0

function dbg_print(dbg_level, string)
    if dbg_level <= report_level then
        --print(string)
    end
end

function LoadPedPOIModels(modelTable)
    local modelsLoaded = 1
    while 0 < modelsLoaded do
        modelsLoaded = 0
        for i, model in modelTable do
            if model ~= nil and model ~= -1 and not RequestModel(model, true) then
                modelsLoaded = modelsLoaded + 1
            end
        end
        Wait(0)
    end
end

function LoadPedPOIModel(model)
    local modelsLoaded = 1
    while 0 < modelsLoaded do
        modelsLoaded = 0
        if model ~= nil and model ~= -1 and not RequestModel(model, true) then
            modelsLoaded = modelsLoaded + 1
        end
        Wait(0)
    end
end

function LoadWeaponPOIModel(model)
    local modelsLoaded = 1
    while 0 < modelsLoaded do
        modelsLoaded = 0
        if model ~= nil and model ~= -1 and not WeaponRequestModel(model, true) then
            modelsLoaded = modelsLoaded + 1
        end
        Wait(0)
    end
end

function LoadVehiclePOIModel(model)
    local modelsLoaded = 1
    while 0 < modelsLoaded do
        modelsLoaded = 0
        if model ~= nil and model ~= -1 and not VehicleRequestModel(model, true) then
            modelsLoaded = modelsLoaded + 1
        end
        Wait(0)
    end
end

function GetStudent(POIFaction, POIGender, size, UseHalloweenModels)
    local pickedModel = 0
    local possibleFaction
    if UseHalloweenModels == nil then
        UseHalloweenModels = true
    end
    if size == nil then
        size = -1
    end
    if POIGender == nil then
        POIGender = 0
    end
    if POIFaction == nil then
        POIFaction = 12
    end
    if shared.gHalloweenActive == true and UseHalloweenModels == true then
        local AreaCount = 13
        if AreaGetVisible() == 14 then
            AreaCount = 11
        end
        for pedCount = 1, AreaCount do
            if AreaCount == 13 then
                pickedModel = RandomElement13(159, 161, 162, 163, 164, 166, 168, 167, 169, 170, 171, 173, 174)
            else
                pickedModel = RandomElement11(159, 161, 162, 163, 164, 168, 169, 170, 171, 173, 174)
            end
            if 0 < PedGetPedCountWithModel(pickedModel) then
                pickedModel = 0
                pedCount = pedCount + 1
            else
                pedCount = AreaCount + 1
                return pickedModel
            end
        end
        return -1
    end
    local ModelUniqueStatus = -1
    local ModelCurrentCount = 0
    for pedCount = 1, 7 do
        if POIFaction == 12 then
            possibleFaction = RandomElement5(6, 1, 5, 2, 4)
            pickedModel = PedGetRandomModelId(possibleFaction, POIGender, size)
        else
            pickedModel = PedGetRandomModelId(POIFaction, POIGender, size)
        end
        if 0 < PedGetUniqueModelStatus(pickedModel) and PedGetPedCountWithModel(pickedModel) >= PedGetUniqueModelStatus(pickedModel) then
            pickedModel = nil
        else
            pedCount = 8
            return pickedModel
        end
    end
    return -1
end

function GetGymModel(POIFaction)
    local pickedModel, possibleFaction
    if POIFaction == nil then
        POIFaction = 12
    end
    for pedCount = 1, 13 do
        if POIFaction ~= 2 then
            pickedModel = RandomElement13(200, 201, 203, 204, 206, 207, 208, 209, 210, 211, 212, 213, 214)
        else
            pickedModel = RandomElement3(204, 206, 207)
        end
        --print("=================> Model ID picked is : " .. pickedModel)
        if PedGetPedCountWithModel(pickedModel) > 0 or F_CheckGymModel(pickedModel) == false then
            pickedModel = nil
            pedCount = pedCount + 1
        else
            return pickedModel
        end
    end
    return -1
end

function F_CheckGymModel(Model)
    if Model == 200 and (PedGetUniqueModelStatus(22) == -1 or PedGetPedCountWithModel(22) > 0) then
        return false
    end
    if Model == 201 and (PedGetUniqueModelStatus(29) == -1 or 0 < PedGetPedCountWithModel(29)) then
        return false
    end
    if Model == 203 and (PedGetUniqueModelStatus(27) == -1 or 0 < PedGetPedCountWithModel(27)) then
        return false
    end
    if Model == 204 and PedGetUniqueModelStatus(18) == -1 then
        return false
    end
    if Model == 206 and PedGetUniqueModelStatus(20) == -1 then
        return false
    end
    if Model == 207 and PedGetUniqueModelStatus(13) == -1 then
        return false
    end
    if Model == 208 and (PedGetUniqueModelStatus(4) == -1 or 0 < PedGetPedCountWithModel(4)) then
        return false
    end
    if Model == 209 and (PedGetUniqueModelStatus(8) == -1 or 0 < PedGetPedCountWithModel(8)) then
        return false
    end
    if Model == 210 and (PedGetUniqueModelStatus(7) == -1 or 0 < PedGetPedCountWithModel(7)) then
        return false
    end
    if Model == 211 and (PedGetUniqueModelStatus(40) == -1 or 0 < PedGetPedCountWithModel(40)) then
        return false
    end
    if Model == 212 and (PedGetUniqueModelStatus(34) == -1 or 0 < PedGetPedCountWithModel(34)) then
        return false
    end
    if Model == 214 and (PedGetUniqueModelStatus(30) == -1 or 0 < PedGetPedCountWithModel(30)) then
        return false
    end
    if Model == 213 and (PedGetUniqueModelStatus(31) == -1 or 0 < PedGetPedCountWithModel(31)) then
        return false
    end
    return true
end

function F_GetStudentInArea(PedFaction)
    local FoundPed
    if PedFaction ~= 12 then
        FoundPed = PedFindRandomPed(PedFaction, 1, -1, 25)
        if FoundPed ~= -1 and not PedHasPOI(FoundPed) and PedIsOnScreen(FoundPed) then
            return FoundPed
        end
    else
        for i, key in BullyChoices do
            FoundPed = PedFindRandomPed(key, 1, -1, 15)
            if FoundPed ~= -1 and not PedHasPOI(FoundPed) and PedIsOnScreen(FoundPed) and PedGetFaction(FoundPed) ~= (8 or PedGetFaction(FoundPed) ~= 0 or PedGetFaction(FoundPed) ~= 7) then
                return FoundPed
            end
        end
    end
    return -1
end

function F_GetOpposingFaction(factionPicked)
    RChoice = math.random(1, 100)
    if factionPicked ~= 6 and RChoice < 15 then
        return 6
    elseif factionPicked == 4 then
        return 5
    elseif factionPicked == 2 then
        return 1
    elseif factionPicked == 5 then
        return 4
    elseif factionPicked == 1 then
        return 2
    elseif factionPicked == 11 then
        if RChoice > 50 then
            return 1
        else
            return 6
        end
    elseif factionPicked == 3 then
        if RChoice < 50 then
            return 11
        elseif RChoice < 75 then
            return 4
        else
            return 5
        end
    elseif factionPicked == 6 then
        return 11
    elseif factionPicked == 9 then
        return 10
    elseif factionPicked == 10 then
        return 10
    end
    return 6
end

function F_ChoosePrank(Ped, PedFaction)
    if PedIsValid(Ped) then
        local WChoice
        local WRoll = math.random(0, 100)
        if 15 < WRoll then
            if PedFaction == 1 then
                WChoice = RandomElement4(309, 301, 397, 307)
            else
                WChoice = RandomElement8(397, 372, 349, 312, 346, 309, 301, 394)
            end
            while not WeaponRequestModel(WChoice, true) do
                Wait(0)
            end
            ModelNotNeededAmbient(WChoice)
            if PedIsValid(Ped) then
                if WChoice == 301 or WChoice == 309 or WChoice == 346 then
                    PedOverrideStat(Ped, 10, 5)
                end
                if WChoice == 307 then
                    PedSetWeapon(Ped, WChoice, 5)
                else
                    PedSetWeapon(Ped, WChoice, 1)
                end
            end
        end
    end
end

function F_SelectBrawlWeapon(Ped, PedFaction)
    local WChoice
    if PedFaction == 1 then
        WChoice = RandomElement2(301, 307)
    elseif PedFaction == 5 then
        WChoice = 312
    elseif PedFaction == 4 then
        WChoice = 303
    elseif PedFaction == 11 then
        WChoice = 303
    elseif PedFaction == 3 then
        WChoice = 311
    else
        return
    end
    while not WeaponRequestModel(WChoice, true) do
        Wait(0)
    end
    ModelNotNeededAmbient(WChoice)
    if PedIsValid(Ped) then
        if WChoice == 307 then
            PedSetWeapon(Ped, WChoice, 5)
        elseif WChoice == 312 then
            PedSetWeapon(Ped, WChoice, 5)
        else
            PedSetWeaponNow(Ped, WChoice, 1)
        end
    end
end

function F_SelectProjWeapon(Ped, PedFaction)
    local WChoice = 312
    while not WeaponRequestModel(WChoice, true) do
        Wait(0)
    end
    ModelNotNeededAmbient(WChoice)
    if PedIsValid(Ped) then
        PedClearAllWeapons(Ped)
        PedSetWeapon(Ped, WChoice, 5)
    end
end

function F_ChooseSniperWeapon(Ped)
    local WChoice
    if PedFaction == 1 then
        WChoice = RandomElement2(307, 301)
    else
        WChoice = RandomElement3(303, 306, 301)
    end
    while not WeaponRequestModel(WChoice, true) do
        Wait(0)
    end
    ModelNotNeededAmbient(WChoice)
    if PedIsValid(Ped) then
        if WChoice == 307 then
            PedSetWeapon(Ped, WChoice, 1)
        elseif WChoice == 301 then
            PedSetWeapon(Ped, WChoice, 10)
        else
            PedSetWeaponNow(Ped, WChoice, 1)
        end
    end
end

function RandomElement2(elem1, elem2)
    rand = math.random(1, 100)
    if rand > 50 then
        return elem2
    end
    return elem1
end

function RandomElement3(elem1, elem2, elem3)
    rand = math.random(1, 3)
    if rand == 1 then
        return elem1
    end
    if rand == 2 then
        return elem2
    end
    if rand == 3 then
        return elem3
    end
    return elem1
end

function RandomElement4(elem1, elem2, elem3, elem4)
    rand = math.random(1, 4)
    if rand == 1 then
        return elem1
    end
    if rand == 2 then
        return elem2
    end
    if rand == 3 then
        return elem3
    end
    if rand == 4 then
        return elem4
    end
    return elem1
end

function RandomElement5(elem1, elem2, elem3, elem4, elem5)
    rand = math.random(1, 5)
    if rand == 1 then
        return elem1
    end
    if rand == 2 then
        return elem2
    end
    if rand == 3 then
        return elem3
    end
    if rand == 4 then
        return elem4
    end
    if rand == 5 then
        return elem5
    end
    return elem1
end

function RandomElement6(elem1, elem2, elem3, elem4, elem5, elem6)
    rand = math.random(1, 6)
    if rand == 1 then
        return elem1
    end
    if rand == 2 then
        return elem2
    end
    if rand == 3 then
        return elem3
    end
    if rand == 4 then
        return elem4
    end
    if rand == 5 then
        return elem5
    end
    if rand == 6 then
        return elem6
    end
    return elem1
end

function RandomElement7(elem1, elem2, elem3, elem4, elem5, elem6, elem7)
    rand = math.random(1, 7)
    if rand == 1 then
        return elem1
    end
    if rand == 2 then
        return elem2
    end
    if rand == 3 then
        return elem3
    end
    if rand == 4 then
        return elem4
    end
    if rand == 5 then
        return elem5
    end
    if rand == 6 then
        return elem6
    end
    if rand == 7 then
        return elem7
    end
    return elem1
end

function RandomElement8(elem1, elem2, elem3, elem4, elem5, elem6, elem7, elem8)
    rand = math.random(1, 8)
    if rand == 1 then
        return elem1
    end
    if rand == 2 then
        return elem2
    end
    if rand == 3 then
        return elem3
    end
    if rand == 4 then
        return elem4
    end
    if rand == 5 then
        return elem5
    end
    if rand == 6 then
        return elem6
    end
    if rand == 7 then
        return elem7
    end
    if rand == 8 then
        return elem8
    end
    return elem1
end

function RandomElement13(elem1, elem2, elem3, elem4, elem5, elem6, elem7, elem8, elem9, elem10, elem11, elem12, elem13)
    rand = math.random(1, 13)
    if rand == 1 then
        return elem1
    end
    if rand == 2 then
        return elem2
    end
    if rand == 3 then
        return elem3
    end
    if rand == 4 then
        return elem4
    end
    if rand == 5 then
        return elem5
    end
    if rand == 6 then
        return elem6
    end
    if rand == 7 then
        return elem7
    end
    if rand == 8 then
        return elem8
    end
    if rand == 9 then
        return elem9
    end
    if rand == 10 then
        return elem10
    end
    if rand == 11 then
        return elem11
    end
    if rand == 12 then
        return elem12
    end
    if rand == 13 then
        return elem13
    end
    return elem1
end

function RandomElement11(elem1, elem2, elem3, elem4, elem5, elem6, elem7, elem8, elem9, elem10, elem11)
    rand = math.random(1, 11)
    if rand == 1 then
        return elem1
    end
    if rand == 2 then
        return elem2
    end
    if rand == 3 then
        return elem3
    end
    if rand == 4 then
        return elem4
    end
    if rand == 5 then
        return elem5
    end
    if rand == 6 then
        return elem6
    end
    if rand == 7 then
        return elem7
    end
    if rand == 8 then
        return elem8
    end
    if rand == 9 then
        return elem9
    end
    if rand == 10 then
        return elem10
    end
    if rand == 11 then
        return elem11
    end
    return elem1
end

function RandomElement14(elem1, elem2, elem3, elem4, elem5, elem6, elem7, elem8, elem9, elem10, elem11, elem12, elem13, elem14)
    rand = math.random(1, 14)
    if rand == 1 then
        return elem1
    end
    if rand == 2 then
        return elem2
    end
    if rand == 3 then
        return elem3
    end
    if rand == 4 then
        return elem4
    end
    if rand == 5 then
        return elem5
    end
    if rand == 6 then
        return elem6
    end
    if rand == 7 then
        return elem7
    end
    if rand == 8 then
        return elem8
    end
    if rand == 9 then
        return elem9
    end
    if rand == 10 then
        return elem10
    end
    if rand == 11 then
        return elem11
    end
    if rand == 12 then
        return elem12
    end
    if rand == 13 then
        return elem13
    end
    if rand == 14 then
        return elem14
    end
    return elem1
end

function POIActionNode2(ped1, ped2, actionNode, fileName)
    if string.find(actionNode, "Global") == nil then
        --print("============>>>> YOU HAVE NOT SPECIFIED A PROPER PATH FOR THE NODE!!!!")
        --print("============>>>> NODE PASSED IN: ", actionNode)
        --print("============>>>> FILE NAME REFERRENCED: ", fileName)
        return
    end
    while PedIsValid(ped1) and PedIsValid(ped2) do
        if not PedIsPlaying(ped1, actionNode, true) and not PedIsPlaying(ped1, actionNode, false) then
            PedSetActionNode(ped1, actionNode, fileName)
        else
            return true
        end
        Wait(0)
    end
    if PedIsValid(ped1) then
        PedClearPOI(ped1)
    end
    if PedIsValid(ped2) then
        PedClearPOI(ped2)
    end
    return false
end

function F_IsSmallKid(PedModel)
    if PedModel == 69 or PedModel == 66 or PedModel == 68 or PedModel == 137 or PedModel == 138 or PedModel == 159 then
        return true
    end
    return false
end
