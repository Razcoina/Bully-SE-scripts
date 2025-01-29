--[[ Changes to this file:
    * Assigned nil to local variable gObserver twice. Why? Because that's the way R* did!!!
    * Added local variables L35_1 and L36_1
    * Removed function GiveCamera, not present in original script
    * Modified function MissionInit, may require testing
    * Modified function PhotoCheckTargetsInFrame, may require testing
    * Modified function PhotoVerifyGoodShot, may require testing
]]

local MAX_PROP_DAMAGED_ALLOWED = 2
local MISSION_RUNNING = 0
local MISSION_PASS = 1
local MISSION_FAIL = 2
local gMissionState = MISSION_RUNNING
local gMissionStage
local gBonfireStartTime = 2000
local gObjective, gObjectiveBlip
local gDropoutModels = {}
local gGreaserModels = {}
local gLeon, gDuncan, gOtto, gJerry, gDarby, gGuy1, gGas, gTorch
local gObserver = nil, nil -- Added this, moved variable from previous line
local gBonfireDropouts = {}
local bPhotoGood = false
local bBonFireStarted = false
local bBonFireTimerDone = false
local gBigSmoke, tblFires
local gRatPackers = {}
local gPropsDamagedCount = 0
local bPropsDestroyed = false

function DropoutsAllAggro()
    --print(">>>[RUI]", "!!DropoutsAllAggro")
    if bDropoutsAreAgro then
        return
    end
    DropoutGoAggro(gPartierB01)
    DropoutGoAggro(gPartierB02)
    DropoutGoAggro(gPartierFire)
    bDropoutsAreAgro = true
end

function DropoutGoAggro(guy)
    if guy and F_PedExists(guy) then
        PedSetActionNode(guy, "/Global/5_02/animations/RatPacking/null", "Act/Conv/5_02.act")
        PedStop(guy)
        PedAttackPlayer(guy, 3)
        --print(">>>[RUI]", "++DropoutGoAggro")
    else
        --print(">>>[RUI]", "**DropoutsGoAggro: bad ped")
    end
end

function DropoutsCleanup()
    --print(">>>[RUI]", "--DropoutsCleanup")
    if gBonfireDropouts then
        for _, guy in gBonfireDropouts do
            if guy then
                MakeAmbient(guy.id)
            end
        end
    end
    gBonfireDropouts = nil
    MakeAmbient(gPartierB01)
    MakeAmbient(gPartierB02)
    MakeAmbient(gPartierFire)
    RatPackersCleanup()
end

function PrepCleanup()
    --print(">>>[RUI]", "--PrepCleanup")
    MakeAmbient(gDarby)
    MakeAmbient(gGuy1)
end

function F_WaitForSpeechSkippable(ped)
    local bSkipped = false
    while SoundSpeechPlaying(ped) do
        if F_IsButtonPressedWithDelayCheck(7, 0) then
            bSkipped = true
            break
        end
        Wait(0)
    end
    if bSkipped then
        --print(">>>[RUI]", "!!F_WaitForSpeechSkippable stopped")
        SoundStopCurrentSpeechEvent(ped)
    end
    return not bSkipped
end

function FailPlayerForLeavingDocks()
    if not PlayerIsInTrigger(TRIGGER._5_02_GAMEAREA) then
        TextPrint("5_02_AREAWARN", 0.5, 1)
        if not PlayerIsInTrigger(TRIGGER._5_02_FAILTRIGGER) then
            return true
        end
    end
    return false
end

function ObjectiveBlipUpdate(newBlip)
    --print(">>>[RUI]", "!!ObjectiveBlipUpdate")
    if newBlip then
        BlipClean(gObjectiveBlip)
        gObjectiveBlip = newBlip
    elseif gObjectiveBlip then
        gObjectiveBlip = BlipClean(gObjectiveBlip)
    end
end

function BlipClean(blip)
    --print(">>>[RUI]", "!!BlipClean")
    if blip and blip ~= -1 then
        BlipRemove(blip)
    end
    return nil
end

function MakeAmbient(ped)
    if F_PedExists(ped) then
        PedMakeAmbient(ped)
    end
end

