local assets = {
    Asset("ANIM", "anim/armor_voidcloth.zip"),
    Asset("ANIM", "anim/shadow_teleport.zip"),
}

local prefabs = {
    "armor_voidcloth_fx",
}

local function OnEnabledSetBonus(inst)
    inst.components.damagetyperesist:AddResist("shadow_aligned", inst, TUNING.ARMOR_VOIDCLOTH_SETBONUS_SHADOW_RESIST, "setbonus")
end

local function OnDisabledSetBonus(inst)
    inst.components.damagetyperesist:RemoveResist("shadow_aligned", inst, "setbonus")
end

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "armor_voidcloth")
    else
        owner.AnimState:OverrideSymbol("swap_body", "armor_voidcloth", "swap_body")
    end

    if inst.fx ~= nil then
        inst.fx:Remove()
    end
    inst.fx = SpawnPrefab("armor_voidcloth_fx")
    inst.fx:AttachToOwner(owner)

	if owner.components.sanity ~= nil then
		owner.components.sanity.neg_aura_modifiers:SetModifier(inst, 0)
	end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.fx ~= nil then
        inst.fx:Remove()
        inst.fx = nil
    end

	if owner.components.sanity ~= nil then
		owner.components.sanity.neg_aura_modifiers:RemoveModifier(inst)
	end
end

local function SetupEquippable(inst)
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
end

local SWAP_DATA_BROKEN = { bank = "armor_voidcloth", anim = "broken" }
local SWAP_DATA = { bank = "armor_voidcloth", anim = "anim" }

local function OnBroken(inst)
	if inst.components.equippable ~= nil then
		inst:RemoveComponent("equippable")
		inst.AnimState:PlayAnimation("broken")
		inst.components.floater:SetSwapData(SWAP_DATA_BROKEN)
		inst:AddTag("broken")
		inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"
	end
end

local function OnRepaired(inst)
	if inst.components.equippable == nil then
		SetupEquippable(inst)
		inst.AnimState:PlayAnimation("anim")
		inst.components.floater:SetSwapData(SWAP_DATA)
		inst:RemoveTag("broken")
		inst.components.inspectable.nameoverride = nil
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_voidcloth")
    inst.AnimState:SetBuild("armor_voidcloth")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("cloth")
	inst:AddTag("shadow_item")
	inst:AddTag("show_broken_ui")

	--shadowlevel (from shadowlevel component) added to pristine state for optimization
	inst:AddTag("shadowlevel")

	inst.foleysound = "dontstarve/movement/foley/shadowcloth_armour"

	MakeInventoryFloatable(inst, "small", 0.2, 0.80, nil, nil, SWAP_DATA)

    inst.scrapbook_specialinfo = "VOIDCLOTHARMOR"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    local armor = inst:AddComponent("armor")
    armor:InitCondition(TUNING.ARMOR_VOIDCLOTH, TUNING.ARMOR_VOIDCLOTH_ABSORPTION)

    local planardefense = inst:AddComponent("planardefense")
    planardefense:SetBaseDefense(TUNING.ARMOR_VOIDCLOTH_PLANAR_DEF)

	SetupEquippable(inst)

    local damagetyperesist = inst:AddComponent("damagetyperesist")
    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.ARMOR_VOIDCLOTH_SHADOW_RESIST)

	local shadowlevel = inst:AddComponent("shadowlevel")
	shadowlevel:SetDefaultLevel(TUNING.ARMOR_VOIDCLOTH_SHADOW_LEVEL)

    local setbonus = inst:AddComponent("setbonus")
    setbonus:SetSetName(EQUIPMENTSETNAMES.VOIDCLOTH)
    setbonus:SetOnEnabledFn(OnEnabledSetBonus)
    setbonus:SetOnDisabledFn(OnDisabledSetBonus)

	MakeForgeRepairable(inst, FORGEMATERIALS.VOIDCLOTH, OnBroken, OnRepaired)
    MakeHauntableLaunch(inst)

    return inst
end

--------------------------------------------------------------------------

local function CreateFxFollowFrame(i)
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.AnimState:SetBank("armor_voidcloth")
    inst.AnimState:SetBuild("armor_voidcloth")
    inst.AnimState:PlayAnimation("settle"..tostring(i))
    inst.AnimState:PushAnimation("idle"..tostring(i), false)

    inst:AddComponent("highlightchild")

    inst.persists = false

    return inst
end

local function fx_OnRemoveEntity(inst)
    for i, v in ipairs(inst.fx) do
        v:Remove()
    end
end

local function fx_OnUpdate(inst)
    local moving = inst.owner:HasTag("moving")
    if moving ~= inst.wasmoving then
        inst.wasmoving = moving
        if not moving then
            for i, v in ipairs(inst.fx) do
                v.AnimState:PlayAnimation("settle"..tostring(i))
                v.AnimState:PushAnimation("idle"..tostring(i), false)
            end
        end
    end
end

local function fx_ColourChanged(inst, r, g, b, a)
	for i, v in ipairs(inst.fx) do
		v.AnimState:SetAddColour(r, g, b, a)
	end
end

local function fx_SpawnFxForOwner(inst, owner)
    inst.owner = owner
    inst.wasmoving = false
    inst.fx = {}
    local frame
    for i = 1, 9 do
        local fx = CreateFxFollowFrame(i)
        fx.entity:SetParent(owner.entity)
        fx.Follower:FollowSymbol(owner.GUID, "swap_body", nil, nil, nil, true, nil, i - 1)
        fx.components.highlightchild:SetOwner(owner)
        table.insert(inst.fx, fx)
    end
	inst.components.colouraddersync:SetColourChangedFn(fx_ColourChanged)
    if owner:HasTag("locomotor") then
        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(fx_OnUpdate)
    end
    inst.OnRemoveEntity = fx_OnRemoveEntity
end

local function fx_OnEntityReplicated(inst)
    local owner = inst.entity:GetParent()
    if owner ~= nil then
        fx_SpawnFxForOwner(inst, owner)
    end
end

local function fx_AttachToOwner(inst, owner)
    inst.entity:SetParent(owner.entity)
	if owner.components.colouradder ~= nil then
		owner.components.colouradder:AttachChild(inst)
	end
    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        fx_SpawnFxForOwner(inst, owner)
    end
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

	inst:AddComponent("colouraddersync")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = fx_OnEntityReplicated

        return inst
    end

    inst.AttachToOwner = fx_AttachToOwner
    inst.persists = false

    return inst
end

return Prefab("armor_voidcloth", fn, assets, prefabs),
    Prefab("armor_voidcloth_fx", fxfn, assets)
