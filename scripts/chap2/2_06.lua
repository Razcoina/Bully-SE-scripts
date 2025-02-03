--[[ Changes to this file:
    * Modified function main, may require testing
]]

local bMissionOver = false
local bFailedDueToViolence = false
local bFailedDueToEunice = false
local bFailedDueToPinky = false
local bFailedDueToLola = false
local bFailedDueToGord = false
local bFailedDueToMoney = false
local theaterX, theaterY, theaterZ = 0, 0, 0
local bEndIt = false
local gBlipTheater = 0
local gBlipPinky = 0
local gBlipEunice = 0
local gBlipPetey = 0
local gBlipKissZone = 0
local objFirst = 0
local objPinky = 0
local objGord = 0
local objEunice = 0
local objChoco = 0
local objPetey = 0
local objFront = 0
local objTheater = 0
local idPinky = {}
local idPetey = {}
local idConst = {}
local idEunice = {}
local idGord = {}
local idLola = {}
local idBike = {}
local bStoleBike = false
local bGordChasingPlayer = false
local bGoneFarEnough = false
local bGetBack = false
local bSeenJimmyEunice = false
local bEuniceShmecked = false
local bGiftedEunice = false
local bKissHerHint = false
local kissX, kissY, kissZ = 0, 0, 0
local bPeteyRanInFear = false
local bThePlayerSawThem = false
local hitCount = 0
local objGordLure = 0
local gBlipGord = 0
local gBlipBike = 0
local bGordGoingForBike = false
local bGordReturnedBike = false
local bGordOffReturnedBike = false
local bAtLola = false
local bLolaSocial = false

function F_MissionInit()
    DisablePOI(false, true)
    AreaClearAllPeds()
    LoadActionTree("Act/Conv/2_06.act")
    LoadAnimationGroup("IDLE_SEXY_C")
    LoadAnimationGroup("NIS_2_06_1")
    LoadPedModels({
        38,
        13,
        85,
        74,
        30,
        25,
        35,
        34
    })
    LoadWeaponModels({ 431 })
    while not VehicleRequestModel(283) do
        Wait(0)
    end
    PedSocialOverrideLoad(24, "Mission/2_06WantGift.act")
    PedSocialOverrideLoad(18, "Mission/2_06Greeting.act")
    PedSocialOverrideLoad(19, "Mission/2_06Flee.act")
    PedSocialOverrideLoad(4, "Mission/2_06Follow.act")
    PedSocialOverrideLoad(15, "Mission/2_06Praise.act")
    idPinky = {
        id = -1,
        left = false,
        blip = 0,
        unique = 0,
        model = 38
    }
    idPetey = {
        id = -1,
        left = false,
        blip = 0,
        unique = 0,
        model = 13
    }
    idConst = {
        id = -1,
        left = false,
        blip = 0,
        unique = 0,
        model = 85
    }
    idEunice = {
        id = -1,
        left = false,
        blip = 0,
        unique = 0,
        model = 74
    }
    idGord = {
        id = -1,
        left = false,
        blip = 0,
        unique = 0,
        model = 30
    }
    idLola = {
        id = -1,
        left = false,
        blip = 0,
        unique = 0,
        model = 25
    }
    idBryce = {
        id = -1,
        left = false,
        blip = 0,
        unique = 0,
        model = 35
    }
    idJustin = {
        id = -1,
        left = false,
        blip = 0,
        unique = 0,
        model = 34
    }
    idBike = {
        id = -1,
        left = false,
        blip = 0,
        unique = 0,
        model = 283
    }
    idPinky.unique = PedGetUniqueModelStatus(idPinky.model)
    idPetey.unique = PedGetUniqueModelStatus(idPetey.model)
    idConst.unique = PedGetUniqueModelStatus(idConst.model)
    idEunice.unique = PedGetUniqueModelStatus(idEunice.model)
    idGord.unique = PedGetUniqueModelStatus(idGord.model)
    idLola.unique = PedGetUniqueModelStatus(idLola.model)
    PedSetUniqueModelStatus(idPinky.model, -1)
    PedSetUniqueModelStatus(idPetey.model, -1)
    PedSetUniqueModelStatus(idConst.model, -1)
    PedSetUniqueModelStatus(idEunice.model, -1)
    PedSetUniqueModelStatus(idGord.model, -1)
    PedSetUniqueModelStatus(idLola.model, -1)
    AreaSetDoorLockedToPeds(TRIGGER._RA_PREPDOOR14, true)
    AreaSetDoorLockedToPeds(TRIGGER._RA_PREPDOOR15, true)
    SpawnerSetActiveWithinRadius(346.873, 218.43, 4.95147, 20, false)
    idPinky.id = PedCreatePoint(idPinky.model, POINTLIST._2_06_PINKYWAITS, 1)
    PedRegisterSocialCallback(idPinky.id, 18, F_GreetPinky)
    PedSetEmotionTowardsPed(idPinky.id, gPlayer, 7, true)
    PedSetMissionCritical(idPinky.id, true, cbPinkyCritical, true)
    PedIgnoreStimuli(idPinky.id, true)
    PlayerSocialDisableActionAgainstPed(idPinky.id, 29, true)
    PlayerSocialDisableActionAgainstPed(idPinky.id, 28, true)
    PlayerSocialDisableActionAgainstPed(idPinky.id, 23, true)
    PlayerSocialDisableActionAgainstPed(idPinky.id, 32, true)
    AreaClearAllPeds()
    idGord.id = PedCreatePoint(idGord.model, POINTLIST._2_06_WAITERS, 1)
    idLola.id = PedCreatePoint(idLola.model, POINTLIST._2_06_WAITERS, 2)
    idBike.id = VehicleCreatePoint(idBike.model, POINTLIST._2_06_GORDSBIKE, 1)
    PedSetMissionCritical(idGord.id, true, cbMissionCriticalGord, true)
    PedSetMissionCritical(idLola.id, true, cbMissionCriticalLola, true)
    VehicleSetOwner(idBike.id, idGord.id)
    PedSetTypeToTypeAttitude(5, 4, 2)
    PedSetPedToTypeAttitude(idGord.id, 4, 4)
    PedSetPedToTypeAttitude(idLola.id, 5, 4)
    PedRecruitAlly(idGord.id, idLola.id, true)
    PedSetEmotionTowardsPed(idGord.id, idLola.id, 7, true)
    PedSetEmotionTowardsPed(idLola.id, idGord.id, 7, true)
    PedSetStationary(idGord.id, true)
    PedSetStationary(idLola.id, true)
    PedClearAllWeapons(idGord.id)
    idBryce.id = PedCreatePoint(idBryce.model, POINTLIST._2_06_OTHERWAITERS, 1)
    idJustin.id = PedCreatePoint(idJustin.model, POINTLIST._2_06_OTHERWAITERS, 2)
    PedSetMissionCritical(idBryce.id, true, cbMissionCriticalLola, true)
    PedSetMissionCritical(idJustin.id, true, cbMissionCriticalLola, true)
    theaterX, theaterY, theaterZ = GetPointList(POINTLIST._2_06_THEATER)
    Wait(250)
    PlayerSetPosPoint(POINTLIST._2_06_PLAYER_START)
    PedFaceObjectNow(gPlayer, idPinky.id, 2)
    CameraReset()
    CameraReturnToPlayer()
    CameraFade(1000, 1)
    Wait(1000)