function DestroyablePropsInitTable()
    --print(">>>[RUI]", "!!DestroyablePropsInitTable")
    gDestroyables = {
        {
            hash = ObjectNameToHashID("iware_StatuePrinc"),
            name = "iware_StatuePrinc"
        },
        {
            hash = ObjectNameToHashID("iware_ExoticPlant1"),
            name = "iware_ExoticPlant1"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pPlant"),
            name = "iware_DPI_pPlant"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_PlanterB"),
            name = "iware_DPI_PlanterB"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Planters01"),
            name = "iware_DPI_Planters01"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_HatSVase02"),
            name = "iware_DPE_HatSVase02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pPlant01"),
            name = "iware_DPI_pPlant01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pVase01"),
            name = "iware_DPI_pVase01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_PlanterB01"),
            name = "iware_DPI_PlanterB01"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_HatVase02"),
            name = "iware_DPE_HatVase02"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_HatVase03"),
            name = "iware_DPE_HatVase03"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pPlant03"),
            name = "iware_DPI_pPlant03"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_VFlytrap02"),
            name = "iware_DPI_VFlytrap02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_VFlytrap03"),
            name = "iware_DPI_VFlytrap03"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_VFlytrap04"),
            name = "iware_DPI_VFlytrap04"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_VFlytrap05"),
            name = "iware_DPI_VFlytrap05"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Planters03"),
            name = "iware_DPI_Planters03"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Planters06"),
            name = "iware_DPI_Planters06"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pVase06"),
            name = "iware_DPI_pVase06"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pVase08"),
            name = "iware_DPI_pVase08"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_VFlytrap06"),
            name = "iware_DPI_VFlytrap06"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_HatSVase04"),
            name = "iware_DPE_HatSVase04"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pPlant04"),
            name = "iware_DPI_pPlant04"
        },
        {
            hash = ObjectNameToHashID("iware_ExoticPlant25"),
            name = "iware_ExoticPlant25"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pPlant05"),
            name = "iware_DPI_pPlant05"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_HatVase04"),
            name = "iware_DPE_HatVase04"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_HatVase05"),
            name = "iware_DPE_HatVase05"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_PlanterB02"),
            name = "iware_DPI_PlanterB02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_PlanterB03"),
            name = "iware_DPI_PlanterB03"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pPlant06"),
            name = "iware_DPI_pPlant06"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate141"),
            name = "iware_DPI_Lcrate141"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Stool2"),
            name = "iware_DPI_Stool2"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_ChairPile"),
            name = "iware_DPI_ChairPile"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_LampMini"),
            name = "iware_DPI_LampMini"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CardBox"),
            name = "iware_DPI_CardBox"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_TVmini"),
            name = "iware_DPI_TVmini"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_StableS"),
            name = "iware_DPI_StableS"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_AsyTable"),
            name = "iware_DPI_AsyTable"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_GnomeB"),
            name = "iware_DPE_GnomeB"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_GnomeA"),
            name = "iware_DPE_GnomeA"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_BirdBath"),
            name = "iware_DPE_BirdBath"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_BenchB"),
            name = "iware_DPE_BenchB"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes"),
            name = "iware_WH_Mcardboxes"
        },
        {
            hash = ObjectNameToHashID("iware_WHCoffTbl"),
            name = "iware_WHCoffTbl"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes"),
            name = "iware_WH_Lcardboxes"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates"),
            name = "iware_WH_Crates"
        },
        {
            hash = ObjectNameToHashID("iware_WHChandalier"),
            name = "iware_WHChandalier"
        },
        {
            hash = ObjectNameToHashID("iware_WHCoffTbl2"),
            name = "iware_WHCoffTbl2"
        },
        {
            hash = ObjectNameToHashID("iware_WH_dresser2"),
            name = "iware_WH_dresser2"
        },
        {
            hash = ObjectNameToHashID("iware_WHChesterF"),
            name = "iware_WHChesterF"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_1"),
            name = "iware_Statuebust_1"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_2"),
            name = "iware_Statuebust_2"
        },
        {
            hash = ObjectNameToHashID("iware_Statuemask"),
            name = "iware_Statuemask"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_GlassCart01"),
            name = "iware_DPE_GlassCart01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_TerriumsL01"),
            name = "iware_DPI_TerriumsL01"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Detour04"),
            name = "iware_DPE_Detour04"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pDoorBrk01"),
            name = "iware_DPI_pDoorBrk01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pCabDoor01"),
            name = "iware_DPI_pCabDoor01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_TerriumsS01"),
            name = "iware_DPI_TerriumsS01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_prepFlwrGls01"),
            name = "iware_DPI_prepFlwrGls01"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_GlassCart02"),
            name = "iware_DPE_GlassCart02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_TerriumsL02"),
            name = "iware_DPI_TerriumsL02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pDoorBrk02"),
            name = "iware_DPI_pDoorBrk02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pCabDoor02"),
            name = "iware_DPI_pCabDoor02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_TerriumsS02"),
            name = "iware_DPI_TerriumsS02"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Detour06"),
            name = "iware_DPE_Detour06"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Detour08"),
            name = "iware_DPE_Detour08"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Detour11"),
            name = "iware_DPE_Detour11"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Detour12"),
            name = "iware_DPE_Detour12"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Detour14"),
            name = "iware_DPE_Detour14"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Detour16"),
            name = "iware_DPE_Detour16"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes01"),
            name = "iware_WH_Lcardboxes01"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes02"),
            name = "iware_WH_Lcardboxes02"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates01"),
            name = "iware_WH_Crates01"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates02"),
            name = "iware_WH_Crates02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate142"),
            name = "iware_DPI_Lcrate142"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk151"),
            name = "iware_DPI_CrateBrk151"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk155"),
            name = "iware_DPI_CrateBrk155"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk156"),
            name = "iware_DPI_CrateBrk156"
        },
        {
            hash = ObjectNameToHashID("iware_StatuePrinc03"),
            name = "iware_StatuePrinc03"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate143"),
            name = "iware_DPI_Lcrate143"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Hcolumn01"),
            name = "iware_DPE_Hcolumn01"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Hcolumn02"),
            name = "iware_DPE_Hcolumn02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate144"),
            name = "iware_DPI_Lcrate144"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates03"),
            name = "iware_WH_Crates03"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk157"),
            name = "iware_DPI_CrateBrk157"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk158"),
            name = "iware_DPI_CrateBrk158"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates05"),
            name = "iware_WH_Crates05"
        },
        {
            hash = ObjectNameToHashID("iware_WHChesterF02"),
            name = "iware_WHChesterF02"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes03"),
            name = "iware_WH_Lcardboxes03"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes04"),
            name = "iware_WH_Lcardboxes04"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate145"),
            name = "iware_DPI_Lcrate145"
        },
        {
            hash = ObjectNameToHashID("iware_WHCoffTbl03"),
            name = "iware_WHCoffTbl03"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes05"),
            name = "iware_WH_Lcardboxes05"
        },
        {
            hash = ObjectNameToHashID("iware_WHChandalier01"),
            name = "iware_WHChandalier01"
        },
        {
            hash = ObjectNameToHashID("iware_WHChandalier02"),
            name = "iware_WHChandalier02"
        },
        {
            hash = ObjectNameToHashID("iware_WHChandalier03"),
            name = "iware_WHChandalier03"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes01"),
            name = "iware_WH_Mcardboxes01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate147"),
            name = "iware_DPI_Lcrate147"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes02"),
            name = "iware_WH_Mcardboxes02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CardBox01"),
            name = "iware_DPI_CardBox01"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_BirdBath01"),
            name = "iware_DPE_BirdBath01"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes05"),
            name = "iware_WH_Mcardboxes05"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_ChairPile01"),
            name = "iware_DPI_ChairPile01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_LampMini01"),
            name = "iware_DPI_LampMini01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_AsyTable02"),
            name = "iware_DPI_AsyTable02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk162"),
            name = "iware_DPI_CrateBrk162"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk163"),
            name = "iware_DPI_CrateBrk163"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk164"),
            name = "iware_DPI_CrateBrk164"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk165"),
            name = "iware_DPI_CrateBrk165"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk166"),
            name = "iware_DPI_CrateBrk166"
        },
        {
            hash = ObjectNameToHashID("iware_WHRichChair08"),
            name = "iware_WHRichChair08"
        },
        {
            hash = ObjectNameToHashID("iware_WHRichChair10"),
            name = "iware_WHRichChair10"
        },
        {
            hash = ObjectNameToHashID("iware_WHRichChair11"),
            name = "iware_WHRichChair11"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk169"),
            name = "iware_DPI_CrateBrk169"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk170"),
            name = "iware_DPI_CrateBrk170"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk171"),
            name = "iware_DPI_CrateBrk171"
        },
        {
            hash = ObjectNameToHashID("iware_WHRichChair16"),
            name = "iware_WHRichChair16"
        },
        {
            hash = ObjectNameToHashID("iware_WHRichChair13"),
            name = "iware_WHRichChair13"
        },
        {
            hash = ObjectNameToHashID("iware_StatuePrinc05"),
            name = "iware_StatuePrinc05"
        },
        {
            hash = ObjectNameToHashID("iware_WHCoffTbl05"),
            name = "iware_WHCoffTbl05"
        },
        {
            hash = ObjectNameToHashID("iware_WHChandalier04"),
            name = "iware_WHChandalier04"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_03"),
            name = "iware_Statuebust_03"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_05"),
            name = "iware_Statuebust_05"
        },
        {
            hash = ObjectNameToHashID("iware_Statuemask01"),
            name = "iware_Statuemask01"
        },
        {
            hash = ObjectNameToHashID("iware_StatuePrinc06"),
            name = "iware_StatuePrinc06"
        },
        {
            hash = ObjectNameToHashID("iware_WHRichChair14"),
            name = "iware_WHRichChair14"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate149"),
            name = "iware_DPI_Lcrate149"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Hcolumn06"),
            name = "iware_DPE_Hcolumn06"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate150"),
            name = "iware_DPI_Lcrate150"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates11"),
            name = "iware_WH_Crates11"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk167"),
            name = "iware_DPI_CrateBrk167"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk168"),
            name = "iware_DPI_CrateBrk168"
        },
        {
            hash = ObjectNameToHashID("iware_WHChesterF03"),
            name = "iware_WHChesterF03"
        },
        {
            hash = ObjectNameToHashID("iware_WHChesterF04"),
            name = "iware_WHChesterF04"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes13"),
            name = "iware_WH_Lcardboxes13"
        },
        {
            hash = ObjectNameToHashID("iware_WHChandalier05"),
            name = "iware_WHChandalier05"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes07"),
            name = "iware_WH_Mcardboxes07"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate152"),
            name = "iware_DPI_Lcrate152"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes16"),
            name = "iware_WH_Lcardboxes16"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes08"),
            name = "iware_WH_Mcardboxes08"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate153"),
            name = "iware_DPI_Lcrate153"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes11"),
            name = "iware_WH_Mcardboxes11"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Stool04"),
            name = "iware_DPI_Stool04"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate09"),
            name = "iware_WhiskyCrate09"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Whisky02"),
            name = "iware_WH_Whisky02"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate11"),
            name = "iware_WhiskyCrate11"
        },
        {
            hash = ObjectNameToHashID("iware_CargoBox13"),
            name = "iware_CargoBox13"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CardBox02"),
            name = "iware_DPI_CardBox02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CardBox03"),
            name = "iware_DPI_CardBox03"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes12"),
            name = "iware_WH_Mcardboxes12"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_TVmini01"),
            name = "iware_DPI_TVmini01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_LampMini07"),
            name = "iware_DPI_LampMini07"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_LampMini08"),
            name = "iware_DPI_LampMini08"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_ChairPile02"),
            name = "iware_DPI_ChairPile02"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate154"),
            name = "iware_DPI_Lcrate154"
        },
        {
            hash = ObjectNameToHashID("iware_WHCoffTbl07"),
            name = "iware_WHCoffTbl07"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes14"),
            name = "iware_WH_Mcardboxes14"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate155"),
            name = "iware_DPI_Lcrate155"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes15"),
            name = "iware_WH_Mcardboxes15"
        },
        {
            hash = ObjectNameToHashID("iware_Statuemask02"),
            name = "iware_Statuemask02"
        },
        {
            hash = ObjectNameToHashID("iware_Statuemask03"),
            name = "iware_Statuemask03"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate12"),
            name = "iware_WhiskyCrate12"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_BenchB02"),
            name = "iware_DPE_BenchB02"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes25"),
            name = "iware_WH_Lcardboxes25"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes26"),
            name = "iware_WH_Lcardboxes26"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes29"),
            name = "iware_WH_Lcardboxes29"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag1"),
            name = "iware_WHseedbag1"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag03"),
            name = "iware_WHseedbag03"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag04"),
            name = "iware_WHseedbag04"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag05"),
            name = "iware_WHseedbag05"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag06"),
            name = "iware_WHseedbag06"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag08"),
            name = "iware_WHseedbag08"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate13"),
            name = "iware_WhiskyCrate13"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Whisky04"),
            name = "iware_WH_Whisky04"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates20"),
            name = "iware_WH_Crates20"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk173"),
            name = "iware_DPI_CrateBrk173"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_CrateBrk175"),
            name = "iware_DPI_CrateBrk175"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes17"),
            name = "iware_WH_Mcardboxes17"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_BirdBath06"),
            name = "iware_DPE_BirdBath06"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_BenchB06"),
            name = "iware_DPE_BenchB06"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_BirdBath07"),
            name = "iware_DPE_BirdBath07"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_ChairPile05"),
            name = "iware_DPI_ChairPile05"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_ChairPile06"),
            name = "iware_DPI_ChairPile06"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_StableS01"),
            name = "iware_DPI_StableS01"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_AsyTable03"),
            name = "iware_DPI_AsyTable03"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_GnomeB02"),
            name = "iware_DPE_GnomeB02"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Whisky07"),
            name = "iware_WH_Whisky07"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_GnomeA03"),
            name = "iware_DPE_GnomeA03"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_ChairPile07"),
            name = "iware_DPI_ChairPile07"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate157"),
            name = "iware_DPI_Lcrate157"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes21"),
            name = "iware_WH_Mcardboxes21"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_LampMini09"),
            name = "iware_DPI_LampMini09"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag13"),
            name = "iware_WHseedbag13"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag14"),
            name = "iware_WHseedbag14"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes22"),
            name = "iware_WH_Mcardboxes22"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes35"),
            name = "iware_WH_Lcardboxes35"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes36"),
            name = "iware_WH_Lcardboxes36"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes37"),
            name = "iware_WH_Lcardboxes37"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag15"),
            name = "iware_WHseedbag15"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag16"),
            name = "iware_WHseedbag16"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag18"),
            name = "iware_WHseedbag18"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate23"),
            name = "iware_WhiskyCrate23"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate25"),
            name = "iware_WhiskyCrate25"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_07"),
            name = "iware_Statuebust_07"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_08"),
            name = "iware_Statuebust_08"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_10"),
            name = "iware_Statuebust_10"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_11"),
            name = "iware_Statuebust_11"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_13"),
            name = "iware_Statuebust_13"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_14"),
            name = "iware_Statuebust_14"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_16"),
            name = "iware_Statuebust_16"
        },
        {
            hash = ObjectNameToHashID("iware_Statuebust_17"),
            name = "iware_Statuebust_17"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes38"),
            name = "iware_WH_Lcardboxes38"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate158"),
            name = "iware_DPI_Lcrate158"
        },
        {
            hash = ObjectNameToHashID("iware_Statuemask05"),
            name = "iware_Statuemask05"
        },
        {
            hash = ObjectNameToHashID("iware_Statuemask06"),
            name = "iware_Statuemask06"
        },
        {
            hash = ObjectNameToHashID("iware_Statuemask07"),
            name = "iware_Statuemask07"
        },
        {
            hash = ObjectNameToHashID("iware_Statuemask08"),
            name = "iware_Statuemask08"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes40"),
            name = "iware_WH_Lcardboxes40"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate27"),
            name = "iware_WhiskyCrate27"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_Lcrate159"),
            name = "iware_DPI_Lcrate159"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes42"),
            name = "iware_WH_Lcardboxes42"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates24"),
            name = "iware_WH_Crates24"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes43"),
            name = "iware_WH_Lcardboxes43"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes45"),
            name = "iware_WH_Lcardboxes45"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag27"),
            name = "iware_WHseedbag27"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag28"),
            name = "iware_WHseedbag28"
        },
        {
            hash = ObjectNameToHashID("iware_WHChesterF05"),
            name = "iware_WHChesterF05"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes46"),
            name = "iware_WH_Lcardboxes46"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates25"),
            name = "iware_WH_Crates25"
        },
        {
            hash = ObjectNameToHashID("iware_WHRichChair20"),
            name = "iware_WHRichChair20"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes23"),
            name = "iware_WH_Mcardboxes23"
        },
        {
            hash = ObjectNameToHashID("iware_WHRichChair22"),
            name = "iware_WHRichChair22"
        },
        {
            hash = ObjectNameToHashID("iware_WHChesterF06"),
            name = "iware_WHChesterF06"
        },
        {
            hash = ObjectNameToHashID("iware_WHCoffTbl09"),
            name = "iware_WHCoffTbl09"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag29"),
            name = "iware_WHseedbag29"
        },
        {
            hash = ObjectNameToHashID("iware_WHRichChair23"),
            name = "iware_WHRichChair23"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag30"),
            name = "iware_WHseedbag30"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag31"),
            name = "iware_WHseedbag31"
        },
        {
            hash = ObjectNameToHashID("iware_WHseedbag32"),
            name = "iware_WHseedbag32"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate28"),
            name = "iware_WhiskyCrate28"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate29"),
            name = "iware_WhiskyCrate29"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate30"),
            name = "iware_WhiskyCrate30"
        },
        {
            hash = ObjectNameToHashID("iware_WhiskyCrate31"),
            name = "iware_WhiskyCrate31"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Mcardboxes24"),
            name = "iware_WH_Mcardboxes24"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes47"),
            name = "iware_WH_Lcardboxes47"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes49"),
            name = "iware_WH_Lcardboxes49"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Lcardboxes50"),
            name = "iware_WH_Lcardboxes50"
        },
        {
            hash = ObjectNameToHashID("iware_WH_Crates26"),
            name = "iware_WH_Crates26"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_ChairPile08"),
            name = "iware_DPI_ChairPile08"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_BirdBath09"),
            name = "iware_DPE_BirdBath09"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pCabDoor03"),
            name = "iware_DPI_pCabDoor03"
        },
        {
            hash = ObjectNameToHashID("iware_DPE_Detour17"),
            name = "iware_DPE_Detour17"
        },
        {
            hash = ObjectNameToHashID("iware_DPI_pCabDoor04"),
            name = "iware_DPI_pCabDoor04"
        },
        {
            hash = ObjectNameToHashID("iware_TruckSidewind"),
            name = "iware_TruckSidewind"
        },
        {
            hash = ObjectNameToHashID("iware_ware_glaswin"),
            name = "iware_ware_glaswin"
        },
        {
            hash = ObjectNameToHashID("iware_ware_glaswin01"),
            name = "iware_ware_glaswin01"
        },
        {
            hash = ObjectNameToHashID("iware_ware_glaswin02"),
            name = "iware_ware_glaswin02"
        },
        {
            hash = ObjectNameToHashID("iware_ware_glaswin03"),
            name = "iware_ware_glaswin03"
        },
        {
            hash = ObjectNameToHashID("iware_ware_glaswin04"),
            name = "iware_ware_glaswin04"
        },
        {
            hash = ObjectNameToHashID("iware_ware_glaswin05"),
            name = "iware_ware_glaswin05"
        },
        {
            hash = ObjectNameToHashID("iware_TruckSidewind01"),
            name = "iware_TruckSidewind01"
        },
        {
            hash = ObjectNameToHashID("iware_TruckSidewind02"),
            name = "iware_TruckSidewind02"
        },
        {
            hash = ObjectNameToHashID("iware_TruckSidewind03"),
            name = "iware_TruckSidewind03"
        },
        {
            hash = ObjectNameToHashID("iware_StatueHorse_2"),
            name = "iware_StatueHorse_2"
        },
        {
            hash = ObjectNameToHashID("iware_StatueHorse_1"),
            name = "iware_StatueHorse_1"
        },
        {
            hash = ObjectNameToHashID("iware_StatueHorse_3"),
            name = "iware_StatueHorse_3"
        },
        {
            hash = ObjectNameToHashID("iware_StatueHorse_12"),
            name = "iware_StatueHorse_12"
        },
        {
            hash = ObjectNameToHashID("iware_StatueHorse_13"),
            name = "iware_StatueHorse_13"
        },
        {
            hash = ObjectNameToHashID("iware_StatueHorse_14"),
            name = "iware_StatueHorse_14"
        },
        {
            hash = ObjectNameToHashID("iware_StatueHorse_16"),
            name = "iware_StatueHorse_16"
        },
        {
            hash = ObjectNameToHashID("iware_StatueHorse_17"),
            name = "iware_StatueHorse_17"
        },
        {
            hash = ObjectNameToHashID("iware_StatueHorse_18"),
            name = "iware_StatueHorse_18"
        },
        {
            hash = ObjectNameToHashID("iware_Armor05"),
            name = "iware_Armor05"
        },
        {
            hash = ObjectNameToHashID("iware_Armor03"),
            name = "iware_Armor03"
        },
        {
            hash = ObjectNameToHashID("iware_Armor02"),
            name = "iware_Armor02"
        },
        {
            hash = ObjectNameToHashID("iware_Armor01"),
            name = "iware_Armor01"
        }
    }
