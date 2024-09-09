

local function MakeBuff(name, data)
    local function OnAttached(inst, target)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0,0,0)
        inst:ListenForEvent("death", function(t)
            inst.components.debuff:Stop()
        end, target)

        if data.onattached then
            data.onattached(inst, target)
        end
    end

    local function OnDetached(inst, target)
        if data.ondetached then
            data.ondetached(inst, target)
        end

        inst:Remove()
    end

    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            inst:DoTaskInTime(0, inst.Remove)
            return
        end

        inst:AddTag("CLASSIFIED")

        inst.entity:AddTransform()

        inst.entity:Hide()
        inst.persists = false

        local debuff = inst:AddComponent("debuff")
        debuff:SetAttachedFn(OnAttached)
        debuff:SetDetachedFn(OnDetached)

        return inst
    end

    return Prefab("mermking_buff_"..name, fn, nil, data.prefabs)
end

local TRIDENT_MODIFIER_KEY = "mermkingtridentupgrade"
local CROWN_MODIFIER_KEY = "mermkingcrownupgrade"
local PAULDRON_MODIFIER_KEY = "mermkingpauldronupgrade"

--
return MakeBuff("trident", {
        onattached = function(inst, target, symbol, offset, data)
            if target.components.combat ~= nil then
                target.components.combat.externaldamagemultipliers:SetModifier(inst, 1.05, TRIDENT_MODIFIER_KEY)
            end
        end,
        ondetached = function(inst, target)
            if target.components.combat ~= nil then
                target.components.combat.externaldamagemultipliers:RemoveModifier(inst, TRIDENT_MODIFIER_KEY)
            end
        end,
    }),
    MakeBuff("crown", {
        onattached = function(inst, target, symbol, offset, data)
            if not target.isplayer and target:HasTag("mermguard") then
                local attackdodger = target:AddComponent("attackdodger")
                attackdodger.ondodgefn = function(inst, attacker) inst:PushEvent("attackdodged", attacker) end
                attackdodger.cooldowntime = TUNING.MERMKING_CROWNBUFF_DODGE_COOLDOWN
            end
            if target.components.sanity then
                target.components.sanity.neg_aura_modifiers:SetModifier(inst, TUNING.MERMKING_CROWNBUFF_SANITYAURA_MOD, CROWN_MODIFIER_KEY)
            end
        end,
        ondetached = function(inst, target)
            if not target.isplayer then
                target:RemoveComponent("attackdodger")
            end
            if target.components.sanity then
                target.components.sanity.neg_aura_modifiers:RemoveModifier(inst, CROWN_MODIFIER_KEY)
            end
        end,
    }),
    MakeBuff("pauldron", {
        onattached = function(inst, target, symbol, offset, data)
            if target.components.health ~= nil then
                local buff_amount = (target.isplayer and TUNING.MERMKING_PAULDRONBUFF_DEFENSEPERCENT_PLAYER)
                    or TUNING.MERMKING_PAULDRONBUFF_DEFENSEPERCENT
                target.components.health.externalabsorbmodifiers:SetModifier(inst, buff_amount, PAULDRON_MODIFIER_KEY)
            end
        end,
        ondetached = function(inst, target)
            if target.components.health ~= nil then
                target.components.health.externalabsorbmodifiers:RemoveModifier(inst, PAULDRON_MODIFIER_KEY)
            end
        end,
    })

-- NOTES(JBK): Search string: mermking_gear_buffs