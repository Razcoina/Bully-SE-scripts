--[[ Changes to this file:
    * Rewrote all local variables, did my best to find names, definitely requires testing
    * Modified function MissionSetup, may require testing
    * Modified function MissionCleanup, may require testing
    * Added function DebugAnimations, may require testing
    * Modified function main, may require testing
    * Removed function F_GetTSize, not present in original script
    * Added function F_CalcTime, may require testing
    * Modified function F_IntroCinematic, may require testing
    * Heavily modified function F_ActionsCallback, requires testing
]]

--[[ Original variables (ALL THE WAY TO LINE 1356)
local missionSuccess = false
local gUnlockAnim
local longWindow = 2
local shortWindow = 1
local medWindow = 1
local gbFailed = false
local totalFailed = 1
local camerasTable = {}
local gGetReadyText = "C6_INT_07"
local shopTeach, classmate01, classmate02, classmate03
animsroot = "/Global/C6/Animations/"
local AnimSeqTier1 = {
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 13,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 13,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 3,
        Anim = "NoTools/TurnCrank/TurnCrank_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/TurnCrank/TurnCrank_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 17,
        Point = false,
        Cam = 3,
        Anim = "Tools/RatchetWheel/PickupRatchet"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 17,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/RatchetWheel/RatchetFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/RatchetWheel/PutDownRatchet"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 17,
        Point = false,
        Cam = 3,
        Anim = "Tools/RatchetWheel/PickupRatchet"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 17,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/RatchetWheel/RatchetFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/RatchetWheel/PutDownRatchet"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 6,
        Point = false,
        Cam = 5,
        Anim = "NoTools/TurnCrank/TurnCrank_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 6,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/TurnCrank/TurnCrank_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 23,
        Anim = nil,
        Point = false
    }
}
local AnimSeqTier2 = {
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 13,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 13,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 3,
        Anim = "NoTools/TurnCrank/TurnCrank_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/TurnCrank/TurnCrank_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 13,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 13,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 3,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 0,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 0,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 17,
        Point = false,
        Cam = 2,
        Anim = "Tools/RatchetWheel/PickupRatchet"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 17,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/RatchetWheel/RatchetFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/RatchetWheel/PutDownRatchet"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 3,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 23,
        Anim = nil,
        Point = false
    }
}
local AnimSeqTier3 = {
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 7,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 7,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 13,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 13,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 7,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 7,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 17,
        Point = false,
        Cam = 2,
        Anim = "Tools/RatchetWheel/PickupRatchet"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 17,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/RatchetWheel/RatchetFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/RatchetWheel/PutDownRatchet"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 14,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 14,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 17,
        Point = false,
        Cam = 2,
        Anim = "Tools/RatchetWheel/PickupRatchet"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 17,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/RatchetWheel/RatchetFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/RatchetWheel/PutDownRatchet"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 14,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 14,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 23,
        Anim = nil,
        Point = false
    }
}
local AnimSeqTier4 = {
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 14,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 14,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 14,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 14,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 17,
        Point = false,
        Cam = 2,
        Anim = "Tools/RatchetWheel/PickupRatchet"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 17,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/RatchetWheel/RatchetFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/RatchetWheel/PutDownRatchet"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 14,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 14,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 10,
        Point = false,
        Cam = 4,
        Anim = "NoTools/TurnCrank/TurnCrank_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 10,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/TurnCrank/TurnCrank_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 7,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 7,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 13,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 13,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 23,
        Anim = nil,
        Point = false
    }
}
local AnimSeqTier5 = {
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 7,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 7,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 10,
        Point = false,
        Cam = 4,
        Anim = "NoTools/TurnCrank/TurnCrank_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 10,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/TurnCrank/TurnCrank_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 7,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 7,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 13,
        Point = false,
        Cam = 5,
        Anim = "Tools/TightenSpoke/PickupTightener"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 13,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/TightenSpoke/TightenerFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "Tools/TightenSpoke/PutDownTightener"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 10,
        Point = false,
        Cam = 3,
        Anim = "NoTools/TurnCrank/TurnCrank_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 10,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/TurnCrank/TurnCrank_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 0,
        Point = false,
        Cam = 2,
        Anim = "Tools/RatchetWheel/PickupRatchet"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 0,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/RatchetWheel/RatchetFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/RatchetWheel/PutDownRatchet"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 8,
        Point = false,
        Cam = 2,
        Anim = "Tools/Oil/PickupOil"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 8,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Oil/OilFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Oil/PutDownOil"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 7,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 7,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 14,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 14,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 17,
        Point = false,
        Cam = 2,
        Anim = "Tools/RatchetWheel/PickupRatchet"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 17,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/RatchetWheel/RatchetFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/RatchetWheel/PutDownRatchet"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 2,
        Point = false,
        Cam = 5,
        Anim = "NoTools/SpinWheel/SpinWheel_loop"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 2,
        Point = true,
        Anim = "None",
        fail_anim = "NoTools/SpinWheel/SpinWheel_fail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Cam = 4,
        Anim = "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/Stop_wheel"
    },
    {
        waitTime = 0.5,
        windowTime = medWindow,
        act = 14,
        Point = false,
        Cam = 3,
        Anim = "Tools/Torch/PickupTorch"
    },
    {
        waitTime = 0,
        windowTime = longWindow,
        act = 14,
        Point = true,
        Anim = "None",
        fail_anim = "Tools/Torch/TorchFail"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 22,
        Point = false,
        Anim = "Tools/Torch/PutDownTorch"
    },
    {
        waitTime = 0.5,
        windowTime = shortWindow,
        act = 23,
        Anim = nil,
        Point = false
    }
}
local diff_easy = 1
]] -- Original variables

