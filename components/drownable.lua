local Drownable = Class(function(self, inst)
    self.inst = inst

	self.enabled = nil

    --V2C: weregoose hacks will set this to false on load.
    --     Please refactor this block to use POST LOAD timing instead.
	self.inst:DoTaskInTime(0, function() if self.enabled == nil then self.enabled = true end end) -- delaying the enable until after the character is finished being set up so that the idle state doesnt sink the player while loading

--	self.customtuningsfn = nil
--	self.ontakedrowningdamage = nil
end)

function Drownable:SetOnTakeDrowningDamageFn(fn)
	self.ontakedrowningdamage = fn
end

function Drownable:SetCustomTuningsFn(fn)
	self.customtuningsfn = fn
end

function Drownable:IsOverWater()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    return not TheWorld.Map:IsVisualGroundAtPoint(x, y, z)
        and TheWorld.Map:GetTileAtPoint(x, y, z) ~= GROUND.INVALID -- allow players to be out of bounds so that a number of mods will still work
        and self.inst:GetCurrentPlatform() == nil
end

function Drownable:ShouldDrown()
    return self.enabled
        and self:IsOverWater()
        and (self.inst.components.health == nil or not self.inst.components.health:IsInvincible()) -- god mode check
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function NoPlayersOrHoles(pt)
    return not (IsAnyPlayerInRange(pt.x, 0, pt.z, 2) or TheWorld.Map:IsPointNearHole(pt))
end

function Drownable:Teleport()
    local target_x, target_y, target_z = self.dest_x, self.dest_y, self.dest_z
    local radius = 2 + math.random() * 3

    local pt = Vector3(target_x, target_y, target_z)
    local angle = math.random() * 2 * PI
    local offset =
        FindWalkableOffset(pt, angle, radius, 8, true, false, NoPlayersOrHoles) or
        FindWalkableOffset(pt, angle, radius * 1.5, 6, true, false, NoPlayersOrHoles) or
        FindWalkableOffset(pt, angle, radius, 8, true, false, NoHoles) or
        FindWalkableOffset(pt, angle, radius * 1.5, 6, true, false, NoHoles)
    if offset ~= nil then
        target_x = target_x + offset.x
        target_z = target_z + offset.z
    end

    if self.inst.Physics ~= nil then
        self.inst.Physics:Teleport(target_x, target_y, target_z)
    elseif self.inst.Transform ~= nil then
        self.inst.Transform:SetPosition(target_x, target_y, target_z)
    end
end

local function _oncameraarrive(inst)
    inst:SnapCamera()
    inst:ScreenFade(true, 2)
end

local function _onarrive(inst)
	if inst.sg.statemem.teleportarrivestate ~= nil then
		inst.sg:GoToState(inst.sg.statemem.teleportarrivestate)
	end

    inst:PushEvent("on_washed_ashore")
end

function Drownable:WashAshore()
	self:Teleport()

	if self.inst:HasTag("player") then
	    self.inst:ScreenFade(false)
		self.inst:DoTaskInTime(3, _oncameraarrive)
	end
    self.inst:DoTaskInTime(4, _onarrive)
end

function Drownable:ShouldDropItems()
	if self.inst:HasTag("stronggrip") then
		return false
	end

	return self.shoulddropitemsfn == nil and true or self.shoulddropitemsfn(self.inst)
end

function Drownable:OnFallInOcean(shore_x, shore_y, shore_z)
	self.src_x, self.src_y, self.src_z = self.inst.Transform:GetWorldPosition()

	if shore_x == nil then
		shore_x, shore_y, shore_z = FindRandomPointOnShoreFromOcean(self.src_x, self.src_y, self.src_z)
	end

	self.dest_x, self.dest_y, self.dest_z = shore_x, shore_y, shore_z

	if self.inst.components.sleeper ~= nil then
		self.inst.components.sleeper:WakeUp()
	end

	local inv = self.inst.components.inventory
	if inv ~= nil then
		local active_item = inv:GetActiveItem()
		if active_item ~= nil and not active_item:HasTag("irreplaceable") and not active_item.components.inventoryitem.keepondrown then
			Launch(inv:DropActiveItem(), self.inst, 3)
		end

		if self:ShouldDropItems() then
			local handitem = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
			if handitem ~= nil and not handitem:HasTag("irreplaceable") and not handitem.components.inventoryitem.keepondrown then
				Launch(inv:DropItem(handitem), self.inst, 3)
			end
		end
	end
end

function Drownable:TakeDrowningDamage()
	local tunings = self.customtuningsfn ~= nil and self.customtuningsfn(self.inst)
					or TUNING.DROWNING_DAMAGE[string.upper(self.inst.prefab)]
					or TUNING.DROWNING_DAMAGE[self.inst:HasTag("player") and "DEFAULT" or "CREATURE"]

	if self.inst.components.moisture ~= nil and tunings.WETNESS ~= nil then
		self.inst.components.moisture:DoDelta(tunings.WETNESS, true)
	end

	if self.inst.components.inventory ~= nil then
		local body_item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if body_item ~= nil and body_item.components.flotationdevice ~= nil and body_item.components.flotationdevice:IsEnabled() then
			body_item.components.flotationdevice:OnPreventDrowningDamage()
			return
		end
	end

	if self.inst.components.hunger ~= nil and tunings.HUNGER ~= nil then
		local delta = -math.min(tunings.HUNGER, self.inst.components.hunger.current - 30)
		if delta < 0 then
			self.inst.components.hunger:DoDelta(delta)
		end
	end

	if self.inst.components.health ~= nil then
		if tunings.HEALTH_PENALTY ~= nil then
			self.inst.components.health:DeltaPenalty(tunings.HEALTH_PENALTY)
		end

		if tunings.HEALTH ~= nil then
			local delta = -math.min(tunings.HEALTH, self.inst.components.health.currenthealth - 30)
			if delta < 0 then
				self.inst.components.health:DoDelta(delta, false, "drowning", true, nil, true)
			end
		end
	end

	if self.inst.components.sanity ~= nil and tunings.SANITY ~= nil then
		local delta = -math.min(tunings.SANITY, self.inst.components.sanity.current - 30)
		if delta < 0 then
			self.inst.components.sanity:DoDelta(delta)
		end
	end

	if self.ontakedrowningdamage ~= nil then
		self.ontakedrowningdamage(self.inst, tunings)
	end
end

function Drownable:DropInventory()
	if not self:ShouldDropItems() then
		return
	end

	local inv = self.inst.components.inventory
	if inv ~= nil then
		local to_drop = {}
		for k, v in pairs(inv.itemslots) do
			if not v:HasTag("irreplaceable") and not v.components.inventoryitem.keepondrown then
				table.insert(to_drop, k)
			end
		end
		shuffleArray(to_drop)

		for i = 1, math.ceil(#to_drop / 2) do
			Launch(inv:DropItem(inv.itemslots[ to_drop[i] ], true), self.inst, 2)
		end
	end
end


return Drownable