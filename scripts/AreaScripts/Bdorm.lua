ImportScript("Library/LibClothing.lua")
local oldFOV = CameraGetFOV()
local bRestoreCam = false
local BDormDoorsSpawner, BDormDoorsDocker, BEntranceDoor, BExitDoor
local BMovePlaya = false
local tblRoomTrophies = {}
local tblSigns = {}
local gClothingHeading = 225
local FireAlarmFlag = false
local gPlayerImmortal = false
local effect = false
local gBoysPJ = false
local gBedWake = false
local bGaryInBed = false
local bSetGaryImmobile = false
local gChemEffects = {}
local bLaunchErrandTut = false
gBDormDoors = {}
function F_MissionComplete(tblEntry)
  if shared.gSkippedWeedKiller then
    return true
  elseif IsMissionCompleated(tblEntry.missionID) then
    return true
  end
  return false
end
function F_FactionDefeated()
  if shared.gSkippedWeedKiller then
    return true
  end
  if StatGetAsInt(84) > 100 then
    return true
  elseif 100 < StatGetAsInt(88) then
    return true
  elseif 100 < StatGetAsInt(92) then
    return true
  elseif 100 < StatGetAsInt(90) then
    return true
  end
  return false
end
function F_PrefectDefeated()
  if shared.gSkippedWeedKiller then
    return true
  end
end
function F_PurchasedCarPoster()
  return PlayerGetScriptSavedData(11) == 1
end
function F_PurchasedRockBandPoster()
  return PlayerGetScriptSavedData(12) == 1
end
function F_PurchasedCarnivalItem(tblData)
  if shared.gSkippedWeedKiller then
    return true
  end
  if tblData.object == "Mission_postcar" then
    return false
  elseif tblData.object == "Mission_4_B03" then
    return false
  end
  return false
end
function F_DiceReward()
  return false
end
function F_HundredPercent()
  if shared.gSkippedWeedKiller then
    return true
  end
  return false
end
function F_BikeRaceReward()
  if IsMissionCompleated("3_R08_Rich7") and IsMissionCompleated("3_R08_Business4") and IsMissionCompleated("3_R08_Poor2") and IsMissionCompleated("3_R08_School1") then
    return true
  end
  return false
end
function F_ShootingGalleryReward()
  if shared.gSkippedWeedKiller then
    return true
  end
  return false
end
function F_CarnivalReward()
  if shared.gSkippedWeedKiller then
    return true
  end
  return false
end
function F_PumpkinReward()
  if shared.gSkippedWeedKiller then
    return true
  end
  return false
