local song_defs = require("prefabs/battlesongdefs").song_defs

local function on_current(self, current)
	local percent = math.ceil(100 * current / self.max) -- convert it to a percent between 0 and 100

    if self.inst.player_classified ~= nil then
        assert(percent >= 0 and percent <= 255, "Player currentinspiration out of range: "..tostring(percent))
        self.inst.player_classified.currentinspiration:set(percent)
    end
end

local function on_is_draining(self, is_draining)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.inspirationdraining:set(is_draining)
    end
end

local SingingInspiration = Class(function(self, inst)
    self.inst = inst
    self.max = TUNING.INSPIRATION_MAX
    self.current = 0
    self.active_songs = {}

    self.attach_radius = TUNING.BATTLESONG_ATTACH_RADIUS
    self.detach_radius = TUNING.BATTLESONG_DETACH_RADIUS

    self.available_slots = 0

    self.is_draining = false

    self.max_enemy_health = 5000
    self.inspiration_gain_bonus = 750

    self.inst:ListenForEvent("onhitother", function(inst, data) self:OnHitOther(data)   end)
    self.inst:ListenForEvent("attacked",   function(inst, data) self:OnAttacked(data) end)

    self.inst:ListenForEvent("death", function() self:SetInspiration(0) end)
end,
nil,
{
    current = on_current,
    is_draining = on_is_draining,
})

------------------------------------------------------------------
-- Getters and setters

function SingingInspiration:SetCalcAvailableSlotsForInspirationFn(fn)
    self.CalcAvailableSlotsForInspirationFn = fn
end

function SingingInspiration:SetMaxInspiration(max)
    self.max = max
end

function SingingInspiration:GetMaxInspiration()
    return self.max or 0
end

function SingingInspiration:SetInspiration(value)
    self.current = value
    self.last_attack_time = GetTime()
    self:DoDelta(0, true)
end

function SingingInspiration:GetPercent()
    return self.current / self.max
end

function SingingInspiration:SetPercent(percent)
    self.current = percent * self.max
    self.last_attack_time = GetTime()
    self:DoDelta(0, true)
end

function SingingInspiration:GetDetachRadius()
    return self.detach_radius
end

function SingingInspiration:IsSongActive(songdata)
    for i,song in ipairs(self.active_songs) do
        if song.NAME == songdata.NAME then
            return true
        end
    end

    return false
end

function SingingInspiration:GetActiveSong(slot_num)
    return self.active_songs[slot_num]
end

function SingingInspiration:IsSinging()
    return #self.active_songs > 0
end

------------------------------------------------------------------

function SingingInspiration:OnAttacked(data)
    self.is_draining = false
    self.last_attack_time = GetTime()

    if data.attacker and data.damageresolved then
        local delta = (data.damageresolved * TUNING.INSPIRATION_GAIN_RATE) * (1 - self:GetPercent())
        self:DoDelta(delta)
    end
end

function SingingInspiration:OnHitOther(data)
    local target = data.target
    if target ~= nil and target:IsValid() and target.components.health and (self.validvictimfn == nil or self.validvictimfn(target)) then
        self.is_draining = false
        self.last_attack_time = GetTime()

        local player_damage = math.max(data.damageresolved or data.damage or 1, 1)
        local delta = (player_damage * TUNING.INSPIRATION_GAIN_RATE) * (1 - self:GetPercent())

        if target:HasTag("epic") then
            delta = delta * TUNING.INSPIRATION_GAIN_EPIC_BONUS --3
        end

        self:DoDelta(delta)
    end
end

function SingingInspiration:DoDelta(delta, forceupdate)
	local prev = self.current
    self.current = math.min(math.max(self.current + delta, 0), self.max)

    local newpercent = self:GetPercent()
    local old_slots_available = self.available_slots
    self.available_slots = self.CalcAvailableSlotsForInspirationFn(self.inst, newpercent)

    self.inst:PushEvent("inspirationdelta", { newpercent = newpercent, slots_available = self.available_slots })

	--print("slots_available", self.available_slots, old_slots_available)
	if self.available_slots ~= old_slots_available then
        for i = #self.active_songs, self.available_slots + 1, -1 do
            self:PopSong()
        end
	end

    if (prev <= 0 and self.current > 0) or forceupdate then
       self.inst:StartUpdatingComponent(self)
    elseif self.current <= 0 and prev > 0 then
       self.inst:StopUpdatingComponent(self)
    end
