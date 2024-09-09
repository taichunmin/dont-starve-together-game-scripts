------------------------------------------------------------------------------------------
-- Manages item drops during a lunar hail storm. The event itself starts in weather.lua
------------------------------------------------------------------------------------------

local SHADECANOPY_MUST_TAGS = {"shadecanopy"}
local SHADECANOPY_SMALL_MUST_TAGS = {"shadecanopysmall"}

local PLAYER_MUST_TAGS = {"player"}

return Class(function(self, inst)
    --------------------------------------------------------------------------
    --[[ Member variables ]]
    --------------------------------------------------------------------------
    
    -- Public
    
    self.inst = inst

    self.onimpact_oneoftags = { "_combat", "_inventoryitem", "farmplantstress" }
    self.onimpact_canttags  = { "INLIMBO", "playerghost", "invisible", "epic", "lunar_aligned", "wall", "hive", "houndmound" }

    -- Private
    local _world = TheWorld
    local _ismastersim = _world.ismastersim

    local _scaleratemin = TUNING.LUNARHAIL_DEBRIS_SPAWN_SCALE_RATE_MIN
    local _scaleratemax = TUNING.LUNARHAIL_DEBRIS_SPAWN_SCALE_RATE_MAX
    
    local _enabled = false

    local _debris =
    {
        { weight = 2.5, loot = { "moonglass"         } },
        { weight = 1,   loot = { "moonglass_charged" } },
    }

    local _tagdebris = { }

    local _activeplayers = {}
    local _scheduleddrops = {}
    local _originalplayers = {}

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    -- Debris methods
    local UpdateShadowSize = _ismastersim and function(shadow, height)
        local scaleFactor = Lerp(.5, 1.2, height / 35)
        shadow.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)
    end or nil
    
    local GetDebris = _ismastersim and function(node_data)
        local debris_table = nil
        if node_data == nil or node_data.tags == nil then
            debris_table = _debris
        else
            debris_table = {}
    
            -- We support empty tables to produce no debris,
            -- so we can't just test for an empty table later.
            local tag_found = false
            for _, tag in ipairs(node_data.tags) do
                local tag_table = _tagdebris[tag]
                if tag_table ~= nil then
                    tag_found = true
                    ConcatArrays(debris_table, tag_table)
                end
            end
    
            if not tag_found then
                debris_table = _debris
            end
        end
    
        local weighttotal = 0
        for i,v in ipairs(debris_table) do
            weighttotal = weighttotal + v.weight
        end
        local val = math.random() * weighttotal
        local droptable = nil
        for i,v in ipairs(debris_table) do
            if val < v.weight then
                droptable = deepcopy(v.loot)
                break
            else
                val = val-v.weight
            end
        end
    
        local todrop = nil
        if droptable ~= nil then
            while todrop == nil and #droptable > 0 do
                local index = math.random(1,#droptable)
                todrop = droptable[index]
            end
        end

        return todrop
    end or nil

    local _BreakDebris = _ismastersim and function(debris)
        local x, y, z = debris.Transform:GetWorldPosition()

        SpawnPrefab(debris.Light ~= nil and "mining_charged_moonglass_fx" or "mining_moonglass_fx").Transform:SetPosition(x, 0, z)

        debris:Remove()
    end or nil

    local _DebrisTimeOver = _ismastersim and function(debris)
        if debris._timeovertask ~= nil then
            debris._timeovertask:Cancel()
            debris._timeovertask = nil
        end

        if not debris:IsInLimbo() then
            _BreakDebris(debris)
        end
    end or nil

    local _DebrisOnEnterLimbo

    _DebrisOnEnterLimbo = _ismastersim and function(debris)
        debris:RemoveEventCallback("enterlimbo", _DebrisOnEnterLimbo)

        if debris._timeovertask ~= nil then
            debris._timeovertask:Cancel()
            debris._timeovertask = nil
        end

        debris.Transform:SetScale(1, 1, 1)

        debris.persists = true
    end or nil

    local DebrisCanHitTarget = _ismastersim and function(debris, target)
        -- FIXME(DiogoW): Temporary, until a new creature protection feature/behavior is added.
        if not target:HasTag("player") then
            return false
        end

        if target.components.combat == nil then
            return false
        end

        if target.components.sheltered ~= nil and target.components.sheltered.sheltered then
            return false
        end

        if target.components.inventory ~= nil and target.components.inventory:EquipHasTag("lunarhailprotection") then
            return false
        end

        return true

    end or nil

    local _GroundDetectionUpdate = _ismastersim and function(debris)
        local x, y, z = debris.Transform:GetWorldPosition()
        if y <= .2 then
            -- NOTE: re-check validity as we iterate, since we're invalidating stuff as we go
            local ents = TheSim:FindEntities(x, 0, z, TUNING.LUNARHAIL_DEBRIS_DAMAGE_RADIUS, nil, self.onimpact_canttags, self.onimpact_oneoftags)
            for i, v in ipairs(ents) do
                if v ~= debris and v:IsValid() and not v:IsInLimbo() then
                    if  DebrisCanHitTarget(debris, v) then
                        v.components.combat:GetAttacked(debris, TUNING.LUNARHAIL_DEBRIS_DAMAGE, nil)

                    -- Don't mess with dropped items used as decoration.
                    elseif v:HasTag("lunarhaildebris") and not v.persists and v.components.inventoryitem ~= nil then
                        Launch(v, debris, TUNING.LAUNCH_SPEED_SMALL)

                    elseif v.components.farmplantstress ~= nil then
                        v.components.farmplantstress:SetStressed("happiness", true, debris)

                        if v.components.growable ~= nil then
                            if v.components.farmplanttendable ~= nil then
                                v.components.farmplanttendable:SetTendable(v.components.growable:GetCurrentStageData().tendable)
                            end
                        end
                    end
                end
            end

            debris.Physics:SetDamping(.6)

            local speed = 2.2 + math.random()
            local angle = math.random() * TWOPI
            debris.Physics:SetMotorVel(0, 0, 0)
            debris.Physics:SetVel(
                speed * math.cos(angle),
                speed * 2.3,
                speed * math.sin(angle)
            )

            debris.shadow:Remove()
            debris.shadow = nil

            debris.updatetask:Cancel()
            debris.updatetask = nil

            debris.SoundEmitter:PlaySound("rifts3/lunarhail/hail_land")

            if math.random() <= TUNING.LUNARHAIL_DEBRIS_KEEP_CHANCE then
                --debris.persists = true -- Do NOT persist!
                debris.entity:SetCanSleep(true)

                debris._timeovertask = debris:DoTaskInTime(TUNING.LUNARHAIL_DEBRIS_LIFETIME, _DebrisTimeOver)
                debris:ListenForEvent("enterlimbo", _DebrisOnEnterLimbo)

                if debris._restorepickup then
                    debris._restorepickup = nil
                    if debris.components.inventoryitem ~= nil then
                        debris.components.inventoryitem.canbepickedup = true
                    end
                end
                debris:PushEvent("stopfalling")

            elseif debris:GetTimeAlive() < 1.5 then
                if debris.Light ~= nil then
                    debris:AddComponent("lighttweener")
                    debris.components.lighttweener:StartTween(debris.Light, 0, 0, nil, nil, 0.3)
                end
                
                --should be our first bounce
                debris:DoTaskInTime(.4, _BreakDebris)
            else
                --we missed detecting our first bounce, so break immediately this time
                _BreakDebris(debris)
            end

        elseif debris:GetTimeAlive() < 3 then
            if y < 2 then
                debris.Physics:SetMotorVel(0, 0, 0)
            end
            UpdateShadowSize(debris.shadow, y)

        elseif debris:IsInLimbo() then
            --failsafe, but maybe we got trapped or picked up somehow, so keep it
            debris.persists = true
            debris.entity:SetCanSleep(true)
            debris.shadow:Remove()
            debris.shadow = nil
            debris.updatetask:Cancel()
            debris.updatetask = nil
            debris.Transform:SetScale(1, 1, 1)
            if debris._restorepickup then
                debris._restorepickup = nil
                if debris.components.inventoryitem ~= nil then
                    debris.components.inventoryitem.canbepickedup = true
                end
            end
            debris:PushEvent("stopfalling")
        else
            --failsafe
            _BreakDebris(debris)
        end
    end or nil

    -- /debris methods

    local OnRemoveDebris = _ismastersim and function(debris)
        debris.shadow:Remove()
    end or nil

    local SpawnDebris = _ismastersim and function(spawn_point, override_prefab)
        local node_index = _world.Map:GetNodeIdAtPoint(spawn_point:Get())
    
        local prefab = override_prefab or GetDebris(_world.topology.nodes[node_index])
        if prefab ~= nil then
            local debris = SpawnPrefab(prefab)
            if debris ~= nil then
                debris.entity:SetCanSleep(false)
                debris.persists = false

                if debris.components.inventoryitem ~= nil and debris.components.inventoryitem.canbepickedup then
                    debris.components.inventoryitem.canbepickedup = false
                    debris._restorepickup = true
                end

                if math.random() < .5 then
                    debris.Transform:SetRotation(180)
                end

                local scale = 0.1 * math.random(8, 10)
                debris.Transform:SetScale(scale, scale, scale)

                debris.Physics:Teleport(spawn_point.x, 35, spawn_point.z)
    
                debris.shadow = SpawnPrefab("warningshadow")
                debris.shadow:ListenForEvent("onremove", OnRemoveDebris, debris)
                debris.shadow.Transform:SetPosition(spawn_point.x, 0, spawn_point.z)
                UpdateShadowSize(debris.shadow, 35)
    
                debris.updatetask = debris:DoPeriodicTask(FRAMES, _GroundDetectionUpdate)
                
                debris:PushEvent("startfalling")
            end
            return debris
        end
    end or nil

    local GetTimeForNextDebris = _ismastersim and function(pt)
        local num_players_near = TheSim:CountEntities(pt.x, pt.y, pt.z, TUNING.LUNARHAIL_DEBRIS_SPAWN_RADIUS, PLAYER_MUST_TAGS)

        -- Based on weather's CalculateLunarHailRate.
        local p = math.clamp(TheWorld.state.lunarhaillevel / 100, 0, 1)
        p = math.sin(p * PI)

        return Lerp(_scaleratemin * num_players_near, _scaleratemax * num_players_near, 1 - p)

    end or nil

    local IsPointProtected = _ismastersim and function(pt)
        local x, y, z = pt:Get()

        return
            TheSim:CountEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE, SHADECANOPY_MUST_TAGS) > 0 or
            TheSim:CountEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE_SMALL, SHADECANOPY_SMALL_MUST_TAGS) > 0 or
            IsUnderRainDomeAtXZ(x, z)
    end

    local GetSpawnPoint = _ismastersim and function(pt, rad, minrad)
        local theta = math.random() * TWOPI
        local radius = math.random() * (rad or TUNING.LUNARHAIL_DEBRIS_SPAWN_RADIUS)

        minrad = (minrad ~= nil and minrad > 0 and minrad * minrad) or nil

        local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
            return (minrad == nil) or (offset.x * offset.x + offset.z * offset.z) >= minrad
        end)

        return (result_offset ~= nil and pt + result_offset) or nil
    end or nil

    local DoDropForPlayer = _ismastersim and function(player, reschedulefn)
        local pt = player:GetPosition()

        local spawn_point = GetSpawnPoint(pt)
        if spawn_point ~= nil and not IsPointProtected(spawn_point) then
            SpawnDebris(spawn_point)
        end

        reschedulefn(player)
    end or nil

    local ScheduleDrop
    ScheduleDrop = _ismastersim and function(player)
        if _scheduleddrops[player] ~= nil then
            _scheduleddrops[player]:Cancel()
        end

        _scheduleddrops[player] = player:DoTaskInTime(GetTimeForNextDebris(player:GetPosition()), DoDropForPlayer, ScheduleDrop)
    end or nil
    
    local CancelDropForPlayer = _ismastersim and function(player)
        if _scheduleddrops[player] ~= nil then
            _scheduleddrops[player]:Cancel()
            _scheduleddrops[player] = nil
        end
    end or nil
    
    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------
    
    local OnPlayerJoined = _ismastersim and function(src, player)
        for i, v in ipairs(_activeplayers) do
            if v == player then
                return
            end
        end
        table.insert(_activeplayers, player)
        if _enabled then
            ScheduleDrop(player)
        end
    end or nil
    
    local OnPlayerLeft = _ismastersim and function(src, player)
        for i, v in ipairs(_activeplayers) do
            if v == player then
                CancelDropForPlayer(player)
                table.remove(_activeplayers, i)
                return
            end
        end
    end or nil

    local ToggleLunarHail = _ismastersim and function(self, active)
        _enabled = active

        if active then
            _originalplayers = {}
            for i, v in ipairs(_activeplayers) do
                ScheduleDrop(v)
        
                table.insert(_originalplayers, v)
            end
        else
            for i,v in pairs(_scheduleddrops) do
                v:Cancel()
            end
            _scheduleddrops = {}
        end
    end or nil

    --------------------------------------------------------------------------
    --[[ Public member functions ]]
    --------------------------------------------------------------------------

    function self:SetDebris(data)
        if not _ismastersim then return end
    
        _debris = data
    end
    
    function self:SetTagDebris(tile, data)
        if not _ismastersim then return end
    
        _tagdebris[tile] = data
    end
    
    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------
    
    --Register events
    if _ismastersim then
        inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, _world)
        inst:ListenForEvent("ms_playerleft", OnPlayerLeft, _world)

        self:WatchWorldState("islunarhailing", ToggleLunarHail)
        inst:DoTaskInTime(0, function() ToggleLunarHail(self, _world.state.islunarhailing) end)
    end

    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------
end)
