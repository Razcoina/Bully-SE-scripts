local pedType = "_Ped"
local pedDefaultGroupName = "_dPd"
local bMonitorPeds

function L_PedCreate(ped)
    --print("point in lib is " .. tostring(ped.point))
    if ped.point then
        ped.id = PedCreatePoint(ped.model, ped.point)
        --print("ran create point")
    elseif ped.x and ped.y and ped.z then
        ped.id = PedCreateXYZ(ped.model, ped.x, ped.y, ped.z)
        --print("ran create xyz")
    end
    F_PedProcessAttribute(ped)
    --print("processed attributes")
end

function L_PedLoadPoint(groupName, pedTable)
    errorFuncName = "L_PedLoadPoint"
    for i, ped in pedTable do
        --print("ped " .. tostring(i) .. " = " .. tostring(ped))
        --assert(ped.model and ped.point, LPed__ErrorField("model/point", i, group))
    end
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    L_PedRequestModel(pedTable)
    LT_Add(group, pedTable, pedType)
    for i, ped in pedTable do
        L_PedCreate(ped)
    end
end

function L_PedLoadXYZ(groupName, pedTable)
    errorFuncName = "L_PedLoadXYZ"
    for i, ped in pedTable do
        --assert(ped.model and ped.x and ped.y and ped.z, LPed__ErrorField("model/x/y/z", i, group))
    end
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    L_PedRequestModel(pedTable)
    LT_Add(group, pedTable, pedType)
    for i, ped in pedTable do
        L_PedCreate(ped)
    end
end

function L_PedLoad(groupName, pedTable)
    errorFuncName = "L_PedLoad"
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    LT_Add(group, pedTable, pedType)
end

function L_PedDeleteGroup(groupName)
    errorFuncName = "L_PedDeleteGroup"
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    LT_Delete(group)
end

function L_PedGetData(pedID, field)
    return LT_GetData(pedID, field, pedType)
end

function L_PedSetData(pedID, field, value)
    --assert(field ~= "id", "L_PedSetData: Don't try to modify the ID directly !!!")
    LT_SetData(pedID, field, value, pedType)
end

function L_PedGetID(field, value)
    local ped = LT_FindElement(field, value, pedType)
    if ped.id then
        return ped.id
    end
end

function L_PedGetPed(id)
    return LT_FindElement("id", id, pedType)
end

function L_PedGetPedByIndex(groupName, index)
    errorFuncName = "L_PedGetPedByIndex"
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    --assert(index ~= nil, LT__ErrorField("Index value = nil"))
    local foundGroup = L_PedGroup(group)
    if foundGroup[index] then
        return foundGroup[index]
    end
end

function L_PedGetIDByIndex(groupName, index)
    errorFuncName = "L_PedGetPedIDByIndex"
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    --assert(index ~= nil, LT__ErrorField("Index value = nil"))
    local foundGroup = L_PedGroup(group)
    if foundGroup[index] then
        return foundGroup[index].id
    end
end

function L_PedGroup(groupName)
    errorFuncName = "L_PedGroup"
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    return LT_Group(group)
end

