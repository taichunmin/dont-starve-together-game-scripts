--this is called back by the engine side

PhysicsCollisionCallbacks = {}
function OnPhysicsCollision(guid1, guid2)
    local i1 = Ents[guid1]
    local i2 = Ents[guid2]

    if PhysicsCollisionCallbacks[guid1] then
        PhysicsCollisionCallbacks[guid1](i1, i2)
    end

    if PhysicsCollisionCallbacks[guid2] then
        PhysicsCollisionCallbacks[guid2](i2, i1)
    end
end

function Launch(inst, launcher, basespeed)
    if inst ~= nil and inst.Physics ~= nil and inst.Physics:IsActive() and launcher ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = launcher.Transform:GetWorldPosition()
        local vx, vz = x - x1, z - z1
        local spd = math.sqrt(vx * vx + vz * vz)
        local angle =
            spd > 0 and
            math.atan2(vz / spd, vx / spd) + (math.random() * 20 - 10) * DEGREES or
            math.random() * 2 * PI
        spd = (basespeed or 5) + math.random() * 2
        inst.Physics:Teleport(x, .1, z)
        inst.Physics:SetVel(math.cos(angle) * spd, 10, math.sin(angle) * spd)
    end
end

function Launch2(inst, launcher, basespeed, speedmult, startheight, startradius)
    if inst ~= nil and inst.Physics ~= nil and inst.Physics:IsActive() and launcher ~= nil then
	    local x, y, z = launcher.Transform:GetWorldPosition()
		local x1, y1, z1 = inst.Transform:GetWorldPosition()
		local dx, dz = x1 - x, z1 - z
		local dsq = dx * dx + dz * dz
		local angle
		if dsq > 0 then
			local dist = math.sqrt(dsq)
			angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
		else
			angle = 2 * PI * math.random()
		end
		local sina, cosa = math.sin(angle), math.cos(angle)
		local speed = basespeed + math.random() * speedmult
		inst.Physics:Teleport(x + startradius * cosa, startheight, z + startradius * sina)
		inst.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
	end
end

function LaunchAt(inst, launcher, target, speedmult, startheight, startradius)
    if inst ~= nil and inst.Physics ~= nil and inst.Physics:IsActive() and launcher ~= nil then
        local x, y, z = launcher.Transform:GetWorldPosition()
        local angle
        if target ~= nil then
            angle = (150 + math.random() * 60 - target:GetAngleToPoint(x, 0, z)) * DEGREES
        else
            local down = TheCamera:GetDownVec()
            angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
        end
        local sina, cosa = math.sin(angle), math.cos(angle)
        local spd = (math.random() * 2 + 1) * (speedmult or 1)
        inst.Physics:Teleport(x + (startradius or 0) * cosa, startheight or .1, z + (startradius or 0) * sina)
        inst.Physics:SetVel(spd * cosa, math.random() * 2 + 4 + 2 * (speedmult or 1), spd * sina)
    end
end

local COLLAPSIBLE_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}
local COLLAPSIBLE_TAGS = { "_combat", "pickable", "campfire" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "antlion", "groundspike", "flying", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }
function LaunchAndClearArea(inst, radius, launch_basespeed, launch_speedmult, launch_startheight, launch_startradius, attack_characters)
    local x, y, z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, 0, z, radius, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() then
            local isworkable = false
            if v.components.workable ~= nil then
                local work_action = v.components.workable:GetWorkAction()
                --V2C: nil action for campfires
                --     allow digging spawners (e.g. rabbithole)
                isworkable = (
                    (work_action == nil and v:HasTag("campfire")) or
                    (v.components.workable:CanBeWorked() and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
                )
            end
            if isworkable then
                v.components.workable:Destroy(inst)
                if v:IsValid() and v:HasTag("stump") then
                    v:Remove()
                end
            elseif v.components.pickable ~= nil
                and v.components.pickable:CanBePicked()
                and not v:HasTag("intense") then
                local num = v.components.pickable.numtoharvest or 1
                local product = v.components.pickable.product
                local x1, y1, z1 = v.Transform:GetWorldPosition()
                v.components.pickable:Pick(inst) -- only calling this to trigger callbacks on the object
                if product ~= nil and num > 0 then
                    for i = 1, num do
                        SpawnPrefab(product).Transform:SetPosition(x1, 0, z1)
                    end
                end
            elseif v.components.combat ~= nil
                and v.components.health ~= nil
                and not v.components.health:IsDead() then
                if v.components.locomotor == nil then
                    v.components.health:Kill()
                elseif attack_characters and inst.components.combat:IsValidTarget(v) then
                    inst.components.combat:DoAttack(v)
                end
            end
        end
    end

    local totoss = TheSim:FindEntities(x, 0, z, radius, { "_inventoryitem" }, { "locomotor", "INLIMBO" })
    for i, v in ipairs(totoss) do
        if v.components.mine ~= nil then
            v.components.mine:Deactivate()
        end
        if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
			Launch2(v, inst, launch_basespeed, launch_speedmult, launch_startheight, launch_startradius)
        end
    end
end