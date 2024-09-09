local assets =
{
	Asset("ANIM", "anim/armor_lunarplant.zip"),
}

local huskassets =
{
	Asset("ANIM", "anim/armor_lunarplant.zip"),
	Asset("ANIM", "anim/armor_lunarplant_husk.zip"),
}

local prefabs =
{
	"armor_lunarplant_glow_fx",
	"hitsparks_reflect_fx",
    "wormwood_vined_debuff",
}

local huskprefabs =
{
	"armor_lunarplant_husk_glow_fx",
	"hitsparks_reflect_fx",
}

local function OnHit_Vines(owner, data)
	if owner == nil or data == nil then
		return
	end

    local attacker = data.attacker
    if not attacker or not attacker.components.locomotor
            or (attacker.components.health and attacker.components.health:IsDead()) then
        return
    end

    local owner_skilltreeupdater = owner.components.skilltreeupdater
    if owner_skilltreeupdater and owner_skilltreeupdater:IsActivated("wormwood_allegiance_lunar_plant_gear_1") then
        attacker:AddDebuff("wormwood_vined_debuff", "wormwood_vined_debuff")
    end
end

local function OnBlocked(owner, data)
	owner.SoundEmitter:PlaySound("dontstarve/common/together/armor/cactus")
end

local function OnEnabledSetBonus(inst)
	inst.components.damagetyperesist:AddResist("lunar_aligned", inst, TUNING.ARMOR_LUNARPLANT_SETBONUS_LUNAR_RESIST, "setbonus")
end

local function OnDisabledSetBonus(inst)
	inst.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "setbonus")
end

local function onequip(inst, owner)
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "armor_lunarplant")
	else
		owner.AnimState:OverrideSymbol("swap_body", inst.build, "swap_body")
	end

	inst:ListenForEvent("blocked", OnBlocked, owner)

	if owner:HasTag("plantkin") then
		if inst._onblocked then
			inst:ListenForEvent("attacked", inst._onblocked, owner)
			inst:ListenForEvent("blocked", inst._onblocked, owner)
		end
		if inst._onattackother then
			inst:ListenForEvent("onattackother", inst._onattackother, owner)
			inst._hitcount = 0
		end
	end

	if inst.fx ~= nil then
		inst.fx:Remove()
	end
	inst.fx = SpawnPrefab(inst.prefab.."_glow_fx")
	inst.fx:AttachToOwner(owner)
	owner.AnimState:SetSymbolLightOverride("swap_body", .1)
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_body")

	inst:RemoveEventCallback("blocked", OnBlocked, owner)

	--"plantkin" (wormwood) events--
	if inst._onblocked then
		inst:RemoveEventCallback("attacked", inst._onblocked, owner)
		inst:RemoveEventCallback("blocked", inst._onblocked, owner)
	end
	if inst._onattackother then
		inst:RemoveEventCallback("onattackother", inst._onattackother, owner)
		inst._hitcount = nil
	end
	--------------------------------

	if inst.fx ~= nil then
		inst.fx:Remove()
		inst.fx = nil
	end
	owner.AnimState:SetSymbolLightOverride("swap_body", 0)

	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end
end

local function SetupEquippable(inst)
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	if inst._equippable_restrictedtag ~= nil then
		inst.components.equippable.restrictedtag = inst._equippable_restrictedtag
	end
end

local SWAP_DATA_BROKEN = { bank = "armor_lunarplant", anim = "broken" }
local SWAP_DATA = { bank = "armor_lunarplant", anim = "anim" }

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

local function ReflectDamageFn(inst, attacker, damage, weapon, stimuli, spdamage)
	return 0,
	{
		planar = attacker ~= nil and attacker:HasTag("shadow_aligned")
			and TUNING.ARMOR_LUNARPLANT_REFLECT_PLANAR_DMG_VS_SHADOW
			or TUNING.ARMOR_LUNARPLANT_REFLECT_PLANAR_DMG,
	}
end

local function OnReflectDamage(inst, data)
	--data.attacker is the target we are reflecting dmg to
	if data ~= nil and data.attacker ~= nil and data.attacker:IsValid() then
		SpawnPrefab("hitsparks_reflect_fx"):Setup(inst.components.inventoryitem.owner or inst, data.attacker)
	end
end

local function commonfn(build, common_postinit, master_postinit)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst:AddTag("lunarplant")
	inst:AddTag("gestaltprotection")
	inst:AddTag("show_broken_ui")

	inst.AnimState:SetBank("armor_lunarplant")
	inst.AnimState:SetBuild(build)
	inst.AnimState:PlayAnimation("anim")

	inst.foleysound = "dontstarve/movement/foley/lunarplantarmour_foley"

	MakeInventoryFloatable(inst, "small", 0.2, 0.80, nil, nil, SWAP_DATA)

	inst.scrapbook_specialinfo = "ARMORLUNARPLANT"

    if common_postinit ~= nil then
        common_postinit(inst)
    end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.build = build

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	inst:AddComponent("armor")
	inst.components.armor:InitCondition(TUNING.ARMOR_LUNARPLANT, TUNING.ARMOR_LUNARPLANT_ABSORPTION)

	inst:AddComponent("planardefense")
	inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_LUNARPLANT_PLANAR_DEF)

	inst:AddComponent("damagereflect")
	inst.components.damagereflect:SetReflectDamageFn(ReflectDamageFn)
	inst:ListenForEvent("onreflectdamage", OnReflectDamage)

	SetupEquippable(inst)

	inst:AddComponent("damagetyperesist")
	inst.components.damagetyperesist:AddResist("lunar_aligned", inst, TUNING.ARMOR_LUNARPLANT_LUNAR_RESIST)

	local setbonus = inst:AddComponent("setbonus")
	setbonus:SetSetName(EQUIPMENTSETNAMES.LUNARPLANT)
	setbonus:SetOnEnabledFn(OnEnabledSetBonus)
	setbonus:SetOnDisabledFn(OnDisabledSetBonus)

	MakeForgeRepairable(inst, FORGEMATERIALS.LUNARPLANT, OnBroken, OnRepaired)

	MakeHauntableLaunch(inst)

    if master_postinit ~= nil then
        master_postinit(inst)
    end

	return inst