end

function RegisterPropHashHandlers()
    local elems = F_TableSize(gDestroyables)
    --print(">>>[RUI]", "++RegisterPropHashHandlers elems: " .. tostring(elems))
    SetNumberOfHandledHashEventObjects(elems)
    if gDestroyables then
        for _, entry in gDestroyables do
            RegisterHashEventHandler(entry.hash, 3, cbPropBroken)
        end
    end
end

function DeregisterPropHashHandlers()
    --print(">>>[RUI]", "--DeregisterPropHashHandlers")
    if gDestroyables then
        for _, entry in gDestroyables do
            RegisterHashEventHandler(entry.hash, 3, nil)
        end
    end
end

function cbPropBroken(HashID, ModelPoolIndex)
    --print(">>>[RUI]", "!!cbLawnPropBroken")
    PropDestroyed()
end

function PropDestroyed()
    --print(">>>[RUI]", "++PropDestroyed")
    gPropsDamagedCount = gPropsDamagedCount + 1
    if gPropsDamagedCount == MAX_PROP_DAMAGED_ALLOWED then
        bPropsDestroyed = true
    end
end

function ObjectiveLogUpdateItem(newObjStr, oldObj, bSkipPrint)
    local newObj
    if newObjStr then
        newObj = MissionObjectiveAdd(newObjStr)
        if not bSkipPrint then
            TextPrint(newObjStr, 6, 1)
        end
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end

function Stage01_FindGreaserInit()
    --print(">>>[RUI]", "++Stage01_FindGreaserInit")
    gObjective = ObjectiveLogUpdateItem("5_02_18", nil)
    local blip = BlipAddPoint(POINTLIST._5_02_GREASERBLIP, 0, 1, 1, 0)
    ObjectiveBlipUpdate(blip)
    GreasersCreate()
    gMissionStage = Stage01_FindGreaserLoop
end

function Stage01_FindGreaserLoop()
    if PlayerIsInTrigger(TRIGGER._5_02_GREASERHANGOUT) or bGreasersAttacked then
        --print(">>>[RUI]", "--Stage01_FindGreaser")
        ObjectiveBlipUpdate(nil)
        NIS_InterrogateGreaser()
        return
    end
    Wait(100)
end

function GreasersCreate()
    --print(">>>[RUI]", "++GreasersCreate")
    gGreaser1 = PedCreatePoint(27, POINTLIST._5_02_GREASERS, 1)
    gGreaser2 = PedCreatePoint(21, POINTLIST._5_02_GREASERS, 2)
    gGreaser3 = PedCreatePoint(29, POINTLIST._5_02_GREASERS, 3)
    RegisterPedEventHandler(gGreaser1, 0, cbGreasersAttacked)
    RegisterPedEventHandler(gGreaser2, 0, cbGreasersAttacked)
    RegisterPedEventHandler(gGreaser3, 0, cbGreasersAttacked)
end

function cbGreasersAttacked()
    --print(">>>[RUI]", "!!cbGreasersAttacked")
    bGreasersAttacked = true
end

function GreasersCleanup()
    MakeAmbient(gGreaser1)
    MakeAmbient(gGreaser2)
    MakeAmbient(gGreaser3)
    --print(">>>[RUI]", "--GreasersCleanup")
end

