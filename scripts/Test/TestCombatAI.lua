local gCurrentMenu = 1
local gFTPed
local gForceGivenCombatZone = false

function F_APOExitCondition()
	if gFTPed ~= nil then
		PedClearObjectives(gFTPed)
		PedAttack(gFTPed, gPlayer, 0)
	end
end

function F_APORemember()
	if gFTPed ~= nil then
		PedClearObjectives(gFTPed)
		PedAttack(gFTPed, gPlayer, 1)
	end
end

function F_APOLockExitConditions()
	if gFTPed ~= nil then
		PedClearObjectives(gFTPed)
		PedAttack(gFTPed, gPlayer, 2)
	end
end

function F_APOLock()
	if gFTPed ~= nil then
		PedClearObjectives(gFTPed)
		PedAttack(gFTPed, gPlayer, 3)
	end
end

local gAttackObjectiveTable = {
	{
		str = "Attack Player with Exit Conditions",
		func = F_APOExitCondition
	},
	{
		str = "Attack Player Remember",
		func = F_APORemember
	},
	{
		str = "Attack Player Lock Exit Conditions",
		func = F_APOLockExitConditions
	},
	{
		str = "Attack Player Lock",
		func = F_APOLock
	}
}

function F_FCZ()
	gForceGivenCombatZone = not gForceGivenCombatZone
	if not gForceGivenCombatZone and gFTPed ~= nil then
		PedSetCombatZoneMask(gFTPed, true, true, true)
	end
end

function F_JPCZAny()
	if gFTPed ~= nil then
		PedSetCombatZoneMask(gFTPed, true, true, true)
		if PedJoinCombatZone(gFTPed, gPlayer, 4) then
			--DebugPrint("Successfully Joined Combat Zone")
		end
	end
end

function F_JPCZShort()
	if gFTPed ~= nil then
		if gForceGivenCombatZone then
			PedSetCombatZoneMask(gFTPed, true, false, false)
		end
		if PedJoinCombatZone(gFTPed, gPlayer, 0) then
			--DebugPrint("Successfully Joined Combat Zone")
		end
	end
end

function F_JPCZMedium()
	if gFTPed ~= nil then
		if gForceGivenCombatZone then
			PedSetCombatZoneMask(gFTPed, false, true, false)
		end
		if PedJoinCombatZone(gFTPed, gPlayer, 1) then
			--DebugPrint("Successfully Joined Combat Zone")
		end
	end
end

function F_JPCZLong()
	if gFTPed ~= nil then
		if gForceGivenCombatZone then
			PedSetCombatZoneMask(gFTPed, false, false, true)
		end
		if PedJoinCombatZone(gFTPed, gPlayer, 2) then
			--DebugPrint("Successfully Joined Combat Zone")
		end
	end
end

function F_LPCZ()
	if gFTPed ~= nil and PedLeaveCombatZone(gFTPed) then
		--DebugPrint("Ped Told to Leave Combat Zone")
	end
end

local gCombatZoneTable = {
	{
		str = "Join Player's Combat Zone",
		func = F_JPCZAny
	},
	{
		str = "Join Player's Short Combat Zone",
		func = F_JPCZShort
	},
	{
		str = "Join Player's Medium Combat Zone",
		func = F_JPCZMedium
	},
	{
		str = "Join Player's Long Combat Zone",
		func = F_JPCZLong
	},
	{
		str = "Leave Player's Combat Zone",
		func = F_LPCZ
	}
}

function F_ClearObjectives()
	if gFTPed ~= nil then
		PedClearObjectives(gFTPed)
	end
end

local gMenuTable = {
	{
		str = "Set Attack Objective",
		currentmenu = 1,
		ftable = gAttackObjectiveTable,
		func = nil
	},
	{
		str = "Force Combat Zone",
		currentmenu = 1,
		ftable = nil,
		func = F_FCZ
	},
	{
		str = "Change Combat Zone",
		currentmenu = 1,
		ftable = gCombatZoneTable,
		func = nil
	},
	{
		str = "Clear Objectives",
		currentmenu = 0,
		ftable = nil,
		func = F_ClearObjectives
	}
}

function MissionSetup()
	DATLoad("TFIGHT01.DAT", 2)
	DATInit()
	AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	local finished = false
	while not finished do
		Wait(0)
		if 0 <= shared.g_currentCreatedPed then
			gFTPed = shared.PedLineupTable[shared.g_currentCreatedPed].handle
		else
			gFTPed = nil
		end
		if IsButtonPressed(11, 0) then
			TextPrintString(gMenuTable[gCurrentMenu].str, 2, 1)
			if IsButtonPressed(2, 0) then
				gCurrentMenu = gCurrentMenu - 1
				if gCurrentMenu <= 0 then
					gCurrentMenu = table.getn(gMenuTable)
				end
				Wait(200)
			elseif IsButtonPressed(3, 0) then
				gCurrentMenu = gCurrentMenu + 1
				if gCurrentMenu > table.getn(gMenuTable) then
					gCurrentMenu = 1
				end
				Wait(200)
			end
			if gMenuTable[gCurrentMenu].ftable ~= nil then
				TextPrintString("Hit ~x~ to Execute: " .. gMenuTable[gCurrentMenu].ftable[gMenuTable[gCurrentMenu].currentmenu].str, 2, 2)
				if IsButtonPressed(0, 0) then
					gMenuTable[gCurrentMenu].currentmenu = gMenuTable[gCurrentMenu].currentmenu - 1
					if 0 >= gMenuTable[gCurrentMenu].currentmenu then
						gMenuTable[gCurrentMenu].currentmenu = table.getn(gMenuTable[gCurrentMenu].ftable)
					end
					Wait(200)
				elseif IsButtonPressed(1, 0) then
					gMenuTable[gCurrentMenu].currentmenu = gMenuTable[gCurrentMenu].currentmenu + 1
					if gMenuTable[gCurrentMenu].currentmenu > table.getn(gMenuTable[gCurrentMenu].ftable) then
						gMenuTable[gCurrentMenu].currentmenu = 1
					end
					Wait(200)
				elseif IsButtonPressed(7, 0) then
					gMenuTable[gCurrentMenu].ftable[gMenuTable[gCurrentMenu].currentmenu].func()
					TextPrintString("Executed: " .. gMenuTable[gCurrentMenu].ftable[gMenuTable[gCurrentMenu].currentmenu].str, 4, 1)
					Wait(1000)
				end
			else
				TextPrintString("Hit ~x~ to Execute", 2, 2)
				if IsButtonPressed(7, 0) then
					gMenuTable[gCurrentMenu].func()
					TextPrintString("Executed: " .. gMenuTable[gCurrentMenu].str, 4, 1)
					Wait(1000)
				end
			end
		end
	end
	MissionSucceed()
end
