POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local SetupComplete = false
local GreetingComplete = false
local DialogComplete = false
local GoalsCreated = false
local ObjectiveMet = false
local MissionScenarioComplete = false

function main()
    while SetupComplete == false do
        SetupComplete = F_ScenarioSetup()
        Wait(0)
    end
    while F_CheckConditions() == true do
        if GreetingComplete == false then
            GreetingComplete = F_OnGreeting()
        elseif DialogComplete == false then
            DialogComplete = F_OnDialog()
        elseif GoalsCreated == false then
            GoalsCreated = F_ScenarioGoals()
        elseif MissionScenarioComplete == false then
            MissionScenarioComplete = F_MissionSpecificCheck()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    F_SetupRubberBandTable()
    PedSetInvulnerable(gPlayer, true)
    return true
end

function F_OnGreeting()
    F_CollectBands()
    return false
end

local bPressX = true
local band = 1
local totalBands = 0
local lastBands = 0
local bGetNextBand = false
local bGettingBand = false

function F_CollectBands()
    if IsButtonPressed(7, 0) and bPressX then
        if band < 76 then
            if not tblRB[band].bGotIt then
                if tblRB[band].area == 0 then
                    zplus = 15
                else
                    zplus = 0
                end
                PlayerSetPosXYZArea(tblRB[band].x, tblRB[band].y, tblRB[band].z + zplus, tblRB[band].area)
                bGettingBand = true
            else
                band = band + 1
            end
        else
            band = 1
        end
        bPressX = false
    end
    if bGettingBand then
        if band == ItemGetCurrentNum(500) then
            tblRB[band].bGotIt = true
            bGetNextBand = true
        else
            bGetNextBand = false
        end
        if bGetNextBand then
            bGettingBand = false
            band = band + 1
        end
    end
    if not IsButtonPressed(7, 0) and not bPressX then
        bPressX = true
    end
    return false
end

local card = 1
local totalCards = 40
local deck = 1

function F_CollectGandG()
    if IsButtonPressed(7, 0) and bPressX then
        --print("====== Card ====", card)
        if card < 41 then
            if not tblCard[card].bGotIt then
                if tblCard[card].area == 0 then
                    zplus = 15
                else
                    zplus = 0
                end
                PlayerSetPosXYZArea(tblCard[card].x, tblCard[card].y, tblCard[card].z + zplus, tblCard[card].area)
                bGettingBand = true
            else
                card = card + 1
            end
        else
            card = 1
        end
        bPressX = false
    end
    if bGettingBand then
        if card == ItemGetCurrentNum(474) then
            tblCard[card].bGotIt = true
            bGetNextBand = true
        else
            bGetNextBand = false
        end
        if bGetNextBand then
            bGettingBand = false
            card = card + 1
        end
    end
    if not IsButtonPressed(7, 0) and not bPressX then
        bPressX = true
    end
    return false
end

local gnome = 1

function F_CollectGnomes()
    if IsButtonPressed(7, 0) and bPressX then
        --print("====== Card ====", gnome)
        if gnome < 26 then
            zplus = 15
            PlayerSetPosXYZArea(tblGnomes[gnome].x, tblGnomes[gnome].y, tblGnomes[gnome].z + zplus, tblGnomes[gnome].area)
            bGettingBand = true
            gnome = gnome + 1
        else
            gnome = 1
        end
        bPressX = false
    end
    if not IsButtonPressed(7, 0) and not bPressX then
        bPressX = true
    end
    return false
end

function F_OnDialog()
    return true
end

function F_ScenarioGoals()
    return true
end

function F_MissionSpecificCheck()
    return true
end

function F_ObjectiveMet()
    return true
end

function F_CheckConditions()
    if PlayerHasWeapon(325) then
        return false
    else
        return true
    end
end

function F_ScenarioCleanup()
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end

