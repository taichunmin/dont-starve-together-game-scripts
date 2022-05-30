local assets =
{
    Asset("ANIM", "anim/reskin_tool.zip"),
    Asset("ANIM", "anim/swap_reskin_tool.zip"),
    Asset("ANIM", "anim/reskin_tool_fx.zip"),
}

local prefabs =
{
    "tornado",
}

local reskin_fx_info =
{
	abigail = { offset = 1.3, scale = 1.3 },
	arrowsign_post = { offset = 0.9, scale = 1.2 },
	beebox = { scale = 1.4 },
	bernie_big = { offset = 1.2, scale = 1.8 },
	birdcage = { offset = 1.2, scale = 1.8 },
	bugnet = { offset = 0.4 },
	campfire = { scale = 1.2 },
	cane = { offset = 0.4 },
	coldfirepit = { scale = 1.2 },
	cookpot = { offset = 0.5, scale = 1.4 },
	critter_dragonling = { offset = 0.8 },
	critter_glomling = { offset = 0.8 },
	dragonflyfurnace = { offset = 0.6, scale = 1.8 },
	endtable = { offset = 0.2, scale = 1.3 },
	featherfan = { scale = 1.3 },
	featherhat = { scale = 1.1 },
	fence = { offset = 0.1, scale = 1.2 },
	fence_gate = { offset = 0.2, scale = 1.3 },
	firepit = { scale = 1.2 },
	firestaff = { offset = 0.4 },
	firesuppressor = { offset = 0.5, scale = 1.5 },
	goldenshovel = { offset = 0.2 },
	grass_umbrella = { offset = 0.4 },
	greenstaff = { offset = 0.4 },
	hambat = { offset = 0.2 },
	icebox = { offset = 0.3, scale = 1.3 },
	icestaff = { offset = 0.4 },
	lightning_rod = { offset = 0.8, scale = 1.3 },
	mast = { offset = 4, scale = 2 },
	meatrack = { offset = 1, scale = 1.7 },
	mushroom_light = { offset = 1.2, scale = 1.4 },
	mushroom_light2 = { offset = 1.2, scale = 1.8 },
	nightsword = { offset = 0.2 },
	opalstaff = { offset = 0.4 },
	orangestaff = { offset = 0.4 },
	pighouse = { offset = 1.5, scale = 2.2 },
	rabbithouse = { offset = 1.5, scale = 2.2 },
	rainometer = { offset = 0.9, scale = 1.6 },
	researchlab2 = { offset = 0.5, scale = 1.4 },
	researchlab3 = { offset = 0.5, scale = 1.4 },
	researchlab4 = { offset = 0.5, scale = 1.4 },
	ruins_bat = { offset = 0.4, scale = 1.2 },
	saltbox = { offset = 0.3, scale = 1.3 },
	shovel = { offset = 0.2 },
	spear = { offset = 0.4 },
	spear_wathgrithr = { offset = 0.4 },
	tent = { offset = 0.4, scale = 2.0 },
	treasurechest = { offset = 0.1, scale = 1.1 },
	umbrella = { offset = 0.4 },
	wardrobe = { offset = 0.5, scale = 1.4 },
	winterometer = { offset = 0.8, scale = 1.3 },
	yellowstaff = { offset = 0.4 },
}

