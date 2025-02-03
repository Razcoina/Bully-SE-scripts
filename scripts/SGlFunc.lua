function RandomIndex(arg_table)
    if type(arg_table) == "table" then
        return math.random(1, table.getn(arg_table))
    end
end

function RandomTableElement(arg_table)
    local random_index = RandomIndex(arg_table)
    if random_index then
        return arg_table[random_index]
    end
    return {}
end

function F_SetCharacterModelsUnique(bOn, models)
    if not gUniqueModels then
        gUniqueModels = {}
    end
    if bOn then
        --print(">>>[RUI]", "++F_SetCharacterModelsUnique")
        if not models then
            return
        end
        for _, m in models do
            u = PedGetUniqueModelStatus(m)
            PedSetUniqueModelStatus(m, -1)
            --print(">>>[RUI]", "F_SetCharacterModelsUnique ON  model:" .. tostring(m) .. " stat:" .. tostring(u))
            table.insert(gUniqueModels, { model = m, unique = u })
        end
    else
        --print(">>>[RUI]", "--F_SetCharacterModelsUnique")
        if not gUniqueModels then
            return
        end
        for _, m in gUniqueModels do
            if m.unique then
                --print(">>>[RUI]", "F_SetCharacterModelsUnique OFF model:" .. tostring(m.model) .. " stat:" .. tostring(m.unique))
                PedSetUniqueModelStatus(m.model, m.unique)
            end
        end
    end
end

function GetSkippedClasses()
    local total = 0
    for i, class_skipped in shared.gClassesSkipped do
        if class_skipped then
            total = total + 1
        end
    end
    return total
end

function SetSkippedClass(skipped)
    table.remove(shared.gClassesSkipped, 1)
    table.insert(shared.gClassesSkipped, skipped)
end

local gSkippingPunishmentThresholds = {
    { skipped_classes = 1, punishment_points = 100 },
    { skipped_classes = 3, punishment_points = 100 },
    { skipped_classes = 5, punishment_points = 200 }
}

function GetSkippingPunishment()
    local skipping_punishment = 0
    for i, threshold in gSkippingPunishmentThresholds do
        if GetSkippedClasses() >= threshold.skipped_classes then
            skipping_punishment = threshold.punishment_points
        end
    end
    return skipping_punishment
end

function WaitSkippable(intMilliseconds, F_OnSkip, tblParams)
    --assert(intMilliseconds ~= nil, "SGlFunc.lua:  WaitSkippable -- milliseconds param cannot be nil!")
    --assert(0 < intMilliseconds, "SGlFunc.lua:  WaitSkippable -- milliseconds param must be >= 0!")
    local EndTime = GetTimer() + intMilliseconds
    local WaitOccurred = false
    while EndTime > GetTimer() do
        if F_IsButtonPressedWithDelayCheck(7, 0) then
            if F_OnSkip ~= nil then
                F_OnSkip(tblParams)
            end
            return true
        end
        Wait(0)
        WaitOccurred = true
    end
    if not WaitOccurred then
        Wait(0)
    end
    return false
end

function F_StealthSpottedText()
    TextPrint("STEALTH_SPOTTED", 4, 2)
end

function WaitInterruptible(intMilliseconds, F_InterruptCondition)
    --assert(intMilliseconds ~= nil, "SGlFunc.lua:  WaitSkippable -- milliseconds param cannot be nil!")
    --assert(0 < intMilliseconds, "SGlFunc.lua:  WaitSkippable -- milliseconds param must be >= 0!")
    local EndTime = GetTimer() + intMilliseconds
    while EndTime > GetTimer() do
        if F_InterruptCondition ~= nil and F_InterruptCondition() then
            return true
        end
        Wait(0)
    end
    return false
end

local __LastButtonTime = {
    0,
    0,
    0
}

function F_IsButtonPressedWithDelayCheck(button, pad, timerIndex, delay)
    timerIndex = timerIndex or 1
    delay = delay or 200
    --assert(__LastButtonTime[timerIndex], "SGlFunc.lua: bad timerIndex.")
    if IsButtonPressed(button, pad) and delay < GetTimer() - __LastButtonTime[timerIndex] then
        __LastButtonTime[timerIndex] = GetTimer()
        return true
    end
    return false
end

function WaitAreaDATLoad()
    while not shared.gAreaDataLoaded do
        Wait(0)
    end
end

function DisablePOI(bScriptedPOIs, bHangOutSpots)
    if bScriptedPOIs == nil or bScriptedPOIs == true then
        POISetSystemEnabled(false)
    end
    if bHangOutSpots == nil or bHangOutSpots == true then
        POIGroupsEnabled(false)
    end
end

function EnablePOI(bScriptedPOIs, bHangOutSpots)
    POISetSystemEnabled(true)
    POIGroupsEnabled(true)
end

function LoadModels(modelTable, bIsWeapon)
    local modelsLoaded = 1
    while 0 < modelsLoaded do
        modelsLoaded = 0
        for i, model in modelTable do
            if F_ObjectIsValid(model) then
                if not bIsWeapon or bIsWeapon == nil then
                    if not RequestModel(model) then
                        modelsLoaded = modelsLoaded + 1
                    end
                elseif not WeaponRequestModel(model) then
                    modelsLoaded = modelsLoaded + 1
                end
            end
        end
        Wait(0)
    end
end

function LoadPedModels(modelTable)
    LoadModels(modelTable, false)
end

function LoadWeaponModels(modelTable)
    LoadModels(modelTable, true)
end

function LoadVehicleModels(modelTable)
    for i, model in modelTable do
        if F_ObjectIsValid(model) then
            VehicleRequestModel(model)
        end
    end
    local modelsLoaded = false
    while not modelsLoaded do
        Wait(0)
        modelsLoaded = true
        for i, model in modelTable do
            if F_ObjectIsValid(model) and not VehicleRequestModel(model) then
                modelsLoaded = false
                break
            end
        end
    end
