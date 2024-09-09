require "prefabutil"

local assets_regular =
{
	Asset("ANIM", "anim/treasure_chest_upgraded.zip"),
}

local prefabs_regular =
{
	"collapse_small",
	"chestupgrade_stacksize_fx",
	"alterguardianhatshard",
	"collapsed_treasurechest",
}

local SUNKEN_PHYSICS_RADIUS = .45

local SOUNDS = {
    open  = "dontstarve/wilson/chest_open",
    close = "dontstarve/wilson/chest_close",
    built = "dontstarve/common/chest_craft",
}

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")

        if inst.skin_open_sound then
            inst.SoundEmitter:PlaySound(inst.skin_open_sound)
        else
            inst.SoundEmitter:PlaySound(inst.sounds.open)
        end
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)

        if inst.skin_close_sound then
            inst.SoundEmitter:PlaySound(inst.skin_close_sound)
        else
            inst.SoundEmitter:PlaySound(inst.sounds.close)
        end
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
    end
end

--V2C: also used for restoredfromcollapsed
local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    if inst.skin_place_sound then
        inst.SoundEmitter:PlaySound(inst.skin_place_sound)
    else
        inst.SoundEmitter:PlaySound(inst.sounds.built)
    end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

local function MakeChest(name, bank, build, indestructible, master_postinit, prefabs, assets, common_postinit, force_non_burnable)
    local default_assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
        Asset("ANIM", "anim/ui_chest_3x3.zip"),
        Asset("ANIM", "anim/ui_chest_upgraded_3x3.zip"),
    }
    assets = assets ~= nil and JoinArrays(assets, default_assets) or default_assets

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon(name..".png")

        inst:AddTag("structure")
        inst:AddTag("chest")

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("closed")
        inst.scrapbook_anim="closed"

        if name == "pandoraschest" or name == "terrariumchest" then
            inst.scrapbook_specialinfo = "TREASURECHEST"
        end

		MakeSnowCoveredPristine(inst)

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.sounds = SOUNDS

        inst:AddComponent("inspectable")
        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)
        inst.components.container.onopenfn = onopen
        inst.components.container.onclosefn = onclose
        inst.components.container.skipclosesnd = true
        inst.components.container.skipopensnd = true


        if not indestructible then
            inst:AddComponent("lootdropper")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(2)
            inst.components.workable:SetOnFinishCallback(onhammered)
            inst.components.workable:SetOnWorkCallback(onhit)

            if not force_non_burnable then
                MakeSmallBurnable(inst, nil, nil, true)
                MakeMediumPropagator(inst)
            end
        end

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst:ListenForEvent("onbuilt", onbuilt)
        MakeSnowCovered(inst)

		-- Save / load is extended by some prefab variants
        inst.OnSave = onsave
        inst.OnLoad = onload

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

--------------------------------------------------------------------------
--[[ regular ]]
--------------------------------------------------------------------------

local function regular_getstatus(inst, viewer)
	return inst._chestupgrade_stacksize and "UPGRADED_STACKSIZE" or nil
end

local function regular_ConvertToCollapsed(inst, droploot, burnt)
	if inst.components.burnable and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end

	local x, y, z = inst.Transform:GetWorldPosition()
	if droploot then
		local fx = SpawnPrefab("collapse_small")
		fx.Transform:SetPosition(x, y, z)
		fx:SetMaterial("wood")
		inst.components.lootdropper.min_speed = 2.25
		inst.components.lootdropper.max_speed = 2.75
		if burnt then
			inst:AddTag("burnt")
			inst.components.lootdropper:DropLoot()
			inst:RemoveTag("burnt")
		else
			inst.components.lootdropper:DropLoot()
		end
		inst.components.lootdropper.min_speed = nil
		inst.components.lootdropper.max_speed = nil
	end

	inst.components.container:Close()
	inst.components.workable:SetWorkLeft(2)

	local pile = SpawnPrefab("collapsed_treasurechest")
	pile.Transform:SetPosition(x, y, z)
	pile:SetChest(inst, burnt)