function NIS_InterrogateGreaser()
    --print(">>>[RUI]", "!!NIS_InterrogateGreaser")
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    CameraFade(500, 0)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    Wait(250)
    PlayerSetControl(0)
    Wait(251)
    TextClear()
    SoundStopInteractiveStream(0)
    SoundSetAudioFocusPlayer()
    SoundPlayStream("MS_Confrontation_NIS.rsm", 0.4, 1000, 1000)
    PlayerSetPosPoint(POINTLIST._5_02_PLAYERGREASERNS)
    Wait(150)
    CameraReset()
    if bGreasersAttacked then
        --print(">>>[RUI]", "NIS_InterrogateGreaser Toss greasers make new.")
        PedDelete(gGreaser1)
        PedDelete(gGreaser2)
        PedDelete(gGreaser3)
        gGreaser1 = PedCreatePoint(27, POINTLIST._5_02_GREASERS, 1)
        gGreaser2 = PedCreatePoint(21, POINTLIST._5_02_GREASERS, 2)
        gGreaser3 = PedCreatePoint(29, POINTLIST._5_02_GREASERS, 3)
    end
    Wait(50)
    PedClearAllWeapons(gGreaser1)
    Wait(50)
    PedFaceObject(gGreaser1, gPlayer, 3, 0, false, false)
    PedFaceObject(gGreaser2, gPlayer, 3, 0, false, false)
    PedFaceObject(gGreaser3, gPlayer, 3, 0, false, false)
    CameraSetFOV(30)
    CameraSetXYZ(499.01096, -432.5321, 5.459406, 500.00626, -432.59723, 5.391693)
    CameraFade(500, 1)
    Wait(501)
    MusicFadeWithCamera(true)
    SoundFadeWithCamera(true)
    PedFaceObject(gPlayer, gGreaser1, 2, 0)
    PedSetActionNode(gPlayer, "/Global/5_02/animations/Player/Player01", "Act/Conv/5_02.act")
    SoundPlayScriptedSpeechEvent(gPlayer, "M_5_02", 10, "jumbo")
    if not F_WaitForSpeechSkippable(gPlayer) then
    else
        PedSetActionNode(gGreaser1, "/Global/5_02/animations/Greasers/Vance/Vance01", "Act/Conv/5_02.act")
        SoundPlayScriptedSpeechEvent(gGreaser1, "M_5_02", 25, "jumbo")
        if not F_WaitForSpeechSkippable(gGreaser1) then
        else
            CameraSetFOV(30)
            CameraSetXYZ(508.3472, -434.92203, 5.988695, 507.47607, -434.45657, 5.834953)
            PedSetActionNode(gPlayer, "/Global/5_02/animations/Player/Player02", "Act/Conv/5_02.act")
            SoundPlayScriptedSpeechEvent(gPlayer, "M_5_02", 12, "jumbo")
            if not F_WaitForSpeechSkippable(gPlayer) then
            else
                CameraSetFOV(30)
                CameraSetXYZ(499.01096, -432.5321, 5.459406, 500.00626, -432.59723, 5.391693)
                PedSetActionNode(gGreaser1, "/Global/5_02/animations/Greasers/Vance/Vance02", "Act/Conv/5_02.act")
                SoundPlayScriptedSpeechEvent(gGreaser1, "M_5_02", 26, "jumbo")
                if not F_WaitForSpeechSkippable(gGreaser1) then
                else
                    CameraSetFOV(30)
                    CameraSetXYZ(508.3472, -434.92203, 5.988695, 507.47607, -434.45657, 5.834953)
                    PedSetActionNode(gPlayer, "/Global/5_02/animations/Player/Player03", "Act/Conv/5_02.act")
                    SoundPlayScriptedSpeechEvent(gPlayer, "M_5_02", 8, "jumbo")
                    if not F_WaitForSpeechSkippable(gPlayer) then
                    else
                    end
                end
            end
        end
    end
    F_MakePlayerSafeForNIS(false)
    CameraReturnToPlayer(true)
    CameraDefaultFOV()
    PlayerSetControl(1)
    SoundSetAudioFocusPlayer()
    MusicFadeWithCamera(true)
    SoundFadeWithCamera(true)
    CameraSetWidescreen(false)
    SoundEnableInteractiveMusic(true)
    SoundPlayInteractiveStream("MS_RunningLow02.rsm", 0.5, 1000, 1000)
    SoundSetMidIntensityStream("MS_RunningMid.rsm", 0.6)
    SoundSetHighIntensityStream("MS_FightingDropouts.rsm", 0.7)
    GreasersCleanup()
    Stage02_GetToWareHouseInit()
end

function Stage02_GetToWareHouseInit()
    --print(">>>[RUI]", "!!Stage02_GetToWareHouse")
    gObjective = ObjectiveLogUpdateItem("5_02_16", gObjective)
    local blip = BlipAddPoint(POINTLIST._5_02_WAREHOUSEBLIP, 0, 1, 1, 0)
    ObjectiveBlipUpdate(blip)
    gMissionStage = Stage02_GetToWareHouseLoop
end

function Stage02_GetToWareHouseLoop()
    if AreaGetVisible() == 54 then
        --print(">>>[RUI]", "--Stage02_GetToWareHouse")
        SoundPlayInteractiveStream("MS_PunishmentDetention.rsm", MUSIC_DEFAULT_VOLUME)
        SoundSetHighIntensityStream("MS_FightingDropouts.rsm", 0.7)
        Stage03_FindRatCratesInit()
    end
    Wait(100)
end

function Stage03_FindRatCratesInit()
    --print(">>>[RUI]", "!!Stage03_FindRatCratesInit")
    gObjective = ObjectiveLogUpdateItem("5_02_21", gObjective)
    RegisterPropHashHandlers()
    RatCrateCreate()
    RatPackersCreate()
    RatPatrolCreate()
    RatsCreate()
    local blip = BlipAddXYZ(gRatCrate.x, gRatCrate.y, gRatCrate.z, 0)
    ObjectiveBlipUpdate(blip)
    while AreaIsLoading() do
        Wait(0)
    end
    Wait(500)
    RatPatrolStart()
    gMissionStage = Stage03_FindRatCratesLoop
end

function Stage03_FindRatCratesLoop()
    if PlayerIsInTrigger(TRIGGER._5_02_STARTRATPHOTO) then
        --print(">>>[RUI]", "--Stage03_FindRatCratesLoop")
        Stage04_PhotographRatCratesInit()
    end
    if bPropsDestroyed then
        RatPatrolGoAggro()
        bPropsDestroyed = false
    end
    if bRatPackersAttacked then
        RatPatrolGoAggro()
        RatPackersGoAggro()
        FailMission("5_02_FAIL03")
        return
    end
    Wait(100)
end

function RatCrateCreate()
    --print(">>>[RUI]", "++RatCrateCreate")
    gRatCrate = {}
    gRatCrate.x, gRatCrate.y, gRatCrate.z = -589.739, -166.915, 7.06956
    gRatCrate.index, gRatCrate.simpleObject = CreatePersistentEntity("RatCrateWH", gRatCrate.x, gRatCrate.y, gRatCrate.z, 1.0017, 54)
    gRatCrate.z = gRatCrate.z + 1.25
end

function RatCrateCleanup()
    DeletePersistentEntity(gRatCrate.index, gRatCrate.simpleObject)
    --print(">>>[RUI]", "--RatCrateCleanup")
end

function RatsCreate()
    local s = GetPointListSize(POINTLIST._5_02_RATS)
    gRats = {}
    for i = 1, s do
        rat = PedCreatePoint(136, POINTLIST._5_02_RATS, i)
        PedSetTetherToPoint(rat, POINTLIST._5_02RATTETHER, 1, 5)
        PedSetFaction(rat, 2)
        table.insert(gRats, { id = rat })
    end
    s = GetPointListSize(POINTLIST._5_02AMBIENTRATS)
    for i = 2, s do
        rat = PedCreatePoint(136, POINTLIST._5_02AMBIENTRATS, i)
        PedSetTetherToPoint(rat, POINTLIST._5_02AMBIENTRATS, 1, 15)
        PedSetFaction(rat, 2)
        table.insert(gRats, { id = rat })
    end
    --print(">>>[RUI]", "++RatsCreate")
end

function RatsCleanup()
    if gRats then
        for _, rat in gRats do
            MakeAmbient(rat.id)
        end
    end
    --print(">>>[RUI]", "--RatsCleanup")
end

function RatPatrolCreate()
    gOtto = PedCreatePoint(42, POINTLIST._5_02_RATPATROL, 1)
    gJerry = PedCreatePoint(41, POINTLIST._5_02_RATPATROL, 2)
    --print(">>>[RUI]", "++RatPatrolCreate")
end

function RatPatrolStart()
    PedFollowPath(gOtto, PATH._5_02RATPATROLA, 1, 0)
    PedSetStealthBehavior(gOtto, 1, cbOnSightRatFink, cbOnSightRatFink)
    PedFollowPath(gJerry, PATH._5_02RATPATROLB, 1, 0)
    PedSetStealthBehavior(gJerry, 1, cbOnSightRatFink, cbOnSightRatFink)
    --print(">>>[RUI]", "!!RatPatrolStart")
end

function RatPatrolCleanup()
    if F_PedExists(gOtto) then
        PedDelete(gOtto)
    end
    if F_PedExists(gJerry) then
        PedDelete(gJerry)
    end
    --print(">>>[RUI]", "--RatPatrolCleanup")
end

function RatPackersCreate()
    gLeon = PedCreatePoint(43, POINTLIST._5_02_WHDROPOUTS, 1)
    PedSetStationary(gLeon, true)
    RegisterHitCallback(gLeon, true, cbRatPackersAttacked)
    gDuncan = PedCreatePoint(44, POINTLIST._5_02_WHDROPOUTS, 2)
    PedSetStationary(gDuncan, true)
    PedSetActionNode(gDuncan, "/Global/5_02/animations/RatPacking", "Act/Conv/5_02.act")
    RegisterHitCallback(gLeon, true, cbRatPackersAttacked)
    table.insert(gRatPackers, { id = gLeon })
    table.insert(gRatPackers, { id = gDuncan })
    --print(">>>[RUI]", "++RatPackersCreate")
end

function cbRatPackersAttacked(victim, attacker)
    if attacker == gPlayer then
        --print(">>>[RUI]", "!!cbRatPackersAttacked")
        bRatPackersAttacked = true
        bDoRatPackingDialog = false
    end
end

function RatPackersCleanup()
    MakeAmbient(gLeon)
    MakeAmbient(gDuncan)
    --print(">>>[RUI]", "--RatPackersCleanup")
end

