require "prefabutil"

-- In the anim file, '1' is the highest tier, '3' the lowest (0 means it's destroyed...)
local ANIM_THRESHOLDS =
{
    0.67,
    0.33,
    0,
}

local function getanimthreshold(inst, percent)
    for i, v in ipairs(ANIM_THRESHOLDS) do
        if percent >= v then
            return i
        end
    end
    return #ANIM_THRESHOLDS
end

local function onhealthchange(inst, old_percent, new_percent)
    if not inst or not inst:IsValid() or inst.sg:HasStateTag("dead") then
        return
    end

    -- Play transition animation from one damaged state to another
    local oldindex = getanimthreshold(inst, old_percent)
    local newindex = getanimthreshold(inst, new_percent)
    if new_percent <= 0 then
        inst.sg:GoToState("death")
    elseif oldindex ~= newindex then
        inst.sg:GoToState("changegrade", {
            index = oldindex,
            newindex = newindex,
            isupgrade = (newindex < oldindex) or nil,
        })
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)

    if data.burnt and inst.components.burnable ~= nil and inst.components.burnable.onburnt ~= nil then
        inst.components.burnable.onburnt(inst)
    end

    if inst.components.health then
        local healthpercent = inst.components.health:GetPercent()
        local stateindex = getanimthreshold(inst, healthpercent)
        inst.sg:GoToState("idle", stateindex)
    end
end

local PLAYER_TAGS = { "player" }
local function ValidRepairFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsAboveGroundAtPoint(x, y, z) then
        return true
    end

    if TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
        for i, v in ipairs(TheSim:FindEntities(x, 0, z, 1, PLAYER_TAGS)) do
            if v ~= inst and
            v.entity:IsVisible() and
            v.components.placer == nil and
            v.entity:GetParent() == nil then
                local px, _, pz = v.Transform:GetWorldPosition()
                if math.floor(x) == math.floor(px) and math.floor(z) == math.floor(pz) then
                    return false
                end
            end
        end
    end
    return true
end

local BOAT_MUST_TAGS = {"boat"}
local function CanDeployAtBoatEdge(inst, pt, mouseover, deployer, rot)
    local boat = (mouseover ~= nil and mouseover:HasTag("boat") and mouseover) or nil
    if not boat then
        boat = TheWorld.Map:GetPlatformAtPoint(pt.x,pt.z)

        -- If we're not standing on a boat, try to get the closest boat position via FindEntities()
        if not boat or not boat:HasTag("boat") then
            local boats = TheSim:FindEntities(pt.x, 0, pt.z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS, BOAT_MUST_TAGS)
            if #boats <= 0 then
                return false
            end
            boat = GetClosest(inst, boats)
        end
    end

    if not boat then return false end

    -- Check the outside rim to see if no objects are there
    local boatpos = boat:GetPosition()
    local boatangle = boat.Transform:GetRotation()

    -- Need to look a little outside of the boat edge here
    local boatringdata = boat.components.boatringdata
    local radius = (boatringdata and boatringdata:GetRadius() + 0.25) or 0
    local boatsegments = (boatringdata and boatringdata:GetNumSegments()) or 1

    local snap_point = GetCircleEdgeSnapTransform(boatsegments, radius, boatpos, pt, boatangle)
    return TheWorld.Map:CanDeployWalkablePeripheralAtPoint(snap_point, inst)
end

local function setup_boat_placer(inst)
    inst.components.placer.snap_to_boat_edge = true
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT_BUMPERS)
    inst.AnimState:SetFinalOffset(1)
end

local function CrabkingKit_OnDroppedAsLoot(inst)
    inst.components.stackable:SetStackSize(TUNING.BOAT.BUMPERS.CRABKING.STACKSIZE)

    inst:RemoveEventCallback("on_loot_dropped", inst._OnDroppedAsLoot)
end

local function shell_kit_masterpostinit(inst)
    inst.scrapbook_scale = 0.8
