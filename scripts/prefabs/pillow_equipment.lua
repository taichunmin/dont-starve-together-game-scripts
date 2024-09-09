local pillow_common = require("prefabs/pillow_common")

local EMPTY_DATA = {}

----------------------------------------------------------------------------------------
-- BODY EQUIPMENT
----------------------------------------------------------------------------------------
local function on_body_defense_cooldown(inst)
    inst._cooldown_task = nil
end

local function MakeBodyPillow(materialname, pillowdata)
    pillowdata = pillowdata or EMPTY_DATA

    local bodypillow_assets = {
        Asset("ANIM", "anim/yotr_pillows_body.zip"),
        Asset("ANIM", "anim/swap_pillows_"..materialname..".zip"),

        Asset("SCRIPT", "scripts/prefabs/pillow_defs.lua"),
        Asset("SCRIPT", "scripts/prefabs/pillow_common.lua"),
    }

    local function on_blocked_callback(owner, data, inst)
        if inst._defense_callback and not inst._cooldown_task and data and not data.redirected then
            inst._cooldown_task = inst:DoTaskInTime((inst._defense_cooldown or 0.3), on_body_defense_cooldown)
            inst._defense_callback(owner, data, inst)
        end
    end

    local function onequipbody(inst, owner)
        if owner:HasTag("manrabbit") then
            owner.AnimState:OverrideSymbol("belt", "swap_pillows_"..materialname, "swap_body_rabbit")
        else
            owner.AnimState:OverrideSymbol("swap_body", "swap_pillows_"..materialname, "swap_body")
        end

        inst:ListenForEvent("blocked", inst._on_blocked, owner)
        inst:ListenForEvent("attacked", inst._on_blocked, owner)
    end

    local function onunequipbody(inst, owner)

        if owner:HasTag("manrabbit") then
            owner.AnimState:ClearOverrideSymbol("belt")
        else
            owner.AnimState:ClearOverrideSymbol("swap_body")
        end

        inst:RemoveEventCallback("blocked", inst._on_blocked, owner)
        inst:RemoveEventCallback("attacked", inst._on_blocked, owner)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst:AddTag("bodypillow")

        inst.AnimState:SetBank("yotr_pillows_body")
        inst.AnimState:SetBuild("yotr_pillows_body")
        inst.AnimState:PlayAnimation(materialname)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)

        MakeInventoryFloatable(inst, "large", 0.1, 0.75)

        --Sneak this into pristine state for optimization
        inst:AddTag("_named")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        --Remove this tag so that they can be added properly when replicating later
        inst:RemoveTag("_named")

        inst._prize_value = pillowdata.body_prize_value

        inst._defense_cooldown = pillowdata.defense_cooldown
        inst._defense_callback = pillowdata.defense_callback
        inst._defense_amount = pillowdata.defense_amount

        inst._on_blocked = function(owner, data) on_blocked_callback(owner, data, inst) end

        -------------------------------------------------------
		inst:AddComponent("named")
        inst:AddComponent("inspectable")

        -------------------------------------------------------
        inst:AddComponent("inventoryitem")

        -------------------------------------------------------
        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnEquip(onequipbody)
        inst.components.equippable:SetOnUnequip(onunequipbody)

        -------------------------------------------------------
        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        -------------------------------------------------------
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("bodypillow_"..materialname, fn, bodypillow_assets)
end

