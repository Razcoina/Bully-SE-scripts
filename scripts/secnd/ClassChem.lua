--[[ Changes to this file:
    * Rewrote all local variables, did my best to find names, definitely requires testing
    * Modified function F_SetDifficulty, may require testing
    * Modified function MissionSetup, may require testing
    * Modified function MissionCleanup, may require testing
    * Modified function main, may require testing
    * Removed function F_PlayerAtEndOfPath, not present in original script
    * Modified function F_IntroCinematic, may require testing
    * Heavily modified function F_ActionsCallback, requires testing
    * Removed function F_GetTSize, not present in original script
    * Modified function F_EndPresentation, may require testing
    * Modified function F_CheckIfPrefect, may require testing
    * Removed function F_TurnOffOBJ, not present in original script
    * Removed function F_TurnONOBJ, not present in original script
]]

--[[ Original variables (ALL THE WAY TO LINE 1871)
local missionSuccess = false
local gGetReadyText = "C4_GETREADY"
local gbFailed = false
local IntroWaitTime = 1.5
local introWin = 1.2
local longWin = 3
local shortWin = 2
local tWait = 0.5
local num_missed = 1
local GameCcompleted = false
local camerasTable = {}
local FlaskFX_XYZ = {}
local eff
local bStageLoaded = false
local nCurrentClass = -1
local gAmmoModel = -1
local gAmmoAmount = 3
local gUnlockText = ""
local gClassPassede = false
local gSpeechPlayed = false
local BunsinIndex = 1
local BunsinFlames = {
    "BuntzenFlame",
    "BuntzenFlame2",
    "BuntzenFlame3"
}
local FlameEffect
local animsroot = "/Global/C4B/Animations/"
local AnimSeq
local AnimSeqTier1 = {
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 0,
        Anim = "Left/StrikeMatch/GrabMatch",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 0,
        Anim = "Left/StrikeMatch/StrikeMatch",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/Beaker/GrabBeaker",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/Beaker/PourBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 14,
        Anim = "Left/EyeDrop/GrabEyeDrop",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 14,
        Anim = "Left/EyeDrop/DropEyeDrop",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/Beaker/GrabBeaker",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/Beaker/PourBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 1,
        Anim = "Right/Rod/GrabRod",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 1,
        Anim = "Right/Rod/StirRod",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = 2,
        windowTime = shortWin,
        act = 23,
        Anim = "None",
        Point = false
    }
}
local AnimSeqTier2 = {
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 0,
        Anim = "Left/StrikeMatch/GrabMatch",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 0,
        Anim = "Left/StrikeMatch/StrikeMatch",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 20,
        Anim = "Right/LiftBeaker/GrabBeaker",
        Point = false,
        Cam = 4
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 20,
        Anim = "Right/LiftBeaker/StudyTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 1,
        Anim = "Right/Rod/GrabRod",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 1,
        Anim = "Right/Rod/StirRod",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 14,
        Anim = "Left/EyeDrop/GrabEyeDrop",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 14,
        Anim = "Left/EyeDrop/DropEyeDrop",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/Tube/GrabTube",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 2,
        Anim = "Left/Powder/GrabPowder",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 2,
        Anim = "Left/Powder/ShakePowder",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 13,
        Anim = "Right/TapBeaker/GrabBeaker",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 13,
        Anim = "Right/TapBeaker/TapBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 1,
        Anim = "Right/Rod/GrabRod",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 1,
        Anim = "Right/Rod/StirRod",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = 2,
        windowTime = shortWin,
        act = 23,
        Anim = "None",
        Point = false
    }
}
local AnimSeqTier3 = {
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 0,
        Anim = "Left/StrikeMatch/GrabMatch",
        Point = false,
        effect = "BuntzenOff",
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 0,
        Anim = "Left/StrikeMatch/StrikeMatch",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/Tube/GrabTube",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 14,
        Anim = "Left/EyeDrop/GrabEyeDrop",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 14,
        Anim = "Left/EyeDrop/DropEyeDrop",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/Tube/GrabTube",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 20,
        Anim = "Right/LiftBeaker/GrabBeaker",
        Point = false,
        Cam = 4
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 20,
        Anim = "Right/LiftBeaker/StudyTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 2,
        Anim = "Left/Powder/GrabPowder",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 2,
        Anim = "Left/Powder/ShakePowder",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 12,
        Anim = "Left/TapBeaker/GrabBeaker",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 12,
        Anim = "Left/TapBeaker/TapBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 14,
        Anim = "Left/EyeDrop/GrabEyeDrop",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 14,
        Anim = "Left/EyeDrop/DropEyeDrop",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 1,
        Anim = "Right/Rod/GrabRod",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 1,
        Anim = "Right/Rod/StirRod",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = 2,
        windowTime = shortWin,
        act = 23,
        Anim = "None",
        Point = false
    }
}
local AnimSeqTier4 = {
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 0,
        Anim = "Left/StrikeMatch/GrabMatch",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 0,
        Anim = "Left/StrikeMatch/StrikeMatch",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/Tube/GrabTube",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 14,
        Anim = "Left/EyeDrop/GrabEyeDrop",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 14,
        Anim = "Left/EyeDrop/DropEyeDrop",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 2,
        Anim = "Left/Powder/GrabPowder",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 2,
        Anim = "Left/Powder/ShakePowder",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 1,
        Anim = "Right/Rod/GrabRod",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 1,
        Anim = "Right/Rod/StirRod",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 20,
        Anim = "Right/LiftBeaker/GrabBeaker",
        Point = false,
        Cam = 4
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 20,
        Anim = "Right/LiftBeaker/StudyTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 2,
        Anim = "Left/Powder/GrabPowder",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 2,
        Anim = "Left/Powder/ShakePowder",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 12,
        Anim = "Left/TapBeaker/GrabBeaker",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 12,
        Anim = "Left/TapBeaker/TapBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/TurnDownGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/TurnDownGas/OffBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerDown",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 14,
        Anim = "Left/EyeDrop/GrabEyeDrop",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 14,
        Anim = "Left/EyeDrop/DropEyeDrop",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/Beaker/GrabBeaker",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/Beaker/PourBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 13,
        Anim = "Right/TapBeaker/GrabBeaker",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 13,
        Anim = "Right/TapBeaker/TapBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = 2,
        windowTime = shortWin,
        act = 23,
        Anim = "None",
        Point = false
    }
}
local AnimSeqTier5 = {
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 0,
        Anim = "Left/StrikeMatch/GrabMatch",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 0,
        Anim = "Left/StrikeMatch/StrikeMatch",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 14,
        Anim = "Left/EyeDrop/GrabEyeDrop",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 14,
        Anim = "Left/EyeDrop/DropEyeDrop",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 2,
        Anim = "Left/Powder/GrabPowder",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 2,
        Anim = "Left/Powder/ShakePowder",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 1,
        Anim = "Right/Rod/GrabRod",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 1,
        Anim = "Right/Rod/StirRod",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 20,
        Anim = "Right/LiftBeaker/GrabBeaker",
        Point = false,
        Cam = 4
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 20,
        Anim = "Right/LiftBeaker/StudyTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 2,
        Anim = "Left/Powder/GrabPowder",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 2,
        Anim = "Left/Powder/ShakePowder",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 12,
        Anim = "Left/TapBeaker/GrabBeaker",
        Point = false,
        Cam = 3
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 12,
        Anim = "Left/TapBeaker/TapBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/TurnDownGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/TurnDownGas/OffBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerDown",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 14,
        Anim = "Left/EyeDrop/GrabEyeDrop",
        Point = false,
        Cam = 1
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 14,
        Anim = "Left/EyeDrop/DropEyeDrop",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/TurnOnGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/TurnOnGas/OnBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerUp",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 17,
        Anim = "Right/Beaker/GrabBeaker",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 17,
        Anim = "Right/Beaker/PourBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 13,
        Anim = "Right/TapBeaker/GrabBeaker",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 13,
        Anim = "Right/TapBeaker/TapBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/Tube/GrabTube",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/Tube/PourTube",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 1,
        Anim = "Right/Rod/GrabRod",
        Point = false,
        Cam = 6
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 1,
        Anim = "Right/Rod/StirRod",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false,
        effect = "Chem_Reaction"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 16,
        Anim = "Left/TurnDownGas/GrabBurner",
        Point = false,
        Cam = 5
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 16,
        Anim = "Left/TurnDownGas/OffBurner",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "BurnerDown",
        Point = false,
        effect = "BuntzenFlame"
    },
    {
        waitTime = tWait,
        windowTime = introWin,
        act = 13,
        Anim = "Right/TapBeaker/GrabBeaker",
        Point = false,
        Cam = 2
    },
    {
        waitTime = 0,
        windowTime = longWin,
        act = 13,
        Anim = "Right/TapBeaker/TapBeaker",
        Point = true
    },
    {
        waitTime = 0,
        windowTime = shortWin,
        act = 22,
        Anim = "None",
        Point = false
    },
    {
        waitTime = 2,
        windowTime = shortWin,
        act = 23,
        Anim = "None",
        Point = false
    }
}
local FailAnimTable = {
    "React/Smoke",
    "React/Explode"
}
local chemTeach
local diff_easy = 1
local diff_hard = 2
]] -- Original variables

