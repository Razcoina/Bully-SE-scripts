local nerd_on_gun = false
local orderly1, bar_attacker

function main()
    DATLoad("SpawnTest.DAT", 0)
    DATLoad("TFight01.DAT", 0)
    F_PreDATInit()
    DATInit()
    --DebugPrint("*********************************************** island_3 - main() Start")
    while not (AreaGetVisible() ~= 22 or SystemShouldEndScript()) do
        Wait(0)
    end
    --DebugPrint("*********************************************** island_3 - main() End")
    DATUnload(0)
end