end
function F_CreateRoomTrophies()
  tblRoomTrophies = {}
  local idObject, bObjectPool
  local totalTrophies = 0
  if IsMissionCompleated("1_09") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("1_B") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("1_G1") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("2_07") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("2_08") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("2_B") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("2_G2") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("2_S04") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("2_S06") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("3_01") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("3_B") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("3_G3") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("4_B1") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("4_B2") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("4_G4") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("5_01") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("5_03") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("5_04") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("5_B") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("5_G5") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("4_04") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("6_B") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("C_ART_5") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("C_WRESTLING_5") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("C_PHOTOGRAPHY_5") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("C_WRESTLING_3") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("C_SHOP_5") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("C_MATH_5") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("C_BIOLOGY_5") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("C_GEOGRAPHY_5") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("C_MUSIC_5") then
    totalTrophies = totalTrophies + 1
  end
  if IsMissionCompleated("GOKART_GP5") then
    totalTrophies = totalTrophies + 1
  end
  if F_BikeRaceReward() then
    idObject, bObjectPool = CreatePersistentEntity("Mission_BMX", -496.17, 307.446, 32.707, 0, 14)
    table.insert(tblRoomTrophies, {id = idObject, bPool = bObjectPool})
	totalTrophies = totalTrophies + 1
  end
  if GetMissionSuccessCount("2_R03_X") >= 4 then
    idObject, bObjectPool = CreatePersistentEntity("Mission_PR", -496.203, 315.721, 32.7491, 0, 14)
    table.insert(tblRoomTrophies, {id = idObject, bPool = bObjectPool})
    totalTrophies = totalTrophies + 1
  end
  if shared.gSkippedWeedKiller or F_PurchasedCarPoster() then
    idObject, bObjectPool = CreatePersistentEntity("Mission_CarnTckt01", -493.556, 307.619, 33.0466, 0, 14)
    table.insert(tblRoomTrophies, {id = idObject, bPool = bObjectPool})
    totalTrophies = totalTrophies + 1
  end
  if shared.gSkippedWeedKiller or F_PurchasedRockBandPoster() then
    idObject, bObjectPool = CreatePersistentEntity("Mission_CarnTckt02", -495.479, 315.723, 33.1577, 1.00179E-5, 14)
    table.insert(tblRoomTrophies, {id = idObject, bPool = bObjectPool})
    totalTrophies = totalTrophies + 1
  end
  if shared.gSkippedWeedKiller or StatGetAsInt(265) == 27 then
    idObject, bObjectPool = CreatePersistentEntity("Mission_Pumpkin", -498.236, 307.863, 33.8526, 0.23926, 14)
    table.insert(tblRoomTrophies, {id = idObject, bPool = bObjectPool})
    totalTrophies = totalTrophies + 1
  end
  if shared.gSkippedWeedKiller or StatGetAsInt(266) == 25 then
    idObject, bObjectPool = CreatePersistentEntity("BDorm_GnomeA", -499.407, 310.001, 34.1184, 0, 14)
    table.insert(tblRoomTrophies, {id = idObject, bPool = bObjectPool})
    totalTrophies = totalTrophies + 1
  end
  if shared.gSkippedWeedKiller or StatGetAsInt(264) == 19 then
    idObject, bObjectPool = CreatePersistentEntity("Mission_Tomb", -497.552, 307.855, 31.8739, 0, 14)
    table.insert(tblRoomTrophies, {id = idObject, bPool = bObjectPool})
    totalTrophies = totalTrophies + 1
  end
  local numtroph = totalTrophies
  StatSetAsInt(1, numtroph)
end
function F_DeleteRoomTrophies()
  for i, Entry in tblRoomTrophies, nil, nil do
    if Entry.id ~= nil and Entry.id ~= -1 then
      DeletePersistentEntity(Entry.id, Entry.bPool)
    end
  end
  tblRoomTrophies = {}
end
function F_GetBoardOne()
  if IsMissionCompleated("6_B") then
  elseif IsMissionCompleated("5_02") then
  elseif IsMissionCompleated("3_B") then
  elseif IsMissionCompleated("2_S06") then
  elseif IsMissionCompleated("1_09") then
  end
  return "BulletinChapter1_12"
end
function F_GetBoardThree()
  if IsMissionCompleated("6_B") then
  elseif IsMissionCompleated("5_02") then
  elseif IsMissionCompleated("4_B1") then
  elseif IsMissionCompleated("3_B") then
  elseif IsMissionCompleated("2_B") then
  elseif IsMissionCompleated("1_B") then
  elseif IsMissionCompleated("1_04") then
  end
  return "BulletinChapter1_9"
end
function F_CreateInteractiveSigns()
  local idSignTexture = "BulletinChapter1_1"
  local idSignObject = F_GetBoardOne()
  local objID, objPool = CreatePersistentEntity(idSignObject, -499.849, 309.211, 33.0609, -180, 14)
  table.insert(tblSigns, {
    id = objID,
    bPool = objPool,
    signx = -499.784,
    signy = 309.211,
    signz = 31.415,
    tex = idSignTexture
  })
  idSignObject = F_GetBoardThree()
  objID, objPool = CreatePersistentEntity(idSignObject, -495.223, 325.33, 33.0609, -180, 14)
  table.insert(tblSigns, {
    id = objID,
    bPool = objPool,
    signx = -495.163,
    signy = 325.446,
    signz = 31.415,
    tex = idSignTexture
  })
end
function F_DeleteInteractiveSigns()
  local i, Entry
  for i, Entry in tblSigns, nil, nil do
    if Entry.id ~= nil and Entry.id ~= -1 then
      DeletePersistentEntity(Entry.id, Entry.bPool)
    end
  end
  tblSigns = {}
