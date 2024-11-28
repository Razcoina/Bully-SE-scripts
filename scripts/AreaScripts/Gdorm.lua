local gWindowTable = {}
local FireAlarmFlag = false
local UnderwearOn = false
local bHeadPeekCheck = false
local gLastHeadNode = 0
local gGirlsPJ = false
local bChocboxCreated = false
local bTeacherModelsDisabled = false
local CherryBomb = false
local spawnNumberHall = 0
local spawnNumberSecretary = 0
local spawnNumberNurse = 0
local spawnNumberLibrarian = 0
local spawnNumberArt = 0
function main()
  AreaSetPopulationSexGeneration(true, false)
  if MissionActiveSpecific("6_03") and shared.g6_03_GreasersAlive == true then
    AreaDisableCameraControlForTransition(true)
    DisablePunishmentSystem(true)
  end
  if not MissionActiveSpecific("6_02") then
    DATLoad("eventsGDorm.DAT", 0)
  end
  DATLoad("Gdorm.DAT", 0)
  DATLoad("SP_Girls_Dorm.DAT", 0)
  PedRequestModel(54)
  F_PreDATInit()
  DATInit()
  shared.gAreaDATFileLoaded[35] = true
  shared.gAreaDataLoaded = true
  F_CreateHeadmisress()
  AreaSetDoorOpen("GDORM_UPPERDOORSTORAGE", true)
  if MissionActiveSpecific("6_03") and shared.g6_03_GreasersAlive == true then
    shared.g6_03_GreasersAlive = false
    shared.g6_03_AreaReady = true
  end
  if MissionActiveSpecific("2_S06") or MissionActiveSpecific("4_01") or MissionActiveSpecific("6_03") then
    F_DisableTeacherModels()
    AreaDeactivatePopulationTrigger(TRIGGER._GDORM_GIRLSONLY)
    if MissionActiveSpecific("6_03") then
      AreaActivatePopulationTrigger(TRIGGER._GDORM_POPOVERRIDE)
    end
  else
    AreaDeactivatePopulationTrigger(TRIGGER._GDORM_POPOVERRIDE)
    AreaActivatePopulationTrigger(TRIGGER._GDORM_GIRLSONLY)
  end
  F_SetupGDormSpawners()
  CreateThread("F_GDormAlarm")
  CreateThread("F_CherryBombEffect")
  while AreaGetVisible() == 35 and not SystemShouldEndScript() do
    Wait(0)
    UpdateAmbientSpawners()
    if shared.gAlarmOn == true and FireAlarmFlag == false then
      FireAlarmFlag = true
    end
    if shared.gdormHeadStop then
      if PedIsValid(pedHeadmistress) then
        F_StopHeadmistress()
      end
      shared.gdormHeadStop = false
    end
    if shared.gdormHeadStart then
      if PedIsValid(pedHeadmistress) then
        F_StartHeadmistress()
      else
        F_CreateHeadmisress()
        F_StartHeadmistress()
      end
      shared.gdormHeadStart = false
    end
    if bHeadPeekCheck then
      F_HeadPeek()
      bHeadPeekCheck = false
    end
	do
      local hour, minute = ClockGet()
      if not MissionActiveSpecific("6_03") then
        if hour == 8 and minute >= 20 and gGirlsPJ == true then
          F_SetGirlsRegular()
        elseif hour == 8 and minute < 20 and gGirlsPJ == false then
          F_SetGirlsPJ()
        elseif hour > 22 or hour < 8 and gGirlsPJ == false then
          F_SetGirlsPJ()
        end
      end
      if shared.gGDormToilet == true then
        shared.gGDormToilet = false
        CherryBomb = true
      end
	end
  end
  if not MissionActiveSpecific("6_03") then
    AreaRevertToDefaultPopulation()
  end
  AreaSetPopulationSexGeneration(true, true)
  gGirlsPJ = true
  F_SetGirlsRegular()
  F_DeleteHeadmisress()
  if bTeacherModelsDisabled then
    F_EnableTeacherModels()
  end
  DATUnload(0)
  shared.gAreaDataLoaded = false
  shared.gAreaDATFileLoaded[35] = false
  collectgarbage()
