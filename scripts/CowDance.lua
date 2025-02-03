local CowAct = "Act/Anim/Ambient.act"
local CowTriangle = "/Global/Ambient/Scripted/CowDance/Animation/Triangle/Triangle"
local CowCircle = "/Global/Ambient/Scripted/CowDance/Animation/Circle/Circle"
local CowSquare = "/Global/Ambient/Scripted/CowDance/Animation/Square/Square"
local CowCross = "/Global/Ambient/Scripted/CowDance/Animation/Cross/Cross"
local CowIdle = "/Global/Ambient/Scripted/CowDance/Animation/CustomIdle"
local CowBotch = "/Global/Ambient/Scripted/CowDance/Animation/Botch"
local CowFail = "/Global/Ambient/Scripted/CowDance/Animation/Failure"
local CowPass = "/Global/Ambient/Scripted/CowDance/Animation/Success"
local CowMusicStart = "/Global/Ambient/Scripted/CowDance/CowDanceMusicStart"
local CowMusicStop = "/Global/Ambient/Scripted/CowDance/CowDanceMusicStop"
local CowButtonScrewedAttempts = 0
local CowLastAnim = 0
local PlayerClothes = 0
local tblMoves = {}
local gbFailed = false
local AnimSeq = {
    3,
    1,
    2,
    0
}

function F_CowDanceInit()
    tblMoves = {}
    local move
    for i = 1, 8 do
        move = F_GetMove(move, 0)
        table.insert(tblMoves, move)
    end
    for key, value in tblMoves do
        if key == 1 then
            ClassChemAddAction(0, value, 1.1, 0.5)
        else
            ClassChemAddAction(0, value, 1, 0.5)
        end
    end
end

function F_GetMove(tbl, CurIndex)
    local move = RandomTableElement(AnimSeq)
    if move == tbl then
        CurIndex = CurIndex + 1
        if 4 <= CurIndex then
            if tbl == 3 then
                move = 1
            else
                move = 3
            end
        else
            move = F_GetMove(tbl, CurIndex)
        end
    end
    return move
end

function F_DoMove(move)
    if move == 3 then
        PedSetActionNode(gPlayer, CowTriangle, CowAct)
    elseif move == 1 then
        PedSetActionNode(gPlayer, CowCircle, CowAct)
    elseif move == 2 then
        PedSetActionNode(gPlayer, CowSquare, CowAct)
    elseif move == 0 then
        PedSetActionNode(gPlayer, CowCross, CowAct)
    end
    move = 0
end

function F_KillCow()
end

function F_DanceCowDance()
    shared.forceCowDanceEnd = nil
    while true do
        if bDanceThatCow then
            MinigameCreate("CHEM", false)
            StatAddToInt(15)
            while MinigameIsReady() == false do
                Wait(0)
            end
            MinigameStart()
            ToggleHUDComponentVisibility(20, false)
            ClassChemSetGameType("OTHER")
            MinigameEnableHUD(true)
            ClassChemSetActiveActions(1)
            TextPrint("4_06_CD04", 3, 1)
            PedMakeTargetable(gPlayer, false)
            CowButtonScrewedAttempts = 0
            PedSetActionNode(gPlayer, "/Global/Ambient/Scripted/CowDance/CowDanceMusicStart", CowAct)
            PedSetActionNode(gPlayer, CowIdle, CowAct)
            Wait(1000)
            PedSetActionNode(gPlayer, CowIdle, CowAct)
            F_CowDanceInit()
            local NumOfElements = table.getn(tblMoves)
            local MIndex = 1
            ClassChemSetScrollyOnly(true)
            ClassChemStartSeq(0)
            SoundLoopPlay2D("CowDanceMusic", true)
            --print("===== Starting Up Cow Dance ======")
            PedSetFlag(gPlayer, 13, true)
            PedSetInvulnerable(gPlayer, true)
            while MinigameIsActive() do
                PlayerClothes = ClothingGetPlayer(0)
                if PlayerClothes ~= ObjectNameToHashID("SP_Mascot_H") then
                    PedSetActionNode(gPlayer, "/Global/Ambient/Scripted/CowDance/CowDanceMusicStop", CowAct)
                    while PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/CowDanceMusicStop", false) do
                        Wait(0)
                    end
                    MinigameDestroy(false)
                    break
                end
                if NumOfElements > MIndex then
                    if ClassChemGetActionJustFinished(tblMoves[MIndex]) then
                        F_DoMove(tblMoves[MIndex])
                        MIndex = MIndex + 1
                    elseif ClassChemGetActionJustFailed(tblMoves[MIndex]) then
                        CowButtonScrewedAttempts = CowButtonScrewedAttempts + 1
                        PedSetActionNode(gPlayer, CowBotch, CowAct)
                        MIndex = MIndex + 1
                    end
                end
                if shared.forceCowDanceEnd then
                    shared.forceCowDanceEnd = nil
                    --print("ENDING COW DANCE IN THE SHARED FORCED END")
                    MinigameDestroy(false)
                end
                if PedIsPlaying(gPlayer, "/Global/Actions/Grapples", true) or 0 >= PlayerGetHealth() then
                    --print("ENDING COW DANCE DUE TO GRAPPLING")
                    shared.forceCowDanceEnd = true
                    MinigameDestroy(false)
                    break
                end
                if CowButtonScrewedAttempts == 3 then
                    MinigameEnd()
                    shared.forceCowDanceEnd = nil
                end
                Wait(0)
            end
            PedSetInvulnerable(gPlayer, false)
            PedSetFlag(gPlayer, 13, false)
            SoundLoopPlay2D("CowDanceMusic", false)
            PedMakeTargetable(gPlayer, true)
            ToggleHUDComponentVisibility(20, true)
            if MinigameIsReady() then
                if MinigameIsSuccess() then
                    gPlayerWon = true
                else
                    gPlayerWon = false
                end
                if gPlayerWon then
                    PedSetActionNode(gPlayer, CowPass, CowAct)
                    TextPrint("4_06_CD05", 3, 1)
                    CowLastAnim = CowPass
                    StatAddToInt(16)
                else
                    PedSetActionNode(gPlayer, CowFail, CowAct)
                    TextPrint("4_06_CD06", 3, 1)
                    CowLastAnim = CowFail
                end
                Wait(1000)
                while PedIsPlaying(gPlayer, CowLastAnim, false) do
                    Wait(0)
                end
                Wait(250)
                MinigameDestroy(false)
            end
            PedSetActionNode(gPlayer, "/Global/Ambient/Scripted/Empty/EmptyNode/TrueEmptyNode", "Act/Anim/Ambient.act")
            --print("===== Shutting Down Cow Dance ======")
            UnLoadAnimationGroup("NPC_MASCOT")
            bDanceThatCow = false
        end
        Wait(0)
    end
end