local missionSuccess = false
local L1_1 = 0
local L2_1 = 1
local L3_1 = 2
local gUnlockAnim
local longWindow = 1.7
local shortWindow = 1.7
local medWindow = 1.7
local camerasTable = {}
local gGetReadyText = "C6_INT_07"
local shopTeach, classmate01, classmate02, classmate03
local tab1 = {
    7,
    8,
    3,
    1
}
local tab2 = {
    4,
    5,
    2,
    0
}
local tab3 = { 3, 0 }
local tab4 = { 6, 9 }
animsroot = "/Global/C6/Animations/"
local gActions = {
    0,
    1,
    2,
    3,
    4,
    5,
    7,
    8,
    23,
    22
}
local AnimSeqTier1 = {
    {
        waitTime = 0.5,
        act = 22,
        cams = { 4 },
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_loop",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = medWindow,
        tab = tab2
    },
    {
        waitTime = 0.2,
        act = 22,
        anim = nil,
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = medWindow,
        tab = tab1
    },
    {
        waitTime = 0.2,
        act = 22,
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = medWindow,
        tab = tab2
    },
    {
        waitTime = 0.5,
        act = 0,
        cams = { 2 },
        anim = animsroot .. "Tools/RatchetWheel/PickupRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = medWindow,
        tab = tab1
    },
    {
        waitTime = 0.2,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = medWindow,
        tab = tab2
    },
    {
        waitTime = 0.2,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = medWindow,
        tab = tab2
    },
    {
        waitTime = 0.2,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = medWindow,
        tab = tab1
    },
    {
        waitTime = 0.2,
        act = 0,
        anim = animsroot .. "Tools/RatchetWheel/PutDownRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = medWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 23,
        cams = { 2 },
        anim = animsroot .. "NoTools/SpinWheel/SpinWheel_loop",
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = medWindow,
        tab = tab1
    },
    {
        waitTime = 0.2,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = medWindow,
        tab = tab1
    },
    {
        waitTime = 0.2,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = medWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 34,
        anim = nil,
        fail_anim = nil,
        window = medWindow,
        tab = nil
    }
}
local AnimSeqTier2 = {
    {
        waitTime = 0.5,
        act = 22,
        cams = { 4 },
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_loop",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = nil,
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.5,
        act = 2,
        cams = { 2 },
        anim = animsroot .. "Tools/Oil/PickupOil",
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = animsroot .. "Tools/Oil/PutDownOil",
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.5,
        act = 0,
        cams = { 2 },
        anim = animsroot .. "Tools/RatchetWheel/PickupRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = animsroot .. "Tools/RatchetWheel/PutDownRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.5,
        act = 23,
        cams = { 5 },
        anim = animsroot .. "NoTools/SpinWheel/SpinWheel_loop",
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = medWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.5,
        act = 34,
        anim = nil,
        fail_anim = nil,
        window = medWindow,
        tab = nil,
    }
}
local AnimSeqTier3 = {
    {
        waitTime = 0.5,
        act = 22,
        cams = { 4 },
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_loop",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = nil,
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = medWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.5,
        act = 0,
        cams = { 2 },
        anim = animsroot .. "Tools/RatchetWheel/PickupRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = animsroot .. "Tools/RatchetWheel/PutDownRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.5,
        act = 22,
        cams = { 4 },
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_loop",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = nil,
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.5,
        act = 2,
        cams = { 2 },
        anim = animsroot .. "Tools/Oil/PickupOil",
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab2,
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = animsroot .. "Tools/Oil/PutDownOil",
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.5,
        act = 23,
        cams = { 5 },
        anim = animsroot .. "NoTools/SpinWheel/SpinWheel_loop",
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1,
    },
    {
        waitTime = 0.5,
        act = 34,
        anim = nil,
        fail_anim = nil,
        window = medWindow,
        tab = nil,
    }
}
local AnimSeqTier4 = {
    {
        waitTime = 0.5,
        act = 23,
        cams = { 5 },
        anim = animsroot .. "NoTools/SpinWheel/SpinWheel_loop",
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/stop_wheel",
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 0,
        cams = { 2 },
        anim = animsroot .. "Tools/RatchetWheel/PickupRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = animsroot .. "Tools/RatchetWheel/PutDownRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 22,
        cams = { 4 },
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_loop",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = nil,
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.5,
        act = 2,
        cams = { 2 },
        anim = animsroot .. "Tools/Oil/PickupOil",
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = animsroot .. "Tools/Oil/PutDownOil",
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 1,
        cams = { 3 },
        anim = animsroot .. "Tools/Torch/PickupTorch",
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = nil,
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = nil,
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = nil,
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = animsroot .. "Tools/Torch/PutDownTorch",
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 22,
        cams = { 4 },
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_loop",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = nil,
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 34,
        anim = nil,
        fail_anim = nil,
        window = medWindow,
        tab = nil
    }
}
local AnimSeqTier5 = {
    {
        waitTime = 0.5,
        act = 1,
        cams = { 3 },
        anim = animsroot .. "Tools/Torch/PickupTorch",
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = nil,
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = nil,
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = nil,
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = animsroot .. "Tools/Torch/PutDownTorch",
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 3,
        cams = { 5 },
        anim = animsroot .. "Tools/TightenSpoke/PickupTightener",
        fail_anim = animsroot .. "Tools/TightenSpoke/TightenerFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 3,
        anim = nil,
        fail_anim = animsroot .. "Tools/TightenSpoke/TightenerFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 3,
        anim = nil,
        fail_anim = animsroot .. "Tools/TightenSpoke/TightenerFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 3,
        anim = nil,
        fail_anim = animsroot .. "Tools/TightenSpoke/TightenerFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 3,
        anim = animsroot .. "Tools/TightenSpoke/PutDownTightener",
        fail_anim = animsroot .. "Tools/TightenSpoke/TightenerFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 22,
        cams = { 4 },
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_loop",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = nil,
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 22,
        anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail/TurnCrank_fail_real/stop_crank",
        fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 0,
        cams = { 2 },
        anim = animsroot .. "Tools/RatchetWheel/PickupRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = nil,
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 0,
        anim = animsroot .. "Tools/RatchetWheel/PutDownRatchet",
        fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 23,
        cams = { 5 },
        anim = animsroot .. "NoTools/SpinWheel/SpinWheel_loop",
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail/SpinWheel_fail_real/stop_wheel",
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 2,
        cams = { 2 },
        anim = animsroot .. "Tools/Oil/PickupOil",
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = nil,
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 2,
        anim = animsroot .. "Tools/Oil/PutDownOil",
        fail_anim = animsroot .. "Tools/Oil/OilFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 1,
        cams = { 3 },
        anim = animsroot .. "Tools/Torch/PickupTorch",
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = nil,
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = nil,
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = nil,
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab2
    },
    {
        waitTime = 0.1,
        act = 1,
        anim = animsroot .. "Tools/Torch/PutDownTorch",
        fail_anim = animsroot .. "Tools/Torch/TorchFail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 23,
        cams = { 5 },
        anim = animsroot .. "NoTools/SpinWheel/SpinWheel_loop",
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.1,
        act = 23,
        anim = nil,
        fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
        window = longWindow,
        tab = tab1
    },
    {
        waitTime = 0.5,
        act = 34,
        anim = nil,
        fail_anim = nil,
        window = medWindow,
        tab = nil
    }
}
local diff_easy = 1