end

function MissionSetup()
    MissionDontFadeIn()
    if IsMissionFromDebug() then
        AreaTransitionPoint(0, POINTLIST._2_06_CORONA, 1, true)
    end
    PlayCutsceneWithLoad("2-06", true)
    PlayerClearLastVehicle()
    AreaClearAllVehicles()
    DATLoad("2_06.DAT", 2)
    DATInit()
    if PlayerGetMoney() < 100 then
        PlayerSetMoney(100)
    end
end

function main() -- ! Modified
    PlayerSetPosPoint(POINTLIST._2_06_PLAYER_START)
    F_MissionInit()
    PedSetPosPoint(idPinky.id, POINTLIST._2_06_PINKYWAITS)
    objFirst = MissionObjectiveAdd("2_06_MAIN_OBJ")
    TextPrint("2_06_MAIN_OBJ", 4, 1)
    Wait(4000)
    F_StealTheBike()
    if not bFailedDueToViolence then
        F_GoingBackToTheater(1)
    end
    if not bFailedDueToViolence then
        F_Eunice()
    end
    if not bFailedDueToViolence then
        F_GoingBackToTheater(2)
    end
    if not bFailedDueToViolence then
        F_Petey()
    end
    if not bFailedDueToViolence then
        PedSetFlag(idPinky.id, 113, true)
        PlayerSetControl(0)
        F_MakePlayerSafeForNIS(true)
        BlipRemove(idPinky.blip)
        CameraFade(500, 0)
        Wait(501)
        CameraSetWidescreen(true)
        PlayerSetPosPoint(POINTLIST._2_06_NISPINKYEND, 1)
        PedSetPosPoint(idPinky.id, POINTLIST._2_06_NISPINKYEND, 2)
        PedLockTarget(idPinky.id, gPlayer)
        PedLockTarget(gPlayer, idPinky.id)
        PedSetMissionCritical(idPetey.id, false)
        PedSetMissionCritical(idConst.id, false)
        Wait(1000)
        CameraFade(500, 1)
        PedSetFlag(idPinky.id, 113, false)
        CameraSetFOV(30)
        CameraSetXYZ(339.1834, 219.69032, 6.469275, 339.5291, 220.626, 6.401867)
        PedSetActionNode(idPinky.id, "/Global/2_06/NISPINKY/Pinky/Pinky01", "Act/Conv/2_06.act")
        F_PlaySpeechAndWait(idPinky.id, "M_2_06", 66, "supersize")
        CameraSetFOV(30)
        CameraSetXYZ(337.77795, 224.96237, 6.407122, 338.51523, 224.28859, 6.359848)
        PedSetActionNode(gPlayer, "/Global/2_06/NISPINKY/Jimmy/Jimmy01", "Act/Conv/2_06.act")
        F_PlaySpeechAndWait(gPlayer, "M_2_06", 67, "supersize")
        CameraSetFOV(30)
        CameraSetXYZ(339.1834, 219.69032, 6.469275, 339.5291, 220.626, 6.401867)
        PedSetActionNode(idPinky.id, "/Global/2_06/NISPINKY/Pinky/Pinky02", "Act/Conv/2_06.act")
        F_PlaySpeechAndWait(idPinky.id, "M_2_06", 68, "supersize")
        PedSetActionNode(idPinky.id, "/Global/2_06/NISPINKY/Pinky/Pinky03", "Act/Conv/2_06.act")
        F_PlaySpeechAndWait(idPinky.id, "M_2_06", 69, "supersize")
        PedSetActionNode(idPinky.id, "/Global/2_06/NISPINKY/Pinky/Pinky04", "Act/Conv/2_06.act")
        F_PlaySpeechAndWait(idPinky.id, "M_2_06", 70, "supersize")
        CameraSetFOV(30)
        CameraSetXYZ(337.77795, 224.96237, 6.407122, 338.51523, 224.28859, 6.359848)
        PedSetActionNode(gPlayer, "/Global/2_06/NISPINKY/Jimmy/Jimmy02", "Act/Conv/2_06.act")
        F_PlaySpeechAndWait(gPlayer, "M_2_06", 71, "supersize")
        CameraReset()
        CameraDefaultFOV()
        CameraFollowPed(gPlayer)
        AreaSetDoorLockedToPeds(TRIGGER._RA_PREPDOOR14, false)
        PedMoveToPoint(idPinky.id, 1, POINTLIST._2_06_PINKYWALKOFF, 1, cbNull, 0.3, true)
        bMissionOver = true
        Wait(0)
        F_MakePlayerSafeForNIS(false)
        PedSetInvulnerable(idPinky.id, false)
        PlayerSetInvulnerable(false)
    end
    if bFailedDueToViolence then
        TextClear()
        Wait(1000)
        SoundPlayMissionEndMusic(false, 7)
        shared.b2_06Failed = true
        --[[
        if bFailedDueToPinky then
            MissionFail(true, true, "2_06_PINKYHURT")
        elseif bFailedDueToGord then
            MissionFail(true, true, "2_06_GORDKO")
        elseif bFailedDueToMoney then
            MissionFail(true, true, "CMN_STR_06")
        else
            MissionFail(true, true, "2_06_VIOLENCE")
        end
        ]] -- Changed to:
        if bFailedDueToPinky then
            MissionFail(false, true, "2_06_PINKYHURT")
        elseif bFailedDueToGord then
            MissionFail(false, true, "2_06_GORDKO")
        elseif bFailedDueToMoney then
            MissionFail(false, true, "CMN_STR_06")
        else
            MissionFail(false, true, "2_06_VIOLENCE")
        end
    else
        CameraFade(500, 0)
        Wait(501)
        CameraSetXYZ(341.7389, 222.5517, 6.215684, 340.77945, 222.27452, 6.265081)
        Wait(500)
        CameraFade(500, 1)
        Wait(501)
        MinigameSetCompletion("M_PASS", true, 1500)
        SoundPlayMissionEndMusic(true, 7)
        MinigameAddCompletionMsg("MRESPECT_PM5", 1)
        SetFactionRespect(5, GetFactionRespect(5) - 5)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        CameraFade(500, 0)
        Wait(501)
        CameraReset()
        CameraReturnToPlayer()
        MissionSucceed(false, false, false)
        Wait(500)
        CameraSetWidescreen(false)
        CameraFade(500, 1)
        Wait(501)
        PlayerSetControl(1)
    end
    PlayerSetControl(1)
