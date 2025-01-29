local tblMailboxAmbient, tblMailboxDefault, tblMailboxDefaultTarget, tblMailboxDefaultTargetDefault, tblMailboxActionTreeDefault
local tblMonitorFunction = {}

function F_MailboxTableInit()
    tblMailboxAmbient = {
        {
            id = TRIGGER._RICH_MAILBOX01
        },
        {
            id = TRIGGER._RICH_MAILBOX02
        },
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX04
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX06
        },
        {
            id = TRIGGER._RICH_MAILBOX07
        },
        {
            id = TRIGGER._RICH_MAILBOX08
        },
        {
            id = TRIGGER._RICH_MAILBOX09
        },
        {
            id = TRIGGER._RICH_MAILBOX10
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        },
        {
            id = TRIGGER._RICH_MAILBOX15
        },
        {
            id = TRIGGER._RICH_MAILBOX16
        },
        {
            id = TRIGGER._RICH_MAILBOX17
        },
        {
            id = TRIGGER._RICH_MAILBOX17A
        },
        {
            id = TRIGGER._RICH_MAILBOX18
        },
        {
            id = TRIGGER._RICH_MAILBOX19
        },
        {
            id = TRIGGER._RICH_MAILBOX20
        },
        {
            id = TRIGGER._RICH_MAILBOX21
        },
        {
            id = TRIGGER._RICH_MAILBOX22
        }
    }
    tblMailboxDefault = {
        OnUsed = L_MailboxNewspaperOnUsed,
        OnEnter = L_MailboxNewspaperOnEnter,
        OnExit = L_MailboxNewspaperOnExit,
        ped = gPlayer,
        blipStyle = 4,
        radarIcon = 0
    }
    tblMailboxHumanDefault = {
        OnAIStateReached = L_MailboxHumanNewspaperOnStateReached,
        OnEnter = L_MailboxHumanNewspaperOnEnter,
        OnExit = L_MailboxNewspaperOnExit,
        ped = gPlayer,
        AIstate = "/Global/AI_2_R03_HMB/Projectile/Catch/CatchPaper/CatchSuccess",
        AIrecurse = false,
        blipStyle = 4,
        radarIcon = 0,
        actionNode = "/Global/HMB_2_R03",
        actionFile = "Act/Anim/HMB_2_R03.act",
        AINode = "/Global/AI_2_R03_HMB",
        AIFile = "Act/AI/AI_2_R03_HMB.act"
    }
    tblMailboxPedDefault = {
        actionNode = "/Global/MBP_2_R03",
        actionFile = "Act/Anim/MBP_2_R03.act",
        AINode = "/Global/AI_2_R03_MBP",
        AIFile = "Act/AI/AI_2_R03_MBP.act"
    }
    tblMailboxDefaultTargetDefault = { InTrigger = L_MailboxSetDefaultTarget, OnExit = L_MailboxClearDefaultTarget }
end

function L_MailboxHideAmbient()
    for i, mailbox in tblMailboxAmbient do
        PAnimDelete(mailbox.id)
    end
end

function L_MailboxUnhideAmbient()
    for i, mailbox in tblMailboxAmbient do
        PAnimCreate(mailbox.id)
    end
end

function L_MailboxSetDefaultTarget(trigger)
    if L_PlayerGetCurrentTarget() == nil then
        local ped = RandomTableElement(trigger.target)
        PedLockTarget(gPlayer, ped.id)
    end
end

function L_MailboxClearDefaultTarget()
    if L_PlayerGetCurrentTarget() == nil then
        PedLockTarget(gPlayer, -1)
    end
end

function L_MailboxOverrideDefault(tblOverride)
    for index, value in tblOverride do
        tblMailboxDefault[index] = value
    end
    L_PropOverrideDefault(tblOverride)
end

function L_MailboxNewspaperOnUsed(mailbox)
    mailbox.bChecked = true
    L_PlayerClearCurrentTarget(mailbox)
    L_PropPedUnlockTarget(mailbox)
    L_HUDHidePaper()
    NewspaperThrowPaper()
    NewspaperAddDeliverdPaper()
    L_ObjectiveIncrementTally("deliverPapers", "numPapersDelivered")
    L_ObjectiveDecrementTally("deliverPapers", "numPapersNotDelivered")
    L_HUDBlipRemove(mailbox)
end

function L_MailboxNewspaperOnEnter(mailbox)
    if not mailbox.used then
        L_PlayerSetCurrentTarget(mailbox)
        L_PropPedLockTarget(mailbox)
        L_HUDShowPaper()
        if mailbox.waitingPed then
            PedLockTarget(mailbox.waitingPed.id, gPlayer, false)
        end
    end
end

function L_MailboxNewspaperOnExit(mailbox)
    if L_PlayerGetCurrentTarget() == mailbox.id then
        L_PlayerClearCurrentTarget()
        PedLockTarget(mailbox.ped, -1)
        L_HUDHidePaper()
    end
    --print("ped = " .. tostring(mailbox.ped))
    if mailbox.waitingPed then
        PedMakeAmbient(mailbox.waitingPed.id)
    end
end

function L_MailboxLoad(tblMailboxParam)
    for i, mailbox in tblMailboxParam do
        mailbox.OnUsed = mailbox.OnUsed or tblMailboxDefault.OnUsed
        mailbox.OnEnter = mailbox.OnEnter or tblMailboxDefault.OnEnter
        mailbox.OnExit = mailbox.OnExit or tblMailboxDefault.OnExit
        mailbox.ped = mailbox.ped or tblMailboxDefault.ped
        mailbox.blipStyle = mailbox.blipStyle or tblMailboxDefault.blipStyle
    end
    L_PropLoad("p_dmb", tblMailboxParam)
    L_AddTrigger("t_dmb", tblMailboxParam)
    table.insert(tblMonitorFunction, F_MailboxPropMonitor)
