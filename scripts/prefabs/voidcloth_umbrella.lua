local assets =
{
    Asset("ANIM", "anim/umbrella_voidcloth.zip"),
}

local prefabs =
{
    "voidcloth_umbrella_fx",
}

local function OnIsAcidRaining(inst, isacidraining)
    if isacidraining then
        inst.components.fueled.rate_modifiers:SetModifier(inst, -1, "acidrain")
    else
        inst.components.fueled.rate_modifiers:RemoveModifier(inst, "acidrain")
    end
end

local function OnEquip(inst, owner)
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_umbrella", inst.GUID, "umbrella_voidcloth")
	else
		owner.AnimState:OverrideSymbol("swap_object", "umbrella_voidcloth", "swap_umbrella")
	end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.DynamicShadow:SetSize(2.2, 1.4)

	if inst._fx ~= nil then
		inst._fx:Remove()
	end
    inst._fx = SpawnPrefab("voidcloth_umbrella_fx")
	inst._fx:AttachToOwner(owner)

    inst.components.fueled:StartConsuming()
    inst:WatchWorldState("isacidraining", inst.OnIsAcidRaining)
    inst:OnIsAcidRaining(TheWorld.state.isacidraining)
end

local function OnUnequip(inst, owner)
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.DynamicShadow:SetSize(1.3, 0.6)

    if inst._fx ~= nil then
        inst._fx:Remove()
        inst._fx = nil
    end

    inst.components.fueled:StopConsuming()
    inst:StopWatchingWorldState("isacidraining", inst.OnIsAcidRaining)
	inst:OnIsAcidRaining(false)
end

local function OnEquipToModel(inst, owner, from_ground)
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
    inst:StopWatchingWorldState("isacidraining", inst.OnIsAcidRaining)
	inst:OnIsAcidRaining(false)
end

local function SetupEquippable(inst)
	inst:AddComponent("equippable")
	inst.components.equippable.dapperness = -TUNING.DAPPERNESS_MED
	inst.components.equippable.is_magic_dapperness = true
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable:SetOnEquipToModel(OnEquipToModel)
end

local FLOAT_SCALE_BROKEN = { 0.75, 0.5, 0.75 }
local FLOAT_SCALE = { .975, 0.455, 1 }

local function OnIsBrokenDirty(inst)
	if inst.isbroken:value() then
		inst.components.floater:SetSize("med")
		inst.components.floater:SetVerticalOffset(0.15)
		inst.components.floater:SetScale(FLOAT_SCALE_BROKEN)
	else
		inst.components.floater:SetSize("large")
		inst.components.floater:SetVerticalOffset(0)
		inst.components.floater:SetScale(FLOAT_SCALE)
	end
end

local SWAP_DATA_BROKEN = { sym_build = "umbrella_voidcloth", sym_name = "swap_umbrella_broken_float", bank = "umbrella_voidcloth", anim = "broken" }
local SWAP_DATA = { sym_build = "umbrella_voidcloth", sym_name = "swap_umbrella_float", bank = "umbrella_voidcloth" }

local function SetIsBroken(inst, isbroken)
	if isbroken then
		inst.components.floater:SetBankSwapOnFloat(true, -15, SWAP_DATA_BROKEN)
	else
		inst.components.floater:SetBankSwapOnFloat(true, -47, SWAP_DATA)
	end
	inst.isbroken:set(isbroken)
	OnIsBrokenDirty(inst)
end

local function OnPerish(inst)
	if inst.components.machine:IsOn() then
		inst.components.machine:TurnOff()
	end

    local equippable = inst.components.equippable
	if equippable ~= nil then
		inst.AnimState:PlayAnimation("broken")

		if equippable:IsEquipped() then
			local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
			if owner ~= nil then
				local data =
				{
					prefab = inst.prefab,
					equipslot = equippable.equipslot,
				}
				if owner.components.inventory ~= nil then
					local item = owner.components.inventory:Unequip(equippable.equipslot)
					if item ~= nil then
						owner.components.inventory:GiveItem(item, nil, owner:GetPosition())
					end
				end
				inst:RemoveComponent("equippable")
				SetIsBroken(inst, true)
				owner:PushEvent("umbrellaranout", data)
				return
			end
		end
		inst:RemoveComponent("equippable")
		SetIsBroken(inst, true)
		inst:AddTag("broken")
		inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"
    end
end

local function OnRepaired(inst)
	if inst.components.equippable == nil then
		SetupEquippable(inst)
		inst.AnimState:PlayAnimation("idle")
		SetIsBroken(inst, false)
		inst:RemoveTag("broken")
		inst.components.inspectable.nameoverride = nil
	end
end

