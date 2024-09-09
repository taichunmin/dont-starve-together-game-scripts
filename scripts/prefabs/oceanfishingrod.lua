local assets =
{
    Asset("ANIM", "anim/fishingrod_ocean.zip"),
    Asset("ANIM", "anim/swap_fishingrod_ocean.zip"),
}

local prefabs =
{
	"oceanfishingbobber_none_projectile",
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_fishingrod_ocean", inst.GUID, "swap_fishingrod_ocean")
        owner.AnimState:OverrideItemSkinSymbol("fishingline", skin_build, "fishingline",           inst.GUID, "swap_fishingrod_ocean")
        owner.AnimState:OverrideItemSkinSymbol("FX_fishing",  skin_build, "FX_fishing",            inst.GUID, "swap_fishingrod_ocean")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_fishingrod_ocean", "swap_fishingrod_ocean")
        owner.AnimState:OverrideSymbol("fishingline", "swap_fishingrod_ocean", "fishingline")
        owner.AnimState:OverrideSymbol("FX_fishing", "swap_fishingrod_ocean", "FX_fishing")
    end

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("fishingline")
    owner.AnimState:ClearOverrideSymbol("FX_fishing")

    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function GetTackle(inst)
	return (inst.components.oceanfishingrod ~= nil and inst.components.container ~= nil) and
		{
			bobber = inst.components.container.slots[1],
			lure = inst.components.container.slots[2]
		}
		or {}
end

local function OnTackleChanged(inst, data)
	if inst.components.oceanfishingrod ~= nil then
		inst.components.oceanfishingrod:UpdateClientMaxCastDistance()
	end
end

local OCEANFISHINGFOCUS_MUST_TAGS = {"oceanfishingfocus"}

local function reticuletargetfn(inst)
	local cast_distance = inst.replica.oceanfishingrod ~= nil and inst.replica.oceanfishingrod:GetMaxCastDist() or TUNING.OCEANFISHING_TACKLE.BASE.dist_max

    local rotation = ThePlayer.Transform:GetRotation()
    local pos = ThePlayer:GetPosition()

    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, cast_distance, OCEANFISHINGFOCUS_MUST_TAGS)
    for _, v in ipairs(ents) do
        local epos = v:GetPosition()
        if distsq(pos, epos) > math.max(cast_distance * 0.5, 3) then
            local angletoepos = inst:GetAngleToPoint(epos)
            local angleto = math.abs(anglediff(rotation, angletoepos))
            if angleto < TUNING.CONTROLLER_OCEANFISHINGFOCUS_ANGLE then
                return epos
            end
        end
    end

    return Vector3(ThePlayer.entity:LocalToWorldSpace(cast_distance, 0.001, 0)) -- raised this off the ground a touch so it wont have any z-fighting with the ground biome transition tiles.
end

local function reticuleshouldhidefn(inst)
    return inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:IsHeldBy(ThePlayer) and ThePlayer.components.playercontroller ~= nil and ThePlayer:HasTag("fishing")
end

local function OnStartedFishing(inst, fisher, target)
	if inst.components.container ~= nil then
		inst.components.container:Close()
	end
end

local function OnDoneFishing(inst, reason, lose_tackle, fisher, target)
	if inst.components.container ~= nil and lose_tackle then
		inst.components.container:DestroyContents()
	end

	if inst.components.container ~= nil and fisher ~= nil and inst.components.equippable ~= nil and inst.components.equippable.isequipped then
		inst.components.container:Open(fisher)
	end
end

local function OnHookedSomething(inst, target)
	if target ~= nil and inst.components.container then
		if target.components.oceanfishinghook ~= nil then
			if TheWorld.Map:IsOceanAtPoint(target.Transform:GetWorldPosition()) then
				for slot, item in pairs(inst.components.container.slots) do
					if item ~= nil and item.components.inventoryitem ~= nil then
						item.components.inventoryitem:MakeMoistureAtLeast(TUNING.OCEAN_WETNESS)
					end
				end
			end
		elseif not target:HasTag("projectile") then
			for slot, item in pairs(inst.components.container.slots) do
				if item ~= nil and item.components.oceanfishingtackle ~= nil and item.components.oceanfishingtackle:IsSingleUse() then
					inst.components.container:RemoveItemBySlot(slot):Remove()
				end
			end
		end
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("fishingrod_ocean")
    inst.AnimState:SetBuild("fishingrod_ocean")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon") --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("allow_action_on_impassable")
    inst:AddTag("accepts_oceanfishingtackle")

    local floater_swap_data =
    {
        sym_build = "swap_fishingrod_ocean",
        bank = "fishingrod_ocean",
    }
    MakeInventoryFloatable(inst, "med", 0.05, {0.8, 0.4, 0.8}, true, -12, floater_swap_data)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = reticuletargetfn
    inst.components.reticule.shouldhidefn = reticuleshouldhidefn
    inst.components.reticule.ease = true
    inst.components.reticule.ispassableatallpoints = true
    
    inst.scrapbook_subcat = "tool"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("oceanfishingrod")
	inst.components.oceanfishingrod:SetDefaults("oceanfishingbobber_none_projectile", TUNING.OCEANFISHING_TACKLE.BASE, TUNING.OCEANFISHING_LURE.HOOK, {build = "oceanfishing_hook", symbol = "hook"})
	inst.components.oceanfishingrod.oncastfn = OnStartedFishing
	inst.components.oceanfishingrod.ondonefishing = OnDoneFishing
	inst.components.oceanfishingrod.onnewtargetfn = OnHookedSomething
	inst.components.oceanfishingrod.gettackledatafn = GetTackle

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.FISHINGROD_DAMAGE)
    inst.components.weapon.attackwear = 4

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("oceanfishingrod")
	inst.components.container.canbeopened = false
    inst.components.container.stay_open_on_hide = true
    inst:ListenForEvent("itemget", OnTackleChanged)
    inst:ListenForEvent("itemlose", OnTackleChanged)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("oceanfishingrod", fn, assets, prefabs)
