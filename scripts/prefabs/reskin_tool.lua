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
	anchor = { offset = 0.2, scale = 1.3 },
	arrowsign_post = { offset = 0.9, scale = 1.2 },
	beebox = { scale = 1.4 },
	bernie_big = { offset = 1.2, scale = 1.8 },
	birdcage = { offset = 1.2, scale = 1.8 },
	bugnet = { offset = 0.4 },
	campfire = { scale = 1.2 },
	cane = { offset = 0.4 },
	cavein_boulder = { scale = 1.4 },
	coldfirepit = { scale = 1.2 },
	cookpot = { offset = 0.5, scale = 1.4 },
	critter_dragonling = { offset = 0.8 },
	critter_glomling = { offset = 0.8 },
	dragonflychest = { offset = 0.1, scale = 1.4 },
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
	mast_malbatross = { offset = 4, scale = 2 },
	meatrack = { offset = 1, scale = 1.7 },
	mermhouse_crafted = { offset = 1.5, scale = 2.2 },
	monkey_mediumhat = { scale = 1.2 },
	mushroom_light = { offset = 1.2, scale = 1.4 },
	mushroom_light2 = { offset = 1.2, scale = 1.8 },
	nightsword = { offset = 0.2 },
	oceanfishingrod = { offset = -0.4 },
	opalstaff = { offset = 0.4 },
	orangestaff = { offset = 0.4 },
	pighouse = { offset = 1.5, scale = 2.2 },
	rabbithouse = { offset = 1.5, scale = 2.2 },
	rainometer = { offset = 0.9, scale = 1.6 },
	researchlab = { offset = 0.5, scale = 1.4 },
	researchlab2 = { offset = 0.5, scale = 1.4 },
	researchlab3 = { offset = 0.5, scale = 1.4 },
	researchlab4 = { offset = 0.5, scale = 1.4 },
	ruins_bat = { offset = 0.4, scale = 1.2 },
	saltbox = { offset = 0.3, scale = 1.3 },
	sculptingtable = { scale = 1.2 },
	seafaring_prototyper = { offset = 0.5, scale = 1.5 },
	shovel = { offset = 0.2 },
	siestahut = { scale = 1.8 },
	spear = { offset = 0.4 },
	spear_wathgrithr = { offset = 0.4 },
	stagehand = { offset = 0.2, scale = 1.3 },
	telebase = { scale = 1.6 },
	tent = { offset = 0.4, scale = 2.0 },
	treasurechest = { offset = 0.1, scale = 1.1 },
	treasurechest_upgraded = { offset = 0.1, scale = 1.3 },
	umbrella = { offset = 0.4 },
	wall_moonrock = { offset = 0.2, scale = 1.2 },
	wall_ruins = { offset = 0.2, scale = 1.3 },
	wall_stone = { offset = 0.2, scale = 1.3 },
	wardrobe = { offset = 0.5, scale = 1.4 },
	winterometer = { offset = 0.8, scale = 1.3 },
	wormhole = { scale = 1.3 },
	yellowstaff = { offset = 0.4 },
    mighty_gym = {offset = 2, scale = 2.7},
}
local function GetReskinFXInfo(target)
    if target.prefab == "treasurechest" and target._chestupgrade_stacksize then
        return reskin_fx_info["treasurechest_upgraded"]
    end

    return reskin_fx_info[target.prefab] or {}
end

-- Testing and viewing skins on a more close level.
if CAN_USE_DBUI then
    require("dbui_no_package/debug_skins_data/hooks").Hooks("fxinfo", reskin_fx_info)
end



local function spellCB(tool, target, pos, caster)
	target = target or caster --if no target, then self target for beards
    if target == nil then -- Bail.
        return
    end

    local fx_prefab = "explode_reskin"
    local skin_fx = SKIN_FX_PREFAB[tool:GetSkinName()]
    if skin_fx ~= nil and skin_fx[1] ~= nil then
        fx_prefab = skin_fx[1]
    end

    local fx = SpawnPrefab(fx_prefab)

    local fx_info = GetReskinFXInfo(target)

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

        if target:IsValid() and tool:IsValid() and tool.parent and tool.parent:IsValid() then
            local curr_skin = is_beard and target.components.beard.skinname or target.skinname
            local userid = tool.parent.userid or ""
            local cached_skin = tool._cached_reskinname[prefab_to_skin]
            local search_for_skin = cached_skin ~= nil --also check if it's owned
            if curr_skin == cached_skin or (search_for_skin and not TheInventory:CheckClientOwnership(userid, cached_skin)) then
                local new_reskinname = nil

                if PREFAB_SKINS[prefab_to_skin] ~= nil then
                    local must_have, must_not_have
                    if target.ReskinToolFilterFn ~= nil then
                        must_have, must_not_have = target:ReskinToolFilterFn()
                    end
                    for _,item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
                        local skip_this = PREFAB_SKINS_SHOULD_NOT_SELECT[item_type] or false
                        if not skip_this then
                            if must_have ~= nil and not StringContainsAnyInArray(item_type, must_have) or must_not_have ~= nil and StringContainsAnyInArray(item_type, must_not_have) then
                                skip_this = true
                            end
                            if not skip_this then
                                if search_for_skin then
                                    if cached_skin == item_type then
                                        search_for_skin = false
                                    end
                                else
                                    if TheInventory:CheckClientOwnership(userid, item_type) then
                                        new_reskinname = item_type
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                tool._cached_reskinname[prefab_to_skin] = new_reskinname
                cached_skin = new_reskinname
            end

            if is_beard then
                target.components.beard:SetSkin( cached_skin )
            else
                TheSim:ReskinEntity( target.GUID, target.skinname, cached_skin, nil, userid )

				--Todo(Peter): make this better one day if we do more skins applied to multiple prefabs in the future
                if target.prefab == "wormhole" then
                    local other = target.components.teleporter.targetTeleporter
                    if other ~= nil then
                        TheSim:ReskinEntity( other.GUID, other.skinname, cached_skin, nil, userid )
                    end
                elseif target.prefab == "cave_entrance" or target.prefab == "cave_entrance_open" or target.prefab == "cave_exit" then
                    if target.components.worldmigrator:IsLinked() and Shard_IsWorldAvailable(target.components.worldmigrator.linkedWorld) then
                        local skin_theme = ""
                        if target.skinname ~= nil then
                            skin_theme = string.sub( target.skinname, string.len(target.prefab) + 2 )
                        end

                        SendRPCToShard(SHARD_RPC.ReskinWorldMigrator, target.components.worldmigrator.linkedWorld, target.components.worldmigrator.id, skin_theme, target.skin_id, TheNet:GetSessionIdentifier() )
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
            if not PREFAB_SKINS_SHOULD_NOT_SELECT[item_type] and TheInventory:CheckClientOwnership(doer.userid, item_type) then
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
    inst.scrapbook_specialinfo = "RESKINTOOL"

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