cutsceneTable = {}
cutsceneTable.size = 0
local iCutSceneIndex = 0
local bFoundCutscene = false
function L_CutsceneFade(fadeIn)
  if fadeIn then
    CameraFade(1000, 1)
  else
    CameraFade(1000, 0)
  end
  Wait(1000)
end
function L_CutsceneSpecialInit(Csname)
  if Csname == "1-07" then
    TaggingSetTVsState(true)
  end
end
function L_CutsceneSpecialShutdown(Csname)
  if Csname == "1-07" then
    TaggingSetTVsState(false)
  end
end
function F_PlayCutScene(CutSceneIndex, loadCutscene, avoidFadeIn, avoidFadeOut, dontTransitionBack, dontTransitionTo)
  if not avoidFadeOut then
    CameraFade(1000, 0)
    Wait(1000)
  end
  local oldArea = AreaGetVisible()
  local x, y, z = PlayerGetPosXYZ()
  local heading = PedGetHeading(gPlayer)
  local minSkipDelay = 1500
  if loadCutscene == true then
    LoadCutscene(cutsceneTable[CutSceneIndex].name, false)
  end
  if not dontTransitionTo then
    AreaForceLoadAreaByAreaTransition(true)
    AreaDisableCameraControlForTransition(true)
    AreaTransitionXYZ(cutsceneTable[CutSceneIndex].area, cutsceneTable[CutSceneIndex].x, cutsceneTable[CutSceneIndex].y, 10)
    AreaDisableCameraControlForTransition(false)
    AreaForceLoadAreaByAreaTransition(false)
  end
  if loadCutscene == true then
    LoadCutsceneSound(cutsceneTable[CutSceneIndex].name)
  end
  if cutsceneTable[CutSceneIndex].setupCutscene then
    CutSceneSetActionNode(cutsceneTable[CutSceneIndex].name)
  end
  if cutsceneTable[CutSceneIndex].specialInit then
    L_CutsceneSpecialInit(cutsceneTable[CutSceneIndex].name)
  end
  CameraDefaultFOV()
  if IsCutsceneLoaded() then
    StartCutscene()
    CameraFade(1000, 1)
    Wait(1000)
    while GetCutsceneRunning() ~= 0 and GetCutsceneTime() < cutsceneTable[CutSceneIndex].time - 1000 do
      if cutsceneTable[CutSceneIndex].name == "1-1-1" and not cutsceneTable[CutSceneIndex].bEvent and GetCutsceneTime() > 58000 then
        GeometryInstance("ScGate01Closed", true, 301.439, -72.5059, 8.04657, false)
        GeometryInstance("ScGate02Closed", true, 225.928, 5.79816, 8.39471, false)
        cutsceneTable[CutSceneIndex].bEvent = true
        PAnimSetActionNode(TRIGGER._TSCHOOL_FRONTGATE, "/Global/1_01/Gates/OpenHold", "Act/Conv/1_01.act")
      end
      Wait(minSkipDelay)
	  minSkipDelay = 0
      if IsButtonPressed(7, 0) then
        CutsceneFadeWithCamera(true)
        break
      end
    end
    MissionSurpressMissionNameText()
    CameraFade(1000, 0)
    Wait(1000)
  end
  StopCutscene()
  CutsceneFadeWithCamera(false)
  CameraSetWidescreen(false)
  if not dontTransitionBack then
    AreaDisableCameraControlForTransition(true)
    AreaTransitionXYZ(AreaGetVisible(), PlayerGetPosXYZ())
    AreaDisableCameraControlForTransition(false)
  end
  PlayerFaceHeading(PedGetHeading(gPlayer), 0)
  if cutsceneTable[CutSceneIndex].specialInit then
    L_CutsceneSpecialShutdown(cutsceneTable[CutSceneIndex].name)
  end
  CameraReturnToPlayer()
  AreaRemoveExtraScene()
  if not avoidFadeIn then
    CameraFade(1000, 1)
    Wait(1000)
  end
end
function PlayCutsceneWithLoad(cutsceneName, avoidFadeIn, avoidFadeOut, dontTransitionBack, dontTransitionTo)
  bFoundCutscene = false
  for i, cutscene in cutsceneTable, nil, nil do
    if cutscene.name == cutsceneName then
      F_PlayCutScene(i, true, avoidFadeIn, avoidFadeOut, dontTransitionBack, dontTransitionTo)
      bFoundCutscene = true
      break
    end
  end
  if not bFoundCutscene then
  end
end
function PlayCutSceneForCheatThread()
  F_PlayCutScene(iCutSceneIndex, true, false, false, false, false)
  collectgarbage()
end
function PlayCutSceneForCheat(cutSceneIndex)
  bCutsceneFinished = false
  iCutSceneIndex = cutSceneIndex
  CreateThread("PlayCutSceneForCheatThread")