function F_SetDifficulty()
    if nCurrentClass == 1 then
        AnimSeq = AnimSeqTier1
        gUnlockAnim = "/Global/C6/Animations/Success"
        gGrade = 1
    elseif nCurrentClass == 2 then
        AnimSeq = AnimSeqTier2
        gUnlockAnim = "/Global/C6/Animations/Unlocks/SuccessMed1"
        gGrade = 2
    elseif nCurrentClass == 3 then
        AnimSeq = AnimSeqTier3
        gUnlockAnim = "/Global/C6/Animations/Unlocks/SuccessHi2"
        gGrade = 3
    elseif nCurrentClass == 4 then
        AnimSeq = AnimSeqTier4
        gUnlockAnim = "/Global/C6/Animations/Unlocks/SuccessHi1"
        gGrade = 4
    elseif nCurrentClass == 5 then
        AnimSeq = AnimSeqTier5
        gUnlockAnim = "/Global/C6/Animations/Unlocks/SuccessHi3"
        gGrade = 5
    elseif nCurrentClass >= 6 then
        AnimSeq = AnimSeqTier5
        gUnlockAnim = "/Global/C6/Animations/Unlocks/SuccessHi3"
        gGrade = 5
    end
    --DebugPrint("Difficulty tier: " .. nCurrentClass)
    for i, v in AnimSeq do
        if v.tab and v.act == nil then
            v.act = PickRandom(v.tab)
        end
    end
end

function F_ToggleHUDItems(b_on)
    ToggleHUDComponentVisibility(4, b_on)
    ToggleHUDComponentVisibility(5, b_on)
    ToggleHUDComponentVisibility(11, b_on)
    ToggleHUDComponentVisibility(0, b_on)
end

function MissionSetup() -- ! Modified
    MissionDontFadeIn()
    DATLoad("C6.DAT", 2)
    DATLoad("CLASSLOC.DAT", 2)
    DATInit()
    --[[
    HUDSaveVisibility()
    HUDClearAllElements()
    ToggleHUDComponentVisibility(42, true)
    ]] -- Removed this
    LoadAnimationGroup("MINIBIKE")
    LoadAnimationGroup("SHOPBIKE")
    LoadAnimationGroup("MINICHEM")
    LoadAnimationGroup("MINI_React")
    LoadAnimationGroup("NPC_Spectator")
    LoadAnimationGroup("NPC_Adult")
    LoadActionTree("Act/Conv/C4.act")
    LoadActionTree("Act/Conv/C6.act")
    AreaTransitionPoint(18, POINTLIST._C6_PLAYER_FRONT_DOOR, nil, true)
    SoundEnableInteractiveMusic(false)
    PlayerSetPunishmentPoints(0)
    MinigameCreate("CHEM", false)
    while MinigameIsReady() == false do
        Wait(0)
    end
end

function F_ClassSetup()
    shopTeach = PedCreatePoint(126, POINTLIST._C6_TEACHER)
    classmate01 = PedCreatePoint(24, POINTLIST._C6_CLASSMATE01)
    classmate02 = PedCreatePoint(27, POINTLIST._C6_CLASSMATE02)
    classmate03 = PedCreatePoint(26, POINTLIST._C6_CLASSMATE03)
    PedSetAsleep(classmate01, true)
    PedSetAsleep(classmate02, true)
    PedSetAsleep(classmate03, true)
    Wait(2)
    PAnimCreate(TRIGGER._C6_SHOPBIKE)
    ActionAnimFile = "Act/Conv/C6.act"
    camerasTable = {
        {
            cameraPath = PATH._C6_CAMERAPATH02,
            x = -418.4414,
            y = 379.6123,
            z = 82.2042,
            speed = 0.2
        },
        {
            cameraPath = PATH._C6_CAMERAPATH03,
            x = -418.5426,
            y = 379.4764,
            z = 82.0446,
            speed = 0.2
        },
        {
            cameraPath = PATH._C6_CAMERAPATH04,
            x = -418.3551,
            y = 379.5116,
            z = 82.2646,
            speed = 0.2
        },
        {
            cameraPath = PATH._C6_CAMERAPATH05,
            x = -418.616,
            y = 379.3159,
            z = 82.0646,
            speed = 0.2
        },
        {
            cameraPath = PATH._C6_CAMERAPATH06,
            x = -418.592,
            y = 379.5708,
            z = 82.0846,
            speed = 0.2
        },
        {
            cameraPath = PATH._C6_CAMERAPATH07,
            x = -418.5335,
            y = 379.6112,
            z = 82.2242,
            speed = 0.2
        }
    }
    LoadModels({
        375,
        374,
        373
    })
    SoundStopPA()
    SoundStopCurrentSpeechEvent()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    F_ToggleHUDItems(false)
