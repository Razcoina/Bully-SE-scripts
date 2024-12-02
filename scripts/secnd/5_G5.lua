ImportScript("Library\\LibTable.lua")
ImportScript("Library\\LibPed.lua")
ImportScript("Library\\LibPropNew.lua")
local bHashEventsRegistered = false
local tDestroyables = {}
local tDestroyablesTemp = {}
local tPropsTemp = {}
local zoe
local zoeTotal = 0
local playerTotal = 0
local totalPossibleValue = 0
local DamageValueClimbLadderThreshold = 0
local gStartedHighIntensity = false
local pedDestroyer
local cops = {}
local COMM_5_G5_GNOME = 1
local COMM_5_G5_ARMOUR = 2
local COMM_5_G5_SCULPTURE = 3
local COMM_5_G5_GRAPES = 4
local COMM_5_G5_VFLYTRAP = 5
local COMM_5_G5_GLASS = 6
local COMM_5_G5_FURNITURE = 7
local COMM_5_G5_BOX = 8
local COMM_5_G5_TV = 9
local COMM_5_G5_SEEDBAG = 10
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bDeleteZoe = false
local gMinutesToSmash = 4
local bMetUpWithZoeBottom = false
local bMovedZoeInside = false
local bSentZoeToPlantRoom = false
local bSendZoneToPlantRoomViaPath = false
local bFadeOnFail = false
local bSkipFirstCutscene = false
local gMissionFailMessage = 0

function MissionSetup()
	PlayCutsceneWithLoad("5-G5", true)
	MissionDontFadeIn()
	DATLoad("5_G5.DAT", 2)
	DATInit()
end

function MissionCleanup()
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	F_HideCounters()
	PedSetUniqueModelStatus(48, 0)
	SoundStopInteractiveStream()
	AreaSetDoorLocked("DT_INDOOR_WHOUSEFRONT", false)
	AreaSetDoorLocked("DT_INDOOR_WHOUSEROOF", false)
	AreaSetDoorLocked("DT_whouse_front", false)
	AreaSetDoorLocked("DT_whouse_roof", false)
	PAnimSetPropFlag(TRIGGER._DT_INDOOR_WHOUSEFRONT, 11, false)
	PAnimSetPropFlag(TRIGGER._DT_INDOOR_WHOUSEROOF, 11, false)
	UnLoadAnimationGroup("MINI_React")
	RadarRestoreMinMax()
	F_DeregisterHashEvents()
	DisablePunishmentSystem(false)
	if gMissionFailMessage == 1 and bGoToStage2 then
		AreaTransitionPoint(0, POINTLIST._5_G5_PLAYERBOOTED)
	end
	DATUnload(2)
	DATInit()
end

function main()
	--print("()xxxxx[:::::::::::::::> [start] main()")
	F_SetupMission()
	F_Stage1()
	if bMissionFailed then
		TextPrint("5_G5_EMPTY", 1, 1)
		SoundPlayMissionEndMusic(false, 10)
		if gMissionFailMessage == 1 then
			if bGoToStage2 then
				PlayerSetControl(0)
				MissionFail(true, true, "5_G5_FAIL_01")
			else
				MissionFail(false, true, "5_G5_FAIL_01")
			end
		elseif gMissionFailMessage == 2 then
			MissionFail(false, true, "5_G5_LOST")
			local x1, y1, z1 = PedGetOffsetInWorldCoords(gPlayer, 0.5, 1, 1.2)
			local x2, y2, z2 = PedGetOffsetInWorldCoords(gPlayer, -0.5, -0.7, 1.7)
			CameraSetXYZ(x1, y1, z1, x2, y2, z2)
			PedSetActionNode(gPlayer, "/Global/5_G5/Failure", "Act/Conv/5_G5.act")
		else
			MissionFail(false)
		end
	elseif bMissionPassed then
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		MissionSucceed(false, false, false)
	end
	--print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_SetupMission()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
	WeaponRequestModel(418)
	WeaponRequestModel(300)
	WeaponRequestModel(MODELENUM._W_CRUTCH)
	WeaponRequestModel(323)
	PedRequestModel(48)
	PedSetUniqueModelStatus(48, -1)
	AreaSetDoorLocked("DT_INDOOR_WHOUSEFRONT", true)
	AreaSetDoorLocked("DT_INDOOR_WHOUSEROOF", true)
	LoadAnimationGroup("MINI_React")
	F_TableInit()
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
end

