require("worldsettingsutil")

local prefabs =
{
    "killerbee", --replace with wasp
}

local assets =
{
    Asset("ANIM", "anim/wasphive.zip"),
    Asset("SOUND", "sound/bee.fsb"), --replace with wasp
}

local function OnIgnite(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren(nil, "killerbee")
    end
    inst.SoundEmitter:KillSound("loop")
    DefaultBurnFn(inst)
end

local function OnKilled(inst)
    inst:RemoveComponent("childspawner")
    inst.AnimState:PlayAnimation("cocoon_dead", true)
    RemovePhysicsColliders(inst)

    inst.SoundEmitter:KillSound("loop")

    inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_destroy") --replace with wasp
    inst.components.lootdropper:DropLoot(inst:GetPosition()) --any loot drops?
end

local function onnear(inst, target)
    --hive pop open? Maybe rustle to indicate danger?
    --more and more come out the closer you get to the nest?
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren(target, "killerbee")
    end
end

local function onhitbyplayer(inst, attacker, damage)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren(attacker, "killerbee")
    end
    if not inst.components.health:IsDead() then
        inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_hit")
        inst.AnimState:PlayAnimation("cocoon_small_hit")
        inst.AnimState:PushAnimation("cocoon_small", true)
    end
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/bee/killerbee_hive_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "insect", "playerghost", "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "animal", "monster" }
local function OnHaunt(inst)
    if inst.components.childspawner == nil or
        not inst.components.childspawner:CanSpawn() or
        math.random() > TUNING.HAUNT_CHANCE_HALF then
        return false
    end

    local target = FindEntity(
        inst,
        25,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        RETARGET_MUST_TAGS, --See entityreplica.lua (re: "_combat" tag)
        RETARGET_CANT_TAGS,
        RETARGET_ONEOF_TAGS
    )

    if target ~= nil then
        onhitbyplayer(inst, target)
        return true
    end
    return false
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.WASPHIVE_RELEASE_TIME, TUNING.WASPHIVE_REGEN_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)

    inst.MiniMapEntity:SetIcon("wasphive.png") --replace with wasp version if there is one.

    inst.AnimState:SetBank("wasphive")
    inst.AnimState:SetBuild("wasphive")
    inst.AnimState:PlayAnimation("cocoon_small", true)

    inst:AddTag("structure")
    inst:AddTag("hive")
    inst:AddTag("WORM_DANGER")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(250) --increase health?
    -------------------------
    inst:AddComponent("childspawner")
    --Set spawner to wasp. Change tuning values to wasp values.
    inst.components.childspawner.childspawner = "killerbee"
    inst.components.childspawner:SetRegenPeriod(TUNING.WASPHIVE_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.WASPHIVE_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.WASPHIVE_WASPS)
    inst.components.childspawner.emergencychildname = "killerbee"
    inst.components.childspawner.emergencychildrenperplayer = 1
    inst.components.childspawner.canemergencyspawn = TUNING.WASPHIVE_ENABLED
    inst.components.childspawner:SetMaxEmergencyChildren(TUNING.WASPHIVE_EMERGENCY_WASPS)
    inst.components.childspawner:SetEmergencyRadius(TUNING.WASPHIVE_EMERGENCY_RADIUS)
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.WASPHIVE_RELEASE_TIME, TUNING.WASPHIVE_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.WASPHIVE_REGEN_TIME, TUNING.WASPHIVE_ENABLED)
    if not TUNING.WASPHIVE_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    -------------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({ "honey", "honey", "honey", "honeycomb" })
    -------------------------
    MakeLargeBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    -------------------------
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 13) --set specific values
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetPlayerAliveMode(inst.components.playerprox.AliveModes.AliveOnly)
    -------------------------
    inst:AddComponent("combat")
    --wasp hive should trigger on proximity, release wasps.
    inst.components.combat:SetOnHit(onhitbyplayer)
    inst:ListenForEvent("death", OnKilled)
    -------------------------
    MakeMediumPropagator(inst)
    MakeSnowCovered(inst)
    -------------------------
    inst:AddComponent("inspectable")
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_MEDIUM)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("wasphive", fn, assets, prefabs)
