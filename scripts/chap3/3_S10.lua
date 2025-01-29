--[[ Changes to this file:
    * Removed unused if chunk
    * Removed function TagsReset, not present in original script
    * Removed function TagsBlipAll, not present in original script
    * Removed function TagsTotal, not present in original script
    * Modified function MissionInit, may require testing
]]

local MISSION_DURATION = 5 * 60
local SPRAY_PAINT_COST = 100
local MAX_TARGET_TAGS = 2
local TAG_MIN = 2
local MAX_TAGS = 5
local gRewardMoney = 0
local bReportSpray = true
local MISSION_RUNNING = 0
local MISSION_PASS = 1
local MISSION_FAIL = 2
local gMissionState = MISSION_RUNNING
local gCurrentStageLoop, gObjectiveBlip, gDone_cb
local gTutorialTag = {}
local gGreaserTags = {}
local currentTags
local gRunTaggingTutorial = true
local bTagItTutorial = true
local AREA_REENTRY_DELAY = 20000
local AREA_COUNTDOWN_MAX = 20

function NIS_GreasersGetAngry()
    --print(">>>[RUI]", "++NIS_GreasersGetAngry")
    SoundSetAudioFocusCamera()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraSetWidescreen(true)
    CameraFade(FADE_OUT_TIME, 0)
    Wait(FADE_OUT_TIME)
    PedSetActionNode(gPlayer, "/Global/3_S10_Tags/TutorialTags/PedPropsActions/DisEngage", "Act/Props/3_S10_Tags.act")
    Wait(100)
    gStoredArea = AreaGetVisible()
    if gStoredArea ~= 0 then
        px, py, pz = PlayerGetPosXYZ()
        PlayerSetPosPoint(POINTLIST._3_S10_PLAYEREMERGENCYSPOT, 1)
    end
    LoadModels({ 24, 22 })
    gGreaser1 = PedCreatePoint(22, POINTLIST._3_S10_GREASERS, 1)
    gGreaser2 = PedCreatePoint(24, POINTLIST._3_S10_GREASERS, 2)
    PedSetActionNode(gGreaser1, "/Global/3_S10/NISend/Greaser1", "Act/Conv/3_S10.act")
    PedSetActionNode(gGreaser2, "/Global/3_S10/NISend/Greaser2", "Act/Conv/3_S10.act")
    CameraSetFOV(70)
    CameraSetXYZ(506.60873, -211.98091, 3.225362, 507.3514, -211.31346, 3.276938)
    while AreaIsLoading() and IsStreamingBusy() do
        Wait(0)
    end
    CameraFade(FADE_IN_TIME, 1)
    CameraSetFOV(70)
    Wait(FADE_IN_TIME)
    SoundPlayScriptedSpeechEvent(gGreaser1, "M_3_S10", 4, "jumbo")
    while SoundSpeechPlaying(gGreaser1) do
        Wait(0)
    end
    Wait(600)
    MinigameSetCompletion("M_PASS", true, gRewardMoney, "3_S10_UNLOCK")
    MinigameAddCompletionMsg("MRESPECT_PP5", 2)
    MinigameAddCompletionMsg("MRESPECT_GM25", 1)
    SoundPlayMissionEndMusic(true, 10)
    SoundPlayScriptedSpeechEvent(gGreaser2, "M_3_S10", 3, "jumbo")
    while SoundSpeechPlaying(gGreaser2) do
        Wait(10)
    end
    Wait(800)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    SetFactionRespect(5, GetFactionRespect(5) + 5)
    SetFactionRespect(4, GetFactionRespect(4) - 25)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    CameraFade(FADE_OUT_TIME, 0)
    Wait(FADE_OUT_TIME)
    CameraDefaultFOV()
    if gStoredArea ~= 0 then
        AreaSetVisible(gStoredArea)
        PlayerSetPosXYZ(px, py, pz)
    end
    CameraReset()
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    PedMakeAmbient(gGreaser1)
    PedMakeAmbient(gGreaser2)
    Wait(500)
    F_SetupCounter(false)
    while AreaIsLoading() and IsStreamingBusy() do
        Wait(0)
    end
    CameraFade(500, 1)
    Wait(501)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    SoundSetAudioFocusPlayer()
    --print(">>>[RUI]", "--NIS_GreasersGetAngry")