end

function MissionCleanup() -- ! Modified
    F_MakePlayerSafeForNIS(false)
    --[[
    HUDRestoreVisibility()
    ]] -- Removed this
    SoundRestartPA()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundFadeoutStream()
    SoundEnableInteractiveMusic(true)
    F_ToggleHUDItems(true)
    MinigameDestroy()
    PlayerSetPunishmentPoints(0)
    Wait(1)
    PlayerWeaponHudLock(false)
    --[[
    totalSucceed = 1
    totalFailed = 0
    ]] -- Changed to:
    totalSucceed = 15
    totalFailed = 15
    AreaTransitionPoint(0, POINTLIST._C6_EXITLOC) -- Added this
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PlayerSetHealth(PedGetMaxHealth(gPlayer))
    end
    UnLoadAnimationGroup("MINIBIKE")
    UnLoadAnimationGroup("SHOPBIKE")
    UnLoadAnimationGroup("MINICHEM")
    UnLoadAnimationGroup("MINI_React")
    UnLoadAnimationGroup("NPC_Spectator")
    UnLoadAnimationGroup("NPC_Adult")
    --[[
    AreaTransitionPoint(0, POINTLIST._C6_EXITLOC)
    ]] -- Removed this
    CameraReturnToPlayer()
    CameraReset()
    PlayerSetControl(1)
    DATUnload(2)
end

function DebugAnimations() -- ! Added this
    TextPrintString("START DEBUG ! ", 3, 1)
    CameraSetPath(camerasTable[1].cameraPath, true)
    CameraSetSpeed(camerasTable[1].speed, camerasTable[1].speed, camerasTable[1].speed)
    CameraLookAtXYZ(camerasTable[1].x, camerasTable[1].y, camerasTable[1].z, true)
    local anims = {
        {
            anim = animsroot .. "NoTools/SpinWheel/SpinWheel_loop",
            fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
            window = longWindow,
            tab = tab1
        },
        {
            anim = animsroot .. "NoTools/SpinWheel/SpinWheelPlayer_loop",
            fail_anim = animsroot .. "NoTools/SpinWheel/SpinWheel_fail",
            window = longWindow,
            tab = tab1
        },
        {
            anim = animsroot .. "NoTools/TurnCrank/TurnCrank_loop",
            fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
            window = longWindow,
            tab = tab2
        },
        {
            anim = animsroot .. "Tools/RatchetWheel/PickupRatchet",
            fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
            window = longWindow,
            tab = tab1
        },
        {
            anim = animsroot .. "Tools/RatchetWheel/PutDownRatchet",
            fail_anim = animsroot .. "Tools/RatchetWheel/RatchetFail",
            window = longWindow,
            tab = tab1
        },
        {
            anim = animsroot .. "Tools/Oil/PickupOil",
            fail_anim = animsroot .. "Tools/Oil/OilFail",
            window = longWindow,
            tab = tab1
        },
        {
            anim = animsroot .. "Tools/Oil/PutDownOil",
            fail_anim = animsroot .. "Tools/Oil/OilFail",
            window = longWindow,
            tab = tab1
        },
        {
            anim = animsroot .. "Tools/Torch/PickupTorch",
            fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
            window = longWindow,
            tab = tab2
        },
        {
            anim = animsroot .. "Tools/Torch/PutDownTorch",
            fail_anim = animsroot .. "NoTools/TurnCrank/TurnCrank_fail",
            window = longWindow,
            tab = tab2
        },
        {
            anim = animsroot .. "Tools/TightenSpoke/PickupTightener",
            fail_anim = animsroot .. "NoTools/TurnCrank/TightenerFail",
            window = longWindow,
            tab = tab2
        },
        {
            anim = animsroot .. "Tools/TightenSpoke/PutDownTightener",
            fail_anim = animsroot .. "NoTools/TurnCrank/TightenerFail",
            window = longWindow,
            tab = tab2
        }
    }
    local L1_2 = true
    local L2_2 = 1
    local L3_2 = 1
    while L1_2 do
        if IsButtonPressed(0, 0) then
            L3_2 = L3_2 - 1
            if L3_2 < 1 then
                L3_2 = table.getn(anims)
            end
            TextPrintString("Selecting" .. anims[L3_2].anim, 3, 2)
            Wait(500)
        end
        if IsButtonPressed(2, 0) then
            TextPrintString("ANIMATION:" .. anims[L3_2].anim, 5, 1)
            PedSetActionNode(gPlayer, anims[L3_2].anim, ActionAnimFile)
            Wait(500)
        end
        if IsButtonPressed(3, 0) then
            PedSetActionNode(gPlayer, anims[L3_2].fail_anim, ActionAnimFile)
            TextPrintString("ANIMATION:" .. anims[L3_2].fail_anim, 5, 1)
            Wait(500)
        end
        if IsButtonPressed(1, 0) then
            L3_2 = L3_2 + 1
            if L3_2 > table.getn(anims) then
                L3_2 = 1
            end
            TextPrintString("Selecting" .. anims[L3_2].anim, 3, 2)
            Wait(500)
        end
        Wait(0)
    end
end