end

function cbNull()
end

function cbGordInLine()
    PedSetEmotionTowardsPed(idGord.id, idLola.id, 7, true)
    PedSetEmotionTowardsPed(idLola.id, idGord.id, 7, true)
    PedSetWantsToSocializeWithPed(idGord.id, idLola.id)
    PedSetWantsToSocializeWithPed(idLola.id, idGord.id)
    PedSetStationary(idGord.id, true)
    PedSetStationary(idLola.id, true)
end

function F_StealTheBike()
    TextPrint("2_06_STEAL_BIKE", 5, 1)
    objGord = MissionObjectiveAdd("2_06_STEAL_BIKE")
    gBlipBike = AddBlipForCar(idBike.id, 0, 5)
    while not (not MissionActive() or bStoleBike or bFailedDueToViolence) do
        if not PedIsValid(idGord.id) or PedIsDead(idGord.id) or F_PedIsDead(idGord.id) then
            bFailedDueToViolence = true
            bFailedDueToGord = true
            break
        end
        if PedIsValid(idGord.id) and PedGetWhoHitMeLast(idGord.id) == gPlayer then
            if PedIsPlaying(idGord.id, "/Global/Vehicles/Bikes/ExecuteNodes/Attacks/GrapThorw", true) then
                PedClearHitRecord(idGord.id)
            elseif PedIsPlaying(idGord.id, "/Global/Vehicles/Bikes/ExecuteNodes/Attacks/GrapThorwLeft", true) then
                PedClearHitRecord(idGord.id)
            end
        end
        if not bGordChasingPlayer and (PlayerIsInVehicle(idBike.id) or not PedIsInAreaObject(idGord.id, idBike.id, 1, 12, 0)) then
            BlipRemove(gBlipBike)
            bGordChasingPlayer = true
            bGordGoingForBike = false
            bGordReturnedBike = false
            bGordOffReturnedBike = false
            bAtLola = false
            bLolaSocial = false
            if PedIsValid(idGord.id) and PedHasAlly(idGord.id) then
                PedSetMissionCritical(idLola.id, false)
                if PedIsValid(idGord.id) then
                    PedSetMissionCritical(idGord.id, false)
                end
                if PedIsValid(idGord.id) then
                    PedDismissAlly(idGord.id, idLola.id)
                end
                Wait(100)
                PedSetMissionCritical(idLola.id, true, cbMissionCriticalLola, true)
                if PedIsValid(idGord.id) then
                    PedSetMissionCritical(idGord.id, true, cbMissionCriticalGord, true)
                end
            end
            if PedIsValid(idGord.id) then
                PedSetStationary(idGord.id, false)
            end
            if PedIsValid(idGord.id) then
                PedStopSocializing(idGord.id)
            end
            PedStopSocializing(idLola.id)
            if PedIsValid(idGord.id) then
                PedStop(idGord.id)
            end
            if PedIsValid(idGord.id) then
                PedClearObjectives(idGord.id)
            end
            if PedIsValid(idGord.id) then
                PedSetPedToTypeAttitude(idGord.id, 13, 0)
            end
            if PedIsValid(idGord.id) then
                PedAttackPlayer(idGord.id, 3, true)
            end
            if PedIsValid(idBryce.id) then
                PedAttackPlayer(idBryce.id, 3, true)
            end
            if PedIsValid(idJustin.id) then
                PedAttackPlayer(idJustin.id, 3, true)
            end
            if PedIsValid(idGord.id) then
                SoundPlayAmbientSpeechEvent(idGord.id, "BIKE_STOLEN")
            end
            if PedIsValid(idGord.id) then
                gBlipGord = AddBlipForChar(idGord.id, 6, 0, 4)
                PedSetPunishmentPoints(idGord.id, 0)
            end
        end
        if not bGoneFarEnough and (not PlayerIsInTrigger(TRIGGER._2_06_BIKEZONE) and PlayerIsInVehicle(idBike.id) or not PedIsInTrigger(idGord.id, TRIGGER._2_06_BIKEZONE)) then
            BlipRemove(gBlipGord)
            MissionObjectiveComplete(objGord)
            F_LolaNIS()
            MissionObjectiveComplete(objGordLure)
            TextPrint("2_06_GETBACK", 5, 1)
            gBlipTheater = BlipAddPoint(POINTLIST._2_06_THEATER, 0, 1, 0)
            bStoleBike = true
            bGoneFarEnough = true
            bGetBack = true
        end
        if bGordChasingPlayer and not bGoneFarEnough and PlayerIsInTrigger(TRIGGER._2_06_BIKEZONE) and not bGordGoingForBike and not PlayerIsInAnyVehicle() then
            bPlayerScoopedBike = false
            if PedIsValid(idGord.id) then
                PedStop(idGord.id)
            end
            if PedIsValid(idGord.id) then
                PedClearObjectives(idGord.id)
            end
            if PedIsValid(idGord.id) and not PedIsInAreaObject(idGord.id, idBike.id, 1, 5, 0) then
                PedMoveToObject(idGord.id, idBike.id, 1, 1, nil, 4)
                while not (not PedIsValid(idGord.id) or PedIsInAreaObject(idGord.id, idBike.id, 1, 5, 0)) do
                    if bFailedDueToViolence then
                        break
                    end
                    if PlayerIsInVehicle(idBike.id) then
                        bPlayerScoopedBike = true
                        break
                    end
                    if not PedIsInTrigger(idGord.id, TRIGGER._2_06_BIKEZONE) then
                        break
                    end
                    F_CheckMoney()
                    Wait(0)
                end
            end
            if PedIsValid(idGord.id) then
                PedStop(idGord.id)
                PedClearObjectives(idGord.id)
                PedEnterVehicle(idGord.id, idBike.id)
            end
            while not (not PedIsValid(idGord.id) or PedIsInVehicle(idGord.id, idBike.id)) do
                if bFailedDueToViolence then
                    break
                end
                if PlayerIsInVehicle(idBike.id) then
                    bPlayerScoopedBike = true
                    break
                end
                if not PedIsInTrigger(idGord.id, TRIGGER._2_06_BIKEZONE) then
                    break
                end
                F_CheckMoney()
                Wait(0)
            end
            if PedIsValid(idGord.id) then
                PedSetPunishmentPoints(idGord.id, 0)
            end
            if not bPlayerScoopedBike then
                if PedIsValid(idGord.id) then
                    PedSetPunishmentPoints(idGord.id, 0)
                    PedMoveToPoint(idGord.id, 0, POINTLIST._2_06_GORDSBIKE, 1, cbStopGordsBike, 2.5)
                    PedSetPedToTypeAttitude(idGord.id, 13, 2)
                end
                bGordGoingForBike = true
            end
            bGordChasingPlayer = false
        end
        if not bGordChasingPlayer and not PlayerIsInVehicle(idBike.id) then
            if bGordGoingForBike and bGordReturnedBike and not bGordOffReturnedBike then
                if PedIsValid(idGord.id) then
                    PedStop(idGord.id)
                    PedClearObjectives(idGord.id)
                    Wait(100)
                    VehicleStop(idBike.id)
                    PedExitVehicle(idGord.id)
                    PedSetActionNode(idGord.id, "/Global/Vehicles/Bikes/Ground/Dismount/GetOff", "Act/Vehicles.act")
                end
                while PedIsValid(idGord.id) and PedIsInVehicle(idGord.id, idBike.id) do
                    if bFailedDueToViolence then
                        break
                    end
                    if not PedIsInTrigger(idGord.id, TRIGGER._2_06_BIKEZONE) then
                        break
                    end
                    F_CheckMoney()
                    Wait(0)
                end
                if PedIsValid(idGord.id) then
                    BlipRemove(gBlipGord)
                    PedStop(idGord.id)
                    PedClearObjectives(idGord.id)
                    gBlipBike = AddBlipForCar(idBike.id, 0, 5)
                    PedMoveToPoint(idGord.id, 1, POINTLIST._2_06_WAITERS, 1, cbBackAtLola, 0.3)
                end
                bGordOffReturnedBike = true
            end
            if bAtLola and not bLolaSocial and PedIsValid(idGord.id) then
                PedRecruitAlly(idGord.id, idLola.id, true)
                PedSetStationary(idGord.id, true)
                PedSetStationary(idLola.id, true)
                bLolaSocial = true
            end
        end
        F_CheckMoney()
        Wait(0)
    end
