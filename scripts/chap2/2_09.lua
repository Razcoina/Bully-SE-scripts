ImportScript("chap2/Boxing_util.lua")
missionDATCleanup = false
objective01 = nil
objective02 = nil
boxingringBlip = nil
local bReachedGym = false

function MissionSetup()
    MissionDontFadeIn()
    PlayCutsceneWithLoad("2-09", true)
    AreaSetDoorLocked("DT_trich_BoxingDoor01", true)
    AreaSetDoorLocked("DT_trich_BoxingDoor02", true)
    AreaSetDoorLocked("iboxing_ESCDoorL01", true)
    AreaSetDoorLocked("iboxing_ESCDoorR01", true)
end

function MissionCleanup()
    AreaSetDoorLocked("DT_trich_BoxingDoor01", false)
    AreaSetDoorLocked("DT_trich_BoxingDoor02", false)
    AreaSetDoorLocked("iboxing_ESCDoorL01", false)
    AreaSetDoorLocked("iboxing_ESCDoorR01", false)
    NonMissionPedGenerationEnable()
    BoxingMissionCleanup()
    if missionDATCleanup == false then
        DATUnload(2)
        missionDATCleanup = true
    end
    if not bReachedGym then
        WeatherForceSnow(false)
        WeatherRelease()
    end
    CameraSetWidescreen(false)
end

function main()
    WeatherForceSnow(true)
    WeatherSet(2)
    DATLoad("2_09.DAT", 2)
    DATInit()
    AreaTransitionPoint(0, POINTLIST._2_09_PLAYERSTART)
    PedSetPosPoint(gPlayer, POINTLIST._2_09_PLAYERSTART)
    CameraFade(1000, 1)
    Wait(1000)
    TextPrint("2_09_Objective", 5, 1)
    objective01 = MissionObjectiveAdd("2_09_Objective")
    boxingringBlip = BlipAddXYZ(397.421, 144.495, 5.27711, 0)
    local x1, y1, z1 = GetPointList(POINTLIST._2_09_BOXINGCLUBDOOR)
    local pos = {
        x = x1,
        y = y1,
        z = z1
    }
    while not EntityInteract(pos, 1, "BUT_ENTER", 5, 7, 9) do
        Wait(0)
    end
    bReachedGym = true
    MissionObjectiveComplete(objective01)
    BlipRemove(boxingringBlip)
    CameraFade(1000, 0)
    Wait(1000)
    PedSetWeaponNow(gPlayer, -1, 0)
    AreaTransitionPoint(27, POINTLIST._2_09_CUTSCENE1, 1, true)
    PlayCutsceneWithLoad("2-09B", true)
    objective02 = MissionObjectiveAdd("2_09_Objective2")
    PlayerSetControl(0)
    if missionDATCleanup == false then
        DATUnload(2)
        missionDATCleanup = true
    end
    NonMissionPedGenerationDisable()
    BoxingSetBif()
    BoxingMissionSetup(true)
    BoxingMissionControl()
    MissionObjectiveComplete(objective02)
end
