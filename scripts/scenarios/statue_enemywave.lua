enemytypes = {"knight", "bishop", "rook"}

local function OnEnemyKilled(inst, enemy, scenariorunner)
    if enemy.scene_deathfn then
        inst:RemoveEventCallback("death", enemy.scene_deathfn, enemy)
        enemy.scene_deathfn = nil
    end
	inst.wave[enemy] = nil
	if not next(inst.wave) then
		GetPlayer().components.sanity:SetPercent(1)
		scenariorunner:ClearScenario()
	end
end

local function ListenForDeath(inst, scenariorunner)
	for k,v in pairs(inst.wave) do
		if v.components.combat then
            v.scene_deathfn = function() OnEnemyKilled(inst, v, scenariorunner) end
			inst:ListenForEvent("death", v.scene_deathfn, v)
		end
	end
end

local function TrapInRocks(inst)
    GetPlayer().components.sanity:SetPercent(0.5)
end

local function StartWave(inst)
    inst:PushEvent("MaxwellThreat")
	local pt = inst:GetPosition()
    local theta = math.random() * TWOPI
    local radius = 4
    local steps = math.random(3,4)
    local step_decrement = (TWOPI / steps)
    local ground = TheWorld
    local player = GetPlayer()
    local spawnedguards = {}
    local settarget = function(inst, player)
        if inst and inst.brain then
            inst.brain.followtarget = player
        end
    end
    for _ = 1, steps do
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        local wander_point = pt + offset

        if ground.Map and not TileGroupManager:IsImpassableTile(ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z)) then
			local particle = SpawnPrefab("poopcloud")
            particle.Transform:SetPosition( wander_point.x, wander_point.y, wander_point.z )

            local enemy = SpawnPrefab(enemytypes[math.random(#enemytypes)])
            enemy.Transform:SetPosition( wander_point.x, wander_point.y, wander_point.z )
            enemy:DoTaskInTime(1, settarget, player)
            spawnedguards[enemy] = enemy
        end
        theta = theta - step_decrement
    end

    return spawnedguards
end

local function OnLoad(inst, scenariorunner)
	inst:ListenForEvent("onremove", function()
	inst.wave = StartWave(inst)
	ListenForDeath(inst, scenariorunner)
	TrapInRocks(inst)
	end)
end

return
{
	OnLoad = OnLoad
}
