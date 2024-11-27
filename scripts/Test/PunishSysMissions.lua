function MissionSetup()
end

function MissionCleanup()
end

function main()
	if shared.gPunishmentMissionDebug == 0 then
		shared.gPunishmentMissionDebug = 1
		TextPrintString("==>> Next Punishment Mission will be: Garbage Pickup!", 10, 1)
	end
	if ChapterGet() ~= 2 then
		shared.gPunishmentMissionDebug = shared.gPunishmentMissionDebug + 1
		if shared.gPunishmentMissionDebug > 3 then
			shared.gPunishmentMissionDebug = 1
		end
		if shared.gPunishmentMissionDebug == 1 then
			TextPrintString("==>> Next Punishment Mission will be: Garbage Pickup!", 10, 1)
		elseif shared.gPunishmentMissionDebug == 2 then
			TextPrintString("==>> Next Punishment Mission will be: Grafitti Cleanup!", 10, 1)
		elseif shared.gPunishmentMissionDebug == 3 then
			TextPrintString("==>> Next Punishment Mission will be: Lawnmower!", 10, 1)
		end
	elseif ChapterGet() == 2 then
		shared.gPunishmentMissionDebug = shared.gPunishmentMissionDebug + 1
		if shared.gPunishmentMissionDebug == 3 then
			shared.gPunishmentMissionDebug = 4
		elseif shared.gPunishmentMissionDebug > 4 then
			shared.gPunishmentMissionDebug = 1
		end
		if shared.gPunishmentMissionDebug == 1 then
			TextPrintString("==>> Next Punishment Mission will be: Garbage Pickup!", 10, 1)
		elseif shared.gPunishmentMissionDebug == 2 then
			TextPrintString("==>> Next Punishment Mission will be: Grafitti Cleanup!", 10, 1)
		elseif shared.gPunishmentMissionDebug == 4 then
			TextPrintString("==>> Next Punishment Mission will be: Snow Shoveling!", 10, 1)
		end
	end
	MissionSucceed()
end