end
function F_BDormAlarm()
  while AreaGetVisible() == 14 and not SystemShouldEndScript() do
    if FireAlarmFlag == true then
	  local classHour, classMinute = ClockGet()
      AlarmSpawner = AreaAddAmbientSpawner(10, 1, 0, 200)
      for i, key in gBDormDoors, nil, nil do
        AreaAddSpawnLocation(AlarmSpawner, key.Point, key.Trigger)
      end
      DockerSetUseHeightCheck(BExitDoor, false)
      DockerSetMinimumRange(BExitDoor, 0)
      DockerSetMaximumRange(BExitDoor, 200)
      DockerSetUseFacingCheck(BExitDoor, false)
      DockerSetOverrideActiveSetting(BExitDoor, true)
      DockerSetMinimumRange(BDormDoorsDocker, 0)
      DockerSetMaximumRange(BDormDoorsDocker, 0)
      AreaSetDockerRunPercentage(BExitDoor, 100)
      AreaSetAmbientSpawnerExclusive(AlarmSpawner, true)
      AreaOverridePopulation(10, 0, 0, 2, 0, 2, 2, 4, 0, 0, 0, 0, 0)
      AreaAddAmbientSpawnPeriod(AlarmSpawner, classHour, classMinute, 10)
      AreaSpawnerSetSexGeneration(AlarmSpawner, false, true)
      SpawnerSetOverrideActiveSetting(BEntranceDoor, false)
      PedAddBroadcastStimulus(59, shared.gSchoolFAlarmTime / 1000)
      while shared.gBDormFAlarmOn == true do
        if AreaGetVisible() ~= 14 then
          break
        end
        if SystemShouldEndScript() then
          break
        end
        Wait(0)
      end
      PedRemoveBroadcastStimulus(59)
      AreaRevertToDefaultPopulation()
      if shared.gBDormFAlarmOn == false and not SystemShouldEndScript() then
        AreaSetAmbientSpawnerExclusive(AlarmSpawner, false)
        AreaRemoveSpawner(AlarmSpawner)
        AlarmSpawner = nil
        DockerSetMinimumRange(BExitDoor, 0)
        DockerSetMaximumRange(BExitDoor, 12)
        DockerSetUseHeightCheck(BExitDoor, true)
        DockerSetUseFacingCheck(BExitDoor, true)
        DockerSetMinimumRange(BDormDoorsDocker, 3)
        DockerSetMaximumRange(BDormDoorsDocker, 10)
        AreaSetDockerRunPercentage(BExitDoor, 0)
        SpawnerClearOverrideActiveSetting(BEntranceDoor)
        DockerClearOverrideActiveSetting(BExitDoor)
        FireAlarmFlag = false
      end
    end
    Wait(0)
  end
