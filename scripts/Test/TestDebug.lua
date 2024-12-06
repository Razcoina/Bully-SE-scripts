function F_Option1()
	TextPrintString("Executing Option 1", 4, 1)
end

function F_Option2()
	TextPrintString("Executing Option 2", 4, 1)
end

function F_Option3()
	TextPrintString("Executing Option 3", 4, 1)
end

function F_Option4()
	TextPrintString("Executing Option 4", 4, 1)
end

local gFunctionTable = {
	{ str = "Option1", gFunc = F_Option1 },
	{ str = "Option2", gFunc = F_Option2 },
	{ str = "Option3", gFunc = F_Option3 },
	{ str = "Option4", gFunc = F_Option4 }
}
local gCurrentOption = 1
local gOptionExecuted = false
local gSwitchPresed = false

function MissionSetup()
end

function MissionCleanup()
end

function main()
	while true do
		Wait(0)
		if IsButtonPressed(12, 0) then
			if not gSwitchPresed then
				if IsButtonPressed(0, 0) then
					gCurrentOption = gCurrentOption + 1
					if gCurrentOption > table.getn(gFunctionTable) then
						gCurrentOption = 1
					end
					TextPrintString(gFunctionTable[gCurrentOption].str, 4, 2)
					gSwitchPresed = true
				elseif IsButtonPressed(1, 0) then
					gCurrentOption = gCurrentOption - 1
					if gCurrentOption <= 0 then
						gCurrentOption = table.getn(gFunctionTable)
					end
					TextPrintString(gFunctionTable[gCurrentOption].str, 4, 2)
					gSwitchPresed = true
				end
			elseif not IsButtonPressed(0, 0) and not IsButtonPressed(1, 0) then
				gSwitchPresed = false
			end
			if not gOptionExecuted then
				if IsButtonPressed(9, 0) then
					break
				elseif IsButtonPressed(3, 0) then
					gFunctionTable[gCurrentOption].gFunc()
					gOptionExecuted = true
				end
			elseif not IsButtonPressed(9, 0) and not IsButtonPressed(3, 0) then
				gOptionExecuted = false
			end
		end
	end
	MissionSucceed()
end
