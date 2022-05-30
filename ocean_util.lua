

function IsOceanTile(tile)
	return tile >= GROUND.OCEAN_START and tile <= GROUND.OCEAN_END
end

function IsLandTile(tile)
	return tile < GROUND.UNDERGROUND and
        tile ~= GROUND.IMPASSABLE and
        tile ~= GROUND.INVALID
end

local WAVE_SPAWN_DISTANCE = 1.5
function SpawnAttackWaves(position, rotation, spawn_radius, numWaves, totalAngle, waveSpeed, wavePrefab, idleTime, instantActive)
    wavePrefab = wavePrefab or "wave_med"
    waveSpeed = waveSpeed or 6
    idleTime = idleTime or 5
    totalAngle = (numWaves == 1 and 0) or
            (totalAngle and (totalAngle % 361)) or
            360

    local anglePerWave = (totalAngle == 0 and 0) or
            (totalAngle == 360 and totalAngle/numWaves) or
            totalAngle/(numWaves - 1)

    local startAngle = rotation or math.random(-180, 180)
    local total_rad = (spawn_radius or 0.0) + WAVE_SPAWN_DISTANCE

    local wave_spawned = false
    for i = 0, numWaves - 1 do
        local angle = (startAngle - (totalAngle/2)) + (i * anglePerWave)
        local offset_direction = Vector3(math.cos(angle*DEGREES), 0, -math.sin(angle*DEGREES)):Normalize()
        local wavepos = position + (offset_direction * total_rad)

        if not TheWorld.Map:IsPassableAtPoint(wavepos:Get()) then
            wave_spawned = true

            local wave = SpawnPrefab(wavePrefab)
            wave.Transform:SetPosition(wavepos:Get())
            wave.Transform:SetRotation(angle)
            if type(waveSpeed) == "table" then
                wave.Physics:SetMotorVel(waveSpeed[1], waveSpeed[2], waveSpeed[3])
            else
                wave.Physics:SetMotorVel(waveSpeed, 0, 0)
            end
            wave.idle_time = idleTime

            if instantActive then
                wave.sg:GoToState((idleTime > 0 and "instant_rise") or "lower")
            end
        end
    end

    -- Let our caller know if we actually spawned at least 1 wave.
    return wave_spawned
end

function SpawnAttackWave(position, rotation, waveSpeed, wavePrefab, idleTime, instantActive)
    return SpawnAttackWaves(position, rotation, nil, 1, nil, waveSpeed, wavePrefab, idleTime, instantActive)
end

function FindLandBetweenPoints(p0x, p0y, p1x, p1y)
	local map = TheWorld.Map

	local dx = math.abs(p1x - p0x)
	local dy = math.abs(p1y - p0y)

    local ix = p0x < p1x and TILE_SCALE or -TILE_SCALE
    local iy = p0y < p1y and TILE_SCALE or -TILE_SCALE

    local e = 0;
    for i = 0, dx+dy - 1 do
	    if IsLandTile(map:GetTileAtPoint(p0x, 0, p0y)) then
			return map:GetTileCenterPoint(p0x, 0, p0y)
		end

        local e1 = e + dy
        local e2 = e - dx
        if math.abs(e1) < math.abs(e2) then
            p0x = p0x + ix
            e = e1
		else
            p0y = p0y + iy
            e = e2
        end
	end

	return nil
end