end

local function regular_Upgrade_OnHit(inst, worker)
	if not inst:HasTag("burnt") then
		if inst.components.container then
			inst.components.container:DropEverything(nil, true)
			inst.components.container:Close()
		end
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("closed", false)
	end
end

local function regular_ShouldCollapse(inst)
	if inst.components.container and inst.components.container.infinitestacksize then
		--NOTE: should already have called DropEverything(nil, true) (worked or burnt or deconstructed)
		--      so everything remaining counts as an "overstack"
		local overstacks = 0
		for k, v in pairs(inst.components.container.slots) do
			local stackable = v.components.stackable
			if stackable then
				overstacks = overstacks + math.ceil(stackable:StackSize() / (stackable.originalmaxsize or stackable.maxsize))
				if overstacks >= TUNING.COLLAPSED_CHEST_EXCESS_STACKS_THRESHOLD then
					return true
				end
			end
		end
	end
	return false
end

local function regular_Upgrade_OnHammered(inst, worker)
	if regular_ShouldCollapse(inst) then
		if TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) then
			inst.components.container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_MAX_EXCESS_STACKS_DROPS)
			if not inst.components.container:IsEmpty() then
				regular_ConvertToCollapsed(inst, true, false)
				return
			end
		else
			--sunk, drops more, but will lose the remainder
			if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
				inst.components.burnable:Extinguish()
			end
			inst.components.lootdropper:DropLoot()
			inst.components.container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_EXCESS_STACKS_THRESHOLD)
			local fx = SpawnPrefab("collapse_small")
			fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
			fx:SetMaterial("wood")
			inst:Remove()
			return
		end
	end

	--fallback to default
	onhammered(inst, worker)
end

local function regular_Upgrade_OnRestoredFromCollapsed(inst)
	inst.AnimState:PlayAnimation("rebuild")
	inst.AnimState:PushAnimation("closed", false)
	if inst.skin_place_sound then
		inst.SoundEmitter:PlaySound(inst.skin_place_sound)
	else
		inst.SoundEmitter:PlaySound(inst.sounds.built)
	end
end

local function DoUpgradeVisuals(inst)
    local skin_name = (inst.AnimState:GetSkinBuild() or ""):gsub("treasurechest_", "")
    inst.AnimState:SetBank("chest_upgraded")
    inst.AnimState:SetBuild("treasure_chest_upgraded")
    if skin_name ~= "" then
        skin_name = "treasurechest_upgraded_" .. skin_name
        inst.AnimState:SetSkin(skin_name, "treasure_chest_upgraded")
    end
end

local function OnUpgrade(inst, performer, upgraded_from_item)
    local numupgrades = inst.components.upgradeable.numupgrades
    if numupgrades == 1 then
        inst._chestupgrade_stacksize = true
        if inst.components.container ~= nil then -- NOTES(JBK): The container component goes away in the burnt load but we still want to apply builds.
            inst.components.container:Close()
            inst.components.container:EnableInfiniteStackSize(true)
            inst.components.inspectable.getstatus = regular_getstatus
        end
        if upgraded_from_item then
            -- Spawn FX from an item upgrade not from loads.
            local x, y, z = inst.Transform:GetWorldPosition()
            local fx = SpawnPrefab("chestupgrade_stacksize_fx")
            fx.Transform:SetPosition(x, y, z)
            -- Delay chest visual changes to match fx.
            local total_hide_frames = 6 -- NOTES(JBK): Keep in sync with fx.lua! [CUHIDERFRAMES]
            inst:DoTaskInTime(total_hide_frames * FRAMES, DoUpgradeVisuals)
        else
            DoUpgradeVisuals(inst)
        end
    end
    inst.components.upgradeable.upgradetype = nil

    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:SetLoot({ "alterguardianhatshard" })
    end
	inst.components.workable:SetOnWorkCallback(regular_Upgrade_OnHit)
	inst.components.workable:SetOnFinishCallback(regular_Upgrade_OnHammered)
	inst:ListenForEvent("restoredfromcollapsed", regular_Upgrade_OnRestoredFromCollapsed)
