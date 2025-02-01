--[[ Changes to this file:
    * Removed unused local variables
    * Removed function RandomTablePick, not present in original script
    * Removed function F_ExplainSoundError, not present in original script
    * Modified function SoundPlayScriptedSpeechEventWrapper, may require testing
    * Modified function UpdateTextQueue, may require testing
    * Removed function PriorityQueueText, not present in original script
    * Removed function DumpTextQueue, not present in original script
    * Removed function ResetTextQueueTimer, not present in original script
    * Modified function ExecuteActionNode, may require testing
    * Modified function AreaTransitionPoint, may require testing
    * Removed function F_CameraTweak, not present in original script
    * Modified function F_ProcessWakeUpMissionBasedLogic, may require testing
    * Removed function ModelReport, not present in original script
    * Removed function ReturnModelNameForNumber, not present in original script
    * Modified function F_UnlockYearbookReward, may require testing
    * Removed function F_CleanBlip, not present in original script
    * Removed function TagsBlip, not present in original script
    * Removed function TagsBlipSchoolHalls, not present in original script
    * Removed function TagsBlipSchoolGrounds, not present in original script
    * Removed function TagsBlipRichArea, not present in original script
    * Removed function TagsBlipPoorArea, not present in original script
    * Removed function TagsBlipIdustrialArea, not present in original script
    * Removed function TagsBlipDowntown, not present in original script
]]

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

--[[
function RandomTablePick(arg_table)
    local random_index = RandomIndex(arg_table)
    if random_index then
        local ret_val = arg_table[random_index]
        table.remove(arg_table, random_index)
        return ret_val
    end
    return {}
end
]] -- Not present in original script

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

--[[
local soundSpeechErrCodes = {
    "kSPCH_ItemNotFoundInQueue",
    "kSPCH_NoMatchFound",
    "kSPCH_CantAddItem",
    "kSPCH_EmptyEventPackage",
    "kSPCH_NoRandInstalled",
    "kSPCH_NoTimerInstalled",
    "kSPCH_NoStreamerInstalled",
    "kSPCH_TooManySpeechItems",
    "kSPCH_NoneFoundAfterMaxAttempts",
    "kSPCH_SpeechLibDisabledError",
    "kNoStopProcInstalledErr",
    "kNoBusyProcInstalledErr",
    "kMessageActivelyFilteredErr",
    "kSPCH_BadEventNumber",
    "kSPCH_NoSpeechHandlerInstalled"
}

function F_ExplainSoundError(err)
    if err < 0 and -15 <= err then
        print("**SoundPlayScriptedSpeechEvent error: " .. soundSpeechErrCodes[err * -1])
    else
        print("error " .. err .. " out of range!")
    end
end
]] -- Not present in original script

local sound_retval

function SoundPlayScriptedSpeechEventWrapper(id, bank, speechid, voltable) -- ! Modified
    --DebugPrint("SoundPlayScriptedSpeechEventWrapper() ped: " .. id .. " bank: " .. bank .. " speechid: " .. speechid .. " voltable: " .. tostring(voltable))
    --DebugPrint("Time is now: " .. GetTimer())
    if voltable ~= nil then
        soundret = SoundPlayScriptedSpeechEvent(id, bank, speechid, voltable)
    else
        soundret = SoundPlayScriptedSpeechEvent(id, bank, speechid)
    end
    if soundret < 0 then
        --DebugPrint("SoundPlayScriptedSpeechEvent had error: " .. soundret)
        --[[
        F_ExplainSoundError(soundret)
        ]] -- Removed this
    end
end

function UpdateTextQueue() -- ! Modified
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
                        --[[
                        F_ExplainSoundError(sound_retval)
                        ]] -- Removed this
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

--[[
function PriorityQueueText(text, textTime, style, printString)
    table.insert(gTextTable, 1, {
        mText = text,
        mTime = textTime,
        mStyle = style,
        mType = printString
    })
end

function DumpTextQueue()
    DebugPrint("                  DumpTextQueue()")
    for i, entry in gTextTable do
        if entry.mSpeechPed then
            DebugPrint("i: " .. i .. " mSpeechPed: " .. tostring(entry.mSpeechPed) .. " mSpeechEvent: " .. tostring(entry.mSpeechEvent) .. " mParam: " .. tostring(entry.mParam))
        elseif entry.mText then
            DebugPrint("i: " .. i .. " mText: " .. tostring(entry.mText) .. " mTime: " .. tostring(entry.mTime) .. " mStyle: " .. tostring(entry.mStyle))
        else
            DebugPrint("i: " .. i .. " !!! neither speech nor text!")
        end
    end
end

function ResetTextQueueTimer()
    gPreviousTextClock = 0
    gPreviousTextTimer = 0
end
]]                                                    -- Not present in original script

function ExecuteActionNode(ped, actionNode, fileName) -- ! Modified
    if string.find(actionNode, "Global") == nil then
        --print("============>>>> YOU HAVE NOT SPECIFIED A PROPER PATH FOR THE NODE!!!!")
        --print("============>>>> NODE PASSED IN: ", actionNode)
        --print("============>>>> FILE NAME REFERRENCED: ", fileName)
        do return end
        --[[
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
        ]] -- Moved this outide the if
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

function AreaTransitionPoint(idArea, idPoint, numPoint, disableCameraControl) -- ! Modified
    --[[
    if SystemIsReady() then
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
    ]] -- Removed first if, all code is outside the if structure
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