function FindRandomPointOnShoreFromOcean(x, y, z)
	local nodes = {}

    for i, node in ipairs(TheWorld.topology.nodes) do
		if node.type ~= NODE_TYPE.Blank and node.type ~= NODE_TYPE.Blocker and node.type ~= NODE_TYPE.SeparatedRoom then
			table.insert(nodes, {n = node, distsq = VecUtil_LengthSq(x - node.x, z - node.y)})
		end
	end
	table.sort(nodes, function(a, b) return a.distsq < b.distsq end)

	local num_rooms_to_pick = 4

	local closest = {}
	for i = 1, num_rooms_to_pick do
		table.insert(closest, nodes[i])
	end
	shuffleArray(closest)

	local dest_x, dest_y, dest_z
	for _, c in ipairs(closest) do
		dest_x, dest_y, dest_z = FindLandBetweenPoints(x, z, c.n.x, c.n.y)
		if dest_x ~= nil and TheSim:WorldPointInPoly(dest_x, dest_z, c.n.poly) then
			return dest_x, dest_y, dest_z
		end
	end

	for i = num_rooms_to_pick + 1, #nodes do
		local c = nodes[i]
		if c ~= nil then
			dest_x, dest_y, dest_z = FindLandBetweenPoints(x, z, c.n.x, c.n.y)
			if dest_x ~= nil and TheSim:WorldPointInPoly(dest_x, dest_z, c.n.poly) then
				return dest_x, dest_y, dest_z
			end
		end
	end

	if TheWorld.components.playerspawner ~= nil then
		return TheWorld.components.playerspawner:GetAnySpawnPoint()
	end

	return nil
end

function LandFlyingCreature(creature)
    creature:RemoveTag("flying")
    creature:PushEvent("on_landed")
    if creature.Physics ~= nil then
        if TheWorld.has_ocean then
            creature.Physics:CollidesWith(COLLISION.LIMITS)
        end
        creature.Physics:ClearCollidesWith(COLLISION.FLYERS)
    end
end

function RaiseFlyingCreature(creature)
    creature:AddTag("flying")
    creature:PushEvent("on_no_longer_landed")
    if creature.Physics ~= nil then
        if TheWorld.has_ocean then
            creature.Physics:ClearCollidesWith(COLLISION.LIMITS)
        end
        creature.Physics:CollidesWith(COLLISION.FLYERS)
    end
end

function ShouldEntitySink(entity, entity_sinks_in_water)
    local inventory = (entity.components ~= nil and entity.components.inventoryitem) or nil
    if not entity:IsInLimbo() and (not inventory or not inventory:IsHeld()) then
        local px, _, pz = entity.Transform:GetWorldPosition()
        return not TheWorld.Map:IsPassableAtPoint(px, 0, pz, not entity_sinks_in_water)
    end
end

function SinkEntity(entity)
    if not entity:IsValid() then
        return
    end

    local px, py, pz = 0, 0, 0
    if entity.Transform ~= nil then
        px, py, pz = entity.Transform:GetWorldPosition()
    end

    if entity.components.inventory ~= nil then
        entity.components.inventory:DropEverything()
    end

    if entity.components.container ~= nil then
        entity.components.container:DropEverything()
    end

    local fx = SpawnPrefab((TheWorld.Map:IsValidTileAtPoint(px, py, pz) and "splash_sink") or "splash_ocean")
    fx.Transform:SetPosition(px, py, pz)

    -- If the entity is irreplaceable, respawn it at the player
    if entity:HasTag("irreplaceable") then
        local sx, sy, sz = FindRandomPointOnShoreFromOcean(px, py, pz)
        if sx ~= nil then
            entity.Transform:SetPosition(sx, sy, sz)
        else
            -- Our reasonable cases are out... so let's loop to find the portal and respawn there.
            for k, v in pairs(Ents) do
                if v:IsValid() and v:HasTag("multiplayer_portal") then
                    entity.Transform:SetPosition(v.Transform:GetWorldPosition())
                end
            end
        end
    else
        entity:Remove()
    end
end

function CanProbablyReachTargetFromShore(inst, target, max_distance)
    local myx, myy, myz = inst.Transform:GetWorldPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local normx, normz = VecUtil_Normalize(myx - tx, myz - tz)
    return TheWorld.Map:IsAboveGroundAtPoint(tx + normx * max_distance, ty, tz + normz * max_distance)
end

function TintByOceanTile(inst)
    local GroundTiles = require("worldtiledefs")
    inst:DoTaskInTime(0,function(inst)
        local pos = inst:GetPosition()
        local tile = TheWorld.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
        local tile_info = GetTileInfo(tile)
        if tile_info then
            local color = tile_info.wavetint
            if color then
                inst.AnimState:SetMultColour(color[1],color[2],color[3],1)
            end

        else
            -- if it can't tint. it's not on water. Remove it.
            inst:Remove()
        end
    end)
end