function F_TableInit()
	--print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
	pedZoe = {
		spawn = POINTLIST._5_G5_ZOE,
		element = 1,
		model = 48
	}
	tDestroyablesTemp = {
		{
			name = "iware_DPE_BirdBath11",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPE_BirdBath10",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPE_BirdBath09",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPE_BirdBath07",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPE_BirdBath06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPE_BirdBath01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPE_BirdBath",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPE_GlassCart01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPE_GlassCart02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPE_HatSVase04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPE_HatSVase02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPE_HatVase05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPE_HatVase04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPE_HatVase03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPE_HatVase02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPE_Hcolumn06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPE_Hcolumn02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPE_Hcolumn01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPI_AsyTable04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_AsyTable03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_AsyTable02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_AsyTable",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CardBox03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CardBox02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CardBox01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CardBox",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_ChairPile09",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_ChairPile08",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_ChairPile07",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_ChairPile06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_ChairPile05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_ChairPile02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_ChairPile01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_ChairPile",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_CrateBrk175",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk173",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk171",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk170",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk169",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk166",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk165",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk164",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk163",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk162",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk168",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk167",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk158",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk157",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk156",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk155",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_CrateBrk151",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_Fraffy",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 1000
		},
		{
			name = "iware_DPI_LampMini09",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_LampMini08",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_LampMini07",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_LampMini01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_LampMini",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_LampMini10",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_Lcrate154",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPI_Lcrate152",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPI_Lcrate159",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPI_Lcrate145",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPI_Lcrate142",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPI_Lcrate141",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPI_pCabDoor03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_pCabDoor04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_pCabDoor01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_pCabDoor02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_pDoorBrk01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPI_pDoorBrk02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_DPI_pPlant04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_pPlant06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_pPlant05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_pPlant03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_pPlant01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_pPlant",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_prepFlwrGls01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_pVase06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_pVase08",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_pVase01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_Stool06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_Stool05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_Stool04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_Stool2",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_DPI_TerriumsL01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPI_TerriumsL02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_DPI_TerriumsS02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_TerriumsS01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_TVmini05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_TVmini04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_TVmini01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_DPI_TVmini",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ExoticPlant25",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ExoticPlant1",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_RedFlash06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_ShipinBox49",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox48",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox44",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox41",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox36",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox31",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox30",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox29",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ShipinBox2",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuebust_29",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_26",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_23",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_20",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_15",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_12",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_09",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_0",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_28",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_24",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_21",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_18",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_16",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_13",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_10",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_07",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_1",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_27",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_25",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_22",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_19",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_17",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_14",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_11",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_08",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuebust_2",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_22",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_19",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_15",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_0",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_21",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_17",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_13",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_1",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_12",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_20",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_16",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_2",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_23",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_18",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_14",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_StatueHorse_3",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_Statuemask08",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask07",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask_08",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask_07",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask_06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask_05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask_03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask_02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask_01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_Statuemask_0",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ware_glaswin05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ware_glaswin04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ware_glaswin03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ware_glaswin02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ware_glaswin01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_ware_glaswin",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Crates26",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Crates25",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Crates24",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Crates20",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Crates11",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Crates05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Crates03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Crates02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Crates01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Crates",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WH_Lcardboxes50",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes49",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes47",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes46",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes45",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes43",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes42",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes40",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes38",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes37",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes36",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes35",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes29",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes26",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes25",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes16",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes13",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Lcardboxes",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Mcardboxes26",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes25",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes24",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes23",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes22",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes21",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes17",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes15",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes14",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes12",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes11",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes08",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes07",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Mcardboxes",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WH_Whisky10",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Whisky11",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Whisky04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Whisky02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WH_Whisky09",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WHChesterF04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WHChesterF03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WHChesterF06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WHChesterF05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WHChesterF02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WHChesterF",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WHCoffTbl09",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WHCoffTbl07",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WHCoffTbl05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 50
		},
		{
			name = "iware_WhiskyCrate31",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WhiskyCrate29",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WhiskyCrate28",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WhiskyCrate27",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WhiskyCrate25",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WhiskyCrate23",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WhiskyCrate13",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WhiskyCrate12",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WhiskyCrate11",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WhiskyCrate09",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 75
		},
		{
			name = "iware_WHRichChair14",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair25",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair24",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair16",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair20",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair13",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair10",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair27",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair26",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair23",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHRichChair08",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 100
		},
		{
			name = "iware_WHseedbag16",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag06",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag04",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag1",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag32",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag31",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag30",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag29",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag28",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag27",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag15",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag14",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag13",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag08",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_WHseedbag03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 25
		},
		{
			name = "iware_CrateLikr4Galway",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 200
		}
	}
	tPropsTemp = {
		{
			name = "iware_Armor05",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 200
		},
		{
			name = "iware_Armor03",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 200
		},
		{
			name = "iware_Armor02",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 200
		},
		{
			name = "iware_Armor01",
			pedTarget = true,
			destroyed = false,
			destroyer = nil,
			value = 200
		}
	}
	collectgarbage()
	--print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Setup()
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	if IsMissionFromDebug() then
		AreaTransitionPoint(0, POINTLIST._5_G5_START, nil, true)
	end
	PAnimSetPropFlag(TRIGGER._DT_INDOOR_WHOUSEFRONT, 11, true)
	PAnimSetPropFlag(TRIGGER._DT_INDOOR_WHOUSEROOF, 11, true)
	pedZoe.id = PedCreatePoint(pedZoe.model, pedZoe.spawn, pedZoe.element)
	PedSetFlag(pedZoe.id, 98, false)
	PedSetMissionCritical(pedZoe.id, true, F_MissionCritical, false)
	PedIgnoreStimuli(pedZoe.id, true)
	PedSetPedToTypeAttitude(pedZoe.id, 13, 4)
	PedAlwaysUpdateAnimation(pedZoe.id, true)
	PedSetInfiniteSprint(pedZoe.id, true)
	collectgarbage()
	F_RegisterHashEventHandlers()
	PedFollowPath(pedZoe.id, PATH._5_G5_ZOE2WAREHOUSE, 0, 3)
	PedSetTetherToPed(pedZoe.id, gPlayer, 12)
	blipFrontDoor = BlipAddPoint(POINTLIST._5_G5_WHFRONTDOOR, 0, 1, 1, 7, 0)
	blipBackDoor = BlipAddPoint(POINTLIST._5_G5_WHBACKDOOR, 0, 1, 0, 7, 0)
	CameraFade(500, 1)
	Wait(500)
	TextPrint("5_G5_MOBJ01", 4, 1)
	gObjective01 = MissionObjectiveAdd("5_G5_MOBJ01")
	CreateThread("T_ZoeText01")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	while bLoop do
		Stage1_Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage2 then
			F_Stage2()
			break
		end
		Wait(0)
	end