local missionSuccess = false
local L1_1 = 0
local L2_1 = 1
local L3_1 = 2
local IntroWaitTime = 0.45
local gGetReadyText = "C4_GETREADY"
local shortWait = 0.2
local longWait = 0.8
local Win1 = 0.6
local Win2 = 0.55
local Win3 = 0.55
local Win4 = 0.5
local Win5 = 0.5
local num_missed = 1
local camerasTable = {}
local FlaskFX_XYZ = {}
local eff
local bStageLoaded = false
local nCurrentClass = -1
local gAmmoModel = -1
local gAmmoAmount = 3
local gUnlockText = ""
local gClassPassede = false
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
local tab3 = { 28, 29 }
local tab4 = { 22, 23 }
local tab5 = { 3, 0 }
local tab6 = { 6, 9 }
animsroot = "/Global/C4/Animations/"
local AnimSeq
local gActions = {
    0,
    1,
    2,
    3,
    4,
    7,
    5,
    8
}
local AnimSeqTier1 = {
    {
        waitTime = longWait,
        cams = { 2 },
        act = 0,
        anim = animsroot .. "Right/Tube/GrabTube",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Right/Tube/PourTube",
        window = Win1,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 3,
        anim = animsroot .. "Right/Tube/PutDownTube",
        window = Win1
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 4,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win1,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win1,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win1
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 2,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win1,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win1
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 4,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win1,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win1,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win1
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win1,
        tab = nil
    }
}
local AnimSeqTier2 = {
    {
        waitTime = longWait,
        cams = { 2 },
        act = 0,
        anim = animsroot .. "Right/Tube/GrabTube",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Right/Tube/PourTube",
        window = Win2,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 3,
        anim = animsroot .. "Right/Tube/PutDownTube",
        window = Win2
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 4,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win2,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win2,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win2
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 2,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win2,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win2
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 4,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win2,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win2,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win2
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 2,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win2,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win2
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win2,
        tab = nil
    }
}
local AnimSeqTier3 = {
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win3,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 2 },
        act = 1,
        anim = animsroot .. "Left/Tube/GrabTube",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/Tube/PourTube",
        window = Win3,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/Tube/PutDownTube",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = nil,
        window = Win3,
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win3,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win3
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 7,
        anim = animsroot .. "Left/Powder/GrabPowder",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Left/Powder/ShakePowder",
        window = Win3,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Left/Powder/PutDownPowder",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win3
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 0,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 2,
        nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 1,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win3,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win3
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win3,
        tab = nil
    }
}
local AnimSeqTier4 = {
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win4,
        effect = "Chem_Reaction"
    },
    {
        waitTime = longWait,
        cams = { 2 },
        act = 1,
        anim = animsroot .. "Right/Tube/GrabTube",
        window = Win4,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Right/Tube/PourTube",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Right/Tube/PutDownTube",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = nil,
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win4,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 7,
        anim = animsroot .. "Left/Powder/GrabPowder",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Left/Powder/ShakePowder",
        window = Win4,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Left/Powder/PutDownPowder",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 0,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 2,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 1,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win4,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 5,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win4,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win4
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 1,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 7,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win4,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win4,
        tab = nil
    }
}
local AnimSeqTier5 = {
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win5,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = nil,
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 2 },
        act = 5,
        anim = animsroot .. "Left/Tube/GrabTube",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 3,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Left/Tube/PourTube",
        window = Win5,
        effect = "Chem_Reaction",
        ambEffect = "Chem_ContainerCalm"
    },
    {
        waitTime = shortWait,
        act = 1,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Left/Tube/PutDownTube",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 3,
        anim = nil,
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 3 },
        act = 7,
        anim = animsroot .. "BothMisc/Burner/AdjustBurner",
        window = Win5,
        effect = "Chem_Reaction"
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 5,
        nil,
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 4,
        anim = animsroot .. "Right/Beaker/GrabBeaker",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 2,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 4,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Right/Beaker/PourBeaker",
        window = Win5,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 5,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 0,
        anim = animsroot .. "Right/Beaker/PutDownBeaker",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 4 },
        act = 0,
        anim = animsroot .. "Left/EyeDrop/GrabEyeDrop",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 5,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 2,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 8,
        anim = animsroot .. "Left/EyeDrop/DropEyeDrop",
        window = Win5,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 3,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 4,
        nil,
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 1,
        anim = animsroot .. "Left/EyeDrop/PutDownEyeDrop",
        window = Win5
    },
    {
        waitTime = longWait,
        cams = { 5 },
        act = 7,
        anim = animsroot .. "Left/Powder/GrabPowder",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 1,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 2,
        anim = animsroot .. "Left/Powder/ShakePowder",
        window = Win5,
        effect = "Chem_GoodReaction"
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 4,
        anim = animsroot .. "Left/Powder/PutDownPowder",
        window = Win5
    },
    {
        waitTime = shortWait,
        act = 7,
        nil,
        window = Win4
    },
    {
        waitTime = shortWait,
        act = 34,
        anim = nil,
        window = Win5,
        tab = nil
    }
}
local FailAnimTable = {
    animsroot .. "React/Smoke",
    animsroot .. "React/Explode"
}
local chemTeach
local diff_easy = 1
local diff_hard = 2

