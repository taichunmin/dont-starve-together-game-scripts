local assets =
{
    Asset("ANIM", "anim/torch.zip"),
    Asset("ANIM", "anim/swap_torch.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "torchfire",
}

local function DoIgniteSound(inst, owner)
	inst._ignitesoundtask = nil
    local se = (owner ~= nil and owner:IsValid() and owner or inst).SoundEmitter
    if se ~= nil then
        se:PlaySound("dontstarve/wilson/torch_swing")
    end
end

local function DoExtinguishSound(inst, owner)
	inst._extinguishsoundtask = nil
    local se = (owner ~= nil and owner:IsValid() and owner or inst).SoundEmitter
    if se ~= nil then
       se:PlaySound("dontstarve/common/fireOut")
    end
end

local function PlayIgniteSound(inst, owner, instant, force)
	if inst._extinguishsoundtask ~= nil then
		inst._extinguishsoundtask:Cancel()
		inst._extinguishsoundtask = nil
		if not force then
			return
		end
	end
	if instant then
		if inst._ignitesoundtask ~= nil then
			inst._ignitesoundtask:Cancel()
		end
		DoIgniteSound(inst, owner)
	elseif inst._ignitesoundtask == nil then
		inst._ignitesoundtask = inst:DoTaskInTime(0, DoIgniteSound, owner)
	end
end

local function PlayExtinguishSound(inst, owner, instant, force)
	if inst._ignitesoundtask ~= nil then
		inst._ignitesoundtask:Cancel()
		inst._ignitesoundtask = nil
		if not force then
			return
		end
	end
	if instant then
		if inst._extinguishsoundtask ~= nil then
			inst._extinguishsoundtask:Cancel()
		end
		DoExtinguishSound(inst, owner)
	elseif inst._extinguishsoundtask == nil then
		inst._extinguishsoundtask = inst:DoTaskInTime(0, DoExtinguishSound, owner)
	end
end

local function OnRemoveEntity(inst)
	--Due to timing of unequip on removal, we may have passed CancelAllPendingTasks already.
	if inst._ignitesoundtask ~= nil then
		inst._ignitesoundtask:Cancel()
		inst._ignitesoundtask = nil
	end
	if inst._extinguishsoundtask ~= nil then
		inst._extinguishsoundtask:Cancel()
		inst._extinguishsoundtask = nil
	end
end

local function applyskillbrightness(inst, value)
    if inst.fires then
        for i,fx in ipairs(inst.fires) do
            fx:SetLightRange(value)
        end
    end
end

local function applyskillfueleffect(inst, value)
	if value ~= 1 then
		inst.components.fueled.rate_modifiers:SetModifier(inst, value, "wilsonskill")
	else
		inst.components.fueled.rate_modifiers:RemoveModifier(inst, "wilsonskill")
	end
end

local function getskillfueleffectmodifier(skilltreeupdater)
	return (skilltreeupdater:IsActivated("wilson_torch_3") and TUNING.SKILLS.WILSON_TORCH_3)
		or (skilltreeupdater:IsActivated("wilson_torch_2") and TUNING.SKILLS.WILSON_TORCH_2)
		or (skilltreeupdater:IsActivated("wilson_torch_1") and TUNING.SKILLS.WILSON_TORCH_1)
		or 1
end

local function getskillbrightnesseffectmodifier(skilltreeupdater)
	return (skilltreeupdater:IsActivated("wilson_torch_6") and TUNING.SKILLS.WILSON_TORCH_6)
		or (skilltreeupdater:IsActivated("wilson_torch_5") and TUNING.SKILLS.WILSON_TORCH_5)
		or (skilltreeupdater:IsActivated("wilson_torch_4") and TUNING.SKILLS.WILSON_TORCH_4)
		or 1
end

local function RefreshAttunedSkills(inst, owner)
	local skilltreeupdater = owner and owner.components.skilltreeupdater or nil
	if skilltreeupdater then
		applyskillbrightness(inst, getskillbrightnesseffectmodifier(skilltreeupdater))
		applyskillfueleffect(inst, getskillfueleffectmodifier(skilltreeupdater))
	else
		applyskillbrightness(inst, 1)
		applyskillfueleffect(inst, 1)
	end
end

local function WatchSkillRefresh(inst, owner)
	if inst._owner then
		inst:RemoveEventCallback("onactivateskill_server", inst._onskillrefresh, inst._owner)
		inst:RemoveEventCallback("ondeactivateskill_server", inst._onskillrefresh, inst._owner)
	end
	inst._owner = owner
	if owner then
		inst:ListenForEvent("onactivateskill_server", inst._onskillrefresh, owner)
		inst:ListenForEvent("ondeactivateskill_server", inst._onskillrefresh, owner)
	end
end

local function onequip(inst, owner)
    inst.components.burnable:Ignite()

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_torch", inst.GUID, "swap_torch")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_torch", "swap_torch")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

	PlayIgniteSound(inst, owner, true, false)

    if inst.fires == nil then
        inst.fires = {}

        for i, fx_prefab in ipairs(inst:GetSkinName() == nil and { "torchfire" } or SKIN_FX_PREFAB[inst:GetSkinName()] or {}) do
            local fx = SpawnPrefab(fx_prefab)
            fx.entity:SetParent(owner.entity)
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(owner.GUID, "swap_object", fx.fx_offset_x or 0, fx.fx_offset, 0)
            fx:AttachLightTo(owner)
            if fx.AssignSkinData ~= nil then
                fx:AssignSkinData(inst)
            end

            table.insert(inst.fires, fx)
        end
    end

	WatchSkillRefresh(inst, owner)
	RefreshAttunedSkills(inst, owner)