end

local function regular_OnBurnt(inst)
    inst.components.upgradeable.upgradetype = nil
    inst.components.inspectable.getstatus = nil

	if inst.components.container then
		inst.components.container:DropEverything(nil, true)
	end

	if regular_ShouldCollapse(inst) then
		inst.components.container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_MAX_EXCESS_STACKS_DROPS)
		if not inst.components.container:IsEmpty() then
			regular_ConvertToCollapsed(inst, true, true)
			return
		end
	end

	--fallback to default
	DefaultBurntStructureFn(inst)
end

local function regular_OnLoad(inst, data, newents)
    if inst.components.upgradeable ~= nil and inst.components.upgradeable.numupgrades > 0 then
        OnUpgrade(inst)
    end
	onload(inst, data, newents)
end

local function regular_OnDecontructStructure(inst, caster)
    if inst.components.upgradeable ~= nil and inst.components.upgradeable.numupgrades > 0 then
        if inst.components.lootdropper ~= nil then
            inst.components.lootdropper:SpawnLootPrefab("alterguardianhatshard")
        end
    end

	if regular_ShouldCollapse(inst) then
		inst.components.container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_MAX_EXCESS_STACKS_DROPS)
		if not inst.components.container:IsEmpty() then
			regular_ConvertToCollapsed(inst, false, false)
			inst.no_delete_on_deconstruct = true
			return
		end
	end

	--fallback to default
	inst.no_delete_on_deconstruct = nil
end

local function regular_common_postinit(inst)
	inst:SetDeploySmartRadius(0.5) --recipe min_spacing/2
end

local function regular_master_postinit(inst)
    inst.scrapbook_removedeps = { "alterguardianhatshard" }

    local upgradeable = inst:AddComponent("upgradeable")
    upgradeable.upgradetype = UPGRADETYPES.CHEST
    upgradeable:SetOnUpgradeFn(OnUpgrade)

	inst.components.burnable:SetOnBurntFn(regular_OnBurnt)
    inst:ListenForEvent("ondeconstructstructure", regular_OnDecontructStructure)

	inst.OnLoad = regular_OnLoad
end

--------------------------------------------------------------------------
--[[ pandora ]]
--------------------------------------------------------------------------

local pandora_scrapbook_adddeps = {
    "armorwood",
    "footballhat",
    "spear",
    "nightmarefuel",
    "redgem",
    "bluegem",
    "purplegem",
    "thulecite_pieces",
    "thulecite",
    "yellowgem",
    "orangegem",
    "greengem",
    "batbat",
    "firestaff",
    "icestaff",
    "multitool_axe_pickaxe",
    "spider_dropper",
}

local function pandora_master_postinit(inst)
    inst.scrapbook_adddeps = pandora_scrapbook_adddeps

    inst:ListenForEvent("resetruins", function()
        local was_open = inst.components.container:IsOpen()

        if inst.components.scenariorunner == nil then
            inst.components.container:Close()
            inst.components.container:DropEverythingWithTag("irreplaceable")
            inst.components.container:DestroyContents()

            inst:AddComponent("scenariorunner")
            inst.components.scenariorunner:SetScript("chest_labyrinth")
            inst.components.scenariorunner:Run()
        end

        if not inst:IsAsleep() then
            if not was_open then
                inst.AnimState:PlayAnimation("hit")
                inst.AnimState:PushAnimation("closed", false)
                inst.SoundEmitter:PlaySound("dontstarve/common/together/chest_retrap")
            end

            SpawnPrefab("pandorachest_reset").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end, TheWorld)
    MakeRoseTarget_CreateFuel_IncreasedHorror(inst)
end