function F_SetDifficulty() -- ! Modified
    if nCurrentClass == 1 then
        AnimSeq = AnimSeqTier1
        allowedActions = 4 -- Added this
        gGrade = 1
        gAmmoModel = 301
        gAmmoAmount = 3
        gUnlockText = "C4_Unlock01"
    elseif nCurrentClass == 2 then
        AnimSeq = AnimSeqTier2
        allowedActions = 4 -- Added this
        gGrade = 2
        gAmmoModel = 309
        gAmmoAmount = 5
        gUnlockText = "C4_Unlock02"
    elseif nCurrentClass == 3 then
        AnimSeq = AnimSeqTier3
        allowedActions = 6 -- Added this
        gGrade = 3
        gAmmoModel = 394
        gAmmoAmount = 3
        gUnlockText = "C4_Unlock03"
    elseif nCurrentClass == 4 then
        AnimSeq = AnimSeqTier4
        allowedActions = 8 -- Added this
        gGrade = 4
        gAmmoModel = 308
        gAmmoAmount = 5
        gUnlockText = "C4_Unlock04"
    elseif nCurrentClass == 5 then
        AnimSeq = AnimSeqTier5
        allowedActions = 8 -- Added this
        gAmmoModel = 308
        gAmmoAmount = 10
        gUnlockText = "C4_Unlock05"
        gGrade = 5
    elseif 6 <= nCurrentClass then
        gGrade = 5
        AnimSeq = AnimSeqTier5
        allowedActions = 8 -- Added this
        gUnlockText = false
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
    DATLoad("C4.DAT", 2)
    DATLoad("CLASSLOC.DAT", 2)
    DATLoad("1_02C.DAT", 2) -- Added this
    --[[
    HUDSaveVisibility()
    HUDClearAllElements()
    ToggleHUDComponentVisibility(42, true)
    ]] -- Removed this
    DATInit()
    F_ToggleHUDItems(false)
    --[[
    PlayerSetControl(0)
    LoadAnimationGroup("NPC_Spectator")
    LoadAnimationGroup("NPC_Adult")
    LoadAnimationGroup("UBO")
    ]] -- Removed this
    LoadAnimationGroup("MINICHEM")
    LoadAnimationGroup("WeaponUnlock")
    LoadAnimationGroup("MINI_React")
    LoadAnimationGroup("NPC_Spectator") -- Added this
    LoadAnimationGroup("NPC_Adult")     -- Added this
    LoadAnimationGroup("MG_Craps")      -- Added this
    --[[
    LoadAnimationGroup("MINIBIKE")
    LoadAnimationGroup("SHOPBIKE")
    ]] -- Removed this
    --[[
    ActionAnimFile = "Act/Conv/C4B.act"
    LoadActionTree(ActionAnimFile)
    ]] -- Modified to:
    LoadActionTree("Act/Conv/C4.act")
    WeaponRequestModel(366)
    WeaponRequestModel(369)
    WeaponRequestModel(367)
    WeaponRequestModel(368)
    WeaponRequestModel(365)
    WeaponRequestModel(351)
    WeaponRequestModel(408)
    LoadAnimationGroup("MINIBIKE") -- Added this
    LoadAnimationGroup("SHOPBIKE") -- Added this
    WeaponRequestModel(375)
    --[[
    WeaponRequestModel(441)
    WeaponRequestModel(442)
    ]] -- Removed this
    SoundEnableInteractiveMusic(false)
    AreaTransitionPoint(4, POINTLIST._C4_P_DOOR, nil, true)
    PlayerSetPunishmentPoints(0)
    MinigameCreate("CHEM", false)
    while not MinigameIsReady() do
        Wait(0)
    end
    Wait(2)
    ActionAnimFile = "Act/Conv/C4.act"
    FailAnimTableSize = table.getn(FailAnimTable)
    local hide = false
    GeometryInstance("Grab_BeakerX", hide, -596.55, 323.487, 35.407)
    GeometryInstance("Grab_TesttubeRightX", hide, -595.786, 323.605, 35.311)
    GeometryInstance("Grab_CanisterX", hide, -595.951, 323.461, 35.238)
    GeometryInstance("chem_stirX", hide, -596.426, 323.612, 35.175)
    GeometryInstance("Grab_EyedropX", hide, -595.839, 323.426, 35.3079)
    --[[
    GeometryInstance("Grab_Testtube_LeftX", hide, -595.786, 323.605, 35.311)
    GeometryInstance("matchbox_1p", hide, -595.96, 323.608, 35.156)
    GeometryInstance("matchstick_1p", hide, -595.346, 323.967, 34.96)
    GeometryInstance("Grab_Beaker2X", true, -593.993, 323.487, 35.407)
    GeometryInstance("grab_ttube2rightx", true, -598.084, 323.499, 35.272)
    GeometryInstance("Grab_Canister2X", true, -593.394, 323.461, 35.238)
    GeometryInstance("chem_stir2X", true, -593.869, 323.612, 35.175)
    GeometryInstance("Grab_Eyedrop2X", true, -593.282, 323.426, 35.308)
    GeometryInstance("grab_ttube2_leftx", true, -597.497, 323.605, 35.311)
    GeometryInstance("matchbox_2p", true, -597.671, 323.608, 35.156)
    GeometryInstance("matchstick_2p", true, -598.057, 323.967, 34.96)
    ]] -- Removed this
    FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z = GetPointList(POINTLIST._C4_FLASK_FX)
    camerasTable = {
        {
            cameraPath = PATH._C4_CAMPATH01,
            x = -595.9582,
            y = 323.8534,
            z = 35.3826,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH02,
            x = -596.3934,
            y = 324.1351,
            z = 35.4825,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH03,
            x = -595.785,
            y = 324.1081,
            z = 35.6425,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH04,
            x = -596.1057,
            y = 323.7872,
            z = 35.5224,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH05,
            x = -596.1946,
            y = 323.8774,
            z = 35.5921,
            speed = 0.2
        },
        {
            cameraPath = PATH._C4_CAMPATH06,
            x = -596.1849,
            y = 323.8566,
            z = 35.542,
            speed = 0.2
        }
    }
    GeometryInstance("chem_desk06", false, -597.038, 323.127, 34.9106, false)
    SoundStopPA()
    SoundStopCurrentSpeechEvent()
    SoundDisableSpeech_ActionTree()