end

function L_MailboxPedLoad(tblMailboxPedParam)
    for i, ped in tblMailboxPedParam do
        ped.actionTree = ped.actionTree or tblMailboxPedDefault.actionTree
        ped.actionNode = ped.actionNode or tblMailboxPedDefault.actionNode
        ped.actionFile = ped.actionFile or tblMailboxPedDefault.actionFile
        ped.AINode = ped.AINode or tblMailboxPedDefault.AINode
        ped.AIFile = ped.AIFile or tblMailboxPedDefault.AIFile
    end
    L_PedLoadPoint("p_mbp", tblMailboxPedParam)
end

function L_MailboxHumanLoad(tblMailboxParam, tblPedParam)
    for i, mailbox in tblMailboxParam do
        mailbox.OnEnter = mailbox.OnEnter or tblMailboxHumanDefault.OnEnter
        mailbox.OnExit = mailbox.OnExit or tblMailboxHumanDefault.OnExit
        mailbox.ped = mailbox.ped or tblMailboxHumanDefault.ped
    end
    for i, mailboxPed in tblPedParam do
        mailboxPed.blipStyle = mailboxPed.blipStyle or tblMailboxHumanDefault.blipStyle
        mailboxPed.OnStateReached = mailboxPed.OnStateReached or tblMailboxHumanDefault.OnStateReached
        mailboxPed.state = mailboxPed.state or tblMailboxHumanDefault.state
        mailboxPed.recurse = mailboxPed.recurse or tblMailboxHumanDefault.recurse
        mailboxPed.AIstate = mailboxPed.AIstate or tblMailboxHumanDefault.AIstate
        mailboxPed.AIrecurse = mailboxPed.AIrecurse or tblMailboxHumanDefault.AIrecurse
        mailboxPed.actionTree = mailboxPed.actionTree or tblMailboxHumanDefault.actionTree
        mailboxPed.actionNode = mailboxPed.actionNode or tblMailboxHumanDefault.actionNode
        mailboxPed.actionFile = mailboxPed.actionFile or tblMailboxHumanDefault.actionFile
        mailboxPed.AINode = mailboxPed.AINode or tblMailboxHumanDefault.AINode
        mailboxPed.AIFile = mailboxPed.AIFile or tblMailboxHumanDefault.AIFile
    end
    L_PedLoadPoint("p_dhmb", tblPedParam)
    L_AddTrigger("t_dhmb", tblMailboxParam)
    table.insert(tblMonitorFunction, F_MailboxHumanMonitor)
end

function L_MailboxHumanNewspaperOnStateReached(ped)
    ped.bStateChecked = true
    ped.trigger.bChecked = true
    L_HUDBlipRemove(ped)
    L_PlayerClearCurrentTarget(ped)
    PedLockTarget(gPlayer, -1)
    PedSetTaskNode(ped.id, "/Global/AI", "Act/AI.act")
    L_HUDHidePaper()
    NewspaperThrowPaper()
    NewspaperAddDeliverdPaper()
    L_ObjectiveIncrementTally("deliverPapers", "numPapersDelivered")
    L_ObjectiveDecrementTally("deliverPapers", "numPapersNotDelivered")
    L_HUDBlipRemove(ped.trigger)
end

function L_MailboxHumanNewspaperOnEnter(mailbox)
    if not mailbox.bStateChecked then
        L_PlayerSetCurrentTarget(mailbox.target)
        PedLockTarget(mailbox.ped, mailbox.target.id)
        L_HUDShowPaper()
    end
end

function L_MailboxLoadDefaultTarget(tblMailboxDefaultTargetParam)
    for i, trigger in tblMailboxDefaultTargetParam do
        trigger.OnEnter = trigger.OnEnter or tblMailboxDefaultTargetDefault.OnEnter
        trigger.InTrigger = trigger.InTrigger or tblMailboxDefaultTargetDefault.InTrigger
        trigger.OnExit = trigger.OnExit or tblMailboxDefaultTargetDefault.OnExit
    end
    L_AddTrigger("t_dft", tblMailboxDefaultTargetParam)
    table.insert(tblMonitorFunction, F_DefaultTargetMonitor)
end

function L_MailboxSetup()
    F_MailboxTableInit()
end

function L_MailboxCleanup()
    L_PropCleanup("p_dmb")
end

function T_MailboxMonitor()
    while not L_ObjectiveProcessingDone() do
        F_MailboxMonitor()
        Wait(0)
    end
    collectgarbage()
end

function F_MailboxPropMonitor()
    LF_PropMonitor("p_dmb")
    F_MonitorTriggers("t_dmb")
end

function F_MailboxHumanMonitor()
    F_PedMonitor("p_dhmb")
    F_MonitorTriggers("t_dhmb")
end

function F_DefaultTargetMonitor()
    F_MonitorTriggers("t_dft")
end

function F_MailboxMonitor()
    for i, F_Monitor in tblMonitorFunction do
        F_Monitor()
    end
end

function L_MailboxDeliverySetup(mailboxCount)
    LoadAnimationGroup("2_R03PaperRoute")
    NewspaperMakeHUDVisible(true)
    NewspaperSetDeliveredPapers(0)
    NewspaperSetMaxPapers(mailboxCount)
    L_HUDBlipSetup()
end

function L_MailboxDeliveryCleanup()
    UnLoadAnimationGroup("2_R03PaperRoute")
    NewspaperMakeHUDVisible(false)
    PedLockTarget(gPlayer, -1)
    L_HUDHidePaper()
    L_HUDBlipCleanup()
    PedSetWeaponNow(0, -1, 0)
end
