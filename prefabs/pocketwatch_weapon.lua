
local assets =
{
    Asset("ANIM", "anim/pocketwatch_weapon.zip"),
}

local prefabs = 
{
	"pocketwatch_weapon_fx",
}

local function TryStartFx(inst, owner)
	owner = owner
			or inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner
			or nil

	if owner == nil then
		return
	end

	if not inst.components.fueled:IsEmpty() then
		if inst._vfx_fx_inst ~= nil and inst._vfx_fx_inst.entity:GetParent() ~= owner then
			inst._vfx_fx_inst:Remove()
			inst._vfx_fx_inst = nil
		end

		if inst._vfx_fx_inst == nil then
			inst._vfx_fx_inst = SpawnPrefab("pocketwatch_weapon_fx")
			inst._vfx_fx_inst.entity:AddFollower()
			inst._vfx_fx_inst.entity:SetParent(owner.entity)
			inst._vfx_fx_inst.Follower:FollowSymbol(owner.GUID, "swap_object", 15, 70, 0)
		end
	end
end

local function StopFx(inst)
    if inst._vfx_fx_inst ~= nil then
        inst._vfx_fx_inst:Remove()
        inst._vfx_fx_inst = nil
    end
end

-------------------------------------------------------------------------------
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "pocketwatch_weapon", "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

	TryStartFx(inst, owner)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

	StopFx(inst)
end

local function onattack(inst, attacker, target)
	if not inst.components.fueled:IsEmpty() then
		inst.components.fueled:DoDelta(-TUNING.TINY_FUEL)

		if attacker == nil or attacker.age_state == nil or attacker.age_state == "young" then
			inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/shadow_attack")
		else
			-- fx will handle sounds
		end
	else
        inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/attack")
	end
end

local function GetStatus(inst, viewer)
	return (viewer:HasTag("pocketwatchcaster") and inst.components.fueled:IsEmpty()) and "DEPLETED"
			or nil
end

local function OnFuelChanged(inst, data)
    if data and data.percent then
        if data.percent > 0 then
            if not inst:HasTag("shadow_item") then
                inst:AddTag("shadow_item")
			    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_SHADOW_DAMAGE)
				TryStartFx(inst)
            end
        else
            inst:RemoveTag("shadow_item")
		    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_DEPLETED_DAMAGE)
			StopFx(inst)
        end
    end
end

local function OnTakeFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst:AddTag("pocketwatch")

    inst.AnimState:SetBank("pocketwatch_weapon")
    inst.AnimState:SetBuild("pocketwatch_weapon")
    inst.AnimState:PlayAnimation("idle", true)

    MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("lootdropper")
	
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.restrictedtag = "pocketwatchcaster"

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_SHADOW_DAMAGE)
    inst.components.weapon:SetRange(TUNING.WHIP_RANGE)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
    inst.components.fueled:InitializeFuelLevel(4 * TUNING.LARGE_FUEL)
    inst.components.fueled.accepting = true
	inst.components.fueled:SetTakeFuelFn(OnTakeFuel)

    inst:ListenForEvent("percentusedchange", OnFuelChanged)
	
    inst:DoTaskInTime(0, function() 
        OnFuelChanged(inst, { percent = inst.components.fueled:GetPercent() })
    end)

    MakeHauntableLaunch(inst)

    return inst
end

--------------------------------------------------------------------------------

return Prefab("pocketwatch_weapon", fn, assets, prefabs)
