local MAX_TARGETS = 2

local SinkholeSpawner = Class(function(self, inst)
    self.inst = inst
    self.targets = {}
end)

local function GetPlayerFromClientTable(c)
    for _, v in ipairs(AllPlayers) do
        if v.userid == c.userid then
            return v
        end
    end
end

function SinkholeSpawner:StartSinkholes()
    local weighted_players = {}
    local num_players = 0
    for i, v in ipairs(TheNet:GetClientTable() or {}) do
		local player = GetPlayerFromClientTable(v)
        if #v.prefab > 0 and (player == nil or TheWorld.Map:IsVisualGroundAtPoint(player.Transform:GetWorldPosition())) then
            weighted_players[v] = math.sqrt(v.playerage or 1)
            num_players = num_players + 1
        end
    end

    if num_players > 0 then
        local target_players = { weighted_random_choice(weighted_players) }
        if num_players > 3 then
            weighted_players[target_players[1]] = nil
            table.insert(target_players, weighted_random_choice(weighted_players))
        end

        local year_length = TUNING.AUTUMN_LENGTH + TUNING.WINTER_LENGTH + TUNING.SPRING_LENGTH + TUNING.SUMMER_LENGTH
        local base_num_attacks = TheWorld.state.remainingdaysinseason <= 2 and 1 or 0
        for i, v in pairs(target_players) do
            local num_attacks = math.min(base_num_attacks + math.floor((((v.playerage or 1) - 1) / year_length)) * 2 + TUNING.ANTLION_SINKHOLE.WAVE_MIN_ATTACKS, TUNING.ANTLION_SINKHOLE.WAVE_MAX_ATTACKS)
            if num_attacks > 0 then
                local targetinfo =
                {
                    client = v,
                    userhash = smallhash(v.userid),
                    attacks = num_attacks,
                }
                self:UpdateTarget(targetinfo)
                if targetinfo.client ~= nil then
                    if #self.targets >= MAX_TARGETS then
                        table.remove(self.targets, 1)
                    end
                    table.insert(self.targets, targetinfo)
                    self:DoTargetWarning(targetinfo)
                end
            end
        end

        self:PushRemoteTargets()

        if #self.targets > 0 then
            self.inst:StartUpdatingComponent(self)
			self.inst:PushEvent("onsinkholesstarted")
        end
    end
end

function SinkholeSpawner:StopSinkholes()
    while #self.targets > 0 do
        table.remove(self.targets)
        self.inst:StopUpdatingComponent(self)
    end

	self.inst:PushEvent("onsinkholesfinished")
    self:PushRemoteTargets()
end

function SinkholeSpawner:UpdateTarget(targetinfo)
    for i1, v1 in ipairs(AllPlayers) do
        if v1.userid == targetinfo.client.userid then
            targetinfo.player = v1
            targetinfo.pos = v1:GetPosition()
            return
        end
    end
    targetinfo.player = nil
    --V2C: TheShard:IsMigrating(userid) only works on master shard
    if targetinfo.pos ~= nil and not TheShard:IsMigrating(targetinfo.client.userid) then
        targetinfo.pos = nil
    end
end

local WARNING_RADIUS = 3.5
function SinkholeSpawner:DoTargetWarning(targetinfo)
    if targetinfo.warnings == nil then
        targetinfo.warnings = TUNING.ANTLION_SINKHOLE.NUM_WARNINGS
        targetinfo.next_warning = math.random() * TUNING.ANTLION_SINKHOLE.WARNING_DELAY_VARIANCE
    elseif targetinfo.warnings >= 0 then
        if targetinfo.pos ~= nil then
            --Handle locally
            ShakeAllCameras(CAMERASHAKE.SIDE, TUNING.ANTLION_SINKHOLE.WARNING_DELAY, .04, .05, targetinfo.pos, 6)

			for i = 1, math.ceil((TUNING.ANTLION_SINKHOLE.NUM_WARNINGS - (targetinfo.warnings or 0) + 1) / 3.2) do
				local fxpt = targetinfo.pos + Vector3((math.random() * (WARNING_RADIUS*2)) - WARNING_RADIUS, 0, (math.random() * (WARNING_RADIUS*2)) - WARNING_RADIUS)
				local rocks = SpawnPrefab("sinkhole_warn_fx_"..math.random(3)).Transform:SetPosition(fxpt:Get())
			end

            if ((targetinfo.warnings or 0) % 4 == 0) and targetinfo.player ~= nil and targetinfo.player:IsValid() then
                targetinfo.player.components.talker:Say(GetString(targetinfo.player, "ANNOUNCE_ANTLION_SINKHOLE"))
            end
        end

        targetinfo.warnings = targetinfo.warnings - 1

        if targetinfo.warnings <= 0 or targetinfo.client == nil then
            targetinfo.warnings = nil
            targetinfo.next_warning = nil
            targetinfo.next_attack = TUNING.ANTLION_SINKHOLE.WARNING_DELAY + math.random() * TUNING.ANTLION_SINKHOLE.WARNING_DELAY_VARIANCE
        else
            targetinfo.next_warning = TUNING.ANTLION_SINKHOLE.WARNING_DELAY + math.random() * TUNING.ANTLION_SINKHOLE.WARNING_DELAY_VARIANCE
        end
    end
