mission_running = true
gPed = nil
gTags = {}
bTagADone = false
bTagBDone = false
bTagCDone = false

function SpawnSprayer(spot, kind)
    if not spot or 4 < spot then
        spot = 1
    end
    local model = GetModelFromName(kind)
    if F_PedExists(gPed) then
        PedDelete(gPed)
    end
    gPed = PedCreatePoint(model, POINTLIST._GRAFFITITESTSPAWN, spot)
    PedSetWeapon(gPed, 321, 10)
    PedStop(gPed)
    PedSetActionTree(gPed, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
    --print(">>>[RUI]", "SpawnSprayer " .. tostring(spot) .. " " .. tostring(kind) .. " " .. tostring(gTags[spot].id) .. " " .. gTags[spot].name)
end

function SpawnAttacker()
    if not spot or spot > 4 then
        spot = 1
    end
    if F_PedExists(gAttacker) then
        PedDelete(gAttacker)
    end
    gAttacker = PedCreatePoint(102, POINTLIST._GTPLAYERSTART, 1)
    PedAttack(gAttacker, gPlayer, 3)
    --print(">>>[RUI]", "++SpawnAttacker")
end

function ResetTags()
    for _, tag in gTags do
        if tag.startNode then
            --print(">>>[RUI]", "reset Tag " .. tag.name .. " " .. tostring(tag.id))
            PAnimSetActionNode(tag.id, tag.startNode, tag.startFile)
            --print(">>>[RUI]", "ok")
        end
    end
end

function ResetPlayer()
    PedSetActionNode(gPlayer, "/Global/Tags/PedPropsActions/PerformTag/DrawMedTag/ParametricTagging/Finished", "Act/Prop/Tags.act")
    GiveWeaponToPlayer(321)
    GiveAmmoToPlayer(321, 10)
end

function EnableBigTags(bEnable)
    if bEnable then
        PAnimSetActionNode(TRIGGER._BIGTAG1, "/Global/CityHallTag/BigTag/Useable", "Act/Prop/pxTagLRG.act")
        PAnimSetActionNode(TRIGGER._BIGTAG2, "/Global/CityHallTag/BigTag/Useable", "Act/Prop/pxTagLRG.act")
        PAnimSetActionNode(TRIGGER._BIGTAG3, "/Global/CityHallTag/BigTag/Useable", "Act/Prop/pxTagLRG.act")
    else
        PAnimSetActionNode(TRIGGER._BIGTAG1, "/Global/CityHallTag/BigTag/NotUseable/invisible", "Act/Prop/pxTagLRG.act")
        PAnimSetActionNode(TRIGGER._BIGTAG2, "/Global/CityHallTag/BigTag/NotUseable/invisible", "Act/Prop/pxTagLRG.act")
        PAnimSetActionNode(TRIGGER._BIGTAG3, "/Global/CityHallTag/BigTag/NotUseable/invisible", "Act/Prop/pxTagLRG.act")
    end
end

function EnableGreaserTag(bEnable)
    if bEnable then
        PAnimSetActionNode(TRIGGER._GREASERTAG, "/Global/3_S10_Tags/TutorialTags/Useable", "Act/Prop/3_S10_Tags.act")
    else
        PAnimSetActionNode(TRIGGER._GREASERTAG, "/Global/3_S10_Tags/TutorialTags/NotUseable/invisible", "Act/Prop/3_S10_Tags.act")
    end
end

function TestTag(node)
    PAnimSetActionNode(TRIGGER._TAG1, node, "Act/Prop/3_S10_Tags.act")
end

function cbTagFail(trigger)
    --print(">>>[RUI]", "cbTagFail " .. tostring(trigger))
end

function F_Tag2Ready()
    if not bTagADone then
        return 1
    else
        return 0
    end
end

function F_Tag2Ready()
    if bTagADone then
        return 1
    else
        return 0
    end
end

function F_Tag3Ready()
    if bTagADone and bTagBDone then
        return 1
    else
        return 0
    end
end

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("GraffitiTest.DAT", 2)
    DATInit()
    LoadActionTree("Act/Props/3_S10_Tags.act")
    TaggingStartPersistentTag()
    mission_running = true
end

function MissionCleanup()
    TaggingStopPersistentTag()
    DATUnload(2)
    if F_PedExists(gPed) then
        PedDelete(gPed)
    end
    if F_PedExists(gAttacker) then
        PedDelete(gAttacker)
    end
end

function cbTagDone(trigger)
    --print(">>>[RUI]", "!!cbTagDone " .. tostring(trigger))
    local tag = TagFind(gTags, trigger)
    --print(">>>[RUI]", "hit tag: " .. tag.name)
end

function TagFind(tbl, trigger)
    for _, tag in tbl do
        if tag and tag.id == trigger then
            return tag
        end
    end
    return nil
end

function MissionInit()
    ManagedPlayerSetPosPoint(POINTLIST._GTPLAYERSTART, 1)
    LoadModels({
        24,
        102,
        30,
        6,
        12
    })
    LoadWeaponModels({ 321 })
    gTags = {
        {
            id = TRIGGER._TAG1,
            startNode = "/Global/Tags/Useable",
            startFile = "Act/Prop/Tags.act",
            name = "defaultTag"
        },
        {
            id = TRIGGER._SMALLTAG,
            startNode = "/Global/TagSmall/Useable",
            startFile = "Act/Prop/TagSmall.act",
            name = "smallTag"
        },
        {
            id = TRIGGER._TUTORIALTAG,
            startNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            startFile = "Act/Prop/3_S10_Tags.act",
            name = "tutorialTag"
        },
        {
            id = TRIGGER._GREASERTAG,
            startNode = "/Global/3_S10_Tags/TutorialTags/Useable",
            startFile = "Act/Prop/3_S10_Tags.act",
            name = "greaserTag"
        },
        {
            id = TRIGGER._BIGTAG1,
            startNode = "/Global/CityHallTag/BigTag/Useable",
            startFile = "Act/Prop/pxTagLRG.act",
            name = "bigTag1"
        },
        {
            id = TRIGGER._BIGTAG2,
            startNode = "/Global/CityHallTag/BigTag/Useable",
            startFile = "Act/Prop/pxTagLRG.act",
            name = "bigTag2"
        },
        {
            id = TRIGGER._BIGTAG3,
            startNode = "/Global/CityHallTag/BigTag/Useable",
            startFile = "Act/Prop/pxTagLRG.act",
            name = "bigTag3"
        }
    }
    GiveWeaponToPlayer(321)
    GiveAmmoToPlayer(321, 10)
    mission_running = true
    ResetTags()
    CameraFade(500, 1)
    Wait(500)
    TaggingStartPersistentTag()
end

function main()
    MissionInit()
    TextPrintString("Graffiti Test", 4, 1)
    while mission_running do
        Wait(0)
    end
    MissionSucceed()
    TaggingStopPersistentTag()
end

function TestEnd()
    mission_running = false
end

function GetModelFromName(name)
    if name == "bully" then
        return 102
    elseif name == "greaser" then
        return 24
    elseif name == "preppy" then
        return 30
    elseif name == "nerd" then
        return 6
    elseif name == "jock" then
        return 12
    else
        return 24
    end
end
