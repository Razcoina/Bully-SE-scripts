INVALID = -9999

function F_LoadEffect(effectTable)
    local x, y, z
    if effectTable.pointlist ~= nil then
        if effectTable.pointlist_id ~= nil then
            x, y, z = GetPointFromPointList(effectTable.pointlist, effectTable.pointlist_id)
        else
            x, y, z = GetPointList(effectTable.pointlist)
        end
        effectTable.id = EffectRegisterInArea(effectTable.effect, x, y, z, effectTable.zone)
    else
        effectTable.id = EffectRegisterInArea(effectTable.effect, effectTable.x, effectTable.y, effectTable.z, effectTable.zone)
    end
    if effectTable.orient.x ~= INVALID then
        EffectSetDirection(effectTable.id, effectTable.orient.x, effectTable.orient.y, effectTable.orient.z)
    end
    EffectSetNightOnly(effectTable.id, effectTable.bNightOnly)
end

F_LoadEffect({
    id = INVALID,
    zone = 38,
    effect = "TVFlickerLight",
    x = -666.706,
    y = 524.085,
    z = 7.016,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 38,
    effect = "boilerfire2",
    x = -784.127,
    y = 504.341,
    z = 3.115,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 224.89,
    y = 408.964,
    z = 11.454,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 229.227,
    y = 414.985,
    z = 11.488,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 177.124,
    y = 449.942,
    z = 13.366,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 173.387,
    y = 443.822,
    z = 13.546,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 143.493,
    y = 505.279,
    z = 40.745,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 143.493,
    y = 499.903,
    z = 40.745,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 119.859,
    y = 512.293,
    z = 8.55,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = true
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 120.979,
    y = 508.962,
    z = 8.55,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = true
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 93.897,
    y = 495.552,
    z = 12.633,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = true
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "CarnivalFire",
    x = 91.594,
    y = 498.155,
    z = 12.633,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = true
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SearchLightBeamParent",
    x = 196,
    y = 445.7,
    z = 1.77,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = true
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SearchLightBeamParent",
    x = 121.4,
    y = 397.2,
    z = 1.77,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = true
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "DustDirt",
    x = -738.062,
    y = -541.609,
    z = 11.223,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "DustDirt",
    x = -746.013,
    y = -542.731,
    z = 11.414,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "DustDirt",
    x = -755.385,
    y = -542.281,
    z = 11.085,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "DustDirt",
    x = -762.987,
    y = -440.687,
    z = 19.832,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "DustDirt",
    x = -766.769,
    y = -444.304,
    z = 19.898,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "DustDirt",
    x = -755.028,
    y = -428.629,
    z = 17.29,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "DustDirt",
    x = -743.472,
    y = -399.475,
    z = 15.485,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "DustDirt",
    x = -739.676,
    y = -395.285,
    z = 15.407,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "TorchFlame",
    x = -754.4,
    y = -536.4,
    z = 26.4,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "TorchFlame",
    x = -754.4,
    y = -528.5,
    z = 26.4,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 37,
    effect = "TorchFlame",
    x = -754.4,
    y = -517.2,
    z = 26.4,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "BarrelFire",
    x = 303,
    y = -300.5,
    z = 1.07,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "waterfallmist",
    x = -85.512,
    y = -311.538,
    z = 1.654,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ElectrocuteLRG",
    x = 156.157,
    y = -498.067,
    z = 14.99,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ElectricalSparkSpawnLRG",
    x = 139.04,
    y = -504.329,
    z = 8.25,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ElectricitySpawn",
    x = 145.286,
    y = -518.529,
    z = 4.3,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStack",
    x = 179.837,
    y = -483.921,
    z = 41.6042,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStack",
    x = 94.4754,
    y = -516.283,
    z = 38.108,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStack",
    x = 53.5224,
    y = -478.978,
    z = 30.6523,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStackBLK",
    x = 164.552,
    y = -425.836,
    z = 31.9157,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStack",
    x = 57.5704,
    y = -483.193,
    z = 30.6523,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStackBLK",
    x = -12.0194,
    y = -541.234,
    z = 33.0564,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStackBLK",
    x = 244.103,
    y = -455.566,
    z = 28.0484,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 216.921,
    y = -361.561,
    z = 11.5529,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 226.533,
    y = -396.808,
    z = 13.8261,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 312.891,
    y = -421.942,
    z = 10.45,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 68.2865,
    y = -310.458,
    z = 21.4614,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 86.4397,
    y = -460.818,
    z = 16.1089,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStackBLK",
    x = -53.8066,
    y = -500.532,
    z = 67.4129,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStackBLK",
    x = -56.2774,
    y = -518.624,
    z = 67.4129,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStack",
    x = 261.613,
    y = -310.034,
    z = 18.7942,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "SmokeStack",
    x = 200.563,
    y = -470.838,
    z = 27.19,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "waterfallmist",
    x = 646.092,
    y = 87.049,
    z = -1,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "waterfallmist",
    x = 645.169,
    y = 84.258,
    z = -1,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "waterfallmist",
    x = 643.987,
    y = 81.465,
    z = -1,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "waterfallmistSM",
    x = 651.877,
    y = 85.012,
    z = 8.972,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "waterfallmistSM",
    x = 650.794,
    y = 82.248,
    z = 8.972,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "waterfallmistSM",
    x = 649.862,
    y = 79.738,
    z = 8.972,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "LightHouseBeamParent",
    x = 234.511,
    y = 340.139,
    z = 25.331,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = true
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 333.72,
    y = 278.79,
    z = 14.431,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 528.154,
    y = 277.041,
    z = 33.6174,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 559.068,
    y = 209.838,
    z = 32.254,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 554.94,
    y = 252.649,
    z = 31.727,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "crows",
    x = 622.948,
    y = -99.768,
    z = 39.08,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 459.594,
    y = -89.214,
    z = 5.378,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 522.139,
    y = -87.096,
    z = 3.825,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 489.21,
    y = -88.011,
    z = 4.852,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 550.743,
    y = -91.297,
    z = 5.08,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 575.605,
    y = -89.27,
    z = 5.342,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 476.247,
    y = -283.647,
    z = 2.935,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 478.352,
    y = -314.285,
    z = 3.059,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 495.134,
    y = -349.877,
    z = 3.037,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 490.912,
    y = -414.896,
    z = 2.051,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 524.759,
    y = -446.034,
    z = 4.378,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 563.968,
    y = -483.311,
    z = 4.392,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 519.734,
    y = -322.59,
    z = 2.147,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "ManHoleSteam",
    x = 497.591,
    y = -232.983,
    z = 2.118,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "Chimney",
    x = 514.71,
    y = -487.556,
    z = 18.296,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "crows",
    x = 103.58,
    y = -82.743,
    z = 32.235,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "steam_Shower",
    x = 175.5,
    y = -62.8,
    z = 22.7,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "steam_Shower",
    x = 166.4,
    y = -57.5,
    z = 22.7,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "steam_Shower",
    x = 178.6,
    y = -83.4,
    z = 22.7,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "steam_Shower",
    x = 166.1,
    y = -89.4,
    z = 22.7,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 0,
    effect = "steam_Shower",
    x = 199.7,
    y = -57.2,
    z = 22.7,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 4,
    effect = "greenbeakersmoke",
    x = -596.629,
    y = 326.037,
    z = 35.2,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 4,
    effect = "drip",
    x = -592.839,
    y = 318.088,
    z = 35.6,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 4,
    effect = "drip",
    x = -597.038,
    y = 323.345,
    z = 35.519,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 4,
    effect = "drip",
    x = -592.805,
    y = 320.685,
    z = 35.603,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 4,
    effect = "BuntzenFlame",
    x = -596.179,
    y = 323.505,
    z = 35.361,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 5,
    effect = "boilerfire2",
    x = -696.523,
    y = 205.154,
    z = 31.767,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "DirtyDrip",
    x = -778.505,
    y = -89.768,
    z = 12.938,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "DirtyDrip",
    x = -773.311,
    y = -135.438,
    z = 16.17,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "DirtyDrip",
    x = -763.834,
    y = -141.038,
    z = 15.649,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "DirtyDrip",
    x = -765.068,
    y = -128.765,
    z = 15.503,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "DirtyDrip",
    x = -772.626,
    y = -85.454,
    z = 11.989,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "DirtyDrip",
    x = -755.574,
    y = -151.812,
    z = 13.053,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "SewageWater",
    x = -765.616,
    y = -128.28,
    z = 15.866,
    orient = {
        x = 0.3,
        y = 0.2,
        z = -0.7
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "SewageWater",
    x = -764.124,
    y = -141.299,
    z = 15.866,
    orient = {
        x = 0.3,
        y = 0.2,
        z = -0.7
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "SewageWater",
    x = -766.143,
    y = -143.277,
    z = 15.864,
    orient = {
        x = 0.3,
        y = 0.2,
        z = -0.7
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "steam",
    x = -759.449,
    y = -58.878,
    z = 12.546,
    orient = {
        x = 0.2,
        y = -0.1,
        z = -0.8
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "ElectricalSparkSpawn",
    x = -762.167,
    y = -159.827,
    z = 10.152,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "ElectricalSparkSpawn",
    x = -766.245,
    y = -124.883,
    z = 10.019,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "ElectricalSparkSpawn",
    x = -775.226,
    y = -108.353,
    z = 10.561,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 8,
    effect = "ElectricalSparkSpawn",
    x = -769.159,
    y = -95.189,
    z = 9.334,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 9,
    effect = "boilerfire2",
    x = -772.25,
    y = 187.49,
    z = 90.996,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 9,
    effect = "boilerfire2",
    x = -772.4,
    y = 187.49,
    z = 91.057,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 2,
    effect = "ManHoleSteam",
    x = -630.485,
    y = -263.461,
    z = -0.551,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 2,
    effect = "ManHoleSteam",
    x = -629.368,
    y = -263.43,
    z = -0.278,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 2,
    effect = "IncineratorSmoke",
    x = -631.882,
    y = -263.555,
    z = -0.658,
    orient = {
        x = 1,
        y = -0.1,
        z = 1
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 2,
    effect = "Flys",
    x = -631.951,
    y = -266.31,
    z = 0.673,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 23,
    effect = "boilerfire2",
    x = -649.348,
    y = 221.234,
    z = -0.183,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 23,
    effect = "boilerfire2",
    x = -649.609,
    y = 221.234,
    z = -0.203,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 26,
    effect = "Flys",
    x = -571.965,
    y = 394.993,
    z = 2.152,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 26,
    effect = "Flys",
    x = -575.833,
    y = 394.993,
    z = 2.152,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "CandleFlame",
    x = -560.815,
    y = 134.555,
    z = 48.301,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "CandleFlame",
    x = -560.826,
    y = 132.063,
    z = 48.301,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "CandleFlame",
    x = -559.508,
    y = 134.555,
    z = 48.301,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "CandleFlame",
    x = -559.518,
    y = 132.063,
    z = 48.301,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "CandleFlame",
    x = -531.496,
    y = 134.532,
    z = 48.98,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "CandleFlame",
    x = -531.496,
    y = 132.164,
    z = 48.98,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "boilerfire2",
    x = -531.355,
    y = 133.4,
    z = 46.313,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "boilerfire2",
    x = -531.355,
    y = 133.3,
    z = 46.313,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "Flys",
    x = -547.187,
    y = 132.464,
    z = 60.32,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 32,
    effect = "Flys",
    x = -547.187,
    y = 133.459,
    z = 59.931,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 35,
    effect = "boilerfire2",
    x = -445.042,
    y = 297.118,
    z = -7.696,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 35,
    effect = "boilerfire2",
    x = -444.858,
    y = 297.118,
    z = -7.696,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 20,
    effect = "AcidPool",
    x = -756.513,
    y = 78.03,
    z = -0.135,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 55,
    effect = "goldfish",
    x = -488.862,
    y = -51.471,
    z = 11.827,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 55,
    effect = "bubbles",
    x = -489.001,
    y = -53.698,
    z = 9.902,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 55,
    effect = "bubbles",
    x = -488.704,
    y = -50.008,
    z = 9.902,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 55,
    effect = "bubbles",
    x = -491.691,
    y = -51.751,
    z = 11.139,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 55,
    effect = "boilerfire2",
    x = -454.945,
    y = -72.566,
    z = 10.035,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 55,
    effect = "boilerfire2",
    x = -455.092,
    y = -72.666,
    z = 10.134,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 55,
    effect = "TVFlickerLight",
    x = -439.721,
    y = -52.377,
    z = 10.442,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 53,
    effect = "GymFire",
    x = 26.82449,
    y = -106.95383,
    z = 77.03485,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 53,
    effect = "SmokeStackLRG",
    x = 26.82449,
    y = -106.95383,
    z = 77.03485,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 53,
    effect = "GymFire",
    x = 66.83613,
    y = -76.22343,
    z = 67.96165,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 53,
    effect = "SmokeStackLRG",
    x = 66.83613,
    y = -76.22343,
    z = 67.96165,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 53,
    effect = "GymFire",
    x = 34.07664,
    y = -9.62429,
    z = 58.20825,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 53,
    effect = "SmokeStackLRG",
    x = 34.07664,
    y = -9.62429,
    z = 58.20825,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 53,
    effect = "GymFire",
    x = 39.26028,
    y = -15.73993,
    z = 58.20825,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect({
    id = INVALID,
    zone = 53,
    effect = "SmokeStackLRG",
    x = 39.26028,
    y = -15.73993,
    z = 58.20825,
    orient = {
        x = INVALID,
        y = INVALID,
        z = INVALID
    },
    bNightOnly = false
})
F_LoadEffect = nil
