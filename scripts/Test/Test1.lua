mission_completed = false
greaser1 = nil

function F_CreateCharacters()
    greaser1 = PedCreatePoint(26, POINTLIST._TEST_HEADING_PED)
    AddBlipForChar(greaser1, 2, 1)
end

function main()
    TextPrintString("TEST : Set Player and Ped headings", 8)
    F_CreateCharacters()
    AreaTransitionPoint(VISIBLEAREA_CAF_KITCHEN, POINTLIST._TEST_HEADING_PLAYER)
    while mission_completed == false do
        Wait(0)
    end
end
