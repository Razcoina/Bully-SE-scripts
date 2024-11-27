ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibTrigger.lua")
ImportScript("Library/LibPropNew.lua")
local mission_started = false
local bReachedArea = false
local idFireBlip, idAreaTrigger
local intNumAreasChosen = 1
local intAreasSentTo = 0
local intChosenDifficulty = 0
local strChosenRegion = ""
local tblPrevAreas = {}
local tblRegions = {}
local tblFireProps = {}
local tblFireSettings = {}

function F_FiresOut()
	local i, tblEntry
	for i, tblEntry in tblFireProps do
		if tblEntry.idFire ~= nil and FireGetHealth(tblEntry.idFire) > 0 then
			return false
		end
	end
	if bReachedArea then
		if idFireBlip ~= nil then
			BlipRemove(idFireBlip)
			idFireBlip = nil
		end
		if intAreasSentTo < intNumAreasChosen then
			bReachedArea = false
			TextPrint("2_R04_12", 4, 1)
			F_ChooseArea()
		else
			return true
		end
	end
	return false
end

function F_MonitorObjects()
	local i, tblEntry
	for i, tblEntry in tblFireProps do
		if tblEntry.idFire ~= nil then
			if PAnimIsDestroyed(tblEntry.propTrigger) then
				return true
			elseif FireGetHealth(tblEntry.idFire) <= 0 then
				PAnimHideHealthBar(tblEntry.propTrigger)
			end
		end
	end
	return false
end

function F_CreateFires()
	local i, tblFireEntry, interval, damage, minHealth, maxHealth
	for i, tblFireEntry in tblFireProps do
		if tblFireEntry.regionTrigger == idAreaTrigger then
			interval, damage, minHealth, maxHealth = F_GetSettingsForModel(tblFireEntry.model)
			tblFireEntry.idFire = FireCreate(tblFireEntry.propTrigger, interval, damage, minHealth, maxHealth)
			PAnimShowHealthBar(tblFireEntry.propTrigger, false)
		end
	end
	if shared.g2SS07MissionState < 1 then
		TextPrint("2_R04_11", 4, 1)
	end
	bReachedArea = true
end

function F_GetSettingsForModel(strModel)
	local j, tblSettingEntry
	for j, tblSettingEntry in tblFireSettings do
		if tblSettingEntry.model == strModel then
			return tblSettingEntry.interval, tblSettingEntry.damage, tblSettingEntry.minHealth, tblSettingEntry.maxHealth
		end
	end
end

function F_FailMission()
	TextPrint("M_FAIL", 3, 1)
	SoundPlayMissionEndMusic(false, 10)
	MissionFail()
end

function F_CompleteMission()
	shared.g2SS07MissionState = shared.g2SS07MissionState + 1
	TextPrint("M_PASS", 3, 1)
	SoundPlayMissionEndMusic(true, 10)
	MissionSucceed()
end

function F_Intro()
	local idFireman = PedCreatePoint(82, POINTLIST._2_R04_CORONA)
	PedStop(idFireman)
	PedStartConversation("R04Conv", "Act\\Conv\\2_R04.act", gPlayer, idFireman)
	while PedInConversation(gPlayer) or PedInConversation(idFireman) do
		Wait(100)
	end
	Wait(100)
	PedDelete(idFireman)
end

function F_EvaluateDifficulty()
	if shared.g2SS07MissionState <= 2 then
		intChosenDifficulty = 0
		intNumAreasChosen = 1
	elseif shared.g2SS07MissionState <= 5 then
		intChosenDifficulty = 0
		intNumAreasChosen = 2
	elseif shared.g2SS07MissionState <= 10 then
		intChosenDifficulty = 0
		intNumAreasChosen = 3
	else
		intChosenDifficulty = 0
		intNumAreasChosen = 4
	end
end

function F_ResetProps(idTrigger)
	local i, tblEntry
	for i, tblEntry in tblFireProps do
		if tblEntry.regionTrigger == idTrigger then
			PAnimReset(tblEntry.propTrigger)
			PAnimHideHealthBar(tblEntry.propTrigger)
		end
	end
end

function F_CleanupProps()
	local i, tblEntry
	for i, tblEntry in tblFireProps do
		if tblEntry.idFire ~= nil then
			FireDestroy(tblEntry.idFire)
			tblEntry.idFire = nil
		end
		PAnimHideHealthBar(tblEntry.propTrigger)
		PAnimReset(tblEntry.propTrigger)
	end