----------------------------------------------------------------------------------------
-- HAND EQUIPMENT
----------------------------------------------------------------------------------------
local PLAYERHIT_VERTICAL_OFFSET =       Vector3(0, 1.0, 0)
local NPCHIT_VERTICAL_OFFSET =          Vector3(0, 2.5, 0)
local function MakeHandPillow(materialname, pillowdata)
    pillowdata = pillowdata or EMPTY_DATA

    local handpillow_assets = {
        Asset("ANIM", "anim/yotr_pillows_hand.zip"),
        Asset("ANIM", "anim/swap_pillows_"..materialname..".zip"),

        Asset("SCRIPT", "scripts/prefabs/pillow_defs.lua"),
        Asset("SCRIPT", "scripts/prefabs/pillow_common.lua"),
    }

    local handpillow_prefabs =
    {
        "attackfx_handpillow_"..materialname,
        "reticulearc",
        "reticulearcping",
    }

    local function OnEquipHand(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_pillows_"..materialname, "swap_object")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end

    local function OnUnequipHand(inst, owner)
        owner.AnimState:ClearOverrideSymbol("swap_object")
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end

    local function onweaponattack(inst, attacker, target)
        if not target then
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            return
        end

        inst.SoundEmitter:PlaySound("yotr_2023/common/pillow_hit_"..inst.materialname)
    
        local fx = SpawnPrefab("attackfx_handpillow_"..materialname)
        local vertical_hitfx_offset = (target.isplayer and PLAYERHIT_VERTICAL_OFFSET) or NPCHIT_VERTICAL_OFFSET
        fx.Transform:SetPosition((target:GetPosition() + vertical_hitfx_offset):Get())
    
        if target.components.minigame_participator
                and target.components.minigame_participator:CurrentMinigameType() == "bunnyman_pillowfighting" then
            local knockback_data =
            {
                amount          = inst._knockback,
                strengthmult    = inst._strengthmult,
            }
            pillow_common.DoKnockback(target, attacker, knockback_data)
        else
            target:PushEvent("attacked", { attacker = attacker, weapon = inst, damage = 0,})
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("yotr_pillows_hand")
        inst.AnimState:SetBuild("yotr_pillows_hand")
        inst.AnimState:PlayAnimation(materialname)

        inst:AddTag("pillow")
        inst:AddTag("propweapon")

        inst.materialname = materialname

        MakeInventoryFloatable(inst, "small", 0.1)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst._prize_value = pillowdata.hand_prize_value

        inst._knockback = pillowdata.knockback or 0.1
        inst._stored_knockback = inst._knockback
        inst._strengthmult = pillowdata.strengthmult or 1.0
        inst._laglength = pillowdata.laglength or 1.0

        -------------------------------------------------------
        inst:AddComponent("inspectable")

        -------------------------------------------------------
        inst:AddComponent("inventoryitem")

        -------------------------------------------------------
        local equippable = inst:AddComponent("equippable")
        equippable.equipslot = EQUIPSLOTS.HANDS
        equippable:SetOnEquip(OnEquipHand)
        equippable:SetOnUnequip(OnUnequipHand)

        -------------------------------------------------------
        local weapon = inst:AddComponent("weapon")
        weapon:SetDamage(TUNING.PILLOW_DAMAGE)
        weapon:SetRange(TUNING.DEFAULT_ATTACK_RANGE, TUNING.PILLOW_HIT_RANGE)
        weapon:SetOnAttack(onweaponattack)

        -------------------------------------------------------
        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        -------------------------------------------------------
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("handpillow_"..materialname, fn, handpillow_assets, handpillow_prefabs)
end

----------------------------------------------------------------------------------------
-- HAND SPECIAL ATTACK FX
----------------------------------------------------------------------------------------
local hand_special_attack_fx_assets =
{
    Asset("ANIM", "anim/pillow_equipment_fx.zip"),
}

local FX_EXTRA_TIME = 2*FRAMES
local function FastForwardAttackFX(inst, pct)
    if inst._task ~= nil then
        inst._task:Cancel()
    end
    local len = inst.AnimState:GetCurrentAnimationLength()
    pct = math.clamp(pct, 0, 1)
    inst.AnimState:SetTime(len * pct)
    inst._task = inst:DoTaskInTime(len * (1 - pct) + FX_EXTRA_TIME, inst.Remove)
end

local function MakePillowFX(materialname, data)
    local function hand_special_attack_fx()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst.AnimState:SetBank("pillow_equipment_fx")
        inst.AnimState:SetBuild("pillow_equipment_fx")
        inst.AnimState:PlayAnimation("debris_"..materialname)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst._task = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FX_EXTRA_TIME, inst.Remove)

        inst.FastForward = FastForwardAttackFX

        return inst
    end

    return Prefab("attackfx_handpillow_"..materialname, hand_special_attack_fx, hand_special_attack_fx_assets)
end

local all_pillow_prefabs = {}
for material, data in pairs(require("prefabs/pillow_defs")) do
    table.insert(all_pillow_prefabs, MakeBodyPillow(material, data))
    table.insert(all_pillow_prefabs, MakeHandPillow(material, data))
    table.insert(all_pillow_prefabs, MakePillowFX(material, data))
end

----------------------------------------------------------------------------------------

return unpack(all_pillow_prefabs)