end

function SinkholeSpawner:DoTargetAttack(targetinfo)
    if targetinfo.pos ~= nil then
        --Handle locally
        targetinfo.attacks = targetinfo.attacks - 1
        targetinfo.next_attack = targetinfo.attacks > 0 and TUNING.ANTLION_SINKHOLE.WAVE_ATTACK_DELAY + math.random() * TUNING.ANTLION_SINKHOLE.WAVE_ATTACK_DELAY_VARIANCE or nil

        for i, v in ipairs(self.targets) do
            if v ~= targetinfo and v.pos ~= nil and v.pos:DistSq(targetinfo.pos) < TUNING.ANTLION_SINKHOLE.WAVE_MERGE_ATTACKS_DIST_SQ then
                --Skip attack
                return
            end
        end
        self:SpawnSinkhole(targetinfo.pos)
    else
        --Remote attacks only once
        targetinfo.attacks = 0
        targetinfo.next_attack = nil
    end
end

local SINKHOLD_BLOCKER_TAGS = { "antlion_sinkhole_blocker" }
function SinkholeSpawner:SpawnSinkhole(spawnpt)
    local x = GetRandomWithVariance(spawnpt.x, TUNING.ANTLION_SINKHOLE.RADIUS)
    local z = GetRandomWithVariance(spawnpt.z, TUNING.ANTLION_SINKHOLE.RADIUS)

    local function IsValidSinkholePosition(offset)
        local x1, z1 = x + offset.x, z + offset.z
        local tile = TheWorld.Map:GetTileAtPoint(x1, 0, z1)
        if TileGroupManager:IsTemporaryTile(tile) and tile ~= WORLD_TILES.FARMING_SOIL then
            return false
        end
        if #TheSim:FindEntities(x1, 0, z1, TUNING.ANTLION_SINKHOLE.RADIUS * 1.9, SINKHOLD_BLOCKER_TAGS) > 0 then
            return false
        end
        for dx = -1, 1 do
            for dz = -1, 1 do
                if not TheWorld.Map:IsPassableAtPoint(x1 + dx * TUNING.ANTLION_SINKHOLE.RADIUS, 0, z1 + dz * TUNING.ANTLION_SINKHOLE.RADIUS, false, true) then
                    return false
                end
            end
        end
        return true
    end

    local offset = Vector3(0, 0, 0)
    offset =
        IsValidSinkholePosition(offset) and offset or
        FindValidPositionByFan(math.random() * TWOPI, TUNING.ANTLION_SINKHOLE.RADIUS * 1.8 + math.random(), 9, IsValidSinkholePosition) or
        FindValidPositionByFan(math.random() * TWOPI, TUNING.ANTLION_SINKHOLE.RADIUS * 2.9 + math.random(), 17, IsValidSinkholePosition) or
        FindValidPositionByFan(math.random() * TWOPI, TUNING.ANTLION_SINKHOLE.RADIUS * 3.9 + math.random(), 17, IsValidSinkholePosition) or
        nil

    if offset ~= nil then
        local sinkhole = SpawnPrefab("antlion_sinkhole")
        sinkhole.Transform:SetPosition(x + offset.x, 0, z + offset.z)
        sinkhole:PushEvent("startcollapse")
    end
end