end
local bLaunchErrandTut = false
function main()
  F_KillAllLittleKids()
  AreaSetPopulationSexGeneration(false, true)
  DATLoad("BoysDorm.DAT", 0)
  DATLoad("BDorm_Doors.DAT", 0)
  DATLoad("eventsBDorm.DAT", 0)
  DATLoad("isc_dorm.DAT", 0)
  DATLoad("SP_BoysDorm.DAT", 0)
  DATLoad("tags_dorm.DAT", 0)
  if IsMissionCompleated("4_B1") then
    DATLoad("BDorm_Spud.DAT", 0)
  end
  if IsMissionCompleated("3_R09_N") then
    DATLoad("BDorm_RLauncher.DAT", 0)
  end
  if IsMissionCompleated("2_03") then
    DATLoad("BDorm_Eggs.DAT", 0)
  end
  F_GaryOnBedInit()
  F_PreDATInit()
  DATInit()
  shared.gAreaDATFileLoaded[14] = true
  gClothingUnlocked = true
  shared.ChemistrySetLastTimeUsed = PlayerGetScriptSavedData(25)
  F_SetupDormSpawners()
  F_CreateRoomTrophies()
  F_CreateInteractiveSigns()
  F_RegisterEvents()
  ThadUniqueValue = PedGetUniqueModelStatus(7)
  ThadPJUniqueValue = PedGetUniqueModelStatus(224)
  LBUniqueValue = PedGetUniqueModelStatus(66)
  LBPJUniqueValue = PedGetUniqueModelStatus(225)
  HBUniqueValue = PedGetUniqueModelStatus(69)
  HBPJUniqueValue = PedGetUniqueModelStatus(226)
  B1UniqueValue = PedGetUniqueModelStatus(72)
  B1PJUniqueValue = PedGetUniqueModelStatus(227)
  B2UniqueValue = PedGetUniqueModelStatus(73)
  B2PJUniqueValue = PedGetUniqueModelStatus(228)
  CreateThread("F_BDormAlarm")
  F_ToggleArcadeScreens()
  while AreaGetVisible() == 14 and not SystemShouldEndScript() do
    UpdateAmbientSpawners()
    if not MissionActive() and not IsMissionCompleated("1_E01") and not PlayerIsInTrigger(TRIGGER._PLAYER_ROOM) and not bLaunchErrandTut and IsMissionCompleated("1_05") and ClockGet() >= 8 and ClockGet() <= 18 then
      bLaunchErrandTut = true
      ForceStartMission("1_E01")
    end
    if IsMissionCompleated("1_02A") and not gPlayerImmortal and not IsMissionCompleated("1_02B_Dummy") then
      PedSetFlag(gPlayer, 58, true)
      gPlayerImmortal = true
    end
    if gPlayerImmortal and 0 >= PedGetHealth(gPlayer) then
      PlayerSetControl(0)
      Wait(1000)
      CameraFade(500, 0)
      Wait(500)
      PlayerSetHealth(PedGetMaxHealth(gPlayer))
      PedSetFlag(gPlayer, 58, true)
      PlayerSetPosPoint(POINTLIST._BOYSDORM_PLAYERBED)
      AreaClearAllPeds()
      PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
      Wait(1000)
      CameraFade(1000, 1)
      PlayerSetControl(1)
    end
    if gBedWake == true then
      gBedWake = false
      ExecuteActionNode(gPlayer, "/Global/Ambient/MissionSpec/WakeUp/GetUp", "Act/Anim/Ambient.act")
    end
    if shared.gAlarmOn == true and FireAlarmFlag == false then
      FireAlarmFlag = true
    end
    if (gClothingUnlocked or shared.unlockedClothing) and not shared.lockClothingManager then
      if not cx then
        cx, cy, cz = GetPointList(POINTLIST._CM_CORONA)
      end
      if not gClothing and F_CheckPedNotInGrapple(gPlayer) and PlayerIsInAreaXYZ(cx, cy, cz, 1, 6, 90) then
        TextPrint("BUT_CLOTH", 1, 3)
        if IsButtonBeingPressed(9, 0) then
          L_ClothingSetup(gClothingHeading, CbFinishClothing)
          gClothing = true
        end
      end
    end
    if ClockGet() == 8 and ClockGet() >= 20 and gBoysPJ == true then
      F_SetBoysRegular()
    elseif ClockGet() == 8 and ClockGet() < 20 and gBoysPJ == false then
      F_SetBoysPJ()
    elseif ClockGet() > 22 or ClockGet() < 8 and gBoysPJ == false then
      F_SetBoysPJ()
    end
    F_ChemistrySet()
    if bGaryInBed then
      if MissionActive() then
        F_UnloadGaryInBed()
        shared.lockClothingManager = false
        bGaryInBed = false
      end
      F_GarySpeaks()
    end
    if shared.b1x11_failed == true then
      F_GaryOnBedInit()
      shared.b1x11_failed = false
    end
    if BMovePlaya == true then
      BMovePlaya = false
      CameraFade(500, 0)
      Wait(500)
      AreaTransitionPoint(14, POINTLIST._BOYSDORM_BEDWAKEUP, 1, true)
      CameraFade(500, 1)
    end
    Wait(0)
  end
  gBoysPJ = true
  F_SetBoysRegular()
  F_BringBackTheLittleOnes()
  if gPlayerImmortal then
    PedSetFlag(gPlayer, 58, false)
  end
  F_CleanChemEffects()
  AreaClearDockers()
  AreaClearSpawners()
  AreaSetPopulationSexGeneration(true, true)
  if bGaryInBed then
    F_UnloadGaryInBed()
    shared.lockClothingManager = false
  end
  F_DeleteRoomTrophies()
  tblRoomTrophies = nil
  F_DeleteInteractiveSigns()
  tblSigns = nil
  shared.unlockedClothing = nil
  DATUnload(0)
  DATUnload(5)
  shared.gAreaDataLoaded = false
  shared.gAreaDATFileLoaded[14] = false
  collectgarbage()
