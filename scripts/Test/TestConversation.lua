ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibSocial.lua")
local interlocutor

function F_TableInit()
    tblPed1 = {
        model = 130,
        point = POINTLIST._INTERLOCUTOR1,
        interact = F_2PedConversation,
        interactRange = 2,
        radarIcon = 0,
        blipStyle = 4,
        asleep = true
    }
    tblPed1a = {
        model = 84,
        point = POINTLIST._INTERLOCUTOR1A
    }
    tblPed2 = {
        model = 4,
        point = POINTLIST._INTERLOCUTOR2,
        interact = F_3PedConversation,
        interactRange = 2,
        radarIcon = 0,
        blipStyle = 4,
        asleep = true
    }
    tblPed3 = {
        model = 130,
        point = POINTLIST._INTERLOCUTOR3,
        asleep = true
    }
end

function MissionSetup()
    DATLoad("TestConversation.DAT", 2)
    DATInit()
    AreaTransitionPoint(31, POINTLIST._PLAYER)
    F_TableInit()
    L_PedCreate(tblPed1)
    L_PedCreate(tblPed1a)
    shared.tblPed1a = tblPed1a
    L_PedCreate(tblPed3)
end

function L_SocialGiftGiveCallback(pedID)
    SoundPlayScriptedSpeechEvent(pedID, "M_2_02", 24)
end

function L_SocialGiftAskAboutCallback(pedID)
    SoundPlayScriptedSpeechEvent(pedID, "M_2_02", 1)
end

function MissionCleanup()
    L_SocialCleanup()
    DATUnload(2)
end

function F_2PedConversation()
    PedStartConversation("/Global/TestConv_2Ped", "Act/Conv/TestConv_2Ped.act", gPlayer, tblPed1.id)
    while PedInConversation(gPlayer) do
        Wait(0)
    end
end

function main()
    local pickupModel = 504
    local numInventory = ItemGetCurrentNum(pickupModel)
    L_SocialGiftPedSetup(tblPed1a.id, pickupModel, true)
    PickupCreateFromPed(pickupModel, tblPed1a.id, "PermanentMissionVelocity")
    while true do
        L_PedInteract(tblPed1)
        Wait(0)
    end
end