end

function LoadPAnims(triggerTable)
    local blockForLoading = 0
    repeat
        for _, anim in triggerTable do
            if F_ObjectIsValid(anim) then
                if not PAnimRequest(anim) then
                    blockForLoading = blockForLoading + 1
                else
                    blockForLoading = blockForLoading - 1
                end
            end
        end
        Wait(0)
    until blockForLoading <= 0
end

function UnloadModels(models)
    for _, model in models do
        ModelNotNeeded(model)
    end
    --print(">>>[RUI]", "--UnloadModels")
end

local gTextTable = {}
local gPreviousTextClock = 0
local gPreviousTextTimer = 0

function QueueText(text, textTime, style, skip, cb_func)
    table.insert(gTextTable, {
        mText = text,
        mTime = textTime,
        mStyle = style,
        mType = false,
        mSkip = F_DefaultTrue(skip),
        callback = cb_func or nil
    })
end

function F_DefaultTrue(var)
    if var == false then
        return false
    end
    return true
end

function QueueTextString(text, textTime, style, skip, cb_func)
    table.insert(gTextTable, {
        mText = text,
        mTime = textTime,
        mStyle = style,
        mType = true,
        mSkip = F_DefaultToTrue(skip),
        callback = cb_func
    })
end

function QueueSoundSpeech(pedId, speechEvent, param, cb_func, volume)
    table.insert(gTextTable, {
        mSpeechPed = pedId,
        mSpeechEvent = speechEvent,
        mParam = param,
        callback = cb_func,
        vol = volume
    })
end

function F_DefaultToTrue(var)
    if var ~= true then
        return var
    end
    return true
end

function GetTextQueueSize()
    return table.getn(gTextTable)
end

local F_SkipOrNot = function(mSkip)
    if mSkip and F_IsButtonPressedWithDelayCheck(7, 0, 2, 200) then
        return true
    end
    return false
end

local sound_retval

function SoundPlayScriptedSpeechEventWrapper(id, bank, speechid, voltable)
    --DebugPrint("SoundPlayScriptedSpeechEventWrapper() ped: " .. id .. " bank: " .. bank .. " speechid: " .. speechid .. " voltable: " .. tostring(voltable))
    --DebugPrint("Time is now: " .. GetTimer())
    if voltable ~= nil then
        soundret = SoundPlayScriptedSpeechEvent(id, bank, speechid, voltable)
    else
        soundret = SoundPlayScriptedSpeechEvent(id, bank, speechid)
    end
    if soundret < 0 then
        --DebugPrint("SoundPlayScriptedSpeechEvent had error: " .. soundret)
    end
end

function UpdateTextQueue()
    if table.getn(gTextTable) > 0 then
        local event = gTextTable[1]
        if event.mText then
            if (GetTimer() - gPreviousTextClock) / 1000 > gPreviousTextTimer or F_SkipOrNot(event.mSkip) then
                if 0 < gPreviousTextClock then
                    --DebugPrint("removing from queue:  mText: " .. tostring(event.mText) .. " mTime: " .. tostring(event.mTime) .. " mStyle: " .. tostring(event.mStyle) .. " at time: " .. GetTimer())
                    table.remove(gTextTable, 1)
                    if table.getn(gTextTable) == 0 then
                        gPreviousTextClock = 0
                        return
                    end
                end
                event = gTextTable[1]
                gPreviousTextClock = GetTimer()
                gPreviousTextTimer = event.mTime
                if event.mType then
                    if event.mStyle then
                        if event.mText then
                            TextPrintString(event.mText, event.mTime, event.mStyle)
                        end
                    elseif event.mText then
                        TextPrintString(event.mText, event.mTime, 2)
                    end
                elseif event.mStyle then
                    if event.mText then
                        TextPrint(event.mText, event.mTime, event.mStyle)
                    end
                elseif event.mText then
                    TextPrint(event.mText, event.mTime, 2)
                end
                if event.callback then
                    event.callback(event.mText)
                end
            end
        elseif event.mSpeechPed then
            if event.mSpeechPed and PedIsValid(event.mSpeechPed) and SoundSpeechPlaying(event.mSpeechPed) == true then
                --print("SoundSpeechPlaying() == true")
                return
            elseif not PedIsValid(event.mSpeechPed) or SoundSpeechPlaying() == false or F_SkipOrNot(true) then
                if 0 < gPreviousTextClock then
                    --DebugPrint("removing from queue: mSpeechPed: " .. tostring(event.mSpeechPed) .. " mSpeechEvent: " .. tostring(event.mSpeechEvent) .. " mParam: " .. tostring(event.mParam) .. " at time: " .. GetTimer())
                    table.remove(gTextTable, 1)
                    if table.getn(gTextTable) == 0 then
                        gPreviousTextClock = 0
                        --print("returning early from UpdateTextQueue")
                        return
                    end
                end
                event = gTextTable[1]
                gPreviousTextClock = GetTimer()
                gPreviousTextTimer = 1
                if event.mSpeechPed and PedIsValid(event.mSpeechPed) then
                    sound_retval = SoundPlayScriptedSpeechEvent(event.mSpeechPed, event.mSpeechEvent, event.mParam, event.vol or "large")
                    if sound_retval ~= 0 then
                        --print("Error " .. sound_retval .. " when playing sound event id:" .. event.mSpeechEvent .. " parameter: " .. event.mParam)
                    else
                        --print("playing event:" .. tostring(event.mSpeechEvent) .. " parameter: " .. tostring(event.mParam) .. " at time: " .. GetTimer())
                    end
                else
                    --print("UpdateTextQueue: Ped not valid")
                end
                --print("Just called speech for ped " .. tostring(event.mSpeechPed) .. " param: " .. tostring(event.mParam))
                if event.callback then
                    event.callback(event.mSpeechEvent)
                end
                Wait(100)
            end
        end
    end
end