end

function F_SetupCounter(bOn, tmax)
    if bOn then
        CounterSetCurrent(0)
        CounterSetMax(tmax)
        CounterSetIcon("spraycan", "spraycan_x")
        CounterMakeHUDVisible(true)
    else
        CounterMakeHUDVisible(false)
        CounterClearIcon()
        CounterSetCurrent(0)
        CounterSetMax(0)
        CounterClearText()
        CounterClearIcon()
    end
end

--[[
if PlayerHasItem(321) then
    PedDestroyWeapon(gPlayer, 321)
    --print(">>>[RUI]", "DEBUG removing spray for flow")
end


function TagsReset(tagGroup)
    local set = tagGroup or -1
    if set == 1 then
        TagsActivate(gTutorialTag)
    elseif set == 2 then
        TagsActivate(gGreaserTags)
    elseif set == 3 then
    else
        TagsActivate(gTutorialTag)
        TagsActivate(gGreaserTags)
    end
end

function TagsBlipAll(tagGroup)
    local set = tagGroup or -1
    if set == 1 then
        TagsBlip(gTutorialTag)
    elseif set == 2 then
        TagsBlip(gGreaserTags)
    elseif set == 3 then
    else
        TagsBlip(gTutorialTag)
        TagsBlip(gGreaserTags)
    end
end

function TagsTotal()
    local money = 0
    local time = 0
    for _, tag in gGreaserTags do
        money = money + tag.money
        time = time + tag.time
    end
    money = money / 100
    print(">>>[RUI]", "total money to be made = $" .. tostring(money))
    print(">>>[RUI]", "total time bonus = " .. tostring(time) .. " seconds")
end
]] -- Not present in original script

function TagsBlip(tagTbl, bOn, bShortRange)
    if not tagTbl then
        return
    end
    local bx, by, bz
    for _, tag in tagTbl do
        tag.blip = F_CleanBlip(tag.blip)
        if bOn then
            bx, by, bz = GetAnchorPosition(tag.id)
            if tag.bAltitude then
                tag.blip = BlipAddXYZ(bx, by, bz, 29, 1)
            else
                tag.blip = BlipAddXYZ(bx, by, bz, 0, 1)
            end
            if bShortRange then
                BlipSetShortRanged(tag.blip, true)
            end
        end
    end
end

function TagsBlipRefresh(tagTbl)
    if not tagTbl then
        return
    end
    local bx, by, bz
    for _, tag in tagTbl do
        --print(">>>[RUI]", "ForceBlip " .. tostring(tag.name))
        if not tag.bTagged then
            tag.blip = F_CleanBlip(tag.blip)
            bx, by, bz = GetAnchorPosition(tag.id)
            if tag.bAltitude then
                tag.blip = BlipAddXYZ(bx, by, bz, 29, 1)
            else
                tag.blip = BlipAddXYZ(bx, by, bz, 0, 1)
            end
            if tagTbl == gGreaserTags then
                BlipSetShortRanged(tag.blip, true)
            end
        end
    end
end

function F_CSPlayIntro()
    PlayerSetControl(0)
    PlayCutsceneWithLoad("3-S10", true)
    MissionInit()
    CameraReturnToPlayer(false)
    CameraFade(1000, 1)
    Wait(1000)
    PlayerSetControl(1)
    --print(">>>[RUI]", "!!F_CSPlayIntro")
end

function F_CleanBlip(blip)
    --print(">>>[RUI]", "!!F_CleanBlip")
    if blip then
        BlipRemove(blip)
    end
    return nil
end

