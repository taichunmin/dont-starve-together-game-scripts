local assets =
{
    Asset("ANIM", "anim/gnarwail_horn.zip"),
    Asset("ANIM", "anim/swap_gnarwailhorn.zip"),
    Asset("INV_IMAGE", "gnarwail_horn"),
}

local prefabs =
{
    "wave_splash"
}

local function reticuletargetfunction(inst)
    return Vector3(ThePlayer.entity:LocalToWorldSpace(3.5, 0.001, 0))
end

local function onusesfinished(inst)
    if inst.components.inventoryitem.owner ~= nil then
        inst.components.inventoryitem.owner:PushEvent("toolbroke", { tool = inst })
    end

    inst:Remove()
end

local function onequipped(inst, equipper)
    equipper.AnimState:OverrideSymbol("swap_object", "swap_gnarwailhorn", "swap_gnarwailhorn")
    equipper.AnimState:Show("ARM_carry")
    equipper.AnimState:Hide("ARM_normal")
end

local function onunequipped(inst, equipper)
    equipper.AnimState:Hide("ARM_carry")
    equipper.AnimState:Show("ARM_normal")
end

local PLANT_TAGS = {"tendable_farmplant"}

local function create_waves(inst, target, position)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner == nil then
        return
    end

    local angle = owner:GetAngleToPoint(position:Get())
    local angle_rads = angle * DEGREES

    local offset1 = Vector3(math.cos(angle_rads + PI/2), 0, -math.sin(angle_rads + PI/2)) * 1.5
    local wp1 = position + offset1
    local s1 = SpawnAttackWave(wp1, angle, nil, nil, 0.5, true)
    if s1 then
        local splash = SpawnPrefab("wave_splash")
        splash.Transform:SetPosition(wp1:Get())
        splash.Transform:SetRotation(angle)
    end

    local offset2 = Vector3(math.cos(angle_rads - PI/2), 0, -math.sin(angle_rads - PI/2)) * 1.5
    local wp2 = position + offset2
    local s2 = SpawnAttackWave(wp2, angle, nil, nil, 0.5, true)
    if s2 then
        local splash = SpawnPrefab("wave_splash")
        splash.Transform:SetPosition(wp2:Get())
        splash.Transform:SetRotation(angle)
    end

    if s1 or s2 then
        inst.components.finiteuses:Use(1)
    end

    local x, y, z = owner.Transform:GetWorldPosition()
    for _, v in pairs(TheSim:FindEntities(x, y, z, TUNING.GNARWAIL_HORN_FARM_PLANT_INTERACT_RANGE, PLANT_TAGS)) do
		if v.components.farmplanttendable ~= nil then
			v.components.farmplanttendable:TendTo(owner)
		end
	end

end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("gnarwail_horn")
    inst:AddTag("nopunch")
    inst:AddTag("allow_action_on_impassable")

    inst.spelltype = "MUSIC"

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = reticuletargetfunction
    inst.components.reticule.ease = true
    inst.components.reticule.ispassableatallpoints = true

    inst.AnimState:SetBank("gnarwail")
    inst.AnimState:SetBuild("gnarwail_horn")
    inst.AnimState:PlayAnimation("horn_idle")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    MakeHauntableLaunch(inst)

    ---------------------------------------------------------------------

    inst:AddComponent("inspectable")

    ---------------------------------------------------------------------

    inst:AddComponent("inventoryitem")

    ---------------------------------------------------------------------

    inst:AddComponent("tradable")

    ---------------------------------------------------------------------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.GNARWAIL_HORN.USES)
    inst.components.finiteuses:SetUses(TUNING.GNARWAIL_HORN.USES)
    inst.components.finiteuses:SetOnFinished(onusesfinished)

    ---------------------------------------------------------------------

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequipped)
    inst.components.equippable:SetOnUnequip(onunequipped)

    ---------------------------------------------------------------------

    inst.playsound = "hookline/creatures/gnarwail/horn"

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(create_waves)
    inst.components.spellcaster.canuseonpoint_water = true

    return inst
end

return Prefab("gnarwail_horn", fn, assets, prefabs)
