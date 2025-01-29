local bMonitorTargets = false
local funcRef
local tblTargets = {}
local gCheckValidity = true
local photoType = "_Pht"
local phtDefaultGroupName = "_dPh"

function L_AddPhotoTarget(groupName, tblTargetData)
    errorFuncName = "L_AddPhotoTarget"
    local group = ValidateGroup(groupName, phtDefaultGroupName, photoType)
    for i, target in tblTargetData do
        if target.id ~= nil then
            --assert(target.type ~= nil, "L_AddPhotoTarget:  Missing type to correspond with id for target: " .. i .. " group: " .. group)
        elseif target.x ~= nil then
            --assert(target.y and target.z, "L_AddPhotoTarget: Missing y and z to correspond with x for target: " .. i .. " group: " .. group)
        else
            --assert(target.id or target.x, "L_AddPhotoTarget: Invalid target data:  need either id and type, or xyz coordinates for target: " .. i .. " group: " .. group)
        end
        if target.valid == nil then
            target.valid = true
        end
    end
    LT_Add(group, tblTargetData, photoType)
end

function L_DeletePhotoTarget(groupName)
    errorFuncName = "L_DeletePhotoTarget"
    local group = ValidateGroup(groupName, phtDefaultGroupName, photoType)
    LT_Delete(group)
end

function L_PhotoSetFunction(idFunction)
    --assert(idFunction ~= nil, "L_PhotoSetFunction: Function is nil!")
    funcRef = idFunction
end

function L_SetValidity(bValid)
    gCheckValidity = bValid
end

function L_MonitorTargets()
    bMonitorTargets = true
    while bMonitorTargets do
        if PhotoHasBeenTaken() then
            if funcRef ~= nil then
                --print("PHOTOHASBEENTAKEN:")
                local bValid = funcRef(L_GetTargetsInFrame())
                if bValid ~= nil and type(bValid) == type(true) then
                    PhotoSetValid(bValid)
                end
            else
                --DebugPrint("no funcRef")
            end
        elseif gCheckValidity then
            PhotoSetValid(L_TargetInFrame())
        end
        Wait(0)
    end
    collectgarbage()
    --DebugPrint("LibPhotography: L_MonitorTargets() ended.")
end

function L_StopMonitoringTargets()
    bMonitorTargets = false
end

function L_TargetInFrame()
    local i, group, j, target
    local bTargetInFrame = false
    for i, group in LT_LibTable() do
        if LT_Type(i) == photoType then
            for j, target in group do
                if target.valid then
                    if target.id ~= nil then
                        bTargetInFrame = PhotoTargetInFrame(target.id, target.type)
                    elseif target.x ~= nil then
                        bTargetInFrame = PhotoTargetInFrame(target.x, target.y, target.z)
                    end
                    if bTargetInFrame then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function L_GetTargetsInFrame()
    local i, group, j, target
    local bTargetInFrame = false
    tblTargets = {}
    for i, group in LT_LibTable() do
        if LT_Type(i) == photoType then
            for j, target in group do
                if target.valid then
                    bTargetInFrame = false
                    if target.id ~= nil then
                        bTargetInFrame = PhotoTargetInFrame(target.id, target.type)
                    elseif target.x ~= nil then
                        bTargetInFrame = PhotoTargetInFrame(target.x, target.y, target.z)
                    end
                    if bTargetInFrame then
                        table.insert(tblTargets, target)
                    end
                end
            end
        end
    end
    return tblTargets
end

function L_SetTargetValid(tblTarget, bValid)
    local i, group, j, target
    for i, group in LT_LibTable() do
        if LT_Type(i) == photoType then
            for j, target in group do
                if tblTarget.id ~= nil then
                    if target.id ~= nil and tblTarget.id == target.id then
                        target.valid = bValid
                        break
                    end
                elseif tblTarget.x ~= nil and target.x ~= nil and tblTarget.x == target.x and tblTarget.y == target.y and tblTarget.z == target.z then
                    target.valid = bValid
                    break
                end
            end
        end
    end
end