function T_TagLoader()
    --print(">>>[RUI]", "++TagLoader")
    while not bAllTagsLoaded and gMissionState == MISSION_RUNNING do
        if not bTagsALoaded and PlayerIsInTrigger(TRIGGER._3_S10_ATAGSLOAD) then
            TagsLoadForArea(gGreaserTags, TRIGGER._3_S10_ATAGSLOAD)
            bTagsALoaded = true
            --print(">>>[RUI]", "++TagsALoaded")
        end
        Wait(100)
        if not bTagsBLoaded and PlayerIsInTrigger(TRIGGER._3_S10_BTAGSLOAD) then
            TagsLoadForArea(gGreaserTags, TRIGGER._3_S10_BTAGSLOAD)
            bTagsBLoaded = true
            --print(">>>[RUI]", "++TagsBLoaded")
        end
        if not bTagsCLoaded and PlayerIsInTrigger(TRIGGER._3_S10_CTAGSLOAD) then
            TagsLoadForArea(gGreaserTags, TRIGGER._3_S10_CTAGSLOAD)
            bTagsCLoaded = true
            --print(">>>[RUI]", "++TagsCLoaded")
        end
        if not bTagsDLoaded and PlayerIsInTrigger(TRIGGER._3_S10_DTAGSLOAD) then
            TagsLoadForArea(gGreaserTags, TRIGGER._3_S10_DTAGSLOAD)
            bTagsDLoaded = true
            --print(">>>[RUI]", "++TagsDLoaded")
        end
        bAllTagsLoaded = bTagsALoaded and bTagsBLoaded and bTagsCLoaded and bTagsDLoaded
    end
    --print(">>>[RUI]", "--TagLoader")
end

function T_TagBlipper()
    --print(">>>[RUI]", "++T_TagBlipper")
    while gMissionState == MISSION_RUNNING do
        while AreaGetVisible() == 0 do
            if gMissionState ~= MISSION_RUNNING then
                break
            end
            Wait(10)
        end
        --print(">>>[RUI]", "T_TagBlipper:  left mainmap")
        while AreaGetVisible() ~= 0 do
            if gMissionState ~= MISSION_RUNNING then
                break
            end
            Wait(10)
        end
        --print(">>>[RUI]", "T_TagBlipper:  back in main map")
        TagsBlipRefresh(currentTags)
        Wait(100)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T_TagBlipper")
end

function Stage00_GoToPoorAreaInit()
    --print(">>>[RUI]", "!!Stage00_GoToPoorArea")
    gObjectiveBlip = BlipAddPoint(POINTLIST._3_S10_POORAREABLIP, 0)
    gObjective = ObjectiveLogUpdateItem("3_S10_01", nil)
    gCurrentStageLoop = Stage00_GoToPoorAreaLoop
end

function Stage00_GoToPoorAreaLoop()
    SprayRefresher()
    if PlayerIsInTrigger(TRIGGER._3_S10_TUTORIALSTART) then
        SoundPlayInteractiveStream("MS_WildstyleLow.rsm", MUSIC_DEFAULT_VOLUME)
        SoundSetMidIntensityStream("MS_WildstyleMid.rsm", MUSIC_DEFAULT_VOLUME)
        SoundSetHighIntensityStream("MS_WildstyleHigh.rsm", MUSIC_DEFAULT_VOLUME)
        gObjectiveBlip = F_CleanBlip(gObjectiveBlip)
        gObjectiveBlip = BlipAddPoint(POINTLIST._3_S10_TUTBLIP, 0, 1, 1, 7)
        gCurrentStageLoop = Stage01_TagTutorialInit
        --print(">>>[RUI]", "near tutorial tag")
        return
    end
    Wait(100)
end

function SprayRefresher()
    if not PlayerHasItem(321) and not PedMePlaying(gPlayer, "DrawMedTag", true) then
        GiveAmmoToPlayer(321, 1)
        --print(">>>[RUI]", "++SprayRefresher")
    end
end

function Stage01_TagTutorialInit()
    --print(">>>[RUI]", "!!Stage01_TagTutorial")
    gObjective = ObjectiveLogUpdateItem("3_S10_02", gObjective)
    TagsActivate(gTutorialTag, true)
    TagsActivate(gGreaserTags, false)
    TaggingStartPersistentTag()
    TagsRegisterDoneCallBack(cbTutorialTagDone)
    currentTags = gTutorialTag
    CreateThread("T_TagBlipper")
    CreateThread("T_TagIt")
    gCurrentStageLoop = Stage01_TagTutorialLoop
end

