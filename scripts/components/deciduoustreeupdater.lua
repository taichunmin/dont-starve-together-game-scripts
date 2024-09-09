local DeciduousTreeUpdater = Class(function(self, inst)
    self.inst = inst

    self.monster = false
    self.monster_target = nil
    self.last_monster_target = nil
    self.last_attack_time = 0
    self.root = nil

    self.starttask = nil
    self.drakespawntask = nil
    self.ignitedrakespawntask = nil
    self.sleeptask = nil
end)

local function OnStartTask(inst, self)
    self.starttask = nil
    inst:StartUpdatingComponent(self)
end

function DeciduousTreeUpdater:StartMonster(starttime)
    if not self.monster then
        self.monster = true
        self.time_to_passive_drake = 1
        self.num_passive_drakes = 0
        self.inst.monster_start_time = starttime or GetTime()
        self.inst.monster_duration = GetRandomWithVariance(TUNING.DECID_MONSTER_DURATION, .33 * TUNING.DECID_MONSTER_DURATION)
        self.monsterFreq = .5 + math.random()
        self.monsterTime = self.monsterFreq
        self.inst:AddTag("monster")
        self.spawneddrakes = false
        if self.starttask ~= nil then
            self.starttask:Cancel()
        end
        self.starttask = self.inst:DoTaskInTime(19 * FRAMES, OnStartTask, self)
    end
end

function DeciduousTreeUpdater:StopMonster()
    self.monster = false
    self.monster_target = nil
    self.last_monster_target = nil
    self.inst:RemoveTag("monster")
    if self.starttask ~= nil then
        self.starttask:Cancel()
        self.starttask = nil
    end
    if self.drakespawntask ~= nil then
        self.drakespawntask:Cancel()
        self.drakespawntask = nil
    end
    if self.ignitedrakespawntask ~= nil then
        self.ignitedrakespawntask:Cancel()
        self.ignitedrakespawntask = nil
    end
    if self.inst.monster_stop_task ~= nil then
        self.inst.monster_stop_task:Cancel()
        self.inst.monster_stop_task = nil
    end
    if self.sleeptask ~= nil then
        self.sleeptask:Cancel()
        self.sleeptask = nil
    end
    self.inst:StopUpdatingComponent(self)
end

DeciduousTreeUpdater.OnRemoveFromEntity = DeciduousTreeUpdater.StopMonster

function DeciduousTreeUpdater:OnEntityWake()
    if self.sleeptask ~= nil then
        self.sleeptask:Cancel()
        self.sleeptask = nil
    else
        self:StartMonster()
    end
end

local function OnSleepTask(inst, self)
    self.sleeptask = nil
    self:StopMonster()
end

function DeciduousTreeUpdater:OnEntitySleep()
    if self.sleeptask == nil then
        self.sleeptask = self.inst:DoTaskInTime(1, OnSleepTask, self)
    end
end

local prefabs =
{
    "green_leaves",
    "red_leaves",
    "orange_leaves",
    "yellow_leaves",
    "deciduous_root",
    "birchnutdrake",
}

local builds =
{
    normal = { --Green
        leavesbuild="tree_leaf_green_build",
        fx="green_leaves",
        chopfx="green_leaves_chop",
    },
    barren = {
        leavesbuild=nil,
        fx=nil,
        chopfx=nil,
    },
    red = {
        leavesbuild="tree_leaf_red_build",
        fx="red_leaves",
        chopfx="red_leaves_chop",
    },
    orange = {
        leavesbuild="tree_leaf_orange_build",
        fx="orange_leaves",
        chopfx="orange_leaves_chop",
    },
    yellow = {
        leavesbuild="tree_leaf_yellow_build",
        fx="yellow_leaves",
        chopfx="yellow_leaves_chop",
    },
    poison = {
        leavesbuild="tree_leaf_poison_build",
        fx=nil,
        chopfx=nil,
    },
}

local function GetBuild(inst)
    return builds[inst.build] or builds.normal
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function OnStopMonster(inst)
    inst.monster_stop_task = nil
    inst:StopMonster()
end

local DRAKESPAWNTARGET_MUST_TAGS = { "_combat" } --see entityreplica.lua
local DRAKESPAWNTARGET_CANT_TAGS = { "flying", "birchnutdrake", "wall" }
local function OnPassDrakeSpawned(passdrake)
    if passdrake.components.combat ~= nil then
        local target = FindEntity(
                passdrake,
                TUNING.DECID_MONSTER_TARGET_DIST * 4,
                function(guy)
                    return passdrake.components.combat:CanTarget(guy)
                end,
                DRAKESPAWNTARGET_MUST_TAGS,
                DRAKESPAWNTARGET_CANT_TAGS
            )
        if target ~= nil then
            passdrake.components.combat:SuggestTarget(target)
        end
    end