end

function cbBackAtLola()
    bAtLola = true
end

function cbStopGordsBike()
    if PedIsInVehicle(idGord.id, idBike.id) then
        bGordReturnedBike = true
    end
end

function F_LolaNIS()
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    PedSetMissionCritical(idGord.id, false)
    PedSetMissionCritical(idLola.id, false)
    PedStop(idGord.id)
    PedIgnoreStimuli(idPinky.id, true)
    PedIgnoreStimuli(idGord.id, true)
    PedClearObjectives(idGord.id)
    PedSetPosPoint(idLola.id, POINTLIST._2_06_WAITERS, 2)
    PedSetStationary(idLola.id, false)
    PedFaceHeading(idLola.id, 210, 0)
    PedStop(idLola.id)
    PedClearObjectives(idLola.id)
    CameraSetWidescreen(true)
    SoundSetAudioFocusCamera()
    PedSetPosPoint(idGord.id, POINTLIST._2_06_NISLOLA, 2)
    if PedIsValid(idBryce.id) then
        PedSetMissionCritical(idBryce.id, false)
        PedFollowFocus(idBryce.id, idGord.id)
    end
    if PedIsValid(idJustin.id) then
        PedSetMissionCritical(idJustin.id, false)
        PedFollowFocus(idJustin.id, idGord.id)
    end
    CameraSetFOV(40)
    CameraSetXYZ(344.96176, 217.97504, 6.145543, 345.2788, 218.92291, 6.174417)
    PedStop(idGord.id)
    PedClearObjectives(idGord.id)
    PedIgnoreStimuli(idGord.id, true)
    PedLockTarget(idGord.id, idLola.id)
    PedSetActionNode(idLola.id, "/Global/2_06/NISLOLA/Lola/Lola01", "Act/Conv/2_06.act")
    F_PlaySpeechAndWait(idLola.id, "M_2_06", 99, "supersize")
    PedMoveToPoint(idLola.id, 1, POINTLIST._2_06_NISLOLA, 1)
    Wait(3000)
    PedRecruitAlly(idLola.id, idGord.id)
    CameraSetFOV(35)
    SoundSetAudioFocusCamera()
    CameraSetXYZ(329.16235, 228.57582, 6.054848, 329.86694, 227.86958, 5.986094)
    PedSetActionNode(idGord.id, "/Global/2_06/NISLOLA/Gord/Gord01", "Act/Conv/2_06.act")
    SoundPlayScriptedSpeechEvent(idGord.id, "M_2_06", 99, "genric", false, false)
    while SoundSpeechPlaying(idGord.id) do
        Wait(0)
    end
    Wait(1000)
    CameraSetWidescreen(false)
    CameraReturnToPlayer(true)
    PedDelete(idLola.id)
    PedDelete(idGord.id)
    if PedIsValid(idBryce.id) then
        PedDelete(idBryce.id)
    end
    if PedIsValid(idJustin.id) then
        PedDelete(idJustin.id)
    end
    CameraReset()
    CameraFollowPed(gPlayer)
    F_MakePlayerSafeForNIS(false)
    SoundSetAudioFocusPlayer()
    PlayerSetControl(1)
