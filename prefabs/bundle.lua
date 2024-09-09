require "prefabs/winter_ornaments"

local function OnStartBundling(inst)--, doer)
    inst.components.stackable:Get():Remove()
end

local function MakeWrap(name, containerprefab, tag, cheapfuel)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    local prefabs =
    {
        name,
        containerprefab,
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        if tag ~= nil then
            inst:AddTag(tag)
        end

        inst.scrapbook_specialinfo = "BUNDLEWRAP"

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:SetSinks(true)

        inst:AddComponent("bundlemaker")
        inst.components.bundlemaker:SetBundlingPrefabs(containerprefab, name)
        inst.components.bundlemaker:SetOnStartBundlingFn(OnStartBundling)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = cheapfuel and TUNING.TINY_FUEL or TUNING.MED_FUEL

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)
        inst.components.propagator.flashpoint = 10 + math.random() * 5
        MakeHauntableLaunchAndIgnite(inst)

        return inst
    end

    return Prefab(name.."wrap", fn, assets, prefabs)
end

local function MakeContainer(name, build, tag)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("bundle")

		if tag ~= nil then
			inst:AddTag(tag)
		end

        --V2C: blank string for controller action prompt
        inst.name = " "

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)

        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets)
end

local function onburnt(inst)
    inst.burnt = true
    inst.components.unwrappable:Unwrap()
end

local function onignite(inst)
    inst.components.unwrappable.canbeunwrapped = false
end

local function onextinguish(inst)
    inst.components.unwrappable.canbeunwrapped = true
end

