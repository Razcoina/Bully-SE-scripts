local propDefaultGroupName = "_dPr"
local propType = "_Prp"
local monitorRunning = false

function F_Nil()
end

local propLookup = {}
local propRegisterQueue = {}
local registerFlag = false
local registerCount = 0
local propDefault = {
    x = nil,
    y = nil,
    z = nil,
    bGeo = false,
    bIsOpen = false,
    create = true,
    lockID = false,
    bStreamNormal = false,
    bGenerateObstacle = true
}

function F_DefaultForNil(originalValue, defaultValue)
    if originalValue == nil then
        return defaultValue
    end
    return originalValue
end

function L_PropOverrideDefault(propDefaultParam)
    for index, value in propDefaultParam do
        propDefault[index] = value
    end
end

function L_PropOnBrokenNew(hash_id, trigger_id)
    --print("firing on broken event for trigger", trigger_id)
    local propGroup = propLookup[trigger_id]
    if propGroup then
        for i, prop in propGroup do
            if prop.OnDestroyed then
                prop.OnDestroyed(prop)
            end
            prop.destroyed = true
        end
    end
end

function L_PropOnUsedNew(hash_id, trigger_id)
    --print("firing on used event for trigger", trigger_id)
    local propGroup = propLookup[trigger_id]
    --print("looking up event returned ", propGroup)
    if propGroup then
        --print("prop group has", table.getn(propGroup), "entries")
        for i, prop in propGroup do
            --print("prop", i, "in group has OnUsed?", tostring(prop.OnUsed))
            if prop.OnUsed then
                --print("executing OnUsed")
                prop.OnUsed(prop)
            end
            prop.used = true
        end
    end
end

function L_PropLoad(group, propsList)
    group = ValidateGroup(group, propDefaultGroupName, propType)
    for i, prop in propsList do
        --assert(prop.id ~= nil, "ASSERT: id is nil for prop " .. i)
        prop.bGeo = F_DefaultForNil(prop.bGeo, propDefault.bGeo)
        if prop.bGeo == nil or prop.bGeo == false then
            if prop.lockID ~= nil and prop.lockID then
                prop.id = TriggerLock(prop.id)
            end
            prop.trigger = prop.id
            local x, y, z = GetAnchorPosition(prop.id)
            prop.x = x
            prop.y = y
            prop.z = z
        end
        prop.bIsOpen = prop.bIsOpen or propDefault.bIsOpen
        prop.lockID = prop.lockID or propDefault.lockID
        prop.OnUsed = prop.OnUsed or propDefault.OnUsed
        prop.OnDestroyed = prop.OnDestroyed or propDefault.OnDestroyed
        prop.OnOpen = prop.OnOpen or propDefault.OnOpen
        prop.OnClose = prop.OnClose or propDefault.OnClose
        prop.CustomSetup = prop.CustomSetup or propDefault.CustomSetup
        prop.CustomCleanup = prop.CustomCleanup or propDefault.CustomCleanup
        prop.OnLockTarget = prop.OnLockTarget or propDefault.OnLockTarget
        prop.OnUnlockTarget = prop.OnUnlockTarget or propDefault.OnUnlockTarget
        prop.create = F_DefaultForNil(prop.create, propDefault.create)
        prop.bStreamNormal = prop.bStreamNormal or propDefault.bStreamNormal
        prop.bGenerateObstacle = F_DefaultForNil(prop.bGenerateObstacle, propDefault.bGenerateObstacle)
        if propLookup[prop.id] == nil then
            registerCount = registerCount + 1
            propLookup[prop.id] = {}
            table.insert(propRegisterQueue, prop)
        end
        table.insert(propLookup[prop.id], prop)
    end
    LT_Add(group, propsList, propType)
    L_PropCreate(group, false)
    registerFlag = true
end

function L_StopPropMonitor()
    monitorRunning = false
end

function L_StartPropMonitor()
    if not monitorRunning then
        CreateThread(L_PropMonitor)
        monitorRunning = true
    end
end