end

local function master_postinit(inst)
	inst._onblocked = OnHit_Vines
end

local function fn()
	return commonfn("armor_lunarplant", nil, master_postinit)
end

--------------------------------------------------------------------------

local function OnCooldown(inst)
    inst._cdtask = nil
end

local function DoThorns(inst, owner)
    --V2C: tiny CD to limit chain reactions
    inst._cdtask = inst:DoTaskInTime(.3, OnCooldown)

	if inst._hitcount then
		inst._hitcount = 0
	end
    
    SpawnPrefab("bramblefx_armor_upgrade"):SetFXOwner(owner)        

    if owner.SoundEmitter ~= nil then
        owner.SoundEmitter:PlaySound("dontstarve/common/together/armor/cactus")
    end
end

local function OnAttackOther(owner, data, inst)
	if inst._cdtask == nil and
		owner.components.skilltreeupdater and
		owner.components.skilltreeupdater:IsActivated("wormwood_armor_bramble")
	then
        inst._hitcount = inst._hitcount + 1

        if inst._hitcount >= TUNING.WORMWOOD_ARMOR_BRAMBLE_RELEASE_SPIKES_HITCOUNT then
            DoThorns(inst, owner)
        end
	else
		inst._hitcount = 0
    end
end

local function OnHuskBlocked(owner, data, inst)
    if inst._cdtask == nil and data ~= nil and not data.redirected then
        DoThorns(inst, owner)
    end
end

local function husk_common_postinit(inst)
	inst:AddTag("bramble_resistant")
end

local function husk_master_postinit (inst)
	inst._onblocked      = function(owner, data) OnHuskBlocked(owner, data, inst) end
	inst._onattackother  = function(owner, data) OnAttackOther(owner, data, inst) end

	inst._equippable_restrictedtag = "plantkin"
	inst.components.equippable.restrictedtag = inst._equippable_restrictedtag
end

local function huskfn()
	return commonfn("armor_lunarplant_husk", husk_common_postinit, husk_master_postinit)
end

--------------------------------------------------------------------------

local function CreateFxFollowFrame(i, build)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst:AddTag("FX")

	inst.AnimState:SetBank("armor_lunarplant")
	inst.AnimState:SetBuild(build)
	inst.AnimState:PlayAnimation("idle"..tostring(i), true)
	inst.AnimState:SetSymbolBloom("glowcentre")
	inst.AnimState:SetSymbolLightOverride("glowcentre", .5)
	inst.AnimState:SetLightOverride(.1)

	inst:AddComponent("highlightchild")

	inst.persists = false

	return inst
end

local function glow_OnRemoveEntity(inst)
	for i, v in ipairs(inst.fx) do
		v:Remove()
	end
end

local function glow_ColourChanged(inst, r, g, b, a)
	for i, v in ipairs(inst.fx) do
		v.AnimState:SetAddColour(r, g, b, a)
	end
end

local function glow_SpawnFxForOwner(inst, owner)
	inst.fx = {}
	local frame
	for i = 1, 6 do
		local fx = CreateFxFollowFrame(i, inst.build)
		frame = frame or math.random(fx.AnimState:GetCurrentAnimationNumFrames()) - 1
		fx.entity:SetParent(owner.entity)
		fx.Follower:FollowSymbol(owner.GUID, "swap_body", nil, nil, nil, true, nil, i - 1)
		fx.AnimState:SetFrame(frame)
		fx.components.highlightchild:SetOwner(owner)
		table.insert(inst.fx, fx)
	end
	inst.components.colouraddersync:SetColourChangedFn(glow_ColourChanged)
	inst.OnRemoveEntity = glow_OnRemoveEntity
end

local function glow_OnEntityReplicated(inst)
	local owner = inst.entity:GetParent()
	if owner ~= nil then
		glow_SpawnFxForOwner(inst, owner)
	end
end

local function glow_AttachToOwner(inst, owner)
	inst.entity:SetParent(owner.entity)
	if owner.components.colouradder ~= nil then
		owner.components.colouradder:AttachChild(inst)
	end
	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		glow_SpawnFxForOwner(inst, owner)
	end
end

local function MakeGlow(name, build, assets)
	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddNetwork()

		inst:AddTag("FX")

		inst:AddComponent("colouraddersync")

		inst.build = build

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			inst.OnEntityReplicated = glow_OnEntityReplicated

			return inst
		end

		inst.AttachToOwner = glow_AttachToOwner
		inst.persists = false

		return inst
	end

	return Prefab(name, fn, assets)
end

return Prefab("armor_lunarplant", fn, assets, prefabs),
		MakeGlow("armor_lunarplant_glow_fx", "armor_lunarplant", assets),
		--
		Prefab("armor_lunarplant_husk", huskfn, huskassets, huskprefabs),
		MakeGlow("armor_lunarplant_husk_glow_fx", "armor_lunarplant_husk", huskassets)