function F_SetupRubberBandTable()
    --print("=============== Rubbers Intited ================")
    tblRB = {
        {
            name = "RubBand01",
            bGotIt = false,
            area = 0,
            x = 533.039,
            y = 512.56,
            z = 19.617
        },
        {
            name = "RubBand02",
            bGotIt = false,
            area = 0,
            x = 420.391,
            y = 299.711,
            z = 9.38
        },
        {
            name = "RubBand03",
            bGotIt = false,
            area = 0,
            x = 447.949,
            y = 188.055,
            z = 9.17
        },
        {
            name = "RubBand04",
            bGotIt = false,
            area = 0,
            x = 487.535,
            y = 76.236,
            z = 4.04
        },
        {
            name = "RubBand05",
            bGotIt = false,
            area = 0,
            x = 218.417,
            y = 256.22,
            z = 3.415
        },
        {
            name = "RubBand06",
            bGotIt = false,
            area = 0,
            x = 549.805,
            y = -17.746,
            z = 11.156
        },
        {
            name = "RubBand07",
            bGotIt = false,
            area = 0,
            x = 648.264,
            y = -87.613,
            z = 28.676
        },
        {
            name = "RubBand08",
            bGotIt = false,
            area = 0,
            x = 529.229,
            y = -160.922,
            z = 15.937
        },
        {
            name = "RubBand09",
            bGotIt = false,
            area = 0,
            x = 525.049,
            y = -273.836,
            z = 2.309
        },
        {
            name = "RubBand10",
            bGotIt = false,
            area = 0,
            x = 429.888,
            y = -462.774,
            z = 2.99
        },
        {
            name = "RubBand11",
            bGotIt = false,
            area = 0,
            x = 236.595,
            y = -286.584,
            z = 3.567
        },
        {
            name = "RubBand12",
            bGotIt = false,
            area = 0,
            x = 69.408,
            y = -400.446,
            z = 1.045
        },
        {
            name = "RubBand13",
            bGotIt = false,
            area = 0,
            x = 551.4,
            y = -251.6,
            z = 7.545
        },
        {
            name = "RubBand14",
            bGotIt = false,
            area = 0,
            x = 256.731,
            y = 372.793,
            z = 20.018
        },
        {
            name = "RubBand15",
            bGotIt = false,
            area = 0,
            x = 343.4,
            y = -63.5,
            z = 4.3
        },
        {
            name = "RubBand16",
            bGotIt = false,
            area = 0,
            x = 166.539,
            y = 378.244,
            z = 1.566
        },
        {
            name = "RubBand17",
            bGotIt = false,
            area = 0,
            x = 149.891,
            y = 88.044,
            z = 2.508
        },
        {
            name = "RubBand18",
            bGotIt = false,
            area = 0,
            x = 228.792,
            y = -363.43,
            z = 2.671
        },
        {
            name = "RubBand19",
            bGotIt = false,
            area = 0,
            x = -65.9,
            y = -325.2,
            z = 4.2
        },
        {
            name = "RubBand20",
            bGotIt = false,
            area = 0,
            x = 162.954,
            y = -418.241,
            z = 2.615
        },
        {
            name = "RubBand21",
            bGotIt = false,
            area = 0,
            x = 585.395,
            y = -476.787,
            z = 4.49
        },
        {
            name = "RubBand22",
            bGotIt = false,
            area = 0,
            x = 309.403,
            y = 374.066,
            z = 24.6
        },
        {
            name = "RubBand23",
            bGotIt = false,
            area = 0,
            x = 567.169,
            y = 385.852,
            z = 14.8
        },
        {
            name = "RubBand24",
            bGotIt = false,
            area = 0,
            x = 572.467,
            y = -133.53,
            z = 5.872
        },
        {
            name = "RubBand25",
            bGotIt = false,
            area = 0,
            x = 39.366,
            y = 26.081,
            z = 6.121
        },
        {
            name = "RubBand26",
            bGotIt = false,
            area = 0,
            x = -2.709,
            y = -371.505,
            z = 7.769
        },
        {
            name = "RubBand27",
            bGotIt = false,
            area = 0,
            x = 193.233,
            y = -467.992,
            z = 9.375
        },
        {
            name = "RubBand28",
            bGotIt = false,
            area = 0,
            x = 32.0124,
            y = 297.424,
            z = 4.069
        },
        {
            name = "RubBand30",
            bGotIt = false,
            area = 0,
            x = 323.471,
            y = -340.511,
            z = 3.399
        },
        {
            name = "RubBand31",
            bGotIt = false,
            area = 0,
            x = 438.8,
            y = 384.6,
            z = 17.235
        },
        {
            name = "RubBand32",
            bGotIt = false,
            area = 0,
            x = 475.6,
            y = 273.4,
            z = 20.055
        },
        {
            name = "RubBand33",
            bGotIt = false,
            area = 0,
            x = 599.1,
            y = -89.3,
            z = 6
        },
        {
            name = "RubBand34",
            bGotIt = false,
            area = 0,
            x = 487,
            y = -74.3,
            z = 5.42
        },
        {
            name = "RubBand35",
            bGotIt = false,
            area = 0,
            x = 628.6,
            y = 203.3,
            z = 18.5
        },
        {
            name = "RubBand36",
            bGotIt = false,
            area = 0,
            x = 337.3,
            y = 239.4,
            z = 6.96
        },
        {
            name = "RubBand37",
            bGotIt = false,
            area = 0,
            x = 401.2,
            y = 119.8,
            z = 5.375
        },
        {
            name = "RubBand41",
            bGotIt = false,
            area = 0,
            x = 492.4,
            y = -277.9,
            z = 2.5
        },
        {
            name = "RubBand42",
            bGotIt = false,
            area = 0,
            x = 257.475,
            y = -414.012,
            z = 2.72
        },
        {
            name = "RubBand43",
            bGotIt = false,
            area = 0,
            x = 305.524,
            y = -231.61,
            z = 0.24
        },
        {
            name = "RubBand44",
            bGotIt = false,
            area = 0,
            x = 521.78,
            y = -405.488,
            z = 2.28
        },
        {
            name = "RubBand46",
            bGotIt = false,
            area = 0,
            x = 431.636,
            y = 550.239,
            z = 24.971
        },
        {
            name = "RubBand47",
            bGotIt = false,
            area = 0,
            x = 6.93654,
            y = 0.581118,
            z = 7.041
        },
        {
            name = "RubBand50",
            bGotIt = false,
            area = 0,
            x = 210.4,
            y = -42.3,
            z = 8.695
        },
        {
            name = "RubBand51",
            bGotIt = false,
            area = 0,
            x = -28.3,
            y = -21.8,
            z = 2.03
        },
        {
            name = "RubBand52",
            bGotIt = false,
            area = 0,
            x = 55.998,
            y = -106.087,
            z = 7.139
        },
        {
            name = "RubBand53",
            bGotIt = false,
            area = 0,
            x = 148.3,
            y = -153.3,
            z = 7.3
        },
        {
            name = "RubBand54",
            bGotIt = false,
            area = 0,
            x = 247.5,
            y = -15.3,
            z = 6.26
        },
        {
            name = "RubBand55",
            bGotIt = false,
            area = 0,
            x = 119.469,
            y = -15.3664,
            z = 7.26
        },
        {
            name = "RubBand56",
            bGotIt = false,
            area = 0,
            x = 48.3,
            y = -49.2,
            z = 5.1
        },
        {
            name = "RubBand57",
            bGotIt = false,
            area = 0,
            x = 247.7,
            y = -124.8,
            z = 6.04
        },
        {
            name = "RubBand58",
            bGotIt = false,
            area = 0,
            x = 101.8,
            y = -74.5,
            z = 7.6
        },
        {
            name = "RubBand60",
            bGotIt = false,
            area = 0,
            x = 165.6,
            y = -17,
            z = 6.41
        },
        {
            name = "RubBand61",
            bGotIt = false,
            area = 0,
            x = 173.3,
            y = 11.5,
            z = 6.1
        },
        {
            name = "RubBand62",
            bGotIt = false,
            area = 0,
            x = 45.8,
            y = -224.8,
            z = 2.635
        },
        {
            name = "RubBand63",
            bGotIt = false,
            area = 0,
            x = 334.7,
            y = 325,
            z = 13.15
        },
        {
            name = "RubBand65",
            bGotIt = false,
            area = 0,
            x = 260.5,
            y = -436.3,
            z = 3.645
        },
        {
            name = "RubBand66",
            bGotIt = false,
            area = 0,
            x = 629.7,
            y = -63.5,
            z = 9.095
        },
        {
            name = "RubBand67",
            bGotIt = false,
            area = 0,
            x = 523.3,
            y = 195.9,
            z = 16.545
        },
        {
            name = "RubBand72",
            bGotIt = false,
            area = 0,
            x = 587.6,
            y = 454.1,
            z = 18.82
        },
        {
            name = "RubBand73",
            bGotIt = false,
            area = 0,
            x = 488.1,
            y = 492.6,
            z = 21.405
        },
        {
            name = "RubBand74",
            bGotIt = false,
            area = 0,
            x = 214.6,
            y = -403.4,
            z = 2.785
        },
        {
            name = "RubBand75",
            bGotIt = false,
            area = 0,
            x = -9.1,
            y = -224.9,
            z = 2.15
        },
        {
            name = "RubBand29",
            bGotIt = false,
            area = 2,
            x = -636.3,
            y = -288.8,
            z = 5.515
        },
        {
            name = "RubBand45",
            bGotIt = false,
            area = 2,
            x = -619.6,
            y = -262.79,
            z = -1.71
        },
        {
            name = "RubBand38",
            bGotIt = false,
            area = 27,
            x = -736.8,
            y = 386.4,
            z = 298.08
        },
        {
            name = "RubBand64",
            bGotIt = false,
            area = 55,
            x = -477.2,
            y = -39.4,
            z = 9.8
        },
        {
            name = "RubBand69",
            bGotIt = false,
            area = 9,
            x = -771,
            y = 216.2,
            z = 95.6
        },
        {
            name = "RubBand70",
            bGotIt = false,
            area = 35,
            x = -442.7,
            y = 307.5,
            z = -2.47
        },
        {
            name = "RubBand71",
            bGotIt = false,
            area = 35,
            x = -426.6,
            y = 300.8,
            z = -2.5
        },
        {
            name = "RubBand49",
            bGotIt = false,
            area = 14,
            x = -523.6,
            y = 319.9,
            z = 31.43
        },
        {
            name = "RubBand39",
            bGotIt = false,
            area = 33,
            x = -698.4,
            y = 266.8,
            z = 0.03
        },
        {
            name = "RubBand48",
            bGotIt = false,
            area = 30,
            x = -737,
            y = 37.2,
            z = -2.3
        },
        {
            name = "RubBand68",
            bGotIt = false,
            area = 8,
            x = -759.6,
            y = -76.8,
            z = 8.725
        },
        {
            name = "RubBand40",
            bGotIt = false,
            area = 8,
            x = -760.4,
            y = -154.7,
            z = 7.4
        },
        {
            name = "RubBand59",
            bGotIt = false,
            area = 13,
            x = -656.8,
            y = -53.2,
            z = 55.245
        }
    }
    tblCard = {
        {
            bGotIt = false,
            area = 0,
            name = "GGCard01",
            x = 165.807,
            y = -77.422,
            z = 14.817
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard02",
            x = 507.938,
            y = -58.442,
            z = 2.42
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard03",
            x = 34.7,
            y = -150.3,
            z = 3.1
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard04",
            x = 165.36,
            y = -346.764,
            z = 3.002
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard06",
            x = 70.251,
            y = -102,
            z = 7.049
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard08",
            x = 31.2417,
            y = 188.951,
            z = 2.35932
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard11",
            x = 448.502,
            y = -205.207,
            z = 3.347
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard12",
            x = 532.588,
            y = -115.388,
            z = 5.5
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard13",
            x = 110.791,
            y = 5.736,
            z = 6.125
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard16",
            x = 446.2,
            y = -438.2,
            z = 3.95
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard17",
            x = 253.9,
            y = -339.3,
            z = 2.765
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard18",
            x = 283.125,
            y = -371.803,
            z = 2.73
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard19",
            x = 445.897,
            y = -247,
            z = 5.00264
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard20",
            x = 592,
            y = -122.2,
            z = 11.285
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard21",
            x = 167.691,
            y = 461.325,
            z = 6.70998
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard22",
            x = 417.2,
            y = 315.1,
            z = 12.285
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard23",
            x = 433.6,
            y = 480.6,
            z = 23.335
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard24",
            x = 352.1,
            y = 206,
            z = 4.725
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard25",
            x = 501,
            y = -438.5,
            z = 6.8
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard26",
            x = 561.1,
            y = -161.3,
            z = 7.445
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard28",
            x = -27,
            y = -248.7,
            z = 5.785
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard29",
            x = 202,
            y = 16.7,
            z = 5.82
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard30",
            x = 279.801,
            y = -469.597,
            z = 4.03
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard32",
            x = 229.9,
            y = 302.7,
            z = 1.41
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard33",
            x = 326.3,
            y = 100.3,
            z = 4.5
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard34",
            x = 120.6,
            y = -401,
            z = 7.7
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard36",
            x = 507.8,
            y = -24.9,
            z = 6.46
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard37",
            x = 583,
            y = -388.4,
            z = 5.435
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard38",
            x = 476.3,
            y = -217.1,
            z = 7.14
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard39",
            x = 206,
            y = 172.5,
            z = 0.525
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard40",
            x = 617.8,
            y = 160.7,
            z = 19.935
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard35",
            x = 121.9,
            y = -440.5,
            z = 3.1
        },
        {
            bGotIt = false,
            area = 0,
            name = "GGCard14",
            x = 233.3,
            y = 443.4,
            z = 4.6
        },
        {
            bGotIt = false,
            area = 9,
            name = "GGCard5",
            x = -760.265,
            y = 188.003,
            z = 90.935
        },
        {
            bGotIt = false,
            area = 56,
            name = "GGCard15",
            x = -673.533,
            y = 386.713,
            z = 2.419
        },
        {
            bGotIt = false,
            area = 30,
            name = "GGCard27",
            x = -739.9,
            y = 32.1,
            z = -1.85
        },
        {
            bGotIt = false,
            area = 50,
            name = "GGCard31",
            x = -787.4,
            y = 53.2,
            z = 7.3
        },
        {
            bGotIt = false,
            area = 35,
            name = "GGCard09",
            x = -410.861,
            y = 312.519,
            z = 2.64494
        },
        {
            bGotIt = false,
            area = 13,
            name = "GGCard10",
            x = -648.322,
            y = -72.1265,
            z = 55.15
        },
        {
            bGotIt = false,
            area = 57,
            name = "GGCard07",
            x = -664.288,
            y = 251.164,
            z = 15.243
        }
    }
    tblGnomes = {
        {
            bGotIt = false,
            area = 0,
            x = 604.096,
            y = -115.376,
            z = 5.83
        },
        {
            bGotIt = false,
            area = 0,
            x = 619.599,
            y = 205.569,
            z = 18.48
        },
        {
            bGotIt = false,
            area = 0,
            x = 478.421,
            y = 480.311,
            z = 19.72
        },
        {
            bGotIt = false,
            area = 0,
            x = 463.187,
            y = 487.064,
            z = 22.89
        },
        {
            bGotIt = false,
            area = 0,
            x = 344.335,
            y = -357.715,
            z = 2.677
        },
        {
            bGotIt = false,
            area = 0,
            x = 554.492,
            y = 377.262,
            z = 17.014
        },
        {
            bGotIt = false,
            area = 0,
            x = 532.137,
            y = 270.944,
            z = 16.867
        },
        {
            bGotIt = false,
            area = 0,
            x = 366.282,
            y = 458.851,
            z = 23.534
        },
        {
            bGotIt = false,
            area = 0,
            x = 143.463,
            y = -131.531,
            z = 6.82
        },
        {
            bGotIt = false,
            area = 0,
            x = 572.137,
            y = 477.839,
            z = 18.837
        },
        {
            bGotIt = false,
            area = 0,
            x = 438.648,
            y = 536.89,
            z = 23.626
        },
        {
            bGotIt = false,
            area = 0,
            x = 309.076,
            y = 403.923,
            z = 24.786
        },
        {
            bGotIt = false,
            area = 0,
            x = 479.635,
            y = 383.763,
            z = 15.997
        },
        {
            bGotIt = false,
            area = 0,
            x = 479.27,
            y = 382.295,
            z = 16.021
        },
        {
            bGotIt = false,
            area = 0,
            x = -143.477,
            y = -346.202,
            z = 4.739
        },
        {
            bGotIt = false,
            area = 0,
            x = 537.031,
            y = 446.643,
            z = 18.019
        },
        {
            bGotIt = false,
            area = 0,
            x = 65.321,
            y = 225.603,
            z = 3.117
        },
        {
            bGotIt = false,
            area = 0,
            x = 603.556,
            y = 383.165,
            z = 16.443
        },
        {
            bGotIt = false,
            area = 0,
            x = 348.057,
            y = -229.008,
            z = 2.252
        },
        {
            bGotIt = false,
            area = 0,
            x = 406.13,
            y = 395.838,
            z = 12.33
        },
        {
            bGotIt = false,
            area = 0,
            x = 346.661,
            y = 387.369,
            z = 21.49
        },
        {
            bGotIt = false,
            area = 0,
            x = 528.143,
            y = 174.455,
            z = 16.258
        },
        {
            bGotIt = false,
            area = 0,
            x = 484.465,
            y = 417.46,
            z = 17.041
        },
        {
            bGotIt = false,
            area = 0,
            x = 495.413,
            y = 431.474,
            z = 17.427
        },
        {
            bGotIt = false,
            area = 0,
            x = 442.3,
            y = 341.6,
            z = 16.8
        }
    }
end
