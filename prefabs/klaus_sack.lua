require "prefabs/winter_ornaments"

local assets =
{
    Asset("ANIM", "anim/klaus_bag.zip"),
}

local prefabs =
{
    "klaus",
    "boneshard",
    "bundle",
    "gift",

    --loot
    "krampus_sack",
    "charcoal",
    "goldnugget",
    "amulet",

    --winter loot
    "goatmilk",
    "winter_food1", --gingerbread cookies
    "winter_food2", --sugar cookies
}

local giant_loot1 =
{
    "deerclops_eyeball",
    "dragon_scales",
    "hivehat",
    "shroom_skin",
    "mandrake",
}

local giant_loot2 =
{
    "dragonflyfurnace_blueprint",
    "red_mushroomhat_blueprint",
    "green_mushroomhat_blueprint",
    "blue_mushroomhat_blueprint",
    "mushroom_light2_blueprint",
    "mushroom_light_blueprint",
    "townportal_blueprint",
    "bundlewrap_blueprint",
}

local giant_loot3 =
{
    "bearger_fur",
    "royal_jelly",
    "goose_feather",
    "lavae_egg",
    "spiderhat",
    "steelwool",
    "townportaltalisman",
}

for i, v in ipairs(giant_loot1) do
    table.insert(prefabs, v)
end

for i, v in ipairs(giant_loot2) do
    table.insert(prefabs, v)
end

for i, v in ipairs(giant_loot3) do
    table.insert(prefabs, v)
end

for i, v in ipairs(GetAllWinterOrnamentPrefabs()) do
    table.insert(prefabs, v)
end

local function DropBundle(inst, items)
    local bundle = SpawnPrefab(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "gift" or "bundle")
    bundle.components.unwrappable:WrapItems(items)
    for i, v in ipairs(items) do
        v:Remove()
    end
    inst.components.lootdropper:FlingItem(bundle)
end

local function FillItems(items, prefab)
    for i = 1 + #items, math.random(3, 4) do
        table.insert(items, SpawnPrefab(prefab))
    end
end