function ClearTextQueue()
    while table.getn(gTextTable) > 0 do
        table.remove(gTextTable)
    end
    gTextTable = {}
    gPreviousTextClock = 0
    gPreviousTextTimer = 0
    collectgarbage()
end

function ExecuteActionNode(ped, actionNode, fileName)
    if string.find(actionNode, "Global") == nil then
        --print("============>>>> YOU HAVE NOT SPECIFIED A PROPER PATH FOR THE NODE!!!!")
        --print("============>>>> NODE PASSED IN: ", actionNode)
        --print("============>>>> FILE NAME REFERRENCED: ", fileName)
        do return end
    end
    while true do
        Wait(0)
        if ped == nil then
            return nil
        elseif PedIsDead(ped) then
            return false
        elseif not PedIsDead(ped) then
            if not PedIsPlaying(ped, actionNode, true) and not PedIsPlaying(ped, actionNode, false) then
                PedSetActionNode(ped, actionNode, fileName)
            else
                return true
            end
        end
    end
end

function F_PlayerIsDead()
    return PlayerGetHealth() <= 0 or PedMePlaying(gPlayer, "Dead", true)
end

function AreaTransitionPoint(idArea, idPoint, numPoint, disableCameraControl)
    if disableCameraControl then
        AreaDisableCameraControlForTransition(true)
    end
    if numPoint == nil then
        PlayerSetPosPointArea(idArea, idPoint)
    else
        PlayerSetPosPointArea(idArea, idPoint, numPoint)
    end
    Wait(5)
    while AreaIsLoading() do
        Wait(0)
    end
    if disableCameraControl then
        AreaDisableCameraControlForTransition(false)
    end
    Wait(100)
end

function AreaTransitionXYZ(idArea, x, y, z, disableCameraControl)
    if disableCameraControl then
        AreaDisableCameraControlForTransition(true)
    end
    PlayerSetPosXYZArea(x, y, z, idArea)
    Wait(5)
    local count = 0
    while AreaIsLoading() do
        if count == 0 then
        end
        count = count + 1
        Wait(0)
    end
    if disableCameraControl then
        AreaDisableCameraControlForTransition(false)
    end
    Wait(100)
end

function ManagedPlayerSetPosPoint(idPoint, numPoint)
    if numPoint == nil then
        PlayerSetPosPoint(idPoint)
    else
        PlayerSetPosPoint(idPoint, numPoint)
    end
    Wait(5)
    while AreaIsLoading() do
        Wait(0)
    end
    Wait(100)
end

function ManagedPlayerSetPosXYZ(x, y, z)
    PlayerSetPosXYZ(x, y, z)
    Wait(5)
    while AreaIsLoading() do
        Wait(0)
    end
    Wait(100)
end

local textPrinting = false

function EntityInteract(info, radius, instruction, length, corona, button, bOverrideGrapple)
    local x, y, z
    if type(info) == "table" then
        x = info.x
        y = info.y
        z = info.z
        if corona == 3 then
            z = z + 0.6
        end
    elseif type(info) == "number" then
        if corona == 3 then
            x, y, z = PedGetHeadPos(info)
        else
            x, y, z = PedGetPosXYZ(info)
        end
    end
    if PedIsInAreaXYZ(gPlayer, x, y, z, radius, corona) then
        if IsButtonPressed(button, 0) then
            if bOverrideGrapple then
                PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/PlayerIdle/IdleOneFrame", "Act/Anim/Ambient.act")
            end
            TextPrint(instruction, 0, 3)
            textPrinting = false
            return true
        else
            if instruction ~= nil then
                TextPrint(instruction, 0.1, 3)
                textPrinting = true
            end
            return false
        end
    elseif textPrinting == true then
        textPrinting = false
    end
    return nil
end

function DistanceBetweenPeds2D(ped1_id, ped2_id)
    --assert(ped1_id ~= nil and 0 <= ped1_id, "DistanceBetweenPeds2D Error: Invalid ped id for ped1_id")
    --assert(ped2_id ~= nil and 0 <= ped2_id, "DistanceBetweenPeds2D Error: Invalid ped id for ped2_id")
    local x1, y1, z1 = PedGetPosXYZ(ped1_id)
    local x2, y2, z2 = PedGetPosXYZ(ped2_id)
    return DistanceBetweenCoords2d(x1, y1, x2, y2)
end

function DistanceBetweenPeds3D(ped1_id, ped2_id)
    --assert(ped1_id ~= nil and 0 <= ped1_id, "DistanceBetweenPeds3D Error: Invalid ped id for ped1_id")
    --assert(ped2_id ~= nil and 0 <= ped2_id, "DistanceBetweenPeds3D Error: Invalid ped id for ped2_id")
    local x1, y1, z1 = PedGetPosXYZ(ped1_id)
    local x2, y2, z2 = PedGetPosXYZ(ped2_id)
    return DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2)
end

function NonMissionPedGenerationDisable()
    AreaClearAllPeds()
    DisablePOI()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllVehicles()
    VehicleOverrideAmbient(0, 0, 0, 0)
end

function NonMissionPedGenerationEnable()
    AreaRevertToDefaultPopulation()
    EnablePOI()
    VehicleRevertToDefaultAmbient()
end

function F_EnableJimmyToOfficePA()
    --DebugPrint("********************** called F_EnablePA for jimmy announce")
    --DebugPrint("********************** calling the function")
    SoundMusicJimmyComeToTheOfficePA(true)
    --DebugPrint("********************** DONE")
end

function F_DisableJimmyToOfficePA()
    --DebugPrint("********************** called F_DiablePA for jimmy announce")
    SoundMusicJimmyComeToTheOfficePA(false)
    --DebugPrint("********************** DONE")
end

function TutorialMessage(messageString, bForceWait, messageWaitTime, gKeepMessage)
    local waitTime = messageWaitTime or 3000
    TutorialShowMessage(messageString)
    if bForceWait then
        Wait(waitTime)
    else
        WaitSkippable(waitTime)
    end
    if not gKeepMessage then
        TutorialRemoveMessage()
    end