end

local function crabking_kit_masterpostinit(inst)
    inst.scrapbook_scale = 0.7

    inst._OnDroppedAsLoot = CrabkingKit_OnDroppedAsLoot -- Mods.

    inst:ListenForEvent("on_loot_dropped", inst._OnDroppedAsLoot)
end

function MakeBumperType(data)
    local assets =
    {
        Asset("ANIM", "anim/boat_bumper.zip"), -- Anim file (and build for kelp bumper)
    }

    -- Default is kelp, so no need to load a build anim for it
    local buildname = data.name ~= nil and data.name ~= "kelp" and "boat_bumper_" .. data.name or "boat_bumper"
    if buildname ~= "boat_bumper" then
        table.insert(assets, Asset("ANIM", "anim/" .. buildname .. ".zip"))
    end

    local prefabs =
    {
        "collapse_small",
    }

    local function onbuilt(inst, builddata) -- builder, pos, rot, deployable
        if builddata == nil then
            return
        end

        inst.sg:GoToState("place")
        local boat = TheWorld.Map:GetPlatformAtPoint(builddata.pos.x, builddata.pos.z)

        -- If clicked point isn't on a boat, try to get the closest boat via FindEntities()
        if not boat then
            local boats = TheSim:FindEntities(builddata.pos.x, 0, builddata.pos.z, TUNING.BOAT.RADIUS, BOAT_MUST_TAGS)
            if boats then
                boat = GetClosest(inst, boats)
            end
        end

        if boat then
            SnapToBoatEdge(inst, boat, builddata.pos)
            boat.components.boatring:AddBumper(inst)
        end

        if data.buildsound then
            inst.SoundEmitter:PlaySound(data.buildsound)
        end
    end

    local function onhammered(inst, worker)
        if data.maxloots and data.loot then
            local num_loots = math.max(1, math.floor(data.maxloots * inst.components.health:GetPercent()))
            for _ = 1, num_loots do
                inst.components.lootdropper:SpawnLootPrefab(data.loot)
            end
        end

        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if data.material then
            fx:SetMaterial(data.material)
        end

        inst:Remove()
    end

    local function onhit(inst)
        if inst.sg:HasStateTag("busy") then
            return
        end

        local healthpercent = inst.components.health:GetPercent()
        if healthpercent > 0 then
            local animindex = getanimthreshold(inst, healthpercent)
            inst.sg:GoToState("hit", {index = animindex})
        end
    end

    local function ondeath(inst)
        -- Remove bumper from list of boat bumpers
        local pos = inst:GetPosition()
        local boat = TheWorld.Map:GetPlatformAtPoint(pos.x, pos.z)
        if boat and boat.components.boatring then
            boat.components.boatring:RemoveBumper(inst)
        end
    end

    local function onrepaired(inst)
        if data.buildsound then
            inst.SoundEmitter:PlaySound(data.buildsound)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetNoFaced()

        inst:AddTag("boatbumper")
        inst:AddTag("mustforceattack")
        inst:AddTag("noauradamage")
        inst:AddTag("walkableperipheral")

        inst.AnimState:SetBank("boat_bumper")
        inst.AnimState:SetBuild(buildname)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT_BUMPERS)

        inst:SetPhysicsRadiusOverride(0.75) -- For action distance.

        for _, v in ipairs(data.tags) do
            inst:AddTag(v)
        end

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_anim = "idle_1"
        inst.scrapbook_scale = 0.7

        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")
        inst:AddComponent("savedrotation")

        local repairable = inst:AddComponent("repairable")
        repairable.repairmaterial = data.material
        repairable.onrepaired = onrepaired
        repairable.testvalidrepairfn = ValidRepairFn

        inst:ListenForEvent("onbuilt", onbuilt)
        inst:ListenForEvent("boatcollision", onhit)
        inst:ListenForEvent("death", ondeath)

        local health = inst:AddComponent("health")
        health:SetMaxHealth(data.maxhealth)
        health.ondelta = onhealthchange
        health.nofadeout = true
        health.canheal = false

        if data.flammable then
            local burnable = MakeMediumBurnable(inst)
            MakeLargePropagator(inst)
            burnable.flammability = .5
            burnable.nocharring = true

            --lame!
            if data.name == "kelp" then
                inst.components.propagator.flashpoint = 30 + math.random() * 10
            end
        else
            health.fire_damage_scale = 0
        end

        local workable = inst:AddComponent("workable")
        workable:SetWorkAction(ACTIONS.HAMMER)
        workable:SetWorkLeft(data.name == MATERIALS.MOONROCK and TUNING.MOONROCKWALL_WORK or 3)
        workable:SetOnFinishCallback(onhammered)
        workable:SetOnWorkCallback(onhit)

        MakeHauntableWork(inst)

        inst:SetStateGraph("SGboatbumper")
        inst.sg.mem.bumpertype = data.name -- For determining which FX name to play, which is dependant on the bumper type

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab("boat_bumper_"..data.name, fn, assets, prefabs),
        MakeDeployableKitItem(
            "boat_bumper_"..data.name.."_kit",
            "boat_bumper_"..data.name,
            "boat_bumper",
            buildname,
            "idle",
            assets,
            {size = "med"},
            {"boat_accessory"},
            data.flammable and {fuelvalue = TUNING.LARGE_FUEL} or nil,
            {
                deploymode = DEPLOYMODE.CUSTOM,
                deployspacing = DEPLOYSPACING.MEDIUM,
                custom_candeploy_fn = CanDeployAtBoatEdge,
            },
            TUNING.STACK_SIZE_MEDITEM,
            data.kitpostinit
        ),
        MakePlacer(
            "boat_bumper_"..data.name.."_kit_placer",
            "boat_bumper",
            buildname,
            "idle_1",
            false, false, false,
            nil, nil, nil--[[NoFaced]],
            setup_boat_placer
        )