--------------------------------------------------------------------------
--[[ minotaur ]]
--------------------------------------------------------------------------

local minotaur_scrapbook_adddeps = {
    "atrium_key",
    "armorruins",
    "ruinshat",
    "ruins_bat",
    "orangestaff",
    "yellowstaff",
    "orangeamulet",
    "yellowamulet",
    "yellowgem",
    "orangegem",
    "greengem",
    "thulecite",
    "thulecite_pieces",
    "gears",
}

local function minotuar_master_postinit(inst)
    inst.scrapbook_adddeps = minotaur_scrapbook_adddeps

    inst:ListenForEvent("resetruins", function()
        inst.components.container:Close()
        inst.components.container:DropEverything()

        if not inst:IsAsleep() then
            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx:SetMaterial("wood")
        end

        inst:Remove()
    end, TheWorld)

    MakeRoseTarget_CreateFuel_IncreasedHorror(inst)
end


--------------------------------------------------------------------------
--[[ Terrarium ]]
--------------------------------------------------------------------------

local function terrarium_GetStatus(inst)
    return inst.fx ~= nil and "SHIMMER" 
			or inst:HasTag("burnt") and "BURNT"
			or nil
end

local function terrarium_removefx(inst)
	if inst.fx ~= nil then
		inst.fx:Remove()
		inst.fx = nil
		inst:RemoveEventCallback("onburnt", terrarium_removefx)
		inst:RemoveEventCallback("onopen", terrarium_removefx)
		inst.SoundEmitter:KillSound("shimmer")
	end
end

local terrarium_scrapbook_adddeps = {
    "terrarium",
    "spear",
    "blowdart_pipe",
    "boomerang",
    "fireflies",
    "razor",
    "grass_umbrella",
    "papyrus",
    "gunpowder",
    "cutstone",
    "marble",
    "rope",
    "healingsalve",
    "torch",
    "messagebottleempty",
    "goldnugget",
    "log",
}

local function terrarium_master_postinit(inst)
    inst.scrapbook_adddeps = terrarium_scrapbook_adddeps
    inst.components.inspectable.getstatus = terrarium_GetStatus

	if TUNING.SPAWN_EYEOFTERROR then
		inst:DoTaskInTime(0, function(i)
			if i.components.scenariorunner ~= nil then
				i.fx = SpawnPrefab("terrariumchest_fx")
				i.fx.entity:SetParent(i.entity)

				i:ListenForEvent("onburnt", terrarium_removefx)
				i:ListenForEvent("onopen", terrarium_removefx)

				inst.SoundEmitter:PlaySound("terraria1/terrarium/shimmer_chest_lp", "shimmer")
			end
		end)
	end
end

local function terrariumchest_fx_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.AnimState:SetBuild("terrariumchest_fx")
	inst.AnimState:SetBank("terrariumchest_fx")
	inst.AnimState:PlayAnimation("idle_back", true)
	inst.AnimState:SetFinalOffset(1)
	

	if not TheNet:IsDedicated() then
		local fx_front = CreateEntity()
		fx_front.entity:AddTransform()
		fx_front.entity:AddAnimState()
		fx_front.entity:SetParent(inst.entity)

		fx_front:AddTag("FX")
		fx_front:AddTag("CLASSIFIED")

		fx_front.AnimState:SetBuild("terrariumchest_fx")
		fx_front.AnimState:SetBank("terrariumchest_fx")
		fx_front.AnimState:PlayAnimation("idle_front", true)
		fx_front.AnimState:SetFinalOffset(-3)
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	return inst
end

--------------------------------------------------------------------------
--[[ sunken ]]
--------------------------------------------------------------------------

local function sunken_onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
        if inst.components.container ~= nil then
            inst.components.container:Close()
        end
    end
end

local function sunken_OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function sunken_OnEquip(inst, owner)
    if inst.components.container ~= nil then
		inst.components.container:Close()
	end
    owner.AnimState:OverrideSymbol("swap_body", "swap_sunken_treasurechest", "swap_body")