end
function F_CreateHeadmisress()
  if not MissionActiveSpecific("6_03") then
    PedSetUniqueModelStatus(54, -1)
    pedHeadmistress = PedCreatePoint(54, POINTLIST._GDORM_HEADSPAWN, 1)
    PedSetStealthBehavior(pedHeadmistress, 1, F_stealthCallbackHeadmistress)
    PedFollowPath(pedHeadmistress, PATH._GDORM_HEADMISTRESS, 1, 0, F_routeGdormHeadmistress)
    shared.gdormHeadID = pedHeadmistress
    shared.gdormHeadSpottedPlayer = false
    shared.gdormHeadStop = false
    shared.gdormHeadStart = false
    shared.gdormHeadCanMove = true
  end
end
function F_DeleteHeadmisress()
  if shared.gdormHeadID then
    PedDelete(shared.gdormHeadID)
    shared.gdormHeadID = nil
    shared.gdormHeadSpottedPlayer = nil
    shared.gdormHeadStop = nil
    shared.gdormHeadStart = nil
  end
  PedSetUniqueModelStatus(54, 1)
end
function F_HeadPeek()
  if math.random(1, 100) >= 60 or gLastHeadNode == 4 then
    PedStop(pedHeadmistress)
    if gLastHeadNode == 0 then
      F_HeadPeek02(1, 1)
    elseif gLastHeadNode == 1 then
      F_HeadPeek02(2, 1)
    elseif gLastHeadNode == 2 then
      F_HeadPeek02(3, 1)
    elseif gLastHeadNode == 3 then
      F_HeadPeek02(4, 1)
    elseif gLastHeadNode == 4 then
      F_HeadPeek02(5, 1)
    elseif gLastHeadNode == 11 then
      F_HeadPeek02(6, 0)
    elseif gLastHeadNode == 12 then
      F_HeadPeek02(7, 1)
    elseif gLastHeadNode == 13 then
      F_HeadPeek02(8, 1)
    elseif gLastHeadNode == 14 then
      F_HeadPeek02(9, 1)
    elseif gLastHeadNode == 15 then
      F_HeadPeek02(10, 0)
    elseif gLastHeadNode == 16 then
      F_HeadPeek02(11, 0)
    end
    if shared.gdormHeadCanMove == true then
      PedFollowPath(pedHeadmistress, PATH._GDORM_HEADMISTRESS, 1, 0, F_routeGdormHeadmistress, gLastHeadNode + 1)
    end
  end
end
function F_HeadPeek02(lookElem, textType)
  tempX, tempY, tempZ = GetPointFromPointList(POINTLIST._GDORM_HEADPEEK, lookElem)
  if shared.gdormHeadCanMove == true and textType == 1 then
    SoundPlayScriptedSpeechEvent(pedHeadmistress, "M_2_S06", 4)
  end
  if shared.gdormHeadCanMove == true then
    PedFaceXYZ(pedHeadmistress, tempX, tempY, tempZ, 1)
  end
  Wait(3000)
  if not Alive then
    return
  end
  if shared.gdormHeadCanMove == true then
    PedMoveToPoint(pedHeadmistress, 0, POINTLIST._GDORM_HEADPEEK, lookElem)
  end
  Wait(10000)
  if not Alive then
    return
  end
  if shared.gdormHeadCanMove == true and textType == 1 then
    SoundPlayScriptedSpeechEvent(pedHeadmistress, "M_2_S06", 4)
  end
end
function F_routeGdormHeadmistress(pedID, pathID, nodeID)
  gLastHeadNode = nodeID
  if nodeID == 0 or nodeID == 1 or nodeID == 2 or nodeID == 3 or nodeID == 4 or nodeID == 11 or nodeID == 12 or nodeID == 13 or nodeID == 14 or nodeID == 15 or nodeID == 16 then
    bHeadPeekCheck = true
  end
end
function F_stealthCallbackHeadmistress(pedID)
  SoundPlayScriptedSpeechEvent(pedHeadmistress, "M_2_S06", 40)
  shared.gdormHeadSpottedPlayer = true
