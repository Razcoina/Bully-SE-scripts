local gFunctionTable = {}
local gCurrentOption = 1
local gOptionExecuted = false
local gSwitchPresed = false
local gNISMode = false

function T_NISDebug()
	while MissionActive() do
		Wait(0)
		if not gNISMode then
			if IsButtonPressed(6, 1) then
				gNISMode = true
				gSwitchPresed = true
				TextPrintString("Entering NIS Mode.", 4, 1)
			end
		else
			F_NISDebug()
		end
	end
	gFunctionTable = {}
	collectgarbage()
end

function F_RegisterFunction(strRef, funcRef)
	table.insert(gFunctionTable, { str = strRef, gFunc = funcRef })
end

function F_NISDebug()
	if not gSwitchPresed and IsButtonPressed(11, 1) then
		gCurrentOption = gCurrentOption + 1
		if gCurrentOption > table.getn(gFunctionTable) then
			gCurrentOption = 1
		end
		TextPrintString(gFunctionTable[gCurrentOption].str, 4, 2)
		gSwitchPresed = true
	elseif not gSwitchPresed and IsButtonPressed(13, 1) then
		gCurrentOption = gCurrentOption - 1
		if gCurrentOption <= 0 then
			gCurrentOption = table.getn(gFunctionTable)
		end
		TextPrintString(gFunctionTable[gCurrentOption].str, 4, 2)
		gSwitchPresed = true
	elseif IsButtonPressed(8, 0) then
		Wait(200)
		TextPrint("Entering camera tweak mode.", 4, 1)
		Wait(200)
		F_CameraTweak()
	elseif not gSwitchPresed and IsButtonPressed(6, 1) then
		gFunctionTable[gCurrentOption].gFunc()
		gSwitchPresed = true
	elseif gSwitchPresed and not IsButtonPressed(11, 1) and not IsButtonPressed(13, 1) and not IsButtonPressed(8, 1) and not IsButtonPressed(6, 1) then
		gSwitchPresed = false
	end
end
