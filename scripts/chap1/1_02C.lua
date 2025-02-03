local classDoor = TRIGGER._DT_TSCHOOL_GYML
local classBlip, objID
local timerRanOut = false
local bSuccess = false

function MissionSetup()
    MissionDontFadeIn()
    if shared.b102finished == true then
        shared.b102finished = nil
    else
        CameraFade(500, 0)
        Wait(500)
        AreaClearAllPeds()
    end
    CameraReturnToPlayer(true)
    ClockSet(9, 0)
    SoundStopFireAlarm()
    PlayerSetPunishmentPoints(0)
end

function MissionCleanup()
    if bSuccess then
        --print("ObjectTypeSetPickupListOverride CALLED!!!")
        --print("ObjectTypeSetPickupListOverride CALLED!!!")
        --print("ObjectTypeSetPickupListOverride CALLED!!!")
        ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBox")
        ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrate")
        ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrate")
        shared.passed1_02C = true
        DATLoad("Pickups.DAT", 1)
    end
    SoundStopFireAlarm()
    BlipRemove(classBlip)
    DATUnload(2)
    MissionDontFadeInAfterCompetion()
end

function F_TimerPassed(time)
    return time < GetTimer()
end

function main()
    DATLoad("1_02C.DAT", 2)
    DATInit()
    local x, y, z = GetPointList(POINTLIST._CLASS_CHEM)
    Wait(1000)
    if AreaGetVisible() == 2 then
        local tempX, tempY, tempZ = GetPointList(POINTLIST._1_02C_SPAWNPLAYER)
        PlayerSetPosSimple(tempX, tempY, tempZ)
        PedFaceHeading(gPlayer, 180, 0)
        CameraReturnToPlayer()
        CameraReset()
    else
        AreaTransitionPoint(2, POINTLIST._1_02C_SPAWNPLAYER, nil, false)
    end
    PlayerSetControl(0)
    PlayerSetPosXYZ(-637.4, -296.2, 0)
    CameraReset()
    CameraSetXYZ(-635.5, -299.65, 0.8, -635.95, -298.8, 0.9)
    Wait(1)
    CameraReturnToPlayer(false)
    Wait(500)
    CameraSetWidescreen(false)
    PauseGameClock()
    PlayerSetHealth(200)
    CameraFade(500, 1)
    Wait(501)
    if GetMissionAttemptCount("1_02C") == 1 then
        Wait(501)
        TutorialShowMessage("TUT_CLASS01", 4500, false)
        Wait(4500)
        TutorialShowMessage("TUT_CLASS02", 4500, false)
        Wait(4500)
        TutorialShowMessage("TUT_CLASS03", 4500, false)
        UnpauseGameClock()
        Wait(4500)
    else
        UnpauseGameClock()
    end
    Wait(1000)
    F_RingSchoolBell()
    TextPrint("1_02C_OBJ01", 5, 1)
    objID = MissionObjectiveAdd("1_02C_OBJ01")
    PlayerSetControl(1)
    local startTimer
    while true do
        if gTimer then
            if F_TimerPassed(gTimer) then
                timerRanOut = true
                break
            end
        else
            gTimer = GetTimer() + 57000
        end
        if PlayerIsInAreaXYZ(x, y, z, 0.75, 0) then
            TextPrint("BUT_CLASS_CHE", 0.1, 3)
            if IsButtonPressed(9, 0) then
                break
            end
        end
        Wait(0)
    end
    BlipRemove(classBlip)
    if not timerRanOut then
        bSuccess = true
        CameraFade(700, 0)
        Wait(800)
        MissionObjectiveComplete(objID)
        F_SetRestartPoints()
        MissionSucceed(false, false, false)
    else
        SoundPlayMissionEndMusic(false, 10)
        MissionFail(false, true, "1_02C_FAIL_01")
    end
end

function F_SetRestartPoints()
    shared.extraKOPoints = true
end