function Stage01_TagTutorialLoop()
    if bTutorialTagDone then
        --print(">>>[RUI]", "Stage01_TagTutorialLoop COMPLETE")
        gCurrentStageLoop = Stage02_BuySprayInit
    end
    if not bEntranceHandled and PlayerIsInTrigger(TRIGGER._3_S10_UNDERBRIDGE) then
        bEnteredNewCoventry = true
        bEntranceHandled = true
    end
    if bEnteredNewCoventry and FailPlayerForLeavingPoorArea() then
        FailMission("3_S10_FAIL02")
        return
    end
    SprayRefresher()
    Wait(100)
end

function Stage02_BuySprayInit()
    --print(">>>[RUI]", "!!Stage02_BuySprayInit")
    bTagItTutorial = false
    Wait(2000)
    if PlayerHasItem(321) then
        PedClearWeapon(gPlayer, 321)
    end
    gObjective = ObjectiveLogUpdateItem("3_S10_06", gObjective)
    gObjectiveBlip = F_CleanBlip(gObjectiveBlip)
    gObjectiveBlip = BlipAddPoint(POINTLIST._3_S10_MARKET, 0)
    Wait(1000)
    gCurrentStageLoop = Stage02_BuySprayLoop
end

function Stage02_BuySprayLoop()
    if AreaGetVisible() == 0 and bEnteredShop then
        if PlayerHasWeapon(321) or PlayerHasItem(321) then
            Wait(500)
            gCurrentStageLoop = Stage03_TagGreaserSpotsInit
        elseif not gObjectiveBlip then
            --print(">>>[RUI]", "Stage02_BuySprayLoop reblip shop")
            gObjectiveBlip = BlipAddPoint(POINTLIST._3_S10_MARKET, 0)
            bEnteredShop = false
        end
    elseif AreaGetVisible() == 26 then
        if not bEnteredShop then
            gObjectiveBlip = F_CleanBlip(gObjectiveBlip)
            bEnteredShop = true
        end
        if gObjective and (PlayerHasWeapon(321) or PlayerHasItem(321)) then
            gObjective = ObjectiveLogUpdateItem(nil, gObjective)
            gObjectiveBlip = BlipAddPoint(POINTLIST._3_S10_MARKET, 0)
        else
        end
    end
    if PlayerGetMoney() < SPRAY_PAINT_COST and not PlayerHasItem(321) and not shared.playerShopping then
        FailMission("3_S10_FAIL01")
        return
    end
    if FailPlayerForLeavingPoorArea() then
        FailMission("3_S10_FAIL02")
        return
    end
end

function Stage03_TagGreaserSpotsInit()
    --print(">>>[RUI]", "!!Stage03_TagGreaserSpotsInit")
    gObjectiveBlip = F_CleanBlip(gObjectiveBlip)
    gObjective = ObjectiveLogUpdateItem("3_S10_03", gObjective)
    TaggingOnlyShowMissionTags(false)
    TagsActivate(gGreaserTags, true)
    TagsBlip(gGreaserTags, true, true)
    currentTags = gGreaserTags
    TagsRegisterDoneCallBack(cbGreaserTagDone)
    F_SetupCounter(true, MAX_TAGS)
    CreateThread("T_TagLoader")
    gCurrentStageLoop = Stage03_TagGreaserSpotsLoop
end

function Stage03_TagGreaserSpotsLoop()
    if CounterGetCurrent() >= MAX_TAGS then
        --print(">>>[RUI]", "Stage03_TagGreaserSpotsLoop COMPLETE")
        gCurrentStageLoop = nil
        gMissionState = MISSION_PASS
        bReportSpray = false
        TextPrint("", 1, 1)
        return
    end
    if sprayCheckTimer then
        if TimerPassed(sprayCheckTimer) then
            if not shared.playerShopping then
                if PlayerGetMoney() < SPRAY_PAINT_COST then
                    if not PlayerHasItem(321) then
                        FailMission("3_S10_FAIL01")
                        return
                    end
                elseif not PlayerHasItem(321) then
                    if bReportSpray then
                        if bShowReminder then
                            TextPrint("3_S10_07", 6, 1)
                            bShowReminder = false
                        end
                    else
                        TextPrint("", 0, 1)
                    end
                else
                    bShowReminder = true
                end
            end
            sprayCheckTimer = GetTimer() + 4000
        end
    else
        sprayCheckTimer = GetTimer() + 4000
    end
    if FailPlayerForLeavingPoorArea() then
        FailMission("3_S10_FAIL02")
        return
    end
    Wait(100)