end

local function onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.fires ~= nil then
        for i, fx in ipairs(inst.fires) do
            fx:Remove()
        end
        inst.fires = nil
		PlayExtinguishSound(inst, owner, false, false)
    end

    inst.components.burnable:Extinguish()
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

	WatchSkillRefresh(inst, nil)
	RefreshAttunedSkills(inst, nil)
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.fires ~= nil then
        for i, fx in ipairs(inst.fires) do
            fx:Remove()
        end
        inst.fires = nil
		PlayExtinguishSound(inst, owner, true, false)
    end

    inst.components.burnable:Extinguish()
end

local function onpocket(inst, owner)
	--V2C: I think this is redundant, otherwise it would've needed fire fx cleanup as well
    inst.components.burnable:Extinguish()
end

local function onattack(weapon, attacker, target)
    --target may be killed or removed in combat damage phase
    if target ~= nil and target:IsValid() and target.components.burnable ~= nil and (math.random() < TUNING.TORCH_ATTACK_IGNITE_PERCENT * target.components.burnable.flammability or attacker.components.skilltreeupdater:IsActivated("willow_controlled_burn_1")) then
        target.components.burnable:Ignite(nil, attacker)
    end
end

local function onupdatefueledraining(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local owner_protected = owner ~= nil and (owner.components.sheltered ~= nil and owner.components.sheltered.sheltered or owner.components.rainimmunity ~= nil)
    inst.components.fueled.rate =
        (owner_protected or inst.components.rainimmunity ~= nil) and (inst._fuelratemult or 1) or
        (1 + TUNING.TORCH_RAIN_RATE * TheWorld.state.precipitationrate) * (inst._fuelratemult or 1)
end

local function onisraining(inst, israining)
    if inst.components.fueled ~= nil then
        if israining then
            inst.components.fueled:SetUpdateFn(onupdatefueledraining)
            onupdatefueledraining(inst)
        else
            inst.components.fueled:SetUpdateFn()
            inst.components.fueled.rate = inst._fuelratemult or 1
        end
    end
end

local function onfuelchange(newsection, oldsection, inst)
    if newsection <= 0 then
        --when we burn out
        if inst.components.burnable ~= nil then
            inst.components.burnable:Extinguish()
        end
		local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
		if owner ~= nil then
			local equippable = inst.components.equippable
			if equippable ~= nil and equippable:IsEquipped() then
                local data =
                {
                    prefab = inst.prefab,
                    equipslot = equippable.equipslot,
                    announce = "ANNOUNCE_TORCH_OUT",
                }
				PlayExtinguishSound(inst, owner, true, false)
				inst:Remove() --need to remove before "itemranout" for auto-reequip to work
                owner:PushEvent("itemranout", data)
			else
				inst:Remove()
            end
		elseif inst.fires ~= nil then
			for i, fx in ipairs(inst.fires) do
				fx:Remove()
			end
			inst.fires = nil
			PlayExtinguishSound(inst, nil, true, false)
			inst.persists = false
			inst:AddTag("NOCLICK")
			ErodeAway(inst)
		else
			--Shouldn't reach here
			inst:Remove()
        end
    end
end

local function SetFuelRateMult(inst, mult)
    mult = mult ~= 1 and mult or nil

    if inst._fuelratemult ~= mult then
        inst._fuelratemult = mult
        onisraining(inst, TheWorld.state.israining)
    end
end

local function IgniteTossed(inst)
	inst.components.burnable:Ignite()

	if inst.fires == nil then
		inst.fires = {}

		for i, fx_prefab in ipairs(inst:GetSkinName() == nil and { "torchfire" } or SKIN_FX_PREFAB[inst:GetSkinName()] or {}) do
			local fx = SpawnPrefab(fx_prefab)
			fx.entity:SetParent(inst.entity)
			fx.entity:AddFollower()
			fx.Follower:FollowSymbol(inst.GUID, "swap_torch", fx.fx_offset_x or 0, fx.fx_offset, 0)
			fx:AttachLightTo(inst)
			if fx.AssignSkinData ~= nil then
				fx:AssignSkinData(inst)
			end

			table.insert(inst.fires, fx)
		end
	end
    if inst.thrower then
		applyskillbrightness(inst, inst.thrower.brightnessmod or 1)
		applyskillfueleffect(inst, inst.thrower.fuelmod or 1)
    end
end

local function OnThrown(inst, thrower)
	inst.thrower = thrower and thrower.components.skilltreeupdater and {
		fuelmod = getskillfueleffectmodifier(thrower.components.skilltreeupdater),
		brightnessmod = getskillbrightnesseffectmodifier(thrower.components.skilltreeupdater),
	} or nil
	inst.AnimState:PlayAnimation("spin_loop", true)
	inst.SoundEmitter:PlaySound("wilson_rework/torch/torch_spin", "spin_loop")
	PlayIgniteSound(inst, nil, true, true)
	IgniteTossed(inst)
	inst.components.inventoryitem.canbepickedup = false
	inst:AddTag("FX") --prevent targeting, like flingo
end

local function OnHit(inst)
	inst.AnimState:PlayAnimation("land")
	inst.SoundEmitter:KillSound("spin_loop")
	inst.SoundEmitter:PlaySound("wilson_rework/torch/stick_ground")
	inst.components.inventoryitem.canbepickedup = true
	inst:RemoveTag("FX")
end

local function RemoveThrower(inst)
    if inst.thrower then
		if inst._owner == nil then
			applyskillbrightness(inst, 1)
			applyskillfueleffect(inst, 1)
		end
		inst.thrower = nil
    end
end

local function OnPutInInventory(inst, owner)
    RemoveThrower(inst)
	inst.AnimState:PlayAnimation("idle")

	if inst.fires ~= nil then
		for i, fx in ipairs(inst.fires) do
			fx:Remove()
		end
		inst.fires = nil
		PlayExtinguishSound(inst, owner, false, false)
	end

	inst.components.burnable:Extinguish()
end

local function OnExtinguish(inst)
	--V2C: Handle cases where we're extinguished externally while stuck in ground.
	--     e.g. flingo, waterballoon, icestaff
	--     NOTE: these checks should not pass for any internally handled extinguishes.
	if inst.fires ~= nil and not (inst.components.inventoryitem:IsHeld() or inst.components.fueled:IsEmpty()) then
		for i, fx in ipairs(inst.fires) do
			fx:Remove()
		end
		inst.fires = nil
		PlayExtinguishSound(inst, nil, true, false)
		--shouldn't be possible while spinning, but JUST IN CASE
		if inst:HasTag("activeprojectile") then
			inst.components.complexprojectile:Cancel()
			inst.SoundEmitter:KillSound("spin_loop")
			inst.components.inventoryitem.canbepickedup = true
			inst:RemoveTag("FX")
		end
		inst.AnimState:PlayAnimation("idle")
		local x, y, z = inst.Transform:GetWorldPosition()
		local theta = math.random() * TWOPI
		local speed = math.random()
		inst.Physics:Teleport(x, math.max(.1, y), z)
		inst.Physics:SetVel(speed * math.cos(theta), 8 + math.random(), -speed * math.sin(theta))
	end
end

local function OnSave(inst, data)
	if inst.components.burnable:IsBurning() and not inst.components.inventoryitem:IsHeld() then
		if inst.thrower ~= nil then
			data.thrower = inst.thrower
		else
			data.lit = true
		end
	end
end

local function OnLoad(inst, data)
	if data ~= nil and (data.lit or data.thrower ~= nil) and not inst.components.inventoryitem:IsHeld() then
		inst.AnimState:PlayAnimation("land")
		inst.thrower = data.thrower
		IgniteTossed(inst)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("torch")
    inst.AnimState:SetBuild("swap_torch")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("wildfireprotected")

    --lighter (from lighter component) added to pristine state for optimization
    inst:AddTag("lighter")

    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

	--projectile (from complexprojectile component) added to pristine state for optimization
	inst:AddTag("projectile")

	--Only get TOSS action via PointSpecialActions
    inst:AddTag("special_action_toss")
	inst:AddTag("keep_equip_toss")

	MakeInventoryFloatable(inst, "med", nil, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.TORCH_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)

    -----------------------------------
    inst:AddComponent("lighter")
    -----------------------------------

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	inst.components.inventoryitem:SetOnPickupFn(RemoveThrower)

    -----------------------------------

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnPocket(onpocket)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

	-----------------------------------

	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetHorizontalSpeed(15)
	inst.components.complexprojectile:SetGravity(-35)
	inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
	inst.components.complexprojectile:SetOnLaunch(OnThrown)
	inst.components.complexprojectile:SetOnHit(OnHit)
	inst.components.complexprojectile.ismeleeweapon = true

    -----------------------------------

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

    -----------------------------------

    inst:AddComponent("inspectable")

    -----------------------------------

    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil
	inst.components.burnable:SetOnExtinguishFn(OnExtinguish)

    -----------------------------------

    inst:AddComponent("fueled")
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:InitializeFuelLevel(TUNING.TORCH_FUEL)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

	inst._onskillrefresh = function(owner) RefreshAttunedSkills(inst, owner) end

    inst:WatchWorldState("israining", onisraining)
    onisraining(inst, TheWorld.state.israining)

    inst._fuelratemult = nil
    inst.SetFuelRateMult = SetFuelRateMult

    MakeHauntableLaunch(inst)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnRemoveEntity = OnRemoveEntity

    return inst
end

return Prefab("torch", fn, assets, prefabs)
