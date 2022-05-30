local function oncancast(self)
    if self.spell ~= nil then
        if self.canusefrominventory then
            self.inst:AddTag("castfrominventory")
        else
            self.inst:RemoveTag("castfrominventory")
        end

        if self.canuseontargets then
            if not (self.canonlyuseonrecipes or
                    self.canonlyuseonlocomotors or
                    self.canonlyuseonlocomotorspvp or
                    self.canonlyuseonworkable or
                    self.canonlyuseoncombat) then
                self.inst:AddTag("castontargets")
            else
                self.inst:RemoveTag("castontargets")
            end

            if self.canonlyuseonrecipes then
                self.inst:AddTag("castonrecipes")
            else
                self.inst:RemoveTag("castonrecipes")
            end

            if self.canonlyuseonlocomotorspvp then
                self.inst:AddTag("castonlocomotorspvp")
                self.inst:RemoveTag("castonlocomotors")
            else
                self.inst:RemoveTag("castonlocomotorspvp")
                if self.canonlyuseonlocomotors then
                    self.inst:AddTag("castonlocomotors")
                else
                    self.inst:RemoveTag("castonlocomotors")
                end
            end

            if self.canonlyuseonworkable then
                self.inst:AddTag("castonworkable")
            else
                self.inst:RemoveTag("castonworkable")
            end

            if self.canonlyuseoncombat then
                self.inst:AddTag("castoncombat")
            else
                self.inst:RemoveTag("castoncombat")
            end
        else
            self.inst:RemoveTag("castontargets")
            self.inst:RemoveTag("castonrecipes")
            self.inst:RemoveTag("castonlocomotors")
            self.inst:RemoveTag("castonlocomotorspvp")
            self.inst:RemoveTag("castonworkable")
            self.inst:RemoveTag("castoncombat")
        end

        if self.canuseonpoint then
            self.inst:AddTag("castonpoint")
        else
            self.inst:RemoveTag("castonpoint")
        end

        if self.canuseonpoint_water then
            self.inst:AddTag("castonpointwater")
        else
            self.inst:RemoveTag("castonpointwater")
        end
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
    if self.quickcast then
        self.inst:AddTag("quickcast")
    else
        self.inst:RemoveTag("quickcast")
    end
end

local function onveryquickcast(self)
    if self.veryquickcast then
        self.inst:AddTag("veryquickcast")
    else
        self.inst:RemoveTag("veryquickcast")
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

function SpellCaster:CastSpell(target, pos)
    if self.spell ~= nil then
        self.spell(self.inst, target, pos)

        if self.onspellcast ~= nil then
            self.onspellcast(self.inst, target, pos)
        end
    end
end

local function IsWorkAction(action)
    return action == ACTIONS.CHOP
        or action == ACTIONS.DIG
        or action == ACTIONS.HAMMER
        or action == ACTIONS.MINE
end

function SpellCaster:SetCanCastFn(fn)
    self.can_cast_fn = fn
end

function SpellCaster:CanCast(doer, target, pos)
    if self.spell == nil then
        return false
    elseif target == nil then
        if pos == nil then
            return self.canusefrominventory
        end

        if self.canuseonpoint then
            local px, py, pz = pos:Get()
            return TheWorld.Map:IsAboveGroundAtPoint(px, py, pz, self.canuseonpoint_water) and not TheWorld.Map:IsGroundTargetBlocked(pos)
        elseif self.canuseonpoint_water then
            return TheWorld.Map:IsOceanAtPoint(pos:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pos)
        else
            return false
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
    end
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

return SpellCaster