--[[
function F_CameraTweak(pedId, entityType)
    local tx, ty, tz = PlayerGetPosXYZ()
    local r = 2
    local x = tx + r
    local y = ty
    local z = tz + 1.5
    local th = 0
    local dth = 2
    local currentSpeed = 1
    local speeds = {
        0.1,
        0.5,
        1
    }
    local speedId = {
        "Slow",
        "Medium",
        "Fast"
    }
    PlayerSetControl(0)
    local effectId = -1
    local effectId2 = -1
    local playerLookAt = true
    local entityId = pedId or gPlayer
    local eType = entityType or 3
    local playerOffset = 0
    while true do
        if 0 < GetStickValue(17, 0) then
            r = r - speeds[currentSpeed] * GetStickValue(17, 0)
            if r < 0 then
                r = 0
            end
            moved = true
        end
        if 0 > GetStickValue(17, 0) then
            r = r - speeds[currentSpeed] * GetStickValue(17, 0)
            moved = true
        end
        if 0 > GetStickValue(16, 0) then
            th = th + speeds[currentSpeed] * GetStickValue(16, 0)
            if 359 < th then
                th = th - 360
            end
            moved = true
        end
        if 0 < GetStickValue(16, 0) then
            th = th + speeds[currentSpeed] * GetStickValue(16, 0)
            if th < 0 then
                th = 360 + th
            end
            moved = true
        end
        if IsButtonPressed(1, 0) then
            th = th + 0.1
            if 359 < th then
                th = th - 360
            end
            moved = true
        end
        if IsButtonPressed(0, 0) then
            th = th - 0.1
            if th < 0 then
                th = 360 + th
            end
            moved = true
        end
        if 0.5 < GetStickValue(18, 0) then
            tx = tx + speeds[currentSpeed] * GetStickValue(18, 0)
        end
        if 0.5 < GetStickValue(19, 0) then
            ty = ty + speeds[currentSpeed] * GetStickValue(19, 0)
        end
        if 0.5 > GetStickValue(18, 0) then
            tx = tx + speeds[currentSpeed] * GetStickValue(18, 0)
        end
        if 0.5 > GetStickValue(19, 0) then
            ty = ty + speeds[currentSpeed] * GetStickValue(19, 0)
        end
        if IsButtonPressed(6, 0) then
            playerLookAt = not playerLookAt
            if playerLookAt then
                TextPrintString("Looking at Player", 3, 2)
                EffectKill(effectId)
                EffectKill(effectId2)
                effectId = -1
            else
                TextPrintString("Looking at Coords", 3, 2)
                effectId = EffectCreate("BottleRocketFuse", tx, ty, tz)
                effectId2 = EffectCreate("Blowtorch_SM", tx, ty, tz)
            end
            Wait(200)
        end
        if IsButtonPressed(10, 0) then
            z = z + speeds[currentSpeed] / 5
        end
        if IsButtonPressed(11, 0) then
            z = z - speeds[currentSpeed] / 5
        end
        if IsButtonPressed(12, 0) then
            if playerLookAt then
                playerOffset = playerOffset + speeds[currentSpeed] / 5
            else
                tz = tz + speeds[currentSpeed] / 5
            end
        end
        if IsButtonPressed(13, 0) then
            if playerLookAt then
                playerOffset = playerOffset - speeds[currentSpeed] / 5
            else
                tz = tz - speeds[currentSpeed] / 5
            end
        end
        if IsButtonPressed(7, 0) then
            TextPrintString("Printing Coords", 3, 2)
            if playerLookAt then
                if entityId == gPlayer then
                    print("COMMAND: CameraLookAtPlayer( true, " .. playerOffset .. " )")
                end
                print("COORDS x,y,z ", x, y, z, "Player Offset ", playerOffset)
            else
                print("COMMAND: CameraLookAtXYZ( " .. tx .. ", " .. ty .. ", " .. tz .. ", true )")
                print("COMMAND: CameraSetXYZ(" .. x .. ", " .. y .. ", " .. z .. ", " .. tx .. ", " .. ty .. ", " .. tz .. ")")
            end
            Wait(200)
        end
        if IsButtonPressed(9, 0) then
            currentSpeed = currentSpeed + 1
            if currentSpeed > table.getn(speeds) then
                currentSpeed = 1
            end
            TextPrintString("Speed: " .. speedId[currentSpeed], 3, 2)
            Wait(200)
        end
        if IsButtonPressed(4, 0) then
            local gWaiting = true
            local gInstructions = false
            while gWaiting do
                TextPrintString("Press ~x~ for instructions, ~o~ to continue", 1, 1)
                if IsButtonPressed(7, 0) then
                    gInstructions = true
                    gWaiting = false
                elseif IsButtonPressed(8, 0) then
                    gWaiting = false
                end
                Wait(0)
            end
            TextPrintString("", 1, 1)
            Wait(200)
            if gInstructions then
                TextPrintString("~s~ to switch between looking at the ped or looking at a coordinate", 5, 1)
                WaitSkippable(5000)
                TextPrintString("~t~ toggle movement speeds, ~x~ print camera command to the console", 5, 1)
                WaitSkippable(5000)
                TextPrintString("~o~ exit the tool without resetting camera, -start- to exit resetting the camera", 5, 1)
                WaitSkippable(5000)
                TextPrintString("left analog stick to move camera on x and y axis, L1/L2 for z axis", 5, 1)
                WaitSkippable(5000)
                TextPrintString("Right analog stick to move the coord target in 'coord mode'", 5, 1)
                WaitSkippable(5000)
                TextPrintString("R1/R2 z axis for 'coord mode', z offset for 'ped mode' ", 5, 1)
                WaitSkippable(5000)
            end
            Wait(200)
        end
        if IsButtonPressed(5, 0) then
            break
        end
        if IsButtonPressed(8, 0) then
            CameraReturnToPlayer()
            CameraReset()
            break
        end
        if playerLookAt then
            tx, ty, tz = PlayerGetPosXYZ()
        end
        if moved then
            dx = math.cos(th) * r
            dy = math.sin(th) * r
            x = tx + dx
            y = ty + dy
            moved = false
        end
        CameraLookAtXYZ(tx, ty, tz, true)
        CameraSetXYZ(x, y, z, tx, ty, tz)
        if playerLookAt then
            CameraLookAtObject(entityId, eType, true, playerOffset)
        else
            EffectSetPosition(effectId, tx, ty, tz)
            EffectSetPosition(effectId2, tx, ty, tz)
        end
        Wait(0)
    end
    if effectId ~= -1 then
        EffectKill(effectId)
        EffectKill(effectId2)
    end
    PlayerSetControl(1)
    Wait(500)
end
]] -- Not present in original script

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

function F_ProcessWakeUpMissionBasedLogic() -- ! Modified
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
        --[[
        MiniObjectiveSetIsComplete(18)
        ]] -- Modified to:
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

