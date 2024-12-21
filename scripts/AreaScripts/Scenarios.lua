--[[ Changes to this file:
	* Modified function F_CheckConditions, may require testing
]]

local ZONE_SCHOOL = {}
local ZONE_BUSINESS = {}
local ZONE_RICH = {}
local ZONE_POOR = {}
local ZONE_INDUSTRIAL = {}
local ZONE_INTERIOR = {}
local ZONE_BOYSDORM = {}
local ZONE_SCHOOLHALLWAYS = {}
local ZONE_POOLANDGYM = {}
local ZONE_BMXPARK = {}
local ZONE_TEST = {}
ZONE_TEST = {}
ZONE_INTERIOR = {}
ZONE_BMXPARK = {}
ZONE_POOLANDGYM = {}
ZONE_BOYSDORM = {}
ZONE_SCHOOL = {
	{
		name = "scenario_EggBDorm",
		script = "EggBDorm",
		missionreq = "2_03",
		repeatable = false,
		enum = 13
	},
	{
		name = "scenario_EggGDorm",
		script = "EggGDorm",
		missionreq = "2_03",
		repeatable = false,
		enum = 14
	},
	{
		name = "scenario_TakeMeHome",
		script = "TakeMeHome",
		missionreq = "1_07",
		repeatable = false,
		enum = 45
	},
	{
		name = "scenario_Canning",
		script = "Canning",
		missionreq = "1_B",
		repeatable = false,
		enum = 6
	}
}
ZONE_SCHOOLHALLWAYS = {
	{
		name = "scenario_AlgieEscort",
		script = "AlgieEscort",
		missionreq = "1_05",
		repeatable = false,
		enum = 1
	},
	{
		name = "scenario_BogRoll",
		script = "BogRoll",
		missionreq = "1_B",
		repeatable = false,
		enum = 2
	},
	{
		name = "scenario_BogRoll2",
		script = "BogRoll2",
		missionreq = "2_B",
		repeatable = false,
		enum = 3,
		prereq = 2
	},
	{
		name = "scenario_CherryToilet",
		script = "CherryToilet",
		missionreq = "2_B",
		repeatable = false,
		enum = 8
	},
	{
		name = "scenario_FireAlarm",
		script = "FireAlarm",
		missionreq = "1_07",
		repeatable = false,
		enum = 19
	},
	{
		name = "scenario_Lockered",
		script = "Lockered",
		missionreq = "1_B",
		repeatable = false,
		enum = 23
	},
	{
		name = "scenario_PickIt",
		script = "PickIt",
		missionreq = "1_07",
		repeatable = false,
		enum = 29
	},
	{
		name = "scenario_SecretAdmirer",
		script = "SecretAdmirer",
		missionreq = "1_07",
		repeatable = false,
		enum = 33
	},
	{
		name = "scenario_SecretAdmirer2",
		script = "SecretAdmirer2",
		missionreq = "1_07",
		repeatable = false,
		enum = 34
	}
}
ZONE_INDUSTRIAL = {
	{
		name = "scenario_LostCargo",
		script = "LostCargo",
		missionreq = "4_B2",
		repeatable = false,
		enum = 25
	},
	{
		name = "scenario_SmashCar",
		script = "SmashCar",
		missionreq = "5_B",
		repeatable = false,
		enum = 37
	},
	{
		name = "scenario_CrazyFarm",
		script = "CrazyFarm",
		missionreq = "4_B2",
		repeatable = false,
		enum = 10
	},
	{
		name = "scenario_ShippingReceiving",
		script = "ShippingReceiving",
		missionreq = "4_B2",
		repeatable = false,
		enum = 35
	},
	{
		name = "scenario_RatKiller",
		script = "RatKiller",
		missionreq = "4_B2",
		repeatable = false,
		enum = 31
	},
	{
		name = "scenario_EggGreaser",
		script = "EggGreaser",
		missionreq = "5_B",
		repeatable = false,
		enum = 15
	},
	{
		name = "scenario_CableGuy",
		script = "CableGuy",
		missionreq = "4_B2",
		repeatable = false,
		enum = 5
	}
}
ZONE_BUSINESS = {
	{
		name = "scenario_DetectiveJimmy",
		script = "DetectiveJimmy",
		missionreq = "3_B",
		repeatable = false,
		enum = 11
	},
	{
		name = "scenario_Algie1",
		script = "Algie1",
		missionreq = "2_B",
		repeatable = false,
		enum = 0
	},
	{
		name = "scenario_PrankB",
		script = "PrankB",
		missionreq = "1_B",
		repeatable = false,
		enum = 30
	},
	{
		name = "scenario_SmokeFree",
		script = "SmokeFree",
		missionreq = "1_B",
		repeatable = false,
		enum = 39
	},
	{
		name = "scenario_EasyDrugs",
		script = "EasyDrugs",
		missionreq = "1_B",
		repeatable = false,
		enum = 12
	},
	{
		name = "scenario_LostDog",
		script = "LostDog",
		missionreq = "1_B",
		repeatable = false,
		enum = 26
	},
	{
		name = "scenario_LostDog2",
		script = "LostDog2",
		missionreq = "1_B",
		repeatable = false,
		enum = 27
	},
	{
		name = "scenario_BusGetBike",
		script = "BusGetBike",
		missionreq = "1_B",
		repeatable = false,
		enum = 4
	},
	{
		name = "scenario_StrangeHobo",
		script = "StrangeHobo",
		missionreq = "2_B",
		repeatable = false,
		enum = 41
	}
}
ZONE_RICH = {
	{
		name = "scenario_FastFood",
		script = "FastFood",
		missionreq = "1_B",
		repeatable = false,
		enum = 18
	},
	{
		name = "scenario_CrabTraps",
		script = "CrabTraps",
		missionreq = "1_B",
		repeatable = false,
		enum = 9
	},
	{
		name = "scenario_TheMailman",
		script = "TheMailman",
		missionreq = "2_B",
		repeatable = false,
		enum = 48
	},
	{
		name = "scenario_Shipwreaked",
		script = "ShipWreaked",
		missionreq = "1_B",
		repeatable = false,
		enum = 36
	},
	{
		name = "scenario_JumpMan",
		script = "JumpMan",
		missionreq = "1_B",
		repeatable = false,
		enum = 22
	},
	{
		name = "scenario_CarniePhoto",
		script = "CarniePhotographer",
		missionreq = "2_B",
		repeatable = false,
		enum = 7
	},
	{
		name = "scenario_TheWidow",
		script = "TheWidow",
		missionreq = "3_B",
		repeatable = false,
		enum = 49
	},
	{
		name = "scenario_Escapist",
		script = "Escapist",
		missionreq = "2_B",
		repeatable = false,
		enum = 17
	},
	{
		name = "scenario_TagRich",
		script = "TagRich",
		missionreq = "3_S10",
		repeatable = false,
		enum = 44
	},
	{
		name = "scenario_SwimIt",
		script = "SwimIt",
		missionreq = "1_B",
		repeatable = false,
		enum = 42
	},
	{
		name = "scenario_LostBear",
		script = "LostBear",
		missionreq = "1_B",
		repeatable = false,
		enum = 24
	},
	{
		name = "scenario_Pirate",
		script = "Pirate",
		missionreq = "1_B",
		repeatable = false,
		enum = -1
	}
}
ZONE_POOR = {
	{
		name = "scenario_SmashCarP",
		script = "SmashCarP",
		missionreq = "2_B",
		repeatable = false,
		enum = 38
	},
	{
		name = "scenario_EggPoorH",
		script = "EggPoorH",
		missionreq = "2_B",
		repeatable = false,
		enum = 16
	},
	{
		name = "scenario_SpazzDelivery",
		script = "SpazzDelivery",
		missionreq = "4_B2",
		repeatable = false,
		enum = 40
	},
	{
		name = "scenario_RatsOut",
		script = "RatsOut",
		missionreq = "3_B",
		repeatable = false,
		enum = 32
	},
	{
		name = "scenario_TagPoor",
		script = "TagPoor",
		missionreq = "3_05",
		repeatable = false,
		enum = 43
	},
	{
		name = "scenario_TheCheat",
		script = "TheCheat",
		missionreq = "2_B",
		repeatable = false,
		enum = 47
	},
	{
		name = "scenario_TenFires",
		script = "TenFires",
		missionreq = "3_B",
		repeatable = false,
		enum = 46
	},
	{
		name = "scenario_PhotoTag",
		script = "PhotoTag",
		missionreq = "3_S10",
		repeatable = false,
		enum = 28
	},
	{
		name = "scenario_GirlEscort",
		script = "GirlEscort",
		missionreq = "4_B2",
		repeatable = false,
		enum = 20
	},
	{
		name = "scenario_HomelessHelp",
		script = "HomelessHelp",
		missionreq = "3_05",
		repeatable = false,
		enum = 21
	}
}