end

function MissionCleanup() -- ! Modified
    --[[
    HUDRestoreVisibility()
    ]] -- Removed this
    SoundRestartPA()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundEnableInteractiveMusic(true)
    SoundEnableSpeech_ActionTree()
    SoundStopStream()
    CameraReturnToPlayer()
    SoundFadeoutStream()
    F_ToggleHUDItems(true)
    --[[
    PedSetWeaponNow(gPlayer, MODELENUM._NOWEAPON, 0)
    ]] -- Removed this
    PedDelete(chemTeach)
    MinigameDestroy()
    PlayerWeaponHudLock(false)
    if eff ~= nil then
        EffectKill(eff)
        eff = nil
    end
    --[[
    if FlameEffect then
        EffectKill(FlameEffect)
        FlameEffect = nil
    end
    ]] -- Modified to:
    if gBuntzenFlame2 then
        EffectKill(gBuntzenFlame2)
        gBuntzenFlame2 = nil
    end
    if gBuntzenFlame3 then -- Added this
        EffectKill(gBuntzenFlame3)
        gBuntzenFlame3 = nil
    end
    if g_eff ~= nil then
        EffectKill(g_eff)
        g_eff = nil
    end
    if gBubbleEffect then
        EffectKill(gBubbleEffect)
        gBubbleEffect = false
    end
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    if AreaGetVisible() ~= 2 then
        AreaTransitionPoint(2, POINTLIST._C4_EXIT)
        --[[
    else
        CameraFade(500, 1)
        Wait(500)
    ]] -- Removed this
    end
    PlayerSetPunishmentPoints(0)
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PlayerSetHealth(PedGetMaxHealth(gPlayer))
    end
    if nCurrentClass == 5 then -- Added this
        UnLoadAnimationGroup("NPC_Spectator")
    end
    PlayerSetControl(1)
    UnLoadAnimationGroup("MINICHEM")
    UnLoadAnimationGroup("MG_Craps") -- Added this
    --[[
    UnLoadAnimationGroup("WeaponUnlock")
    UnLoadAnimationGroup("MINI_React")
    UnLoadAnimationGroup("NPC_Spectator")
    ]]                                   -- Removed this
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("WeaponUnlock") -- Added this
    UnLoadAnimationGroup("MINI_React")   -- Added this
    --[[
    UnLoadAnimationGroup("UBO")
    UnLoadAnimationGroup("MINIBIKE")
    UnLoadAnimationGroup("SHOPBIKE")
    ]] -- Removed this
    DATUnload(2)
end