end

local function OnDrakeSpawned(drake)
    if drake.components.combat ~= nil then
        drake.components.combat:SuggestTarget(drake.target or FindClosestPlayerToInst(drake, 30, true))
    end
end

local function OnDrakeSpawnTask(inst, self, pos, sectorsize)
    if self.numdrakes > 0 then
        local drake = SpawnPrefab("birchnutdrake")
        local minang = sectorsize * (self.numdrakes - 1) >= 0 and sectorsize * (self.numdrakes - 1) or 0
        local maxang = sectorsize * self.numdrakes <= 360 and sectorsize * self.numdrakes or 360
        local offset = FindWalkableOffset(pos, math.random(minang, maxang) * DEGREES, GetRandomMinMax(2, TUNING.DECID_MONSTER_TARGET_DIST), 30, false, false, NoHoles)
        if offset ~= nil then
            drake.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
        else
            drake.Transform:SetPosition(pos:Get())
        end
        drake.target = self.monster_target or self.last_monster_target
        drake:DoTaskInTime(0, OnDrakeSpawned)
        self.numdrakes = self.numdrakes - 1
    else
        self.drakespawntask:Cancel()
        self.drakespawntask = nil
    end
end

function DeciduousTreeUpdater:OnUpdate(dt)
    if self.monster and self.inst.monster_start_time and ((GetTime() - self.inst.monster_start_time) > self.inst.monster_duration) then
        self.monster = false
        if self.inst.monster_start_task ~= nil then
            self.inst.monster_start_task:Cancel()
            self.inst.monster_start_task = nil
        end
        if self.inst.monster and
            not (self.inst.components.burnable ~= nil and
                self.inst.components.burnable:IsBurning()) and
            not self.inst:HasTag("stump") and
            not self.inst:HasTag("burnt") then
            if self.inst.monster_stop_task == nil then
                self.inst.monster_stop_task = self.inst:DoTaskInTime(math.random(0, 2), OnStopMonster)
            end
        end
        return
    end

    if self.monster then
        -- We want to spawn drakes at some interval
        if self.time_to_passive_drake <= 0 then
            if self.num_passive_drakes <= 0 then
                self.num_passive_drakes = math.random() < .33 and TUNING.PASSIVE_DRAKE_SPAWN_NUM_LARGE or TUNING.PASSIVE_DRAKE_SPAWN_NUM_NORMAL
                self.passive_drakes_spawned = 0
            elseif self.passive_drakes_spawned < self.num_passive_drakes then
                local passdrake = SpawnPrefab("birchnutdrake")
                local pos = self.inst:GetPosition()
                local passoffset = FindWalkableOffset(pos, math.random() * TWOPI, GetRandomMinMax(2, TUNING.DECID_MONSTER_TARGET_DIST * 1.5), 30, false, false, NoHoles)
                if passoffset ~= nil then
                    passdrake.Transform:SetPosition(pos.x + passoffset.x, 0, pos.z + passoffset.z)
                else
                    passdrake.Transform:SetPosition(pos:Get())
                end
                passdrake.range = TUNING.DECID_MONSTER_TARGET_DIST * 4
                passdrake:DoTaskInTime(0, OnPassDrakeSpawned)
                self.passive_drakes_spawned = self.passive_drakes_spawned + 1
            else
                self.num_passive_drakes = 0
                self.time_to_passive_drake = GetRandomWithVariance(TUNING.PASSIVE_DRAKE_SPAWN_INTERVAL,TUNING.PASSIVE_DRAKE_SPAWN_INTERVAL_VARIANCE)
            end
        else
            self.time_to_passive_drake = self.time_to_passive_drake - dt
        end

        -- We only want to do the thinking for roots and proximity-drakes so often
        if self.monsterTime > 0 then
            self.monsterTime = self.monsterTime - dt
        else
            local targdist = TUNING.DECID_MONSTER_TARGET_DIST
            -- Look for nearby targets (anything not flying, a wall or a drake)
            self.monster_target =
                self.inst.components.combat ~= nil and
                FindEntity(
                    self.inst,
                    targdist * 1.5,
                    function(guy)
                        return self.inst.components.combat:CanTarget(guy)
                    end,
                    DRAKESPAWNTARGET_MUST_TAGS, --see entityreplica.lua
                    DRAKESPAWNTARGET_CANT_TAGS
                ) or nil

            if self.monster_target ~= nil and self.last_monster_target ~= nil and GetTime() - self.last_attack_time > TUNING.DECID_MONSTER_ATTACK_PERIOD then
                -- Spawn a root spike and give it a target
                self.last_attack_time = GetTime()
                self.root = SpawnPrefab("deciduous_root")
                local x, y, z = self.inst.Transform:GetWorldPosition()
                local mx, my, mz = self.monster_target.Transform:GetWorldPosition()
                local mdistsq = distsq(x, z, mx, mz)
                local targdistsq = targdist * targdist
                local rootpos = Vector3(mx, 0, mz)
                local angle = self.inst:GetAngleToPoint(rootpos) * DEGREES
                if mdistsq > targdistsq then
                    rootpos.x = x + math.cos(angle) * targdist
                    rootpos.z = z - math.sin(angle) * targdist
                end

                self.root.Transform:SetPosition(x + 1.75 * math.cos(angle), 0, z - 1.75 * math.sin(angle))
                self.root:PushEvent("givetarget", { target = self.monster_target, targetpos = rootpos, targetangle = angle, owner = self.inst })

                -- If we haven't spawned drakes yet and the player is close enough, spawn drakes
                if not self.spawneddrakes and mdistsq < targdistsq * .25 then
                    self.spawneddrakes = true
                    self.time_to_passive_drake = GetRandomWithVariance(TUNING.PASSIVE_DRAKE_SPAWN_INTERVAL,TUNING.PASSIVE_DRAKE_SPAWN_INTERVAL_VARIANCE)
                    self.numdrakes = math.random(TUNING.MIN_TREE_DRAKES, TUNING.MAX_TREE_DRAKES)
                    if self.drakespawntask ~= nil then
                        self.drakespawntask:Cancel()
                    end
                    self.drakespawntask = self.numdrakes > 0 and self.inst:DoPeriodicTask(6 * FRAMES, OnDrakeSpawnTask, nil, self, Vector3(x, y, z), 360 / self.numdrakes) or nil
                end
            end

            if self.monster_target ~= nil and self.last_monster_target == nil and not self.inst.sg:HasStateTag("burning") then
                self.inst:PushEvent("sway", {monster=true, monsterpost=nil})
            elseif self.monster_target == nil and self.last_monster_target ~= nil and not self.inst.sg:HasStateTag("burning") then
                self.inst:PushEvent("sway", {monster=nil, monsterpost=true})
            end
            self.last_monster_target = self.monster_target
            self.monsterTime = self.monsterFreq
        end
    end
