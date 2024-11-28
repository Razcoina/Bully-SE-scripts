local pete
function MissionSetup()
  MissionDontFadeIn()
  LoadPedModels({
    134,
    56,
    236
  })
  LoadVehicleModels({284, 291})
  DATLoad("Chapt4Trans.dat", 2)
  SoundStopCurrentSpeechEvent()
  SystemEnableFrontEndAndSelectScreens(false)
  if not shared.indusrtialRestartPointsAdded then
    AddKORestartPoint(POINTLIST._RESTART_I_HS, 0)
    AddKORestartPoint(POINTLIST._RESTART_I_HS, 0)
    AddArrestRestartPoint(POINTLIST._RESTART_I_PS, 0)
    local industrialAreaInteriors = {
      20,
      16,
      54
    }
    for i, lArea in industrialAreaInteriors, nil, nil do
      AddInteriorKORestartPoint(lArea, POINTLIST._RESTART_I_HS, 0)
      AddInteriorArrestRestartPoint(lArea, POINTLIST._RESTART_I_PS, 0)
      AddInteriorAsleepRestartPoint(lArea, POINTLIST._RESTART_I_HS, 0)
    end
    SetKORestartPointCameraPos(POINTLIST._RESTART_I_HS, POINTLIST._RESTART_I_HS_CAM)
    SetArrestRestartPointCameraPos(POINTLIST._RESTART_I_PS, POINTLIST._RESTART_I_PS_CAM)
    shared.indusrtialRestartPointsAdded = true
  end
