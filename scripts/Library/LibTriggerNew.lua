local bMonitorTriggers = false
local bObjectsRegistered = false
local triggerObjectCount = 0
local triggerType = "_Trg"
local trgDefaultGroupName = "_dTr"
local tblTriggerLookup = {}
local tblRegisterQueue = {}

function L_TriggerOnEnterOld(triggerID, pedID)
    for i, trigger in tblTriggerLookup[triggerID] do
        trigger.bInTrigger = true
        if trigger.OnEnter ~= nil and (trigger.ped == pedID or trigger.ped == nil) then
            trigger.OnEnter(trigger, triggerID, pedID)
        end
    end
end

function L_TriggerInTriggerOld(triggerID, pedID)
    for i, trigger in tblTriggerLookup[triggerID] do
        if trigger.InTrigger ~= nil and (trigger.ped == pedID or trigger.ped == nil) then
            trigger.InTrigger(trigger, triggerID, pedID)
        end
    end
end

function L_TriggerOnExitOld(triggerID, pedID)
    for i, trigger in tblTriggerLookup[triggerID] do
        trigger.bInTrigger = false
        if trigger.OnExit ~= nil and (trigger.ped == pedID or trigger.ped == nil) then
            trigger.OnExit(trigger, triggerID, pedID)
        end
        if trigger.bTriggerOnlyOnce and trigger.ped == pedID then
            trigger.bChecked = true
        end
    end
end

function L_TriggerOnImpactOld(triggerID, modelID)
    for i, trigger in tblTriggerLookup[triggerID] do
        if trigger.OnImpact ~= nil and (trigger.projectile == modelID or trigger.projectile == nil) then
            trigger.OnImpact(trigger, triggerID, modelID)
        end
    end
end

function L_AddTrigger(groupName, tblTriggerData)
    errorFuncName = "L_AddTrigger"
    local group = ValidateGroup(groupName, trgDefaultGroupName, triggerType)
    for i, trigger in tblTriggerData do
        --assert(not (trigger.trigger or trigger.id) or trigger.ped or trigger.projectile, errorFuncName .. ": Missing trigger/ped or projectile for trigger: " .. i .. " group: " .. group)
        trigger.id = trigger.id or trigger.trigger
        trigger.trigger = trigger.trigger or trigger.id
        trigger.bOnEnter = trigger.bOnEnter and true
        trigger.bOnExit = trigger.bOnExit and true
        trigger.bOnContainPed = trigger.bOnContainPed and true
        trigger.bOnEnterProjectile = trigger.bOnEnterProjectile and true
        if tblTriggerLookup[trigger.id] == nil then
            triggerObjectCount = triggerObjectCount + 1
            tblTriggerLookup[trigger.id] = {}
            table.insert(tblRegisterQueue, trigger)
        end
        table.insert(tblTriggerLookup[trigger.id], trigger)
    end
    LT_Add(group, tblTriggerData, triggerType)
end

function L_TriggerGetTrigger(triggerID)
    return LT_FindElement("trigger", triggerID, triggerType)
end

function L_GetTriggerEntry(triggerID)
    for i, trigger in tblTriggerLookup[triggerID] do
        --print("COOL??!!!!")
        if trigger ~= nil and trigger.id == triggerID then
            --print("GOOD TRIGGER!!")
            return trigger
        end
    end
end

function L_TriggerSetData(triggerID, field, value)
    --assert(field ~= "trigger", "L_TriggerSetData: Don't try to modify the trigger ID directly !!!")
    --assert(field ~= "id", "L_TriggerSetData: Don't try to modify the trigger ID directly !!!")
    LT_SetData(pedID, field, value, pedType)
end

function F_MonitorTriggers(groupName)
    if not bObjectsRegistered then
        bObjectsRegistered = true
        SetNumberOfHandledTriggerEventObjects(triggerObjectCount)
    end
    while table.getn(tblRegisterQueue) > 0 do
        trigger_id = table.remove(tblRegisterQueue)
        if trigger_id.bOnEnter or trigger_id.bOnEnter == nil then
            --print("Registering on enter event!")
            RegisterTriggerEventHandler(trigger_id.id, 0, L_TriggerOnEnterOld)
        end
        if trigger_id.bOnExit or trigger_id.bOnExit == nil then
            --print("Registering on exit event!")
            RegisterTriggerEventHandler(trigger_id.id, 3, L_TriggerOnExitOld)
        end
        if trigger_id.bOnContainPed or trigger_id.bOnContainPed == nil then
            --print("Registering on contain ped event!")
            RegisterTriggerEventHandler(trigger_id.id, 5, L_TriggerInTriggerOld)
        end
        if trigger_id.bOnEnterProjectile or trigger_id.bOnEnterProjectile == nil then
            --print("Registering on enter projectile event!")
            RegisterTriggerEventHandler(trigger_id.id, 2, L_TriggerOnImpactOld)
        end
    end
end

function L_TriggerCleanup(groupName)
    for i, group in LT_LibTable() do
        if LT_Type(i) == triggerType and (groupName == nil or groupName and i == groupName) then
            for j, trigger in group do
                if trigger.bOnEnter then
                    RegisterTriggerEventHandler(trigger.id, 0, nil)
                end
                if trigger.bOnExit then
                    RegisterTriggerEventHandler(trigger.id, 3, nil)
                end
                if trigger.bOnContainPed then
                    RegisterTriggerEventHandler(trigger.id, 5, nil)
                end
                if trigger.bOnEnterProjectile then
                    RegisterTriggerEventHandler(trigger.id, 2, nil)
                end
            end
        end
    end
end

function L_MonitorTriggers()
    bMonitorTriggers = true
    while bMonitorTriggers do
        F_MonitorTriggers()
        Wait(0)
    end
    L_TriggerCleanup()
    collectgarbage()
end

function L_StopMonitoringTriggers()
    bMonitorTriggers = false
end

function T_TriggerMonitor()
    F_MonitorTriggers()
end

function L_TriggerMonitor(groupName)
    F_MonitorTriggers(groupName)
end

function L_RegisterNumberOfObjectEvents(nTriggerObjectCount)
    if not bObjectsRegistered then
        bObjectsRegistered = true
        SetNumberOfHandledTriggerEventObjects(nTriggerObjectCount)
        triggerObjectCount = nTriggerObjectCount
    else
        --print("LIB TRIGGER NEW ERROR!! Trying to re-size number of trigger events after size has been set.")
        --print("LIB TRIGGER NEW: Call this PRIOR to adding ANY triggers.")
    end
end