end

function cbLolaLeaving(pedID)
    PedWander(pedID, 0)
    PedMakeAmbient(pedID)
end

function F_GoingBackToTheater(val)
    if val == 1 then
        F_SetupEunice()
        F_SetupWaitingPetey()
    elseif val == 2 then
        F_SetupPetey()
    end
    TextPrint("2_06_GETBACK", 5, 1)
    gBlipTheater = BlipAddPoint(POINTLIST._2_06_THEATER, 0, 1, 1)
    objTheater = MissionObjectiveAdd("2_06_GETBACK")
    while not (not (MissionActive() and bGetBack) or PlayerIsInAreaXYZ(theaterX, theaterY, theaterZ, 7.5, 0)) do
        if bFailedDueToViolence then
            break
        end
        if val == 1 then
            F_CheckMoney()
        end
        Wait(0)
    end
    BlipRemove(gBlipTheater)
    MissionObjectiveRemove(objTheater)
    if val == 1 then
        gBlipEunice = AddBlipForChar(idEunice.id, 6, 17, 4)
    end
    if val == 2 then
        TextPrint("2_06_PETEY", 5, 1)
        objPetey = MissionObjectiveAdd("2_06_PETEY")
        gBlipPetey = AddBlipForChar(idPetey.id, 6, 0, 4)
    end
    bGetBack = false
    bGoneFarEnough = false
end

function F_SetupEunice()
    idEunice.id = PedCreatePoint(idEunice.model, POINTLIST._2_06_WAITERS, 1)
    PedSetPedToTypeAttitude(idEunice.id, 13, 3)
    kissX, kissY, kissZ = GetPointList(POINTLIST._2_06_KISSKISS)
    PedSetRequiredGift(idEunice.id, 1)
    PedEnableGiftRequirement(idEunice.id, false)
    PedUseSocialOverride(idEunice.id, 18)
    PedUseSocialOverride(idEunice.id, 4)
    PedUseSocialOverride(idEunice.id, 24)
    PedRegisterSocialCallback(idEunice.id, 4, cbGiftedEunice)
    PedRegisterSocialCallback(idEunice.id, 24, cbGreetEunice)
    PlayerSocialOverrideLoad(32, "Mission/206GiveChocolates.act")
    PlayerSocialDisableActionAgainstPed(idEunice.id, 32, true)
    PlayerSocialDisableActionAgainstPed(idEunice.id, 28, true)
    PlayerSocialDisableActionAgainstPed(idEunice.id, 29, true)
    PedIgnoreAttacks(idEunice.id, true)
    PedOverrideStat(idEunice.id, 6, 0)
    PedOverrideStat(idEunice.id, 7, 0)
    RegisterGlobalEventHandler(7, cbMissionCriticalEunice)
end

local bPlayerGaveGift = false
local bKissCut = false
local objAlly = 0
local bBlippedStore = false
local bBlippedInsideStore = false
local gBlipStore = 0
local bGreetEunice01 = false
local bGreetEunice02 = false
local bStoreBoughtChocolates = false

function F_Eunice()
    TextPrint("2_06_EUNICE", 5, 1)
    objEunice = MissionObjectiveAdd("2_06_EUNICE")
    while not (not MissionActive() or bEuniceShmecked or bFailedDueToViolence) do
        if not bGiftedEunice and bGreetEunice01 and ItemGetCurrentNum(478) == 0 then
            if not bBlippedStore then
                BlipRemove(gBlipEunice)
                gBlipStore = BlipAddPoint(POINTLIST._2_06_YUMYUM, 0, 1)
                bBlippedStore = true
            end
            if not bBlippedInsideStore and AreaGetVisible() == 26 then
                BlipRemove(gBlipStore)
                gBlipStore = BlipAddPoint(POINTLIST._2_06_YUMYUM, 0, 2)
                bBlippedInsideStore = true
            end
            if bBlippedInsideStore and AreaGetVisible() == 0 then
                BlipRemove(gBlipStore)
                bBlippedStore = false
                bBlippedInsideStore = false
            end
            if not bGreetEunice01 or bBlippedInsideStore then
            end
        end
        if 1 <= ItemGetCurrentNum(478) and bGreetEunice01 and not shared.playerShopping and not bStoreBoughtChocolates then
            BlipRemove(gBlipStore)
            gBlipEunice = AddBlipForChar(idEunice.id, 6, 0, 4)
            while AreaGetVisible() ~= 0 do
                F_CheckMoney()
                if bFailedDueToViolence then
                    break
                end
                Wait(0)
            end
            bBlippedInsideStore = false
            bStoreBoughtChocolates = true
            MissionObjectiveRemove(objChoco)
            TextPrint("2_06_CHOCOGIVE", 5, 1)
            objChoco = MissionObjectiveAdd("2_06_CHOCOGIVE")
            PedSetFlag(idEunice.id, 132, true)
        end
        if not bGiftedEunice then
            F_CheckMoney()
            if bStoreBoughtChocolates and PlayerIsInAreaObject(idEunice.id, 2, 1.5, 0) and not PlayerIsInAnyVehicle() then
                F_GiftEunice()
                break
            end
        end
        if PedIsDoingTask(idEunice.id, "/Global/AI/GeneralObjectives/FleeObjective/Flee", true) then
            bFailedDueToViolence = true
            bFailedDueToEunice = true
        end
        if bFailedDueToViolence then
            break
        end
        Wait(0)
    end
    while not (not MissionActive() or bEuniceShmecked or bFailedDueToViolence) do
        if PedIsDoingTask(idEunice.id, "/Global/AI/GeneralObjectives/FleeObjective/Flee", true) then
            bFailedDueToViolence = true
            bFailedDueToEunice = true
        end
        if not bSeenJimmyEunice and PedCanSeeObject(idPinky.id, gPlayer, 2) and PedCanSeeObject(idPinky.id, idEunice.id, 2) then
            while SoundSpeechPlaying(idPinky.id) do
                Wait(0)
            end
            SoundPlayAmbientSpeechEvent(idPinky.id, "DISGUST")
            bSeenJimmyEunice = true
        end
        if bGiftedEunice and not bEuniceShmecked and bEuniceWithPlayer and PlayerIsInAreaXYZ(kissX, kissY, kissZ, 1, 0) then
            if not bKissHerHint then
                PedDismissAlly(gPlayer, idEunice.id)
                Wait(100)
                PedSetFlag(idEunice.id, 84, true)
                BlipRemove(gBlipKissZone)
                bKissHerHint = true
                F_KissEunice()
            end
            if bKissHerHint and bKissCut then
                BlipRemove(gBlipEunice)
                bEuniceShmecked = true
                bGetBack = true
                MissionObjectiveComplete(objAlly)
                PedLockTarget(gPlayer, -1)
                PedMakeAmbient(idEunice.id, false)
                PedWander(idEunice.id, 1)
            end
        elseif bGiftedEunice and not bEuniceShmecked and not PlayerIsInAreaXYZ(kissX, kissY, kissZ, 1, 0) then
            if bEuniceWithPlayer and not PedIsInAreaObject(gPlayer, idEunice.id, 2, 5, 0) then
                BlipRemove(gBlipEunice)
                BlipRemove(gBlipKissZone)
                PedDismissAlly(gPlayer, idEunice.id)
                PedStop(idEunice.id)
                PedClearObjectives(idEunice.id)
                PedMoveToPoint(idEunice.id, 1, POINTLIST._2_06_WAITERS, 1)
                gBlipEunice = AddBlipForChar(idEunice.id, 6, 0, 4)
                MissionObjectiveRemove(objAlly)
                TextPrint("2_06_GET_EUNICE", 5, 1)
                objAlly = MissionObjectiveAdd("2_06_GET_EUNICE")
                bEuniceWithPlayer = false
            elseif not bEuniceWithPlayer and PedIsInAreaObject(gPlayer, idEunice.id, 2, 1, 0) then
                BlipRemove(gBlipEunice)
                PedStop(idEunice.id)
                PedClearObjectives(idEunice.id)
                MissionObjectiveRemove(objAlly)
                TextPrint("2_06_ALLEY", 5, 1)
                objAlly = MissionObjectiveAdd("2_06_ALLEY")
                PedRecruitAlly(gPlayer, idEunice.id, true)
                bEuniceWithPlayer = true
                gBlipEunice = AddBlipForChar(idEunice.id, 6, 27, 4)
                gBlipKissZone = BlipAddXYZ(kissX, kissY, kissZ, 0, 1, 7)
            end
        end
        if F_PedIsDead(idEunice.id) then
            bFailedDueToViolence = true
        end
        Wait(0)
    end