end

function F_ChooseRegion()
	local bFoundRegion = false
	local intChosenRegion
	while not bFoundRegion do
		intChosenRegion = math.random(1, table.getn(tblRegions))
		if intChosenRegion ~= nil and tblRegions[intChosenRegion].difficulty <= intChosenDifficulty then
			strChosenRegion = tblRegions[intChosenRegion].id
			--DebugPrint("*************************************************** strChosen1 = " .. tostring(strChosenRegion))
			bFoundRegion = true
		end
	end
end

function F_DialogueGetRegion()
	--DebugPrint("******************************************************** strChosen = " .. tostring(strChosenRegion))
	if strChosenRegion == "Downtown" then
		return 0
	elseif strChosenRegion == "PoorHouse" then
		return 1
	end
	return 0
end

function F_ChooseArea()
	local i, tblEntry, idPoint
	for i, tblEntry in tblRegions do
		if tblEntry.id == strChosenRegion then
			idAreaTrigger, idPoint = F_GetUnusedArea(tblEntry.areas)
			L_AddTrigger(nil, {
				{
					trigger = idAreaTrigger,
					OnEnter = F_CreateFires,
					ped = gPlayer,
					bTriggerOnlyOnce = true
				}
			})
			local x, y, z = GetPointList(idPoint)
			idFireBlip = BlipAddXYZ(x, y, z, 1, RADARICON_FIRE)
			intAreasSentTo = intAreasSentTo + 1
			break
		end
	end
end

function F_GetUnusedArea(tblAreas)
	local i
	local bFoundArea = false
	while not bFoundArea do
		i = math.random(1, table.getn(tblAreas))
		if not F_IsAreaAlreadyUsed(tblAreas[i].trigger) then
			bFoundArea = true
			table.insert(tblPrevAreas, tblAreas[i].trigger)
			return tblAreas[i].trigger, tblAreas[i].point
		end
	end
end

function F_IsAreaAlreadyUsed(idAreaTrigger)
	local i, idPrevArea
	for i, idPrevArea in tblPrevAreas do
		if idPrevArea == idAreaTrigger then
			return true
		end
	end
	return false
end