end

local function OnIgniteDrakeSpawnTask(inst, self, pos, sectorsize)
    if self.ignitenumdrakes > 0 then
        local drake = SpawnPrefab("birchnutdrake")
        local minang = sectorsize * (self.ignitenumdrakes - 1) >= 0 and sectorsize * (self.ignitenumdrakes - 1) or 0
        local maxang = sectorsize * self.ignitenumdrakes <= 360 and sectorsize * self.ignitenumdrakes or 360
        local offset = FindWalkableOffset(pos, math.random(minang, maxang) * DEGREES, GetRandomMinMax(2, TUNING.DECID_MONSTER_TARGET_DIST), 30, false, false, NoHoles)
        if offset ~= nil then
            drake.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
        else
            drake.Transform:SetPosition(pos:Get())
        end
        drake.target = self.monster_target or self.last_monster_target
        drake:DoTaskInTime(0, OnDrakeSpawned)
        self.ignitenumdrakes = self.ignitenumdrakes - 1
    else
        self.ignitedrakespawntask:Cancel()
        self.ignitedrakespawntask = nil
    end
end

function DeciduousTreeUpdater:SpawnIgniteWave()
    if self.monster then
        self.ignitenumdrakes = math.random(TUNING.MIN_TREE_DRAKES, TUNING.MAX_TREE_DRAKES)
        if self.ignitedrakespawntask ~= nil then
            self.ignitedrakespawntask:Cancel()
        end
        self.ignitedrakespawntask = self.ignitenumdrakes > 0 and self.inst:DoPeriodicTask(6 * FRAMES, OnIgniteDrakeSpawnTask, nil, self, self.inst:GetPosition(), 360 / self.ignitenumdrakes) or nil
    end
end

return DeciduousTreeUpdater
