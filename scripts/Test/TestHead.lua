function main()
    local x, y, z = PedGetPosXYZ(gPlayer)
    x = x + 3
    y = y + 3
    local actor = PedCreateXYZ(15, x, y, z)
    while not IsButtonPressed(9, 0) do
        Wait(0)
        if IsButtonPressed(8, 0) then
            PedFaceObject(actor, gPlayer, 2, 1)
        end
    end
end