local WAVE_FX_LEN = 0.5
local function WaveFxOnUpdate(inst, dt)
	inst.t = inst.t + dt

	if inst.t < WAVE_FX_LEN then
		local k = 1 - inst.t / WAVE_FX_LEN
		k = k * k
		inst.AnimState:SetMultColour(1, 1, 1, k)
		k = (2 - 1.7 * k) * (inst.scalemult or 1)
		inst.AnimState:SetScale(k, k)
	else
		inst:Remove()
	end
end

local function CreateWaveFX()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("umbrella_voidcloth")
	inst.AnimState:SetBuild("umbrella_voidcloth")
	inst.AnimState:PlayAnimation("barrier_rim")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst:AddComponent("updatelooper")
	inst.components.updatelooper:AddOnUpdateFn(WaveFxOnUpdate)
	inst.t = 0
	inst.scalemult = .75
	WaveFxOnUpdate(inst, 0)

	return inst
end

local function CreateDomeFX()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("umbrella_voidcloth")
	inst.AnimState:SetBuild("umbrella_voidcloth")
	inst.AnimState:PlayAnimation("barrier_dome")
	inst.AnimState:SetFinalOffset(7)

	inst:AddComponent("updatelooper")
	inst.components.updatelooper:AddOnUpdateFn(WaveFxOnUpdate)
	inst.t = 0
	WaveFxOnUpdate(inst, 0)

	return inst
end

local function CLIENT_TriggerFX(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	CreateWaveFX().Transform:SetPosition(x, 0, z)
	local fx = CreateDomeFX()
	fx.Transform:SetPosition(x, 0, z)
	fx.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_activate")
end

local function SERVER_TriggerFX(inst)
	inst.triggerfx:push()
	if not TheNet:IsDedicated() then
		CLIENT_TriggerFX(inst)
	end
end

local function SetShadow(inst, enable)
	inst.DynamicShadow:Enable(enable)
end

local function turnon(inst)
	if not inst.components.fueled:IsEmpty() then
		inst.components.inventoryitem.canbepickedup = false
		inst.components.fueled.rate = TUNING.VOIDCLOTH_UMBRELLA_DOME_RATE
		inst.components.fueled:StartConsuming()
		inst.components.raindome:Enable()

		if inst.components.sanityaura == nil then
			inst:AddComponent("sanityaura")
			inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL
			inst.components.sanityaura.max_distsq = TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS * TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS
		end

		if inst.shadowtask ~= nil then
			inst.shadowtask:Cancel()
			inst.shadowtask = nil
		end

		if inst:IsAsleep() or POPULATING then
			inst.DynamicShadow:Enable(true)
			inst.AnimState:PlayAnimation("barrier_loop", true)
		else
			inst.DynamicShadow:Enable(false)
			inst.shadowtask = inst:DoTaskInTime(7 * FRAMES, SetShadow, true)
			inst.AnimState:PlayAnimation("barrier_pre")
			inst.AnimState:PushAnimation("barrier_loop")
			SERVER_TriggerFX(inst)
		end

		inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_lp", "loop")
	end
end

local function turnoff(inst)
	inst.components.inventoryitem.canbepickedup = true
	inst.components.fueled:StopConsuming()
	inst.components.fueled.rate = 1
	inst.components.raindome:Disable()

	if inst.components.sanityaura ~= nil then
		inst:RemoveComponent("sanityaura")
	end

	if inst.shadowtask ~= nil then
		inst.shadowtask:Cancel()
		inst.shadowtask = nil
	end

	local shouldsfx
	if inst.components.fueled:IsEmpty() then
		inst.DynamicShadow:Enable(false)
		inst.AnimState:PlayAnimation("broken")
		shouldsfx = true
	elseif inst.components.inventoryitem:IsHeld() or inst:IsAsleep() then
		inst.DynamicShadow:Enable(false)
		inst.AnimState:PlayAnimation("idle")
	else
		inst.DynamicShadow:Enable(true)
		inst.shadowtask = inst:DoTaskInTime(9 * FRAMES, SetShadow, false)
		inst.AnimState:PlayAnimation("barrier_pst")
		inst.AnimState:PushAnimation("idle", false)
		shouldsfx = true
	end

	if inst.SoundEmitter:PlayingSound("loop") then
		inst.SoundEmitter:KillSound("loop")
		if shouldsfx then
			inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_close")
		end
	end
end

local function topocket(inst)--, owner)
	if inst.components.machine:IsOn() then
		inst.components.machine:TurnOff()
	end
	local anim = inst.components.fueled:IsEmpty() and "broken" or "idle"
	if not inst.AnimState:IsCurrentAnimation(anim) then
		inst.AnimState:PlayAnimation(anim)
	end
end

local function OnExitLimbo(inst)
	--unfortunately returning to scene always re-enables shadow
	if not inst.components.machine:IsOn() then
		inst.DynamicShadow:Enable(false)
	end
end

local function OnLoad(inst)
	if inst.components.fueled:IsEmpty() then
		OnPerish(inst)
	end
end