end

local function sunken_OnSubmerge(inst)
	if inst.components.container ~= nil then
		inst.components.container:Close()
	end
end

local function sunken_GetStatus(inst)
    return (inst.components.container ~= nil and not inst.components.container.canbeopened) and "LOCKED" or nil
end

local function sunken_common_postinit(inst)
	inst:AddTag("heavy")

	MakeHeavyObstaclePhysics(inst, SUNKEN_PHYSICS_RADIUS)
	inst:SetPhysicsRadiusOverride(SUNKEN_PHYSICS_RADIUS)
end

local sunken_scrapbook_adddeps = require("messagebottletreasures").GetPrefabs()

local function sunken_master_postinit(inst)
    inst.scrapbook_adddeps = sunken_scrapbook_adddeps
    inst.components.workable:SetOnWorkCallback(sunken_onhit)

    inst.components.inspectable.getstatus = sunken_GetStatus

	inst:AddComponent("heavyobstaclephysics")
	inst.components.heavyobstaclephysics:SetRadius(SUNKEN_PHYSICS_RADIUS)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(sunken_OnEquip)
    inst.components.equippable:SetOnUnequip(sunken_OnUnequip)
    inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

    inst.components.container.canbeopened = false

	inst:AddComponent("submersible")
	inst:AddComponent("symbolswapdata")
    inst.components.symbolswapdata:SetData("swap_sunken_treasurechest", "swap_body")

	inst:ListenForEvent("on_submerge", sunken_OnSubmerge)
end

local ANCIENT_SOUNDS = {
    open  = "qol1/ancientboat/chest_open_f2",
    close = "qol1/ancientboat/chest_close_f2",
    built = "qol1/ancientboat/chest_place",
}

local function ancient_container_common_postinit(inst)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT)
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    inst:AddTag("NOBLOCK")
    inst:AddTag("outofreach")
end

local function ancient_onsink(inst, data)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
end

local function ancient_onplaced(inst) -- NOTES(DiogoW): This is called manually in boat.lua
    inst:Show()

    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed")

    inst.SoundEmitter:PlaySound(inst.sounds.built)
end

local function ancient_container_master_postinit(inst)
    inst.sounds = ANCIENT_SOUNDS
    inst.OnPlaced = ancient_onplaced

    inst:ListenForEvent("onsink", ancient_onsink)
end

return MakeChest("treasurechest", "chest", "treasure_chest", false, regular_master_postinit, prefabs_regular, assets_regular, regular_common_postinit),
    MakePlacer("treasurechest_placer", "chest", "treasure_chest", "closed"),
    MakeChest("pandoraschest", "pandoras_chest", "pandoras_chest", true, pandora_master_postinit, { "pandorachest_reset" }),
    MakeChest("minotaurchest", "pandoras_chest_large", "pandoras_chest_large", true, minotuar_master_postinit, { "collapse_small" }),
    MakeChest("terrariumchest", "chest", "treasurechest_terrarium", false, terrarium_master_postinit, { "collapse_small", "terrariumchest_fx" }, { Asset("ANIM", "anim/treasurechest_terrarium.zip") }),
	Prefab("terrariumchest_fx", terrariumchest_fx_fn, { Asset("ANIM", "anim/terrariumchest_fx.zip") }, { "collapse_small" }),
	MakeChest("sunkenchest", "sunken_treasurechest", "sunken_treasurechest", false, sunken_master_postinit, { "collapse_small", "underwater_salvageable", "splash_green" }, { Asset("ANIM", "anim/swap_sunken_treasurechest.zip") }, sunken_common_postinit, true),
    MakeChest("boat_ancient_container", "boat_ancient_container", "boat_ancient_container", true, ancient_container_master_postinit, nil, { Asset("ANIM", "anim/ui_boat_ancient_4x4.zip") }, ancient_container_common_postinit, true)
