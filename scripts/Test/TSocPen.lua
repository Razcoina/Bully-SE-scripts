local proj1 = -1
local bSuccessMessage = false
local ax, ay, az
local num_kicked = 0
local button_down = false
local incremented_counter = false

function F_SocPenInit()
    PlayerSetPosXYZ(ax - 0.5, ay, az)
    PlayerFaceHeadingNow(-90)
    proj1 = CreateProjectile(329, ax + 0.5, ay, az + 0.2, 0, 0, 0)
    PedSetActionNode(gPlayer, "/Global/Ambient/Scripted/UseSoccerGoal2/UseSoccerGoalStart", "Act/Anim/Ambient.act")
    SoccerPSetProjectile(proj1)
end

function MissionSetup()
    DATLoad("SoccerGoal.DAT", 2)
    DATInit()
    MinigameCreate("SOCCERP", false)
    local points = {
        POINTLIST._UPPERLEFT,
        POINTLIST._UPPERMIDDLE,
        POINTLIST._UPPERRIGHT,
        POINTLIST._LOWERLEFT,
        POINTLIST._LOWERMIDDLE,
        POINTLIST._LOWERRIGHT
    }
    for i, point in points do
        local x, y, z = GetPointFromPointList(point, 1)
        SoccerPSetLocation(i - 1, x, y, z)
    end
    local x, y, z = GetPointList(POINTLIST._ALIGNMENTPOINT)
    SoccerPSetLocation(6, x, y, z)
    F_SetDifficulty()
    AreaTransitionPoint(0, POINTLIST._ALIGNMENTPOINT)
    num_kicked = 0
    F_SocPenInit()
end

function MissionCleanup()
    DATUnload(2)
    CounterMakeHUDVisible(false)
    DestroyProjectile(proj1)
    PedSetActionNode(gPlayer, "/Global/Ambient/Scripted/UseSoccerGoal2/UseSoccerGoalEnd", "Act/Anim/Ambient.act")
    PedActionControllerUpdate(gPlayer)
    MinigameEnd()
    MinigameDestroy()
end

function F_Success()
    if not bSuccessMessage then
        bSuccessMessage = true
        TextPrintString("Objective complete!", 4, 2)
    end
end

function main()
    local bWaiting = true
    TextPrintString("Press ~o~ for instructions, ~x~ to continue", 1000, 1)
    PlayerSetControl(0)
    while bWaiting do
        WaitSkippable(1)
        if IsButtonPressed(8, 0) then
            TextPrintString("Let's see your soccer skills!", 2, 1)
            WaitSkippable(2000)
            TextPrintString("Power up your kick, aim your shot and let 'er rip. ", 3, 1)
            WaitSkippable(3000)
            TextPrintString("Hit all 6 red squares before time runs out to advance to the next stage.", 4, 1)
            WaitSkippable(4000)
            bWaiting = false
        elseif IsButtonPressed(7, 0) then
            bWaiting = false
        end
    end
    PlayerSetControl(1)
    TextPrintString("", 0, 1)
    MinigameStart()
    MinigameEnableHUD(true)
    CounterMakeHUDVisible(true, true)
    SoccerPSetProjectile(proj1)
    while MinigameIsActive() do
        if IsButtonPressed(6, 0) then
            SoccerPAllowAim(false)
            button_down = true
        end
        if button_down and not IsButtonPressed(6, 0) and not incremented_counter then
            CounterIncrementCurrent(1)
            incremented_counter = true
        end
        if MinigameIsSuccess() then
            F_Success()
            break
        end
        if SoccerPBallDone() then
            CameraFade(500, 0)
            Wait(500)
            DestroyProjectile(proj1)
            F_SocPenInit()
            SoccerPAllowAim(true)
            button_down = false
            incremented_counter = false
            CameraFade(500, 1)
            Wait(500)
            num_kicked = num_kicked + 1
            --DebugPrint("num_kicked: " .. num_kicked .. " counter says: " .. CounterGetCurrent())
            if num_kicked ~= CounterGetCurrent() then
                --DebugPrint("num_kicked and CounterGetCurrent() are in disagreement!!!!!")
            end
        end
        if num_kicked >= max_num_kicks_allowed then
            --DebugPrint("num_kicked: " .. num_kicked .. " greater than or equal to max: " .. max_num_kicks_allowed .. " stopping now")
            break
        end
        Wait(0)
    end
    local bSuccess = MinigameIsSuccess()
    MinigameEnd()
    MinigameEnableHUD(false)
    if bSuccess then
        --DebugPrint("mission success!")
        TextPrintString("You win!", 4, 1)
        MissionSucceed()
    else
        --DebugPrint("mission fail!")
        TextPrintString("You lose!", 4, 1)
        MissionFail()
    end
end

function F_SetDifficulty()
    gMissionSucceedCount = GetMissionCurrentSuccessCount()
    --DebugPrint([[
    --
    --
    --MISSION SUCCESS COUNT: ]] .. gMissionSucceedCount .. [[
    --
    --
    --]])
    CounterMakeHUDVisible(true, true)
    if gMissionSucceedCount == 0 then
        SoccerPSetDifficulty(820000, 3500, 3500, 0)
        max_num_kicks_allowed = 20
    elseif gMissionSucceedCount == 1 then
        SoccerPSetDifficulty(820000, 3500, 3500, 0)
        max_num_kicks_allowed = 15
    elseif gMissionSucceedCount == 2 then
        SoccerPSetDifficulty(820000, 3500, 3500, 0)
        max_num_kicks_allowed = 12
    elseif gMissionSucceedCount == 3 then
        SoccerPSetDifficulty(820000, 3500, 3500, 0)
        max_num_kicks_allowed = 10
    elseif gMissionSucceedCount == 4 then
        SoccerPSetDifficulty(820000, 3500, 3400, 0)
        max_num_kicks_allowed = 8
    elseif gMissionSucceedCount >= 5 then
        SoccerPSetDifficulty(820000, 2000, 2000, 0)
        max_num_kicks_allowed = 6
    end
    CounterSetMax(max_num_kicks_allowed)
    CounterSetCurrent(0)
end
