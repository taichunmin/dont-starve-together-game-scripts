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

require("components/klaussackloot") --contains GLOBAL function AddGiantLootPrefabs
AddGiantLootPrefabs(prefabs)

for i, v in ipairs(GetAllWinterOrnamentPrefabs()) do
    table.insert(prefabs, v)
end

local function DropBundle(inst, items)
    for i, v in ipairs(items) do
        if type(v) == "string" then
            items[i] = SpawnPrefab(v)
        else
            items[i] = SpawnPrefab(v[1])
			items[i].components.stackable:SetStackSize(v[2])
        end
    end

    local bundle = SpawnPrefab(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "gift" or "bundle")
    bundle.components.unwrappable:WrapItems(items)
    for i, v in ipairs(items) do
        v:Remove()
    end
    inst.components.lootdropper:FlingItem(bundle)
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

        for i, items in ipairs(TheWorld.components.klaussackloot:GetLoot()) do
            DropBundle(inst, items)
        end

        inst.persists = false
        inst:AddTag("NOCLICK")
        inst:DoTaskInTime(1, ErodeAway)

        inst:RemoveComponent("klaussacklock")

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
                math.random() * TWOPI, 33, 16, true, true,
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
                local offset = FindWalkableOffset(pos, math.random() * TWOPI, 3, 8, false, true)
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

    MakeSmallObstaclePhysics(inst, 1)

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
