local function DefaultLunarPlantTentacleCondition(inst, owner, attack_data)
    return (owner ~= nil) and (owner.components.skilltreeupdater ~= nil) and
        owner.components.skilltreeupdater:IsActivated("wormwood_allegiance_lunar_plant_gear_2")
end

local LunarPlant_Tentacle_Weapon = Class(function(self, inst)
    self.inst = inst

    self.spawn_chance = 0.2
    self.tentacle_prefab = "lunarplanttentacle"

    self.should_do_tentacles_fn = DefaultLunarPlantTentacleCondition

    self._on_attack = function(owner, data)
        self:OnAttack(owner, data)
    end

    --self.owner = nil
    self._erase_owner = function() self.owner = nil end

    self._equipped_callback = function(_, data)
        self:SetOwner(data.owner)
    end
    self.inst:ListenForEvent("equipped", self._equipped_callback)

    self._unequipped_callback = function(_, data)
        self:SetOwner(nil)
    end
    self.inst:ListenForEvent("unequipped", self._unequipped_callback)
end)

function LunarPlant_Tentacle_Weapon:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("equipped", self._equipped_callback)
    self.inst:RemoveEventCallback("unequipped", self._unequipped_callback)
    if self.owner then
        self.inst:RemoveEventCallback("onattackother", self._on_attack, self.owner)
        self.inst:RemoveEventCallback("onremove", self._erase_owner, self.owner)
    end
end

function LunarPlant_Tentacle_Weapon:SetOwner(owner)
    if self.owner then
        self.inst:RemoveEventCallback("onattackother", self._on_attack, self.owner)
        self.inst:RemoveEventCallback("onremove", self._erase_owner, self.owner)
    end

    self.owner = owner

    if owner then
        self.inst:ListenForEvent("onattackother", self._on_attack, owner)
        self.inst:ListenForEvent("onremove", self._erase_owner, owner)
    end
end

local function NoHoles(pt)
    return (TheWorld ~= nil) and not TheWorld.Map:IsPointNearHole(pt)
end

function LunarPlant_Tentacle_Weapon:OnAttack(owner, attack_data)
	if attack_data == nil or attack_data.weapon ~= self.inst then
		--e.g. could be attack events from projectiles fired before we equipped this weapon
		return
	elseif self.should_do_tentacles_fn and not self.should_do_tentacles_fn(self.inst, owner, attack_data) then
        return
    end

    local target = attack_data.target

    if target and target:IsValid() and math.random() < self.spawn_chance then
        local pt = target:GetPosition()

        local offset = FindWalkableOffset(pt, TWOPI * math.random(), 2, 3, false, true, NoHoles, false, true)
        if offset then
            local tentacle = SpawnPrefab(self.tentacle_prefab)
            if tentacle then
				tentacle.owner = owner
                tentacle.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
                tentacle.components.combat:SetTarget(target)
            end
        end
    end
end

return LunarPlant_Tentacle_Weapon