end
function F_StopHeadmistress()
  PedStop(pedHeadmistress)
  PedClearObjectives(pedHeadmistress)
  PedSetPosPoint(pedHeadmistress, POINTLIST._GDORM_HEADSTOP, 1)
  PedSetIsStealthMissionPed(pedHeadmistress, false)
  PedSetStationary(pedHeadmistress, true)
end
function F_StartHeadmistress()
  PedSetStationary(pedHeadmistress, false)
  PedSetStealthBehavior(pedHeadmistress, 1, F_stealthCallbackHeadmistress)
  PedFollowPath(pedHeadmistress, PATH._GDORM_HEADMISTRESS, 1, 0, F_routeGdormHeadmistress, 16)
end
function F_SetupGDormSpawners()
  gDormSpawner = AreaAddAmbientSpawner(2, 2, 50, 1000)
  gDormDocker = AreaAddDocker(2, 3)
  AreaAddSpawnLocation(gDormSpawner, POINTLIST._GDORMSPAWN_DOORR, TRIGGER._GDORM_DOORR)
  AreaAddSpawnLocation(gDormSpawner, POINTLIST._GDORMSPAWN_DOORL, TRIGGER._DT_GDORM_DOORL)
  AreaAddDockLocation(gDormDocker, POINTLIST._GDORMDOCK_DOORL, TRIGGER._DT_GDORM_DOORL)
  AreaAddDockLocation(gDormDocker, POINTLIST._GDORMDOCK_DOORLEXIT, TRIGGER._DT_GDORM_DOORLEXIT)
  AreaAddAmbientSpawnPeriod(gDormSpawner, 11, 30, 80)
  AreaAddAmbientSpawnPeriod(gDormSpawner, 15, 30, 420)
  AreaSpawnerSetSexGeneration(gDormSpawner, true, false)
  AreaAddDockPeriod(gDormDocker, 7, 0, 110)
  AreaAddDockPeriod(gDormDocker, 11, 30, 105)
  AreaAddDockPeriod(gDormDocker, 15, 0, 420)
  DockerSetMinimumRange(gDormDocker, 3)
  DockerSetMaximumRange(gDormDocker, 8)
  DockerSetUseFacingCheck(gDormDocker, true)
end
function UpdateAmbientSpawners()
  if FireAlarmFlag == false then
    classHour, classMinute = ClockGet()
    if classHour == 8 and classMinute == 45 then
      AreaSetDockerRunPercentage(gDormDocker, 50)
      DockerSetUseFacingCheck(gDormDocker, false)
      DockerSetUseHeightCheck(gDormDocker, false)
      DockerSetMinimumRange(gDormDocker, 0)
      DockerSetMaximumRange(gDormDocker, 30)
    elseif classHour == 9 and classMinute == 15 then
      AreaSetDockerRunPercentage(gDormDocker, 3)
      DockerSetUseHeightCheck(gDormDocker, true)
      DockerSetUseFacingCheck(gDormDocker, true)
      DockerSetMinimumRange(gDormDocker, 3)
      DockerSetMaximumRange(gDormDocker, 8)
    elseif classHour == 12 and classMinute == 45 then
      AreaSetDockerRunPercentage(gDormDocker, 50)
      DockerSetUseFacingCheck(gDormDocker, false)
      DockerSetUseHeightCheck(gDormDocker, false)
      DockerSetMinimumRange(gDormDocker, 0)
      DockerSetMaximumRange(gDormDocker, 30)
    elseif classHour == 13 and classMinute == 15 then
      AreaSetDockerRunPercentage(gDormDocker, 3)
      DockerSetUseHeightCheck(gDormDocker, true)
      DockerSetUseFacingCheck(gDormDocker, true)
      DockerSetMinimumRange(gDormDocker, 3)
      DockerSetMaximumRange(gDormDocker, 8)
    end
  end