end

function F_PedMoveAwayFromXYZ(pedid, x, y, z, distance)
    local px, py, pz = PedGetPosXYZ(pedid)
    local hyp = math.sqrt((x - px) ^ 2 + (y - py) ^ 2)
    local dx, dy = -(distance / hyp) * (x - px), -(distance / hyp) * (y - py)
    PlayerSetPosXYZ(px + dx, py + dy, z)
end

function F_VendorCheck()
    local weaponroll = math.random(1, 100)
    local roll = math.random(1, 100)
    local item, itemcount
    if PlayerHasItem(307) and 50 <= weaponroll then
        item = 308
        itemcount = 5
        TextPrint("SOC_VND2", 3, 2)
    elseif PlayerHasItem(305) and 50 <= weaponroll then
        item = 316
        itemcount = 5
        TextPrint("SOC_VND5", 3, 2)
    elseif roll < 30 then
        item = 301
        itemcount = 5
        TextPrint("SOC_VND1", 3, 2)
    elseif roll < 60 then
        item = 309
        itemcount = 5
        TextPrint("SOC_VND4", 3, 2)
    elseif roll <= 100 then
        item = 312
        itemcount = 5
        TextPrint("SOC_VND3", 3, 2)
    end
    GiveAmmoToPlayer(item, itemcount)
end

function F_PedIsHitByPlayer(ped, interval)
    local time = interval or 500
    if not F_PedExists(ped) then
        return false
    end
    PedClearHitRecord(ped)
    Wait(5)
    if PedIsHit(ped, 2, time) and PedGetWhoHitMeLast(ped) == gPlayer then
        return true
    end
end

function F_PedIsDead(ped)
    if not ped or ped == -1 then
        return true
    end
    return PedGetHealth(ped) <= 0
end

function F_PedExists(ped)
    return ped and PedIsValid(ped) and not F_PedIsDead(ped)
end

function F_RainBeGone()
    local weather = WeatherGet()
    if weather == 2 or weather == 5 then
        WeatherSet(1)
    else
        WeatherSet(weather)
    end
end

function F_PlaySpeechAndWait(model, event, parameter, volume, play2D, skippable)
    if volume then
        if play2D then
            SoundPlayScriptedSpeechEvent(model, event, parameter, volume, play2D)
        else
            SoundPlayScriptedSpeechEvent(model, event, parameter, volume)
        end
    else
        SoundPlayScriptedSpeechEvent(model, event, parameter)
    end
    Wait(500)
    local skipped = false
    while SoundSpeechPlaying(model) do
        if skippable and IsButtonPressed(7, 0) then
            SoundStopCurrentSpeechEvent(model)
            skipped = true
        end
        Wait(0)
    end
    if skipped then
        return true
    else
        return false
    end
end

function F_ClassIsAvailable()
    if IsMissionAvailable("C_Wrestling_1") or IsMissionAvailable("C_Wrestling_2") or IsMissionAvailable("C_Wrestling_3") or IsMissionAvailable("C_Wrestling_4") or IsMissionAvailable("C_Wrestling_5") then
        return true
    end
    if IsMissionAvailable("C_Photography_1") or IsMissionAvailable("C_Photography_2") or IsMissionAvailable("C_Photography_3") or IsMissionAvailable("C_Photography_4") or IsMissionAvailable("C_Photography_5") then
        return true
    end
    if IsMissionAvailable("C_Shop_1") or IsMissionAvailable("C_Shop_2") or IsMissionAvailable("C_Shop_3") or IsMissionAvailable("C_Shop_4") or IsMissionAvailable("C_Shop_5") then
        return true
    end
    if IsMissionAvailable("C_English_1") or IsMissionAvailable("C_English_1_unlocked") or IsMissionAvailable("C_English_2") or IsMissionAvailable("C_English_2_unlocked") or IsMissionAvailable("C_English_3") or IsMissionAvailable("C_English_3_unlocked") or IsMissionAvailable("C_English_4") or IsMissionAvailable("C_English_4_unlocked") or IsMissionAvailable("C_English_5") or IsMissionAvailable("C_English_5_unlocked") then
        return true
    end
    if IsMissionAvailable("C_Art_1") or IsMissionAvailable("C_Art_1_repeat") or IsMissionAvailable("C_Art_2") or IsMissionAvailable("C_Art_2_repeat") or IsMissionAvailable("C_Art_3") or IsMissionAvailable("C_Art_3_repeat") or IsMissionAvailable("C_Art_4") or IsMissionAvailable("C_Art_4_repeat") or IsMissionAvailable("C_Art_5") or IsMissionAvailable("C_Art_5_repeat") then
        return true
    end
    if IsMissionAvailable("C_Chem_1") or IsMissionAvailable("C_Chem_1_repeat") or IsMissionAvailable("C_Chem_2") or IsMissionAvailable("C_Chem_2_repeat") or IsMissionAvailable("C_Chem_3") or IsMissionAvailable("C_Chem_3_repeat") or IsMissionAvailable("C_Chem_4") or IsMissionAvailable("C_Chem_4_repeat") or IsMissionAvailable("C_Chem_5") or IsMissionAvailable("C_Chem_5_repeat") then
        return true
    end
    if IsMissionAvailable("C_Biology_1") or IsMissionAvailable("C_Biology_1_repeat") or IsMissionAvailable("C_Biology_2") or IsMissionAvailable("C_Biology_2_repeat") or IsMissionAvailable("C_Biology_3") or IsMissionAvailable("C_Biology_3_repeat") or IsMissionAvailable("C_Biology_4") or IsMissionAvailable("C_Biology_4_repeat") or IsMissionAvailable("C_Biology_5") or IsMissionAvailable("C_Biology_5_repeat") then
        return true
    end
    if IsMissionAvailable("C_Math_1") or IsMissionAvailable("C_Math_1_repeat") or IsMissionAvailable("C_Math_2") or IsMissionAvailable("C_Math_2_repeat") or IsMissionAvailable("C_Math_3") or IsMissionAvailable("C_Math_3_repeat") or IsMissionAvailable("C_Math_4") or IsMissionAvailable("C_Math_4_repeat") or IsMissionAvailable("C_Math_5") or IsMissionAvailable("C_Math_5_repeat") then
        return true
    end
    if IsMissionAvailable("C_Geography_1") or IsMissionAvailable("C_Geography_1_repeat") or IsMissionAvailable("C_Geography_2") or IsMissionAvailable("C_Geography_2_repeat") or IsMissionAvailable("C_Geography_3") or IsMissionAvailable("C_Geography_3_repeat") or IsMissionAvailable("C_Geography_4") or IsMissionAvailable("C_Geography_4_repeat") or IsMissionAvailable("C_Geography_5") or IsMissionAvailable("C_Geography_5_repeat") then
        return true
    end
    if IsMissionAvailable("C_Music_1") or IsMissionAvailable("C_Music_1_repeat") or IsMissionAvailable("C_Music_2") or IsMissionAvailable("C_Music_2_repeat") or IsMissionAvailable("C_Music_3") or IsMissionAvailable("C_Music_3_repeat") or IsMissionAvailable("C_Music_4") or IsMissionAvailable("C_Music_4_repeat") or IsMissionAvailable("C_Music_5") or IsMissionAvailable("C_Music_5_repeat") then
        return true
    end
