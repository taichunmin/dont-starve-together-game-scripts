
function IsOceanTile(tile)
	return tile >= GROUND.OCEAN_START and tile <= GROUND.OCEAN_END
end

function IsLandTile(tile)
	return tile < GROUND.UNDERGROUND and
        tile ~= GROUND.IMPASSABLE and
        tile ~= GROUND.INVALID
end

function SpawnWaves(inst, numWaves, totalAngle, waveSpeed, wavePrefab, initialOffset, idleTime, instantActive, random_angle)
	wavePrefab = wavePrefab or "rogue_wave"
	totalAngle = math.clamp(totalAngle, 1, 360)

    local pos = inst:GetPosition()
    local startAngle = (random_angle and math.random(-180, 180)) or inst.Transform:GetRotation()
    local anglePerWave = totalAngle/(numWaves - 1)

	if totalAngle == 360 then
		anglePerWave = totalAngle/numWaves
	end

    --[[
    local debug_offset = Vector3(2 * math.cos(startAngle*DEGREES), 0, -2 * math.sin(startAngle*DEGREES)):Normalize()
    inst.components.debugger:SetOrigin("debugy", pos.x, pos.z)
    local debugpos = pos + (debug_offset * 2)
    inst.components.debugger:SetTarget("debugy", debugpos.x, debugpos.z)
    inst.components.debugger:SetColour("debugy", 1, 0, 0, 1)
	--]]

    for i = 0, numWaves - 1 do
        local wave = SpawnPrefab(wavePrefab)

        local angle = (startAngle - (totalAngle/2)) + (i * anglePerWave)
        local rad = initialOffset or (inst.Physics and inst.Physics:GetRadius()) or 0.0
        local total_rad = rad + wave.Physics:GetRadius() + 0.1
        local offset = Vector3(math.cos(angle*DEGREES),0, -math.sin(angle*DEGREES)):Normalize()
        local wavepos = pos + (offset * total_rad)

        if inst:GetIsOnWater(wavepos:Get()) then
	        wave.Transform:SetPosition(wavepos:Get())

	        local speed = waveSpeed or 6
	        wave.Transform:SetRotation(angle)
	        wave.Physics:SetMotorVel(speed, 0, 0)
	        wave.idle_time = idleTime or 5

	        if instantActive then
	        	wave.sg:GoToState("idle")
	        end

	        if wave.soundtidal then
	        	wave.SoundEmitter:PlaySound("dontstarve_DLC002/common/rogue_waves/"..wave.soundtidal)
	        end
        else
        	wave:Remove()
        end
    end
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
        creature.Physics:CollidesWith(COLLISION.LIMITS)
        creature.Physics:ClearCollidesWith(COLLISION.FLYERS)
    end
end

function RaiseFlyingCreature(creature)
    creature:AddTag("flying")
    creature:PushEvent("on_no_longer_landed")
    if creature.Physics ~= nil then
        creature.Physics:ClearCollidesWith(COLLISION.LIMITS)
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