function main() -- ! Modified
    while not bStageLoaded do
        Wait(0)
    end
    F_ClassSetup()
    F_SetDifficulty() -- Added this
    LoadModels({
        373,
        374,
        375
    }, true)
    math.randomseed(GetTimer())
    --[[
    F_SetDifficulty()
    ]] -- Removed this
    F_MakePlayerSafeForNIS(true)
    PlayerWeaponHudLock(true)
    F_IntroCinematic()
    PlayerSetControl(0)
    SoundStopInteractiveStream(0)                                                    -- Added this
    SoundPlayStream("MS_ShopClass.rsm", 0.45, 2, 1)                                  -- Added this
    CameraSetPath(camerasTable[1].cameraPath, true)                                  -- Added this
    CameraSetSpeed(camerasTable[1].speed, camerasTable[1].speed, camerasTable[1].speed) -- Added this
    CameraLookAtXYZ(camerasTable[1].x, camerasTable[1].y, camerasTable[1].z, true)   -- Added this
    --[[
    Wait(200)
    ]] -- Changed to:
    Wait(1000)
    local x, y, z = GetPointList(POINTLIST._C6_PSTART)
    PlayerSetPosSimple(x, y, z)
    --[[
    PlayerFaceHeading(135, 0)
    ]] -- Changed to:
    PlayerFaceHeadingNow(180)
    --[[
    Wait(200)
    CameraSetPath(camerasTable[1].cameraPath, true)
    CameraSetSpeed(camerasTable[1].speed, camerasTable[1].speed, camerasTable[1].speed)
    CameraLookAtXYZ(camerasTable[1].x, camerasTable[1].y, camerasTable[1].z, true)
    ]]                                      -- Removed this
    TutorialShowMessage("C6_INST01")     -- Added this
    MissionObjectiveAdd("C6_INST01", 0, -1) -- Added this
    CameraSetWidescreen(false)
    --[[
    MinigameSetType(1)
    MinigameStart()
    ClassChemSetGameType("SHOP")
    MinigameEnableHUD(true)
    for i = 1, F_GetTSize(AnimSeq) do
        ClassChemAddAction(0, AnimSeq[i].act, AnimSeq[i].waitTime, AnimSeq[i].windowTime, AnimSeq[i].Point)
    end
    CameraFade(1000, 1)
    Wait(1100)
    SoundStopInteractiveStream(0)
    SoundPlayStream("MS_ShopClass.rsm", 1, 2, 1)
    TextPrint(gGetReadyText, 2, 1)
    Wait(2500)
    TextPrint("C6_INT_08", 1, 1)
    Wait(2000)
    if MinigameIsActive() then
        ClassChemFeedbackCallback(F_ActionsCallback)
        ClassChemStartSeq(1)
    end
    while MinigameIsActive() do
        if gbFailed == true then
            for index = 1, F_GetTSize(AnimSeq) do
                ClassChemResetAction(0, index - 1, AnimSeq[index].waitTime, AnimSeq[index].windowTime)
            end
            TextPrint(gGetReadyText, 2, 1)
            Wait(2500)
            TextPrint("C6_INT_08", 1, 1)
            Wait(2000)
            if MinigameIsActive() then
                ClassChemStartSeq(1)
            end
            gbFailed = false
        end
        Wait(0)
    end
    if MinigameIsSuccess() then
        totalSucceed = 1
    end
    Wait(0)
    ]]                             -- Removed this
    CameraFade(1000, 1)         -- Added this
    local L3_2 = -1             -- Added this
    local L4_2 = 1              -- Added this
    local L5_2 = 0              -- Added this
    local L6_2 = 0              -- Added this
    while L6_2 < 1 and L5_2 < 3 do -- Added this
        Wait(1100)
        local L7_2 = 1
        local L8_2 = table.getn(AnimSeq)
        local L9_2 = 0
        local L10_2 = 0
        MinigameStart()
        ClassChemSetGameType("SHOP")
        ClassChemSetActiveActions(5)
        MinigameEnableHUD(true)
        ClassChemSetScrollyVisible(false)
        for key, value in AnimSeq do
            if key == 1 then
                ClassChemAddAction(0, value.act, value.waitTime, 1)
            else
                ClassChemAddAction(0, value.act, value.waitTime, 1)
            end
        end
        local L11_2 = 0
        local L12_2 = 0
        TextPrint(gGetReadyText, 2, 1)
        Wait(2500)
        TextPrint("C6_INT_08", 1, 1)
        Wait(2000)
        ClassChemStartSeq(0)
        TutorialRemoveMessage()
        while MinigameIsActive() do
            if not gTorchLit and PedIsPlaying(gPlayer, "/Global/C6/Animations/Tools/Torch/PickupTorch/ApplyTorch", true) then
                gTorchLit = true
                local x, y, z = GetPointList(POINTLIST._C6_BURNINGEFFECT)
                gEffFlame = EffectCreate("TorchImpact", x, y, z)
            elseif gTorchLit and not PedIsPlaying(gPlayer, "/Global/C6/Animations/Tools/Torch/PickupTorch/ApplyTorch", true) then
                EffectKill(gEffFlame)
                gEffFlame = nil
                gTorchLit = false
            end
            if L7_2 < L8_2 then
                if ClassChemGetActionJustFinished(AnimSeq[L7_2].act) then
                    if not gSpeechPlayed then
                        SoundPlayScriptedSpeechEvent(shopTeach, "SHOP_CLASS", 13, "jumbo", true)
                        gSpeechPlayed = true
                        gSpeechTimer = GetTimer()
                    elseif 5500 < GetTimer() - gSpeechTimer then
                        gSpeechPlayed = false
                    end
                    F_ActionsCallback(AnimSeq[L7_2], true)
                    L7_2 = L7_2 + 1
                    Wait(300)
                end
                if ClassChemGetActionJustFailed(AnimSeq[L7_2].act) then
                    L5_2 = L5_2 + 1
                    if 2 < L9_2 then
                        SoundPlayScriptedSpeechEvent(shopTeach, "SHOP_CLASS", 11, "jumbo", true)
                    else
                        SoundPlayScriptedSpeechEvent(shopTeach, "SHOP_CLASS", 12, "jumbo", true)
                    end
                    gFailed = true
                    F_ActionsCallback(AnimSeq[L7_2], false)
                    L7_2 = L7_2 + 1
                    if 3 <= L5_2 then
                        StartVibration(2, 1500, 254)
                    elseif L5_2 == 1 then
                        gGetReadyText = "C6_GETREADY2"
                    elseif L5_2 == 2 then
                        gGetReadyText = "C6_GETREADY3"
                    end
                    Wait(300)
                end
            end
            Wait(0)
        end
        if MinigameIsSuccess() then
            break
        end
        Wait(0)
    end
    PedSetActionNode(gPlayer, "/Global/C6/Animations/CycleClear", ActionAnimFile)
    CameraSetPath(camerasTable[5].cameraPath, true)
    CameraSetSpeed(camerasTable[5].speed, camerasTable[5].speed, camerasTable[5].speed)
    CameraLookAtXYZ(camerasTable[5].x, camerasTable[5].y, camerasTable[5].z, true)
    --print("<<<<<<<<<<<<<<<<<<<<< BEFORE MISSION QUERY")
    if MinigameIsSuccess() then
        minigameWasSuccess = true
        if nCurrentClass == 5 and not bIsRepeatable then
        else
            --print("<<<<<<<<<<<<<<<<<<<<< success")
            PedSetActionNode(gPlayer, gUnlockAnim, "Act/Conv/C6.act")
            --[[
            SoundPlayScriptedSpeechEvent(shopTeach, "CLASSSHOP", 14, "jumbo", true)
            ]] -- Changed to:
            SoundPlayScriptedSpeechEvent(shopTeach, "SHOP_CLASS", 14, "jumbo", true)
        end
        if not bIsRepeatable then
            PlayerSetGrade(8, gGrade)
        end
    else
        --print("<<<<<<<<<<<<<<<<<<<<< fail")
        SoundStopCurrentSpeechEvent(shopTeach)
        --[[
        SoundPlayScriptedSpeechEvent(shopTeach, "CLASSSHOP", 15, "jumbo", true)
        ]] -- Changed to:
        SoundPlayScriptedSpeechEvent(shopTeach, "SHOP_CLASS", 15, "jumbo", true)
        PedSetActionNode(gPlayer, animsroot .. "Failure", "Act/Conv/C6.act")
    end
    --print("<<<<<<<<<<<<<<<<<<<<< AFTER MISSION QUERY")
    Wait(3000)
    SoundFadeoutStream()
    if not bIsRepeatable then
        if minigameWasSuccess then
            SoundPlayMissionEndMusic(true, 9)
        else
            SoundPlayMissionEndMusic(false, 9)
        end
        MinigameSetGrades(8, gGrade - 1)
        while MinigameIsShowingGrades() do
            Wait(0)
        end
    end
    if minigameWasSuccess then
        if nCurrentClass == 5 and not bIsRepeatable then
            CameraFade(1500, 0)
            Wait(1550)
            PedStop(shopTeach)
            PedClearObjectives(shopTeach)
            CameraLookAtXYZ(-422.43277, 364.42984, 82.48458, true)
            CameraSetXYZ(-423.3968, 368.01886, 82.16489, -422.43277, 364.42984, 82.48458)
            CameraSetWidescreen(true)
            CameraFade(1000, 1)
            Wait(550)
            PedSetActionNode(shopTeach, "/Global/C4/Animations/TeacherFinishClass", "Act/Conv/C4.act")
            --[[
            F_PlaySpeechAndWait(shopTeach, "CLASSSHOP", 16, "jumbo", true)
            ]] -- Changed to:
            F_PlaySpeechAndWait(shopTeach, "SHOP_CLASS", 16, "jumbo", true)
        end
        CameraFade(-1, 0)
        Wait(FADE_OUT_TIME)
        if not bIsRepeatable then
            CameraSetWidescreen(true)
            CameraLookAtXYZ(-419.34927, 366.21942, 82.54457, true)
            CameraSetPath(PATH._C6_UNLOCKPATH, true)
            CameraSetSpeed(0.5, 0.5, 0.5)
            local unlkTxt = ""
            local unlkTut = ""
            if nCurrentClass == 1 then
                unlkTxt = "C6_UNLK_01"
                unlkTut = "Desc_89"
                VehicleCreatePoint(274, POINTLIST._C6_BIKELOC)
                GarageSetStoredVehicle(0, 274)
            elseif nCurrentClass == 2 then
                unlkTxt = "C6_UNLK_02"
                unlkTut = "Desc_94"
                VehicleCreatePoint(273, POINTLIST._C6_BIKELOC)
                GarageSetStoredVehicle(0, 273)
            elseif nCurrentClass == 3 then
                unlkTxt = "C6_UNLK_03"
                unlkTut = "Desc_88"
                VehicleCreatePoint(272, POINTLIST._C6_BIKELOC)
                GarageSetStoredVehicle(0, 272)
            elseif nCurrentClass == 4 then
                unlkTxt = "C6_UNLK_04"
                unlkTut = "Desc_90"
                VehicleCreatePoint(278, POINTLIST._C6_BIKELOC)
                GarageSetStoredVehicle(0, 278)
            elseif nCurrentClass == 5 then
                unlkTxt = "C6_UNLK_05"
                unlkTut = "Desc_87"
                VehicleCreatePoint(277, POINTLIST._C6_BIKELOC)
                GarageSetStoredVehicle(0, 277)
            end
            CameraFade(-1, 1)
            --print(unlkTxt, unlkTut)
            MinigameSetCompletion("MEN_BLANK", true, 0, unlkTxt)
            Wait(FADE_IN_TIME)
            TutorialShowMessage(unlkTut, -1, true)
            SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
            Wait(5000)
            TutorialRemoveMessage()
            CameraSetWidescreen(false)
        end
        MissionSucceed(true, false, false)
    else
        MissionFail(true, false)
    end