--[[
local allModels = {
    {
        model = MODELENUM._2HANDSTICK,
        name = "MODELENUM_2HANDSTICK"
    },
    {
        model = 294,
        name = "MODELENUM_70WAGON"
    },
    {
        model = 566,
        name = "MODELENUM_AMMO_BROCKETS"
    },
    {
        model = 567,
        name = "MODELENUM_AMMO_CHERRYB"
    },
    {
        model = 568,
        name = "MODELENUM_AMMO_EGGCARTON"
    },
    {
        model = 569,
        name = "MODELENUM_AMMO_POTATOCAN"
    },
    {
        model = 570,
        name = "MODELENUM_AMMO_STINKBOMB"
    },
    {
        model = 469,
        name = "MODELENUM_ANGELBAND"
    },
    {
        model = 381,
        name = "MODELENUM_ANIBBALL"
    },
    {
        model = 378,
        name = "MODELENUM_ANIFOOTY"
    },
    {
        model = 310,
        name = "MODELENUM_APPLE"
    },
    {
        model = 298,
        name = "MODELENUM_ARC_1"
    },
    {
        model = 287,
        name = "MODELENUM_ARC_2"
    },
    {
        model = 285,
        name = "MODELENUM_ARC_3"
    },
    {
        model = 349,
        name = "MODELENUM_BAGMRBLS"
    },
    {
        model = 279,
        name = "MODELENUM_BANBIKE"
    },
    {
        model = 380,
        name = "MODELENUM_BARREL"
    },
    {
        model = 302,
        name = "MODELENUM_BASEBALL"
    },
    {
        model = 300,
        name = "MODELENUM_BAT"
    },
    {
        model = 327,
        name = "MODELENUM_BBAGBOTTLE"
    },
    {
        model = 391,
        name = "MODELENUM_BBGUN"
    },
    {
        model = 483,
        name = "MODELENUM_BEA_DIARY"
    },
    {
        model = 468,
        name = "MODELENUM_BEADBRAC"
    },
    {
        model = 473,
        name = "MODELENUM_BIGWATCH"
    },
    {
        model = 277,
        name = "MODELENUM_BIKE"
    },
    {
        model = 275,
        name = "MODELENUM_BIKECOP"
    },
    {
        model = 386,
        name = "MODELENUM_BOXCARD01"
    },
    {
        model = 311,
        name = "MODELENUM_BRICK"
    },
    {
        model = 308,
        name = "MODELENUM_BROCKET"
    },
    {
        model = 307,
        name = "MODELENUM_BROCKETLAUNCHER"
    },
    {
        model = 467,
        name = "MODELENUM_CANAHAT"
    },
    {
        model = 293,
        name = "MODELENUM_CARGREEN"
    },
    {
        model = 382,
        name = "MODELENUM_CEMENT"
    },
    {
        model = 497,
        name = "MODELENUM_CHARSHEET"
    },
    {
        model = 351,
        name = "MODELENUM_CHEM_STIR"
    },
    {
        model = 337,
        name = "MODELENUM_CHEMICAL"
    },
    {
        model = 301,
        name = "MODELENUM_CHERRYB"
    },
    {
        model = 371,
        name = "MODELENUM_CHKNLEG"
    },
    {
        model = 478,
        name = "MODELENUM_CHOCBOX"
    },
    {
        model = 387,
        name = "MODELENUM_CHSHIELDA"
    },
    {
        model = 388,
        name = "MODELENUM_CHSHIELDB"
    },
    {
        model = 389,
        name = "MODELENUM_CHSHIELDC"
    },
    {
        model = 339,
        name = "MODELENUM_CIGARETTE"
    },
    {
        model = 472,
        name = "MODELENUM_CLOWNWIG"
    },
    {
        model = 464,
        name = "MODELENUM_CLWNPANT"
    },
    {
        model = 465,
        name = "MODELENUM_CLWNSHOE"
    },
    {
        model = 462,
        name = "MODELENUM_COIN_DOLLAR"
    },
    {
        model = 463,
        name = "MODELENUM_COIN_PENNY"
    },
    {
        model = 481,
        name = "MODELENUM_COLLECTA"
    },
    {
        model = 504,
        name = "MODELENUM_COMICBK"
    },
    {
        model = 357,
        name = "MODELENUM_CRICKET"
    },
    {
        model = 514,
        name = "MODELENUM_CRNPOSTERA"
    },
    {
        model = 506,
        name = "MODELENUM_CRNPOSTERB"
    },
    {
        model = 278,
        name = "MODELENUM_CUSTOMBIKE"
    },
    {
        model = 355,
        name = "MODELENUM_DEC_PLATE"
    },
    {
        model = 1,
        name = "MODELENUM_DEFAULTPED"
    },
    {
        model = 470,
        name = "MODELENUM_DEVILHORN"
    },
    {
        model = 291,
        name = "MODELENUM_DLVTRUCK"
    },
    {
        model = 47,
        name = "MODELENUM_DO2ND_OMAR"
    },
    {
        model = 154,
        name = "MODELENUM_DO_HENRY_ASSYLUM"
    },
    {
        model = 153,
        name = "MODELENUM_DO_LEON_ASSYLUM"
    },
    {
        model = 150,
        name = "MODELENUM_DO_OTTO_ASYLUM"
    },
    {
        model = 318,
        name = "MODELENUM_DODGEBALL"
    },
    {
        model = 141,
        name = "MODELENUM_DOG_PITBULL"
    },
    {
        model = 48,
        name = "MODELENUM_DOGIRL_ZOE"
    },
    {
        model = MODELENUM._DOGIRL_ZOEUW,
        name = "MODELENUM_DOGIRL_ZOEUW"
    },
    {
        model = 44,
        name = "MODELENUM_DOH1_DUNCAN"
    },
    {
        model = 42,
        name = "MODELENUM_DOH1A_OTTO"
    },
    {
        model = 41,
        name = "MODELENUM_DOH2_JERRY"
    },
    {
        model = 43,
        name = "MODELENUM_DOH2A_LEON"
    },
    {
        model = 45,
        name = "MODELENUM_DOH3_HENRY"
    },
    {
        model = 46,
        name = "MODELENUM_DOH3A_GURNEY"
    },
    {
        model = 91,
        name = "MODELENUM_DOLEAD_EDGAR"
    },
    {
        model = 75,
        name = "MODELENUM_DOLEAD_RUSSELL"
    },
    {
        model = 505,
        name = "MODELENUM_DOSSIER"
    },
    {
        model = 288,
        name = "MODELENUM_DOZER"
    },
    {
        model = 501,
        name = "MODELENUM_DRUGBAG"
    },
    {
        model = 312,
        name = "MODELENUM_EGGPROJ"
    },
    {
        model = 352,
        name = "MODELENUM_EYEDROP"
    },
    {
        model = 326,
        name = "MODELENUM_FIREEXTING"
    },
    {
        model = 350,
        name = "MODELENUM_FLASK"
    },
    {
        model = 359,
        name = "MODELENUM_FLOWERBUND"
    },
    {
        model = 475,
        name = "MODELENUM_FLOWERGIFT"
    },
    {
        model = 362,
        name = "MODELENUM_FRAFFYCAN"
    },
    {
        model = 343,
        name = "MODELENUM_GARBPICK"
    },
    {
        model = 474,
        name = "MODELENUM_GEEKCARD"
    },
    {
        model = 121,
        name = "MODELENUM_GENERICWRESTLER"
    },
    {
        model = 482,
        name = "MODELENUM_GIFTA"
    },
    {
        model = 39,
        name = "MODELENUM_GN_ASIANGIRL"
    },
    {
        model = 166,
        name = "MODELENUM_GN_ASIANGIRL_WEEN"
    },
    {
        model = 72,
        name = "MODELENUM_GN_BOY01"
    },
    {
        model = 73,
        name = "MODELENUM_GN_BOY02"
    },
    {
        model = 171,
        name = "MODELENUM_GN_BOY02_WEEN"
    },
    {
        model = 102,
        name = "MODELENUM_GN_BULLY01"
    },
    {
        model = 170,
        name = "MODELENUM_GN_BULLY01_WEEN"
    },
    {
        model = 99,
        name = "MODELENUM_GN_BULLY02"
    },
    {
        model = 85,
        name = "MODELENUM_GN_BULLY03"
    },
    {
        model = 145,
        name = "MODELENUM_GN_BULLY04"
    },
    {
        model = 146,
        name = "MODELENUM_GN_BULLY05"
    },
    {
        model = 147,
        name = "MODELENUM_GN_BULLY06"
    },
    {
        model = 71,
        name = "MODELENUM_GN_FATBOY"
    },
    {
        model = 74,
        name = "MODELENUM_GN_FATGIRL"
    },
    {
        model = 70,
        name = "MODELENUM_GN_GREEKBOY"
    },
    {
        model = 159,
        name = "MODELENUM_GN_HBOY_WEEN"
    },
    {
        model = 69,
        name = "MODELENUM_GN_HISPANICBOY"
    },
    {
        model = 66,
        name = "MODELENUM_GN_LITTLEBLKBOY"
    },
    {
        model = 68,
        name = "MODELENUM_GN_LITTLEBLKGIRL"
    },
    {
        model = 137,
        name = "MODELENUM_GN_LITTLEGIRL_2"
    },
    {
        model = 138,
        name = "MODELENUM_GN_LITTLEGIRL_3"
    },
    {
        model = 67,
        name = "MODELENUM_GN_SEXYGIRL"
    },
    {
        model = 142,
        name = "MODELENUM_GN_SKINNYBBOY"
    },
    {
        model = 139,
        name = "MODELENUM_GN_WHITEBOY"
    },
    {
        model = 169,
        name = "MODELENUM_GN_WHITEBOY_WEEN"
    },
    {
        model = 289,
        name = "MODELENUM_GOCART"
    },
    {
        model = 21,
        name = "MODELENUM_GR2ND_PEANUT"
    },
    {
        model = 365,
        name = "MODELENUM_GRAB_BEAKER"
    },
    {
        model = 367,
        name = "MODELENUM_GRAB_CANISTER"
    },
    {
        model = 368,
        name = "MODELENUM_GRAB_EYEDROP"
    },
    {
        model = 369,
        name = "MODELENUM_GRAB_TESTTUBE_LEFT"
    },
    {
        model = 366,
        name = "MODELENUM_GRAB_TESTTUBE_RIGHT"
    },
    {
        model = 25,
        name = "MODELENUM_GRGIRL_LOLA"
    },
    {
        model = 96,
        name = "MODELENUM_GRGIRL_LOLAUW"
    },
    {
        model = 24,
        name = "MODELENUM_GRH1_LEFTY"
    },
    {
        model = 27,
        name = "MODELENUM_GRH1A_VANCE"
    },
    {
        model = 173,
        name = "MODELENUM_GRH1A_VANCE_WEEN"
    },
    {
        model = 29,
        name = "MODELENUM_GRH2_NORTON"
    },
    {
        model = 22,
        name = "MODELENUM_GRH2A_HAL"
    },
    {
        model = 26,
        name = "MODELENUM_GRH3_LUCKY"
    },
    {
        model = 161,
        name = "MODELENUM_GRH3_LUCKY_WEEN"
    },
    {
        model = 28,
        name = "MODELENUM_GRH3A_RICKY"
    },
    {
        model = 23,
        name = "MODELENUM_GRLEAD_JOHNNY"
    },
    {
        model = 377,
        name = "MODELENUM_JBROOM"
    },
    {
        model = MODELENUM._JIMMY,
        name = "MODELENUM_JIMMY"
    },
    {
        model = 20,
        name = "MODELENUM_JK2ND_JURI"
    },
    {
        model = 92,
        name = "MODELENUM_JK_LUISWRESTLE"
    },
    {
        model = 112,
        name = "MODELENUM_JKDAMON_FB"
    },
    {
        model = 111,
        name = "MODELENUM_JKDAN_FB"
    },
    {
        model = 14,
        name = "MODELENUM_JKGIRL_MANDY"
    },
    {
        model = 93,
        name = "MODELENUM_JKGIRL_MANDYUW"
    },
    {
        model = 12,
        name = "MODELENUM_JKH1_DAMON"
    },
    {
        model = 168,
        name = "MODELENUM_JKH1_DAMON_WEEN"
    },
    {
        model = 13,
        name = "MODELENUM_JKH1A_KIRBY"
    },
    {
        model = 15,
        name = "MODELENUM_JKH2_DAN"
    },
    {
        model = 16,
        name = "MODELENUM_JKH2A_LUIS"
    },
    {
        model = 17,
        name = "MODELENUM_JKH3_CASEY"
    },
    {
        model = 164,
        name = "MODELENUM_JKH3_CASEY_WEEN"
    },
    {
        model = 18,
        name = "MODELENUM_JKH3A_BO"
    },
    {
        model = 109,
        name = "MODELENUM_JKKIRBY_FB"
    },
    {
        model = 19,
        name = "MODELENUM_JKLEAD_TED"
    },
    {
        model = 110,
        name = "MODELENUM_JKTED_FB"
    },
    {
        model = 372,
        name = "MODELENUM_KICKME"
    },
    {
        model = 488,
        name = "MODELENUM_LABNOTES"
    },
    {
        model = 507,
        name = "MODELENUM_LAUNDBAG"
    },
    {
        model = 315,
        name = "MODELENUM_LID"
    },
    {
        model = 508,
        name = "MODELENUM_LIPSTICK"
    },
    {
        model = 304,
        name = "MODELENUM_MARBLE"
    },
    {
        model = 511,
        name = "MODELENUM_MOPED"
    },
    {
        model = 284,
        name = "MODELENUM_MOWER"
    },
    {
        model = 280,
        name = "MODELENUM_MTNBIKE"
    },
    {
        model = 6,
        name = "MODELENUM_ND2ND_MELVIN"
    },
    {
        model = 122,
        name = "MODELENUM_ND_FATTYWRESTLE"
    },
    {
        model = 3,
        name = "MODELENUM_NDGIRL_BEATRICE"
    },
    {
        model = 95,
        name = "MODELENUM_NDGIRL_BEATRICEUW"
    },
    {
        model = 5,
        name = "MODELENUM_NDH1_FATTY"
    },
    {
        model = 155,
        name = "MODELENUM_NDH1_FATTYCHOCOLATE"
    },
    {
        model = 4,
        name = "MODELENUM_NDH1A_ALGERNON"
    },
    {
        model = 7,
        name = "MODELENUM_NDH2_THAD"
    },
    {
        model = 9,
        name = "MODELENUM_NDH2A_CORNELIUS"
    },
    {
        model = 8,
        name = "MODELENUM_NDH3_BUCKY"
    },
    {
        model = 11,
        name = "MODELENUM_NDH3A_DONALD"
    },
    {
        model = 162,
        name = "MODELENUM_NDH3A_DONALD_WEEN"
    },
    {
        model = 10,
        name = "MODELENUM_NDLEAD_EARNEST"
    },
    {
        model = 130,
        name = "MODELENUM_NEMESIS_GARY"
    },
    {
        model = 160,
        name = "MODELENUM_NEMESIS_WEEN"
    },
    {
        model = 320,
        name = "MODELENUM_NEWSROLL"
    },
    {
        model = 491,
        name = "MODELENUM_NPEARL"
    },
    {
        model = 373,
        name = "MODELENUM_OILCAN"
    },
    {
        model = 281,
        name = "MODELENUM_OLADBIKE"
    },
    {
        model = 510,
        name = "MODELENUM_ORDERLY"
    },
    {
        model = 502,
        name = "MODELENUM_PCHEALTH"
    },
    {
        model = 503,
        name = "MODELENUM_PCSPEC"
    },
    {
        model = 490,
        name = "MODELENUM_PERFUME"
    },
    {
        model = 134,
        name = "MODELENUM_PETER"
    },
    {
        model = 165,
        name = "MODELENUM_PETER_WEEN"
    },
    {
        model = 49,
        name = "MODELENUM_PF2ND_MAX"
    },
    {
        model = 50,
        name = "MODELENUM_PFH1_SETH"
    },
    {
        model = 51,
        name = "MODELENUM_PFH2_EDWARD"
    },
    {
        model = 52,
        name = "MODELENUM_PFLEAD_KARL"
    },
    {
        model = 485,
        name = "MODELENUM_PICKBULL"
    },
    {
        model = 353,
        name = "MODELENUM_PLANTPOT"
    },
    {
        model = 0,
        name = "MODELENUM_PLAYER"
    },
    {
        model = 88,
        name = "MODELENUM_PLAYER_MASCOT"
    },
    {
        model = MODELENUM._PLAYER_OBOX,
        name = "MODELENUM_PLAYER_OBOX"
    },
    {
        model = 98,
        name = "MODELENUM_PLAYER_OWRES"
    },
    {
        model = MODELENUM._PLAYER_WEEN,
        name = "MODELENUM_PLAYER_WEEN"
    },
    {
        model = MODELENUM._POISONSPRAY,
        name = "MODELENUM_POISONSPRAY"
    },
    {
        model = 572,
        name = "MODELENUM_POLICE_WHEEL"
    },
    {
        model = 295,
        name = "MODELENUM_POLICECAR"
    },
    {
        model = 341,
        name = "MODELENUM_POMPOM"
    },
    {
        model = 399,
        name = "MODELENUM_POOBAG"
    },
    {
        model = 512,
        name = "MODELENUM_POSTBAND"
    },
    {
        model = 513,
        name = "MODELENUM_POSTCAR"
    },
    {
        model = 316,
        name = "MODELENUM_POTATO"
    },
    {
        model = 356,
        name = "MODELENUM_PPLANT_PROJ"
    },
    {
        model = 33,
        name = "MODELENUM_PR2ND_BIF"
    },
    {
        model = 133,
        name = "MODELENUM_PR2ND_BIF_OBOX"
    },
    {
        model = 38,
        name = "MODELENUM_PRGIRL_PINKY"
    },
    {
        model = 167,
        name = "MODELENUM_PRGIRL_PINKY_WEEN"
    },
    {
        model = 94,
        name = "MODELENUM_PRGIRL_PINKYUW"
    },
    {
        model = 30,
        name = "MODELENUM_PRH1_GORD"
    },
    {
        model = 31,
        name = "MODELENUM_PRH1A_TAD"
    },
    {
        model = 35,
        name = "MODELENUM_PRH2_BRYCE"
    },
    {
        model = 36,
        name = "MODELENUM_PRH2_BRYCE_OBOX"
    },
    {
        model = 32,
        name = "MODELENUM_PRH2A_CHAD"
    },
    {
        model = 117,
        name = "MODELENUM_PRH2A_CHAD_OBOX"
    },
    {
        model = 34,
        name = "MODELENUM_PRH3_JUSTIN"
    },
    {
        model = 118,
        name = "MODELENUM_PRH3_JUSTIN_OBOX"
    },
    {
        model = 40,
        name = "MODELENUM_PRH3A_PARKER"
    },
    {
        model = 119,
        name = "MODELENUM_PRH3A_PARKER_OBOX"
    },
    {
        model = 163,
        name = "MODELENUM_PRH3A_PARKER_WEEN"
    },
    {
        model = 37,
        name = "MODELENUM_PRLEAD_DARBY"
    },
    {
        model = 360,
        name = "MODELENUM_PSHEILD"
    },
    {
        model = 354,
        name = "MODELENUM_PVASE_PROJ"
    },
    {
        model = 282,
        name = "MODELENUM_RACER"
    },
    {
        model = 476,
        name = "MODELENUM_RADIO"
    },
    {
        model = 136,
        name = "MODELENUM_RAT_PED"
    },
    {
        model = 374,
        name = "MODELENUM_RATCHET"
    },
    {
        model = 489,
        name = "MODELENUM_SAVE"
    },
    {
        model = 276,
        name = "MODELENUM_SCOOTER"
    },
    {
        model = 492,
        name = "MODELENUM_SEXDRESS"
    },
    {
        model = 324,
        name = "MODELENUM_SLEDGEHAMMER"
    },
    {
        model = 303,
        name = "MODELENUM_SLINGSHOT"
    },
    {
        model = MODELENUM._SMPADDLE,
        name = "MODELENUM_SMPADDLE"
    },
    {
        model = 313,
        name = "MODELENUM_SNOWBALL"
    },
    {
        model = 364,
        name = "MODELENUM_SNOWSHWL"
    },
    {
        model = 330,
        name = "MODELENUM_SNWBALLB"
    },
    {
        model = 329,
        name = "MODELENUM_SOCBALL"
    },
    {
        model = 588,
        name = "MODELENUM_SPECIAL10"
    },
    {
        model = 589,
        name = "MODELENUM_SPECIAL11"
    },
    {
        model = 590,
        name = "MODELENUM_SPECIAL12"
    },
    {
        model = 591,
        name = "MODELENUM_SPECIAL13"
    },
    {
        model = 592,
        name = "MODELENUM_SPECIAL14"
    },
    {
        model = 593,
        name = "MODELENUM_SPECIAL15"
    },
    {
        model = 594,
        name = "MODELENUM_SPECIAL16"
    },
    {
        model = 595,
        name = "MODELENUM_SPECIAL17"
    },
    {
        model = 596,
        name = "MODELENUM_SPECIAL18"
    },
    {
        model = 597,
        name = "MODELENUM_SPECIAL19"
    },
    {
        model = 580,
        name = "MODELENUM_SPECIAL2"
    },
    {
        model = 598,
        name = "MODELENUM_SPECIAL20"
    },
    {
        model = 581,
        name = "MODELENUM_SPECIAL3"
    },
    {
        model = 582,
        name = "MODELENUM_SPECIAL4"
    },
    {
        model = 583,
        name = "MODELENUM_SPECIAL5"
    },
    {
        model = 584,
        name = "MODELENUM_SPECIAL6"
    },
    {
        model = 585,
        name = "MODELENUM_SPECIAL7"
    },
    {
        model = 586,
        name = "MODELENUM_SPECIAL8"
    },
    {
        model = 587,
        name = "MODELENUM_SPECIAL9"
    },
    {
        model = 579,
        name = "MODELENUM_SPFIRST"
    },
    {
        model = 608,
        name = "MODELENUM_SPLAST"
    },
    {
        model = 321,
        name = "MODELENUM_SPRAYCAN"
    },
    {
        model = 305,
        name = "MODELENUM_SPUDG"
    },
    {
        model = 309,
        name = "MODELENUM_STINKBOMB"
    },
    {
        model = 466,
        name = "MODELENUM_STPDSHRT"
    },
    {
        model = 347,
        name = "MODELENUM_SUPERGLUE"
    },
    {
        model = 322,
        name = "MODELENUM_SUPERMARBLE"
    },
    {
        model = 306,
        name = "MODELENUM_SUPERSLING"
    },
    {
        model = 396,
        name = "MODELENUM_SUPERSPUDG"
    },
    {
        model = 494,
        name = "MODELENUM_TADKEY"
    },
    {
        model = 286,
        name = "MODELENUM_TAXICAB"
    },
    {
        model = 63,
        name = "MODELENUM_TE_ART"
    },
    {
        model = 129,
        name = "MODELENUM_TE_ASSYLUM"
    },
    {
        model = 126,
        name = "MODELENUM_TE_AUTOSHOP"
    },
    {
        model = 64,
        name = "MODELENUM_TE_BIOLOGY"
    },
    {
        model = 58,
        name = "MODELENUM_TE_CAFETERIA"
    },
    {
        model = 106,
        name = "MODELENUM_TE_CHEMISTRY"
    },
    {
        model = 57,
        name = "MODELENUM_TE_ENGLISH"
    },
    {
        model = 55,
        name = "MODELENUM_TE_GYMTEACHER"
    },
    {
        model = 54,
        name = "MODELENUM_TE_HALLMONITOR"
    },
    {
        model = 151,
        name = "MODELENUM_TE_HISTORY"
    },
    {
        model = 56,
        name = "MODELENUM_TE_JANITOR"
    },
    {
        model = 62,
        name = "MODELENUM_TE_LIBRARIAN"
    },
    {
        model = 61,
        name = "MODELENUM_TE_MATHTEACHER"
    },
    {
        model = 60,
        name = "MODELENUM_TE_NURSE"
    },
    {
        model = 65,
        name = "MODELENUM_TE_PRINCIPAL"
    },
    {
        model = 59,
        name = "MODELENUM_TE_SECRETARY"
    },
    {
        model = 363,
        name = "MODELENUM_TEDDYBEAR"
    },
    {
        model = 498,
        name = "MODELENUM_TEXTBOOK"
    },
    {
        model = 495,
        name = "MODELENUM_TICKET"
    },
    {
        model = 124,
        name = "MODELENUM_TO_ASSOCIATE"
    },
    {
        model = 125,
        name = "MODELENUM_TO_ASYLUMPATIENT"
    },
    {
        model = 132,
        name = "MODELENUM_TO_BARBERPOOR"
    },
    {
        model = 120,
        name = "MODELENUM_TO_BARBERRICH"
    },
    {
        model = 86,
        name = "MODELENUM_TO_BIKEOWNER"
    },
    {
        model = 76,
        name = "MODELENUM_TO_BUSINESS1"
    },
    {
        model = 77,
        name = "MODELENUM_TO_BUSINESS2"
    },
    {
        model = 144,
        name = "MODELENUM_TO_BUSINESS3"
    },
    {
        model = 148,
        name = "MODELENUM_TO_BUSINESS4"
    },
    {
        model = 149,
        name = "MODELENUM_TO_BUSINESS5"
    },
    {
        model = 78,
        name = "MODELENUM_TO_BUSINESSW1"
    },
    {
        model = 79,
        name = "MODELENUM_TO_BUSINESSW2"
    },
    {
        model = 143,
        name = "MODELENUM_TO_CARNIE_FEMALE"
    },
    {
        model = 114,
        name = "MODELENUM_TO_CARNY01"
    },
    {
        model = 113,
        name = "MODELENUM_TO_CARNY02"
    },
    {
        model = 115,
        name = "MODELENUM_TO_CARNYMIDGET"
    },
    {
        model = 84,
        name = "MODELENUM_TO_COMIC"
    },
    {
        model = 83,
        name = "MODELENUM_TO_COP"
    },
    {
        model = 97,
        name = "MODELENUM_TO_COP2"
    },
    {
        model = 104,
        name = "MODELENUM_TO_CSOWNER_2"
    },
    {
        model = 105,
        name = "MODELENUM_TO_CSOWNER_3"
    },
    {
        model = 82,
        name = "MODELENUM_TO_FIREMAN"
    },
    {
        model = 103,
        name = "MODELENUM_TO_FIREOWNER"
    },
    {
        model = 140,
        name = "MODELENUM_TO_FMIDGET"
    },
    {
        model = 156,
        name = "MODELENUM_TO_GROCERYCLERK"
    },
    {
        model = 89,
        name = "MODELENUM_TO_GROCERYOWNER"
    },
    {
        model = 157,
        name = "MODELENUM_TO_HANDY"
    },
    {
        model = 87,
        name = "MODELENUM_TO_HOBO"
    },
    {
        model = 123,
        name = "MODELENUM_TO_INDUSTRIAL"
    },
    {
        model = 127,
        name = "MODELENUM_TO_MAILMAN"
    },
    {
        model = 108,
        name = "MODELENUM_TO_MOTELOWNER"
    },
    {
        model = 131,
        name = "MODELENUM_TO_OLDMAN2"
    },
    {
        model = 53,
        name = "MODELENUM_TO_ORDERLY"
    },
    {
        model = 158,
        name = "MODELENUM_TO_ORDERLY2"
    },
    {
        model = 116,
        name = "MODELENUM_TO_POORMAN2"
    },
    {
        model = 107,
        name = "MODELENUM_TO_POORWOMAN"
    },
    {
        model = 152,
        name = "MODELENUM_TO_RECORD"
    },
    {
        model = 100,
        name = "MODELENUM_TO_RICHM1"
    },
    {
        model = 101,
        name = "MODELENUM_TO_RICHM2"
    },
    {
        model = 135,
        name = "MODELENUM_TO_RICHM3"
    },
    {
        model = 80,
        name = "MODELENUM_TO_RICHW1"
    },
    {
        model = 81,
        name = "MODELENUM_TO_RICHW2"
    },
    {
        model = 128,
        name = "MODELENUM_TO_TATTOOIST"
    },
    {
        model = 375,
        name = "MODELENUM_TORCH"
    },
    {
        model = 385,
        name = "MODELENUM_TROPHY"
    },
    {
        model = 297,
        name = "MODELENUM_TRUCK"
    },
    {
        model = 323,
        name = "MODELENUM_TWOBYFOUR"
    },
    {
        model = 484,
        name = "MODELENUM_UNDIE"
    },
    {
        model = 393,
        name = "MODELENUM_W_CANDY"
    },
    {
        model = 346,
        name = "MODELENUM_W_DEADRAT"
    },
    {
        model = 397,
        name = "MODELENUM_W_FOUNTAIN"
    },
    {
        model = 394,
        name = "MODELENUM_W_ITCH"
    },
    {
        model = 395,
        name = "MODELENUM_W_PGUN"
    },
    {
        model = 334,
        name = "MODELENUM_WBBALL"
    },
    {
        model = 328,
        name = "MODELENUM_WCAMERA"
    },
    {
        model = 338,
        name = "MODELENUM_WDISH"
    },
    {
        model = 471,
        name = "MODELENUM_WEIRDHAT"
    },
    {
        model = 335,
        name = "MODELENUM_WFRISBEE"
    },
    {
        model = 331,
        name = "MODELENUM_WFTBALL"
    },
    {
        model = 400,
        name = "MODELENUM_WFTBOMB"
    },
    {
        model = 345,
        name = "MODELENUM_WHATSVASE"
    },
    {
        model = 390,
        name = "MODELENUM_WHATVASE"
    },
    {
        model = 575,
        name = "MODELENUM_WHEEL_70WAGON"
    },
    {
        model = 574,
        name = "MODELENUM_WHEEL_CARGREEN"
    },
    {
        model = 576,
        name = "MODELENUM_WHEEL_VAN"
    },
    {
        model = 332,
        name = "MODELENUM_WMALLET"
    },
    {
        model = 376,
        name = "MODELENUM_WRENCH"
    },
    {
        model = 348,
        name = "MODELENUM_WTRAY"
    },
    {
        model = 342,
        name = "MODELENUM_WTRPIPE"
    },
    {
        model = 299,
        name = "MODELENUM_YARDSTICK"
    }
}
]] -- Not present in original script