function L_PedExec(groupName, func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
    errorFuncName = "L_PedExec"
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    LT_GroupFunction(group, func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
end

function L_PedExecByField(field, value, func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
    errorFuncName = "L_PedExecByField"
    --assert(field ~= nil, LT__ErrorField("Field name is nil"))
    LT_FieldFunction(pedType, field, value, func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
end

function L_PedIterateWithFunc(groupName, funcName)
    errorFuncName = "L_PedIterateWithFunc"
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    LT_GroupIterateWith(group, funcName)
end

function L_PedSize(groupName)
    errorFuncName = "L_PedSize"
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    return LT_GroupSize(group)
end

function L_PedAllSetTo(field, requiredValue, groupName)
    errorFuncName = "L_PedAllSetTo"
    --assert(field ~= nil, LT__ErrorField("Field name is nil"))
    --assert(requiredValue ~= nil, LT__ErrorField("Value is nil"))
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    local allEqual = true
    for i, ped in LT_Group(group) do
        if ped[field] then
            if ped[field] ~= requiredValue then
                allEqual = false
                break
            end
        else
            allEqual = false
            break
        end
    end
    return allEqual
end

function L_PedAllDead(groupName)
    errorFuncName = "L_PedAllDead"
    local allDead = true
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    for i, ped in LT_Group(group) do
        if ped.id then
            if not PedIsDead(ped.id) then
                allDead = false
                break
            end
        else
            allDead = false
            break
        end
    end
    return allDead
end

function L_PedDeadCount(groupName)
    errorFuncName = "L_PedDeadCount"
    local deadCount = 0
    local group = ValidateGroup(groupName, pedDefaultGroupName, pedType)
    for i, ped in LT_Group(group) do
        if ped.id and PedIsDead(ped.id) then
            deadCount = deadCount + 1
        end
    end
    --DebugPrint("L_PedDeadCount() -- " .. deadCount)
    return deadCount
end

function F_PedMonitor(groupName)
    errorFuncName = "L_PedMonitor"
    for i, group in LT_LibTable() do
        if LT_Type(i) == pedType and (groupName == nil or i == groupName) then
            for i, ped in group do
                if PedIsDead(ped.id) and not ped.isDead then
                    ped.isDead = true
                    if ped.OnDeath then
                        ped.OnDeath(ped)
                    end
                end
                if not ped.isDead and ped.state then
                    if PedIsPlaying(ped.id, ped.state, ped.recurse) then
                        if not ped.bStateChecked then
                            if not ped.bInState then
                                ped.bInState = true
                                if ped.OnStateReached ~= nil then
                                    ped.OnStateReached(ped)
                                end
                            elseif ped.InState ~= nil then
                                ped.InState(ped)
                            end
                        end
                    elseif ped.bInState then
                        ped.bInState = false
                        if ped.OnStateLeft ~= nil then
                            ped.OnStateLeft(ped)
                        end
                        if ped.bCheckStateOnlyOnce then
                            ped.bStateChecked = true
                        end
                    end
                end
                if not ped.isDead and ped.AIstate then
                    if PedIsDoingTask(ped.id, ped.AIstate, ped.AIrecurse) then
                        if not ped.bAIStateChecked then
                            if not ped.bInAIState then
                                ped.bInAIState = true
                                if ped.OnAIStateReached ~= nil then
                                    ped.OnAIStateReached(ped)
                                end
                            elseif ped.InAIState ~= nil then
                                ped.InAIState(ped)
                            end
                        end
                    elseif ped.bInAIState then
                        ped.bInAIState = false
                        if ped.OnAIStateLeft ~= nil then
                            ped.OnAIStateLeft(ped)
                        end
                        if ped.bCheckAIStateOnlyOnce then
                            ped.bAIStateChecked = true
                        end
                    end
                end
                if ped.bNISPed and PedGetWhoHitMeLast(ped.id) == gPlayer and ped.cbAttacked then
                    ped.cbAttacked(ped.id)
                    ped.bNISPed = false
                end
            end
        end
    end
end

function L_MonitorPeds()
    bMonitorPeds = true
    while bMonitorPeds do
        F_PedMonitor()
        Wait(0)
    end
    collectgarbage()
end

function L_StopMonitoringPeds()
    bMonitorPeds = false
end

function L_PedRequestModel(tblPed)
    for i, ped in tblPed do
        PedRequestModel(ped.model)
    end
    local modelsLoaded = false
    while not modelsLoaded do
        for i, ped in tblPed do
            if not ped.modelLoaded and PedRequestModel(ped.model) then
                ped.modelLoaded = true
                break
            end
        end
        modelsLoaded = true
    end
end

function T_PedMonitor()
    while true do
        F_PedMonitor()
        Wait(0)
    end
end

function L_PedMonitor(groupName)
    F_PedMonitor(groupName)
end

function L_PedInteractGroup(groupName)
    for i, group in LT_LibTable() do
        if LT_Type(i) == pedType and (groupName == nil or i == groupName) then
            for i, ped in group do
                L_PedInteract(ped)
            end
        end
    end
    return true
end

function L_PedInteract(ped)
    local interactRange = ped.interactRange or 1.5
    local awayRange = interactRange + (ped.awayRange or 1)
    local x, y, z = PedGetPosXYZ(ped.id)
    local corona = ped.corona or 0
    if corona == 3 or ped.radarIcon == 0 and ped.blip ~= nil then
        corona = 0
        question_x, question_y, question_z = PedGetHeadPos(ped.id)
        PedIsInAreaXYZ(gPlayer, question_x, question_y, question_z, 0, 3)
    end
    if PedIsInAreaXYZ(gPlayer, x, y, z, interactRange, corona) or PedGetWhoHitMeLast(ped.id) == gPlayer then
        ped.interactResult = ped.interact(ped)
        local x2, y2, z2 = PedGetPosXYZ(ped.id)
        local x1, y1, z1 = PlayerGetPosXYZ()
        local hyp = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
        local dx, dy = -(awayRange / hyp) * (x2 - x1), -(awayRange / hyp) * (y2 - y1)
        PlayerSetPosXYZ(x2 + dx, y2 + dy, z2)
    end
    return true
end

function L_PedCleanup()
    LT_Cleanup()
end

function LPed__ErrorField(requiredField, pos, group)
    group = group or "Default"
    return errorFuncName .. ": Field(s) " .. requiredField .. " not found for ped: " .. pos .. " group: " .. group
end

function F_PedProcessAttribute(ped)
    if ped.gravity ~= nil then
        PedSetEffectedByGravity(ped.id, ped.gravity)
    end
    if ped.weapon then
        PedSetWeaponNow(ped.id, ped.weapon.model, ped.weapon.ammo or 0)
    end
    if ped.actionFile then
        if ped.actionNode then
            PedSetActionNode(ped.id, ped.actionNode, ped.actionFile)
        elseif ped.actionTree then
            PedSetActionTree(ped.id, ped.actionTree, ped.actionFile)
        end
    end
    if ped.AINode and ped.AIFile then
        PedSetAITree(ped.id, ped.AINode, ped.AIFile)
    end
    if ped.bike and ped.bike.id == nil then
        local x, y, z = GetPointList(ped.bike.point)
        local tblAreaBike = VehicleFindInAreaXYZ(x, y, z, 1, false)
        if tblAreaBike then
            for i, bikeID in tblAreaBike do
                VehicleDelete(bikeID)
            end
        end
        ped.bike.id = VehicleCreatePoint(ped.bike.model, ped.bike.point)
        if ped.startOnBike == true then
            PedPutOnBike(ped.id, ped.bike.id)
        end
        if ped.isBikeOwner == true then
            VehicleSetOwner(ped.bike.id, ped.id)
        end
    end
    if ped.asleep ~= nil then
        PedSetAsleep(ped.id, ped.asleep)
        PedIgnoreStimuli(ped.id, ped.asleep)
    end
    if ped.showHealth ~= nil then
        PedShowHealthBar(ped.id, ped.showHealth)
    end
    if ped.ignoreStimuli ~= nil then
        PedIgnoreStimuli(ped.id, ped.ignoreStimuli)
    end
    if ped.stat then
        for i, pair in ped.stat do
            PedOverrideStat(ped.id, pair.name, pair.value)
        end
    end
    if ped.attitude then
        for i, pair in ped.attitude do
            PedSetPedToTypeAttitude(ped.id, pair.type, pair.rating)
        end
    end
    if not ped.noSpawnBlip and not ped.blip and ped.blipStyle and ped.radarIcon then
        ped.blip = AddBlipForChar(ped.id, 2, ped.radarIcon, ped.blipStyle)
    end
    if ped.lockTarget then
        PedLockTarget(ped.id, ped.lockTarget.ped, ped.lockTarget.targetRule)
    end
    if ped.ignoreAttacks ~= nil then
        PedIgnoreAttacks(ped.id, ped.ignoreAttacks)
    end
    if ped.tether then
        if ped.tether.ped then
            PedSetTetherToPed(ped.id, ped.tether.ped, ped.tether.radius)
        elseif ped.tether.point then
            PedSetTetherToPoint(ped.id, ped.tether.point, ped.tether.radius)
        elseif ped.tether.prop then
            PedSetTetherToProp(ped.id, ped.tether.prop, ped.tether.radius)
        elseif ped.tether.trigger then
            PedSetTetherToTrigger(ped.id, ped.tether.trigger)
        elseif ped.tether.x and ped.tether.y and ped.tether.z then
            PedSetTetherToXYZ(ped.id, ped.tether.x, ped.tether.y, ped.tether.z, ped.tether.radius)
        end
        if ped.tether.moveToCenter then
            PedSetTetherMoveToCenter(ped.id, ped.tether.moveToCenter)
        end
        if ped.tether.moveToTarget then
            PedSetTetherMoveToTarget(ped.id, ped.tether.moveToTarget)
        end
        if ped.tether.speed then
            PedSetTetherSpeed(ped.id, ped.tether.speed)
        end
    end
    if ped.antiTether then
        if ped.antiTether.ped then
            PedSetAntiTetherToPed(ped.id, ped.antiTether.ped, ped.antiTether.radius)
        elseif ped.antiTether.point then
            PedSetAntiTetherToPoint(ped.id, ped.antiTether.point, ped.antiTether.radius)
        elseif ped.antiTether.prop then
            PedSetAntiTetherToProp(ped.id, ped.antiTether.prop, ped.antiTether.radius)
        elseif ped.antiTether.trigger then
            PedSetAntiTetherToTrigger(ped.id, ped.antiTether.trigger)
        elseif ped.antiTether.x and ped.antiTether.y and ped.antiTether.z then
            PedSetAntiTetherToXYZ(ped.id, ped.antiTether.x, ped.antiTether.y, ped.antiTether.z, ped.antiTether.radius)
        end
    end
    if ped.bNISPed then
        --print("NIS PED???")
        if ped.cbAttacked == nil then
            --print("Error, trying to register an NIS ped without an NIS callback.")
            ped.bNISPed = false
        end
    end
end