end

--[[
function F_GetTSize(tbl)
    local NumOfElements = 0
    for i, k in AnimSeq do
        NumOfElements = NumOfElements + 1
    end
    return NumOfElements
end
]]                    -- Not present in original script

function F_CalcTime() -- ! Added this
    initTimer = GetTimer()
    while true do
        if IsButtonPressed(0, 0) then
            endTimer = GetTimer()
            break
        end
        Wait(0)
    end
end

function F_IntroCinematic() -- ! Modified
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    PedSetActionNode(classmate01, "/Global/C6/PedUnderHood", "Act/Conv/C6.act")
    Wait(1000)
    PedSetPosPoint(classmate01, POINTLIST._C6_CLASSMATE01)
    if not F_CheckIfPrefect() then
        CameraFade(1000, 1)
    end
    CameraSetPath(PATH._C6_INTROCAM, true)
    CameraSetSpeed(1.2, 1.2, 1.2)
    CameraLookAtPath(PATH._C6_CAMERAFOCUS, true)
    CameraLookAtPathSetSpeed(1.8, 1.8, 1.8)
    PedFollowPath(gPlayer, PATH._C6_PLAYERPATH, 0, 0)
    PedFollowPath(classmate02, PATH._C6_CLASSMATE02, 0, 0)
    PedFollowPath(classmate03, PATH._C6_CLASSMATE03, 0, 0)
    if nCurrentClass == 1 then
        --[[
        F_PlaySpeechAndWait(shopTeach, "CLASSSHOP", 1, "jumbo", true)
        F_PlaySpeechAndWait(gPlayer, "CLASSSHOP", 2, "jumbo", true)
        F_PlaySpeechAndWait(shopTeach, "CLASSSHOP", 3, "jumbo", true)
        F_PlaySpeechAndWait(shopTeach, "CLASSSHOP", 4, "jumbo", true)
        ]] -- Changed to:
        F_PlaySpeechAndWait(shopTeach, "SHOP_CLASS", 1, "jumbo", true)
        F_PlaySpeechAndWait(gPlayer, "SHOP_CLASS", 2, "jumbo", true)
        F_PlaySpeechAndWait(shopTeach, "SHOP_CLASS", 3, "jumbo", true)
        F_PlaySpeechAndWait(shopTeach, "SHOP_CLASS", 4, "jumbo", true)
    else
        if nCurrentClass == 2 then
            --[[
            SoundPlayScriptedSpeechEvent(shopTeach, "CLASSSHOP", 7, "jumbo", true)
            ]] -- Changed to:
            SoundPlayScriptedSpeechEvent(shopTeach, "SHOP_CLASS", 7, "jumbo", true)
        elseif nCurrentClass == 3 then
            --[[
            SoundPlayScriptedSpeechEvent(shopTeach, "CLASSSHOP", 8, "jumbo", true)
            ]] -- Changed to:
            SoundPlayScriptedSpeechEvent(shopTeach, "SHOP_CLASS", 8, "jumbo", true)
        elseif nCurrentClass == 4 then
            --[[
            SoundPlayScriptedSpeechEvent(shopTeach, "CLASSSHOP", 9, "jumbo", true)
            ]] -- Changed to:
            SoundPlayScriptedSpeechEvent(shopTeach, "SHOP_CLASS", 9, "jumbo", true)
        elseif nCurrentClass == 5 then
            --[[
            SoundPlayScriptedSpeechEvent(shopTeach, "CLASSSHOP", 10, "jumbo", true)
            ]] -- Changed to:
            SoundPlayScriptedSpeechEvent(shopTeach, "SHOP_CLASS", 10, "jumbo", true)
        end
        Wait(7238)
    end
    CameraFade(500, 0)
    Wait(600)
    F_CleanPrefect()
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    local x, y, z = GetPointList(POINTLIST._C6_PSTART)
    PlayerSetPosSimple(x, y, z)
    PlayerFaceHeadingNow(180)
