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
    self.projectile = nil
    self.stimuli = nil
    --self.overridestimulifn = nil

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

function Weapon:SetProjectile(projectile)
    self.projectile = projectile
end

function Weapon:SetElectric()
    self.stimuli = "electric"
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

function Weapon:OnAttack(attacker, target, projectile)
    if self.onattack ~= nil then
        self.onattack(self.inst, attacker, target)
    end

    if self.inst.components.finiteuses ~= nil then
        self.inst.components.finiteuses:Use(self.attackwear or 1)
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
                proj.Transform:SetPosition(attacker.Transform:GetWorldPosition())
                proj.components.projectile:Throw(self.inst, target, attacker)
                if self.inst.projectiledelay ~= nil then
                    proj.components.projectile:DelayVisibility(self.inst.projectiledelay)
                end
            elseif proj.components.complexprojectile ~= nil then
                proj.Transform:SetPosition(attacker.Transform:GetWorldPosition())
                proj.components.complexprojectile:Launch(target:GetPosition(), attacker, self.inst)
            end
        end
    end
end

return Weapon