function main() -- ! Modified
    while not bStageLoaded do
        Wait(0)
    end
    F_SetDifficulty()          -- Added this
    for _, value in AnimSeq do -- Added this
        if value.tab then
            value.act = PickRandom(value.tab)
        end
    end
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PlayerWeaponHudLock(true)
    PlayerSetControl(0) -- Added this
    F_MakePlayerSafeForNIS(true)
    --[[
    F_SetDifficulty()
    ]] -- Removed this
    F_IntroCinematic()
    --[[
    CameraSetWidescreen(false)
    CameraSetPath(camerasTable[6].cameraPath, true)
    CameraSetSpeed(camerasTable[6].speed, camerasTable[6].speed, camerasTable[6].speed)
    CameraLookAtXYZ(camerasTable[6].x, camerasTable[6].y, camerasTable[6].z, true)
    for i = 1, F_GetTSize(AnimSeq) do
        ClassChemAddAction(0, AnimSeq[i].act, AnimSeq[i].waitTime, AnimSeq[i].windowTime, AnimSeq[i].Point)
    end
    MinigameSetType(0)
    MinigameStart()
    ClassChemSetGameType("CHEM")
    MinigameEnableHUD(true)
    PedSetPosPoint(gPlayer, POINTLIST._C4_P_TABLE)
    Wait(100)
    ]]                                                    -- Removed this
    bUsingTimer = false                                   -- Added this
    MissionObjectiveAdd("C4_INST01", 0, -1)               -- Added this
    TextPrintString("", 0.1, 1)                           -- Added this
    PedFollowPath(chemTeach, PATH._C4_TEACHER_PATH, 1, 0) -- Moved this here
    if nCurrentClass == 1 then                            -- Moved this here
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 3, "jumbo", true)
    elseif nCurrentClass == 2 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 11, "jumbo", true)
    elseif nCurrentClass == 3 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 3, "jumbo", true)
    elseif nCurrentClass == 4 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 9, "jumbo", true)
    else
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 2, "jumbo", true)
    end
    --[[
    PlayerFaceHeading(162, 1)
    ]]                  -- Changed to:
    PlayerFaceHeadingNow(180)
    CameraFade(1000, 1) -- Added this
    --[[
    Wait(100)
    ]] -- Changed to:
    Wait(1100)
    local tx, ty, tz = GetPointList(POINTLIST._C4_BUBBLEPOINT)
    gBubbleEffect = EffectCreate("Chem_Bubbles", tx, ty, tz)
    --[[
    PedSetActionNode(gPlayer, animsroot .. "StartAnimations", ActionAnimFile)
    ]] -- Removed this
    --[[
    PedFollowPath(chemTeach, PATH._C4_TEACHER_PATH, 1, 0)
    if nCurrentClass == 1 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 3, "jumbo", true)
    elseif nCurrentClass == 2 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 11, "jumbo", true)
    elseif nCurrentClass == 3 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 3, "jumbo", true)
    elseif nCurrentClass == 4 then
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 9, "jumbo", true)
    else
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 2, "jumbo", true)
    end
    ]]                               -- Moved this a few lines back
    local L3_2 = -1                  -- Added this
    local L4_2 = 0                   -- Added this
    local L5_2 = 1                   -- Added this
    local L6_2 = table.getn(AnimSeq) -- Added this
    local L7_2 = 0                   -- Added this
    local L8_2 = 0                   -- Added this
    while L4_2 < 1 and L7_2 < 3 do   -- Added this
        L5_2 = 1
        Wait(2000)
        MinigameStart()
        ClassChemSetGameType("CHEM")
        ClassChemSetScrollyOnly(true)
        MinigameEnableHUD(true)
        if gCamera then
            CameraSetPath(camerasTable[6].cameraPath, true)
            CameraSetSpeed(camerasTable[6].speed, camerasTable[6].speed, camerasTable[6].speed)
            CameraLookAtXYZ(camerasTable[6].x, camerasTable[6].y, camerasTable[6].z, true)
        else
            gCamera = true
        end
        for key, value in AnimSeq do
            if AnimSeq[key].act ~= 34 and L7_2 == 0 then
                AnimSeq[key].act = gActions[math.random(1, allowedActions)]
            end
            if key == 1 then
                ClassChemAddAction(0, value.act, value.waitTime + 2, value.window)
            else
                ClassChemAddAction(0, value.act, value.waitTime, value.window)
            end
        end
        local L9_2 = 0
        local L10_2 = 0
        TutorialShowMessage("C4_INST01")
        TextPrint(gGetReadyText, 2, 1)
        Wait(2500)
        if L7_2 == 0 then
            SoundPlayStream("MS_ChemistryClass.rsm", 0.25, 2, 1)
        end
        TextPrint("C4_BEGIN", 1, 1)
        Wait(1000)
        if gBadExperiment then
            EffectKill(gBadExperiment)
            gBadExperiment = nil
        end
        TutorialRemoveMessage()
        ClassChemStartSeq(0)
        while MinigameIsActive() do
            if L6_2 > L5_2 then
                if ClassChemGetActionJustFinished(AnimSeq[L5_2].act) then
                    F_ActionsCallback(AnimSeq[L5_2], true)
                    L5_2 = L5_2 + 1
                    Wait(300)
                end
                if ClassChemGetActionJustFailed(AnimSeq[L5_2].act) then
                    gSlowdown = GetTimer()
                    L7_2 = L7_2 + 1
                    F_ActionsCallback(AnimSeq[L5_2], false, L7_2)
                    L5_2 = L5_2 + 1
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
    --[[
    SoundStopInteractiveStream(0)
    SoundPlayStream("MS_ChemistryClass.rsm", 1, 2, 1)
    TextPrint(gGetReadyText, 2, 1)
    Wait(2500)
    TextPrint("C4_BEGIN", 1, 1)
    Wait(1000)
    ClassChemFeedbackCallback(F_ActionsCallback)
    ClassChemStartSeq(1)
    while MinigameIsActive() do
        if gbFailed == true then
            for index = 1, F_GetTSize(AnimSeq) do
                ClassChemResetAction(0, index - 1, AnimSeq[index].waitTime, AnimSeq[index].windowTime)
            end
            if gBadExperiment then
                EffectKill(gBadExperiment)
                gBadExperiment = nil
            end
            TextPrint(gGetReadyText, 2, 1)
            Wait(2500)
            TextPrint("C4_BEGIN", 1, 1)
            Wait(2000)
            if MinigameIsActive() then
                ClassChemStartSeq(1)
            end
            gbFailed = false
        end
        Wait(0)
    end
    if MinigameIsSuccess() then
        GameCcompleted = true
    end
    ]] -- Removed this
    if MinigameIsSuccess() then
        --[[
        PedSetActionNode(gPlayer, animsroot .. "Success", ActionAnimFile)
        ]] -- Changed to:
        PedSetActionNode(gPlayer, animsroot .. "Success", "Act/Conv/C4.act")
        EffectCreate("Chem_GoodReaction", FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
        if not bIsRepeatable then
            PlayerSetGrade(1, gGrade)
            if nCurrentClass == 5 then
                MinigameSetGrades(1, gGrade - 1)
                SoundFadeoutStream()
                SoundPlayMissionEndMusic(true, 9)
                while MinigameIsShowingGrades() do
                    Wait(0)
                end
                Wait(1000)
                CameraFade(-1, 0)
                Wait(FADE_OUT_TIME)
                PedStop(chemTeach)
                PedClearObjectives(chemTeach)
                PedSetPosPoint(chemTeach, POINTLIST._C4_TEACH)
                PedFaceHeading(chemTeach, 180, 0)
                CameraLookAtXYZ(-595.66345, 325.33215, 35.663586, true)
                CameraSetXYZ(-595.4686, 324.35153, 35.64855, -595.66345, 325.33215, 35.663586)
                CameraSetWidescreen(true)
                CameraFade(-1, 1)
                Wait(FADE_IN_TIME)
                --[[
                PedSetActionNode(chemTeach, animsroot .. "TeacherFinishClass", ActionAnimFile)
                ]] -- Changed to:
                PedSetActionNode(chemTeach, "/Global/C4/Animations/TeacherFinishClass", "Act/Conv/C4.act")
                F_PlaySpeechAndWait(chemTeach, "CHEM", 16, "jumbo", true)
            else
                --[[
                SoundStopCurrentSpeechEvent(chemTeach)
                ]] -- Removed this
                SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 14, "supersize", true)
                MinigameSetGrades(1, gGrade - 1)
                SoundFadeoutStream()
                SoundPlayMissionEndMusic(true, 9)
                while MinigameIsShowingGrades() do
                    Wait(0)
                end
            end
        else
            Wait(2000)
        end
        missionSuccess = true
    elseif not bIsRepeatable then
        MinigameSetGrades(1, gGrade - 1)
        SoundFadeoutStream()
        SoundPlayMissionEndMusic(false, 9)
        while MinigameIsShowingGrades() do
            Wait(0)
        end
    else
        Wait(2000)
    end
    --[[
    PedSetActionNode(gPlayer, animsroot .. "CycleClear", ActionAnimFile)
    ]] -- Changed to:
    PedSetActionNode(gPlayer, "/Global/C4/Animations/CycleClear", "Act/Conv/C4.act")
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    if missionSuccess then
        if not bIsRepeatable then
            F_EndPresentation()
        else
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME)
        end
        if gUnlockText ~= false then
            TextPrintString("", 1, 1)
        end
        MissionSucceed(false, false, false)
    else
        MissionFail(true, false)
    end