end

function F_Stage2()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2()")
	F_Stage2_Setup()
	F_Stage2_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
	BlipRemove(blipFrontDoor)
	BlipRemove(blipBackDoor)
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(500)
	AreaTransitionPoint(54, POINTLIST._5_G5_PLAYER_WH, nil, true)
	while IsStreamingBusy() do
		Wait(0)
	end
	LoadAnimationGroup("NIS_5_G5")
	PedClearObjectives(pedZoe.id)
	PedClearTether(pedZoe.id)
	PedSetPosPoint(pedZoe.id, POINTLIST._5_G5_ZOE_WH)
	PedSetPosPoint(gPlayer, POINTLIST._5_G5_PLAYER_WH)
	PedFaceObject(pedZoe.id, gPlayer, 3, 0)
	Wait(500)
	AreaClearAllPeds()
	TextClear()
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	PlayerSetControl(0)
	CameraFade(500, 1)
	CreateThread("T_Cutscene01")
	while not bSkipFirstCutscene do
		if IsButtonPressed(7, 0) then
			bSkipFirstCutscene = true
		end
		Wait(0)
	end
	CameraFade(500, 0)
	Wait(500)
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	CameraReset()
	UnLoadAnimationGroup("NIS_5_G5")
	DisablePunishmentSystem(true)
	SoundPlayStream("MS_DestructionVandalismMid.rsm", MUSIC_DEFAULT_VOLUME)
	AreaSetDoorLocked("DT_whouse_front", true)
	AreaSetDoorLocked("DT_whouse_roof", true)
	PlayerSetControl(1)
	F_SpawnWeapons()
	pedZoe.blip = AddBlipForChar(pedZoe.id, 6, 2, 1, 0)
	PedOverrideStat(pedZoe.id, 15, 100)
	PedOverrideStat(pedZoe.id, 3, 100)
	PedOverrideStat(pedZoe.id, 2, 360)
	PedWander(pedZoe.id, 1)
	F_SetupCounters()
	F_StartTimer()
	CameraFade(500, 1)
	Wait(500)
	MissionObjectiveComplete(gObjective01)
	TextPrint("5_G5_MOBJ02", 4, 1)
	gObjective02 = MissionObjectiveAdd("5_G5_MOBJ02")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
	while bLoop do
		Stage2_Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage3 then
			F_Stage3()
			break
		end
		Wait(0)
	end