function RatPackersBeAware(bStealthOn)
    if bStealthOn then
        PedSetIsStealthMissionPed(gLeon, true)
        PedSetStealthBehavior(gLeon, 0, cbOnSightPackers)
        PedSetIsStealthMissionPed(gDuncan, true)
        PedSetStealthBehavior(gDuncan, 0, cbOnSightPackers)
    else
        PedSetIsStealthMissionPed(gLeon, false)
        PedSetIsStealthMissionPed(gDuncan, false)
    end
end

function RatPackersGoAggro()
    if bRatPackersAggro then
        return
    end
    PedStop(gLeon)
    PedSetIsStealthMissionPed(gLeon, false)
    PedSetStationary(gLeon, false)
    PedClearTether(gLeon)
    PedAttackPlayer(gLeon, 1)
    MakeAmbient(gLeon)
    PedStop(gDuncan)
    PedSetIsStealthMissionPed(gDuncan, false)
    PedSetStationary(gDuncan, false)
    PedClearTether(gDuncan)
    PedSetActionNode(gDuncan, "/Global/5_02/animations/RatPacking/StandBackUp/stand", "Act/Conv/5_02.act")
    PedAttackPlayer(gDuncan, 1)
    MakeAmbient(gDuncan)
    bRatPackersAggro = true
    --print(">>>[RUI]", "!!RatPackerGoAggro")
end

function RatPatrolGoAggro()
    if bRatPatrolAggro then
        return
    end
    RatPatrollerGoAggro(gOtto)
    RatPatrollerGoAggro(gJerry)
    bRatPatrolAggro = true
    --print(">>>[RUI]", "!!RatPatrolGoAggro")
end

function RatPatrollerGoAggro(guy)
    if F_PedExists(guy) then
        PedAttackPlayer(guy, 1)
        MakeAmbient(guy)
        --print(">>>[RUI]", "!!RatPatrollerGoAggro")
    end
end

function cbOnSightRatFink(ped)
    --print(">>>[RUI]", "cbOnSightRatFink")
    SoundPlayScriptedSpeechEvent(ped, "CHASE", 0, "large")
end

function cbOnSightPackers(ped)
    --print(">>>[RUI]", "cbOnSightPackers")
    SoundPlayScriptedSpeechEvent(ped, "CHASE", 0, "large")
    bSpottedByRatPackers = true
    bDoRatPackingDialog = false
    gFailMessage = "5_02_20"
end

function Stage04_PhotographRatCratesInit()
    --print(">>>[RUI]", "!!Stage04_PhotographRatCratesInit")
    bDoRatPackingDialog = true
    CreateThread("T_RatPackersDialog")
    RatPackersBeAware(true)
    bSpottedByRatPackers = false
    gMissionStage = Stage04_PhotographRatCratesLoop
end

function Stage04_PhotographRatCratesLoop()
    if PhotoIsGood(nil, gRatPackers) then
        bDoRatPackingDialog = false
        NIS_DropoutsLeaveForParty()
        Stage_LeaveWarehouseInit()
        return
    end
    if PlayerIsInTrigger(TRIGGER._5_02_WAREHOUSEUPSTAIRS) and RatPatrolFollowedPlayer() then
        bDoRatPackingDialog = false
        bSpottedByRatPackers = true
        --print(">>>[RUI]", "!!RatPatrolFollowedPlayer")
    end
    if bPropsDestroyed then
        --print(">>>[RUI]", "!!bPropsDestroyed")
        bSpottedByRatPackers = true
    end
    if bRatPackersAttacked then
        RatPatrolGoAggro()
        RatPackersGoAggro()
        FailMission("5_02_FAIL03")
        return
    end
    if bSpottedByRatPackers then
        bDoRatPackingDialog = false
        RatPatrolGoAggro()
        RatPackersGoAggro()
        FailMission("5_02_20")
        return
    end
    Wait(100)
end

function FailMission(message)
    --print(">>>[RUI]", "--FailMission " .. tostring(message))
    gFailMessage = message
    gMissionStage = nil
    gMissionState = MISSION_FAIL
end

function RatPatrolFollowedPlayer()
    return PedIsInTrigger(gOtto, TRIGGER._5_02_WAREHOUSEUPSTAIRS) or PedIsInTrigger(gOtto, TRIGGER._5_02_WAREHOUSEUPSTAIRS) or PedIsInTrigger(gJerry, TRIGGER._5_02_WAREHOUSEUPSTAIRS) or PedIsInTrigger(gJerry, TRIGGER._5_02_WAREHOUSEUPSTAIRS)
end

function Stage_LeaveWarehouseInit()
    --print(">>>[RUI]", "!!Stage_LeaveWarehouseInit")
    gObjective = ObjectiveLogUpdateItem("5_02_12", gObjective)
    local blip = BlipAddPoint(POINTLIST._5_02_PORTBLIP, 0)
    ObjectiveBlipUpdate(blip)
    CreateThread("T_MoveTheFuckersOutside")
    gMissionStage = Stage_LeaveWarehouseLoop
end

function Stage_LeaveWarehouseLoop()
    if bSpottedByRatPackers then
        RatPackersGoAggro()
    end
    if AreaGetVisible() ~= 54 then
        Stage04_PhotographRatCratesCleanup()
        --print(">>>[RUI]", "--Stage_LeaveWarehouse")
        Stage05_GoToDocksInit()
        return
    end
    Wait(100)
end

function Stage04_PhotographRatCratesCleanup()
    --print(">>>[RUI]", "!!Stage04_PhotographRatCratesCleanup")
    RatCrateCleanup()
    RatsCleanup()
    DeregisterPropHashHandlers()
end

function DoRatDialogLine(ratPacker, line)
    if not F_PedExists(ratPacker) then
        return false
    end
    SoundPlayScriptedSpeechEvent(ratPacker, "M_5_02", line, "supersize")
    while SoundSpeechPlaying(ratPacker) do
        if not bDoRatPackingDialog then
            SoundStopCurrentSpeechEvent(ratPacker)
            return false
        end
        Wait(0)
    end
    Wait(1500)
    return true
end

function T_RatPackersDialog()
    --print(">>>[RUI]", "++T_RatPackersDialog")
    bDoRatPackingDialog = true
    repeat
        if not DoRatDialogLine(gDuncan, 16) then
            break
        end
        if not DoRatDialogLine(gDuncan, 17) then
            break
        end
        if not DoRatDialogLine(gLeon, 18) then
            break
        end
        if not DoRatDialogLine(gDuncan, 19) then
            break
        end
        if not DoRatDialogLine(gLeon, 20) then
            break
        end
        if not DoRatDialogLine(gLeon, 21) then
            break
        end
        Wait(3000)
        --print(">>>[RUI]", "intro conversation done")
        local timer = GetTimer() + 8000
        for i = 1, 5 do
            if not bDoRatPackingDialog then
                break
            end
            if gMissionState ~= MISSION_RUNNING then
                break
            end
            if not MissionActive() then
                break
            end
            if not DoRatDialogLine(gDuncan, 22) then
                break
            end
            if not DoRatDialogLine(gLeon, 23) then
                break
            end
            while timer > GetTimer() do
                Wait(0)
                if not bDoRatPackingDialog then
                    break
                end
            end
        end
        bDoRatPackingDialog = false
    until not bDoRatPackingDialog
    collectgarbage()
    --print(">>>[RUI]", "--T_RatPackersDialog")
end

function NIS_DropoutsLeaveForParty()
    --print(">>>[RUI]", "!!NIS_DropoutsLeaveForParty")
    TextClear()
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    PlayerSetControl(0)
    RatPatrolCleanup()
    SoundSetAudioFocusCamera()
    CameraSetXYZ(-592.772, -165.6973, 7.879876, -591.96857, -166.28809, 7.806678)
    CameraReset()
    CameraFade(500, 1)
    Wait(501)
    PedLockTarget(gLeon, gDuncan)
    PedClearAllWeapons(gLeon)
    PedClearAllWeapons(gDuncan)
    Wait(50)
    PedSetActionNode(gLeon, "/Global/5_02/animations/RatPacking/Leon", "Act/Conv/5_02.act")
    SoundPlayScriptedSpeechEvent(gLeon, "M_5_02", 24, "large")
    Wait(1500)
    PedSetActionNode(gDuncan, "/Global/5_02/animations/RatPacking/StandBackUp", "Act/Conv/5_02.act")
    while PedIsPlaying(gDuncan, "/Global/5_02/animations/RatPacking/StandBackUp", true) do
        Wait(0)
    end
    Wait(500)
    RatPackersPathOut()
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    if PlayerIsInTrigger(TRIGGER._5_02_NEARNIS) then
        local x, y, z = GetPointFromPointList(POINTLIST._5_02_PLAYERAFTERRPNIS, 1)
        PlayerSetPosSimple(x, y, z)
        PedFaceObjectNow(gPlayer, gLeon, 2)
        PedSetFlag(gPlayer, 2, true)
    end
    CameraReturnToPlayer()
    CameraReset()
    CameraFade(500, 1)
    Wait(501)
    SoundSetAudioFocusPlayer()
    MusicFadeWithCamera(true)
    SoundFadeWithCamera(true)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
end

function RatPackersPathOut()
    --print(">>>[RUI]", "!!RatPackersPathOut")
    if F_PedExists(gLeon) then
        PedSetStationary(gLeon, false)
        PedStop(gLeon)
        PedFollowPath(gLeon, PATH._5_02_LEONEXITPATH, 0, 1, cbLeonReachedDoor)
    end
    --print(">>>[RUI]", "Go Otto")
    Wait(1000)
    if F_PedExists(gDuncan) then
        PedSetStationary(gDuncan, false)
        PedStop(gDuncan)
        PedFollowPath(gDuncan, PATH._5_02_DUNCANEXITPATH, 0, 1, cbDuncanReachedDoor)
    end
end