end

function F_GiftEunice()
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    PlayerSetControl(0)
    bGiftedEunice = true
    PedSetMissionCritical(idEunice.id, false)
    SoundDisableSpeech_ActionTree()
    PedSetStationary(idEunice.id, false)
    PedFaceObject(idEunice.id, gPlayer, 3, 1)
    PedFaceObject(gPlayer, idEunice.id, 2, 1)
    PedLockTarget(gPlayer, idEunice.id, 3)
    PedMoveToObject(idEunice.id, gPlayer, 2, 0)
    while not PlayerIsInAreaObject(idEunice.id, 2, 0.8, 0) do
        Wait(0)
    end
    PedStop(idEunice.id)
    PedClearObjectives(idEunice.id)
    PedLockTarget(gPlayer, idEunice.id, 3)
    PedSetActionNode(gPlayer, "/Global/Player/Gifts/GiveChocolates", "Act/Player.act")
    while PedIsPlaying(gPlayer, "/Global/Player/Gifts/GiveChocolates", true) do
        Wait(0)
    end
    PedSetRequiredGift(idEunice.id, 0, false, true)
    PedLockTarget(gPlayer, -1)
    PedLockTarget(idEunice.id, -1)
    PedClearObjectives(idEunice.id)
    PedSetActionNode(idEunice.id, "/Global/2_06/2_06_Go", "Act/Conv/2_06.act")
    SoundEnableSpeech_ActionTree()
    SoundPlayAmbientSpeechEvent(idEunice.id, "THANKS_JIMMY")
    SoundPlayInteractiveStream("MS_MovieTixRomance.rsm", 0.5, 0, 1000)
    CameraReturnToPlayer()
    local chocoCount = ItemGetCurrentNum(478)
    chocoCount = chocoCount - 1
    if chocoCount < 0 then
        chocoCount = 0
    end
    ItemSetCurrentNum(478, chocoCount)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    MissionObjectiveComplete(objChoco)
    TextPrint("2_06_ALLEY", 5, 1)
    objAlly = MissionObjectiveAdd("2_06_ALLEY")
    PedRecruitAlly(gPlayer, idEunice.id, true)
    BlipRemove(gBlipEunice)
    bEuniceWithPlayer = true
    gBlipEunice = AddBlipForChar(idEunice.id, 6, 27, 4)
    gBlipKissZone = BlipAddXYZ(kissX, kissY, kissZ, 0, 1, 7)
end

