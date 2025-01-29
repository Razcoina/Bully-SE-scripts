local objectiveProcessingDone = false
local objectives
local objectiveDefault = {
    completed = false,
    failed = false,
    successConditions = {},
    successConditionParam = nil,
    failureConditions = {},
    failureConditionParam = nil,
    stopOnFailed = false,
    stopOnCompleted = false,
    failActions = {},
    failActionParam = nil,
    completeActions = {},
    completeActionParam = nil,
    activator = nil,
    killer = nil
}

function L_ObjectiveSetParam(objectivesParam)
    objectiveProcessingDone = false
    for i, objective in objectivesParam do
        objective.successConditions = objective.successConditions or objectiveDefault.successConditions
        objective.successConditionParam = objective.successConditionParam or objectiveDefault.successConditionParam
        objective.failureConditions = objective.failureConditions or objectiveDefault.failureConditions
        objective.failureConditionParam = objective.failureConditionParam or objectiveDefault.failureConditionParam
        objective.stopOnFailed = objective.stopOnFailed or objectiveDefault.stopOnFailed
        objective.stopOnCompleted = objective.stopOnCompleted or objectiveDefault.stopOnCompleted
        objective.failActions = objective.failActions or objectiveDefault.failActions
        objective.failActionParam = objective.failActionParam or objectiveDefault.failActionParam
        objective.completeActions = objective.completeActions or objectiveDefault.completeActions
        objective.completeActionParam = objective.completeActionParam or objectiveDefault.completeActionParam
        objective.activator = objective.activator or objectiveDefault.activator
        objective.killer = objective.killer or objectiveDefault.killer
        objective.completed = objective.completed or objectiveDefault.completed
        objective.failed = objective.failed or objectiveDefault.failed
    end
    objectives = objectivesParam
end

function L_ObjectiveDecrementTally(objective_key, element_key)
    objectives[objective_key][element_key] = objectives[objective_key][element_key] - 1
end

function L_ObjectiveIncrementTally(objective_key, element_key)
    objectives[objective_key][element_key] = objectives[objective_key][element_key] + 1
end

function L_ObjectiveCheckConditions(conditions, param, objective, obj_name)
    local bReturnValue = true
    if conditions[1] ~= nil then
        for i, F_CheckCondition in conditions do
            local conditionMet
            if param then
                conditionMet = F_CheckCondition(param, objective, obj_name)
            else
                conditionMet = F_CheckCondition()
            end
            if not conditionMet then
                bReturnValue = false
                break
            end
        end
    else
        bReturnValue = false
    end
    return bReturnValue
end

function L_ObjectiveProcessActions(actions, param, objective, obj_name)
    for i, F_Action in actions do
        if param then
            F_Action(param, objective, obj_name)
        else
            F_Action()
        end
    end
end

function F_ObjectiveMonitor()
    local allObjectivesMet = true
    for obj_name, objective in objectives do
        local activatorProcessed = L_ObjectiveActivatorProcessed(objective)
        local killerProcessed = L_ObjectiveKillerProcessed(objective)
        if not activatorProcessed then
            allObjectivesMet = false
        end
        if not objective.completed and not objective.failed and activatorProcessed and not killerProcessed then
            if objective.successConditions[1] == nil and objective.failureConditions[1] == nil then
                if objective.completeActions then
                    if objective.completeActionParam then
                        L_ObjectiveProcessActions(objective.completeActions, objective.completeActionParam, objective, obj_name)
                    else
                        L_ObjectiveProcessActions(objective.completeActions)
                    end
                    objective.completed = true
                elseif objective.failActions then
                    if objective.failActionsParam then
                        L_ObjectiveProcessActions(objective.failActions, objective.failActionParam, objective, obj_name)
                    else
                        L_ObjectiveProcessActions(objective.failActions)
                    end
                    objective.failed = true
                end
            else
                if objective.successConditionParam then
                    objective.completed = L_ObjectiveCheckConditions(objective.successConditions, objective.successConditionParam, objective, obj_name)
                else
                    objective.completed = L_ObjectiveCheckConditions(objective.successConditions)
                end
                if not objective.completed then
                    allObjectivesMet = false
                else
                    if objective.completeActionParam then
                        L_ObjectiveProcessActions(objective.completeActions, objective.completeActionParam, objective, obj_name)
                    else
                        L_ObjectiveProcessActions(objective.completeActions)
                    end
                    if objective.stopOnCompleted then
                        objectiveProcessingDone = true
                        break
                    end
                end
                if objective.failureConditionParam then
                    objective.failed = L_ObjectiveCheckConditions(objective.failureConditions, objective.failureConditionParam, objective, obj_name)
                else
                    objective.failed = L_ObjectiveCheckConditions(objective.failureConditions)
                end
                if objective.failed then
                    if objective.failActionParam then
                        L_ObjectiveProcessActions(objective.failActions, objective.failActionParam, objective, obj_name)
                    else
                        L_ObjectiveProcessActions(objective.failActions)
                    end
                    if objective.stopOnFailed then
                        objectiveProcessingDone = true
                        break
                    end
                end
            end
        end
    end
    if allObjectivesMet then
        objectiveProcessingDone = true
    end
end

function T_ObjectiveMonitor()
    while not objectiveProcessingDone do
        F_ObjectiveMonitor()
        Wait(0)
    end
    collectgarbage()
end

function L_ObjectiveProcessingDone()
    return objectiveProcessingDone
end

function L_WaitUntilObjectiveProcessingDone()
    while not objectiveProcessingDone do
        Wait(0)
    end
end

function L_ObjectiveActivatorProcessed(objective)
    if objective.activator == nil then
        return true
    else
        for i, dependant in objective.activator do
            if not objectives[dependant].failed and not objectives[dependant].completed then
                return false
            end
        end
        return true
    end
end

function L_ObjectiveKillerProcessed(objective)
    if objective.killer == nil then
        return false
    else
        for i, dependant in objective.killer do
            if not objectives[dependant].failed and not objectives[dependant].completed then
                return false
            end
        end
        return true
    end
end

function L_ObjectiveReset(param, objective)
    objective.failed = false
    objective.completed = false
    if objective.activator then
        for i, obj_name in objective.activator do
            objectives[obj_name].failed = false
            objectives[obj_name].completed = false
        end
    end
    if objective.killer then
        for i, obj_name in objective.killer do
            objectives[obj_name].failed = false
            objectives[obj_name].completed = false
        end
    end
end

function L_ObjectiveLogCleanup()
    if objectives then
        for i, objective in objectives do
            local logID = objective.logID
            if logID then
                MissionObjectiveRemove(logID)
                objective.logID = nil
            end
        end
    end
end

function L_ObjectiveCleanup()
    L_ObjectiveLogCleanup()
    objectives = nil
    objectiveDefault = nil
    collectgarbage()
end