local function MakeBundle(name, onesize, variations, loot, tossloot, setupdata, bank, build, inventoryimage)
    local assets =
    {
        Asset("ANIM", "anim/"..(inventoryimage or name)..".zip"),
    }

    if variations ~= nil then
        for i = 1, variations do
            if onesize then
                table.insert(assets, Asset("INV_IMAGE", (inventoryimage or name)..tostring(i)))
            else
                table.insert(assets, Asset("INV_IMAGE", (inventoryimage or name).."_small"..tostring(i)))
                table.insert(assets, Asset("INV_IMAGE", (inventoryimage or name).."_medium"..tostring(i)))
                table.insert(assets, Asset("INV_IMAGE", (inventoryimage or name).."_large"..tostring(i)))
            end
        end
    elseif not onesize then
        table.insert(assets, Asset("INV_IMAGE", (inventoryimage or name).."_small"))
        table.insert(assets, Asset("INV_IMAGE", (inventoryimage or name).."_medium"))
        table.insert(assets, Asset("INV_IMAGE", (inventoryimage or name).."_large"))
    end

    local prefabs =
    {
        "ash",
        name.."_unwrap",
    }

    if loot ~= nil then
        for _, v in ipairs(loot) do
            table.insert(prefabs, v)
        end
    end

    local function UpdateInventoryImage(inst)
        local suffix = inst.suffix or "_small"
        if variations ~= nil then
            inst.variation = inst.variation or math.random(variations)
            local variation_string = tostring(inst.variation)

            suffix = (onesize and variation_string) or suffix..variation_string

            inst.components.inventoryitem:ChangeImageName((inst:GetSkinName() or name)..suffix)
        elseif not onesize then
            inst.components.inventoryitem:ChangeImageName((inst:GetSkinName() or name)..suffix)
        end
    end


    local function OnWrapped(inst, num, doer)
        local suffix =
            (onesize and "_onesize") or
            (num > 3 and "_large") or
            (num > 1 and "_medium") or
            "_small"

        inst.suffix = suffix

        UpdateInventoryImage(inst)

        if inst.variation then
            suffix = suffix..tostring(inst.variation)
        end
        inst.AnimState:PlayAnimation("idle"..suffix)
        inst.scrapbook_anim = "idle"..suffix

        if doer ~= nil and doer.SoundEmitter ~= nil then
            doer.SoundEmitter:PlaySound(inst.skin_wrap_sound or "dontstarve/common/together/packaged")
        end
    end

    local function OnUnwrapped(inst, pos, doer)
        if inst.burnt then
            SpawnPrefab("ash").Transform:SetPosition(pos:Get())
        else
            local loottable = (setupdata ~= nil and setupdata.lootfn ~= nil) and setupdata.lootfn(inst, doer) or loot
            if loottable ~= nil then
                local moisture = inst.components.inventoryitem:GetMoisture()
                local iswet = inst.components.inventoryitem:IsWet()
                for i, v in ipairs(loottable) do
                    local item = SpawnPrefab(v)
                    if item ~= nil then
                        if item.Physics ~= nil then
                            item.Physics:Teleport(pos:Get())
                        else
                            item.Transform:SetPosition(pos:Get())
                        end
                        if item.components.inventoryitem ~= nil then
                            item.components.inventoryitem:InheritMoisture(moisture, iswet)
                            if tossloot then
                                item.components.inventoryitem:OnDropped(true, .5)
                            end
                        end
                    end
                end
            end
            SpawnPrefab(name.."_unwrap").Transform:SetPosition(pos:Get())
        end
        if doer ~= nil and doer.SoundEmitter ~= nil then
            doer.SoundEmitter:PlaySound(inst.skin_wrap_sound or "dontstarve/common/together/packaged")
        end
        inst:Remove()
    end

    local OnSave = variations ~= nil and function(inst, data)
        data.variation = inst.variation
    end or nil

    local OnPreLoad = variations ~= nil and function(inst, data)
        if data ~= nil then
            inst.variation = data.variation
        end
    end or nil

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(bank or name)
        inst.AnimState:SetBuild(build or name)
        inst.AnimState:PlayAnimation(
            variations ~= nil and
            (onesize and "idle_onesize1" or "idle_large1") or
            (onesize and "idle_onesize" or "idle_large")
        )
        inst.scrapbook_anim = variations ~= nil and
            (onesize and "idle_onesize1" or "idle_large1") or
            (onesize and "idle_onesize" or "idle_large")

        inst:AddTag("bundle")

        --unwrappable (from unwrappable component) added to pristine state for optimization
        inst:AddTag("unwrappable")

        if setupdata ~= nil and setupdata.common_postinit ~= nil then
            setupdata.common_postinit(inst, setupdata)
        end

        inst.scrapbook_specialinfo = "BUNDLE"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:SetSinks(true)

        if inventoryimage then
            inst.components.inventoryitem:ChangeImageName(inventoryimage)
        end

        if variations ~= nil or not onesize then
            inst.components.inventoryitem:ChangeImageName(
                name..
                (variations == nil and "_large" or (onesize and "1" or "_large1"))
            )
        end

        inst:AddComponent("unwrappable")
        inst.components.unwrappable:SetOnWrappedFn(OnWrapped)
        inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)
        inst.UpdateInventoryImage = UpdateInventoryImage

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)
        inst.components.propagator.flashpoint = 10 + math.random() * 5
        inst.components.burnable:SetOnBurntFn(onburnt)
        inst.components.burnable:SetOnIgniteFn(onignite)
        inst.components.burnable:SetOnExtinguishFn(onextinguish)

        MakeHauntableLaunchAndIgnite(inst)

        if setupdata ~= nil and setupdata.master_postinit ~= nil then
            setupdata.master_postinit(inst, setupdata)
        end

        inst.OnSave = OnSave
        inst.OnPreLoad = OnPreLoad

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local bundle =
{
	common_postinit = function(inst, setupdata)
		inst.SCANNABLE_RECIPENAME = "bundlewrap"
	end,
}

local gift =
{
	common_postinit = function(inst, setupdata)
		inst.SCANNABLE_RECIPENAME = "giftwrap"
	end,
}

local redpouch =
{
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    end,
}

local redpouch_yotp =
{
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    end,
    common_postinit = function(inst, setupdata)
		inst:SetPrefabNameOverride("redpouch")
    end,
}