function F_SetupFireData()
	tblRegions = {
		{
			id = "Downtown",
			difficulty = 0,
			areas = {
				{
					trigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_01,
					point = POINTLIST._2_R04_BUSINESS_FIRE_REGION_01
				},
				{
					trigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_02,
					point = POINTLIST._2_R04_BUSINESS_FIRE_REGION_02
				},
				{
					trigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_03,
					point = POINTLIST._2_R04_BUSINESS_FIRE_REGION_03
				},
				{
					trigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_04,
					point = POINTLIST._2_R04_BUSINESS_FIRE_REGION_04
				}
			}
		}
	}
	tblFireProps = {
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_01,
			propTrigger = TRIGGER._2_R04_NEWS_03,
			idFire = nil,
			model = "news",
			id = "1"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_01,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_BENCHA,
			idFire = nil,
			model = "benchb",
			id = "2"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_01,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_BENCHA01,
			idFire = nil,
			model = "benchb",
			id = "3"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_01,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_BENCHA02,
			idFire = nil,
			model = "benchb",
			id = "4"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_01,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_BENCHA03,
			idFire = nil,
			model = "benchb",
			id = "5"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_02,
			propTrigger = TRIGGER._TBUSINESS_FTSTAND01,
			idFire = nil,
			model = "fruitstand",
			id = "7"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_02,
			propTrigger = TRIGGER._2_R04_NEWS_01,
			idFire = nil,
			model = "news",
			id = "8"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_02,
			propTrigger = TRIGGER._2_R04_SIGN_01,
			idFire = nil,
			model = "sign",
			id = "9"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_02,
			propTrigger = TRIGGER._TBUSINESS_GARBCANA08,
			idFire = nil,
			model = "garbagecan",
			id = "10"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_03,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_DUMPSTER04,
			idFire = nil,
			model = "dumpster",
			id = "11"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_03,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_DUMPSTER05,
			idFire = nil,
			model = "dumpster",
			id = "12"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_03,
			propTrigger = TRIGGER._TBUSINESS_DUMPSTER09,
			idFire = nil,
			model = "dumpster",
			id = "13"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_03,
			propTrigger = TRIGGER._2_R04_CRATES_01,
			idFire = nil,
			model = "lgcrate",
			id = "14"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_03,
			propTrigger = TRIGGER._2_R04_CRATES_02,
			idFire = nil,
			model = "lgcrate",
			id = "15"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_03,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_CRATE21,
			idFire = nil,
			model = "crate",
			id = "16"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_04,
			propTrigger = TRIGGER._TBUSINESS_DUMPSTER06,
			idFire = nil,
			model = "dumpster",
			id = "17"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_04,
			propTrigger = TRIGGER._TBUSINESS_DUMPSTER07,
			idFire = nil,
			model = "dumpster",
			id = "18"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_04,
			propTrigger = TRIGGER._TBUSINESS_DUMPSTER08,
			idFire = nil,
			model = "dumpster",
			id = "19"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_04,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_GARBAGECAN06,
			idFire = nil,
			model = "garbagecan",
			id = "20"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_04,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_GARBAGECAN07,
			idFire = nil,
			model = "garbagecan",
			id = "21"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_04,
			propTrigger = TRIGGER._TBUSINESS_GARBCANA04,
			idFire = nil,
			model = "garbagecan",
			id = "22"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_04,
			propTrigger = TRIGGER._TBUSINESS_GARBCANA03,
			idFire = nil,
			model = "garbagecan",
			id = "23"
		},
		{
			regionTrigger = TRIGGER._2_R04_BUSINESS_FIRE_REGION_04,
			propTrigger = TRIGGER._ANIMPROPS_MAINMAP_CRATE18,
			idFire = nil,
			model = "crate",
			id = "24"
		}
	}
	tblFireSettings = {
		{
			model = "news",
			interval = 15000,
			damage = 15,
			minHealth = 20,
			maxHealth = 100
		},
		{
			model = "dumpster",
			interval = 15000,
			damage = 12,
			minHealth = 20,
			maxHealth = 100
		},
		{
			model = "sign",
			interval = 30000,
			damage = 1,
			minHealth = 20,
			maxHealth = 100
		},
		{
			model = "lgcrate",
			interval = 5000,
			damage = 1,
			minHealth = 20,
			maxHealth = 100
		},
		{
			model = "garbagecan",
			interval = 15000,
			damage = 5,
			minHealth = 20,
			maxHealth = 100
		},
		{
			model = "benchb",
			interval = 15000,
			damage = 15,
			minHealth = 20,
			maxHealth = 100
		},
		{
			model = "crate",
			interval = 45000,
			damage = 1,
			minHealth = 20,
			maxHealth = 100
		},
		{
			model = "fruitstand",
			interval = 15000,
			damage = 10,
			minHealth = 20,
			maxHealth = 100
		}
	}
end

function F_AreaTrans()
	AreaTransitionPoint(0, POINTLIST._2_R04_PSTART)
end

function MissionSetup()
	DATLoad("2_R04.DAT", 2)
	DATInit()
	WeaponRequestModel(326)
	F_AreaTrans()
	L_ObjectiveSetParam({
		objPutOutFires = {
			successConditions = { F_FiresOut },
			failureConditions = { F_MonitorObjects },
			stopOnFailed = true,
			stopOnCompleted = true,
			failActions = { F_FailMission },
			completeActions = { F_CompleteMission }
		}
	})
	mission_started = true
end

function MissionCleanup()
	F_CleanupProps()
	if idFireBlip ~= nil then
		BlipRemove(idFireBlip)
		idFireBlip = nil
	end
	DATUnload(2)
	DATInit()
	CameraSetWidescreen(false)
	mission_started = false
end

function main()
	if mission_started then
		F_SetupFireData()
		if strChosenRegion == "" then
			F_ChooseRegion()
		end
		F_EvaluateDifficulty()
		F_ChooseArea()
		if not IsMissionFromRestart() then
			F_Intro()
		end
		PlayerSetWeapon(326, 0)
		TextPrint("2_R04_10", 4, 1)
		if 1 > shared.g2SS07MissionState then
			PlayerSetControl(0)
			Wait(4000)
			TextPrint("2_R04_11", 4, 1)
			PlayerSetControl(1)
		end
		CreateThread("T_ObjectiveMonitor")
		CreateThread("L_MonitorTriggers")
		while not L_ObjectiveProcessingDone() do
			Wait(100)
		end
	else
		Wait(100)
	end
end
