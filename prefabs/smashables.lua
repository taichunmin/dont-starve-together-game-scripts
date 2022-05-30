local prefabs =
{
    "thulecite",
    "rocks",
    "cutstone",
    "silk",
    "trinket_1",
    "trinket_3",
    "trinket_6",
    "trinket_9",
    "trinket_12",
    "sewing_kit",
    "spider_hider",
    "spider_spitter",
    "monkey",
    "gears",
    "nightmarefuel",
    "greengem",
    "orangegem",
    "yellowgem",
    "collapse_small",
}

SetSharedLootTable('smashables',
{
    {'rocks',      0.80},
    {'cutstone',   0.10},
    {'trinket_6',  0.05}, -- frayed wires
})

local function makeassetlist(buildname)
    return
    {
        Asset("ANIM", "anim/"..buildname..".zip"),
        Asset("MINIMAP_IMAGE", "relic"),
    }
end

local function OnDeath(inst)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial(inst.smashsound or "pot")
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

--Only call this if inst.animated
local function OnHit(inst)
    if inst.rubble then
        inst.AnimState:PlayAnimation("repair")
        inst.AnimState:PushAnimation("broken", false)
    else
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function KeepTargetFn()
    return false
end

local function MakeRelic(inst)
    if inst.components.repairable ~= nil then
        inst:RemoveComponent("repairable")
    end
    inst.components.inspectable.nameoverride = "relic"
    if inst.animated then
        inst.AnimState:PushAnimation("idle", false)
    else
        inst.AnimState:PlayAnimation("idle")
    end
end

local function OnRepaired(inst, doer)
    if inst.components.health:GetPercent() >= 1 then
        if doer.components.sanity ~= nil then
            doer.components.sanity:DoDelta(TUNING.SANITY_TINY)
        end
        if inst.rubble then
            inst.rubble = false
            if inst.animated then
                inst.AnimState:PlayAnimation("hit")
            end
            MakeRelic(inst)
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/fixed_stonefurniture")
    else
        inst.SoundEmitter:PlaySound("dontstarve/common/repair_stonefurniture")
        if inst.animated then
            OnHit(inst)
        end
    end
end

local function MakeRubble(inst)
    if inst.components.repairable == nil then
        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = MATERIALS.STONE
        inst.components.repairable.onrepaired = OnRepaired
    end
    inst.components.inspectable.nameoverride = "ruins_rubble"
    if inst.animated then
        inst.AnimState:PushAnimation("broken", false)
    else
        inst.AnimState:PlayAnimation("broken")
    end
end

local function OnHealthDelta(inst, oldpct, newpct)
    if not inst.rubble and newpct < .5 and newpct < oldpct then
        inst.rubble = true
        if inst.animated then
            inst.AnimState:PlayAnimation("repair")
        end
        MakeRubble(inst)
    end
end

local function OnSave(inst, data)
    data.rubble = inst.rubble or nil
    data.maxhealth = inst.components.health.maxhealth
end

local function OnPreLoad(inst, data)
    if data ~= nil then
        if data.maxhealth ~= nil then
            inst.components.health:SetMaxHealth(data.maxhealth)
        end

        if data.rubble then
            if not inst.rubble then
                inst.rubble = true
                MakeRubble(inst)
            end
        elseif inst.rubble then
            inst.rubble = false
            MakeRelic(inst)
        end
    end
end

local function displaynamefn(inst)
    return STRINGS.NAMES[inst:HasTag("repairable_stone") and "RUINS_RUBBLE" or "RELIC"]
end

local function makefn(name, asset, animated, smashsound, rubble)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .25)

        inst.MiniMapEntity:SetIcon("relic.png")

        inst.AnimState:SetBank(asset)
        inst.AnimState:SetBuild(asset)
        inst.AnimState:PlayAnimation(rubble and "broken" or "idle")

        inst:AddTag("cavedweller")
        inst:AddTag("smashable")
        inst:AddTag("object")
        inst:AddTag(smashsound == "rock" and "stone" or "clay")
		inst:AddTag("noauradamage")

        inst.displaynamefn = displaynamefn

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.rubble = rubble
        inst.animated = animated

        inst.OnSave = OnSave
        inst.OnPreLoad = OnPreLoad

        inst:AddComponent("combat")
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
        if animated then
            inst.components.combat.onhitfn = OnHit
        end

        inst:AddComponent("health")
        inst.components.health.nofadeout = true
        inst.components.health.canmurder = false
        inst.components.health.canheal = false
        inst.components.health:SetMaxHealth(GetRandomWithVariance(90, 20))
        inst.components.health.ondelta = OnHealthDelta

        inst:ListenForEvent("death", OnDeath)

        inst:AddComponent("lootdropper")
        if not string.find(name, "bowl") and not string.find(name, "plate") then
            if string.find(name, "vase") then
                local trinket = GetRandomItem({ "trinket_1", "trinket_3", "trinket_9", "trinket_12", "trinket_6" })
                inst.components.lootdropper:AddChanceLoot(trinket          , 0.10)

                inst.components.lootdropper.numrandomloot = 1
                inst.components.lootdropper.chancerandomloot = 0.05  -- drop some random item X% of the time
                inst.components.lootdropper:AddRandomLoot("silk"           , 0.1) -- Weighted average
                inst.components.lootdropper:AddRandomLoot(trinket          , 0.1)
                inst.components.lootdropper:AddRandomLoot("thulecite"      , 0.1)
                inst.components.lootdropper:AddRandomLoot("sewing_kit"     , 0.1)
                inst.components.lootdropper:AddRandomLoot("spider_hider"   , 0.05)
                inst.components.lootdropper:AddRandomLoot("spider_spitter" , 0.05)
                inst.components.lootdropper:AddRandomLoot("monkey"         , 0.05)
            else
                inst.components.lootdropper:SetChanceLootTable('smashables')
                inst.components.lootdropper.numrandomloot = 1
                inst.components.lootdropper.chancerandomloot = 0.01  -- drop some random item 1% of the time
                inst.components.lootdropper:AddRandomLoot("gears"         , 0.01)
                inst.components.lootdropper:AddRandomLoot("greengem"      , 0.01)
                inst.components.lootdropper:AddRandomLoot("yellowgem"     , 0.01)
                inst.components.lootdropper:AddRandomLoot("orangegem"     , 0.01)
                inst.components.lootdropper:AddRandomLoot("nightmarefuel" , 0.01)
            end
        end

        inst:AddComponent("inspectable")

        if rubble then
            MakeRubble(inst)
            inst.components.health:SetPercent(.2)
        else
            MakeRelic(inst)
            inst.components.health:SetPercent(.8)
        end

        inst.smashsound = smashsound

        MakeHauntableWork(inst)

        return inst
    end
end

local function item(name, animated, sound)
    return Prefab(name, makefn(name, name, animated, sound, false), makeassetlist(name), prefabs)
end

local function rubble(name, assetname, animated, sound, rubble)
    return Prefab(name, makefn(name, assetname, animated, sound, true), makeassetlist(assetname), prefabs)
end

return item("ruins_plate", false),
    item("ruins_bowl", false),
    item("ruins_chair", true, "rock"),
    item("ruins_chipbowl", false),
    item("ruins_vase", true),
    item("ruins_table", true, "rock"),
    rubble("ruins_rubble_table", "ruins_table", true, "rock"),
    rubble("ruins_rubble_chair", "ruins_chair", true, "rock"),
    rubble("ruins_rubble_vase", "ruins_vase", true)