end

function TimerPassed(time)
    return time < GetTimer()
end

function F_TagsInit()
    gTutorialTag = {
        {
            id = TRIGGER._3_S10_TUT_TAG,
            startNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            startFile = "Act/Props/3_S10_Tags.act",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/JimmyTag/tag1",
            bAddBlip = false,
            bTagged = false,
            name = "tutorialTag"
        }
    }
    gGreaserTags = {
        {
            id = TRIGGER._3_S10_TUT_TAG02,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "target tag 1"
        },
        {
            id = TRIGGER._3_S10_TUT_TAG03,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "target tag 2"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_001,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "Greaser tag 1"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_002,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_BTAGSLOAD,
            name = "Greaser tag 2"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_004,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "Greaser tag 4"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_005,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "Greaser tag 5"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_006,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_BTAGSLOAD,
            name = "Greaser tag 6"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_007,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "Greaser tag 7"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_008,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "Greaser tag 8"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_009,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "Greaser tag 9"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_010,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 1000,
            time = 25,
            activateTrigger = TRIGGER._3_S10_BTAGSLOAD,
            name = "Greaser tag 10"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_013,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 1000,
            time = 25,
            activateTrigger = TRIGGER._3_S10_CTAGSLOAD,
            name = "Greaser tag 13"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_014,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_CTAGSLOAD,
            name = "Greaser tag 14"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_015,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_CTAGSLOAD,
            name = "Greaser tag 15"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_016,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_CTAGSLOAD,
            name = "Greaser tag 16"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_017,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 1000,
            time = 25,
            activateTrigger = TRIGGER._3_S10_CTAGSLOAD,
            name = "Greaser tag 17"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_018,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_CTAGSLOAD,
            name = "Greaser tag 18"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_019,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_CTAGSLOAD,
            name = "Greaser tag 19"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_020,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_BTAGSLOAD,
            name = "Greaser tag 20"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_021,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_BTAGSLOAD,
            name = "Greaser tag 21"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_022,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 1000,
            time = 20,
            activateTrigger = TRIGGER._3_S10_DTAGSLOAD,
            name = "Greaser tag 22"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_023,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "Greaser tag 23"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_024,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 20000,
            time = 40,
            bAltitude = true,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            name = "$200 tag"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_025,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 500,
            time = 20,
            activateTrigger = TRIGGER._3_S10_CTAGSLOAD,
            name = "Greaser tag 25"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_026,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 1000,
            time = 25,
            activateTrigger = TRIGGER._3_S10_DTAGSLOAD,
            name = "Greaser tag 26"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_027,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 2000,
            time = 30,
            bAltitude = true,
            activateTrigger = TRIGGER._3_S10_DTAGSLOAD,
            name = "Greaser tag 27"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_028,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 10000,
            time = 350,
            activateTrigger = TRIGGER._3_S10_ATAGSLOAD,
            bAltitude = true,
            name = "Wonder Meats tag 28"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_029,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 5000,
            time = 30,
            bAltitude = true,
            activateTrigger = TRIGGER._3_S10_DTAGSLOAD,
            name = "Drive Through tag 29"
        },
        {
            id = TRIGGER._POORAREA_MEDIUM_030,
            startNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible",
            startFile = "Act/Props/3_S10_Tags.act",
            activeNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            taggedNode = "/Global/3_S10_Tags/TutorialTags/NotUseable/Tagged/GreaserMed",
            bTagged = false,
            bActive = false,
            money = 5000,
            time = 30,
            bAltitude = true,
            activateTrigger = TRIGGER._3_S10_BTAGSLOAD,
            name = "garage tag 27"
        }
    }
    --print(">>>[RUI]", "++F_TagsInit")
end

function cbTagDone(trigger)
    if gDone_cb then
        gDone_cb(trigger)
        --print(">>>[RUI]", "cbTagDone callback fired")
    else
        --print(">>>[RUI]", "cbTagDone no callback")
    end
end

function cbTagFail(trigger)
    --print(">>>[RUI]", "cbTagFail " .. tostring(trigger))
end