end

function F_Stage3()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3()")
	F_Stage3_Setup()
	F_Stage3_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3()")
end

function F_Stage3_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3_Setup()")
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	TextPrint("5_G5_TIMEUP", 3, 1)
	if playerTotal <= zoeTotal then
		SoundPlayScriptedSpeechEvent(pedZoe.id, "M_5_G5", 34, "speech", true)
	else
		SoundPlayScriptedSpeechEvent(pedZoe.id, "M_5_G5", 35, "speech", true)
	end
	Wait(3000)
	CameraFade(500, 0)
	Wait(500)
	local tempX, tempY, tempZ = GetPointList(POINTLIST._5_G5_ENDPLAYER)
	PlayerStopAllActionControllers()
	PlayerSetPosSimple(tempX, tempY, tempZ)
	PedSetPosPoint(pedZoe.id, POINTLIST._5_G5_ENDZOE)
	PedSetMissionCritical(pedZoe.id, false)
	PedSetStationary(pedZoe.id, true)
	PedSetEmotionTowardsPed(pedZoe.id, gPlayer, 8, true)
	PedSetPedToTypeAttitude(pedZoe.id, gPlayer, 4)
	PedSetFlag(pedZoe.id, 84, true)
	PedFaceObject(pedZoe.id, gPlayer, 3, 0)
	PedFaceObject(gPlayer, pedZoe.id, 2, 0)
	CameraSetXYZ(-609.70465, -160.07443, 1.402566, -610.62445, -160.44948, 1.516572)
	CameraFade(500, 1)
	Wait(500)
	TextAddParamNum(playerTotal)
	TextPrint("5_G5_FINALSCORE01", 4, 1)
	SoundPlayScriptedSpeechEvent(gPlayer, "M_5_G5", 15, "speech", true)
	Wait(4000)
	CameraSetXYZ(-610.0809, -160.12903, 1.616041, -609.2096, -160.61493, 1.684267)
	TextAddParamNum(zoeTotal)
	TextPrint("5_G5_FINALSCORE02", 4, 1)
	if playerTotal <= zoeTotal then
		PedSetActionNode(pedZoe.id, "/Global/5_G5/Success", "Act/Conv/5_G5.act")
	else
		PedSetActionNode(pedZoe.id, "/Global/5_G5/ZoeFailure", "Act/Conv/5_G5.act")
	end
	Wait(4000)
	TextPrint("5_G5_EMPTY", 1, 1)
	CameraSetXYZ(-608.1808, -162.01682, 1.253873, -608.85065, -161.28893, 1.397656)
	F_WaitForSpeech(gPlayer)
	if playerTotal <= zoeTotal then
		SoundPlayScriptedSpeechEvent(pedZoe.id, "M_5_G5", 103, "speech", true)
		F_WaitForSpeech(pedZoe.id)
		PedSetActionNode(pedZoe.id, "/Global/5_G5/Empty", "Act/Conv/5_G5.act")
		PedSetStationary(pedZoe.id, false)
		PedMoveToPoint(pedZoe.id, 1, POINTLIST._5_G5_CENTER, 1)
		bFadeOnFail = true
		gMissionFailMessage = 2
		bMissionFailed = true
	else
		local x1, y1, z1 = PedGetOffsetInWorldCoords(gPlayer, 0.5, 1, 1.2)
		local x2, y2, z2 = PedGetOffsetInWorldCoords(gPlayer, -0.5, -0.7, 1.7)
		CameraSetXYZ(x1, y1, z1, x2, y2, z2)
		PedSetActionNode(gPlayer, "/Global/5_G5/Success", "Act/Conv/5_G5.act")
		MinigameSetCompletion("M_PASS", true, 6000)
		SoundPlayMissionEndMusic(true, 10)
		SoundPlayScriptedSpeechEvent(pedZoe.id, "M_5_G5", 21, "speech", true)
		PedSetActionNode(pedZoe.id, "/Global/5_G5/Empty", "Act/Conv/5_G5.act")
		PedSetStationary(pedZoe.id, false)
		PedMoveToPoint(pedZoe.id, 1, POINTLIST._5_G5_CENTER, 1)
		bMissionPassed = true
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3_Setup()")
end

