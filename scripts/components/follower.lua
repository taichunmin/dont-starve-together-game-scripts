local function onattacked(inst, data)
    if inst.components.follower.leader == data.attacker then
        inst.components.follower:SetLeader(nil)
    end
end

local function onleader(self, leader)
    self.inst.replica.follower:SetLeader(leader)
end

--both of these are defined lower in the file where it makes more sense.
local OnPlayerJoined
local OnNewPlayerSpawned

local Follower = Class(function(self, inst)
    self.inst = inst

    self.leader = nil
    self.targettime = nil
    self.maxfollowtime = nil
    self.canaccepttarget = true
    --self.keepdeadleader = nil
    --self.keepleaderonattacked = nil
	--self.noleashing = nil

    self.inst:ListenForEvent("attacked", onattacked)
    self.OnLeaderRemoved = function()
        self:SetLeader(nil)
    end
    
    self.cached_player_join_fn = function(world, player) OnPlayerJoined(self, player) end
    self.cached_new_player_spawned_fn = function(world, player) OnNewPlayerSpawned(self, player) end
end,
nil,
{
    leader = onleader,
})

function Follower:GetDebugString()
    local str = "Following "..tostring(self.leader)
    if self.targettime ~= nil then
        str = str..string.format(" Stop in %2.2fs, %2.2f%%", self.targettime - GetTime(), 100 * self:GetLoyaltyPercent())
    end
    return str
end

function Follower:GetLeader()
    return self.leader
end

local function DoPortNearLeader(inst, pos)
    if inst.Physics ~= nil then
        inst.Physics:Teleport(pos:Get())
    else
        inst.Transform:SetPosition(pos:Get())
    end
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function TryPorting(inst, self)
	self.porttask = nil

    if inst.components.hitchable and not inst.components.hitchable.canbehitched then
        return
    end

    if self.leader == nil or self.leader:IsAsleep() or not inst:IsAsleep() then
        return
    end

    if self.leader.components.inventoryitem ~= nil then
        local owner = self.leader.components.inventoryitem:GetGrandOwner()
        if owner ~= nil and owner:HasTag("pocketdimension_container") then
            return
        end
    end

    local init_pos = inst:GetPosition()
    local leader_pos = self.leader:GetPosition()

    if distsq(leader_pos, init_pos) > 1600 then
        if inst.components.combat ~= nil then
            inst.components.combat:SetTarget(nil)
        end

        local allow_land = true
        local allow_ocean = false
        if inst.components.locomotor ~= nil then
            allow_land = inst.components.locomotor:CanPathfindOnLand()
            allow_ocean = inst.components.locomotor:CanPathfindOnWater()
        end

        local angle = self.leader:GetAngleToPoint(init_pos) * DEGREES
        if allow_ocean then
            local offset = FindSwimmableOffset(leader_pos, angle, 30, 10, false, true, NoHoles, false)
            if offset ~= nil then
                leader_pos.x = leader_pos.x + offset.x
                leader_pos.z = leader_pos.z + offset.z
            end
            leader_pos.y = 0

            if TheWorld.Map:IsOceanAtPoint(leader_pos:Get()) then
				DoPortNearLeader(inst, leader_pos)
				return --successfully teleported, so early out
            end
        end

        if allow_land then
            local offset = FindWalkableOffset(leader_pos, angle, 30, 10, false, true, NoHoles)
            if offset ~= nil then
                leader_pos.x = leader_pos.x + offset.x
                leader_pos.z = leader_pos.z + offset.z
            end
            leader_pos.y = 0

            -- We don't want to teleport onto boats because it'll probably be on top of the player,
            -- so include boats in the ocean test we're negating.
            if not TheWorld.Map:IsOceanAtPoint(leader_pos.x, leader_pos.y, leader_pos.z, true) then
				DoPortNearLeader(inst, leader_pos)
				return --successfully teleported, so early out
            end
        end
    end

	--Retry later
	self.porttask = inst:DoTaskInTime(3, TryPorting, self)
end

local function OnEntitySleep(inst)
	local self = inst.components.follower
	if self.porttask ~= nil then
		self.porttask:Cancel()
	end
	self.porttask = self.inst:DoTaskInTime(0, TryPorting, self)
end

function Follower:StartLeashing()
	if self.noleashing then
		return
	elseif self._onleaderwake == nil and self.leader ~= nil then
        self._onleaderwake = function() OnEntitySleep(self.inst) end
        self.inst:ListenForEvent("entitywake", self._onleaderwake, self.leader)
        self.inst:ListenForEvent("entitysleep", OnEntitySleep)
    end

    self.inst:PushEvent("startleashing")