end

local boatbumperprefabs = {}

local boatbumperdata =
{
    {
        name = "kelp",
        material = MATERIALS.KELP,
        tags = { "kelp" },
        loot = "kelp",
        maxloots = 2,
        maxhealth = TUNING.BOAT.BUMPERS.KELP.HEALTH,
        flammable = true,
        buildsound = "dontstarve/common/place_structure_straw",
    },
    {
        name = "shell",
        material = MATERIALS.SHELL,
        tags = { "shell" },
        loot = "slurtle_shellpieces",
        maxloots = 2,
        maxhealth = TUNING.BOAT.BUMPERS.SHELL.HEALTH,
        flammable = true,
        buildsound = "dontstarve/common/place_structure_stone",
        kitpostinit = shell_kit_masterpostinit,
    },
    {
        name = "yotd",
        material = MATERIALS.WOOD,
        tags = {},
        loot = nil,
        maxloots = nil,
        maxhealth = TUNING.BOAT.BUMPERS.SHELL.HEALTH,
        flammable = false,
        buildsound = "dontstarve/common/place_structure_wood",
    },
    {
        name = "crabking",
        material = MATERIALS.STONE,
        tags = { "collision_world_safe" },
        loot = "rocks",
        maxloots = 3,
        maxhealth = TUNING.BOAT.BUMPERS.CRABKING.HEALTH,
        flammable = false,
        buildsound = "dontstarve/common/place_structure_stone",
        kitpostinit = crabking_kit_masterpostinit,
    },
}
for _, v in ipairs(boatbumperdata) do
    local boatbumper, item, placer = MakeBumperType(v)
    table.insert(boatbumperprefabs, boatbumper)
    table.insert(boatbumperprefabs, item)
    table.insert(boatbumperprefabs, placer)
end

return unpack(boatbumperprefabs)

