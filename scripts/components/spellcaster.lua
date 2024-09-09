local function oncancast(self)
    if self.spell ~= nil then
        self.inst:AddOrRemoveTag("castfrominventory", self.canusefrominventory)

        if self.canuseontargets then
            self.inst:AddOrRemoveTag("castontargets",
                not (self.canonlyuseonrecipes or
                    self.canonlyuseonlocomotors or
                    self.canonlyuseonlocomotorspvp or
                    self.canonlyuseonworkable or
                    self.canonlyuseoncombat)
            )

            self.inst:AddOrRemoveTag("castonrecipes", self.canonlyuseonrecipes)

            if self.canonlyuseonlocomotorspvp then
                self.inst:AddTag("castonlocomotorspvp")
                self.inst:RemoveTag("castonlocomotors")
            else
                self.inst:RemoveTag("castonlocomotorspvp")
                self.inst:AddOrRemoveTag("castonlocomotors", self.canonlyuseonlocomotors)
            end

            self.inst:AddOrRemoveTag("castonworkable", self.canonlyuseonworkable)
            self.inst:AddOrRemoveTag("castoncombat", self.canonlyuseoncombat)
        else
            self.inst:RemoveTag("castontargets")
            self.inst:RemoveTag("castonrecipes")
            self.inst:RemoveTag("castonlocomotors")
            self.inst:RemoveTag("castonlocomotorspvp")
            self.inst:RemoveTag("castonworkable")
            self.inst:RemoveTag("castoncombat")
        end

        self.inst:AddOrRemoveTag("castonpoint", self.canuseonpoint)
        self.inst:AddOrRemoveTag("castonpointwater", self.canuseonpoint_water)
    else
        self.inst:RemoveTag("castfrominventory")
        self.inst:RemoveTag("castontargets")
        self.inst:RemoveTag("castonrecipes")
        self.inst:RemoveTag("castonlocomotors")
        self.inst:RemoveTag("castonlocomotorspvp")
        self.inst:RemoveTag("castonworkable")
        self.inst:RemoveTag("castoncombat")
        self.inst:RemoveTag("castonpoint")
    end
end

local function onquickcast(self)
    self.inst:AddOrRemoveTag("quickcast", self.quickcast)
end

local function onveryquickcast(self)
    self.inst:AddOrRemoveTag("veryquickcast", self.veryquickcast)
end

local function onspelltype(self, newtype, oldtype)
    if oldtype then
        self.inst:RemoveTag(oldtype.."_spellcaster")
    end

    if newtype then
        self.inst:AddTag(newtype.."_spellcaster")
    end
end

local SpellCaster = Class(function(self, inst)
    self.inst = inst
    self.onspellcast = nil
    self.canusefrominventory = false
    self.canuseontargets = false
    self.canuseondead = false
    self.canonlyuseonrecipes = false
    self.canonlyuseonlocomotors = false
    self.canonlyuseonlocomotorspvp = false
    self.canonlyuseonworkable = false
    self.canonlyuseoncombat = false
    self.canuseonpoint = false
    self.canuseonpoint_water = false
    self.spell = nil
    self.quickcast = false
    self.veryquickcast = false

    self.spelltype = nil

    --self.can_cast_fn = nil
end,
nil,
{
    spell = oncancast,
    canusefrominventory = oncancast,
    canuseontargets = oncancast,
    canonlyuseonrecipes = oncancast,
    canonlyuseonlocomotors = oncancast,
    canonlyuseonlocomotorspvp = oncancast,
    canonlyuseonworkable = oncancast,
    canonlyuseoncombat = oncancast,
    canuseonpoint = oncancast,
    canuseonpoint_water = oncancast,
    quickcast = onquickcast,
    veryquickcast = onveryquickcast,
    spelltype = onspelltype,
})

function SpellCaster:OnRemoveFromEntity()
    self.inst:RemoveTag("castfrominventory")
    self.inst:RemoveTag("castontargets")
    self.inst:RemoveTag("castonrecipes")
    self.inst:RemoveTag("castonlocomotors")
    self.inst:RemoveTag("castonlocomotorspvp")
    self.inst:RemoveTag("castonworkable")
    self.inst:RemoveTag("castoncombat")
    self.inst:RemoveTag("castonpoint")
    self.inst:RemoveTag("quickcast")
    self.inst:RemoveTag("veryquickcast")
end

function SpellCaster:SetSpellFn(fn)
    self.spell = fn
end

function SpellCaster:SetOnSpellCastFn(fn)
    self.onspellcast = fn
end

function SpellCaster:SetCanCastFn(fn)
    self.can_cast_fn = fn
end

function SpellCaster:SetSpellType(type)
    self.spelltype = type
end

function SpellCaster:CastSpell(target, pos, doer)
    if self.spell ~= nil then
        self.spell(self.inst, target, pos, doer)

        if self.onspellcast ~= nil then
            self.onspellcast(self.inst, target, pos, doer)
        end
    end
end

local function IsWorkAction(action)
    return action == ACTIONS.CHOP
        or action == ACTIONS.DIG
        or action == ACTIONS.HAMMER
        or action == ACTIONS.MINE
end

function SpellCaster:CanCast(doer, target, pos)
    if self.spell == nil then
        return false
    elseif self.spelltype ~= nil and not doer:HasTag(self.spelltype.."_spelluser") then
        return false
    elseif target == nil then
        if pos == nil then
            return self.canusefrominventory
        else
            local can_cast, cast_fail_reason = true, nil
            if self.can_cast_fn ~= nil then
                can_cast, cast_fail_reason = self.can_cast_fn(doer, nil, pos)
            end

            if not can_cast then
                return can_cast, cast_fail_reason
            end

            if self.canuseonpoint then
                local px, py, pz = pos:Get()
                return TheWorld.Map:IsAboveGroundAtPoint(px, py, pz, self.canuseonpoint_water) and not TheWorld.Map:IsGroundTargetBlocked(pos)
            elseif self.canuseonpoint_water then
                return TheWorld.Map:IsOceanAtPoint(pos:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pos)
            else
                return false
            end
        end
    elseif target:IsInLimbo()
        or not target.entity:IsVisible()
        or (target.components.health ~= nil and target.components.health:IsDead() and not self.canuseondead)
        or (target.sg ~= nil and (
                target.sg.currentstate.name == "death" or
                target.sg:HasStateTag("flight") or
                target.sg:HasStateTag("invisible") or
                target.sg:HasStateTag("nospellcasting")
            )) then
        return false
    else
        return self.canuseontargets and (
                (self.canonlyuseonrecipes and AllRecipes[target.prefab] ~= nil and not FunctionOrValue(AllRecipes[target.prefab].no_deconstruction, target)) or
                (target.components.locomotor ~= nil and (
                    (self.canonlyuseonlocomotors and not self.canonlyuseonlocomotorspvp) or
                    (self.canonlyuseonlocomotorspvp and (target == doer or TheNet:GetPVPEnabled() or not (target:HasTag("player") and doer:HasTag("player"))))
                )) or
                (self.canonlyuseonworkable and target.components.workable ~= nil and target.components.workable:CanBeWorked() and IsWorkAction(target.components.workable:GetWorkAction())) or
                (self.canonlyuseoncombat and doer.components.combat ~= nil and doer.components.combat:CanTarget(target)) or
                (self.can_cast_fn ~= nil and self.can_cast_fn(doer, target, pos))
            )
    end
end

return SpellCaster