end
function main()
  local Janitor, Mower
  PlayerSetHealth(200)
  PlayerSetPunishmentPoints(0)
  ChapterSet(4)
  ClockSet(7, 0)
  WeatherSet(4)
  AreaDisableCameraControlForTransition(true)
  AreaForceLoadAreaByAreaTransition(true)
  AreaTransitionPoint(0, POINTLIST._CHAPT4TRANS_FOOTBALL, 1, true)
  Wait(1000)
  PlayerSetControl(0)
  CameraSetWidescreen(true)
  SoundPreloadSpeech(gPlayer, "NARRATION", 115, "supersize", true)
  Wait(50)
  while not SoundIsSpeechPreloaded() do
    Wait(0)
  end
  DisablePOI(true, true)
  CameraSetXYZ(13.125735, -144.02072, 13.466585, 14.076521, -143.74162, 13.332967)
  CameraFade(500, 1)
  Wait(501)
  SoundPlayPreloadedSpeech()
  Wait(50)
  SoundPreloadSpeech(gPlayer, "NARRATION", 116, "supersize", true)
  Wait(1050)
  while not SoundIsSpeechPreloaded() do
    Wait(0)
  end
  while SoundSpeechPlaying(gPlayer, "NARRATION", 115) do
    Wait(0)
  end
  Janitor = PedCreatePoint(56, POINTLIST._CHAPT4TRANS_MOW, 1)
  Mower = VehicleCreatePoint(284, POINTLIST._CHAPT4TRANS_MOW, 2)
  PedClearAllWeapons(Janitor)
  VehicleEnableEngine(Mower, true)
  PedWarpIntoCar(Janitor, Mower)
  VehicleSetCruiseSpeed(Mower, 3)
  VehicleFollowPath(Mower, PATH._CHAPT4TRANS_MOWER)
  CameraSetXYZ(-4.781454, -61.58442, 1.891966, -5.492266, -62.282463, 1.977515)
  SoundPlayPreloadedSpeech()
  Wait(50)
  SoundPreloadSpeech(gPlayer, "NARRATION", 117, "supersize", true)
  Wait(3000)
  while not SoundIsSpeechPreloaded() do
    Wait(0)
  end
  while SoundSpeechPlaying(gPlayer, "NARRATION", 116) do
    Wait(0)
  end
  SoundPlayPreloadedSpeech()
  while SoundSpeechPlaying(gPlayer, "NARRATION", 117) do
    Wait(0)
  end
  CameraFade(500, 0)
  Wait(501)
  EnablePOI(true, true)
  PlayerSetPosPoint(POINTLIST._CHAPT4TRANS_DRIVER, 1)
  Wait(1000)
  local driver = PedCreatePoint(236, POINTLIST._CHAPT4TRANS_DRIVER, 1)
  local truck = VehicleCreatePoint(291, POINTLIST._CHAPT4TRANS_TRUCK, 1)
  CameraSetXYZ(24.4817, -352.843, 2.81197, 29.9067, -357.025, 3.121985)
  Wait(1000)
  PedClearAllWeapons(driver)
  VehicleEnableEngine(truck, true)
  Wait(1000)
  PedWarpIntoCar(driver, truck)
  VehicleSetCruiseSpeed(truck, 7)
  VehicleFollowPath(truck, PATH._CHAPT4TRANS_TRUCK)
  MinigameSetChapterCompletion("Chapt4Trans_Title", "Chapt4Trans_Name", true, 0)
  MinigameHoldCompletion()
  CameraFade(500, 1)
  Wait(501)
  Wait(1000)
  CameraReset()
  CameraReturnToPlayer()
  CameraSetPath(PATH._CHAPT4TRANS_CAMERA, true)
  CameraSetSpeed(15, 15, 15)
  CameraLookAtPath(PATH._CHAPT4TRANS_CAMERALOOKAT, true)
  CameraLookAtPathSetSpeed(15, 15, 15)
  Wait(6000)
  MinigameReleaseCompletion()
  while MinigameIsShowingCompletion() do
    Wait(0)
  end
  CameraFade(500, 0)
  Wait(501)
  PedExitVehicle(driver)
  PedDelete(driver)
  VehicleDelete(truck)
  PedExitVehicle(Janitor)
  PedDelete(Janitor)
  VehicleDelete(Mower)
  UnloadModels({
    134,
    56,
    236
  })
  UnloadModels({284, 291})
  ClockSet(8, 30)
  AreaForceLoadAreaByAreaTransition(true)
  AreaTransitionPoint(0, POINTLIST._CHAPT4TRANS, 1)
  PlayCutsceneWithLoad("5-0", true, true)
  LoadPedModels({134})
  PlayerFaceHeading(270, 0)
  pete = PedCreatePoint(134, POINTLIST._CHAPT4TRANS, 2)
  PedFaceObjectNow(pete, gPlayer, 3)
  Wait(10)
  LoadActionTree("Act/Conv/Chapt3Trans.act")
  PedSetActionNode(pete, "/Global/Chapter3Trans/JimmyBye", "Act/Conv/Chapt3Trans.act")
  SoundPlayScriptedSpeechEvent(pete, "BYE", 0, "large")
  PedMakeAmbient(pete)
  PedMoveToXYZ(pete, 0, 187.708, -159.923, 8.944, 1, true)
  CameraReset()
  CameraReturnToPlayer()
  WeatherRelease()
  AreaDisableCameraControlForTransition(false)
  CameraFade(500, 1)
  Wait(501)
  MissionSucceed(false, false, false)
end
function MissionCleanup()
  CameraSetWidescreen(false)
  ClockSet(8, 30)
  UnloadModels({134})
  if pete ~= nil then
    PedMakeAmbient(pete)
    PedWander(pete, 0)
  end
  if Janitor ~= nil then
    if Mower ~= nil then
      VehicleEnableEngine(Mower, false)
    end
    PedWarpOutOfCar(Janitor)
    PedDelete(Janitor)
    Janitor = nil
    if Mower ~= nil then
      VehicleDelete(Mower)
      Mower = nil
    end
  end
  SoundRemoveAllQueuedSpeech(gPlayer)
  SetFactionRespect(11, 100)
  SetFactionRespect(1, 100)
  SetFactionRespect(5, 100)
  SetFactionRespect(4, 100)
  SetFactionRespect(2, 100)
  SetFactionRespect(3, 0)
  CameraReturnToPlayer()
  PlayerSetScriptSavedData(3, PlayerGetNumTimesBusted())
  PlayerSetScriptSavedData(14, 0)
  AreaForceLoadAreaByAreaTransition(false)
  AreaDisableCameraControlForTransition(false)
  SystemEnableFrontEndAndSelectScreens(true)
  AreaSetNodesSwitchedOffInTrigger(TRIGGER._INDUSTRIALBARRICADE, false)
  DATUnload(2)
end