function T_MoveTheFuckersOutside()
    --print(">>>[RUI]", "++T_MoveTheFuckersOutside")
    while gMissionState == MISSION_RUNNING and gMissionStage == Stage_LeaveWarehouseLoop do
        if bDuncanReachedDoor and not bDuncanWarped then
            PedStop(gDuncan)
            PedSetPosPoint(gDuncan, POINTLIST._5_02_WHDROPOUTS02, 2)
            PedSetStationary(gDuncan, true)
            PedSetIsStealthMissionPed(gDuncan, true)
            PedSetStealthBehavior(gDuncan, 1)
            --print(">>>[RUI]", "moved duncan outside")
            bDuncanWarped = true
        end
        if bLeonReachedDoor and not bLeonWarped then
            PedStop(gLeon)
            PedSetPosPoint(gLeon, POINTLIST._5_02_WHDROPOUTS02, 1)
            PedSetStationary(gLeon, true)
            PedSetIsStealthMissionPed(gLeon, true)
            PedSetStealthBehavior(gLeon, 1)
            --print(">>>[RUI]", "moved leon outside")
            bLeonWarped = true
        end
        Wait(0)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T_MoveTheFuckersOutside")
end

function cbLeonReachedDoor(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) then
        --print(">>>[RUI]", "cbLeonReachedDoor")
        bLeonReachedDoor = true
    end
end

function cbDuncanReachedDoor(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) then
        --print(">>>[RUI]", "cbDuncanReachedDoor")
        bDuncanReachedDoor = true
    end
end

function RatPackersGotoDocks()
    --print(">>>[RUI]", "!!RatPackersGotoDocks")
    if F_PedExists(gLeon) then
        if bLeonWarped then
            PedStop(gLeon)
            PedSetStationary(gLeon, false)
            PedSetIsStealthMissionPed(gLeon, false)
            PedFollowPath(gLeon, PATH._5_02_DOCKLEONPATH, 0, 1, cbLeonAtDocks)
            --print(">>>[RUI]", "RatPackersGotoDocks Send Leon")
        else
            --print(">>>[RUI]", "RatPackersGotoDocks remove Leon")
            MakeAmbient(gLeon)
        end
    end
    if F_PedExists(gDuncan) then
        if bDuncanWarped then
            PedStop(gDuncan)
            PedSetStationary(gDuncan, false)
            PedSetIsStealthMissionPed(gDuncan, false)
            PedFollowPath(gDuncan, PATH._5_02_DOCKDUNCANPATH, 0, 1, cbDuncanAtDocks)
            --print(">>>[RUI]", "!!RatPackersGotoDocks Send Duncan")
        else
            MakeAmbient(gDuncan)
            --print(">>>[RUI]", "RatPackersGotoDocks remove Duncan")
        end
    end
end

function cbLeonAtDocks(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) then
        PedWander(gLeon, 0)
        --print(">>>[RUI]", "cbLeonAtDocks ")
    end
end

function cbDuncanAtDocks(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) then
        PedWander(gDuncan, 0)
        --print(">>>[RUI]", "cbDuncanAtDocks")
    end
end

function Stage05_GoToDocksInit()
    --print(">>>[RUI]", "!!Stage05_GoToDocksInit")
    RatPackersGotoDocks()
    gMissionStage = Stage05_GoToDocksLoop
end

function Stage05_GoToDocksLoop()
    if not bDepopulated and PlayerIsInTrigger(TRIGGER._5_02_DEPOPULATEDOCKS) then
        VehicleOverrideAmbient(0, 0, 0, 0)
        AreaDeactivatePopulationTrigger(TRIGGER._INDUSTRIAL_DOCKS)
        AreaActivatePopulationTrigger(TRIGGER._5_02_DEPOPULATEDOCKS)
        --print(">>>[RUI]", "!!Stage05_GoToDocksLoop:  Depopulate area")
        bDepopulated = true
    end
    if PlayerIsInTrigger(TRIGGER._5_02_DOCKPARTYCREATE) then
        --print(">>>[RUI]", "--Stage05_GoToDocks")
        Stage06_FindTrophiesInit()
        return
    end
    Wait(100)
end

function Stage06_FindTrophiesInit()
    --print(">>>[RUI]", "!!Stage06_FindTrophiesInit")
    RadarSetMinMax(30, 30, 30)
    DropoutsCreateAll()
    local blip = TrophyPileCreate()
    ObjectiveBlipUpdate(blip)
    gMissionStage = Stage06_FindTrophiesLoop
end

function Stage06_FindTrophiesLoop()
    if PlayerIsInTrigger(TRIGGER._5_02_BONFIRETRIGGER01) or PlayerIsInTrigger(TRIGGER._5_02_BonfireTrigger02) then
        --print(">>>[RUI]", "--Stage06_FindTrophies")
        Stage07_TakeDockPhotoInit()
        return
    end
    Wait(100)
end

function RegisterHitCallback(ped, bOn, cb)
    if bOn then
        --assert(cb, "**RegisterHitCallback(ped, bOn, cb):  cb==nil")
        --print(">>>[RUI]", "++RegisterHitCallback")
        RegisterPedEventHandler(ped, 0, cb)
    else
        --print(">>>[RUI]", "--RegisterHitCallback")
        RegisterPedEventHandler(ped, 0, nil)
    end
end

function DropoutsCreateForBonfire()
    --print(">>>[RUI]", "++DropoutsCreateForBonfire")
    gGas = BonfireDropoutsCreate(45, POINTLIST._5_02_BONFIREDROPOUTS, 1, "/Global/5_02/animations/GasolinePour/start")
    RegisterHitCallback(gGas, true, cbBonfirePedsHit)
    gTorch = BonfireDropoutsCreate(44, POINTLIST._5_02_BONFIREDROPOUTS, 2, "/Global/5_02/animations/StandingSmoke", "Act/Conv/5_02.act")
    RegisterHitCallback(gTorch, true, cbBonfirePedsHit)
    gObserver = BonfireDropoutsCreate(42, POINTLIST._5_02_BONFIREDROPOUTS, 4, "/Global/5_02/animations/ObserverLoops")
    RegisterHitCallback(gObserver, true, cbBonfirePedsHit)
    table.insert(gBonfireDropouts, { id = gTorch })
    table.insert(gBonfireDropouts, { id = gGas })
    table.insert(gBonfireDropouts, { id = gObserver })
end

function BonfireDropoutsCreate(model, point, index, action, poi)
    local townie = PedCreatePoint(model, point, index)
    Wait(10)
    PedSetActionNode(townie, action, "Act/Conv/5_02.act")
    return townie
end

function TrophyPileCreate()
    --print(">>>[RUI]", "++TrophyPileCreate")
    gTrophyPile = {}
    gTrophyPile.x, gTrophyPile.y, gTrophyPile.z = 353.588, -240.294, 2.92264
    gTrophyPile.index, gTrophyPile.simpleObject = CreatePersistentEntity("5_02_inTrophyPile", gTrophyPile.x, gTrophyPile.y, gTrophyPile.z, 0, 0)
    local blip = BlipAddXYZ(gTrophyPile.x, gTrophyPile.y, gTrophyPile.z, 0, 4)
    gTrophyPile.z = gTrophyPile.z + 1
    return blip
end

function DropoutsCreateAll()
    --print(">>>[RUI]", "++DropoutsCreateAll")
    gPartierB01 = PedCreatePoint(RandomTableElement(gDropoutModels), POINTLIST._5_02_DOPARTIERS02, 1)
    gPartierB02 = PedCreatePoint(RandomTableElement(gDropoutModels), POINTLIST._5_02_DOPARTIERS02, 2)
    DropoutsChat(gPartierB01, gPartierB02)
    RegisterHitCallback(gPartierB01, true, cbBonfirePedsHit)
    RegisterHitCallback(gPartierB01, true, cbBonfirePedsHit)
    gPartierFire = PedCreatePoint(RandomTableElement(gDropoutModels), POINTLIST._5_02_DOFIREBARREL01, 1)
    PedSetIsStealthMissionPed(gPartierFire, true)
    PedSetStealthBehavior(gPartierFire, 0, cbStealthPOISee, cbStealthPOISee)
end

function DropoutsChat(dude1, dude2)
    PedSetEmotionTowardsPed(dude2, dude1, 7, true)
    PedSetEmotionTowardsPed(dude1, dude2, 7, true)
    PedSetWantsToSocializeWithPed(dude2, dude1)
    PedSetWantsToSocializeWithPed(dude1, dude2)
end

function cbStealthPOISee(ped)
    --print(">>>[RUI]", "!!cbStealthPOISee " .. tostring(ped))
    SoundPlayScriptedSpeechEvent(ped, "CHASE", 0, "large")
    PedStop(ped)
    PedAttackPlayer(ped, 1)
end

function DropoutsGoWatchFire()
    DropoutWatchFire(gPartierB01)
    DropoutWatchFire(gPartierB02)
    DropoutWatchFire(gPartierFire)
    --print(">>>[RUI]", "DropoutsGoWatchFire  Dropouts sent")
    DropoutWatchFire(gLeon, 1)
    DropoutWatchFire(gDuncan, 2)
    --print(">>>[RUI]", "!!DropoutsGoWatchFire")
end

function DropoutWatchFire(dude, wp)
    --print(">>>[RUI]", "!!DropoutWatchFire")
    if F_PedExists(dude) then
        PedStop(dude)
        if wp then
            PedMoveToPoint(dude, 1, POINTLIST._5_02_BONFIREOBSERVERS, wp, cbReachedWatchPoint)
        else
            PedSetActionNode(dude, "/Global/5_02/animations/MoshOut", "Act/Conv/5_02.act")
        end
    end
end

function cbBonfirePedsHit(victim, attacker)
    if attacker == gPlayer and (victim == gGas or victim == gTorch or victim == gObserver) then
        if not bBonFireStarted and bBonfireExists then
            --print(">>>[RUI]", "MonitorBonfirePeds: Someone shot a DO")
            BonfireStart()
        end
        if not bDropoutsAgrod then
            DropoutsAllAggro()
            BonfireDropoutsTaunt()
            bDropoutsAgrod = true
            bBonfirePedsHit = true
        end
        --print(">>>[RUI]", "!!cbBonfirePedsHit")
    end
end

function cbReachedWatchPoint(ped)
    PedStop(ped)
    PedSetActionNode(ped, "/Global/5_02/animations/MoshOut", "Act/Conv/5_02.act")
    --print(">>>[RUI]", "!!cbReachedWatchPoint " .. tostring(ped))