end
function F_SetupDormSpawners()
  BDormDoorsSpawner = AreaAddAmbientSpawner(10, 3, 0, 1000)
  BDormDoorsDocker = AreaAddDocker(10, 2)
  BExitDoor = AreaAddDocker(1, 5)
  BEntranceDoor = AreaAddAmbientSpawner(1, 2, 0, 1000)
  table.insert(gBDormDoors, {
    Trigger = TRIGGER.BdrDoorDownstairs1,
    Point = POINTLIST.BdrDoorDownstairs1
  })
  table.insert(gBDormDoors, {
    Trigger = TRIGGER.BdrDoorDownstairs2,
    Point = POINTLIST.BdrDoorDownstairs2
  })
  table.insert(gBDormDoors, {
    Trigger = TRIGGER.BdrDoorDownstairs4,
    Point = POINTLIST.BdrDoorDownstairs4
  })
  table.insert(gBDormDoors, {
    Trigger = TRIGGER.BdrDoorDownstairs5,
    Point = POINTLIST.BdrDoorDownstairs5
  })
  table.insert(gBDormDoors, {
    Trigger = TRIGGER.BdrDoorDownstairs6,
    Point = POINTLIST.BdrDoorDownstairs6
  })
  table.insert(gBDormDoors, {
    Trigger = TRIGGER.BdrDoorDownstairs7,
    Point = POINTLIST.BdrDoorDownstairs7
  })
  table.insert(gBDormDoors, {
    Trigger = TRIGGER.BdrDoorDownstairs8,
    Point = POINTLIST.BdrDoorDownstairs8
  })
  for i, key in gBDormDoors, nil, nil do
    AreaAddSpawnLocation(BDormDoorsSpawner, key.Point, key.Trigger)
    AreaAddDockLocation(BDormDoorsDocker, key.Point, key.Trigger)
  end
  AreaAddSpawnLocation(BEntranceDoor, POINTLIST.DormExitDoorR, TRIGGER.DormExitDoorR)
  AreaAddDockLocation(BExitDoor, POINTLIST.DormExitDoorL, TRIGGER.DT_DormExitDoorL)
  AreaSpawnerSetSexGeneration(BDormDoorsSpawner, false, true)
  AreaSpawnerSetSexGeneration(BEntranceDoor, false, true)
  AreaSetDockerSexReception(BDormDoorsDocker, false, true)
  AreaSetDockerSexReception(BExitDoor, false, true)
  AreaAddAmbientSpawnPeriod(BDormDoorsSpawner, 7, 0, 125)
  AreaAddAmbientSpawnPeriod(BDormDoorsSpawner, 12, 30, 30)
  AreaAddAmbientSpawnPeriod(BDormDoorsSpawner, 16, 0, 300)
  AreaAddDockPeriod(BDormDoorsDocker, 11, 30, 60)
  AreaAddDockPeriod(BDormDoorsDocker, 15, 30, 900)
  AreaSetDockerChanceToDock(BDormDoorsDocker, 10)
  AreaAddDockPeriod(BExitDoor, 7, 0, 135)
  AreaAddDockPeriod(BExitDoor, 12, 30, 45)
  DockerSetMinimumRange(BExitDoor, 3)
  DockerSetMaximumRange(BExitDoor, 10)
  AreaAddAmbientSpawnPeriod(BEntranceDoor, 12, 0, 45)
  AreaAddAmbientSpawnPeriod(BEntranceDoor, 15, 30, 420)