end

function F_PreDATInit()
    AreaSignalAreaTransitionReadyToLoad()
    Wait(5)
    while AreaIsLoading() do
        Wait(50)
    end
    Wait(5)
end

function F_TableSize(tbl)
    local size = 0
    if tbl then
        for _, e in tbl do
            if e then
                size = size + 1
            end
        end
    end
    return size
end

function F_PedSetDropItem(pedId, pickupModel, dropProbability, dropCount)
    if not F_PedExists(pedId) then
        assert(nil, "F_PedSetDropItem(pedId, pickupModel, dropProbability, dropCount): pedId == INVALID_PED")
    end
    --assert(pickupModel, "F_PedSetDropItem(pedId, pickupModel, dropProbability, dropCount): pickupModel == NIL")
    local percent = dropProbability or 100
    local count = dropCount or 1
    PedOverrideStat(pedId, 0, pickupModel)
    PedOverrideStat(pedId, 1, percent)
end

function F_ProcessWakeUpMissionBasedLogic()
    if shared.PlayerGotCarnieTicket then
        if AreaGetVisible() == 0 then
            if not PlayerIsInTrigger(TRIGGER._ZONECARNIVAL) then
                shared.PlayerGotCarnieTicket = nil
                ItemSetCurrentNum(479, 0)
            end
        else
            shared.PlayerGotCarnieTicket = nil
            ItemSetCurrentNum(479, 0)
        end
    end
    if IsMissionCompleated("1_11x1") and not IsMissionCompleated("1_11_Dummy") then
        if ClothingIsWearingOutfit("Halloween") then
            ClothingSetPlayerOutfit("Uniform")
            ClothingBuildPlayer()
        end
        MissionSuccessCountInc("1_11_Dummy")
        AreaLoadSpecialEntities("Halloween1", false)
        AreaLoadSpecialEntities("Halloween2", false)
        AreaLoadSpecialEntities("Halloween3", false)
        AreaRevertToDefaultPopulation()
        AreaEnsureSpecialEntitiesAreCreated()
        MiniObjectiveSetIsComplete(19)
        shared.gHalloweenActive = false
        shared.gHCriminalsActive = false
        PedSetUniqueModelStatus(159, -1)
        PedSetUniqueModelStatus(161, -1)
        PedSetUniqueModelStatus(162, -1)
        PedSetUniqueModelStatus(163, -1)
        PedSetUniqueModelStatus(164, -1)
        PedSetUniqueModelStatus(166, -1)
        PedSetUniqueModelStatus(167, -1)
        PedSetUniqueModelStatus(168, -1)
        PedSetUniqueModelStatus(169, -1)
        PedSetUniqueModelStatus(170, -1)
        PedSetUniqueModelStatus(171, -1)
        PedSetUniqueModelStatus(173, -1)
        PedSetUniqueModelStatus(174, -1)
        PedSetUniqueModelStatus(69, 1)
        PedSetUniqueModelStatus(26, 1)
        PedSetUniqueModelStatus(11, 1)
        PedSetUniqueModelStatus(40, 1)
        PedSetUniqueModelStatus(17, 1)
        PedSetUniqueModelStatus(39, 1)
        PedSetUniqueModelStatus(38, 1)
        PedSetUniqueModelStatus(12, 1)
        PedSetUniqueModelStatus(139, 1)
        PedSetUniqueModelStatus(102, 1)
        PedSetUniqueModelStatus(73, 1)
        PedSetUniqueModelStatus(27, 1)
        PedSetUniqueModelStatus(7, 1)
        PedSetUniqueModelStatus(66, 1)
        PedSetUniqueModelStatus(68, 1)
        PedSetUniqueModelStatus(74, 1)
        PedSetUniqueModelStatus(71, 1)
        PedSetUniqueModelStatus(70, 1)
        PedSetUniqueModelStatus(137, 1)
        PedSetUniqueModelStatus(138, 1)
        PedSetUniqueModelStatus(139, 1)
        AreaClearAllPeds()
        shared.cm_lockHead = false
        shared.cm_lockTorso = false
        shared.cm_lockLWrist = false
        shared.cm_lockRWrist = false
        shared.cm_lockLegs = false
        shared.cm_lockFeet = false
        shared.cm_lockOutfit = false
        shared.lockClothingManager = false
        SoundStopStream()
        AreaEnableAllPatrolPaths()
        CameraReturnToPlayer()
    end
    if IsMissionCompleated("3_08") and not IsMissionCompleated("3_08_PostDummy") then
        --print("Removing Christmas stuff!")
        MissionForceCompleted("3_08_PostDummy")
        MissionSuccessCountInc("3_08_PostDummy")
        AreaLoadSpecialEntities("Christmas", false)
        AreaEnsureSpecialEntitiesAreCreated()
        CameraReturnToPlayer()
    end
    if shared.gPetey and PedIsValid(shared.gPetey) then
        PedDelete(shared.gPetey)
        shared.gPetey = nil
    end
    if shared.gGary and PedIsValid(shared.gGary) then
        PedDelete(shared.gGary)
        shared.gGary = nil
    end
    shared.bCleanUpErrand = true
    if IsMissionCompleated("5_02") and not IsMissionCompleated("6_01") then
        CreateThread("T_ExpelledLogic")
        ForceStartMission("6_01_Launch")
        CameraReturnToPlayer(true)
    end
    if IsMissionCompleated("Chapt2Trans") and not IsMissionCompleated("3_08") then
        ForceStartMission("3_08_Launch")
        CreateThread("T_ChristmasdLogic")
        CameraReturnToPlayer(true)
    end