end

--[[
function F_PlayerAtEndOfPath()
    PlayerFaceHeading(180, 1)
end
]]                          -- Not present in original script

function F_IntroCinematic() -- ! Modified
    while not PedRequestModel(106) do
        Wait(1)
    end
    chemTeach = PedCreatePoint(106, POINTLIST._C4_TEACH)
    student1 = PedCreatePoint(3, POINTLIST._C4_STUDENTS, 1)
    student2 = PedCreatePoint(66, POINTLIST._C4_STUDENTS, 2)
    PedIgnoreStimuli(student1, true)
    PedIgnoreStimuli(student2, true)
    PedIgnoreStimuli(chemTeach, true)
    PedSetInvulnerable(chemTeach, true)
    PedMakeTargetable(chemTeach, false)
    Wait(1)
    CameraSetWidescreen(true)
    if not F_CheckIfPrefect() then
        CameraFade(1000, 1)
    end
    --[[
    PedFollowPath(gPlayer, PATH._C4_PLAYERPATH, 0, 0, F_PlayerAtEndOfPath)
    ]] -- Changed to:
    PedFollowPath(gPlayer, PATH._C4_PLAYERPATH, 0, 0)
    PedFollowPath(student1, PATH._C4_STUDENT01, 0, 0)
    PedFollowPath(student2, PATH._C4_STUDENT02, 0, 0)
    CameraSetPath(PATH._C4_CAMPATH, true)
    CameraSetSpeed(1.4, 3.4, 1.4)
    CameraLookAtPath(PATH._C4_CAMLOOKAT, true)
    CameraLookAtPathSetSpeed(1.8, 1.8, 1.8)
    --[[
    PedSetActionNode(chemTeach, animsroot .. "TeacherFinishClass", ActionAnimFile)
    ]] -- Removed this
    if nCurrentClass == 1 then
        --[[
        F_PlaySpeechAndWait(chemTeach, "CHEM", 6, "jumbo")
        ]] -- Changed to:
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 6, "jumbo", true)
    elseif nCurrentClass == 2 then
        --[[
        F_PlaySpeechAndWait(chemTeach, "CHEM", 10, "jumbo")
        ]] -- Changed to:
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 10, "jumbo", true)
    elseif nCurrentClass == 3 then
        --[[
        F_PlaySpeechAndWait(chemTeach, "CHEM", 2, "jumbo")
        ]] -- Changed to:
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 2, "jumbo", true)
    elseif nCurrentClass == 4 then
        --[[
        F_PlaySpeechAndWait(chemTeach, "CHEM", 7, "jumbo")
        ]] -- Changed to:
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 7, "jumbo", true)
    else
        --[[
        F_PlaySpeechAndWait(chemTeach, "CHEM", 1, "jumbo")
        ]] -- Changed to:
        SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 1, "jumbo", true)
    end
    PedSetActionNode(chemTeach, "/Global/C4/Animations/TeacherFinishClass", "Act/Conv/C4.act") -- Added this
    Wait(2738)                                                                                 -- Added this
    PlayerFaceHeading(180, 1)                                                                  -- Added this
    Wait(1095)
    if nCurrentClass == 1 then
        IntroConv = "C4_INTRO1"
    elseif nCurrentClass == 2 then
        IntroConv = "C4_INTRO2"
    elseif nCurrentClass == 3 then
        IntroConv = "C4_INTRO3"
    elseif nCurrentClass == 4 then
        IntroConv = "C4_INTRO4"
    elseif 5 <= nCurrentClass then
        IntroConv = "C4_INTRO5"
    end
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(800, 0)
    --[[
    Wait(1200)
    ]] -- Changed to:
    Wait(900)
    F_CleanPrefect()
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PlayerSetPosPoint(POINTLIST._C4_P_TABLE)                                              -- Added this
    Wait(100)                                                                             -- Added this
    CameraSetWidescreen(false)                                                            -- Added this
    CameraSetPath(camerasTable[6].cameraPath, true)                                       -- Added this
    CameraSetSpeed(camerasTable[6].speed, camerasTable[6].speed, camerasTable[6].speed)   -- Added this
    CameraLookAtXYZ(camerasTable[6].x, camerasTable[6].y, camerasTable[6].z, true)        -- Added this
    CameraFade(1000, 1)                                                                   -- Added this
    PedSetActionNode(gPlayer, "/Global/C4/Animations/StartAnimations", "Act/Conv/C4.act") -- Added this
end

function F_ExplainGame()
    TutorialMessage("C4_INST01")
    TextPrintString("", 0.1, 1)
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
local ChemTeacherSayCount = 0
]] -- Not present in original script

local L40_1 = true

