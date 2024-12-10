--[[ Changes to this file:
	* Modified function F_SetupMissionRequirements, may require testing
]]

function F_SetupMissionRequirements(missionId) -- ! Modified
	--DebugPrint("Setting Up Mission Requirements For Mission: " .. missionId)

	if missionId == MissionGetIndex("1_01") then
		shared.bCrateStateSetup = false
	end
	if missionId == MissionGetIndex("1_02A") then
		shared.lockClothingManager = false
		shared.cm_lockHead = false
		shared.cm_lockTorso = false
		shared.cm_lockLWrist = false
		shared.cm_lockRWrist = false
		shared.cm_lockLegs = false
		shared.cm_lockFeet = false
	elseif missionId == MissionGetIndex("1_02C") then
		UnpauseGameClock()
		--print("==========> PASSING MISSION 1_02C")
		if not shared.bCrateStateSetup then
			ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBox")
			ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrate")
			ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrate")
			DATLoad("Pickups.DAT", 1)
			shared.bCrateStateSetup = true
			--print("==========> shared.bCrateStateSetup 1_02C")
		end
		F_SetRestartPoints()
	elseif missionId == MissionGetIndex("1_03") and not IsMissionCompleated("1_09") then
		if ItemGetCurrentNum(303) == 0 then
			GiveWeaponToPlayer(303)
		end
	elseif missionId == MissionGetIndex("C_Photography_2") then
		HUDPhotographySetSaveLevel1(true)
	elseif missionId == MissionGetIndex("C_Photography_1") then
		HUDPhotographySetSaveLevel2(true)
	elseif missionId == MissionGetIndex("C_Photography_3") then
		HUDPhotographySetColourUpgrade(true)
	elseif missionId == MissionGetIndex("1_S01") then
		if not PlayerHasItem(328) then
			GiveWeaponToPlayer(328)
		end
	elseif missionId == MissionGetIndex("1_06_01") then
		if IsMissionCompleated("1_05") and not IsMissionCompleated("1_11_Dummy") then
			AreaLoadSpecialEntities("Halloween1", true)
			AreaEnsureSpecialEntitiesAreCreated()
		end
		CollectiblesSetTypeAvailable(1, true)
	elseif missionId == MissionGetIndex("1_07") then
		GiveWeaponToPlayer(437, false)
		MissionForceCompleted("1_E01")
		MissionSuccessCountInc("1_E01")
	elseif missionId == MissionGetIndex("1_08") then
		if ItemGetCurrentNum(309) == 0 then
			GiveAmmoToPlayer(309, 5)
		end
	elseif missionId == MissionGetIndex("1_09") then
		if ItemGetCurrentNum(306) == 0 then
			GiveWeaponToPlayer(306)
		end
		if IsMissionCompleated("1_09") and not IsMissionCompleated("1_11_Dummy") then
			shared.g1_09JustFinished = true
			AreaLoadSpecialEntities("Halloween2", true)
			--print("========== Halloween should have turned off the clock, 1.09 complete =====")
		end
	elseif missionId == MissionGetIndex("1_11x1") then
		--print("========== Checking 1_11x1 =====")
		if IsMissionCompleated("1_09") and not IsMissionCompleated("1_11_Dummy") then
			AreaLoadSpecialEntities("Halloween2", true)
			AreaEnsureSpecialEntitiesAreCreated()
			shared.g1_09JustFinished = true
			--print("========== Halloween should have turned off the clock, 1_11x1 complete =====")
		end
		if ItemGetCurrentNum(394) == 0 then
			GiveAmmoToPlayer(394, 5)
			GiveAmmoToPlayer(397, 5)
		end
	elseif missionId == MissionGetIndex("1_11xp") then
		if IsMissionCompleated("1_11x1") and not IsMissionCompleated("1_11_Dummy") then
			AreaLoadSpecialEntities("Halloween2", true)
			AreaLoadSpecialEntities("Halloween3", true)
			AreaEnsureSpecialEntitiesAreCreated()
		end
		shared.g1_11XpJustFinished = true
	elseif missionId == MissionGetIndex("1_11_Dummy") then
		ClothingGivePlayerOutfit("Halloween")
		AreaLoadSpecialEntities("Halloween1", false)
		AreaLoadSpecialEntities("Halloween2", false)
		AreaLoadSpecialEntities("Halloween3", false)
		AreaEnsureSpecialEntitiesAreCreated()
	elseif missionId == MissionGetIndex("2_01") then
		if ItemGetCurrentNum(312) == 0 then
			GiveAmmoToPlayer(312, 5)
		end
	elseif missionId == MissionGetIndex("2_03") then
		if not ClothingPlayerOwns("R_Sweater1", 1) then
			ClothingGivePlayer("R_Sweater1", 1, false)
		end
	elseif missionId == MissionGetIndex("2_S06") then
		DebugMissionPassDependant("Chapt1Trans")
	elseif missionId == MissionGetIndex("3_04") then
		if ItemGetCurrentNum(307) == 0 then
			GiveWeaponToPlayer(307)
		end
	elseif missionId == MissionGetIndex("3_S10") then
		--print("==========> PASSING MISSION 3S10")
		if not shared.bCrateStateSetup then
			ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBoxSprayCan")
			ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateSprayCan")
			ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateSprayCan")
			shared.bCrateStateSetup = true
			--print("==========> shared.bCrateStateSetup 3_S10")
		end
		if ItemGetCurrentNum(321) == 0 then
			GiveAmmoToPlayer(321, 10)
		end
	elseif missionId == MissionGetIndex("3_08_PostDummy") then
		ClothingGivePlayer("SP_XmsSweater", 1)
		AreaLoadSpecialEntities("Christmas", false)
		AreaEnsureSpecialEntitiesAreCreated()
	elseif missionId == MissionGetIndex("1_B") then
		shared.addBusPoints = true
		if 1 >= ChapterGet() then
			ChapterSet(1)
			MissionForceCompleted("1_11x2")
			MissionSuccessCountInc("1_11x2")
		end
		MissionForceCompleted("C_Chem_1")
		MissionSuccessCountInc("C_Chem_1")
		MissionForceCompleted("C_Art_1")
		MissionSuccessCountInc("C_Art_1")
		MissionForceCompleted("Art1X")
		MissionSuccessCountInc("Art1X")
		MissionForceCompleted("C_Wrestling_1")
		MissionSuccessCountInc("C_Wrestling_1")
		MissionForceCompleted("C_English_1")
		MissionSuccessCountInc("C_English_1")
		--[[
		MissionForceCompleted("1_06_02")
		MissionSuccessCountInc("1_06_02")
		]] -- Removed this
		shared.updateDefaultKOPoint = true
	elseif missionId == MissionGetIndex("2_B") then
		if ChapterGet() <= 2 then
			--print("Setting chapter to 3!")
			ChapterSet(2)
			if not IsMissionCompleated("3_08") then
				--print("Passed Chapter 2, starting Christmas")
				AreaLoadSpecialEntities("Christmas", true)
				AreaEnsureSpecialEntitiesAreCreated()
			end
		end
		MissionForceCompleted("C_Chem_2")
		MissionSuccessCountInc("C_Chem_2")
		MissionForceCompleted("C_Art_2")
		MissionSuccessCountInc("C_Art_2")
		MissionForceCompleted("C_Wrestling_2")
		MissionSuccessCountInc("C_Wrestling_2")
		MissionForceCompleted("C_English_2")
		MissionSuccessCountInc("C_English_2")
		--[[
		MissionForceCompleted("1_06_03")
		MissionSuccessCountInc("1_06_03")
		MissionForceCompleted("1_06_04")
		MissionSuccessCountInc("1_06_04")
		]] -- Removed this
		MissionForceCompleted("C_Photography_2")
		MissionSuccessCountInc("C_Photography_2")
		MissionForceCompleted("C_Photography_1")
		MissionSuccessCountInc("C_Photography_1")
		HUDPhotographySetSaveLevel1(true)
		HUDPhotographySetSaveLevel2(true)
	elseif missionId == MissionGetIndex("3_B") then
		if ChapterGet() <= 3 then
			AreaLoadSpecialEntities("Christmas", false)
			--print("Setting chapter to 4!")
			ChapterSet(3)
		end
		MissionForceCompleted("C_Chem_3")
		MissionSuccessCountInc("C_Chem_3")
		MissionForceCompleted("C_Art_3")
		MissionSuccessCountInc("C_Art_3")
		MissionForceCompleted("C_Wrestling_3")
		MissionSuccessCountInc("C_Wrestling_3")
		MissionForceCompleted("C_English_3")
		MissionSuccessCountInc("C_English_3")
		--[[
		MissionForceCompleted("1_06_07")
		MissionSuccessCountInc("1_06_07")
		]] -- Removed this
		MissionForceCompleted("C_Photography_3")
		MissionSuccessCountInc("C_Photography_3")
		HUDPhotographySetColourUpgrade(true)
	elseif missionId == MissionGetIndex("4_02") then
		--print("Passed 4_02, unlocking spud gun")
		if ItemGetCurrentNum(305) == 0 then
			GiveWeaponToPlayer(305)
		end
	elseif missionId == MissionGetIndex("4_B1") then
		if not shared.bCrateStateSetup then
			ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBoxSprayCan")
			ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateBRockets")
			ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateBRockets")
			shared.bCrateStateSetup = true
			--print("==========> shared.bCrateStateSetup 4_B1")
		end
		MissionForceCompleted("C_Photography_4")
		MissionSuccessCountInc("C_Photography_4")
		--print("==========> PASSING MISSION 4B1")
	elseif missionId == MissionGetIndex("4_B2") then
		--print("==========> PASSING MISSION 4B2")
		MissionForceCompleted("C_Chem_4")
		MissionSuccessCountInc("C_Chem_4")
		MissionForceCompleted("C_Art_4")
		MissionSuccessCountInc("C_Art_4")
		MissionForceCompleted("C_Wrestling_4")
		MissionSuccessCountInc("C_Wrestling_4")
		MissionForceCompleted("C_English_4")
		MissionSuccessCountInc("C_English_4")
		--[[
		MissionForceCompleted("1_06_08")
		MissionSuccessCountInc("1_06_08")
		]] -- Removed this
		MissionForceCompleted("C_Photography_5")
		MissionSuccessCountInc("C_Photography_5")
		if not shared.indusrtialRestartPointsAdded then
			AddKORestartPoint(POINTLIST._RESTART_I_HS, 0)
			AddKORestartPoint(POINTLIST._RESTART_I_HS, 0)
			AddArrestRestartPoint(POINTLIST._RESTART_I_PS, 0, 8, 18)
			AddArrestRestartPoint(POINTLIST._RESTART_I_PS, 0, 18, 8, POINTLIST._BOYSDORM_BEDWAKEUP, 14)
			local industrialAreaInteriors = {
				20,
				16,
				54
			}
			for i, lArea in industrialAreaInteriors do
				AddInteriorKORestartPoint(lArea, POINTLIST._RESTART_I_HS, 0)
				AddInteriorArrestRestartPoint(lArea, POINTLIST._RESTART_I_PS, 0)
				AddInteriorAsleepRestartPoint(lArea, POINTLIST._RESTART_I_HS, 0)
			end
			SetKORestartPointCameraPos(POINTLIST._RESTART_I_HS, POINTLIST._RESTART_I_HS_CAM)
			SetArrestRestartPointCameraPos(POINTLIST._RESTART_I_PS, POINTLIST._RESTART_I_PS_CAM)
			shared.indusrtialRestartPointsAdded = true
		end
	elseif missionId == MissionGetIndex("4_03") then
		if not shared.bCrateStateSetup then
			ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBoxSprayCan")
			ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateSpudGuns")
			ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateSpudGuns")
			shared.bCrateStateSetup = true
			--print("==========> shared.bCrateStateSetup 4_03")
		end
		--print("==========> PASSING MISSION 4B2")
	elseif missionId == MissionGetIndex("5_01") then
		--print("Passed 5_01, unlocking super spud gun")
		if ChapterGet() <= 4 then
			--print("Setting chapter to 5!")
			ChapterSet(4)
		end
	elseif missionId == MissionGetIndex("5_06") then
		shared.enclaveGateRespawn = 2
	end
	F_MissionFactionChanges()
