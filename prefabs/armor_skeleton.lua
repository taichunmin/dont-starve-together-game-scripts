local assets =
{
    Asset("ANIM", "anim/armor_skeleton.zip"),
}

local prefabs = {}

local SHIELD_DURATION = 10 * FRAMES
local SHIELD_VARIATIONS = 3
local MAIN_SHIELD_CD = 1.2

local RESISTANCES =
{
    "_combat",
    "explosive",
    "quakedebris",
    "lunarhaildebris",
    "caveindebris",
    "trapdamage",
}

for j = 0, 3, 3 do
    for i = 1, SHIELD_VARIATIONS do
        table.insert(prefabs, "shadow_shield"..tostring(j + i))
    end
end

local function PickShield(inst)
    local t = GetTime()
    local flipoffset = math.random() < .5 and SHIELD_VARIATIONS or 0

    --variation 3 is the main shield
    local dt = t - inst.lastmainshield
    if dt >= MAIN_SHIELD_CD then
        inst.lastmainshield = t
        return flipoffset + 3
    end

    local rnd = math.random()
    if rnd < dt / MAIN_SHIELD_CD then
        inst.lastmainshield = t
        return flipoffset + 3
    end

    return flipoffset + (rnd < dt / (MAIN_SHIELD_CD * 2) + .5 and 2 or 1)
end

local function OnShieldOver(inst, OnResistDamage)
    inst.task = nil
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end
    inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
end

local function OnResistDamage(inst)--, damage)
    local owner = inst.components.inventoryitem:GetGrandOwner() or inst
    local fx = SpawnPrefab("shadow_shield"..tostring(PickShield(inst)))
    fx.entity:SetParent(owner.entity)

    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(SHIELD_DURATION, OnShieldOver, OnResistDamage)
    inst.components.resistance:SetOnResistDamageFn(nil)

    inst.components.fueled:DoDelta(-TUNING.MED_FUEL)
    if inst.components.cooldown.onchargedfn ~= nil then
        inst.components.cooldown:StartCharging()
    end
end

local function ShouldResistFn(inst)
    if not inst.components.equippable:IsEquipped() then
        return false
    end
    local owner = inst.components.inventoryitem.owner
    return owner ~= nil
        and not (owner.components.inventory ~= nil and
                owner.components.inventory:EquipHasTag("forcefield"))
end

local function OnChargedFn(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:AddResistance(v)
    end
end

local function nofuel(inst)
    inst.components.cooldown.onchargedfn = nil
    inst.components.cooldown:FinishCharging()
end

local function CLIENT_PlayFuelSound(inst)
	local parent = inst.entity:GetParent()
	local container = parent ~= nil and (parent.replica.inventory or parent.replica.container) or nil
	if container ~= nil and container:IsOpenedBy(ThePlayer) then
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	end
end

local function SERVER_PlayFuelSound(inst)
	local owner = inst.components.inventoryitem.owner
	if owner == nil then
		inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	elseif inst.components.equippable:IsEquipped() and owner.SoundEmitter ~= nil then
		owner.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	else
		inst.playfuelsound:push()
		--Dedicated server does not need to trigger sfx
		if not TheNet:IsDedicated() then
			CLIENT_PlayFuelSound(inst)
		end
	end
end

local function ontakefuel(inst)
    if inst.components.equippable:IsEquipped() and
        not inst.components.fueled:IsEmpty() and
        inst.components.cooldown.onchargedfn == nil then
        inst.components.cooldown.onchargedfn = OnChargedFn
        inst.components.cooldown:StartCharging(TUNING.ARMOR_SKELETON_FIRST_COOLDOWN)
    end
	SERVER_PlayFuelSound(inst)
end

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "armor_skeleton")
    else
		owner.AnimState:OverrideSymbol("swap_body", "armor_skeleton", "swap_body")
    end

    inst.lastmainshield = 0
    if not inst.components.fueled:IsEmpty() then
        inst.components.cooldown.onchargedfn = OnChargedFn
        inst.components.cooldown:StartCharging(math.max(TUNING.ARMOR_SKELETON_FIRST_COOLDOWN, inst.components.cooldown:GetTimeToCharged()))
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.cooldown.onchargedfn = nil
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end

local function onequiptomodel(inst, owner, from_ground)
    inst.components.cooldown.onchargedfn = nil

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end

    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end
end

local function GetShadowLevel(inst)
	return not inst.components.fueled:IsEmpty() and TUNING.ARMOR_SKELETON_SHADOW_LEVEL or 0
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_skeleton")
    inst.AnimState:SetBuild("armor_skeleton")
    inst.AnimState:PlayAnimation("anim")

    inst.scrapbook_specialinfo = "ARMORBONE"

    inst:AddTag("fossil")

	--shadowlevel (from shadowlevel component) added to pristine state for optimization
	inst:AddTag("shadowlevel")

    inst.foleysound = "dontstarve/movement/foley/bone"

	inst.playfuelsound = net_event(inst.GUID, "armorskeleton.playfuelsound")

    local swap_data = {bank = "armor_skeleton", anim = "anim"}
    MakeInventoryFloatable(inst, "small", 0.2, 0.80, nil, nil, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		--delayed because we don't want any old events
		inst:DoTaskInTime(0, inst.ListenForEvent, "armorskeleton.playfuelsound", CLIENT_PlayFuelSound)

        return inst
    end

    inst.scrapbook_fueled_rate = TUNING.MED_FUEL
    inst.scrapbook_fueled_uses = true

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("resistance")
    inst.components.resistance:SetShouldResistFn(ShouldResistFn)
    inst.components.resistance:SetOnResistDamageFn(OnResistDamage)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
    inst.components.fueled:InitializeFuelLevel(4 * TUNING.LARGE_FUEL)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled.accepting = true

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("cooldown")
    inst.components.cooldown.cooldown_duration = TUNING.ARMOR_SKELETON_COOLDOWN

	inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(TUNING.ARMOR_SKELETON_SHADOW_LEVEL)
	inst.components.shadowlevel:SetLevelFn(GetShadowLevel)

    MakeHauntableLaunch(inst)

    inst.task = nil
    inst.lastmainshield = 0

    return inst
end

return Prefab("armorskeleton", fn, assets, prefabs)