function F_Stage3_Loop()
	while bLoop do
		Stage3_Objectives()
		if bMissionFailed then
			break
		end
		if bMissionPassed then
			break
		end
		Wait(0)
	end
end

function Stage1_Objectives()
	if not bMovedZoeInside and PedIsInTrigger(pedZoe.id, TRIGGER._5_G5_WAREDOORZOE) then
		PedStop(pedZoe.id)
		PedSetPosPoint(pedZoe.id, POINTLIST._5_G5_ZOE_WH)
		PedClearTether(pedZoe.id)
		bMovedZoeInside = true
	end
	if PlayerIsInTrigger(TRIGGER._5_G5_WHFRONTDOOR) or PlayerIsInTrigger(TRIGGER._5_G5_WHBACKDOOR) then
		bGoToStage2 = true
	end
end

function Stage2_Objectives()
	if MissionTimerGetTimeRemaining() <= gMinutesToSmash * 60 / 2 and gStartedHighIntensity == false then
		SoundPlayStream("MS_DestructionVandalismHigh.rsm", 0.7, 500, 500)
		gStartedHighIntensity = true
	end
	if not bSentZoeToPlantRoom and MissionTimerGetTimeRemaining() <= gMinutesToSmash * 60 / 2 then
		F_SendZoeToPlantRoom()
		bSentZoeToPlantRoom = true
	end
	if bSendZoneToPlantRoomViaPath then
		PedFollowPath(pedZoe.id, PATH._5_G5_ZOETOEXIT, 0, 2, cbZoeInPlantRoom)
		bSendZoneToPlantRoomViaPath = false
	end
	if MissionTimerHasFinished() then
		MissionTimerStop()
		F_HideCounters()
		PedOverrideStat(pedZoe.id, 15, 0)
		PedStop(pedZoe.id)
		PedClearWeapon(pedZoe.id, 418)
		bGoToStage3 = true
	end
end