end

function F_LaunchingMission(missionIndex)
	--print("F_LaunchingMission: ", tostring(missionIndex))
	if missionIndex == MissionGetIndex("2_S04") then
		--print("WTF 2S04????")
		DebugMissionPassDependant(MissionGetIndex("Chapt1Trans"))
	end
end

local missionId, hour, minute, startPoint, visibleArea

function F_SetupBeforeMissionThread()
	--DebugPrint("Setting Up Before Mission For Mission: " .. missionId)
	--DebugPrint("hour: " .. hour .. " min: " .. minute)
	--DebugPrint("startPoint: " .. startPoint .. " visibleArea: " .. visibleArea)
	if hour ~= -1 and minute ~= -1 then
		--print("Prev Time ( hour: ", hour, " minute: ", minute, " ) ")
		if 2 < minute then
			minute = minute - 5
		else
			hour = hour - 1
			minute = 55
		end
		--print("New Time ( hour: ", hour, " minute: ", minute, " ) ")
		ClockSet(hour, minute)
	end
	if visibleArea ~= -1 and startPoint ~= -1 then
		--print("Visible area code: ", visibleArea, " startPoint: ", startPoint)
		AreaForceLoadAreaByAreaTransition(true)
		AreaTransitionPoint(visibleArea, startPoint)
		AreaForceLoadAreaByAreaTransition(false)
	end
	if missionId == MissionGetIndex("1_11x1") then
		TextPrintString("Debugging to make halloween available!", 3, 2)
	end
	collectgarbage()
end

function F_SetupBeforeMission(missionIdParam, hourParam, minuteParam, startPointParam, visibleAreaParam)
	missionId = missionIdParam
	hour = hourParam
	minute = minuteParam
	startPoint = startPointParam
	visibleArea = visibleAreaParam
	CreateThread("F_SetupBeforeMissionThread")
end

function F_SetRestartPoints()
	shared.extraKOPoints = true
end