end
function UpdateAmbientSpawners()
  if FireAlarmFlag == false then
    classHour, classMinute = ClockGet()
    if classHour == 8 and classMinute == 40 then
      AreaSetDockerRunPercentage(BExitDoor, 50)
      DockerSetUseFacingCheck(BExitDoor, false)
      DockerSetUseHeightCheck(BExitDoor, false)
      DockerSetMinimumRange(BExitDoor, 0)
      DockerSetMaximumRange(BExitDoor, 30)
    elseif classHour == 9 and classMinute == 15 then
      AreaSetDockerRunPercentage(BExitDoor, 3)
      DockerSetUseHeightCheck(BExitDoor, true)
      DockerSetUseFacingCheck(BExitDoor, true)
      DockerSetMinimumRange(BExitDoor, 3)
      DockerSetMaximumRange(BExitDoor, 10)
    elseif classHour == 11 and classMinute == 30 then
      AreaSetAmbientSpawnerExclusive(BEntranceDoor, true)
    elseif classHour == 11 and classMinute == 40 then
      AreaSetAmbientSpawnerExclusive(BEntranceDoor, false)
    elseif classHour == 12 and classMinute == 45 then
      AreaSetAmbientSpawnerExclusive(BDormDoorsSpawner, true)
      AreaSetDockerRunPercentage(BExitDoor, 100)
    elseif classHour == 13 and classMinute == 15 then
      AreaSetAmbientSpawnerExclusive(BDormDoorsSpawner, false)
      AreaSetDockerRunPercentage(BExitDoor, 3)
    elseif classHour == 15 and classMinute == 30 then
      AreaSetAmbientSpawnerExclusive(BEntranceDoor, true)
    elseif classHour == 15 and classMinute == 45 then
      AreaSetAmbientSpawnerExclusive(BEntranceDoor, false)
      AreaSetDockerRunPercentage(BDormDoorsDocker, 3)
    end
  end
end
function CbFinishClothing()
  gClothing = false
  if MissionActiveSpecific("1_02A") or MissionActiveSpecific("1_11X1") then
    shared.finishedFirstClothing = true
  end
end
local currentHour, currentDay
function F_ChemistrySet()
  currentHour = ClockGet()
  currentDay = GetCurrentDay(false)
  if IsMissionCompleated("C_Chem_5") and shared.ChemistrySetLocked == 0 then
    shared.ChemistrySetLocked = 1
  elseif currentDay ~= shared.ChemistrySetLastDayUsed and shared.ChemistrySetLocked == 0 then
    shared.ChemistrySetLocked = 1
  end
  if shared.ChemistrySetLocked == 1 and IsMissionCompleated("C_Chem_1") then
    if not effect then
      local fx, fy, fz = GetPointFromPointList(POINTLIST._DORMCHEMISTRYFX, 1)
      gChemEffects[1] = EffectCreate("BuntzenFlame3", fx, fy, fz)
      fx, fy, fz = GetPointFromPointList(POINTLIST._DORMCHEMISTRYFX, 2)
      gChemEffects[2] = EffectCreate("greenbeakersmoke", fx, fy, fz)
      fx, fy, fz = GetPointFromPointList(POINTLIST._DORMCHEMISTRYFX, 3)
      gChemEffects[3] = EffectCreate("ManHoleSteam", fx, fy, fz)
      effect = true
    end
  elseif shared.ChemistrySetLocked == 2 then
    shared.ChemistrySetLocked = 0
    shared.ChemistrySetLastTimeUsed = currentHour
    shared.ChemistrySetLastDayUsed = currentDay
    if not IsMissionCompleated("C_Chem_5") then
      effect = false
      F_CleanChemEffects()
    end
    local fx, fy, fz = GetPointFromPointList(POINTLIST._DORMCHEMISTRYFX, 3)
    gChemEffects[4] = EffectCreate("Chem_Reaction", fx, fy, fz)
    PlayerSetScriptSavedData(25, currentDay)
    Wait(500)
  end
end
function F_CleanChemEffects()
  for i, lEffect in gChemEffects, nil, nil do
    if EffectIsRunning(lEffect) then
      EffectKill(lEffect)
    end
  end
end
function F_DeathKOTest()
  local x, y, z = GetPointList(POINTLIST._BOYSDORM_BEDWAKEUP)
  if PedIsInAreaXYZ(gPlayer, x, y, z, 0.25, 0) and PedGetFlag(gPlayer, 31) == true then
    gBedWake = true
  end
end
function F_SetBoysPJ()
  if gBoysPJ == false then
    PedSetUniqueModelStatus(224, 1)
    PedSetUniqueModelStatus(227, 1)
    PedSetUniqueModelStatus(228, 1)
  end
  F_UnlockModelChanges()
  gBoysPJ = true
end
function F_SetBoysRegular()
  if gBoysPJ == true then
    PedSetUniqueModelStatus(224, -1)
    PedSetUniqueModelStatus(227, -1)
    PedSetUniqueModelStatus(228, -1)
  end
  F_UnlockModelChanges()
  gBoysPJ = false