end
function F_GDormAlarm()
  while AreaGetVisible() == 35 and not SystemShouldEndScript() do
    if FireAlarmFlag == true then
      local classHour, classMinute = ClockGet()
      DockerSetOverrideActiveSetting(gDormDocker, true)
      DockerSetUseHeightCheck(gDormDocker, false)
      DockerSetMinimumRange(gDormDocker, 0)
      DockerSetMaximumRange(gDormDocker, 100)
      DockerSetUseFacingCheck(gDormDocker, false)
      AreaSetDockerRunPercentage(gDormDocker, 100)
      PedAddBroadcastStimulus(59, shared.gSchoolFAlarmTime / 1000)
      while shared.gGDormFAlarmOn == true do
        Wait(0)
        if AreaGetVisible() ~= 35 or SystemShouldEndScript() then
          break
        end
      end
      PedRemoveBroadcastStimulus(59)
      if shared.gGDormFAlarmOn == false and not SystemShouldEndScript() then
        DockerSetMinimumRange(gDormDocker, 0)
        DockerSetMaximumRange(gDormDocker, 12)
        DockerSetUseHeightCheck(gDormDocker, true)
        DockerSetUseFacingCheck(gDormDocker, true)
        DockerSetMinimumRange(gDormDocker, 3)
        DockerSetMaximumRange(gDormDocker, 8)
        AreaSetDockerRunPercentage(gDormDocker, 0)
        DockerClearOverrideActiveSetting(gDormDocker)
        FireAlarmFlag = false
      end
    end
    Wait(0)
  end
end
function F_SetGirlsPJ()
  if gGirlsPJ == false then
    PedSetUniqueModelStatus(90, 1)
    PedSetUniqueModelStatus(93, 1)
    PedSetUniqueModelStatus(96, 1)
    PedSetUniqueModelStatus(94, 1)
    PedSetUniqueModelStatus(95, 1)
  end
  F_UnlockModelChanges()
  gGirlsPJ = true
end
function F_SetGirlsRegular()
  if gGirlsPJ == true then
    PedSetUniqueModelStatus(90, -1)
    PedSetUniqueModelStatus(93, -1)
    PedSetUniqueModelStatus(96, -1)
    PedSetUniqueModelStatus(94, -1)
    PedSetUniqueModelStatus(95, -1)
  end
  F_UnlockModelChanges()
  gGirlsPJ = false
end
function F_DisableTeacherModels()
  spawnNumberHall = PedGetUniqueModelStatus(54)
  spawnNumberSecretary = PedGetUniqueModelStatus(59)
  spawnNumberNurse = PedGetUniqueModelStatus(60)
  spawnNumberLibrarian = PedGetUniqueModelStatus(62)
  spawnNumberArt = PedGetUniqueModelStatus(63)
  PedSetUniqueModelStatus(54, -1)
  PedSetUniqueModelStatus(59, -1)
  PedSetUniqueModelStatus(60, -1)
  PedSetUniqueModelStatus(62, -1)
  PedSetUniqueModelStatus(63, -1)
  bTeacherModelsDisabled = true
end
function F_EnableTeacherModels()
  PedSetUniqueModelStatus(54, spawnNumberHall)
  PedSetUniqueModelStatus(59, spawnNumberSecretary)
  PedSetUniqueModelStatus(60, spawnNumberNurse)
  PedSetUniqueModelStatus(62, spawnNumberLibrarian)
  PedSetUniqueModelStatus(63, spawnNumberArt)
end
function F_CherryBombEffect()
  while AreaGetVisible() == 35 and not SystemShouldEndScript() do
    if CherryBomb == true then
      Wait(1000)
      local x, y, z = PlayerGetPosXYZ()
      local tblToiletEffects = {}
      SoundPlay3D(x, y, z, "Chrybmb_Exp")
      Wait(30)
      SoundPlay3D(x, y, z, "ToiletExp")
      for i = 1, 2 do
        x, y, z = GetPointFromPointList(POINTLIST._GDORM_TOILETS, i)
        local effect = EffectCreate("ToiletExplode", x, y, z)
        table.insert(tblToiletEffects, effect)
      end
      Wait(2000)
      for _, entry in tblToiletEffects, nil, nil do
        EffectKill(entry)
        table.remove({}, entry)
      end
      CherryBomb = false
    end
    Wait(0)
  end
end
