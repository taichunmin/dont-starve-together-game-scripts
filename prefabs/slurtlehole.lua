require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/slurtle_mound.zip"),
    Asset("MINIMAP_IMAGE", "slurtle_den"),
}

local prefabs =
{
    "slurtle",
    "snurtle",
    "slurtleslime",
    "slurtle_shellpieces",
    "explode_small",
}

SetSharedLootTable("slurtlehole",
{
    {"slurtleslime", 1.0},
    {"slurtleslime", 1.0},
    {"slurtleslime", 1.0},
    {"slurtle_shellpieces", 1.0},
})

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/mound_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function ReturnChildren(inst)
    for k, child in pairs(inst.components.childspawner.childrenoutside) do
        if child.components.homeseeker ~= nil then
            child.components.homeseeker:GoHome()
        end
        child:PushEvent("gohome")
    end
end

local function OnHit(inst, attacker, damage)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:SpawnChild(attacker)
    end
    if not inst.components.health:IsDead() then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function OnDoKilled(inst)
    inst.components.lootdropper:DropLoot(inst:GetPosition())
    inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/mound_explode")
end

local function OnKilled(inst)
    inst:RemoveComponent("childspawner")
    inst.AnimState:PlayAnimation("break")
    inst.AnimState:PushAnimation("idle_broken")
    RemovePhysicsColliders(inst)
    inst:DoTaskInTime(0.66, OnDoKilled)
end

local function OnPostEndQuake(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:StopSpawning()
    end
end

local function OnIgniteFn(inst)
    inst.AnimState:PlayAnimation("shake", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
    end
    DefaultBurnFn(inst)
end

local function OnExtinguishFn(inst)
    inst.SoundEmitter:KillSound("hiss")
    DefaultExtinguishFn(inst)
end

local function OnExplodeFn(inst)
    inst.SoundEmitter:KillSound("hiss")
    SpawnPrefab("explode_small_slurtlehole").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.SLURTLEHOLE_SPAWN_PERIOD, TUNING.SLURTLEHOLE_REGEN_PERIOD)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 2)

    inst.MiniMapEntity:SetIcon("slurtle_den.png")

    inst.AnimState:SetBuild("slurtle_mound")
    inst.AnimState:SetBank("slurtle_mound")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("cavedweller")
    inst:AddTag("hostile")
    inst:AddTag("explosive")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetRegenPeriod(TUNING.SLURTLEHOLE_REGEN_PERIOD)
    inst.components.childspawner:SetSpawnPeriod(TUNING.SLURTLEHOLE_SPAWN_PERIOD)
    if TUNING.SLURTLEHOLE_CHILDREN.max == 0 then
        inst.components.childspawner:SetMaxChildren(0)
    else
        inst.components.childspawner:SetMaxChildren(math.random(TUNING.SLURTLEHOLE_CHILDREN.min, TUNING.SLURTLEHOLE_CHILDREN.max))
    end
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.SLURTLEHOLE_SPAWN_PERIOD, TUNING.SLURTLEHOLE_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.SLURTLEHOLE_REGEN_PERIOD, TUNING.SLURTLEHOLE_ENABLED)
    if not TUNING.SLURTLEHOLE_ENABLED then
        inst.components.childspawner.childreninside = 0
    end
    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "slurtle"
    inst.components.childspawner:SetRareChild("snurtle", TUNING.SLURTLEHOLE_RARECHILD_CHANCE)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("slurtlehole")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(350)

    inst:AddComponent("combat")
    inst.components.combat:SetOnHit(OnHit)

    inst:ListenForEvent("death", OnKilled)

    inst:ListenForEvent("endquake", function()
        if inst.components.childspawner ~= nil then
            inst.components.childspawner:StartSpawning()
            inst:DoTaskInTime(15, OnPostEndQuake)
        end
    end, TheWorld.net)

    inst:AddComponent("inspectable")

    MakeLargeBurnable(inst)
    --V2C: Remove default OnBurnt handler, as it conflicts with
    --explosive component's OnBurnt handler for removing itself
    inst.components.burnable:SetOnBurntFn(nil)
    inst.components.burnable:SetOnIgniteFn(OnIgniteFn)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguishFn)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive.explosivedamage = 50
    inst.components.explosive.buildingdamage = 15
    inst.components.explosive.lightonexplode = false

    MakeHauntableIgnite(inst)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("slurtlehole", fn, assets, prefabs)