end
function F_DormTriggas(TriggerID, PedID)
  if TriggerID == TRIGGER._DORMDOORTRIG1 or TriggerID == TRIGGER._DORMDOORTRIG2 or TriggerID == TRIGGER._DORMDOORTRIG3 or TriggerID == TRIGGER._DORMDOORTRIG4 then
    BMovePlaya = true
  end
end
function F_RegisterEvents()
  F_WalkableMeshCallback()
  RegisterGlobalEventHandler(6, F_WalkableMeshCallback)
  RegisterTriggerEventHandler(TRIGGER._DORMDOORTRIG1, 1, F_DormTriggas, 0)
  RegisterTriggerEventHandler(TRIGGER._DORMDOORTRIG2, 1, F_DormTriggas, 0)
  RegisterTriggerEventHandler(TRIGGER._DORMDOORTRIG3, 1, F_DormTriggas, 0)
  RegisterTriggerEventHandler(TRIGGER._DORMDOORTRIG4, 1, F_DormTriggas, 0)
end
function F_WalkableMeshCallback(hashID)
  if ChapterGet() == 0 then
    AreaSetPathableInRadius(-523.41, 314.656, 31.4, 0.5, 5, false)
  end
end
function F_GaryOnBedInit()
  if IsMissionCompleated("1_09") and not MissionActive() and not IsMissionCompleated("1_11x1") then
    F_LoadGaryInBed()
    shared.lockClothingManager = true
    bGaryInBed = true
  end
end
function F_LoadGaryInBed()
  if not shared.b1x11_failed then
    LoadActionTree("Act/Conv/1_11X1.act")
    while not PedRequestModel(160) do
      Wait(0)
    end
  end
  pedGary = {
    spawn = POINTLIST._BOYSDORM_1_11_GARYBED,
    element = 1,
    model = 160
  }
  bGarySpeech = false
  timerGarySpeak = 0
  pedGary.id = PedCreatePoint(pedGary.model, pedGary.spawn, pedGary.element)
  ExecuteActionNode(pedGary.id, "/Global/1_11X1/Animations/GaryIdleInBed", "Act/Conv/1_11X1.act")
  PedSetInvulnerable(pedGary.id, true)
  PedMakeTargetable(pedGary.id, false)
  PedSetStationary(pedGary.id, true)
end
function F_UnloadGaryInBed()
  if PedIsValid(pedGary.id) then
    PedDelete(pedGary.id)
  end
end
function F_GarySpeaks()
  if PedIsValid(pedGary.id) then
    if not PedIsPlaying(pedGary.id, "/Global/1_11X1/Animations/GaryIdleInBed", true) then
      ExecuteActionNode(pedGary.id, "/Global/1_11X1/Animations/GaryIdleInBed", "Act/Conv/1_11X1.act")
    end
    if not bGarySpeech then
      if PlayerIsInTrigger(TRIGGER._PLAYER_ROOM) then
        if not bSetGaryImmobile then
          PedSetFlag(pedGary.id, 10, false)
          bSetGaryImmobile = true
        end
        SoundPlayScriptedSpeechEventWrapper(pedGary.id, "WHERES_YOUR_COSTUME", 121)
        timerGarySpeak = GetTimer()
        bGarySpeech = true
      end
    elseif PlayerIsInTrigger(TRIGGER._PLAYER_ROOM) and timerGarySpeak + 10000 <= GetTimer() then
      SoundPlayScriptedSpeechEventWrapper(pedGary.id, "WHERES_YOUR_COSTUME", 122)
      timerGarySpeak = GetTimer()
    end
  end
end
function F_KillAllLittleKids()
  PedSetUniqueModelStatus(69, -1)
  PedSetUniqueModelStatus(66, -1)
  if shared.gHalloweenActive == true then
    PedSetUniqueModelStatus(159, -1)
  end
end
function F_BringBackTheLittleOnes()
  if shared.gHalloweenActive == false then
    PedSetUniqueModelStatus(69, 1)
    PedSetUniqueModelStatus(66, 1)
  end
  if shared.gHalloweenActive == true then
    PedSetUniqueModelStatus(159, 2)
  end
end