end

function F_PlayerSleptInBed()
    shared.gPlayerSlept = true
end

function F_AlarmSound()
    local Area = AreaGetVisible()
    if Area == 14 then
        SoundPlay3DIgnoreFade(-493.3519, 315.53796, 32.145157, "Alarm Clock", "large")
    elseif Area == 30 then
        SoundPlay3DIgnoreFade(-738.806, 38.3087, -1.3985, "Alarm Clock", "large")
    elseif Area == 59 then
        SoundPlay3DIgnoreFade(-743.409, 355.714, 4.09885, "Alarm Clock", "large")
    elseif Area == 60 then
        SoundPlay3DIgnoreFade(-765.543, 358.094, 7.2061, "Alarm Clock", "large")
    elseif Area == 57 then
        SoundPlay3DIgnoreFade(-654.122, 250.885, 15.9965, "Alarm Clock", "large")
    elseif Area == 61 then
        SoundPlay3DIgnoreFade(-699.269, 341.508, 4.02137, "Alarm Clock", "large")
    end
end

function F_PlayerHasSleptInBed()
    local ClockHour, ClockMinute
    local PlayAlarm = false
    ClockFlag = false
    SoundStopFireAlarm()
    PlayerResetPhysicalState()
    if PlayerGetScriptSavedData(26) == 0 then
        PlayerSetScriptSavedData(26, 1)
    end
    AreaClearAllPeds()
    shared.gBDormFAlarmOn = false
    ClockHour, ClockMinute = ClockGet()
    ClockSet(8, 1)
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PlayerSetHealth(PedGetMaxHealth(gPlayer))
    end
    PlayerSetPunishmentPoints(0)
    PlayerSetControl(1)
    F_ProcessWakeUpMissionBasedLogic()
end

function F_MakePlayerSafeForNIS(bOn, bWeapon, bAllowAmbientSpeech, bPreserveAmbientPopulation)
    local turnOn = bOn
    if turnOn == nil then
        turnOn = true
    end
    local bKeepWeapon = bWeapon
    if bKeepWeapon == nil then
        bKeepWeapon = true
    end
    if bPreserveAmbientPopulation == nil then
        bPreserveAmbientPopulation = true
    end
    if turnOn then
        EnterNIS()
        if not bAllowAmbientSpeech then
            SoundDisableSpeech_ActionTree()
            SoundStopCurrentSpeechEvent()
        end
        if bKeepWeapon then
            shared.gWeaponBeforeCut = PedGetWeapon(gPlayer)
            shared.gAmmoBeforeCut = PedGetAmmoCount(gPlayer, shared.gWeaponBeforeCut)
        end
        PedSetWeaponNow(gPlayer, -1, 0)
        AreaClearAllExplosions()
        AreaClearAllProjectiles()
        PedSetFlag(gPlayer, 108, true)
        PedSetFlag(gPlayer, 117, false)
        PedSetFlag(gPlayer, 2, false)
        if CameraGetActive() ~= 4 then
            if CameraGetActive() == 2 then
                CameraSetActive(13, 0.5, false)
            else
                CameraSetActive(1, 0.5, false)
            end
        end
        DisablePunishmentSystem(true)
        StopAmbientPedAttacks()
        SetAmbientPedsIgnoreStimuli(true)
        PedStop(gPlayer)
        PedSetInvulnerable(gPlayer, true)
        if not bPreserveAmbientPopulation then
            AreaClearAllPeds()
            StopPedProduction(true)
            shared.bClearedPopulationBeforeCut = true
        else
            shared.bClearedPopulationBeforeCut = false
        end
        --print(">>>[RUI]", "++F_MakePlayerSafeForNIS")
    else
        if shared.bClearedPopulationBeforeCut ~= nil and shared.bClearedPopulationBeforeCut then
            StopPedProduction(false)
            shared.bClearedPopulationBeforeCut = nil
        end
        if not bAllowAmbientSpeech then
            SoundEnableSpeech_ActionTree()
        end
        if bKeepWeapon and not WeaponEquipped() and F_ObjectIsValid(shared.gWeaponBeforeCut) and shared.gWeaponBeforeCut ~= 437 and shared.gWeaponBeforeCut ~= 363 and (not ClothingIsWearingOutfit("Mascot") or ClothingIsWearingOutfit("Mascot") and not bHadProjectileWeapon) then
            shared.gAmmoBeforeCut = PedGetAmmoCount(gPlayer, shared.gWeaponBeforeCut)
            PlayerSetWeapon(shared.gWeaponBeforeCut, shared.gAmmoBeforeCut, false)
            shared.gWeaponBeforeCut = nil
            shared.gAmmoBeforeCut = 0
        end
        DisablePunishmentSystem(false)
        PedSetInvulnerable(gPlayer, false)
        SetAmbientPedsIgnoreStimuli(false)
        PedMakeTargetable(gPlayer, true)
        PedSetFlag(gPlayer, 108, false)
        PedSetFlag(gPlayer, 117, true)
        bHadProjectileWeapon = shared.gWeaponBeforeCut == 303 or shared.gWeaponBeforeCut == 306 or shared.gWeaponBeforeCut == 305 or shared.gWeaponBeforeCut == 307
        ExitNIS()
        --print(">>>[RUI]", "--F_MakePlayerSafeForNIS")
    end
    if CameraGetActive() ~= 4 and CameraGetActive() ~= 1 then
        CameraSetActive(1, 0.5, false)
    end