function SinkholeSpawner:PushRemoteTargets()
    local data = {}
    for i, v in ipairs(self.targets) do
        if v.pos == nil then
            local warn = v.next_warning ~= nil and v.next_warning <= 0
            local attack = not warn and v.next_attack ~= nil and v.next_attack <= 0
            table.insert(data, {
                userhash = v.userhash,
                warn = warn or nil,
                attack = attack or nil,
            })
        end
    end
    TheWorld:PushEvent("master_sinkholesupdate", { targets = data })
end

function SinkholeSpawner:OnUpdate(dt)
    local towarn = {}
    local toattack = {}
    for i, v in ipairs(self.targets) do
        if v.client ~= nil then
            if v.player ~= nil and v.player:IsValid() then
				if not TheWorld.has_ocean or TheWorld.Map:IsVisualGroundAtPoint(v.player.Transform:GetWorldPosition()) then
	                v.pos.x, v.pos.y, v.pos.z = v.player.Transform:GetWorldPosition()
				end
            else
                v.client = TheNet:GetClientTableForUser(v.client.userid)
                if v.client ~= nil and #v.client.prefab > 0 then
                    self:UpdateTarget(v)
                else
                    v.client = nil
                    v.player = nil
                end
            end
        end
        if v.next_warning ~= nil then
            v.next_warning = v.next_warning - dt
            if v.next_warning <= 0 then
                table.insert(towarn, v)
            end
        elseif v.next_attack ~= nil then
            v.next_attack = v.next_attack - dt
            if v.next_attack <= 0 then
                table.insert(toattack, 1, { i, v })
            end
        end
    end

    self:PushRemoteTargets()

    for i, v in ipairs(towarn) do
        self:DoTargetWarning(v)
    end

    for i, v in ipairs(toattack) do
        self:DoTargetAttack(v[2])
        if v[2].attacks <= 0 then
            table.remove(self.targets, v[1])
        end
    end

    if #self.targets <= 0 then
        self.inst:StopUpdatingComponent(self)
        self.inst:PushEvent("onsinkholesfinished")
    end
end

function SinkholeSpawner:OnSave()
    if #self.targets > 0 then
        local data = {}
        for i, v in ipairs(self.targets) do
            if v.pos ~= nil then
                table.insert(data, {
                    x = v.pos.x,
                    z = v.pos.z,
                    attacks = v.attacks,
                    next_attack = v.next_attack ~= nil and math.floor(v.next_attack) or nil,
                    next_warning = v.next_warning ~= nil and math.floor(v.next_warning) or nil,
                })
            end
        end
        return #data > 0 and { targets = data } or nil
    end
end

function SinkholeSpawner:OnLoad(data)
    if data.targets ~= nil then
        for i, v in ipairs(data.targets) do
            if (v.attacks or 0) > 0 and v.x ~= nil and v.z ~= nil then
                local targetinfo =
                {
                    pos = Vector3(v.x, 0, v.z),
                    attacks = v.attacks,
                    next_attack = v.next_attack,
                    warnings = 0,
                    next_warning = v.next_warning,
                }
                if #self.targets >= MAX_TARGETS then
                    table.remove(self.targets, 1)
                end
                table.insert(self.targets, targetinfo)
            end
        end

        self:PushRemoteTargets()

        if #self.targets > 0 then
            self.inst:StartUpdatingComponent(self)
            self.inst:PushEvent("onsinkholesstarted")
        end
    end
end

function SinkholeSpawner:GetDebugString()
    local s
    for i, v in ipairs(self.targets) do
        if v.next_warning ~= nil then
            s = (s ~= nil and (s.."\n") or "")..string.format("  Warning %s (%d/%d) at (%.1f, %.1f) in %.2fs", tostring(v.player), TUNING.ANTLION_SINKHOLE.NUM_WARNINGS - v.warnings, TUNING.ANTLION_SINKHOLE.NUM_WARNINGS, v.pos ~= nil and v.pos.x or 0, v.pos ~= nil and v.pos.z or 0, v.next_warning)
        elseif v.next_attack ~= nil then
            s = (s ~= nil and (s.."\n") or "")..string.format("  Attacking %s (%d/%d) at (%.1f, %.1f) in %.2fs", tostring(v.player), TUNING.ANTLION_SINKHOLE.WAVE_MAX_ATTACKS - v.attacks, TUNING.ANTLION_SINKHOLE.WAVE_MAX_ATTACKS, v.pos ~= nil and v.pos.x or 0, v.pos ~= nil and v.pos.z or 0, v.next_attack)
        end
    end
    return s
end

return SinkholeSpawner
