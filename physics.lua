--this is called back by the engine side

PhysicsCollisionCallbacks = {}
function OnPhysicsCollision(guid1, guid2, world_position_on_a_x, world_position_on_a_y, world_position_on_a_z, world_position_on_b_x, world_position_on_b_y, world_position_on_b_z, world_normal_on_b_x, world_normal_on_b_y, world_normal_on_b_z, lifetime_in_frames)
    local i1 = Ents[guid1]
    local i2 = Ents[guid2]

    local callback1 = PhysicsCollisionCallbacks[guid1]
    if callback1 then
        callback1(i1, i2, world_position_on_a_x, world_position_on_a_y, world_position_on_a_z, world_position_on_b_x, world_position_on_b_y, world_position_on_b_z, world_normal_on_b_x, world_normal_on_b_y, world_normal_on_b_z, lifetime_in_frames)
    end

    local callback2 = PhysicsCollisionCallbacks[guid2]
    if callback2 then
        callback2(i2, i1, world_position_on_b_x, world_position_on_b_y, world_position_on_b_z, world_position_on_a_x, world_position_on_a_y, world_position_on_a_z, -world_normal_on_b_x, -world_normal_on_b_y, -world_normal_on_b_z, lifetime_in_frames)
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

function Launch2(inst, launcher, basespeed, speedmult, startheight, startradius, vertical_speed, force_angle)
    if inst ~= nil and inst.Physics ~= nil and inst.Physics:IsActive() and launcher ~= nil then
	    local x, y, z = launcher.Transform:GetWorldPosition()
		local x1, y1, z1 = inst.Transform:GetWorldPosition()
		local dx, dz = x1 - x, z1 - z
		local dsq = dx * dx + dz * dz
		local angle = force_angle ~= nil and (force_angle*DEGREES) or nil
		if not angle then
			if dsq > 0 then
				local dist = math.sqrt(dsq)
				angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
			else
				angle = 2 * PI * math.random()
			end
		end
		local sina, cosa = math.sin(angle), math.cos(angle)
		local speed = basespeed + math.random() * speedmult
		local vertical_speed = vertical_speed or (speed * 5 + math.random() * 2)
		inst.Physics:Teleport(x + startradius * cosa, startheight, z + startradius * sina)
		inst.Physics:SetVel(cosa * speed, vertical_speed, sina * speed)

		return angle
	end

	return 0
end

function LaunchAt(inst, launcher, target, speedmult, startheight, startradius, randomangleoffset)
    if inst ~= nil and inst.Physics ~= nil and inst.Physics:IsActive() and launcher ~= nil then
        local x, y, z = launcher.Transform:GetWorldPosition()
        local angleoffset = randomangleoffset or 30
        local angle
        if target ~= nil then
            local start_angle = 180 - angleoffset
            angle = (start_angle + (math.random() * angleoffset * 2) - target:GetAngleToPoint(x, 0, z)) * DEGREES
        else
            local down = TheCamera:GetDownVec()
            angle = math.atan2(down.z, down.x) + (math.random() * angleoffset * 2 - angleoffset) * DEGREES
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
local COLLAPSIBLE_TAGS = { "_combat", "pickable", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "antlion", "groundspike", "flying", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }

function DestroyEntity(ent, destroyer, kill_all_creatures, remove_entity_as_fallback)
    if ent:IsValid() then
        local isworkable = false
        if ent.components.workable ~= nil then
            local work_action = ent.components.workable:GetWorkAction()
                --V2C: nil action for NPC_workable (e.g. campfires)
            --     allow digging spawners (e.g. rabbithole)
            isworkable = (
                    (work_action == nil and ent:HasTag("NPC_workable")) or
                    (work_action ~= nil and ent.components.workable:CanBeWorked() and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
            )
        end

        local health = ent.components.health
        if isworkable then
            ent.components.workable:Destroy(destroyer)
            if ent:IsValid() and ent:HasTag("stump") then
                ent:Remove()
            end
        elseif ent.components.pickable ~= nil
            and ent.components.pickable:CanBePicked()
            and not ent:HasTag("intense") then
            local num = ent.components.pickable.numtoharvest or 1
            local product = ent.components.pickable.product
            local x1, y1, z1 = ent.Transform:GetWorldPosition()
            ent.components.pickable:Pick(destroyer) -- only calling this to trigger callbacks on the object
            if product ~= nil and num > 0 then
                for i = 1, num do
                    SpawnPrefab(product).Transform:SetPosition(x1, 0, z1)
                end
            end
		elseif kill_all_creatures and health ~= nil then
			if not health:IsDead() then
				health:Kill()
			end
        elseif ent.components.combat ~= nil
            and health ~= nil
            and not health:IsDead() then
            if ent.components.locomotor == nil then
                health:Kill()
            end
        elseif remove_entity_as_fallback then
            ent:Remove()
        end
    end
end

local TOSS_MUST_TAGS = { "_inventoryitem" }
local TOSS_CANT_TAGS = { "locomotor", "INLIMBO" }
function LaunchAndClearArea(inst, radius, launch_basespeed, launch_speedmult, launch_startheight, launch_startradius)
    local x, y, z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, 0, z, radius, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)
    for i, v in ipairs(ents) do
		DestroyEntity(v, inst)
    end

    local totoss = TheSim:FindEntities(x, 0, z, radius, TOSS_MUST_TAGS, TOSS_CANT_TAGS)
    for i, v in ipairs(totoss) do
        if v.components.mine ~= nil then
            v.components.mine:Deactivate()
        end
        if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
			Launch2(v, inst, launch_basespeed, launch_speedmult, launch_startheight, launch_startradius)
        end
    end
end