local function spellCB(tool, target, pos)
    
    local fx_prefab = "explode_reskin"
    local skin_fx = SKIN_FX_PREFAB[tool:GetSkinName()]
    if skin_fx ~= nil and skin_fx[1] ~= nil then
        fx_prefab = skin_fx[1]
    end

    local fx = SpawnPrefab(fx_prefab)

    target = target or tool.components.inventoryitem.owner --if no target, then get the owner of the tool. Self target for beards

    local fx_info = reskin_fx_info[target.prefab] or {}

    local scale_override = fx_info.scale or 1
    fx.Transform:SetScale(scale_override, scale_override, scale_override)

    local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
    fx_pos_y = fx_pos_y + (fx_info.offset or 0)
    fx.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z)

    tool:DoTaskInTime(0, function()

        local prefab_to_skin = target.prefab
        local is_beard = false
        if target.components.beard ~= nil and target.components.beard.is_skinnable then
            prefab_to_skin = target.prefab .. "_beard"
            is_beard = true
        end

        if target:IsValid() and tool:IsValid() then
            local curr_skin = is_beard and target.components.beard.skinname or target.skinname
            local search_for_skin = tool._cached_reskinname[prefab_to_skin] ~= nil --also check if it's owned
            if curr_skin == tool._cached_reskinname[prefab_to_skin] or (search_for_skin and not TheInventory:CheckClientOwnership(tool.parent.userid, tool._cached_reskinname[prefab_to_skin])) then
                local new_reskinname = nil

                if PREFAB_SKINS[prefab_to_skin] ~= nil then
                    for _,item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
                        if search_for_skin then
                            if tool._cached_reskinname[prefab_to_skin] == item_type then
                                search_for_skin = false
                            end
                        else
                            if TheInventory:CheckClientOwnership(tool.parent.userid, item_type) then
                                new_reskinname = item_type
                                break
                            end
                        end
                    end
                end
                tool._cached_reskinname[prefab_to_skin] = new_reskinname
            end

            if is_beard then
                target.components.beard:SetSkin( tool._cached_reskinname[prefab_to_skin] )
            else
                TheSim:ReskinEntity( target.GUID, target.skinname, tool._cached_reskinname[prefab_to_skin], nil, tool.parent.userid )

				--Todo(Peter): make this better one day if we do more skins applied to multiple prefabs in the future
                if target.prefab == "wormhole" then
                    local other = target.components.teleporter.targetTeleporter
                    if other ~= nil then
                        TheSim:ReskinEntity( other.GUID, other.skinname, tool._cached_reskinname[prefab_to_skin], nil, tool.parent.userid )
                    end
                end
            end
        end
    end )
end

local function can_cast_fn(doer, target, pos)

    local prefab_to_skin = target.prefab
    local is_beard = false

    if table.contains( DST_CHARACTERLIST, prefab_to_skin ) then
        --We found a player, check if it's us
        if doer.userid == target.userid and target.components.beard ~= nil and target.components.beard.is_skinnable then
            prefab_to_skin = target.prefab .. "_beard"
            is_beard = true
        else
            return false
        end
    end

    if PREFAB_SKINS[prefab_to_skin] ~= nil then
        for _,item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
            if TheInventory:CheckClientOwnership(doer.userid, item_type) then
                return true
            end
        end
    end

    --Is there a skin to turn off?
    local curr_skin = is_beard and target.components.beard.skinname or target.skinname
    if curr_skin ~= nil then
        return true
    end

    return false
end


local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_reskin_tool", inst.GUID, "swap_reskin_tool")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_reskin_tool", "swap_reskin_tool")
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

local function tool_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("reskin_tool")
    inst.AnimState:SetBuild("reskin_tool")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nopunch")

    inst.spelltype = "RESKIN"

    --Sneak these into pristine state for optimization
    inst:AddTag("veryquickcast")

    --inst.spelltype = "SCIENCE"

    local swap_data = {sym_build = "swap_reskin_tool", bank = "reskin_tool"}
    MakeInventoryFloatable(inst, "med", 0.05, {1.0, 0.4, 1.0}, true, -20, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canuseondead = true
    inst.components.spellcaster.veryquickcast = true
    inst.components.spellcaster.canusefrominventory  = true
    inst.components.spellcaster:SetSpellFn(spellCB)
    inst.components.spellcaster:SetCanCastFn(can_cast_fn)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst._cached_reskinname = {}

    return inst
end

return Prefab("reskin_tool", tool_fn, assets, prefabs)