local redpouch_yotc =
{
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    end,
    common_postinit = function(inst, setupdata)
        inst:SetPrefabNameOverride("redpouch")
    end,
}

local yotc_seedpacket_loots =
{
	set1 =
	{
		carrot_seeds = 1,
		corn_seeds = 1,
		tomato_seeds = 1,
		pumpkin_seeds = 1,
		eggplant_seeds = 1,
		potato_seeds = 1,
		watermelon_seeds = 1,
	},
	set2 =
	{
		asparagus_seeds = 1,
		pomegranate_seeds = 1,
		durian_seeds = 1,
		dragonfruit_seeds = 1,
	},
}

local redpouch_yotb =
{
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    end,
    common_postinit = function(inst, setupdata)
        inst:SetPrefabNameOverride("redpouch")
    end,
}

local redpouch_yot_catcoon =
{
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    end,
    common_postinit = function(inst, setupdata)
        inst:SetPrefabNameOverride("redpouch")
    end,
}

local redpouch_yotr =
{
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    end,
    common_postinit = function(inst, setupdata)
        inst:SetPrefabNameOverride("redpouch")
    end,
}

local redpouch_yotd =
{
    common_postinit = function(inst, setupdata)
        inst:SetPrefabNameOverride("redpouch")

        MakeInventoryFloatable(inst, nil, 0.15)
    end,
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH

        inst.components.inventoryitem:SetSinks(false)
    end,
}

local hermit_bundle_shell_loots =
{
    singingshell_octave5 = 2,
    singingshell_octave4 = 2,
    singingshell_octave3 = 1,
}


local yotc_seedpacket =
{
    common_postinit = function(inst, setupdata)
        MakeInventoryFloatable(inst, "small")
    end,

    master_postinit = function(inst, setupdata)
        inst.components.inventoryitem:SetSinks(false)
    end,

	lootfn = function(inst, doer)
        local loots = {}

		table.insert(loots, "seeds")
		table.insert(loots, "seeds")
		table.insert(loots, weighted_random_choice(yotc_seedpacket_loots.set1))

		return loots
	end,
}
local yotc_seedpacket_rare =
{
    common_postinit = function(inst, setupdata)
        MakeInventoryFloatable(inst, "small")
    end,

    master_postinit = function(inst, setupdata)
        inst.components.inventoryitem:SetSinks(false)
    end,

	lootfn = function(inst, doer)
		local loots = {}

		table.insert(loots, weighted_random_choice(yotc_seedpacket_loots.set1))
		table.insert(loots, weighted_random_choice(yotc_seedpacket_loots.set1))
		table.insert(loots, weighted_random_choice(yotc_seedpacket_loots.set2))

		return loots
	end,
}

local carnival_seedpacket =
{
    common_postinit = function(inst, setupdata)
        MakeInventoryFloatable(inst, "small")
    end,

    master_postinit = function(inst, setupdata)
        inst.components.inventoryitem:SetSinks(false)
    end,

	lootfn = function(inst, doer)
        local loots = {}
		table.insert(loots, "corn_seeds")
		table.insert(loots, "corn_seeds")
		table.insert(loots, "corn_seeds")
		table.insert(loots, "corn_seeds")
		if math.random() < 0.1 then
			table.insert(loots, "corn_seeds")
		end

		return loots
	end,
}

local hermit_bundle =
{
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    end,
    common_postinit = function(inst, setupdata)
        inst:SetPrefabNameOverride("hermit_bundle")
    end,
}

local HERMIT_BUNDLE_SHELLS_SHELL_COUNT = 8

local hermit_bundle_shells =
{
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    end,
    common_postinit = function(inst, setupdata)
        inst:SetPrefabNameOverride("hermit_bundle")
    end,
    lootfn = function(inst, doer)
        return weighted_random_choices(hermit_bundle_shell_loots, HERMIT_BUNDLE_SHELLS_SHELL_COUNT)
    end,
}

