require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/marsh_tile.zip"),
    Asset("ANIM", "anim/splash.zip"),
}

local prefabs =
{
    "marsh_plant",
	"pondfish",
	"pondeel",
    "frog",
    "mosquito",
}

local function SpawnPlants(inst)
    inst.task = nil

    if inst.plant_ents ~= nil then
        return
    end

    if inst.plants == nil then
        inst.plants = {}
        for i = 1, math.random(2, 4) do
            local theta = math.random() * 2 * PI
            table.insert(inst.plants,
            {
                offset =
                {
                    math.sin(theta) * 1.9 + math.random() * .3,
                    0,
                    math.cos(theta) * 2.1 + math.random() * .3,
                },
            })
        end
    end

    inst.plant_ents = {}

    for i, v in pairs(inst.plants) do
        if type(v.offset) == "table" and #v.offset == 3 then
            local plant = SpawnPrefab(inst.planttype)
            if plant ~= nil then
                plant.entity:SetParent(inst.entity)
                plant.Transform:SetPosition(unpack(v.offset))
                plant.persists = false
                table.insert(inst.plant_ents, plant)
            end
        end
    end
end

local function DespawnPlants(inst)
    if inst.plant_ents ~= nil then
        for i, v in ipairs(inst.plant_ents) do
            if v:IsValid() then
                v:Remove()
            end
        end

        inst.plant_ents = nil
    end

    inst.plants = nil
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel > .02 then
        if not inst.frozen then
            inst.frozen = true
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/winter/pondfreeze")
            inst.components.childspawner:StopSpawning()
            inst.components.fishable:Freeze()

            inst.Physics:SetCollisionGroup(COLLISION.LAND_OCEAN_LIMITS)
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.WORLD)
            inst.Physics:CollidesWith(COLLISION.ITEMS)

            DespawnPlants(inst)

            inst.components.watersource.available = false
        end
    elseif inst.frozen then
        inst.frozen = false
        inst.AnimState:PlayAnimation("idle"..inst.pondtype, true)
        inst.components.childspawner:StartSpawning()
        inst.components.fishable:Unfreeze()

        inst.Physics:SetCollisionGroup(COLLISION.LAND_OCEAN_LIMITS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)

        SpawnPlants(inst)

        inst.components.watersource.available = true
    elseif inst.frozen == nil then
        inst.frozen = false
        SpawnPlants(inst)
    end
end

local function OnSave(inst, data)
    data.plants = inst.plants
end

local function OnLoad(inst, data)
    if data ~= nil and data.plants ~= nil and inst.plants == nil and inst.task ~= nil then
        inst.plants = data.plants
    end
end

local function OnPreLoadMosquito(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MOSQUITO_POND_SPAWN_TIME, TUNING.MOSQUITO_POND_REGEN_TIME)
end

local function OnPreLoadFrog(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.FROG_POND_SPAWN_TIME, TUNING.FROG_POND_REGEN_TIME)
end

local function commonfn(pondtype)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    local phys = inst.entity:AddPhysics()
    phys:SetMass(0) --Bullet wants 0 mass for static objects
    phys:SetCollisionGroup(COLLISION.LAND_OCEAN_LIMITS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCapsule(1.95, 2)
    inst:AddTag("blocker")

    inst.AnimState:SetBuild("marsh_tile")
    inst.AnimState:SetBank("marsh_tile")
    inst.AnimState:PlayAnimation("idle"..pondtype, true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.MiniMapEntity:SetIcon("pond"..pondtype..".png")

    -- From watersource component
    inst:AddTag("watersource")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")

    inst.no_wet_prefix = true

    inst:SetDeployExtraSpacing(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.pondtype = pondtype

    inst:AddComponent("childspawner")

    inst.frozen = nil
    inst.plants = nil
    inst.plant_ents = nil

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "pond"

    inst:AddComponent("fishable")
    inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("watersource")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function ReturnChildren(inst)
    for k, child in pairs(inst.components.childspawner.childrenoutside) do
        if child.components.homeseeker ~= nil then
            child.components.homeseeker:GoHome()
        end
        child:PushEvent("gohome")
    end
end

local function OnIsDay(inst, isday)
    if isday ~= inst.dayspawn then
        inst.components.childspawner:StopSpawning()
        ReturnChildren(inst)
    elseif not TheWorld.state.iswinter then
        inst.components.childspawner:StartSpawning()
    end
end

local function OnInit(inst)
    inst.task = nil
    inst:WatchWorldState("isday", OnIsDay)
    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnIsDay(inst, TheWorld.state.isday)
    OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function pondmos()
    local inst = commonfn("_mos")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.childspawner:SetSpawnPeriod(TUNING.MOSQUITO_POND_SPAWN_TIME)
    inst.components.childspawner:SetRegenPeriod(TUNING.MOSQUITO_POND_REGEN_TIME)
    if TUNING.MOSQUITO_POND_CHILDREN.max == 0 then
        inst.components.childspawner:SetMaxChildren(0)
    else
        inst.components.childspawner:SetMaxChildren(math.random(TUNING.MOSQUITO_POND_CHILDREN.min, TUNING.MOSQUITO_POND_CHILDREN.max))
    end

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MOSQUITO_POND_SPAWN_TIME, TUNING.MOSQUITO_POND_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MOSQUITO_POND_REGEN_TIME, TUNING.MOSQUITO_POND_ENABLED)
    if not TUNING.MOSQUITO_POND_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "mosquito"
    inst.components.fishable:AddFish("pondfish")

    inst.planttype = "marsh_plant"
    inst.dayspawn = false
    inst.task = inst:DoTaskInTime(0, OnInit)

    inst.OnPreLoad = OnPreLoadMosquito

    return inst
end

local function pondfrog()
    local inst = commonfn("")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.childspawner:SetSpawnPeriod(TUNING.FROG_POND_SPAWN_TIME)
    inst.components.childspawner:SetRegenPeriod(TUNING.FROG_POND_REGEN_TIME)
    if TUNING.FROG_POND_CHILDREN.max == 0 then
        inst.components.childspawner:SetMaxChildren(0)
    else
        inst.components.childspawner:SetMaxChildren(math.random(TUNING.FROG_POND_CHILDREN.min, TUNING.FROG_POND_CHILDREN.max))
    end

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.FROG_POND_SPAWN_TIME, TUNING.FROG_POND_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.FROG_POND_REGEN_TIME, TUNING.FROG_POND_ENABLED)
    if not TUNING.FROG_POND_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "frog"
    inst.components.fishable:AddFish("pondfish")

    inst.planttype = "marsh_plant"
    inst.dayspawn = true
    inst.task = inst:DoTaskInTime(0, OnInit)

    inst.OnPreLoad = OnPreLoadFrog

    return inst
end

local function pondcave()
    local inst = commonfn("_cave")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.fishable:AddFish("pondeel")

    inst.planttype = "pond_algae"
    inst.task = inst:DoTaskInTime(0, SpawnPlants)

    --These spawn nothing at this time.
    return inst
end

return Prefab("pond", pondfrog, assets, prefabs),
    Prefab("pond_mos", pondmos, assets, prefabs),
    Prefab("pond_cave", pondcave, assets, prefabs)