end

function Follower:StopLeashing()
    if self._onleaderwake ~= nil then
        self.inst:RemoveEventCallback("entitysleep", OnEntitySleep)
        self.inst:RemoveEventCallback("entitywake", self._onleaderwake, self.leader)
        self._onleaderwake = nil
        if self.porttask ~= nil then
            self.porttask:Cancel()
            self.porttask = nil
        end
    end

	if not self.noleashing then
		self.inst:PushEvent("stopleashing")
	end
end

OnPlayerJoined = function(self, player)
    if self.cached_player_leader_userid == player.userid then
        local current_time = GetTime()
        local cached_player_leader_timeleft = self.cached_player_leader_timeleft
        if self.inst:GetDistanceSqToInst(player) <= TUNING.FOLLOWER_REFOLLOW_DIST_SQ and
        (not cached_player_leader_timeleft or cached_player_leader_timeleft > current_time) then

            if player.components.leader then
                player.components.leader:AddFollower(self.inst)
            else
                self:SetLeader(player)
            end

            self.targettime = nil
            if cached_player_leader_timeleft then
                self:AddLoyaltyTime(cached_player_leader_timeleft - current_time)
            end
        else
            self:ClearCachedPlayerLeader()
        end
    end
end

OnNewPlayerSpawned = function(self, player)
    if self.cached_player_leader_userid == player.userid then
        self:ClearCachedPlayerLeader()
    end
end

local function clear_cached_player_leader(inst, self)
    self:ClearCachedPlayerLeader()
end

function Follower:CachePlayerLeader(userid, timeleft)
    if userid or (self.leader and self.leader:HasTag("player") and self.leader.userid) then
        self.cached_player_leader_userid = userid or self.leader.userid

        if timeleft or self.targettime then
            local current_time = GetTime()
            self.cached_player_leader_timeleft = current_time + (timeleft or math.max(0, self.targettime - current_time))

            if self.cached_player_leader_task then
                self.cached_player_leader_task:Cancel()
                self.cached_player_leader_task = nil
            end
            self.cached_player_leader_task = self.inst:DoTaskInTime(self.cached_player_leader_timeleft - current_time, clear_cached_player_leader, self)
        end

        self.inst:ListenForEvent("ms_playerjoined", self.cached_player_join_fn, TheWorld)
        self.inst:ListenForEvent("ms_newplayerspawned", self.cached_new_player_spawned_fn, TheWorld)
    end
end

function Follower:ClearCachedPlayerLeader()
    --moved outside the if block so that the event will always get cleared even if the cached_player_leader_userid is nil
    self.inst:RemoveEventCallback("ms_newplayerspawned", self.cached_new_player_spawned_fn, TheWorld)
    self.inst:RemoveEventCallback("ms_playerjoined", self.cached_player_join_fn, TheWorld)

    if self.cached_player_leader_userid then
        if self.cached_player_leader_task then
            self.cached_player_leader_task:Cancel()
            self.cached_player_leader_task = nil
        end

        self.cached_player_leader_timeleft = nil

        self.cached_player_leader_userid = nil
    end
end

function Follower:SetLeader(new_leader)
	local prev_leader = self.leader
	local changed_leader = prev_leader ~= new_leader

    if prev_leader and changed_leader then
        local leader = self.leader.components.leader
        if leader then
            leader:RemoveFollower(self.inst)
        end

        self:StopLeashing()

        self.inst:RemoveEventCallback("onremove", self.OnLeaderRemoved, prev_leader)

        self:CancelLoyaltyTask()

        self.leader = nil
    end

    if new_leader and self.leader ~= new_leader then
        self:ClearCachedPlayerLeader()

        self.leader = new_leader

        local leader = new_leader.components.leader
        if leader then
            leader:AddFollower(self.inst)
        end

        self.inst:ListenForEvent("onremove", self.OnLeaderRemoved, new_leader)

        if new_leader:HasTag("player") or new_leader.components.inventoryitem ~= nil then
            --Special case for pets leashed to players or inventory items
            self:StartLeashing()
        end
    end

	if changed_leader and self.OnChangedLeader ~= nil then
		self.OnChangedLeader(self.inst, new_leader, prev_leader)
	end
end

function Follower:GetLoyaltyPercent()
    if self.targettime ~= nil and self.maxfollowtime ~= nil then
        local timeLeft = math.max(0, self.targettime - GetTime())
        return timeLeft / self.maxfollowtime
    end
    return 0
end

local function stopfollow(inst, self)
    self:StopFollowing()
end

