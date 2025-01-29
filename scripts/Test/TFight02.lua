local SNIPER = 1
local GUARD = 2
local ATTACKER = 3
local enemies = {
    {
        id = nil,
        fight_id = 1,
        model = 30,
        role = ATTACKER,
        spawn = POINTLIST._TF02_F1_ATTACKER1
    },
    {
        id = nil,
        fight_id = 1,
        model = 31,
        role = ATTACKER,
        spawn = POINTLIST._TF02_F1_ATTACKER2
    },
    {
        id = nil,
        fight_id = 1,
        model = 19,
        role = ATTACKER,
        spawn = POINTLIST._TF02_F1_ATTACKER3
    },
    {
        id = nil,
        fight_id = 1,
        model = 18,
        role = GUARD,
        spawn = POINTLIST._TF02_F1_GUARD1
    },
    {
        id = nil,
        fight_id = 1,
        model = 22,
        role = GUARD,
        spawn = POINTLIST._TF02_F1_GUARD2
    },
    {
        id = nil,
        fight_id = 1,
        model = 42,
        role = SNIPER,
        spawn = POINTLIST._TF02_F1_SNIPER1
    },
    {
        id = nil,
        fight_id = 1,
        model = 41,
        role = SNIPER,
        spawn = POINTLIST._TF02_F1_SNIPER2
    },
    {
        id = nil,
        fight_id = 2,
        model = 30,
        role = ATTACKER,
        spawn = POINTLIST._TF02_F2_ATTACKER1
    },
    {
        id = nil,
        fight_id = 2,
        model = 31,
        role = ATTACKER,
        spawn = POINTLIST._TF02_F2_ATTACKER2
    },
    {
        id = nil,
        fight_id = 2,
        model = 22,
        role = GUARD,
        spawn = POINTLIST._TF02_F2_GUARD1
    },
    {
        id = nil,
        fight_id = 2,
        model = 18,
        role = GUARD,
        spawn = POINTLIST._TF02_F2_GUARD2
    },
    {
        id = nil,
        fight_id = 2,
        model = 16,
        role = GUARD,
        spawn = POINTLIST._TF02_F2_GUARD3
    },
    {
        id = nil,
        fight_id = 2,
        model = 43,
        role = SNIPER,
        spawn = POINTLIST._TF02_F2_SNIPER1
    },
    {
        id = nil,
        fight_id = 2,
        model = 45,
        role = SNIPER,
        spawn = POINTLIST._TF02_F2_SNIPER2
    }
}
local fight1active = false
local fight2active = false
local mission_completed = false

function F_EnemyActive(enemy)
    return enemy.fight_id == 1 and fight1active or enemy.fight_id == 2 and fight2active
end

function F_CreateEnemies()
    for i, enemy in enemies do
        enemy.id = PedCreatePoint(enemy.model, enemy.spawn)
        if enemy.role == SNIPER then
            PedSetWeapon(enemy.id, 303, 1)
            PedSetAITree(enemy.id, "AI_Sniper", "Act/AI_Snipe.act")
        end
    end
end

function F_FightStarter()
    while not (mission_completed or fight1active and fight2active) do
        if PlayerIsInTrigger(TRIGGER._TF02_FIGHT1) then
            fight1active = true
        elseif PlayerIsInTrigger(TRIGGER._TF02_FIGHT2) then
            fight2active = true
        end
        Wait(0)
    end
end

function F_ControlEnemies()
    while not mission_completed do
        for i, enemy in enemies do
            if not enemy.attacking and F_EnemyActive(enemy) then
                if enemy.role == ATTACKER or enemy.role == SNIPER then
                    enemy.attacking = true
                    PedAttackPlayer(enemy.id)
                elseif enemy.role == GUARD then
                    local x, y, z = PedGetPosXYZ(enemy.id)
                    if PlayerIsInAreaXYZ(x, y, z, 1, 0) then
                        enemy.attacking = true
                        PedAttackPlayer(enemy.id)
                    end
                end
            end
        end
        Wait(0)
    end
end

function F_WaitForFightToEnd()
    local enemies_alive = true
    while enemies_alive do
        if fight1active or fight2active then
            enemies_alive = false
            for i, enemy in enemies do
                if F_EnemyActive(enemy) and not PedIsDead(enemy.id) then
                    enemies_alive = true
                    break
                end
            end
        end
        Wait(0)
    end
    mission_completed = true
end

function MissionSetup()
    AreaTransitionPoint(22, POINTLIST._TF02_PLAYERSTART)
    F_CreateEnemies()
end

function MissionCleanup()
end

function main()
    TextPrintString("TEST FIGHT 2 -- MULTILEVEL", 2)
    CreateThread("F_FightStarter")
    CreateThread("F_ControlEnemies")
    F_WaitForFightToEnd()
    MissionSucceed()
end
