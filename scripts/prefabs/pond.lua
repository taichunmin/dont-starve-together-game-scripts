require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/marsh_tile.zip"),
    Asset("ANIM", "anim/splash.zip"),
}

local prefabs_normal =
{
    "marsh_plant",
    "pondfish",
    "frog",
}

local prefabs_mos =
{
    "marsh_plant",
    "pondfish",
    "mosquito",
}

local prefabs_cave =
{
    "pondeel",
    "nitre",
    "nitre_formation",
}

local function SpawnNitreFormations(inst)
    if inst.nitreformation_ents ~= nil then
        return
    end

    if inst.nitreformations == nil then
        inst.nitreformations = {}
        local theta = math.random() * PI2
        local count = math.random(3, 4)
        for i = 1, count do
            theta = theta + PI2 / count
            local radius = math.sqrt(math.random()) * 1.25 + 0.25
            table.insert(inst.nitreformations, {
                math.cos(theta) * radius, 0, math.sin(theta) * radius, -- offset
                math.random(1, 3) -- animation
            })
        end
    end

    inst.nitreformation_ents = {}

    for i, v in pairs(inst.nitreformations) do
        if type(v) == "table" and #v >= 4 then
            local nitreformation = SpawnPrefab("nitre_formation")
            if nitreformation ~= nil then
                nitreformation.entity:SetParent(inst.entity)
                nitreformation.Transform:SetPosition(v[1], v[2], v[3])
                nitreformation.AnimState:PlayAnimation("idle" .. v[4])
                nitreformation.persists = false
                table.insert(inst.nitreformation_ents, nitreformation)
            end
        end
    end

	if not TheNet:IsDedicated() then
		inst.highlightchildren = inst.nitreformation_ents
	end
end

local function DespawnNitreFormations(inst)
    if inst.nitreformation_ents ~= nil then
        for i, v in ipairs(inst.nitreformation_ents) do
            if v:IsValid() then
                v:Remove()
            end
        end

        inst.nitreformation_ents = nil
    end

    inst.nitreformations = nil
	inst.highlightchildren = nil
end

local function SpawnPlants(inst)
    inst.task = nil

    if inst.plant_ents ~= nil then
        return
    end

    if inst.plants == nil then
        inst.plants = {}
        for _ = 1, math.random(2, 4) do
            local theta = math.random() * TWOPI
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

local function SlipperyRate(inst, target)
    local speed = target.Physics and target.Physics:GetMotorSpeed() or 0
    if speed > TUNING.WILSON_RUN_SPEED then
        return 50
    end

    return 5
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
            local slipperyfeettarget = inst:AddComponent("slipperyfeettarget")
            slipperyfeettarget:SetSlipperyRate(SlipperyRate)
        end
    elseif inst.frozen then
        inst.frozen = false
        inst.AnimState:PlayAnimation("idle"..inst.pondtype, true)
        inst.components.childspawner:StartSpawning()
        inst.components.fishable:Unfreeze()

		inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)

        SpawnPlants(inst)

        inst.components.watersource.available = true
        inst:RemoveComponent("slipperyfeettarget")
    elseif inst.frozen == nil then
        inst.frozen = false
        SpawnPlants(inst)
    end
end

local function OnSave(inst, data)
    data.plants = inst.plants
    data.nitreformations = inst.nitreformations
end

local function OnLoad(inst, data)
    if data ~= nil then
        if inst.task ~= nil and inst.plants == nil then
            inst.plants = data.plants
        end
    end
end

local function OnPreLoadMosquito(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MOSQUITO_POND_SPAWN_TIME, TUNING.MOSQUITO_POND_REGEN_TIME)
end

local function OnPreLoadFrog(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.FROG_POND_SPAWN_TIME, TUNING.FROG_POND_REGEN_TIME)
end

local function OnPreLoadCave(inst, data)
	inst.nitreformations = data and data.nitreformations or nil
end