local function onuseklauskey(inst, key, doer)
    if key.components.klaussackkey == nil then
        return false
    elseif key.components.klaussackkey.truekey then
        if inst.components.entitytracker:GetEntity("klaus") ~= nil then
            --klaus is already spawned
            --announce danger?
            return false, "KLAUS", false
        end

        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/chain_foley")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/lock_break")

        if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
            local rnd = math.random(3)
            local boss_ornaments =
            {
                "winter_ornament_boss_klaus",
                "winter_ornament_boss_noeyeblue",
                "winter_ornament_boss_noeyered",
                "winter_ornament_boss_krampus",
            }
            local items =
            {
                SpawnPrefab(boss_ornaments[math.random(#boss_ornaments)]),
                SpawnPrefab(GetRandomFancyWinterOrnament()),
                SpawnPrefab(GetRandomLightWinterOrnament()),
                SpawnPrefab(
                    (rnd == 1 and GetRandomLightWinterOrnament()) or
                    (rnd == 2 and GetRandomFancyWinterOrnament()) or
                    GetRandomBasicWinterOrnament()
                ),
            }
            DropBundle(inst, items)

            items =
            {
                SpawnPrefab("goatmilk"),
                SpawnPrefab("goatmilk"),
                SpawnPrefab("winter_food"..tostring(math.random(2))),
            }
            items[3].components.stackable.stacksize = 4
            DropBundle(inst, items)
        end

        local items = {}
        table.insert(items, SpawnPrefab("amulet"))
        table.insert(items, SpawnPrefab("goldnugget"))
        FillItems(items, "charcoal")
        DropBundle(inst, items)

        items = {}
        if math.random() < .5 then
            table.insert(items, SpawnPrefab("amulet"))
        end
        table.insert(items, SpawnPrefab("goldnugget"))
        FillItems(items, "charcoal")
        DropBundle(inst, items)

        items = {}
        if math.random() < .1 then
            table.insert(items, SpawnPrefab("krampus_sack"))
        end
        table.insert(items, SpawnPrefab("goldnugget"))
        FillItems(items, "charcoal")
        DropBundle(inst, items)

        items = {}
        local i1 = math.random(#giant_loot3)
        local i2 = math.random(#giant_loot3 - 1)
        table.insert(items, SpawnPrefab(giant_loot1[math.random(#giant_loot1)]))
        if math.random() < .5 then
            table.insert(items, SpawnPrefab(giant_loot2[math.random(#giant_loot2)]))
        end
        table.insert(items, SpawnPrefab(giant_loot3[i1]))
        table.insert(items, SpawnPrefab(giant_loot3[i2 == i1 and i2 + 1 or i2]))
        DropBundle(inst, items)

        inst.persists = false
        inst:AddTag("NOCLICK")
        inst:DoTaskInTime(1, ErodeAway)

        return true, nil, true
    else
        LaunchAt(SpawnPrefab("boneshard"), inst, doer, .2, 1, 1)

        inst.AnimState:PlayAnimation("jiggle")
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/chain")

        if inst.components.entitytracker:GetEntity("klaus") ~= nil then
            --klaus is already spawned
            --announce danger?
        elseif inst.components.entitytracker:GetEntity("key") ~= nil then
            --already got the right key
            --announce that this isn't the right key
        else
            --Find spawn point far away, preferrably not near players
            local pos = inst:GetPosition()
            local minplayers = math.huge
            local spawnx, spawnz
            FindWalkableOffset(pos,
                math.random() * 2 * PI, 33, 16, true, true,
                function(pt)
                    local count = #FindPlayersInRangeSq(pt.x, pt.y, pt.z, 625)
                    if count < minplayers then
                        minplayers = count
                        spawnx, spawnz = pt.x, pt.z
                        return count <= 0
                    end
                    return false
                end)

            if spawnx == nil then
                --No spawn point (with or without players), so try closer
                local offset = FindWalkableOffset(pos, math.random() * 2 * PI, 3, 8, false, true)
                if offset ~= nil then
                    spawnx, spawnz = pos.x + offset.x, pos.z + offset.z
                end
            end

            local klaus = SpawnPrefab("klaus")
            klaus.Transform:SetPosition(spawnx or pos.x, 0, spawnz or pos.z)
            klaus:SpawnDeer()
            -- override the spawn point so klaus comes to his sack
            klaus.components.knownlocations:RememberLocation("spawnpoint", pos, false)
            klaus.components.spawnfader:FadeIn()

            inst.components.entitytracker:TrackEntity("klaus", klaus)
            inst:ListenForEvent("dropkey", inst.OnDropKey, klaus)
        end
        return false, "WRONGKEY", true
    end
end

local function OnSave(inst, data)
    data.despawnday = inst.despawnday
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.despawnday = data.despawnday or 0
    end
end

local function OnLoadPostPass(inst)
    local klaus = inst.components.entitytracker:GetEntity("klaus")
    if klaus ~= nil then
        inst:ListenForEvent("dropkey", inst.OnDropKey, klaus)
    end
end

--Also called from klaussackspawner
local function OnDropKey(inst, key, klaus)
    local oldkey = inst.components.entitytracker:GetEntity("key")
    if oldkey ~= nil then
        if klaus == nil then
            return
        end
        inst.components.entitytracker:ForgetEntity("key")
    end
    inst.components.entitytracker:TrackEntity("key", key)
end

local function validatesack(inst)
    if not IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and
        TheWorld.state.cycles >= inst.despawnday and
        inst.components.entitytracker:GetEntity("klaus") == nil and
        inst.components.entitytracker:GetEntity("key") == nil then
        inst:Remove()
    end
end

local function OnInit(inst)
    inst.OnEntityWake = validatesack
    inst.OnEntitySleep = validatesack
    if inst:IsAsleep() then
        validatesack(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("klaus_bag")
    inst.AnimState:SetBuild("klaus_bag")
    inst.AnimState:PlayAnimation("idle")
    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        inst.AnimState:OverrideSymbol("swap_chain", "klaus_bag", "swap_chain_winter")
        inst.AnimState:OverrideSymbol("swap_chain_link", "klaus_bag", "swap_chain_link_winter")
        inst.AnimState:OverrideSymbol("swap_chain_lock", "klaus_bag", "swap_chain_lock_winter")
    end

    inst.MiniMapEntity:SetIcon("klaus_sack.png")

    --klaussacklock (from klaussacklock component) added to pristine state for optimization
    inst:AddTag("klaussacklock")

    inst:AddTag("antlion_sinkhole_blocker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("klaussacklock")
    inst.components.klaussacklock:SetOnUseKey(onuseklauskey)

    inst:AddComponent("entitytracker")

    MakeHauntableWork(inst)

    inst:DoTaskInTime(0, OnInit)

    inst.despawnday = TheWorld.state.cycles + TheWorld.state.winterlength

    TheWorld:PushEvent("ms_registerklaussack", inst)

    inst.OnDropKey = function(klaus, key) OnDropKey(inst, key, klaus) end

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("klaus_sack", fn, assets, prefabs)