end
function F_SetCutsceneTableSize()
  CutSetCutsceneTableSize(cutsceneTable.size)
end
function F_SetCutsceneName(csindex)
  CutSetCutsceneName(cutsceneTable[csindex].name)
end
function F_BuildCutsceneTable()
  local schoolx, schooly, schoolz = GetPointList(POINTLIST._PLAYER_START)
  cutsceneTable = {
    {
      name = "3-01AA",
      x = 552.863,
      y = -372.85,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 123033.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-01AB",
      x = 552.931,
      y = -372.72,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 18633.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-01BA",
      x = 505.355,
      y = -114.183,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 72866.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-01CA",
      x = -769.51,
      y = -298.518,
      IPLs = true,
      collision = true,
      textures = true,
      area = 2,
      radius = 10,
      time = 132733.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-01CB",
      x = -618.733,
      y = 309.034,
      IPLs = true,
      collision = true,
      textures = true,
      area = 19,
      radius = 10,
      time = 32266.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-01DA",
      x = 490.276,
      y = -115.97,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 55333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-01DB",
      x = 490.097,
      y = -115.898,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 38066.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-01DC",
      x = 496.624,
      y = -116.894,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 29500,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-S07",
      x = -791.509,
      y = 49.14,
      IPLs = true,
      collision = true,
      textures = true,
      area = 50,
      radius = 10,
      time = 33533.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-R05A",
      x = -595.011,
      y = 325.748,
      IPLs = true,
      collision = true,
      textures = true,
      area = 4,
      radius = 10,
      time = 66833,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-R05B",
      x = -595.011,
      y = 325.748,
      IPLs = true,
      collision = true,
      textures = true,
      area = 4,
      radius = 10,
      time = 9000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-R07",
      x = 498.083,
      y = -391.829,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 58333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-S08",
      x = 283.343,
      y = -460.467,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 63166.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "CS_COUNTER",
      x = -501.584,
      y = 324.111,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 59166.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-1-1",
      x = schoolx,
      y = schooly,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 61666.66,
      setupCutscene = false,
      specialInit = false,
      bEvent = false
    },
    {
      name = "1-1-2",
      x = -705.909,
      y = 227.981,
      IPLs = true,
      collision = true,
      textures = true,
      area = 5,
      radius = 10,
      time = 96600,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-01",
      x = 368.5,
      y = 142.344,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 96666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-02B",
      x = -501.584,
      y = 324.111,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 40666.664,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-02D",
      x = -636.376,
      y = -285.512,
      IPLs = true,
      collision = true,
      textures = true,
      area = 2,
      radius = 10,
      time = 51800,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-02E",
      x = -501.584,
      y = 324.111,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 81666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-03",
      x = 212.481,
      y = -71.042,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 47700,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-04",
      x = -502.47,
      y = 309.606,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 92600,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-05",
      x = -784.875,
      y = 203.098,
      IPLs = true,
      collision = true,
      textures = true,
      area = 9,
      radius = 10,
      time = 61200,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-06",
      x = -502.47,
      y = 309.606,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 86666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-06B",
      x = 158.411,
      y = 25.486,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 90833.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-07",
      x = -501.584,
      y = 324.111,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 97733.33,
      setupCutscene = false,
      specialInit = true
    },
    {
      name = "1-08",
      x = -454,
      y = 311,
      IPLs = true,
      collision = true,
      textures = true,
      area = 35,
      radius = 10,
      time = 66666.664,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-09",
      x = -672.179,
      y = -307.402,
      IPLs = true,
      collision = true,
      textures = true,
      area = 2,
      radius = 10,
      time = 81833.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-10",
      x = -502.47,
      y = 309.606,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 63833.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-11",
      x = -502.47,
      y = 309.606,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 45666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-B",
      x = -772.455,
      y = -134.553,
      IPLs = true,
      collision = true,
      textures = true,
      area = 8,
      radius = 10,
      time = 67666.664,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-BB",
      x = -772.455,
      y = -134.553,
      IPLs = true,
      collision = true,
      textures = true,
      area = 8,
      radius = 10,
      time = 9666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-BC",
      x = -772.455,
      y = -134.553,
      IPLs = true,
      collision = true,
      textures = true,
      area = 8,
      radius = 10,
      time = 62333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-01",
      x = -631.539,
      y = -278.096,
      IPLs = true,
      collision = true,
      textures = true,
      area = 2,
      radius = 10,
      time = 79033.33,
      setupCutscene = true,
      specialInit = false
    },
    {
      name = "2-02",
      x = 516.629,
      y = -58.715,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 32666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-03",
      x = -730.994,
      y = 386.327,
      IPLs = true,
      collision = true,
      textures = true,
      area = 27,
      radius = 10,
      time = 63000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-03b",
      x = 447.991,
      y = 487.784,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 56833.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-04",
      x = -502.47,
      y = 309.606,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 50666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-05",
      x = 351.428,
      y = 148.634,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 43500,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-06",
      x = 345.948,
      y = 216.214,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 58000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-07",
      x = -784.889,
      y = 382.107,
      IPLs = true,
      collision = true,
      textures = true,
      area = 29,
      radius = 10,
      time = 70000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-08",
      x = -709.749,
      y = 312.36,
      IPLs = true,
      collision = true,
      textures = true,
      area = 6,
      radius = 10,
      time = 81733,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-09",
      x = 225.643,
      y = 247.107,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 37500,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-09B",
      x = -704.57,
      y = 374.908,
      IPLs = true,
      collision = true,
      textures = true,
      area = 27,
      radius = 10,
      time = 20666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-01",
      x = 502.7,
      y = -213.2,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 67400,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-02",
      x = 502.7,
      y = -213.2,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 37000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-03",
      x = 506.136,
      y = -434.276,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 51200,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-04",
      x = -784.875,
      y = 203.098,
      IPLs = true,
      collision = true,
      textures = true,
      area = 9,
      radius = 10,
      time = 54666.67,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-04B",
      x = 506.136,
      y = -434.276,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 54833.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-05",
      x = 502.7,
      y = -213.2,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 63333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-06",
      x = 508.592,
      y = -207.972,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 48333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-01",
      x = -696.453,
      y = 74.392,
      IPLs = true,
      collision = true,
      textures = true,
      area = 40,
      radius = 10,
      time = 49666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-02",
      x = -784.875,
      y = 203.098,
      IPLs = true,
      collision = true,
      textures = true,
      area = 9,
      radius = 10,
      time = 59000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-03",
      x = -696.615,
      y = 61.633,
      IPLs = true,
      collision = true,
      textures = true,
      area = 40,
      radius = 10,
      time = 70633.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-04",
      x = -784.875,
      y = 203.098,
      IPLs = true,
      collision = true,
      textures = true,
      area = 9,
      radius = 10,
      time = 66800,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-05",
      x = -696.615,
      y = 61.633,
      IPLs = true,
      collision = true,
      textures = true,
      area = 40,
      radius = 10,
      time = 87233.336,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-06",
      x = -696.615,
      y = 61.633,
      IPLs = true,
      collision = true,
      textures = true,
      area = 40,
      radius = 10,
      time = 80333.336,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-01",
      x = 187.97,
      y = -151.287,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 52666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-02",
      x = -734.979,
      y = 383.66,
      IPLs = true,
      collision = true,
      textures = true,
      area = 27,
      radius = 10,
      time = 76666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-02B",
      x = 383.66,
      y = 147.361,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 71500,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-03",
      x = 502.7,
      y = -213.2,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 58666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-04",
      x = 59.303,
      y = -61.304,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 69000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-05",
      x = 250.96,
      y = -353.99,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 50666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-06",
      x = 268.7,
      y = -107.2,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 68000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-07",
      x = 237.382,
      y = -70.334,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 21000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-09",
      x = -502.47,
      y = 309.606,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 60333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-09B",
      x = -483.996,
      y = 312.71,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 27066.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "6-02",
      x = 250.814,
      y = -352.845,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 40000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "6-02B",
      x = 301.842,
      y = 2.417,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 44333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-G1",
      x = 246.568,
      y = -19,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 70900,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "1-S01",
      x = -563.082,
      y = 316.99,
      IPLs = true,
      collision = true,
      textures = true,
      area = 15,
      radius = 10,
      time = 118666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-B",
      x = -702.445,
      y = 372.796,
      IPLs = true,
      collision = true,
      textures = true,
      area = 27,
      radius = 10,
      time = 57666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-BB",
      x = -702.445,
      y = 372.796,
      IPLs = true,
      collision = true,
      textures = true,
      area = 27,
      radius = 10,
      time = 22666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-0",
      x = -626.389,
      y = -295.36,
      IPLs = true,
      collision = true,
      textures = true,
      area = 2,
      radius = 10,
      time = 46666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-S02",
      x = -563.082,
      y = 316.99,
      IPLs = true,
      collision = true,
      textures = true,
      area = 15,
      radius = 10,
      time = 72333.336,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-S04",
      x = 187.945,
      y = -151.41,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 56333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-S05",
      x = -631.539,
      y = -278.096,
      IPLs = true,
      collision = true,
      textures = true,
      area = 2,
      radius = 10,
      time = 75633.336,
      setupCutscene = true,
      specialInit = false
    },
    {
      name = "2-S05B",
      x = -631.539,
      y = -278.096,
      IPLs = true,
      collision = true,
      textures = true,
      area = 2,
      radius = 10,
      time = 77500,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-S05C",
      x = 446.216,
      y = 198.394,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 24333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-S06",
      x = 530.314,
      y = -130.642,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 98333.336,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "2-G2",
      x = 345.948,
      y = 216.214,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 70000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-B",
      x = 543.6,
      y = -469.469,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 43833.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-BB",
      x = -735.981,
      y = -656.304,
      IPLs = true,
      collision = true,
      textures = true,
      area = 43,
      radius = 10,
      time = 12666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-BC",
      x = -745.773,
      y = -610.745,
      IPLs = true,
      collision = true,
      textures = true,
      area = 43,
      radius = 10,
      time = 9000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-0",
      x = -505.625,
      y = 329.796,
      IPLs = true,
      collision = true,
      textures = true,
      area = 14,
      radius = 10,
      time = 55166.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-G3",
      x = 505.378,
      y = -434.79,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 60333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-S03",
      x = 181.714,
      y = -19.497,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 43666.664,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-S10",
      x = -565.895,
      y = 133.715,
      IPLs = true,
      collision = true,
      textures = true,
      area = 32,
      radius = 10,
      time = 50000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-S11",
      x = -536.586,
      y = 385.22,
      IPLs = true,
      collision = true,
      textures = true,
      area = 17,
      radius = 10,
      time = 83666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-S11C",
      x = -725.296,
      y = 459.467,
      IPLs = true,
      collision = true,
      textures = true,
      area = 38,
      radius = 10,
      time = 48666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-B1",
      x = -696.615,
      y = 61.633,
      IPLs = true,
      collision = true,
      textures = true,
      area = 40,
      radius = 10,
      time = 23333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-B1B",
      x = -696.615,
      y = 61.633,
      IPLs = true,
      collision = true,
      textures = true,
      area = 40,
      radius = 10,
      time = 11933.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-B1C",
      x = -696.615,
      y = 61.633,
      IPLs = true,
      collision = true,
      textures = true,
      area = 40,
      radius = 10,
      time = 11933.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-B1D",
      x = -695.807,
      y = 73.695,
      IPLs = true,
      collision = true,
      textures = true,
      area = 40,
      radius = 10,
      time = 32333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-B2",
      x = -28.53,
      y = -74.936,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 14333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-B2B",
      x = -28.53,
      y = -74.936,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 15666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-G4",
      x = -633.613,
      y = -69.106,
      IPLs = true,
      collision = true,
      textures = true,
      area = 13,
      radius = 10,
      time = 72666.664,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-S12",
      x = -536.998,
      y = 376.584,
      IPLs = true,
      collision = true,
      textures = true,
      area = 17,
      radius = 10,
      time = 95000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-S12B",
      x = -671.8,
      y = -293.1,
      IPLs = true,
      collision = true,
      textures = true,
      area = 2,
      radius = 10,
      time = 78000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "4-0",
      x = 237.382,
      y = -70.334,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 80000,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-0",
      x = 237.382,
      y = -70.334,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 58333.332,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-05B",
      x = 471.465,
      y = 258.79,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 24833.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-B",
      x = -732.955,
      y = 80.83,
      IPLs = true,
      collision = true,
      textures = true,
      area = 20,
      radius = 10,
      time = 24333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-G5",
      x = 250,
      y = -355,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 34333.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "6-0",
      x = -705.909,
      y = 227.981,
      IPLs = true,
      collision = true,
      textures = true,
      area = 5,
      radius = 10,
      time = 106033.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "6-B",
      x = 194.43,
      y = -65.058,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 29666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "6-BB",
      x = 181.386,
      y = -72.321,
      IPLs = true,
      collision = true,
      textures = true,
      area = 0,
      radius = 10,
      time = 53833.33,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "6-BC",
      x = -705.909,
      y = 227.981,
      IPLs = true,
      collision = true,
      textures = true,
      area = 5,
      radius = 10,
      time = 72666.66,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "FX-TEST",
      x = -631.539,
      y = -278.096,
      IPLs = true,
      collision = true,
      textures = true,
      area = 2,
      radius = 10,
      time = 33333.332,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "5-BC",
      x = -732.955,
      y = 80.83,
      IPLs = true,
      collision = true,
      textures = true,
      area = 20,
      radius = 10,
      time = 40833.332,
      setupCutscene = false,
      specialInit = false
    },
    {
      name = "3-BD",
      x = -745.773,
      y = -610.745,
      IPLs = true,
      collision = true,
      textures = true,
      area = 43,
      radius = 10,
      time = 33500,
      setupCutscene = false,
      specialInit = false
    }
  }
  cutsceneTable.size = table.getn(cutsceneTable)
end