local function commonfn(pondtype)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	MakePondPhysics(inst, 1.95)

    inst.AnimState:SetBuild("marsh_tile")
    inst.AnimState:SetBank("marsh_tile")
    inst.AnimState:PlayAnimation("idle"..pondtype, true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.MiniMapEntity:SetIcon("pond"..pondtype..".png")

    -- From watersource component
    inst:AddTag("watersource")
    inst:AddTag("pond")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")

    inst.no_wet_prefix = true

	inst:SetDeploySmartRadius(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.pondtype = pondtype

    inst:AddComponent("childspawner")

    --inst.frozen = nil
    --inst.acidinfused = nil
    --inst.plants = nil
    --inst.plant_ents = nil
    --inst.nitreformations = nil
    --inst.nitreformation_ents = nil

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

    inst.scrapbook_anim = "idle_mos"

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

local function PlayBubble(inst)
    if not inst.AnimState:IsCurrentAnimation("bubble_cave") then
        inst.AnimState:PlayAnimation("bubble_cave", true)
    end
    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble")
end

local function SetBackToNormal_Cave(inst)
    inst.AnimState:PushAnimation("splash_cave", true)
    inst.AnimState:PushAnimation("idle_cave", true)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")
    
    inst.components.workable:SetWorkable(false)

    inst.components.childspawner:StartSpawning()
    inst.components.fishable:Unfreeze()

    inst.components.watersource.available = true

	inst.components.inspectable.nameoverride = "pond"

    DespawnNitreFormations(inst)
end

local function SetAcidic_Cave(inst)
    inst.AnimState:PlayAnimation("idle_nitre", true)
    inst.SoundEmitter:PlaySound("hookline_2/common/shells/creature/dig")

    inst.components.workable:SetWorkable(true)

    inst.components.childspawner:StopSpawning()
    inst.components.fishable:Freeze()

    inst.components.watersource.available = false

	inst.components.inspectable.nameoverride = "nitre_formation"

	SpawnNitreFormations(inst)
end

local function OnAcidLevelDelta_Cave(inst, data)
    if not data then
        return
    end

    local oldacidic, newacidic = data.oldpercent, data.newpercent
    if newacidic > oldacidic then
        -- Grow nitre.
        if newacidic >= TUNING.ACIDRAIN_BOULDER_WORK_STARTS_PERCENT then
            if not inst.acidinfused then
                inst.acidinfused = true
                inst.components.acidlevel:SetPercent(1) -- Make the extreme pop so when it flips state it has time to go backwards.
                SetAcidic_Cave(inst)
            end
        else
            PlayBubble(inst)
        end
    elseif newacidic < oldacidic then
        -- Dissolve nitre.
        if newacidic < TUNING.ACIDRAIN_BOULDER_WORK_STARTS_PERCENT then
            if newacidic == 0 then
                if inst.acidinfused then
                    inst.acidinfused = nil
                    inst.components.acidlevel:SetPercent(0) -- Make the extreme pop so when it flips state it has time to go backwards.
                    SetBackToNormal_Cave(inst)
                end
            else
                PlayBubble(inst)
            end
        end
    --else
        -- No change.
    end
end

local function OnStopIsAcidRaining(inst)
    if not inst.acidinfused then
        -- Stop bubbling when idle even if slightly acidic.
        SetBackToNormal_Cave(inst)
    end
end

local function OnPondCaveMinedFinished(inst, miner)
    local pt = inst:GetPosition()
    for i = 1, 2 + math.random(2) do
        inst.components.lootdropper:SpawnLootPrefab("nitre", pt)
    end
    inst.components.workable:SetWorkLeft(TUNING.ACIDRAIN_BOULDER_WORK)
    inst.components.acidlevel:SetPercent(0)
end

local function PondCaveDisplayNameFn(inst)
	return inst:HasTag("MINE_workable") and STRINGS.NAMES.NITRE_FORMATION or nil
end

local function pondcave()
    local inst = commonfn("_cave")

	inst.displaynamefn = PondCaveDisplayNameFn
    inst.scrapbook_anim = "idle_cave"
    inst.scrapbook_specialinfo = "PONDCAVE"

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.fishable:AddFish("pondeel")

    inst:AddComponent("lootdropper")

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.MINE)
    workable:SetOnFinishCallback(OnPondCaveMinedFinished)
    workable:SetMaxWork(TUNING.ACIDRAIN_BOULDER_WORK)
    workable:SetWorkLeft(TUNING.ACIDRAIN_BOULDER_WORK)
    workable:SetWorkable(false)
    workable.savestate = true

    local acidlevel = inst:AddComponent("acidlevel")
    inst:ListenForEvent("acidleveldelta", OnAcidLevelDelta_Cave)
    acidlevel:SetOnStopIsAcidRainingFn(OnStopIsAcidRaining)
	acidlevel:SetOnStopIsRainingFn(OnStopIsAcidRaining)
	inst:ListenForEvent("gainrainimmunity", OnStopIsAcidRaining)

    inst.planttype = "pond_algae"
    inst.task = inst:DoTaskInTime(0, SpawnPlants)

	inst.OnPreLoad = OnPreLoadCave

    --These spawn nothing at this time.
    return inst
end

return
        Prefab( "pond",      pondfrog, assets, prefabs_normal ),
        Prefab( "pond_mos",  pondmos,  assets, prefabs_mos    ),
        Prefab( "pond_cave", pondcave, assets, prefabs_cave   )