end

function F_ExplainGame()
    CameraSetWidescreen(true)
    TextPrint("C6_INST01", 3, 1)
    WaitSkippable(3000)
    CameraSetWidescreen(false)
end

function PickRandom(tbl)
    if type(tbl) ~= "table" then
        --DebugPrint("PickRandom tbl~=table")
        return nil
    end
    if table.getn(tbl) <= 0 then
        --DebugPrint("PickRandom tbl.size=0")
        return nil
    end
    return tbl[math.random(1, table.getn(tbl))]
end

--[[
local ShopTeacherSayCount = 0
]] -- Not present in original script

--[[
function F_ActionsCallback(PlayerIndex, cAction, bPass, CurIndex)
]]                                         -- Modified to:
function F_ActionsCallback(cAction, bPass) -- ! Heavily modified
    if bPass then
        SoundPlay2D("BikeRight")
        if cAction.anim then
            PedSetActionNode(gPlayer, "/Global/C6/Clear", ActionAnimFile)
            Wait(10)
            PedSetActionNode(gPlayer, cAction.anim, ActionAnimFile)
        end
        if cAction.cams then
            camindex = cAction.cams[1]
            camEntry = camerasTable[camindex]
            CameraSetPath(camEntry.cameraPath, true)
            CameraSetSpeed(camEntry.speed, camEntry.speed, camEntry.speed)
            CameraLookAtXYZ(camEntry.x, camEntry.y, camEntry.z, true)
        end
    else
        StartVibration(1, 400, 7)
        SoundPlay2D("BikeWrong")
        camEntry = camerasTable[6]
        CameraSetPath(camEntry.cameraPath, true)
        CameraSetSpeed(camEntry.speed, camEntry.speed, camEntry.speed)
        CameraLookAtXYZ(camEntry.x, camEntry.y, camEntry.z, true)
        if cAction.fail_anim then
            MinigameEnd()
            PedSetActionNode(gPlayer, cAction.fail_anim, ActionAnimFile)
            Wait(2000)
            CameraSetPath(camerasTable[1].cameraPath, true)
            CameraSetSpeed(camerasTable[1].speed, camerasTable[1].speed, camerasTable[1].speed)
            CameraLookAtXYZ(camerasTable[1].x, camerasTable[1].y, camerasTable[1].z, true)
        end
    end
    --[[
    DebugPrint("F_ActionsCallback(): pass:" .. tostring(bPass) .. " " .. tostring(cAction) .. " " .. tostring(CurIndex))
    local camPath = 0
    if bPass then
        if AnimSeq[CurIndex].Cam then
            DebugPrint("*************** NEW Cam ****************** " .. tostring(AnimSeq[CurIndex].cams))
            camEntry = camerasTable[AnimSeq[CurIndex].Cam]
            CameraSetPath(camEntry.cameraPath, true)
            CameraSetSpeed(camEntry.speed, camEntry.speed, camEntry.speed)
            CameraLookAtXYZ(camEntry.x, camEntry.y, camEntry.z, true)
        elseif cAction ~= 22 then
            DebugPrint("*************** No Action NOT ****************** " .. tostring(cAction))
            SoundPlay2D("BikeRight")
            ShopTeacherSayCount = ShopTeacherSayCount + 1
            if 3 <= ShopTeacherSayCount then
                DebugPrint("***************Teacher should speak ****************** " .. tostring(gSpeechPlayed))
                SoundPlayScriptedSpeechEvent(shopTeach, "CLASSSHOP", 13, "jumbo", true)
                ShopTeacherSayCount = 0
            end
        end
        if AnimSeq[CurIndex].Point == true then
            StartVibration(1, 400, 7)
        end
        if AnimSeq[CurIndex].Anim ~= "None" then
            print("Actiontree node: " .. animsroot .. AnimSeq[CurIndex].Anim .. "   " .. ActionAnimFile)
            PedSetActionNode(gPlayer, "/Global/C6/Clear", ActionAnimFile)
            PedSetActionNode(gPlayer, animsroot .. AnimSeq[CurIndex].Anim, ActionAnimFile)
        elseif not gTorchLit and PedIsPlaying(gPlayer, animsroot .. "Tools/Torch/PickupTorch/ApplyTorch", true) then
            gTorchLit = true
            local x, y, z = GetPointList(POINTLIST._C6_BURNINGEFFECT)
            gEffFlame = EffectCreate("TorchImpact", x, y, z)
        elseif gTorchLit and not PedIsPlaying(gPlayer, animsroot .. "Tools/Torch/PickupTorch/ApplyTorch", true) then
            EffectKill(gEffFlame)
            gEffFlame = nil
            gTorchLit = false
        end
    elseif cAction ~= 23 then
        PedStop(shopTeach)
        PedFaceObject(shopTeach, gPlayer, 3, 0)
        print("Actiontree node: " .. animsroot .. "Teacher/TeacherChew" .. "   " .. "Act/Conv/C4.act")
        PedSetActionNode(shopTeach, "/Global/C4/Animations/Teacher/TeacherChew", "Act/Conv/C4.act")
        if totalFailed < 3 then
            StartVibration(1, 400, 7)
            SoundStopCurrentSpeechEvent(shopTeach)
            SoundPlayScriptedSpeechEvent(shopTeach, "CLASSSHOP", 11, "jumbo", true)
            if 3 <= totalFailed then
                StartVibration(0, 1500, 254)
            elseif totalFailed == 1 then
                gGetReadyText = "C6_GETREADY2"
            elseif totalFailed == 2 then
                gGetReadyText = "C6_GETREADY3"
            end
        else
            SoundStopCurrentSpeechEvent(shopTeach)
            SoundPlayScriptedSpeechEvent(shopTeach, "CLASSSHOP", 12, "jumbo", true)
            StartVibration(0, 1500, 254)
            SoundFadeoutStream()
            MinigameEnd()
        end
        totalFailed = totalFailed + 1
        SoundPlay2D("BikeWrong")
        if AnimSeq[CurIndex].fail_anim then
            PedSetActionNode(gPlayer, animsroot .. AnimSeq[CurIndex].fail_anim, ActionAnimFile)
            CameraSetPath(camerasTable[1].cameraPath, true)
            CameraSetSpeed(camerasTable[1].speed, camerasTable[1].speed, camerasTable[1].speed)
            CameraLookAtXYZ(camerasTable[1].x, camerasTable[1].y, camerasTable[1].z, true)
        else
            camEntry = camerasTable[6]
            CameraSetPath(camEntry.cameraPath, true)
            CameraSetSpeed(camEntry.speed, camEntry.speed, camEntry.speed)
            CameraLookAtXYZ(camEntry.x, camEntry.y, camEntry.z, true)
            DebugPrint("no fail anim for " .. CurIndex .. "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
        end
        gbFailed = true
    end
    ]] -- Original
end

function F_SetStage(param)
    nCurrentClass = param
    bStageLoaded = true
    --print("[ARC]======> nCurrentClass = " .. nCurrentClass)
end

function F_SetStageRepeatable(param)
    nCurrentClass = param
    bStageLoaded = true
    bIsRepeatable = true
    --print("[JASON]======> nCurrentClass = " .. nCurrentClass)
end

function F_CheckIfPrefect()
    if shared.bBustedClassLaunched then
        local prefectModels = {
            49,
            50,
            51,
            52
        }
        local prefectModel = prefectModels[math.random(1, 4)]
        LoadModels({ prefectModel })
        prefect = PedCreatePoint(prefectModel, POINTLIST._PREFECTLOC)
        PedStop(prefect)
        PedClearObjectives(prefect)
        PedIgnoreStimuli(prefect, true)
        PedSetInvulnerable(prefect, true)
        PedFaceObject(gPlayer, prefect, 2, 0)
        PedFaceObject(prefect, gPlayer, 3, 1, false)
        PedSetPedToTypeAttitude(prefect, 3, 2)
        CameraLookAtXYZ(-426.56998, 368.598, 82.284615, true)
        CameraSetXYZ(-425.36288, 369.16025, 82.56482, -426.56998, 368.598, 82.284615)
        CameraFade(-1, 1)
        SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
        PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
        PedSetActionNode(gPlayer, "/Global/C6/Animations/Failure", "Act/Conv/C6.act")
        Wait(3000)
        PedSetActionNode(gPlayer, "/Global/C6/Clear", "Act/Conv/C6.act")
        shared.bBustedClassLaunched = false
        return true
    end
    return false
end

function F_CleanPrefect()
    if prefect and PedIsValid(prefect) then
        PedDelete(prefect)
    end
end
