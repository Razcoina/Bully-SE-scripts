local bMonitorTriggers = false
local triggerType = "_Trg"
local trgDefaultGroupName = "_dTr"

function L_AddTrigger(groupName, tblTriggerData)
	errorFuncName = "L_AddTrigger"
	local group = ValidateGroup(groupName, trgDefaultGroupName, triggerType)
	for i, trigger in tblTriggerData do
		--print("TEST: ", i, " TRIGGER: ", trigger)
		--assert(not (trigger.trigger or trigger.id) or trigger.ped or trigger.projectile, errorFuncName .. ": Missing trigger/ped or projectile for trigger: " .. i .. " group: " .. group)
		trigger.id = trigger.id or trigger.trigger
		trigger.trigger = trigger.trigger or trigger.id
		if trigger.projectile then
			trigger.numProjectile = ObjectNumProjectileImpacts(trigger.id, trigger.projectile)
		end
	end
	LT_Add(group, tblTriggerData, triggerType)
	LT_SetGroupData(group, "bInTrigger", false)
	LT_SetGroupData(group, "bChecked", false)
end

function F_MonitorTriggers(groupName)
	for i, group in LT_LibTable() do
		if LT_Type(i) == triggerType and (groupName == nil or groupName and i == groupName) then
			for j, trigger in group do
				if trigger.ped then
					if PedIsInTrigger(trigger.ped, trigger.trigger) then
						if not trigger.bChecked then
							if not trigger.bInTrigger then
								trigger.bInTrigger = true
								if trigger.OnEnter ~= nil then
									trigger.OnEnter(trigger)
								end
							elseif trigger.InTrigger ~= nil then
								trigger.InTrigger(trigger)
							end
						end
					elseif trigger.bInTrigger then
						trigger.bInTrigger = false
						if trigger.OnExit ~= nil then
							trigger.OnExit(trigger)
						end
						if trigger.bTriggerOnlyOnce then
							trigger.bChecked = true
						end
					end
				end
				if trigger.projectile then
					local impactCount = ObjectNumProjectileImpacts(trigger.id, trigger.projectile)
					if impactCount > trigger.numProjectile then
						trigger.numProjectile = impactCount
						if trigger.OnImpact then
							trigger.OnImpact(trigger)
						end
					end
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

function L_TriggerGetTrigger(triggerID)
	return LT_FindElement("trigger", triggerID, triggerType)
end

function L_TriggerSetData(triggerID, field, value)
	--assert(field ~= "trigger", "L_TriggerSetData: Don't try to modify the trigger ID directly !!!")
	--assert(field ~= "id", "L_TriggerSetData: Don't try to modify the trigger ID directly !!!")
	LT_SetData(pedID, field, value, pedType)
end
