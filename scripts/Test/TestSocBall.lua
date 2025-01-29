local proj = -1

function MissionSetup()
    proj = CreateProjectile(329, gPlayerStartX + 3, gPlayerStartY, gPlayerStartZ, 0, 0, 0)
end

function MissionCleanup()
    DestroyProjectile(proj)
end

function main()
    while 1 do
        Wait(100)
    end
    Wait(10000000)
end