function Follower:AddLoyaltyTime(time)
    if self.neverexpire then
        return
    end

    local leader = self.leader and self.leader.components.leader
    if leader and leader.loyaltyeffectiveness then
		time = time * leader.loyaltyeffectiveness
	end

    local current_time = GetTime()
    if self.targettime then
        self.targettime = math.clamp(math.max(current_time, self.targettime) + time, current_time, current_time + (self.maxfollowtime or 0))
    else
        self.targettime = current_time + math.clamp(time, 0, self.maxfollowtime or 0)
    end

    self.inst:PushEvent("gainloyalty", { leader = self.leader })

    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    self.task = self.inst:DoTaskInTime(self.targettime - current_time, stopfollow, self)
end

function Follower:CancelLoyaltyTask()
    self.targettime = nil
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function Follower:StopFollowing()
    
    if self.neverexpire then
        return
    end

    if self.inst:IsValid() then
        self.targettime = nil
        self.inst:PushEvent("loseloyalty", { leader = self.leader })
        self:SetLeader(nil)
    end
end

function Follower:IsNearLeader(dist)
    return self.leader ~= nil and self.inst:IsNear(self.leader, dist)
end

function Follower:OnSave()
    local data = {}

    local time = GetTime()
    if self.targettime and self.targettime > time then
        data.time = math.floor(self.targettime - time)
    end

    if self.cached_player_leader_userid then
        data.cached_player_leader_userid = self.cached_player_leader_userid

        if self.cached_player_leader_timeleft and self.cached_player_leader_timeleft > time then
            data.cached_player_leader_timeleft = math.floor(self.cached_player_leader_timeleft - time)
        end
    elseif self.leader and self.leader:HasTag("player") and self.leader.userid then
        data.cached_player_leader_userid = self.leader.userid
        data.cached_player_leader_timeleft = data.time
    end

    return not IsTableEmpty(data) and data or nil
end

function Follower:OnLoad(data)
    if data.time ~= nil then
        self:AddLoyaltyTime(data.time)
    end

    if data.cached_player_leader_userid then
        self:CachePlayerLeader(data.cached_player_leader_userid, data.cached_player_leader_timeleft)
    end
end

function Follower:IsLeaderSame(otherfollower)
    if self.leader == nil then
        return false
    end
    local othercmp = otherfollower.components.follower
    if othercmp == nil or othercmp.leader == nil then
        return false
    end
    --Special case for pets leashed to inventory items
    return (self.leader.components.inventoryitem ~= nil and self.leader.components.inventoryitem:GetGrandOwner() or self.leader)
        == (othercmp.leader.components.inventoryitem ~= nil and othercmp.leader.components.inventoryitem:GetGrandOwner() or othercmp.leader)
end

function Follower:KeepLeaderOnAttacked()
	if not self.keepleaderonattacked then
		self.keepleaderonattacked = true
		self.inst:RemoveEventCallback("attacked", onattacked)
	end
end

function Follower:LoseLeaderOnAttacked()
	if self.keepleaderonattacked then
		self.keepleaderonattacked = nil
		self.inst:ListenForEvent("attacked", onattacked)
	end
end

function Follower:LongUpdate(dt)
    if self.leader ~= nil and self.task ~= nil and self.targettime ~= nil then
        self.task:Cancel()
        self.task = nil

        local time_left = self.targettime - GetTime() - dt
        if time_left < 0 then
            self:SetLeader(nil)
        else
            self.targettime = GetTime() + time_left
            self.task = self.inst:DoTaskInTime(time_left, stopfollow, self)
        end
    end

    if self.cached_player_leader_task and self.cached_player_leader_timeleft then
        self.cached_player_leader_task:Cancel()
        self.cached_player_leader_task = nil

        local time_left = self.cached_player_leader_timeleft - GetTime() - dt
        if time_left < 0 then
            self:ClearCachedPlayerLeader()
        else
            self.cached_player_leader_timeleft = GetTime() + time_left
            self.cached_player_leader_task = self.inst:DoTaskInTime(time_left, clear_cached_player_leader, self)
        end
    end
end

function Follower:OnRemoveFromEntity()
    self:StopLeashing()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    if self.cached_player_leader_task then
        self.cached_player_leader_task:Cancel()
        self.cached_player_leader_task = nil
    end
    self.inst:RemoveEventCallback("attacked", onattacked)
    self.inst:RemoveEventCallback("ms_newplayerspawned", self.cached_new_player_spawned_fn, TheWorld)
    self.inst:RemoveEventCallback("ms_playerjoined", self.cached_player_join_fn, TheWorld)
    if self.leader ~= nil then
        self.inst:RemoveEventCallback("onremove", self.OnLeaderRemoved, self.leader)
    end
end

return Follower