end

function SingingInspiration:CanAddSong(songdata)
	return songdata.INSTANT and (self.current >= songdata.DELTA) or (#self.active_songs < self.available_slots)
end

function SingingInspiration:DisplayFx()

    if self.display_fx_count == nil or self.display_fx_count > #self.active_songs then
        self.display_fx_count = 1
    end

    if #self.active_songs == 0 then
        self.display_fx_task:Cancel()
        self.display_fx_task = nil
        self.display_fx_count = 1
        return
    end

    local songdata = self.active_songs[self.display_fx_count]
    if songdata.LOOP_FX then
        local fx = SpawnPrefab(songdata.LOOP_FX)

        if fx then
            fx.Transform:SetNoFaced()

            local xOffset = math.random(-1, 1) * (math.random()/2)
            local yOffset = 1.2 + math.random()/5
            local zOffset = math.random(-1, 1) * (math.random()/2)

            if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then
                yOffset = yOffset + 2.3
                xOffset = xOffset + 0.5
                zOffset = zOffset + 0.5
            end

            self.inst:AddChild(fx)
            fx.Transform:SetPosition(xOffset, yOffset, zOffset)

            fx.Transform:SetScale(0.4, 0.4, 0.4)
        end
    end

    self.display_fx_count = self.display_fx_count + 1
    local next_display_time = 0.4 + math.random()/2

    if self.display_fx_count > #self.active_songs then
        self.display_fx_count = 1
        next_display_time = 4
    end

    self.display_fx_task = self.inst:DoTaskInTime(next_display_time, function() self:DisplayFx() end)
end

function SingingInspiration:AddSong(songdata, skip_inspire)
    if self:CanAddSong(songdata) then
        if songdata.INSTANT then
            self:DoDelta(-songdata.DELTA)
            self:InstantInspire(songdata)
        else
            table.insert(self.active_songs, songdata)
			local slot = #self.active_songs

            if not skip_inspire then
                self:Inspire()
            end

			if self.inspire_refresh_task == nil then
				self.inspire_refresh_task = self.inst:DoPeriodicTask(TUNING.SONG_REAPPLY_PERIOD, function() self:Inspire() end)
			end

            if self.display_fx_task == nil then
                self.display_fx_task = self.inst:DoTaskInTime(4, function() self:DisplayFx()end)
            end

			if self.inst.player_classified ~= nil and slot <= #self.inst.player_classified.inspirationsongs then
				self.inst.player_classified.inspirationsongs[slot]:set(songdata.battlesong_netid)
			end
            self.inst:PushEvent("inspirationsongchanged", {songdata = songdata, slotnum = slot})
        end
    end
end

function SingingInspiration:PopSong()
	local slot = #self.active_songs
	local song = self.active_songs[slot]
	if song ~= nil then
		table.remove(self.active_songs)

		if #self.active_songs == 0 then
            if self.inspire_refresh_task ~= nil then
    			self.inspire_refresh_task:Cancel()
    			self.inspire_refresh_task = nil
            end

            if self.display_fx_task ~= nil then
                self.display_fx_task:Cancel()
                self.display_fx_task = nil
                self.display_fx_count = nil
            end
		end

		self.inst:PushEvent("inspirationsongchanged", {slotnum = slot})
		if self.inst.player_classified ~= nil and slot <= #self.inst.player_classified.inspirationsongs then
			self.inst.player_classified.inspirationsongs[slot]:set(0)
		end
	end
end

local function checkifitemisleader(item)
	return item.components.leader ~= nil
end

function SingingInspiration:FindFriendlyTargetsToInspire()
	-- if not pvp then collect all the players near by, including yourself. If pvp then only yourself is enough
    local x, y, z = self.inst.Transform:GetWorldPosition()
	local all_targets = not TheNet:GetPVPEnabled() and FindPlayersInRange(x, y, z, self.attach_radius, true) or { self.inst }

	for i = 1, #all_targets do -- this is done this way so that we don't keep iterating over the appeneded followers
		local player = all_targets[i]
		-- collect all the companions that are following each player
		if player.components.leader ~= nil then
			for follower, _ in pairs(player.components.leader.followers) do
				if not follower:HasTag("critter")
					and (follower.components.health == nil or not follower.components.health:IsDead())
					and (follower.components.combat == nil or follower.components.combat.target ~= self.inst)
					and follower:GetDistanceSqToPoint(x, y, z) <= self.attach_radius*self.attach_radius
					then
					table.insert(all_targets, follower)
				end
			end
		end

		-- collect all creatures following an item the player has in their inventoryitem
		local leader_items = player.components.inventory and player.components.inventory:FindItems(checkifitemisleader) or {}
		for j = 1, #leader_items do
			for follower, _ in pairs(leader_items[j].components.leader.followers) do
				if not follower:HasTag("critter")
					and (follower.components.health == nil or not follower.components.health:IsDead())
					and (follower.components.combat == nil or follower.components.combat.target ~= self.inst)
					and follower:GetDistanceSqToPoint(x, y, z) <= self.attach_radius*self.attach_radius
					then
					table.insert(all_targets, follower)
				end
			end
		end

		-- add any other per-player searching here
	end

	return all_targets
end

local function HasFriendlyLeader(target, singer, PVP_enabled)
    local target_leader = (target.components.follower ~= nil) and target.components.follower.leader or nil

    if target_leader and target_leader.components.inventoryitem then
        target_leader = target_leader.components.inventoryitem:GetGrandOwner()
        -- Don't attack followers if their follow object has no owner, unless its pvp, then there are no rules!
        if target_leader == nil then
            return not PVP_enabled
        end
    end

    return  (target_leader ~= nil and (target_leader == singer or (not PVP_enabled and target_leader:HasTag("player"))))
			or (not PVP_enabled and target.components.domesticatable and target.components.domesticatable:IsDomesticated())
			or (not PVP_enabled and target.components.saltlicker and target.components.saltlicker.salted)
end

local INSTANT_TARGET_MUST_HAVE_TAGS = {"_combat", "_health"}
local INSTANT_TARGET_CANTHAVE_TAGS = { "INLIMBO", "epic", "structure", "butterfly", "wall", "balloon", "groundspike", "smashable", "companion"}

function SingingInspiration:InstantInspire(songdata)
    local PVP_enabled = TheNet:GetPVPEnabled()

	local fn = songdata.ONINSTANT
	if fn ~= nil then
		local x, y, z = self.inst.Transform:GetWorldPosition()
		local entities_near_me = TheSim:FindEntities(x, y, z, self.attach_radius, INSTANT_TARGET_MUST_HAVE_TAGS, INSTANT_TARGET_CANTHAVE_TAGS)
		for _, ent in ipairs(entities_near_me) do
			if self.inst.components.combat:CanTarget(ent)
				and not HasFriendlyLeader(ent, self.inst, PVP_enabled)
				and (not ent:HasTag("prey") or (ent:HasTag("prey") and ent:HasTag("hostile")))
				then

				fn(self.inst, ent)
			end
		end
	end
end

function SingingInspiration:Inspire()
    local targets = self:FindFriendlyTargetsToInspire()
    for _, target in ipairs(targets) do
        for _, song in ipairs(self.active_songs) do
            target:AddDebuff(song.NAME, song.NAME)
        end
    end
end

function SingingInspiration:SetValidVictimFn(fn)
    self.validvictimfn = fn
end

function SingingInspiration:OnUpdate(dt)
    local current_time = GetTime()

    if self.last_attack_time ~= nil and (current_time - self.last_attack_time >= TUNING.INSPIRATION_DRAIN_BUFFER_TIME) then
        self.is_draining = true
        self:DoDelta(TUNING.INSPIRATION_DRAIN_RATE * dt)
    else
        self.is_draining = false
    end
end

function SingingInspiration:OnSave()
    local data = {}

    data.current = self.current

    if #self.active_songs > 0 then
        data.active_songs = {}
        for i,song in ipairs(self.active_songs) do
            table.insert(data.active_songs, song.ITEM_NAME)
        end
    end

    return data
end

function SingingInspiration:OnLoad(data)
	self:SetInspiration(data.current or 0)

    if data.active_songs then
		for i,song in ipairs(data.active_songs) do
			local songdata = song_defs[song]
			if songdata ~= nil then
				self:AddSong(songdata, true)
			end
		end
    end
end

function SingingInspiration:GetDebugString()
	return "current: " .. tostring(self.current) .. ", active_songs " .. tostring(#self.active_songs) .. ", available_slots " .. tostring(self.available_slots)
end

return SingingInspiration