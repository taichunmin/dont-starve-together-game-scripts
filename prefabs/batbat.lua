local easing = require("easing")
local assets =
{
    Asset("ANIM", "anim/batbat.zip"),
    Asset("ANIM", "anim/swap_batbat.zip"),
}

local assets_bats =
{
    Asset("ANIM", "anim/bat_tree_fx.zip"),
    Asset("PKGREF", "anim/dynamic/batbat_scythe.dyn"),
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_batbat", inst.GUID, "swap_batbat")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_batbat", "swap_batbat")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end

local function onattack(inst, owner, target)
    local skin_fx = SKIN_FX_PREFAB[inst:GetSkinName()]
    if skin_fx ~= nil and skin_fx[1] ~= nil and target ~= nil and target.components.combat ~= nil and target:IsValid() then
        local fx = SpawnPrefab(skin_fx[1])
        if fx ~= nil then
            fx.entity:SetParent(target.entity)
            fx.entity:AddFollower():FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
            if fx.OnFXSpawned ~= nil then
                fx:OnFXSpawned(inst)
            end
        end
    end
    if owner.components.health ~= nil and owner.components.health:GetPercent() < 1 and not (target:HasTag("wall") or target:HasTag("engineering")) then
        owner.components.health:DoDelta(TUNING.BATBAT_DRAIN, false, "batbat")
		if owner.components.sanity ~= nil then
	        owner.components.sanity:DoDelta(-.5 * TUNING.BATBAT_DRAIN)
		end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("batbat")
    inst.AnimState:SetBuild("batbat")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("dull")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    local swap_data = {sym_build = "swap_batbat"}
    MakeInventoryFloatable(inst, "large", 0.05, {0.8, 0.35, 0.8}, true, -27, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE)
    inst.components.weapon.onattack = onattack

    -------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BATBAT_USES)
    inst.components.finiteuses:SetUses(TUNING.BATBAT_USES)

    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

local function DoFlutterSound(inst, intensity)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/flap", nil, easing.outQuad(intensity, 0, 1, 1))
    if intensity > .2 then
        inst:DoTaskInTime(math.random(9, 10) * FRAMES, DoFlutterSound, intensity - .2)
    end
end

local function PlayBatFX(proxy)
    if proxy.variation:value() > 0 then
        local inst = CreateEntity()

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        --V2C: Purposely not using SetFromProxy
        inst.Transform:SetPosition(proxy.Transform:GetWorldPosition())

        inst.AnimState:SetBank("batbat_scythe")
        inst.AnimState:SetBuild("bat_tree_fx")
        inst.AnimState:PlayAnimation("bat"..tostring(proxy.variation:value()))

        DoFlutterSound(inst, 1)

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function OnBatFXSpawned(inst, parent)
    if parent ~= nil then
        if parent._batfxvariations == nil then
            parent._batfxvariations = {}
            local choices = { 1, 2, 3, 4 }
            while #choices > 0 do
                table.insert(parent._batfxvariations, table.remove(choices, math.random(#choices)))
            end
        end
        inst.variation:set(table.remove(parent._batfxvariations, math.max(1, math.random(0, 2))))
        table.insert(parent._batfxvariations, inst.variation:value())
    else
        inst.variation:set(math.random(4))
    end
end

local function batsfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("nointerpolate")

    inst.variation = net_tinybyte(inst.GUID, "batbat_bats.variation")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, PlayBatFX)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(.5, inst.Remove)
    inst.persists = false
    inst.OnFXSpawned = OnBatFXSpawned

    return inst
end

local function PlayFantasyFX(proxy)
    if proxy.variation:value() > 0 then
        local inst = CreateEntity()

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        --V2C: Purposely not using SetFromProxy
        inst.Transform:SetPosition(proxy.Transform:GetWorldPosition())

        inst.AnimState:SetBank("batbat_fantasy")
        inst.AnimState:SetSkin("batbat_fantasy")
        inst.AnimState:PlayAnimation("bat"..tostring(proxy.variation:value()))

        DoFlutterSound(inst, 1)

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function OnFantasyFXSpawned(inst, parent)
    if parent ~= nil then
        if parent._fantasyfxvariations == nil then
            parent._fantasyfxvariations = {}
            local choices = { 1, 2, 3, 4 }
            while #choices > 0 do
                table.insert(parent._fantasyfxvariations, table.remove(choices, math.random(#choices)))
            end
        end
        inst.variation:set(table.remove(parent._fantasyfxvariations, math.max(1, math.random(0, 2))))
        table.insert(parent._fantasyfxvariations, inst.variation:value())
    else
        inst.variation:set(math.random(4))
    end
end

local function fantasyfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("nointerpolate")

    inst.variation = net_tinybyte(inst.GUID, "batbat_fantasy.variation")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, PlayFantasyFX)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(.5, inst.Remove)
    inst.persists = false
    inst.OnFXSpawned = OnFantasyFXSpawned

    return inst
end

return Prefab("batbat", fn, assets),
    Prefab("batbat_bats", batsfn, assets_bats),
    Prefab("batbat_fantasy_fx", fantasyfn, assets_bats)