end

function F_ObjectIsValid(thing)
    return thing ~= nil and thing ~= -1
end

function F_PlayerExitBike(bDetach)
    F_PlayerDismountBike()
end

function F_RingSchoolBell()
    --DebugPrint("F_RingSchoolBell")
    local current_area = AreaGetVisible()
    if current_area == 2 or current_area == 14 then
        SoundPlay2D("School Bell 2D")
    else
        SoundPlay2D("Half Bell 2D")
    end
    --DebugPrint("F_RingSchoolBell eof")
end

function F_LoadSprayCans(forceLoad)
    --print("EXECUTING?")
    if IsMissionCompleated("3_S10") or forceLoad then
        --print("LOAD THE SPRAY CANS!")
        DATLoad("world_spray_cans.DAT", 1)
        DATInit()
    end
end

function F_PedSetCameraOffsetXYZ(pedId, x1, y1, z1, x2, y2, z2, pedId2)
    if pedId ~= nil and PedIsValid(pedId) then
        --print("LSDKFMSDFMK!!!")
        x1, y1, z1 = PedGetOffsetInWorldCoords(pedId, x1, y1, z1)
        if pedId2 == nil then
            --print("NO SECOND PED!")
            x2, y2, z2 = PedGetOffsetInWorldCoords(pedId, x2, y2, z2)
        else
            --print("SECOND PED!")
            x2, y2, z2 = PedGetOffsetInWorldCoords(pedId2, x2, y2, z2)
        end
        CameraSetXYZ(x1, y1, z1, x2, y2, z2)
    end
end

function F_MagicalJasonsByRobertoTransition(visibleArea, pointlist, num, disableCameraControl)
    AreaForceLoadAreaByAreaTransition(true)
    if disableCameraControl then
        AreaDisableCameraControlForTransition(true)
    end
    PedSetEffectedByGravity(gPlayer, false)
    SoundDisableSpeech()
    SoundPause()
    local x, y, z
    if num ~= nil then
        x, y, z = GetPointFromPointList(pointlist, num)
    else
        x, y, z = GetPointList(pointlist)
    end
    PlayerSetPosXYZArea(x, y, z, visibleArea)
    Wait(5)
    local count = 0
    while AreaIsLoading() and IsStreamingBusy() do
        if count == 0 then
        end
        count = count + 1
        Wait(0)
    end
    if disableCameraControl then
        AreaDisableCameraControlForTransition(false)
    end
    AreaForceLoadAreaByAreaTransition(false)
    Wait(100)
    PedSetEffectedByGravity(gPlayer, true)
    SoundEnableSpeech()
    SoundContinue()
end

function F_PlayerDismountBike()
    if PlayerIsInAnyVehicle() then
        PedSetTaskNode(gPlayer, "/Global/PlayerAI/Objectives/ComeToStopInVehicle/Brake", "Act/PlayerAI.act")
        Wait(1400)
        PedSetTaskNode(gPlayer, "/Global/PlayerAI", "Act/PlayerAI.act")
        PlayerDismountBike()
    end
    if PlayerIsInAnyVehicle() then
        Wait(1000)
    end
    if PlayerIsInAnyVehicle() then
        Wait(1000)
    end
    if PlayerIsInAnyVehicle() then
        Wait(1000)
    end
    if PlayerIsInAnyVehicle() then
        Wait(1000)
    end
    if PlayerIsInAnyVehicle() then
        Wait(1000)
    end
    if PlayerIsInAnyVehicle() then
        PlayerDetachFromVehicle()
    end
end

function F_PlayerSleptOnErrand()
    if shared.bCleanUpErrand or PlayerFellAsleep() then
        return true
    end
    return false
end

function T_ExpelledLogic()
    local nTimerStarted = GetTimer()
    local gCurrentArea = AreaGetVisible()
    local exphour, expminute = ClockGet()
    Wait(2000)
    gCurrentArea = AreaGetVisible()
    if gCurrentArea == 0 and PlayerIsInTrigger(TRIGGER._AMB_SCHOOL_AREA) or gCurrentArea == 9 or gCurrentArea == 2 or gCurrentArea == 14 or gCurrentArea == 35 or gCurrentArea == 13 then
        SoundPlayScriptedSpeechEvent_2D("PA_JIMMY_OFFICE_STRONG", 0)
        Wait(3000)
    end
    while not MissionActiveSpecific("6_01") do
        exphour, expminute = ClockGet()
        if 8 <= exphour and exphour < 19 and not MissionActive() and GetTimer() - nTimerStarted > 240000 then
            gCurrentArea = AreaGetVisible()
            if gCurrentArea == 0 and PlayerIsInTrigger(TRIGGER._AMB_SCHOOL_AREA) or gCurrentArea == 9 or gCurrentArea == 2 or gCurrentArea == 14 or gCurrentArea == 35 or gCurrentArea == 13 then
                SoundPlayScriptedSpeechEvent_2D("PA_JIMMY_OFFICE_STRONG", 0)
            end
            nTimerStarted = GetTimer()
        end
        Wait(1000)
    end
    collectgarbage()
