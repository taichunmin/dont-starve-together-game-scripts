local SourceModifierList = require("util/sourcemodifierlist")
local SpDamageUtil = require("components/spdamageutil")

--Update inventoryitem_replica constructor if any more properties are added
local function onattackrange(self, attackrange)
    if self.inst.replica.inventoryitem ~= nil then
        self.inst.replica.inventoryitem:SetAttackRange(attackrange)
    end
end

local Weapon = Class(function(self, inst)
    self.inst = inst
    self.damage = 10
    self.attackrange = nil
    self.hitrange = nil
    self.onattack = nil
    self.onprojectilelaunch = nil
	self.onprojectilelaunched = nil
    self.projectile = nil
    self.stimuli = nil
    --self.overridestimulifn = nil
    --self.electric_damage_mult = nil
    --self.electric_wet_damage_mult = nil

    self.attackwearmultipliers = SourceModifierList(self.inst)

    --V2C: Recommended to explicitly add tag to prefab pristine state
    self.inst:AddTag("weapon")
end,
nil,
{
    attackrange = onattackrange,
})

function Weapon:OnRemoveFromEntity()
    self.inst:RemoveTag("weapon")

    if self.inst.replica.inventoryitem ~= nil then
        self.inst.replica.inventoryitem:SetAttackRange(-1)
    end
end

function Weapon:SetDamage(dmg)
    self.damage = dmg
end

function Weapon:SetRange(attack, hit)
    self.attackrange = attack
    self.hitrange = hit or self.attackrange
end

function Weapon:SetOnAttack(fn)
    self.onattack = fn
end

function Weapon:SetOnProjectileLaunch(fn)
    self.onprojectilelaunch = fn
end

function Weapon:SetOnProjectileLaunched(fn)
    self.onprojectilelaunched = fn
end

function Weapon:SetProjectile(projectile)
    self.projectile = projectile
end

function Weapon:SetProjectileOffset(offset)
    self.projectile_offset = offset
end

function Weapon:SetElectric(damage_mult, wet_damage_mult)
    self.stimuli = "electric"

    self.electric_damage_mult = damage_mult
    self.electric_wet_damage_mult = wet_damage_mult
end

function Weapon:SetOverrideStimuliFn(fn)
    self.overridestimulifn = fn
end

function Weapon:CanRangedAttack()
    return self.projectile ~= nil
end

--V2C: deprecated. why's this even here? it's same as :SetOnAttack(fn)
--     keepin' it around in case modders used it
function Weapon:SetAttackCallback(fn)
    self.onattack = fn
end

function Weapon:GetDamage(attacker, target)
	local dmg = FunctionOrValue(self.damage, self.inst, attacker, target)
	local spdmg = SpDamageUtil.CollectSpDamage(self.inst)
	if self.inst.components.damagetypebonus ~= nil then
		local damagetypemult = self.inst.components.damagetypebonus:GetBonus(target)
		dmg = dmg * damagetypemult
		spdmg = SpDamageUtil.ApplyMult(spdmg, damagetypemult)
	end
	return dmg, spdmg
end

function Weapon:OnAttack(attacker, target, projectile)
    if self.onattack ~= nil then
        self.onattack(self.inst, attacker, target)
    end

	if self.inst.components.finiteuses ~= nil and not self.inst.components.finiteuses:IgnoresCombatDurabilityLoss()
		and not (projectile ~= nil and projectile.components.projectile ~= nil and projectile.components.projectile:IsBounced())
		then
		local uses = (self.attackwear or 1) * self.attackwearmultipliers:Get()
		if attacker ~= nil and attacker:IsValid() and attacker.components.efficientuser ~= nil then
			uses = uses * (attacker.components.efficientuser:GetMultiplier(ACTIONS.ATTACK) or 1)
		end

		self.inst.components.finiteuses:Use(uses)
    end
end

function Weapon:LaunchProjectile(attacker, target)
    if self.projectile ~= nil then
        if self.onprojectilelaunch ~= nil then
            self.onprojectilelaunch(self.inst, attacker, target)
        end

        local proj = SpawnPrefab(self.projectile)
        if proj ~= nil then
            if proj.components.projectile ~= nil then
				if self.projectile_offset ~= nil then
					local x, y, z = attacker.Transform:GetWorldPosition()

					local dir = (target:GetPosition() - Vector3(x, y, z)):Normalize()
					dir = dir * self.projectile_offset

	                proj.Transform:SetPosition(x + dir.x, y, z + dir.z)
				else
	                proj.Transform:SetPosition(attacker.Transform:GetWorldPosition())
				end
                proj.components.projectile:Throw(self.inst, target, attacker)
                if self.inst.projectiledelay ~= nil then
                    proj.components.projectile:DelayVisibility(self.inst.projectiledelay)
                end
            elseif proj.components.complexprojectile ~= nil then
                proj.Transform:SetPosition(attacker.Transform:GetWorldPosition())
                proj.components.complexprojectile:Launch(target:GetPosition(), attacker, self.inst)
            end
        end

        if self.onprojectilelaunched ~= nil then
            self.onprojectilelaunched(self.inst, attacker, target, proj)
        end
    end
end

return Weapon
