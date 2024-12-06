function MissionSetup()
end

function MissionCleanup()
end

function main()
	TextPrintString("Mission Success: " .. tostring(MissionGetCurrentName()) .. " not yet implemented.", 4, 1)
	--DebugPrint("******************************* " .. tostring(MissionGetCurrentName()) .. " completed")
	MissionSucceed()
end