end

function T_ChristmasdLogic()
    local nTimerStarted = GetTimer()
    local gCurrentArea = AreaGetVisible()
    Wait(2000)
    gCurrentArea = AreaGetVisible()
    if gCurrentArea == 0 and PlayerIsInTrigger(TRIGGER._AMB_SCHOOL_AREA) or gCurrentArea == 9 or gCurrentArea == 2 or gCurrentArea == 14 or gCurrentArea == 35 or gCurrentArea == 13 then
        SoundPlayScriptedSpeechEvent_2D("PA_CHRISTMAS_JIMMY", 0)
        Wait(3000)
    end
    PauseGameClock()
    TextPrint("GOTO_PRINCIPAL", 5, 1)
    while not MissionActiveSpecific("3_08") do
        if not MissionActive() and GetTimer() - nTimerStarted > 120000 then
            gCurrentArea = AreaGetVisible()
            if gCurrentArea == 0 and PlayerIsInTrigger(TRIGGER._AMB_SCHOOL_AREA) or gCurrentArea == 9 or gCurrentArea == 2 or gCurrentArea == 14 or gCurrentArea == 35 or gCurrentArea == 13 then
                SoundPlayScriptedSpeechEvent_2D("PA_CHRISTMAS_JIMMY", 0)
            end
            nTimerStarted = GetTimer()
            TextPrint("GOTO_PRINCIPAL", 5, 1)
        end
        Wait(1000)
    end
    collectgarbage()
end

function F_SetupHallowenPeds(bTurnOnPedro)
    PedSetUniqueModelStatus(161, 2)
    PedSetUniqueModelStatus(162, 2)
    PedSetUniqueModelStatus(163, 1)
    PedSetUniqueModelStatus(164, 2)
    PedSetUniqueModelStatus(166, 1)
    PedSetUniqueModelStatus(167, 1)
    PedSetUniqueModelStatus(168, 2)
    PedSetUniqueModelStatus(169, 3)
    PedSetUniqueModelStatus(170, 2)
    PedSetUniqueModelStatus(171, 3)
    PedSetUniqueModelStatus(173, 2)
    PedSetUniqueModelStatus(174, 1)
    if bTurnOnPedro then
        PedSetUniqueModelStatus(159, 2)
    end
    PedSetUniqueModelStatus(69, -1)
    PedSetUniqueModelStatus(26, -1)
    PedSetUniqueModelStatus(11, -1)
    PedSetUniqueModelStatus(40, -1)
    PedSetUniqueModelStatus(17, -1)
    PedSetUniqueModelStatus(39, -1)
    PedSetUniqueModelStatus(38, -1)
    PedSetUniqueModelStatus(12, -1)
    PedSetUniqueModelStatus(139, -1)
    PedSetUniqueModelStatus(102, -1)
    PedSetUniqueModelStatus(73, -1)
    PedSetUniqueModelStatus(27, -1)
    PedSetUniqueModelStatus(7, -1)
    PedSetUniqueModelStatus(66, -1)
    PedSetUniqueModelStatus(68, -1)
    PedSetUniqueModelStatus(74, -1)
    PedSetUniqueModelStatus(71, -1)
    PedSetUniqueModelStatus(70, -1)
    PedSetUniqueModelStatus(137, -1)
    PedSetUniqueModelStatus(138, -1)
end

function F_ToggleArcadeScreens()
    local turnOn = shared.ArcadeMachinesOn
    local area = AreaGetVisible()
    if area == 30 then
        GeometryInstance("CS_ArcadeScrn", not turnOn, -721.868, 39.2926, -0.825597, false)
        GeometryInstance("CS_ArcadeGlow", not turnOn, -721.693, 39.2926, -1.21955, false)
    elseif area == 57 then
        GeometryInstance("DRP_ArcadeScr", not turnOn, -659.387, 243.841, 16.7133, false)
        GeometryInstance("DRP_ArcadeGlow", not turnOn, -659.387, 243.787, 16.4363, false)
    elseif area == 61 then
        GeometryInstance("GRS_Arcade_Scr", not turnOn, -694.223, 341.423, 4.56144, false)
        GeometryInstance("GSR_ArcadeGlow", not turnOn, -694.345, 341.545, 4.93039, false)
    elseif area == 60 then
        GeometryInstance("PS_ArcadeA_Scr", not turnOn, -781.537, 354.188, 7.44108, false)
        GeometryInstance("PS_ArcadeGlow", not turnOn, -781.536, 354.796, 7.35616, false)
    elseif area == 14 then
        GeometryInstance("BDrm_ArcadeAni", not turnOn, -509.239, 323.887, 32.9029, false)
        GeometryInstance("BDrm_ArcadeGlow", not turnOn, -509.293, 323.887, 32.6258, false)
    elseif area == 50 then
        GeometryInstance("ISouv_ArcadeGlow", not turnOn, -786.66, 52.7469, 8.43253, false)
        GeometryInstance("ISouv_ArcScreen2D", not turnOn, -786.033, 52.8742, 8.71017, false)
        GeometryInstance("ISouv_ArcScreen3D", not turnOn, -787.005, 55.4691, 8.33098, false)
        GeometryInstance("ISouv_ArcScreenMon", not turnOn, -785.957, 49.6202, 8.48886, false)
        GeometryInstance("ISouv_ArcScreenNut", not turnOn, -785.876, 50.7278, 8.44285, false)
        GeometryInstance("ISouv_ArcScreenSumo", not turnOn, -786.221, 51.7785, 8.73701, false)
    end
end

function F_UnlockYearbookReward()
    if YearbookIsFull() and not MiniObjectiveGetIsComplete(14) then
        MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_YEARBK_REWARD")
        MinigameSetUberCompletion()
        ClothingGivePlayerOutfit("Ninja_BLK")
        MiniObjectiveSetIsComplete(14)
        PlayerAddMoney(30000, false)
    end
end