end

function F_cbTorchTime()
    --print(">>>[RUI]", "!!F_cbTorchTime")
    bTorchTime = true
end

function Stage07_TakeDockPhotoInit()
    --print(">>>[RUI]", "!!Stage07_TakeDockPhotoInit")
    CreateThread("T_BonfireStarter")
    NIS_BonfireSetup()
    gMissionStage = Stage07_TakeDockPhotoLoop
end

function Stage07_TakeDockPhotoLoop()
    if PhotoIsGood(gTrophyPile, gBonfireDropouts) then
        --print(">>>[RUI]", "--Stage07_TakeDockPhoto")
        Stage08_ReturnToBoxingClubInit()
        return
    end
    if PlayerOnBarge() or bBonfirePedsHit then
        FailMission("5_02_FAIL01")
        BonfireStart()
        return
    end
    if FailPlayerForLeavingDocks() then
        FailMission("5_02_FAIL02")
    end
    Wait(100)
end

function PlayerOnBarge()
    if not bDockersAggro and PlayerIsInTrigger(TRIGGER._5_02_ONBARGE) then
        DropoutsAllAggro()
        BonfireDropoutsGoAggro()
        bDockersAggro = true
        --print(">>>[RUI]", "!!PlayerOnBarge")
        return true
    end
end

function NIS_BonfireSetup()
    --print(">>>[RUI]", "!!NIS_BonfireSetup")
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    SoundSetAudioFocusCamera()
    DropoutsAllSleep(true)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(250, 0)
    Wait(251)
    DropoutsCreateForBonfire()
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(250, 0)
    Wait(251)
    PlayerSetControl(0)
    if PlayerIsInTrigger(TRIGGER._5_02_BONFIRETRIGGER01) then
        CameraSetXYZ(356.68954, -234.01938, 5.834777, 356.21167, -234.84372, 5.531477)
    else
        CameraSetXYZ(356.68954, -234.01938, 5.834777, 356.21167, -234.84372, 5.531477)
    end
    CameraFade(250, 1)
    Wait(251)
    bBonFireStart = true
    SoundSetAudioFocusCamera()
    SoundPlay3D(352.26694, -240.08286, 2.4768896, "GasPourLoop", "Jumbo")
    gObjective = ObjectiveLogUpdateItem("5_02_13", gObjective)
    WaitSkippable(5000)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(250, 0)
    Wait(251)
    CameraFade(250, 1)
    Wait(251)
    CameraSetWidescreen(false)
    DropoutsAllSleep(false)
    SoundSetAudioFocusPlayer()
    MusicFadeWithCamera(true)
    SoundFadeWithCamera(true)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    CameraReturnToPlayer(true)
end

function DropoutsAllSleep(bSleep)
    --print(">>>[RUI]", "!!DropoutsAllSleep " .. tostring(bSleep))
    DropoutSleep(gPartierB01, bSleep)
    DropoutSleep(gPartierB02, bSleep)
    DropoutSleep(gPartierFire, bSleep)
end

function DropoutSleep(dude, bSleep)
    if F_PedExists(dude) then
        if bSleep then
            PedStop(dude)
        end
        PedSetAsleep(dude, bSleep)
    end
end

function BonfireStart()
    if bBonFireStarted then
        return
    end
    --print(">>>[RUI]", "++BonfireStart")
    if F_PedExists(gTorch) then
        PedSetActionNode(gTorch, "/Global/5_02/animations/StepBackMoshOut", "Act/conv/5_02.act")
    end
    if F_PedExists(gGas) then
        PedSetActionNode(gGas, "/Global/5_02/animations/GasolinePour/Stop", "Act/conv/5_02.act")
    end
    if F_PedExists(gObserver) then
        PedSetActionNode(gObserver, "/Global/5_02/animations/StepBackMoshOut", "Act/conv/5_02.act")
    end
    BonfireCreate()
    DropoutsGoWatchFire()
    bBonFireStarted = true
    --print(">>>[RUI]", "--BonfireStart")
end

function TimerPassed(time)
    return time < GetTimer()
end

function T_BonfireStarter()
    --print(">>>[RUI]", "++T_BonfireStarter")
    while not bBonFireStart do
        if not MissionActive() then
            return
        end
        Wait(10)
    end
    Wait(gBonfireStartTime)
    if F_PedExists(gTorch) then
        PedSetActionNode(gTorch, "/Global/5_02/animations/StandingSmoke/StubItOut", "Act/Conv/5_02.act")
        --print(">>>[RUI]", "T_BonfireStarter Torch throw")
    else
        bTorchTime = true
    end
    timeOut = GetTimer() + 2000
    while not bTorchTime do
        if not MissionActive() then
            return
        end
        if TimerPassed(timeOut) then
            break
        end
        Wait(0)
    end
    BonfireStart()
    --print(">>>[RUI]", "--T_BonfireStarter")
    collectgarbage()
end

function BonfireDropoutsTaunt()
    if F_PedExists(gTorch) then
        PedSetWeapon(gTorch, 311, 10)
        PedAttack(gTorch, gPlayer, 3)
    end
    if F_PedExists(gGas) then
        PedSetWeapon(gGas, 311, 10)
        PedAttack(gGas, gPlayer, 3)
    end
    if F_PedExists(gObserver) then
        PedSetWeapon(gObserver, 311, 10)
        PedAttack(gObserver, gPlayer, 3)
    end
end

function BonfireDropoutReset(townie)
    PedIgnoreStimuli(townie, false)
    PedIgnoreAttacks(townie, false)
end

function BonfireDropoutsGoAggro()
    if F_PedExists(gTorch) then
        BonfireDropoutReset(gTorch)
        DropoutGoAggro(gTorch)
    end
    if F_PedExists(gGas) then
        BonfireDropoutReset(gGas)
        DropoutGoAggro(gGas)
    end
    if F_PedExists(gObserver) then
        BonfireDropoutReset(gObserver)
        DropoutGoAggro(gObserver)
    end
end

function BonfireCreate()
    if bBonfireExists then
        return
    end
    SoundPlay3D(352.26694, -240.08286, 2.4768896, "TrophyFire", "Jumbo")
    local flame, xf, yf, zf
    tblFires = {
        {
            fireId = nil,
            trigger = TRIGGER._5_02_FLAME01,
            smokeId = nil
        },
        {
            fireId = nil,
            trigger = TRIGGER._5_02_FLAME02,
            smokeId = nil
        },
        {
            fireId = nil,
            trigger = TRIGGER._5_02_FLAME03,
            smokeId = nil
        }
    }
    local roll = 0
    for _, flame in tblFires do
        if flame.trigger ~= nil then
            flame.fireId = FireCreate(flame.trigger, 1000, 15, 100, 150, "GymFire")
            FireSetScale(flame.fireId, 1)
            FireSetDamageRadius(flame.fireId, 0.5)
            roll = math.random(1, 100)
            xf, yf, zf = GetAnchorPosition(flame.trigger)
            zf = zf + 0.5
            if roll <= 40 then
                flame.smokeId = EffectCreate("SmokeStackLRG", xf, yf, zf)
            else
                flame.smokeId = EffectCreate("SmokeStackBLK", xf, yf, zf)
            end
        end
    end
    xf, yf, zf = GetAnchorPosition(TRIGGER._5_02_BIGSMOKE)
    gBigSmoke = EffectCreate("SmokeStackLRG", xf, yf, zf)
    bBonfireExists = true
    --print(">>>[RUI]", "++BonfireCreate")
end

function BonfireDestroy()
    if tblFires then
        for _, flame in tblFires do
            if flame.fireId then
                FireDestroy(flame.fireId)
            end
            if flame.smokeId then
                EffectKill(flame.smokeId)
            end
        end
        if gBigSmoke then
            EffectKill(gBigSmoke)
        end
    end
    PAnimDelete(TRIGGER._5_02_TROPHYPILE)
    bBonfireExists = false
    --print(">>>[RUI]", "--BonfireDestroy")
end

function Stage08_ReturnToBoxingClubInit()
    --print(">>>[RUI]", "!!Stage08_ReturnToBoxingClubInit")
    gObjective = ObjectiveLogUpdateItem("5_02_14", gObjective)
    local blip = PrepsCreateForCS()
    ObjectiveBlipUpdate(blip)
    gMissionStage = Stage08_ReturnToBoxingClubLoop
end

function Stage08_ReturnToBoxingClubLoop()
    if not bLeftDocks and PlayerIsInTrigger(TRIGGER._5_02_PORTEXIT) then
        AreaRevertToDefaultPopulation()
        VehicleRevertToDefaultAmbient()
        DropoutsCleanup()
        SoundStopInteractiveStream()
        SoundPlayInteractiveStream("MS_StealthLow.rsm", MUSIC_DEFAULT_VOLUME)
        SoundSetMidIntensityStream("MS_StealthMid.rsm", 0.6)
        SoundSetHighIntensityStream("MS_StealthHigh.rsm", 0.7)
        bLeftDocks = true
    end
    if PlayerIsInTrigger(TRIGGER._5_02_FINALNIS) or bPrepsHit then
        --print(">>>[RUI]", "--Stage08_ReturnToBoxingClub")
        Stage09_OutroCSInit()
        return
    end
    Wait(100)
end

function cbPrepsHit(victim, attacker)
    if attacker == gPlayer and (victim == gDarby or victim == gGuy1) then
        bPrepsHit = true
        --print(">>>[RUI]", "!!cbPrepsHit")
    end
end

function Stage09_OutroCSInit()
    --print(">>>[RUI]", "!!Stage09_OutroCSInit")
    gObjective = ObjectiveLogUpdateItem(nil, gObjective)
    ObjectiveBlipUpdate(nil)
    gMissionState = MISSION_PASS
    gMissionStage = nil
    return
end