function F_ScenarioManager(POIInfo)
	if IsMissionCompleated("1_E01") and not shared.gHalloweenActive and (not IsMissionCompleated("4_05") or not not IsMissionCompleated("4_06")) then
		if AreaGetVisible() == 0 then
			if PlayerIsInTrigger(TRIGGER._ZONESCHOOL) then
				for i, scenario in ZONE_SCHOOL do
					if AreaPOICompareName(POIInfo, scenario.name) then
						F_CheckConditions(scenario, POIInfo)
					end
				end
			elseif PlayerIsInTrigger(TRIGGER._ZONEBUSINESS) then
				for i, scenario in ZONE_BUSINESS do
					if AreaPOICompareName(POIInfo, scenario.name) then
						F_CheckConditions(scenario, POIInfo)
					end
				end
			elseif PlayerIsInTrigger(TRIGGER._ZONERICH) then
				for i, scenario in ZONE_RICH do
					if AreaPOICompareName(POIInfo, scenario.name) then
						F_CheckConditions(scenario, POIInfo)
					end
				end
			elseif PlayerIsInTrigger(TRIGGER._ZONEPOOR) then
				for i, scenario in ZONE_POOR do
					if AreaPOICompareName(POIInfo, scenario.name) then
						F_CheckConditions(scenario, POIInfo)
					end
				end
			elseif PlayerIsInTrigger(TRIGGER._ZONEINDUSTRIAL) then
				for i, scenario in ZONE_INDUSTRIAL do
					if AreaPOICompareName(POIInfo, scenario.name) then
						F_CheckConditions(scenario, POIInfo)
					end
				end
			end
		elseif AreaGetVisible() == 14 then
			for i, scenario in ZONE_BOYSDORM do
				if AreaPOICompareName(POIInfo, scenario.name) then
					F_CheckConditions(scenario, POIInfo)
				end
			end
		elseif AreaGetVisible() == 2 then
			for i, scenario in ZONE_SCHOOLHALLWAYS do
				if AreaPOICompareName(POIInfo, scenario.name) then
					F_CheckConditions(scenario, POIInfo)
				end
			end
		elseif AreaGetVisible() == 13 then
			for i, scenario in ZONE_POOLANDGYM do
				if AreaPOICompareName(POIInfo, scenario.name) then
					F_CheckConditions(scenario, POIInfo)
				end
			end
		elseif AreaGetVisible() == 62 then
			for i, scenario in ZONE_BMXPARK do
				if AreaPOICompareName(POIInfo, scenario.name) then
					F_CheckConditions(scenario, POIInfo)
				end
			end
		elseif AreaGetVisible() ~= 62 and AreaGetVisible() ~= 14 and AreaGetVisible() ~= 2 and AreaGetVisible() ~= 13 then
			--print("======= Interior Table Check =====")
			for i, scenario in ZONE_INTERIOR do
				if AreaPOICompareName(POIInfo, scenario.name) then
					F_CheckConditions(scenario, POIInfo)
				end
			end
		end
		if shared.gCurrentAmbientScenarioObject == nil then
			shared.gCurrentAmbientScenario = nil
			shared.bCleanUpErrand = false
		end
	elseif bDebugErrands then
		for i, scenario in ZONE_TEST do
			if AreaPOICompareName(POIInfo, scenario.name) then
				F_DebugScenarios(scenario, POIInfo)
			end
		end
	end