local function UmbrellaFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst.DynamicShadow:SetSize(1.1, .7)
	inst.DynamicShadow:Enable(false)

	inst.AnimState:SetBank("umbrella_voidcloth")
    inst.AnimState:SetBuild("umbrella_voidcloth")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nopunch")
    inst:AddTag("umbrella")
    inst:AddTag("acidrainimmune")
	inst:AddTag("shadow_item")
	inst:AddTag("show_broken_ui")
	inst:AddTag("lunarhailprotection")

    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

	--shadowlevel (from shadowlevel component) added to pristine state for optimization
	inst:AddTag("shadowlevel")

	inst.triggerfx = net_event(inst.GUID, "voidcloth_umbrella.triggerfx")
	inst.isbroken = net_bool(inst.GUID, "voidcloth_umbrella.isbroken", "isbrokendirty")

	inst:AddComponent("floater")
	SetIsBroken(inst, false)

	--Must be added client-side, but configured server-side
	inst:AddComponent("raindome")

	inst.scrapbook_specialinfo = "VOIDCLOTHUMBRELLA"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		--delayed because we don't want any old events
		inst:DoTaskInTime(0, inst.ListenForEvent, "voidcloth_umbrella.triggerfx", CLIENT_TriggerFX)

		inst:ListenForEvent("isbrokendirty", OnIsBrokenDirty)

        return inst
    end

	inst.components.raindome:SetRadius(TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS)

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

    inst:AddComponent("insulator")
    inst.components.insulator:SetSummer()
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled:InitializeFuelLevel(TUNING.VOIDCLOTH_UMBRELLA_PERISHTIME)

	SetupEquippable(inst)

	inst:AddComponent("machine")
	inst.components.machine:SetGroundOnlyMachine(true)
	inst.components.machine.turnonfn = turnon
	inst.components.machine.turnofffn = turnoff
	inst.components.machine.cooldowntime = 0.5

	inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(TUNING.VOIDCLOTH_UMBRELLA_SHADOW_LEVEL)

	MakeForgeRepairable(inst, FORGEMATERIALS.VOIDCLOTH, nil, OnRepaired)

	--V2C: handle this ourselves rather than passing it to MakeForgeRepairable
	inst.components.fueled:SetDepletedFn(OnPerish)

    MakeHauntableLaunch(inst)

    inst.OnIsAcidRaining = OnIsAcidRaining -- Mods.

	inst:ListenForEvent("onputininventory", topocket)
	inst:ListenForEvent("floater_startfloating", topocket)
	inst:ListenForEvent("exitlimbo", OnExitLimbo)

	inst.OnLoad = OnLoad

    return inst
end

local function CreateFxFollowFrame()
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst:AddTag("FX")

	inst.AnimState:SetBank("umbrella_voidcloth")
	inst.AnimState:SetBuild("umbrella_voidcloth")
	inst.AnimState:PlayAnimation("swap_loop1", true)
	inst.AnimState:SetSymbolLightOverride("lightning", 1)

	inst:AddComponent("highlightchild")

	inst.persists = false

	return inst
end

local function FxOnRemoveEntity(inst)
	inst.fx:Remove()
end

local function FxColourChanged(inst, r, g, b, a)
	inst.fx.AnimState:SetAddColour(r, g, b, a)
end

local function FxOnEntityReplicated(inst)
	local owner = inst.entity:GetParent()
	if owner ~= nil then
		inst.fx = CreateFxFollowFrame()
		inst.fx.entity:SetParent(owner.entity)
		inst.fx.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, 5, 8)
		inst.fx.components.highlightchild:SetOwner(owner)
		inst.components.colouraddersync:SetColourChangedFn(FxColourChanged)
		inst.OnRemoveEntity = FxOnRemoveEntity
	end
end

local function FxAttachToOwner(inst, owner)
	inst.entity:SetParent(owner.entity)
	inst.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, 0, 2)
	inst.components.highlightchild:SetOwner(owner)
	if owner.components.colouradder ~= nil then
		owner.components.colouradder:AttachChild(inst)
	end

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		FxOnEntityReplicated(inst)
	end
end

local function FollowSymbolFxFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

	inst.AnimState:SetBank("umbrella_voidcloth")
    inst.AnimState:SetBuild("umbrella_voidcloth")
    inst.AnimState:PlayAnimation("swap_loop1", true)
    inst.AnimState:SetSymbolLightOverride("lightning", 1)

    inst:AddComponent("highlightchild")
	inst:AddComponent("colouraddersync")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst.OnEntityReplicated = FxOnEntityReplicated

        return inst
    end

	inst.AttachToOwner = FxAttachToOwner
    inst.persists = false

    return inst
end

return
        Prefab("voidcloth_umbrella",    UmbrellaFn,       assets, prefabs),
        Prefab("voidcloth_umbrella_fx", FollowSymbolFxFn, assets         )