function Stage3_Objectives()
end

function F_SetupCounters()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupCounters()")
	CounterSetCurrent(0)
	CounterSetMax(0)
	CounterMakeHUDVisible(true, false)
	CounterEnableRoll(true, "ROLL_JIMMY_COUNTER", "ROLL_ZOE_COUNTER", 25)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupCounters()")
end

function F_HideCounters()
	--print("()xxxxx[:::::::::::::::> [start] F_HideCounters()")
	CounterMakeHUDVisible(false)
	--print("()xxxxx[:::::::::::::::> [finish] F_HideCounters()")
end

function F_StartTimer()
	--print("()xxxxx[:::::::::::::::> [start] F_StartTimer()")
	MissionTimerStart(gMinutesToSmash * 60)
	--print("()xxxxx[:::::::::::::::> [finish] F_StartTimer()")
end

function F_SpawnWeapons()
	--print("()xxxxx[:::::::::::::::> [start] F_SpawnWeapons()")
	weaponBat = PickupCreatePoint(300, POINTLIST._5_G5_SPAWNBAT, 1, 0, "PermanentMission")
	weapon2x4 = PickupCreatePoint(323, POINTLIST._5_G5_SPAWN2X4, 1, 0, "PermanentMission")
	weaponWrench = PickupCreatePoint(300, POINTLIST._5_G5_SPAWNWRENCH, 1, 0, "PermanentMission")
	--print("()xxxxx[:::::::::::::::> [finish] F_SpawnWeapons()")
end

function F_SendZoeToPlantRoom()
	--print("()xxxxx[:::::::::::::::> [start] F_SendZoeToPlantRoom()")
	PedStop(pedZoe.id)
	PedClearObjectives(pedZoe.id)
	PedMoveToPoint(pedZoe.id, 2, POINTLIST._5_G5_ZOETOPLANTS, 1, cbZoeAtPlants, 3)
	TextPrint("5_G5_HINT", 4, 1)
	MissionObjectiveReminderTime(-1)
	--print("()xxxxx[:::::::::::::::> [finish] F_SendZoeToPlantRoom()")
end

