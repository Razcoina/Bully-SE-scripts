local objectDefaultGroupName = "_dOb"
local objType = "_Obj"
local monitorRunning = false

function F_Nil()
end

local objectDefault = {
    spawnLocation = nil,
    model = MODELENUM._TULIPS,
    OnDestroyed = nil
}

function L_ObjectValidate(prop)
    --assert(prop.spawnLocation ~= nil, "LibObject Error: tried to load an object without specifying a spawn location")
    prop.spawnLocation = prop.spawnLocation or objectDefault.spawnLocation
    prop.model = prop.model or objectDefault.model
    prop.OnDestroyed = prop.OnDestroyed or objectDefault.OnDestroyed
end

function L_ObjectLoad(tblPropParam)
    for i, prop in tblPropParam do
        L_ObjectValidate(prop)
    end
    LT_Add(objectDefaultGroupName, tblPropParam, objType)
    LT_GroupObjectCreate(objectDefaultGroupName, ObjectCreatePoint, "model", "spawnLocation")
end

function L_ObjectLoadGroup(tblPropParam, groupNameParam)
    local errorFuncName = "L_PropLoadGroup"
    local groupName = ValidateGroup(groupNameParam, objectDefaultGroupName, objType)
    for i, prop in tblPropParam do
        L_ObjectValidate(prop)
    end
    LT_Add(groupName, tblPropParam, objType)
    LT_GroupObjectCreate(groupName, ObjectCreatePoint, "model", "spawnLocation")
end

function L_ObjectOverrideDefault(propDefaultParam)
    for index, value in propDefaultParam do
        objectDefault[index] = value
    end
end

function L_StartObjectMonitor()
    if not monitorRunning then
        CreateThread("L_ObjectMonitor")
        monitorRunning = true
    end
end

function F_ObjectMonitor(groupName)
    for i, group in LT_LibTable() do
        if LT_Type(i) == objType and (groupName == nil or groupName and i == groupName) then
            for i, prop in group do
                if not prop.destroyed and prop.OnDestroyed ~= nil and ObjectIsDestroyed(prop.id) then
                    prop.OnDestroyed(prop)
                end
            end
        end
    end
end

function L_ObjectMonitor()
    monitorRunning = true
    while monitorRunning do
        F_ObjectMonitor()
        Wait(0)
    end
    collectgarbage()
end

function L_ObjectCleanup(group)
    errorFuncName = "L_ObjectCleanup"
    group = ValidateGroup(group, objectDefaultGroupName, objType)
    for i, prop in LT_Group(group) do
        if not prop.destroyed then
            ObjectDelete(prop.id)
        end
        if prop.CustomCleanup ~= nil then
            prop.CustomCleanup(prop)
        end
    end
end