--[[
function ModelReport()
    for _, e in allModels do
        print("{model = " .. e.name .. ", name = \"" .. e.name .. "\", num = " .. tostring(e.model) .. "},")
    end
end

function ReturnModelNameForNumber(num)
    if type(num) == "table" then
        for _, n in num do
            for _, e in allModels do
                if e.model == n then
                    print(e.name .. ",")
                    bFound = true
                end
            end
        end
    elseif type(num) == "number" then
        for _, e in allModels do
            if e.model == num then
                print("{model = " .. e.name .. ", num = " .. tostring(e.model) .. "},")
                bFound = true
            end
        end
    end
    if not bFound then
        print(">>>[RUI]", "num: " .. tostring(num) .. " NOT FOUND")
    end
end
]] -- Not present in original script

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

function F_UnlockYearbookReward() -- ! Modified
    --[[
    if YearbookIsFull() and not MiniObjectiveGetIsComplete(13) then
    ]] -- Modified to:
    if YearbookIsFull() and not MiniObjectiveGetIsComplete(14) then
        MinigameSetErrandCompletion(-1, "AS_OBJCOMPLETE", true, 0, "AS_YEARBK_REWARD")
        MinigameSetUberCompletion()
        ClothingGivePlayerOutfit("Ninja_BLK")
        --[[
        MiniObjectiveSetIsComplete(13)
        ]] -- Changed to:
        MiniObjectiveSetIsComplete(14)
        PlayerAddMoney(30000, false)
    end
