function main()
    --print("=sss=====================> ChemPlant Script running!")
    DATLoad("TestPlatform.DAT", 2)
    DATLoad("SP_Chem_Plant.DAT", 0)
    DATLoad("iChemPlant.DAT", 0)
    F_PreDATInit()
    DATInit()
    Wait(5000)
    while not (AreaGetVisible() ~= 20 or SystemShouldEndScript()) do
        Wait(0)
    end
end