end

function F_CheckConditions(scenario, POIInfo) -- ! Modified
	local bRepeatable = scenario.repeatable ~= nil and scenario.repeatable == true
	local bCompleted = false
	local bMissionOnOff = scenario.missionoff ~= nil and scenario.completed == true
	local bPrereqCompleted = true
	local bMissoinOnOffCompleted = scenario.missionoff ~= nil and IsMissionCompleated(scenario.missionoff)
	local bScheduled = scenario.time == nil or scenario.time ~= nil and GetTimer() > scenario.time
	if scenario.enum == -1 then
		--[[
		if MiniObjectiveGetIsComplete(15) then
		]] -- Changed to:
		if MiniObjectiveGetIsComplete(16) then
			bCompleted = true
		end
	elseif MinigameGetErrandCompletion(scenario.enum) == 0 then
		bCompleted = false
	else
		bCompleted = true
	end
	if scenario.prereq ~= nil then
		--print("==== Requires a prereq =====")
		if 1 <= MinigameGetErrandCompletion(scenario.prereq) then
			bPrereqCompleted = true
			--print("==== prereq complete =====")
		else
			bPrereqCompleted = false
			--print("==== prereq not complete =====")
		end
	end
	if IsMissionCompleated(scenario.missionreq) and (bRepeatable and bPrereqCompleted or bRepeatable == false and bCompleted == false and bPrereqCompleted) and (bMissionOnOff == false or bMissoinOnOffCompleted == false) and shared.gAlarmOn == false and bScheduled then
		if StreamedScriptHasLoaded(scenario.script) == false then
			--print("Waiting for Scenario Name to load: " .. scenario.name)
			StreamedScriptRequest(scenario.script)
		else
			shared.gCurrentAmbientScenarioObject = scenario
			shared.gCurrentAmbientScenario = POIInfo
			--print("Scenario Name Has loaded and should launch: " .. scenario.name)
			StreamedScriptLaunch(scenario.script, true)
		end
	end
end

function F_DebugScenarios(scenario, POIInfo)
	local bCompleted = false
	if MinigameGetErrandCompletion(scenario.enum) == 0 then
		bCompleted = false
	else
		bCompleted = true
	end
	shared.gCurrentAmbientScenario = POIInfo
	shared.gCurrentAmbientScenarioObject = scenario
	--print("Waiting for Debugged Scenario Named to load: " .. scenario.name, tostring(bCompleted))
	if not bCompleted then
		LaunchScenarioScript(scenario.script)
	else
		shared.gCurrentAmbientScenarioObject = nil
		shared.gCurrentAmbientScenario = nil
	end
end