function LF_PropMonitor(groupName)
    if registerFlag == true then
        registerFlag = false
        SetNumberOfHandledPropEventObjects(registerCount)
        for i, prop in propRegisterQueue do
            RegisterPropEventHandler(prop.id, 0, L_PropOnBrokenNew)
            RegisterPropEventHandler(prop.id, 1, L_PropOnUsedNew)
        end
    end
    for i, group in LT_LibTable() do
        if LT_Type(i) == propType and (groupName == nil or groupName and i == groupName) then
            for i, prop in group do
                if prop.bGeo == true and not prop.destroyed and PAnimIsDestroyed(prop.id, prop.x, prop.y, prop.z) then
                    prop.destroyed = true
                    if prop.OnDestroyed ~= nil then
                        prop.OnDestroyed(prop)
                    end
                end
                if prop.bIsDoor then
                    if PAnimIsOpen(prop.id) and prop.bIsOpen == false then
                        prop.bIsOpen = true
                        if prop.OnOpen ~= nil then
                            prop.OnOpen(prop)
                        end
                    elseif not PAnimIsOpen(prop.id) and prop.bIsOpen == true then
                        prop.bIsOpen = false
                        if prop.OnClose ~= nil then
                            prop.OnClose(prop)
                        end
                    end
                end
                if prop.bIsSwitch then
                    local bPlaying = PAnimIsPlaying(prop.id, prop.actNode, prop.bRecursive)
                    if bPlaying and prop.bSwitchActive == false then
                        prop.bSwitchActive = true
                        if prop.OnActivate ~= nil then
                            prop.OnActivate(prop)
                        end
                    elseif not bPlaying and prop.bSwitchActive == true then
                        prop.bSwitchActive = false
                        if prop.OnDeactivate ~= nil then
                            prop.OnDeactivate(prop)
                        end
                    end
                end
            end
        end
    end
end

function L_PropMonitor()
    monitorRunning = true
    while monitorRunning do
        LF_PropMonitor()
        Wait(0)
    end
    --DebugPrint("L_PropMonitor() stopping.")
    collectgarbage()
end

function L_PropGetProp(id)
    return LT_FindElement("id", id, propType)
end

function L_PropGetPropByField(field, value)
    return LT_FindElement(field, value, propType)
end

function L_PropGroup(group)
    errorFuncName = "L_PropGroup"
    group = ValidateGroup(group, propDefaultGroupName, propType)
    return LT_Group(group)
end

function L_PropCreate(group, createAll)
    errorFuncName = "L_PropCreate"
    group = ValidateGroup(group, propDefaultGroupName, propType)
    for j, prop in LT_Group(group) do
        if prop.bGeo == nil or prop.bGeo == false then
            if prop.delete then
                PAnimDelete(prop.id)
            elseif prop.create or createAll then
                if GetIsMissionSpecific(prop.id) then
                    PAnimCreate(prop.id, prop.bStreamNormal, prop.bGenerateObstacle)
                end
                PAnimReset(prop.id)
                if prop.bIsDoor then
                    PAnimCloseDoor(prop.id)
                    prop.bIsOpen = false
                end
                if prop.CustomSetup ~= nil then
                    prop.CustomSetup(prop)
                end
                prop.create = false
            end
        elseif prop.create then
            GeometryInstance(prop.id, false, prop.x, prop.y, prop.z)
            prop.create = false
            --DebugPrint("simple prop " .. prop.id .. " created.")
        end
    end
end

function L_PropCleanup(group)
    errorFuncName = "L_PropCleanup"
    group = ValidateGroup(group, propDefaultGroupName, propType)
    for i, prop in LT_Group(group) do
        if prop.bGeo ~= nil and prop.bGeo == false then
            if GetIsMissionSpecific(prop.id) then
                PAnimDelete(prop.id)
            elseif not prop.destroyed and not prop.used then
                PAnimCreate(prop.id, prop.bStreamNormal, prop.bGenerateObstacle)
            end
            if prop.CustomCleanup ~= nil then
                prop.CustomCleanup(prop)
            end
            if prop.lockID == nil or prop.lockID then
            end
        end
    end
end

function L_PropPedLockTarget(prop)
    if not prop.used then
        PedTargetPAnim(prop.ped, prop.id)
        if prop.OnLockTarget then
            prop.OnLockTarget(prop)
        end
    end
end

function L_PropPedUnlockTarget(prop)
    PedLockTarget(prop.ped, -1)
    if prop.OnUnlockTarget then
        prop.OnUnlockTarget(prop)
    end
end

function L_PropExec(groupName, func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
    errorFuncName = "L_PropExec"
    local group = ValidateGroup(groupName, propDefaultGroupName, propType)
    LT_GroupFunction(group, func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
end