function F_KissEunice()
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    CameraSetWidescreen(true)
    RegisterGlobalEventHandler(7, nil)
    PedSetMissionCritical(idEunice.id, false)
    SoundDisableSpeech_ActionTree()
    PedSetFlag(idEunice.id, 129, true)
    PedSetPedToTypeAttitude(idEunice.id, 13, 3)
    PedSetEmotionTowardsPed(idEunice.id, gPlayer, 7, true)
    PedSetFlag(idEunice.id, 84, true)
    PedSetRequiredGift(idEunice.id, 0, true)
    PedMoveToPoint(gPlayer, 0, POINTLIST._2_06_KISSKISS)
    local x, y, z = PedGetOffsetInWorldCoords(gPlayer, 0, 1, 0)
    PedFaceObject(gPlayer, idEunice.id, 2, 1)
    if not PedIsInAreaObject(idEunice.id, gPlayer, 2, 0.6, 0) then
        PedLockTarget(idEunice.id, gPlayer)
        PedMoveToPoint(idEunice.id, 0, POINTLIST._2_06_KISSKISS)
    end
    while not PedIsInAreaObject(idEunice.id, gPlayer, 2, 0.6, 0) do
        Wait(0)
    end
    PedFaceObject(gPlayer, idEunice.id, 2, 1)
    PedStop(idEunice.id)
    PedSetStationary(idEunice.id, true)
    Wait(250)
    PedLockTarget(gPlayer, idEunice.id, 1)
    PedSetActionNode(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt", "Act/Player.act")
    Wait(10)
    while not PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
        Wait(0)
    end
    Wait(250)
    CameraFade(500, 1)
    Wait(501)
    while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) or PedIsPlaying(idEunice.id, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
        Wait(0)
    end
    MusicFadeWithCamera(true)
    CameraSetWidescreen(false)
    PedUseSocialOverride(idEunice.id, 18, false)
    PedUseSocialOverride(idEunice.id, 4, false)
    PedUseSocialOverride(idEunice.id, 24, false)
    PlayerSetControl(1)
    CameraReturnToPlayer(true)
    CameraReset()
    CameraFollowPed(gPlayer)
    F_MakePlayerSafeForNIS(false)
    PedSetStationary(idEunice.id, false)
    bKissCut = true
    PedSetFlag(idEunice.id, 132, false)
    PedSetFlag(idEunice.id, 129, false)
    SoundEnableSpeech_ActionTree()
    SoundStopInteractiveStream()
end

function cbGiftedEunice()
    bPlayerGaveGift = true
end

function cbGreetEunice()
    if not bGreetEunice01 and ItemGetCurrentNum(478) == 0 then
        MissionObjectiveComplete(objEunice)
        SoundPlayAmbientSpeechEvent(idEunice.id, "GIFT_REQUEST_GIRL")
        TextPrint("2_06_CHOCOLATE", 5, 1)
        objChoco = MissionObjectiveAdd("2_06_CHOCOLATE")
        bGreetEunice01 = true
    elseif not bGreetEunice02 and ItemGetCurrentNum(478) > 0 and not bStoreBoughtChocolates then
        MissionObjectiveComplete(objEunice)
        SoundPlayScriptedSpeechEvent(idEunice.id, "M_1_02", 96, "genric", false, false)
        TextPrint("2_06_CHOCOGIVE", 5, 1)
        objChoco = MissionObjectiveAdd("2_06_CHOCOGIVE")
        bStoreBoughtChocolates = true
        bGreetEunice02 = true
    end
end

function F_GreetEunice()
    if ItemGetCurrentNum(478) == 0 then
        SoundPlayAmbientSpeechEvent(idEunice.id, "GIFT_REQUEST_GIRL")
    elseif ItemGetCurrentNum(478) > 0 then
        SoundPlayScriptedSpeechEvent(idEunice.id, "M_1_02", 96, "genric", false, false)
    end
    PedStopSocializing(idEunice.id)
end

function F_FollowEunice()
    bPlayerGaveGift = true
end

function F_SetupWaitingPetey()
    idPetey.id = PedCreatePoint(idPetey.model, POINTLIST._2_06_OTHERWAITERS, 1)
    idConst.id = PedCreatePoint(idConst.model, POINTLIST._2_06_OTHERWAITERS, 2)
    PedClearAllWeapons(idPetey.id)
    PedClearAllWeapons(idConst.id)
    PedSetEmotionTowardsPed(idPetey.id, idConst.id, 7, true)
    PedSetEmotionTowardsPed(idConst.id, idPetey.id, 7, true)
    PedSetMissionCritical(idPetey.id, true, cbMissionCriticalDudes, true)
    PedSetMissionCritical(idConst.id, true, cbMissionCriticalDudes, true)
    PlayerSocialDisableActionAgainstPed(idPetey.id, 29, true)
    PlayerSocialDisableActionAgainstPed(idPetey.id, 28, true)
    PlayerSocialDisableActionAgainstPed(idPetey.id, 23, true)
    PlayerSocialDisableActionAgainstPed(idPetey.id, 35, true)
    PlayerSocialDisableActionAgainstPed(idConst.id, 29, true)
    PlayerSocialDisableActionAgainstPed(idConst.id, 28, true)
    PlayerSocialDisableActionAgainstPed(idConst.id, 23, true)
    PlayerSocialDisableActionAgainstPed(idConst.id, 35, true)
end

function F_SetupPetey()
    PedSetPosPoint(idPetey.id, POINTLIST._2_06_WAITERS, 1)
    PedSetPosPoint(idConst.id, POINTLIST._2_06_WAITERS, 2)
    PedSetEmotionTowardsPed(idPetey.id, idConst.id, 7, true)
    PedSetEmotionTowardsPed(idConst.id, idPetey.id, 7, true)
    PedRecruitAlly(idPetey.id, idConst.id, true)
    PedSetMissionCritical(idPetey.id, true, cbMissionCriticalDudes, true)
    PedSetMissionCritical(idConst.id, true, cbMissionCriticalDudes, true)
end

function F_Petey()
    while not (not (not PedIsAlerted(idPetey.id, 500) and PedIsInAreaObject(idPetey.id, gPlayer, 2, 8, 0)) or bFailedDueToViolence) do
        Wait(0)
    end
    PedSetFlag(idPinky.id, 113, true)
    if not bFailedDueToViolence then
        F_PeteyNIS()
    end
end

function F_PeteyNIS()
    PedFaceObject(gPlayer, idPetey.id, 2, 1)
    PedLockTarget(gPlayer, idPetey.id)
    Wait(1000)
    PedFaceObject(idPetey.id, gPlayer, 2, 1)
    PedLockTarget(idPetey.id, gPlayer)
    SoundPlayAmbientSpeechEvent(idPetey.id, "TAUNT_RESPONSE_CRY")
    Wait(1000)
    PedFaceObject(idConst.id, gPlayer, 2, 1)
    SoundPlayAmbientSpeechEvent(idConst.id, "INDIGNANT")
    PedMoveToPoint(idPetey.id, 1, POINTLIST._2_06_PETEYRUNSOFF, 1)
    PedMoveToPoint(idConst.id, 1, POINTLIST._2_06_PETEYRUNSOFF, 1)
    while SoundSpeechPlaying(idPetey.id) do
        Wait(0)
    end
    while SoundSpeechPlaying(idConst.id) do
        Wait(0)
    end
    Wait(500)
    bEndIt = true
end

function cbGreetPinky()
    --print("=== Pinky Greeted ===")
    if bPeteyRanInFear then
        MissionObjectiveComplete(objPinky)
        bEndIt = true
    else
        SoundPlayScriptedSpeechEvent(idPinky.id, "M_2_06", 3, "genric", false, false)
    end
end

function F_GreetPinky()
    --print("=== Pinky Greeted ===")
    if bPeteyRanInFear then
        MissionObjectiveComplete(objPinky)
        bEndIt = true
    else
        SoundPlayScriptedSpeechEvent(idPinky.id, "M_2_06", 3, "genric", false, false)
    end
end

function cbPinkyCritical(pedID)
    --print("==== Pinky Hit =====")
    bFailedDueToViolence = true
    bFailedDueToPinky = true
    if idPinky.id and PedIsValid(idPinky.id) then
        PedSetInvulnerable(idPinky.id, false)
        PedSetFlag(idPinky.id, 113, false)
        PedSetStationary(idPinky.id, false)
        PedIgnoreStimuli(idPinky.id, false)
        PedMakeAmbient(idPinky.id)
    end
end

function cbMissionCriticalLola(pedID)
    if PedGetWhoHitMeLast(idLola.id) == gPlayer then
        --print("==== Lola got hit =====")
        bFailedDueToViolence = true
        bFailedDueToLola = true
    end
end

local gGordHitCount = 0

function cbMissionCriticalGord(pedID)
    --print("==== Gord Dead =====")
    if pedID == idGord.id then
        if PedIsValid(idGord.id) and PedGetWhoHitMeLast(idGord.id) == gPlayer and not PedIsPlaying(idGord.id, "/Global/Vehicles/Bikes/ExecuteNodes/Attacks/GrapThorw", true) and not PedIsPlaying(idGord.id, "/Global/Vehicles/Bikes/ExecuteNodes/Attacks/GrapThorwLeft", true) then
            --print("==== Gord Hit By Player ====")
            gGordHitCount = gGordHitCount + 1
            PedClearHitRecord(idGord.id)
        end
        if gGordHitCount == 1 then
            bFailedDueToViolence = true
            bFailedDueToGord = true
        end
        PedClearHitRecord(idGord.id)
    end
end

function cbMissionCriticalDudes(pedID)
    --print("==== Dudes Attacked =====")
    bFailedDueToViolence = true
end

local gEuniceHitCount = 0

function cbMissionCriticalEunice(pedID)
    --print("==== Eunice Dead =====")
    if pedID == idEunice.id and PedIsValid(idEunice.id) then
        gEuniceHitCount = gEuniceHitCount + 1
        if gEuniceHitCount == 1 then
            TutorialShowMessage("TUT_APOLOGY1", 4000, false)
        else
            --print("=== Hit Again ===")
            if F_PedIsDead(idEunice.id) or PedGetWhoHitMeLast(idEunice.id) == gPlayer then
                bFailedDueToViolence = true
                bFailedDueToEunice = true
                return
            end
            if PedGetVehicleWhoHitMeLast(idEunice.id) ~= nil then
                bFailedDueToViolence = true
                bFailedDueToEunice = true
                return
            end
        end
    end
end

function TimerPassed(time)
    if time <= GetTimer() then
        return true
    else
        return false
    end
end

function TimerCheck(timer, atime)
    local min, max = 0, 0
    min = atime
    max = atime + __timerDelta
    if timer >= min and timer < max then
        return true
    end
    return false
end

local buttonpressed = false
local rarrowbutton = false
local larrowbutton = false
local tblDebugBlip = {
    { blip = 0 },
    { blip = 0 },
    { blip = 0 },
    { blip = 0 },
    { blip = 0 }
}

function DEBUG_LINEINFO()
end

function F_PedCleanUp(pedID)
    if PedIsValid(pedID) then
        if shared.b2_06Failed then
            PedSetMissionCritical(pedID, false)
            BlipRemoveFromChar(pedID)
            PedMakeAmbient(pedID, false)
            PedSetStationary(pedID, false)
        else
            PedDelete(pedID)
        end
    end
end

function MissionCleanup()
    PedSetUniqueModelStatus(idPinky.model, idPinky.unique)
    PedSetUniqueModelStatus(idPetey.model, idPetey.unique)
    PedSetUniqueModelStatus(idConst.model, idConst.unique)
    PedSetUniqueModelStatus(idEunice.model, idEunice.unique)
    PedSetUniqueModelStatus(idGord.model, idGord.unique)
    PedSetUniqueModelStatus(idLola.model, idLola.unique)
    if idPinky.id and PedIsValid(idPinky.id) then
        PedSetFlag(idPinky.id, 113, false)
        PedSetInvulnerable(idPinky.id, false)
        PedIgnoreStimuli(idPinky.id, false)
        PedSetStationary(idPinky.id, false)
    end
    EnablePOI(true, true)
    SpawnerSetActiveWithinRadius(346.873, 218.43, 4.95147, 20, true)
    RegisterGlobalEventHandler(7, nil)
    F_PedCleanUp(idGord.id)
    F_PedCleanUp(idLola.id)
    F_PedCleanUp(idBryce.id)
    F_PedCleanUp(idJustin.id)
    F_PedCleanUp(idPetey.id)
    F_PedCleanUp(idEunice.id)
    F_PedCleanUp(idConst.id)
    F_PedCleanUp(idPinky.id)
    if PedHasAlly(gPlayer) then
        local pedID = PedGetAllyFollower(gPlayer)
        PedDismissAlly(gPlayer, pedID)
        PedMakeAmbient(pedID)
    end
    if VehicleIsValid(idBike.id) then
        VehicleMakeAmbient(idBike.id)
    end
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    BlipRemove(gBlipTheater)
    AreaSetDoorLockedToPeds(TRIGGER._RA_PREPDOOR14, false)
    AreaSetDoorLockedToPeds(TRIGGER._RA_PREPDOOR15, false)
    RadarRestoreMinMax()
    UnLoadAnimationGroup("IDLE_SEXY_C")
    DATUnload(2)
    DATInit()
end

function F_PlayerGiveGiftCallback()
    StopAmbientPedAttacks()
    PlayerSocialEnableOverrideAgainstPed(idEunice.id, 32, false)
    bPlayerGaveGift = true
end

function F_CheckMoney()
    if PlayerGetMoney() < 100 and ItemGetCurrentNum(478) == 0 and not shared.playerShopping then
        bFailedDueToViolence = true
        bFailedDueToMoney = true
    end
end