end

--[[
function F_CleanBlip(blip)
    if blip then
        BlipRemove(blip)
        print(">>>[RUI]", "!!F_CleanBlip")
    end
    return nil
end

function TagsBlip(tagTbl, bOn)
    if not tagTbl then
        return
    end
    local bx, by, bz
    for _, tag in tagTbl do
        tag.blip = F_CleanBlip(tag.blip)
        if bOn then
            print(">>>[RUI]", "TagsBlip tostring(tag.id)")
            if AreaTriggerIsValid(tag.id) then
                bx, by, bz = GetAnchorPosition(tag.id)
                tag.blip = BlipAddXYZ(bx, by, bz, 34, 1)
            else
                print(">>>[RUI]", "TagsBlip BAD TAG")
            end
        end
    end
end

function TagsBlipSchoolHalls(bOn)
    if bOn then
        tagsSchoolHallways = {
            {
                id = TRIGGER._SH_MEDIUM01
            },
            {
                id = TRIGGER._SH_MEDIUM02
            },
            {
                id = TRIGGER._SH_MEDIUM03
            },
            {
                id = TRIGGER._SH_MEDIUM04
            },
            {
                id = TRIGGER._SH_MEDIUM05
            },
            {
                id = TRIGGER._SH_MEDIUM07
            },
            {
                id = TRIGGER._SH_MEDIUM08
            },
            {
                id = TRIGGER._SH_MEDIUM09
            }
        }
    end
    TagsBlip(tagsSchoolHallways, bOn)
end

function TagsBlipSchoolGrounds(bOn)
    if bOn then
        tagsSchoolGrounds = {
            {
                id = TRIGGER._SG_MEDIUM01
            },
            {
                id = TRIGGER._SG_MEDIUM02
            },
            {
                id = TRIGGER._SG_MEDIUM03
            },
            {
                id = TRIGGER._SG_MEDIUM04
            },
            {
                id = TRIGGER._SG_MEDIUM05
            },
            {
                id = TRIGGER._SG_MEDIUM06
            },
            {
                id = TRIGGER._SG_MEDIUM07
            },
            {
                id = TRIGGER._SG_MEDIUM08
            },
            {
                id = TRIGGER._SG_MEDIUM09
            },
            {
                id = TRIGGER._SG_MEDIUM10
            },
            {
                id = TRIGGER._SG_MEDIUM11
            },
            {
                id = TRIGGER._SG_MEDIUM12
            },
            {
                id = TRIGGER._SG_MEDIUM14
            },
            {
                id = TRIGGER._SG_MEDIUM15
            },
            {
                id = TRIGGER._SG_MEDIUM16
            },
            {
                id = TRIGGER._SG_MEDIUM17
            },
            {
                id = TRIGGER._SG_MEDIUM18
            },
            {
                id = TRIGGER._SG_MEDIUM19
            },
            {
                id = TRIGGER._SG_MEDIUM20
            },
            {
                id = TRIGGER._SO_MEDIUM01
            },
            {
                id = TRIGGER._SO_MEDIUM02
            },
            {
                id = TRIGGER._SO_MEDIUM03
            },
            {
                id = TRIGGER._SO_MEDIUM04
            },
            {
                id = TRIGGER._SO_MEDIUM05
            }
        }
    end
    TagsBlip(tagsSchoolGrounds, bOn)
end

function TagsBlipRichArea(bOn)
    if bOn then
        tagsRichArea = {
            {
                id = TRIGGER._RA_MEDIUM01
            },
            {
                id = TRIGGER._RA_MEDIUM02
            },
            {
                id = TRIGGER._RA_MEDIUM03
            },
            {
                id = TRIGGER._RA_MEDIUM04
            },
            {
                id = TRIGGER._RA_MEDIUM05
            },
            {
                id = TRIGGER._RA_MEDIUM06
            },
            {
                id = TRIGGER._RA_MEDIUM07
            },
            {
                id = TRIGGER._RA_MEDIUM08
            },
            {
                id = TRIGGER._RA_MEDIUM09
            },
            {
                id = TRIGGER._RA_MEDIUM10
            },
            {
                id = TRIGGER._RA_MEDIUM11
            },
            {
                id = TRIGGER._RA_MEDIUM12
            },
            {
                id = TRIGGER._RA_MEDIUM13
            },
            {
                id = TRIGGER._RA_MEDIUM14
            },
            {
                id = TRIGGER._RA_MEDIUM15
            },
            {
                id = TRIGGER._RA_MEDIUM16
            },
            {
                id = TRIGGER._RA_MEDIUM17
            },
            {
                id = TRIGGER._RA_MEDIUM18
            },
            {
                id = TRIGGER._RA_MEDIUM19
            },
            {
                id = TRIGGER._RA_MEDIUM20
            },
            {
                id = TRIGGER._RA_MEDIUM21
            },
            {
                id = TRIGGER._RA_MEDIUM22
            },
            {
                id = TRIGGER._RA_MEDIUM23
            },
            {
                id = TRIGGER._RA_MEDIUM24
            }
        }
    end
    TagsBlip(tagsRichArea, bOn)
end

function TagsBlipPoorArea(bOn)
    if bOn then
        tagsPoorArea = {
            {
                id = TRIGGER._POORAREA_MEDIUM_001
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_002
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_003
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_004
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_005
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_006
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_007
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_008
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_009
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_010
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_011
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_012
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_013
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_014
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_015
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_016
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_017
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_018
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_019
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_020
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_021
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_022
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_023
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_024
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_025
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_026
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_027
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_028
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_029
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_030
            }
        }
    end
    TagsBlip(tagsPoorArea, bOn)
end

function TagsBlipIdustrialArea(bOn)
    if bOn then
        tagsIndustrialArea = {
            {
                id = TRIGGER._IA_MEDIUM01
            },
            {
                id = TRIGGER._IA_MEDIUM02
            },
            {
                id = TRIGGER._IA_MEDIUM03
            },
            {
                id = TRIGGER._IA_MEDIUM04
            },
            {
                id = TRIGGER._IA_MEDIUM05
            },
            {
                id = TRIGGER._IA_MEDIUM06
            },
            {
                id = TRIGGER._IA_MEDIUM07
            }
        }
    end
    TagsBlip(tagsIndustrialArea, bOn)
end

function TagsBlipDowntown(bOn)
    if bOn then
        tagsDowntownArea = {
            {
                id = TRIGGER._DT_MEDIUM_001
            },
            {
                id = TRIGGER._DT_MEDIUM_002
            },
            {
                id = TRIGGER._DT_MEDIUM_003
            },
            {
                id = TRIGGER._DT_MEDIUM_004
            },
            {
                id = TRIGGER._DT_MEDIUM_005
            },
            {
                id = TRIGGER._DT_MEDIUM_006
            },
            {
                id = TRIGGER._DT_MEDIUM_007
            },
            {
                id = TRIGGER._DT_MEDIUM_008
            },
            {
                id = TRIGGER._DT_MEDIUM_009
            },
            {
                id = TRIGGER._DT_MEDIUM_010
            },
            {
                id = TRIGGER._DT_MEDIUM_011
            },
            {
                id = TRIGGER._DT_MEDIUM_012
            },
            {
                id = TRIGGER._DT_MEDIUM_013
            },
            {
                id = TRIGGER._DT_MEDIUM_014
            },
            {
                id = TRIGGER._DT_MEDIUM_015
            },
            {
                id = TRIGGER._DT_MEDIUM_016
            },
            {
                id = TRIGGER._DT_MEDIUM_017
            },
            {
                id = TRIGGER._DT_MEDIUM_019
            },
            {
                id = TRIGGER._DT_MEDIUM_020
            },
            {
                id = TRIGGER._DT_MEDIUM_021
            },
            {
                id = TRIGGER._DT_MEDIUM_022
            },
            {
                id = TRIGGER._DT_MEDIUM_023
            },
            {
                id = TRIGGER._DT_MEDIUM_024
            },
            {
                id = TRIGGER._DT_MEDIUM_025
            }
        }
    end
    TagsBlip(tagsDowntownArea, bOn)
end
]] -- Not present in original script
