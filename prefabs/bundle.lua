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

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

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

local function MakeContainer(name, build)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("bundle")

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

local function MakeBundle(name, onesize, variations, loot, tossloot, setupdata)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    if variations ~= nil then
        for i = 1, variations do
            if onesize then
                table.insert(assets, Asset("INV_IMAGE", name..tostring(i)))
            else
                table.insert(assets, Asset("INV_IMAGE", name.."_small"..tostring(i)))
                table.insert(assets, Asset("INV_IMAGE", name.."_medium"..tostring(i)))
                table.insert(assets, Asset("INV_IMAGE", name.."_large"..tostring(i)))
            end
        end
    elseif not onesize then
        table.insert(assets, Asset("INV_IMAGE", name.."_small"))
        table.insert(assets, Asset("INV_IMAGE", name.."_medium"))
        table.insert(assets, Asset("INV_IMAGE", name.."_large"))
    end

    local prefabs =
    {
        "ash",
        name.."_unwrap",
    }

    if loot ~= nil then
        for i, v in ipairs(loot) do
            table.insert(prefabs, v)
        end
    end

    local function OnWrapped(inst, num, doer)
        local suffix =
            (onesize and "_onesize") or
            (num > 3 and "_large") or
            (num > 1 and "_medium") or
            "_small"

        if variations ~= nil then
            if inst.variation == nil then
                inst.variation = math.random(variations)
            end
            suffix = suffix..tostring(inst.variation)
            inst.components.inventoryitem:ChangeImageName(name..(onesize and tostring(inst.variation) or suffix))
        elseif not onesize then
            inst.components.inventoryitem:ChangeImageName(name..suffix)
        end

        inst.AnimState:PlayAnimation("idle"..suffix)

        if doer ~= nil and doer.SoundEmitter ~= nil then
            doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
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
            doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
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

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation(
            variations ~= nil and
            (onesize and "idle_onesize1" or "idle_large1") or
            (onesize and "idle_onesize" or "idle_large")
        )

        inst:AddTag("bundle")

        --unwrappable (from unwrappable component) added to pristine state for optimization
        inst:AddTag("unwrappable")

        if setupdata ~= nil and setupdata.common_postinit ~= nil then
            setupdata.common_postinit(inst, setupdata)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")

        if variations ~= nil or not onesize then
            inst.components.inventoryitem:ChangeImageName(
                name..
                (variations == nil and "_large" or (onesize and "1" or "_large1"))
            )
        end

        inst:AddComponent("unwrappable")
        inst.components.unwrappable:SetOnWrappedFn(OnWrapped)
        inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)

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

local redpouch =
{
    master_postinit = function(inst, setupdata)
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    end,
}

local wetpouch =
{
    loottable =
    {
        goggleshat_blueprint = 0,
        deserthat_blueprint = 0,
        succulent_potted_blueprint = 0,
        antliontrinket = 0,
        trinket_1 = 1, -- marbles
        trinket_3 = 1, -- knot
        trinket_8 = 1, -- plug
        trinket_9 = 1, -- buttons
        trinket_26 = .1, -- potatocup
        TOOLS_blueprint = .05,
        LIGHT_blueprint = .05,
        SURVIVAL_blueprint = .05,
        FARM_blueprint = .05,
        SCIENCE_blueprint = .05,
        REFINE_blueprint = .05,
        DRESS_blueprint = .05,
    },

    UpdateLootBlueprint = function(loottable, doer)
        local builder = doer ~= nil and doer.components.builder or nil
        loottable["goggleshat_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("goggleshat")) and 1 or 0.1
        loottable["deserthat_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("deserthat") and builder:KnowsRecipe("goggleshat")) and 1 or 0.1
        loottable["succulent_potted_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("succulent_potted")) and 1 or 0.1
        loottable["antliontrinket"] = (builder ~= nil and builder:KnowsRecipe("deserthat")) and .8 or 0.1
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
    --"bundle", "bundlewrap"
    MakeBundle("bundle", false, nil, { "waxpaper" }),
    MakeWrap("bundle", "bundle_container", nil, false),
    --"gift", "giftwrap"
    MakeBundle("gift", false, 2),
    MakeWrap("gift", "bundle_container", nil, true),
    --"redpouch"
    MakeBundle("redpouch", true, nil, { "lucky_goldnugget" }, true, redpouch),
    MakeBundle("wetpouch", true, nil, JoinArrays(table.invert(wetpouch.loottable), GetAllWinterOrnamentPrefabs()), false, wetpouch)