function F_WaitForSpeech(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeech()")
	if pedID == nil then
		while SoundSpeechPlaying() do
			Wait(0)
		end
	else
		while SoundSpeechPlaying(pedID) do
			Wait(0)
		end
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeech()")
end

function F_WaitForSpeechCutscene01(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeechCutscene01()")
	if pedID == nil then
		while SoundSpeechPlaying() do
			Wait(0)
		end
	else
		while SoundSpeechPlaying(pedID) do
			if bSkipFirstCutscene then
				break
			end
			Wait(0)
		end
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeechCutscene01()")
end

function F_SpawnSledge()
	--print("()xxxxx[:::::::::::::::> [start] F_SpawnSledge()")
	weaponSledge01 = PickupCreatePoint(324, POINTLIST._5_G5_SLEDGE01, 1, 0, "PermanentMission")
	weaponSledge02 = PickupCreatePoint(324, POINTLIST._5_G5_SLEDGE02, 1, 0, "PermanentMission")
	weaponSledge03 = PickupCreatePoint(324, POINTLIST._5_G5_SLEDGE03, 1, 0, "PermanentMission")
	weaponSledge04 = PickupCreatePoint(324, POINTLIST._5_G5_SLEDGE04, 1, 0, "PermanentMission")
	bSledgeSpawned = true
	--print("()xxxxx[:::::::::::::::> [finish] F_SpawnSledge()")
end

function F_CleanupSledge()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupSledge()")
	local tempX, tempY, tempZ = GetPointList(POINTLIST._5_G5_CENTER)
	PickupDestroyTypeInAreaXYZ(tempX, tempY, tempZ, 100, 324)
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupSledge()")
end

function T_ZoeText01()
	--print("()xxxxx[:::::::::::::::> [start] T_ZoeText01()")
	SoundPlayScriptedSpeechEventWrapper(pedZoe.id, "M_5_G5", 1, "large")
	--print("()xxxxx[:::::::::::::::> [finish] T_ZoeText01()")
end

function T_Cutscene01()
	if not bSkipFirstCutscene then
		CameraSetXYZ(-671.4948, -162.91353, 1.316186, -670.57166, -162.53107, 1.279742)
		PedSetActionNode(pedZoe.id, "/Global/5_G5/NIS_Anims/Zoe/Zoe_01", "Act/Conv/5_G5.act")
		SoundPlayScriptedSpeechEvent(pedZoe.id, "M_5_G5", 8, "jumbo")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(pedZoe.id)
	end
	if not bSkipFirstCutscene then
		CameraSetXYZ(-665.8043, -162.53493, 1.153426, -666.5188, -161.83614, 1.151459)
		PedSetActionNode(gPlayer, "/Global/5_G5/NIS_Anims/Jimmy/Jimmy_01", "Act/Conv/5_G5.act")
		SoundPlayScriptedSpeechEvent(gPlayer, "M_5_G5", 9, "jumbo")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(gPlayer)
	end
	if not bSkipFirstCutscene then
		CameraSetXYZ(-669.4946, -162.1607, 1.338242, -668.6671, -161.60136, 1.290168)
		PedSetActionNode(pedZoe.id, "/Global/5_G5/NIS_Anims/Zoe/Zoe_02", "Act/Conv/5_G5.act")
		SoundPlayScriptedSpeechEvent(pedZoe.id, "M_5_G5", 16, "jumbo")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(pedZoe.id)
	end
	if not bSkipFirstCutscene then
		CameraSetXYZ(-666.88885, -161.46582, 1.218866, -667.7805, -161.0165, 1.265604)
		PedSetActionNode(gPlayer, "/Global/5_G5/NIS_Anims/Jimmy/Jimmy_02", "Act/Conv/5_G5.act")
		SoundPlayScriptedSpeechEvent(gPlayer, "M_5_G5", 17, "jumbo")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(gPlayer)
	end
	if not bSkipFirstCutscene then
		CameraSetXYZ(-669.4946, -162.1607, 1.338242, -668.6671, -161.60136, 1.290168)
		PedSetActionNode(pedZoe.id, "/Global/5_G5/NIS_Anims/Zoe/Zoe_03", "Act/Conv/5_G5.act")
		SoundPlayScriptedSpeechEvent(pedZoe.id, "M_5_G5", 10, "jumbo")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(pedZoe.id)
	end
	PedSetActionNode(gPlayer, "/Global/5_G5/Empty", "Act/Conv/5_G5.act")
	bSkipFirstCutscene = true
end

function F_MissionCritical()
	gMissionFailMessage = 1
	PedMakeAmbient(pedZoe.id)
	bMissionFailed = true
end

function cbZoeAtPlants()
	--print("()xxxxx[:::::::::::::::> [start] cbZoeAtPlants()")
	bSendZoneToPlantRoomViaPath = true
	--print("()xxxxx[:::::::::::::::> [finish] cbZoeAtPlants()")
end

function cbZoeInPlantRoom()
	--print("()xxxxx[:::::::::::::::> [start] cbZoeInPlantRoom()")
	PedWander(pedZoe.id, 1)
	--print("()xxxxx[:::::::::::::::> [finish] cbZoeInPlantRoom()")
end

function F_DeregisterWarehouseHashHandlers()
	--print("()xxxxx[:::::::::::::::> [start] F_DeregisterWarehouseHashHandlers()")
	for i, entry in tDestroyables do
		RegisterHashEventHandler(entry.hash, 0, nil)
		RegisterHashEventHandler(entry.hash, 3, nil)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_DeregisterWarehouseHashHandlers()")
end

function F_SendZoeToStairsBase()
	--print("()xxxxx[:::::::::::::::> [start] F_SendZoeToStairsBase()")
	PedOverrideStat(pedZoe.id, 15, 0)
	PedClearObjectives(pedZoe.id)
	if PedIsInTrigger(pedZoe.id, TRIGGER._5_G5_ZONE02) or PedIsInTrigger(pedZoe.id, TRIGGER._5_G5_ZONE01) then
		PedFollowPath(pedZoe.id, PATH._5_G5_ZOE_TO_STAIRS2, 0, 3)
	elseif PedIsInTrigger(pedZoe.id, TRIGGER._5_G5_ZONE03) then
		PedFollowPath(pedZoe.id, PATH._5_G5_ZOE_TO_STAIRS3, 0, 3)
	elseif PedIsInTrigger(pedZoe.id, TRIGGER._5_G5_ZONE04) then
		PedFollowPath(pedZoe.id, PATH._5_G5_ZOE_TO_STAIRS4, 0, 3)
	else
		PedFollowPath(pedZoe.id, PATH._5_G5_ZOEGODOWNSTAIRS, 0, 3)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_SendZoeToStairsBase()")
end

function F_RegisterHashEventHandlers()
	--print("()xxxxx[:::::::::::::::> [start] F_RegisterHashEventHandlers()")
	local x, y
	x = table.getn(tDestroyablesTemp)
	y = table.getn(tPropsTemp)
	SetNumberOfHandledHashEventObjects(x + y)
	for i, entry in tDestroyablesTemp do
		entry.hash = ObjectNameToHashID(entry.name)
		tDestroyables[entry.hash] = entry
		RegisterHashEventHandler(entry.hash, 0, OnObjectCreatedCallback)
		RegisterHashEventHandler(entry.hash, 3, OnObjectBrokenCallback)
	end
	for i, entry in tPropsTemp do
		totalPossibleValue = totalPossibleValue + entry.value
		entry.hash = ObjectNameToHashID(entry.name)
		entry.bAnimProp = true
		tDestroyables[entry.hash] = entry
		RegisterHashEventHandler(entry.hash, 4, OnObjectBrokenCallback)
	end
	DamageValueClimbLadderThreshold = totalPossibleValue / 2
	bHashEventsRegistered = true
	tDestroyablesTemp = nil
	--print("()xxxxx[:::::::::::::::> [finish] F_RegisterHashEventHandlers()")
end

function F_DeregisterHashEvents()
	--print("()xxxxx[:::::::::::::::> [start] F_DeregisterHashEvents()")
	if not bHashEventsRegistered then
		return
	end
	for i, entry in tDestroyables do
		RegisterHashEventHandler(entry.hash, 0, nil)
		RegisterHashEventHandler(entry.hash, 3, nil)
	end
	bHashEventsRegistered = false
	--print("()xxxxx[:::::::::::::::> [finish] F_DeregisterHashEvents()")
end

function OnObjectCreatedCallback(HashID, ModelPoolIndex)
	entry = tDestroyables[HashID]
	if entry.destroyed then
		ObjectBreak(ModelPoolIndex)
	elseif entry.pedTarget == false then
		ObjectPedNoTarget(ModelPoolIndex)
	end
end

function OnObjectBrokenCallback(HashID, ModelPoolIndex)
	--print("()xxxxx[:::::::::::::::> [start] OnObjectBrokenCallback()")
	entry = tDestroyables[HashID]
	entry.destroyed = true
	pedDestroyer = PAnimDestroyedByPed(ModelPoolIndex, 0)
	if bGoToStage3 then
		return
	end
	if pedDestroyer == gPlayer then
		entry.destroyer = gPlayer
		playerTotal = playerTotal + entry.value
		CounterSetCurrent(playerTotal)
	elseif pedDestroyer == pedZoe.id then
		entry.destroyer = pedZoe.id
		zoeTotal = zoeTotal + entry.value
		CounterSetMax(zoeTotal)
	else
		TextPrintString("UNKNOWN DESTROYED SOMETHING - PLEASE REPORT BUG", 4, 1)
	end
	--print("()xxxxx[:::::::::::::::> [finish] OnObjectBrokenCallback()")
end