local wetpouch =
{
    loottable =
    {
        deserthat_blueprint = 0,
        antliontrinket = 0,
        trinket_1 = 1, -- marbles
        trinket_3 = 1, -- knot
        trinket_8 = 1, -- plug
        trinket_9 = 1, -- buttons
        trinket_26 = .1, -- potatocup
		cotl_trinket = 1,
        blueprint = 0.5,
    },

    UpdateLootBlueprint = function(loottable, doer)
        local builder = doer ~= nil and doer.components.builder or nil
        loottable["deserthat_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("deserthat")) and 2 or 0.1
        loottable["antliontrinket"] = (builder ~= nil and builder:KnowsRecipe("deserthat")) and 2 or 0.1
    end,

    lootfn = function(inst, doer)
        inst.setupdata.UpdateLootBlueprint(inst.setupdata.loottable, doer)

        local total = 0
        for _,v in pairs(inst.setupdata.loottable) do
            total = total + v
        end
        --print ("TOTOAL:", total)
        --for k,v in pairs(inst.setupdata.loottable) do print(" - ", tostring(v/total), k) end

        local item = weighted_random_choice(inst.setupdata.loottable)

        if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and
            string.sub(item, 1, 7) == "trinket" and
            item ~= "trinket_26" then
            --chance to replace trinkets (but not potatocup)
            local rnd = math.random(6)
            if rnd == 1 then
                item = GetRandomBasicWinterOrnament()
            elseif rnd == 2 then
                item = GetRandomFancyWinterOrnament()
            elseif rnd == 3 then
                item = GetRandomLightWinterOrnament()
            end
        end

        return { item }
    end,

    master_postinit = function(inst, setupdata)
        inst.build = "wetpouch"
        inst.setupdata = setupdata
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
        inst.components.inventoryitem:InheritMoisture(100, true)
    end,
}

return MakeContainer("bundle_container", "ui_bundle_2x2"),
	MakeContainer("construction_container", "ui_construction_4x1"),
	MakeContainer("construction_repair_container", "ui_construction_4x1", "repairconstructionsite"),
	MakeContainer("construction_rebuild_container", "ui_construction_4x1", "rebuildconstructionsite"),
    --"bundle", "bundlewrap"
	MakeBundle("bundle", false, nil, { "waxpaper" }, nil, bundle),
    MakeWrap("bundle", "bundle_container", nil, false),
    --"gift", "giftwrap"
	MakeBundle("gift", false, 2, nil, nil, gift),
    MakeWrap("gift", "bundle_container", nil, true),
    --"redpouch"
    MakeBundle("redpouch", true, nil, { "lucky_goldnugget" }, true, redpouch),
    MakeBundle("redpouch_yotp", false, nil, nil, true, redpouch_yotp),
    MakeBundle("redpouch_yotc", false, nil, nil, true, redpouch_yotc),
    MakeBundle("redpouch_yotb", false, nil, nil, true, redpouch_yotb),
    MakeBundle("redpouch_yot_catcoon", false, nil, nil, true, redpouch_yot_catcoon),
    MakeBundle("redpouch_yotr",        false, nil, nil, true, redpouch_yotr),
    MakeBundle("redpouch_yotd",        false, nil, nil, true, redpouch_yotd),
	MakeBundle("yotc_seedpacket", true, nil, nil, true, yotc_seedpacket),
	MakeBundle("yotc_seedpacket_rare", true, nil, nil, true, yotc_seedpacket_rare),
	MakeBundle("carnival_seedpacket", true, nil, nil, true, carnival_seedpacket),
    MakeBundle("hermit_bundle", true, nil, nil, true, hermit_bundle),
    MakeBundle("hermit_bundle_shells", true, nil, nil, true, hermit_bundle_shells, "hermit_bundle","hermit_bundle","hermit_bundle"),
    MakeBundle("wetpouch", true, nil, JoinArrays(table.getkeys(wetpouch.loottable), GetAllWinterOrnamentPrefabs()), false, wetpouch)