function PrepsCreateForCS()
    gDarby = PedCreatePoint(37, POINTLIST._5_02_DARBYBOXING, 1)
    RegisterHitCallback(gDarby, true, cbPrepsHit)
    Wait(10)
    gGuy1 = PedCreatePoint(33, POINTLIST._5_02_DARBYBOXING, 2)
    RegisterHitCallback(gGuy1, true, cbPrepsHit)
    Wait(10)
    local blip = AddBlipForChar(gDarby, 5, 0, 4)
    --print(">>>[RUI]", "++PrepsCreateForCS")
    return blip
end

function CS_Intro()
    --print(">>>[RUI]", "!!CS_Intro")
    PlayerSetControl(0)
    PlayCutsceneWithLoad("5-02", true)
    MissionInit()
    CameraReturnToPlayer(false)
    CameraFade(1000, 1)
    Wait(1000)
    SoundSetAudioFocusPlayer()
    MusicFadeWithCamera(true)
    SoundFadeWithCamera(true)
    PlayerSetControl(1)
end

function CS_Outro()
    --print(">>>[RUI]", "!!CS_Outro")
    PlayerSetControl(0)
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    CameraFade(1000, 0)
    Wait(1001)
    F_PlayerExitBike(false)
    PlayCutsceneWithLoad("5-02B", true, true)
    CameraSetWidescreen(true)
    PedClearObjectives(gPlayer)
    PedLockTarget(gPlayer, -1)
    PlayerSetPosPoint(POINTLIST._5_02_PLAYERENDPOINT, 1)
    PlayerSetControl(0)
    PedDelete(gDarby)
    gDarby = PedCreatePoint(37, POINTLIST._5_02_WALKOFFBEG, 1)
    PedDelete(gGuy1)
    gGuy1 = PedCreatePoint(33, POINTLIST._5_02_WALKOFFBEG, 2)
    PedMoveToPoint(gDarby, 0, POINTLIST._5_02_WALKOFF, 1)
    PedMoveToPoint(gGuy1, 0, POINTLIST._5_02_WALKOFF, 2)
    CameraSetXYZ(391.0158, 144.11938, 6.232622, 392.003, 144.24667, 6.328549)
    Wait(10)
    PlayerRecordAttackTime(2000)
    CameraFade(500, 1)
    Wait(501)
    SoundSetAudioFocusPlayer()
    MusicFadeWithCamera(true)
    SoundFadeWithCamera(true)
end

--[[
function GiveCamera()
    GiveWeaponToPlayer(328, false)
end
]] -- Not present in original script

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("5_02.DAT", 2)
    DATInit()
    LoadAnimationGroups(true)
    LoadActionTree("Act/Conv/5_02.act")
    SoundEnableInteractiveMusic(true)
    SoundPlayInteractiveStream("MS_RunningLow02.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetMidIntensityStream("MS_RunningMid.rsm", 0.6)
    SoundSetHighIntensityStream("MS_FightingDropouts.rsm", 0.7)
end

function MissionInit() -- ! Modified
    --print(">>>[RUI]", "!!MissionInit")
    PlayerSetPosPoint(POINTLIST._5_02_PLAYER_START)
    --[[
    PedSetTypeToTypeAttitude(3, 13, 0)
    ]] -- Not present in original script
    prepTude = PedGetTypeToTypeAttitude(5, 13)
    PedSetTypeToTypeAttitude(5, 13, 2)
    gGreaserModels = {
        27,
        21,
        29
    }
    LoadModels(gGreaserModels)
    gDropoutModels = {
        42,
        41,
        43,
        44,
        45
    }
    LoadModels(gDropoutModels)
    LoadModels({
        37,
        33,
        48
    })
    DestroyablePropsInitTable()
    LoadWeaponModels({ 311, 339 })
    LoadModels({
        136,
        425,
        346
    })
    AreaActivatePopulationTrigger(TRIGGER._5_02_DEPOPULATEDOCKS)
    AreaDeactivatePopulationTrigger(TRIGGER._INDUSTRIAL_DOCKS)
end

function MissionCleanup()
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    RadarRestoreMinMax()
    PrepCleanup()
    DropoutsCleanup()
    GreasersCleanup()
    if gMissionState == MISSION_PASS then
        CameraReturnToPlayer(false)
    end
    if gTrophyPile then
        DeletePersistentEntity(gTrophyPile.index, gTrophyPile.simpleObject)
    end
    BonfireDestroy()
    PedSetTypeToTypeAttitude(5, 13, prepTude)
    AreaDeactivatePopulationTrigger(TRIGGER._5_02_DEPOPULATEDOCKS)
    AreaDeactivatePopulationTrigger(TRIGGER._5_02_DEPOPRICHAREA)
    AreaRevertToDefaultPopulation()
    AreaActivatePopulationTrigger(TRIGGER._INDUSTRIAL_DOCKS)
    VehicleRevertToDefaultAmbient()
    LoadAnimationGroups(false)
    DATUnload(2)
end

function LoadAnimationGroups(bLoad)
    --print(">>>[RUI]", "!!LoadAnimationGroups " .. tostring(bLoad))
    if bLoad then
        LoadAnimationGroup("5_02PrVandalized")
        LoadAnimationGroup("NPC_Love")
        LoadAnimationGroup("NPC_ADULT")
        LoadAnimationGroup("Hang_Moshing")
        LoadAnimationGroup("LE_Orderly")
        LoadAnimationGroup("Cheer_Cool1")
        LoadAnimationGroup("Cheer_Cool2")
        LoadAnimationGroup("Cheer_Gen3")
        LoadAnimationGroup("DodgeBall")
        LoadAnimationGroup("POI_Smoking")
        LoadAnimationGroup("IDLE_DOUT_C")
        LoadAnimationGroup("NIS_5_02")
    else
        UnLoadAnimationGroup("5_02PrVandalized")
        UnLoadAnimationGroup("NPC_Love")
        UnLoadAnimationGroup("NPC_ADULT")
        UnLoadAnimationGroup("Hang_Moshing")
        UnLoadAnimationGroup("LE_Orderly")
        UnLoadAnimationGroup("Cheer_Cool1")
        UnLoadAnimationGroup("Cheer_Cool2")
        UnLoadAnimationGroup("Cheer_Gen3")
        UnLoadAnimationGroup("DodgeBall")
        UnLoadAnimationGroup("POI_Smoking")
        UnLoadAnimationGroup("IDLE_DOUT_C")
        UnLoadAnimationGroup("NIS_5_02")
    end
end

function main()
    CS_Intro()
    gMissionStage = Stage01_FindGreaserInit
    while gMissionState == MISSION_RUNNING do
        if gMissionStage then
            gMissionStage()
        else
            --print(">>>[RUI]", "**MAIN no stage loop: " .. tostring(gMissionStage))
        end
        Wait(0)
    end
    if gMissionState == MISSION_PASS then
        CS_Outro()
        MinigameSetCompletion("M_PASS", true, 3000)
        MinigameAddCompletionMsg("MRESPECT_PP15", 2)
        MinigameAddCompletionMsg("MRESPECT_DM25", 1)
        SoundPlayMissionEndMusic(true, 10)
        SetFactionRespect(5, GetFactionRespect(5) + 15)
        SetFactionRespect(3, GetFactionRespect(3) - 25)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        CameraFade(500, 0)
        Wait(501)
        CameraReturnToPlayer(true)
        PedDelete(gDarby)
        PedDelete(gGuy1)
        gDarby = nil
        gGuy1 = nil
        MissionSucceed(true, false, false)
    else
        SoundPlayMissionEndMusic(false, 10)
        if gFailMessage then
            MissionFail(false, true, gFailMessage)
        else
            MissionFail(false, true)
        end
    end
end

local bPhotoTaken, bWasGood, bGoodPictureTaken, bValidPicture

function PhotoIsGood(propLoc, dudeTbl)
    bPhotoTaken, bWasGood = false, false
    bGoodPictureTaken, bValidPicture = false, false
    bValidPicture = PhotoCheckTargetsInFrame(propLoc, dudeTbl)
    PhotoSetValid(bValidPicture)
    bPhotoTaken, bWasGood = PhotoHasBeenTaken()
    bGoodPictureTaken = bPhotoTaken and bWasGood and PhotoVerifyGoodShot(propLoc, dudeTbl)
    if bGoodPictureTaken then
        return true
    end
    return false
end

local bPropInFrame, bDudeInFrame
local L35_1 = false                                 -- ! Cannot recover original name
local L36_1                                         -- ! Cannot recover original name

function PhotoCheckTargetsInFrame(propLoc, dudeTbl) -- ! Modified
    bPropInFrame, bDudeInFrame = false, false
    if propLoc then
        if type(propLoc) == "table" then
            bPropInFrame = PhotoTargetInFrame(propLoc.x, propLoc.y, propLoc.z)
        else
            bPropInFrame = true
        end
    else
        bPropInFrame = true
    end
    for _, dude in dudeTbl do
        if dude and not F_PedIsDead(dude.id) then
            dude.bWasInFrame = false -- Added this
            if dude.bInFrame then -- Added this
                dude.bWasInFrame = true -- Added this
            end
            dude.bInFrame = PhotoTargetInFrame(dude.id, 2)
            if not bDudeInFrame then
                bDudeInFrame = dude.bInFrame or dude.bWasInFrame
                --[[
                bDudeInFrame = dude.bInFrame
                ]] -- Not present in original script
            end
        else
            --print(">>>[RUI]", "**PhotoCheckTargetsInFrame BAD DUDE")
        end
    end
    L36_1 = L35_1                     -- Added this
    L35_1 = bPropInFrame              -- Added this
    bPropInFrame = bPropInFrame or L36_1 -- Added this
    return bPropInFrame and bDudeInFrame
end

local bDudeShotGood

function PhotoVerifyGoodShot(propLoc, dudeTbl) -- ! Modified
    bDudeShotGood = false
    for _, dude in dudeTbl do
        --[[
        if dude and not F_PedIsDead(dude.id) and dude.bInFrame then
        ]] -- Changed this to:
        if dude and not F_PedIsDead(dude.id) and (dude.bInFrame or dude.bWasInFrame) then
            bDudeShotGood = true
            break
        end
    end
    return bPropInFrame and bDudeShotGood
end