function TagsLoadForArea(tbl, trigger)
    if not tbl then
        return
    end
    for _, tag in tbl do
        if tag.activateTrigger == trigger then
            PAnimSetActionNode(tag.id, tag.activeNode, tag.startFile)
            if tag.bAddBlip then
                if tag.bAltitude then
                    tag.blip = BlipAddXYZ(bx, by, bz, 29, 1)
                else
                    tag.blip = BlipAddXYZ(bx, by, bz, 0, 1)
                end
                BlipSetShortRanged(tag.blip, true)
            end
            tag.bActive = true
        end
        --print(">>>[RUI]", "TagsLoadForArea " .. tostring(bOn) .. " " .. tostring(tag.id) .. " " .. tostring(tag.name))
    end
end

function TagsFindTrigger(tbl, trigger)
    for _, tag in tbl do
        if tag and tag.id == trigger then
            return tag
        end
    end
    return nil
end

function TagsRegisterDoneCallBack(cbfunc)
    if cbfunc then
        --print(">>>[RUI]", "++TagsRegisterDoneCallBack")
        gDone_cb = cbfunc
    end
end

function TagsClearAllCallbacks()
    --print(">>>[RUI]", "--TagsClearAllCallbacks")
    gDone_cb = nil
end

function TagsActivate(tbl, bOn)
    if not tbl then
        return
    end
    for _, tag in tbl do
        if bOn then
            PAnimSetActionNode(tag.id, tag.activeNode, tag.startFile)
            if tag.bAddBlip then
                bx, by, bz = GetAnchorPosition(tag.id)
                if tag.bAltitude then
                    tag.blip = BlipAddXYZ(bx, by, bz, 29, 1)
                else
                    tag.blip = BlipAddXYZ(bx, by, bz, 0, 1)
                end
            end
            tag.bActive = true
        else
            PAnimSetActionNode(tag.id, tag.startNode, tag.startFile)
        end
        --print(">>>[RUI]", "TagsActivate bOn " .. tostring(bOn) .. " " .. tostring(tag.id) .. " " .. tostring(tag.name))
    end
end

function TagsRelease(tagTbl)
    for _, tag in tagTbl do
        F_CleanBlip(tag.blip)
    end
    --print(">>>[RUI]", "--TagsRelease")
end

function cbTutorialTagDone(trigger)
    local tag = TagsFindTrigger(gTutorialTag, trigger)
    if tag then
        gRunTaggingTutorial = false
        gObjectiveBlip = F_CleanBlip(gObjectiveBlip)
        tag.bTagged = true
        shared.bSprayUnlocked = true
        bTutorialTagDone = true
        --print(">>>[RUI]", "cbTutorialTagDone")
    end
end

function cbGreaserTagDone(trigger)
    local tag = TagsFindTrigger(gGreaserTags, trigger)
    if tag then
        tag.blip = F_CleanBlip(tag.blip)
        tag.bTagged = true
        --print(">>>[RUI]", "tagged " .. tostring(tag.name) .. " " .. tostring(tag.money))
        CounterIncrementCurrent(1)
        if CounterGetCurrent() == TAG_MIN then
            TutorialShowMessage("3_S10_12", 7000)
        end
        if tag.money then
            gRewardMoney = gRewardMoney + tag.money
        end
        --print(">>>[RUI]", "GREASER TAG")
    end
    --print(">>>[RUI]", "!!cbGreaserTagDone")
end

function cbTargetTagDone(trigger)
    local tag = TagsFindTrigger(gTargetTags, trigger)
    if tag then
        tag.blip = F_CleanBlip(tag.blip)
        tag.bTagged = true
        CounterIncrementCurrent(1)
        if CounterGetCurrent() >= MAX_TARGET_TAGS then
            bTargetTagsDone = true
        end
        --print(">>>[RUI]", "!!cbTargetTagDone")
    end
end

function FailPlayerForLeavingPoorArea()
    if AreaGetVisible() == 0 then
        if not PlayerIsInTrigger(TRIGGER._3_S10_POORAREA) then
            TextPrintF("3S10_AREAWARN", 0.5, 1)
            if not PlayerIsInTrigger(TRIGGER._3_S_10_FAILTRIGGER) then
                return true
            end
        end
        return false
    end
    return false
end