--[[
function F_ActionsCallback(PlayerIndex, cAction, bPass, CurIndex)
]]                                                   -- Modified to:
function F_ActionsCallback(cAction, bPass, CurIndex) -- ! Heavily modified
    --DebugPrint("F_ActionsCallback(): pass:" .. tostring(bPass) .. " " .. tostring(cAction) .. " " .. tostring(CurIndex))
    local camPath = 0
    if bPass then -- Added this entire if and else
        SoundPlay2D("ChemRight")
        Wait(100)
        if cAction.anim then
            camEntry = PickRandom(camerasTable)
            camPath = camEntry.cameraPath
            if cAction.cams then
                if not gSpeechPlayed then
                    SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 13, "jumbo", true)
                    gSpeechPlayed = true
                    gSpeechTimer = GetTimer()
                elseif 3000 < GetTimer() - gSpeechTimer then
                    gSpeechPlayed = false
                end
                local tempTable = cAction.cams[1]
                camEntry = camerasTable[tempTable]
                CameraSetPath(camEntry.cameraPath, true)
                CameraSetSpeed(camEntry.speed, camEntry.speed, camEntry.speed)
                CameraLookAtXYZ(camEntry.x, camEntry.y, camEntry.z, true)
                L40_1 = not L40_1
            else
                L40_1 = not L40_1
            end
            PedSetActionNode(gPlayer, cAction.anim, ActionAnimFile)
            if cAction.effect then
                eff = EffectCreate(cAction.effect, FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
            end
            if cAction.ambEffect then
                g_eff = EffectCreate(cAction.ambEffect, FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
            end
        end
    else
        SoundPlay2D("ChemWrong")
        Wait(100)
        if g_eff then
            EffectKill(g_eff)
            g_eff = nil
        end
        gBadExperiment = EffectCreate("Chem_Reaction", FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
        PedStop(chemTeach)
        PedFaceObject(chemTeach, gPlayer, 3, 0)
        PedSetActionNode(chemTeach, "/Global/C4/Animations/Teacher/TeacherChew", "Act/Conv/C4.act")
        if CurIndex < 3 then
            StartVibration(1, 400, 7)
            PedSetActionNode(gPlayer, FailAnimTable[1], ActionAnimFile)
            SoundStopCurrentSpeechEvent(chemTeach)
            SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 12, "jumbo", true)
            if CurIndex == 1 then
                gGetReadyText = "C4_GETREADY2"
                local x, y, z = GetPointList(POINTLIST._C4_FLAMEPOINT)
                gBuntzenFlame2 = EffectCreate("BuntzenFlame2", x, y, z)
            elseif CurIndex == 2 then
                gGetReadyText = "C4_GETREADY3"
                local x, y, z = GetPointList(POINTLIST._C4_FLAMEPOINT)
                gBuntzenFlame3 = EffectCreate("BuntzenFlame3", x, y, z)
            end
        else
            SoundStopCurrentSpeechEvent(chemTeach)
            SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 15, "jumbo", true)
            StartVibration(2, 1500, 254)
            eff = EffectCreate("Chem_Accident", FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
            PedSetActionNode(gPlayer, FailAnimTable[2], ActionAnimFile)
            SoundFadeoutStream()
        end
        MinigameEnd()
        Wait(1000)
        PedFollowPath(chemTeach, PATH._C4_TEACHER_PATH, 1, 0)
    end
    --[[
    if bPass then
        ChemTeacherSayCount = ChemTeacherSayCount + 1
        if 9 <= ChemTeacherSayCount then
            SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 13, "jumbo", true)
            ChemTeacherSayCount = 0
        end
        if AnimSeq[CurIndex].Cam then
            camEntry = camerasTable[AnimSeq[CurIndex].Cam]
            CameraSetPath(camEntry.cameraPath, true)
            CameraSetSpeed(camEntry.speed, camEntry.speed, camEntry.speed)
            CameraLookAtXYZ(camEntry.x, camEntry.y, camEntry.z, true)
        end
        if AnimSeq[CurIndex].Anim ~= "None" and AnimSeq[CurIndex].Anim ~= "BurnerDown" and AnimSeq[CurIndex].Anim ~= "BurnerUp" then
            --DebugPrint("Actiontree node: " .. animsroot .. AnimSeq[CurIndex].Anim .. " ************************************  " .. ActionAnimFile)
            SoundPlay2D("ChemRight")
            PedSetActionNode(gPlayer, animsroot .. AnimSeq[CurIndex].Anim, ActionAnimFile)
            if AnimSeq[CurIndex].Point == true then
                StartVibration(1, 400, 7)
            end
        end
        if AnimSeq[CurIndex].effect ~= nil then
            --DebugPrint("AnimSeq[CurIndex].effect: " .. AnimSeq[CurIndex].effect .. " ************************************  ")
            if AnimSeq[CurIndex].effect == "BuntzenFlame" then
                if AnimSeq[CurIndex].Anim == "BurnerUp" and BunsinIndex < 3 then
                    BunsinIndex = BunsinIndex + 1
                end
                if AnimSeq[CurIndex].Anim == "BurnerDown" and 1 < BunsinIndex then
                    BunsinIndex = BunsinIndex - 1
                end
                if FlameEffect ~= nil then
                    EffectKill(FlameEffect)
                    FlameEffect = nil
                end
                local x, y, z = GetPointList(POINTLIST._C4_FLAMEPOINT)
                FlameEffect = EffectCreate(BunsinFlames[BunsinIndex], x, y, z)
            elseif AnimSeq[CurIndex].effect == "BuntzenOff" then
                if FlameEffect ~= nil then
                    EffectKill(FlameEffect)
                    BunsinIndex = 1
                    FlameEffect = nil
                end
            else
                --DebugPrint("creating effect: " .. animsroot .. AnimSeq[CurIndex].effect)
                eff = EffectCreate(AnimSeq[CurIndex].effect, FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
                SoundPlay2D("ChemSmoke")
            end
        end
        if AnimSeq[CurIndex].ambEffect then
            --DebugPrint("creating ambEffect: " .. animsroot .. AnimSeq[CurIndex].ambEffect)
            g_eff = EffectCreate(AnimSeq[CurIndex].ambEffect, FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
        end
    elseif cAction ~= 23 then
        SoundPlay2D("ChemWrong")
        if g_eff then
            EffectKill(g_eff)
            g_eff = nil
        end
        if FlameEffect ~= nil then
            EffectKill(FlameEffect)
            BunsinIndex = 1
            FlameEffect = nil
        end
        gBadExperiment = EffectCreate("Chem_Reaction_r", FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
        PedStop(chemTeach)
        PedFaceObject(chemTeach, gPlayer, 3, 0)
        PedSetActionNode(chemTeach, animsroot .. "Teacher/TeacherChew", ActionAnimFile)
        if num_missed < 3 then
            StartVibration(1, 400, 7)
            PedSetActionNode(gPlayer, animsroot .. FailAnimTable[1], ActionAnimFile)
            SoundStopCurrentSpeechEvent(chemTeach)
            SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 12, "jumbo", true)
            if num_missed == 1 then
                gGetReadyText = "C4_GETREADY2"
            elseif num_missed == 2 then
                gGetReadyText = "C4_GETREADY3"
            end
        else
            SoundStopCurrentSpeechEvent(chemTeach)
            SoundPlayScriptedSpeechEvent(chemTeach, "CHEM", 15, "jumbo", true)
            StartVibration(0, 1500, 254)
            eff = EffectCreate("Chem_Accident", FlaskFX_XYZ.x, FlaskFX_XYZ.y, FlaskFX_XYZ.z)
            PedSetActionNode(gPlayer, animsroot .. FailAnimTable[2], ActionAnimFile)
            SoundFadeoutStream()
            MinigameEnd()
        end
        num_missed = num_missed + 1
        gbFailed = true
        PedFollowPath(chemTeach, PATH._C4_TEACHER_PATH, 1, 0)
    end
    ]] -- Original
end

--[[
function F_GetTSize(tbl)
    local NumOfElements = 0
    for i, k in AnimSeq do
        NumOfElements = NumOfElements + 1
    end
    return NumOfElements
end
]] -- Not present in original script

function F_SetStage(param)
    nCurrentClass = param
    bStageLoaded = true
end

function F_SetStageRepeatable(param)
    nCurrentClass = param
    bStageLoaded = true
    bIsRepeatable = true
end

function F_EndPresentation() -- ! Modified
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    AreaTransitionPoint(2, POINTLIST._C4_EXIT, nil, true)
    AreaClearAllPeds()
    CameraSetWidescreen(true)
    local x, y, z = GetPointList(POINTLIST._C4_ENDCAMLOOKAT)
    CameraLookAtXYZ(x, y, z, true)
    CameraSetPath(PATH._C4_UNLOCKPATH, true)
    CameraSetSpeed(0.5, 0.5, 0.5)
    PlayerWeaponHudLock(false)
    local unlockText = false
    local unlockMissionText = false
    --[[
    local unlockAnim = animsroot .. "Unlocks/EarnA"
    local unlockAnim2 = animsroot .. "Success"
    ]] -- Changed to:
    local unlockAnim = "/Global/C4/Animations/Unlocks/EarnA"
    local unlockAnim2 = "/Global/C4/Animations/Success"
    if nCurrentClass == 1 then
        --[[
        unlockText = "C4_unlock01"
        unlockMissionText = "TUT_CHEM1C1"
        unlockAnim2 = animsroot .. "Unlocks/SuccessHi2"
        ]]                                                       -- Removed this
        PlayerSetWeapon(301, 3, false)
        unlockText = "C4_unlock01"                               -- Added this
        unlockMissionText = "TUT_CHEM1C1"                        -- Added this
        unlockAnim2 = "/Global/C4/Animations/Unlocks/SuccessHi2" -- Added this
    elseif nCurrentClass == 2 then
        --[[
        unlockText = "C4_unlock02"
        unlockAnim = animsroot .. "Unlocks/EarnB"
        unlockAnim2 = animsroot .. "Unlocks/SuccessMed1"
        ]]                                                        -- Removed this
        PlayerSetWeapon(309, 3, false)
        unlockText = "C4_unlock02"                                -- Added this
        unlockAnim2 = "/Global/C4/Animations/Unlocks/SuccessMed1" -- Added this
    elseif nCurrentClass == 3 then
        --[[
        unlockText = "C4_Unlock03"
        unlockAnim = animsroot .. "Unlocks/EarnB"
        unlockAnim2 = animsroot .. "Unlocks/SuccessHi2"
        ]]                                                       -- Removed this
        unlockAnim = "/Global/C4/Animations/Unlocks/EarnB"       -- Added this
        PlayerSetWeapon(394, 3, false)
        unlockText = "C4_Unlock03"                               -- Added this
        unlockAnim = "/Global/C4/Animations/Unlocks/EarnB"       -- Added this
        unlockAnim2 = "/Global/C4/Animations/Unlocks/SuccessHi2" -- Added this
    elseif nCurrentClass == 4 then
        unlockText = "C4_Unlock04"
        unlockMissionText = "TUT_CHEM4C1"
        --[[
        unlockAnim = animsroot .. "Unlocks/SuccessHi1"
        ]] -- Changed to:
        unlockAnim = "/Global/C4/Animations/Unlocks/SuccessHi1"
    elseif nCurrentClass == 5 then
        unlockText = "C4_Unlock05"
        unlockMissionText = "TUT_CHEM5C1"
        --[[
        unlockAnim = animsroot .. "Unlocks/SuccessHi3"
        ]] -- Changed to:
        unlockAnim = "/Global/C4/Animations/Unlocks/SuccessHi3"
        unlockAnim2 = false
    end
    if nCurrentClass < 4 then
        local timeout = GetTimer()
        while not WeaponEquipped() do
            if GetTimer() - timeout > 3000 then
                break
            end
            Wait(0)
        end
    end
    CameraFade(-1, 1)
    MinigameSetCompletion("MEN_BLANK", true, 0, unlockText)
    SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
    --[[
    PedSetActionNode(gPlayer, unlockAnim, ActionAnimFile)
    Wait(3000)
    ]] -- Changed to:
    PedSetActionNode(gPlayer, unlockAnim, "Act/Conv/C4.act")
    Wait(2000)
    if unlockMissionText then
        TutorialShowMessage(unlockMissionText, -1, true)
    end
    while PedIsPlaying(gPlayer, unlockAnim, true) do
        Wait(0)
    end
    Wait(3500)
    TutorialRemoveMessage()
    --[[
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME)
    ]] -- Removed this
end

function F_CheckIfPrefect() -- ! Modified
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
        PedFaceObject(prefect, gPlayer, 3, 0)
        PedSetPedToTypeAttitude(prefect, 3, 2)
        CameraSetXYZ(-597.1507, 325.1509, 35.73755, -597.65344, 326.0126, 35.67)
        CameraFade(-1, 1)
        SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
        PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
        --[[
        PedSetActionNode(gPlayer, "/Global/C4B/Animations/Failure", ActionAnimFile)
        ]] -- Changed to:
        PedSetActionNode(gPlayer, "/Global/C4/Animations/Failure", "Act/Conv/C4.act")
        Wait(3000)
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

--[[
local ChemObject = {
    {
        Name = "Grab_BeakerX",
        x = -596.55,
        y = 323.487,
        z = 35.407
    },
    {
        Name = "Grab_TesttubeRightX",
        x = -595.786,
        y = 323.605,
        z = 35.311
    },
    {
        Name = "Grab_CanisterX",
        x = -595.951,
        y = 323.461,
        z = 35.238
    },
    {
        Name = "chem_stirX",
        x = -596.426,
        y = 323.612,
        z = 35.175
    },
    {
        Name = "Grab_EyedropX",
        x = -595.839,
        y = 323.426,
        z = 35.308
    },
    {
        Name = "Grab_Testtube_LeftX",
        x = -595.786,
        y = 323.605,
        z = 35.311
    },
    {
        Name = "matchbox_1p",
        x = -595.96,
        y = 323.608,
        z = 35.156
    },
    {
        Name = "matchstick_1p",
        x = -595.346,
        y = 323.967,
        z = 34.96
    }
}

function F_TurnOffOBJ(objIndex)
    DebugPrint("******************** Hiding " .. ChemObject[objIndex].Name .. " ******************************")
    GeometryInstance(ChemObject[objIndex].Name, true, ChemObject[objIndex].x, ChemObject[objIndex].y, ChemObject[objIndex].z)
end

function F_TurnONOBJ(objIndex)
    GeometryInstance(ChemObject[objIndex].Name, false, ChemObject[objIndex].x, ChemObject[objIndex].y, ChemObject[objIndex].z)
end
]] -- Not present in original script