function MissionInit() -- ! Modified
    --print(">>>[RUI]", "!!MissionInit")
    shared.bSprayUnlocked = false
    LoadWeaponModels({ 321 })
    PlayerSetPosPoint(POINTLIST._3_S10_PLAYER_START)
    F_TagsInit()
    --[[
    if PlayerHasItem(321) or PlayerHasWeapon(321) then
        PedDestroyWeapon(gPlayer, 321)
        print(">>>[RUI]", "DEBUG removing spray for flow")
    end
    ]] -- Not present in original script
end

function FailMission(message)
    --print(">>>[RUI]", "--FailMission " .. tostring(message))
    gFailMessage = message
    gCurrentStageLoop = nil
    gMissionState = MISSION_FAIL
end

function ObjectiveLogUpdateItem(newObjStr, oldObj, bSkipPrint)
    local newObj
    if newObjStr then
        newObj = MissionObjectiveAdd(newObjStr)
        if not bSkipPrint then
            TextPrint(newObjStr, 3, 1)
        end
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("3_S10.DAT", 2)
    DATInit()
    LoadActionTree("Act/Props/3_S10_Tags.act")
    LoadActionTree("Act/Conv/3_S10.act")
    LoadAnimationGroup("W_SprayCan")
    LoadAnimationGroup("IDLE_BULLY_C")
    if PlayerGetMoney() < 100 then
        PlayerSetMoney(100)
    end
    TaggingOnlyShowMissionTags(true)
end

function main()
    F_CSPlayIntro()
    GiveAmmoToPlayer(321, 1)
    gCurrentStageLoop = Stage00_GoToPoorAreaInit
    while gMissionState == MISSION_RUNNING do
        if gCurrentStageLoop then
            gCurrentStageLoop()
        end
        Wait(100)
    end
    TextPrint("", 1, 1)
    if gMissionState == MISSION_PASS then
        PlayerSetControl(0)
        F_MakePlayerSafeForNIS(true)
        Wait(750)
        while PedIsPlaying(gPlayer, "/Global/Tags/PedPropsActions/PerformTag/DrawMedTag/ParametricTagging/Finished", false) do
            Wait(100)
        end
        NIS_GreasersGetAngry()
        ObjectTypeSetPickupListOverride("DPI_CardBox", "PickupListMailBoxSprayCan")
        ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateSprayCan")
        ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateSprayCan")
        MissionSucceed(false, false, false)
    else
        SoundPlayMissionEndMusic(false, 10)
        if gFailMessage then
            MissionFail(false, true, gFailMessage)
        else
            MissionFail(false, true)
        end
    end
end

function MissionCleanup()
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    UnLoadAnimationGroup("IDLE_BULLY_C")
    UnLoadAnimationGroup("W_SprayCan")
    SoundFadeoutStream()
    SoundStopInteractiveStream()
    TaggingStopPersistentTag()
    F_SetupCounter(false)
    TaggingOnlyShowMissionTags(false)
    if gMissionState == MISSION_PASS then
        F_LoadSprayCans(true)
    else
        PedDestroyWeapon(gPlayer, 321)
    end
    TagsRelease(gTutorialTag)
    TagsRelease(gGreaserTags)
    TagsClearAllCallbacks()
    shared.bSprayUnlocked = nil
    DATUnload(2)
    --print(">>>[RUI]", "--MissionCleanup")
end

function F_RunTaggingTutorial()
    --print("gRunTaggingTutorial: ", tostring(gRunTaggingTutorial))
    if gRunTaggingTutorial then
        return 1
    end
    return 0
end

function T_TagIt()
    --print(">>>[RUI]", "++T_TagIt")
    local bTutorialStarted = false
    while bTagItTutorial do
        if PlayerIsInTrigger(TRIGGER._3_S10_TUTTRIGGER) then
            --print("T_TagIt: Player is in trigger.")
            if not bTutorialStarted then
                --print("Start the tutorial")
                TutorialStart("TAGGINGTUT1")
                bTutorialStarted = true
            end
        else
            --print("T_TagIt: Player left the trigger.")
            if bTutorialStarted then
                --print("Tutorial reset")
                bTutorialStarted = false
            end
        end
        Wait(100)
    end
    --print(">>>[RUI]", "--T_TagIt")
    collectgarbage()
end
