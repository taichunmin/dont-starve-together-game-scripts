require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/hound_base.zip"),
    Asset("SOUND", "sound/hound.fsb"),
	Asset("MINIMAP_IMAGE", "hound_mound"),
}

local prefabs =
{
    "hound",
    "firehound",
    "icehound",
    "houndstooth",
    "boneshard",
}

SetSharedLootTable('hound_mound',
{
    {'houndstooth', 1.00},
    {'houndstooth', 1.00},
    {'houndstooth', 1.00},
    {'boneshard',   1.00},
    {'boneshard',   1.00},
    {'redgem',      0.01},
    {'bluegem',     0.01},
})

local function GetSpecialHoundChance()
    local day = TheWorld.state.cycles
    local chance = 0
    for k, v in ipairs(TUNING.HOUND_SPECIAL_CHANCE) do
        if day <= v.minday then
            return chance
        end
        chance = v.chance
    end
    return chance
end

local function SpawnGuardHound(inst, attacker)
    local prefab =
        (math.random() >= GetSpecialHoundChance() and "hound") or
        ((TheWorld.state.iswinter or TheWorld.state.isspring) and "icehound") or
        "firehound"
    local defender = inst.components.childspawner:SpawnChild(attacker, prefab)
    if defender ~= nil and attacker ~= nil and defender.components.combat ~= nil then
        defender.components.combat:SetTarget(attacker)
        defender.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
    end
end

local function SpawnGuards(inst)
    if not inst.components.health:IsDead() and inst.components.childspawner ~= nil then
        local num_to_release = math.min(3, inst.components.childspawner.childreninside)
        for k = 1, num_to_release do
            SpawnGuardHound(inst)
        end
    end
end

local function SpawnAllGuards(inst, attacker)
    if not inst.components.health:IsDead() and inst.components.childspawner ~= nil then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
        local num_to_release = inst.components.childspawner.childreninside
        for k = 1, num_to_release do
            SpawnGuardHound(inst)
        end
    end
end

local function OnKilled(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
    end
    inst.AnimState:PlayAnimation("death", false)
    inst.SoundEmitter:KillSound("loop")
    inst.components.lootdropper:DropLoot(inst:GetPosition())
end

local function OnIsSummer(inst, issummer)
    inst.components.childspawner:SetRareChild("firehound", issummer and 0.2 or 0)
end

local HAUNTTARGET_MUST_TAGS = { "_combat" }
local HAUNTTARGET_CANT_TAGS = { "wall", "playerghost", "houndmound", "hound", "houndfriend", "INLIMBO" }

local function OnHaunt(inst, haunter)
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
        HAUNTTARGET_MUST_TAGS, --See entityreplica.lua (re: "_combat" tag)
        HAUNTTARGET_CANT_TAGS
    )

    if target ~= nil then
        SpawnAllGuards(inst, target)
        return true
    end
    return false
end

local function OnEntityWake(inst)
    inst.components.childspawner:StartSpawning()
    inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/mound_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.HOUNDMOUND_RELEASE_TIME, TUNING.HOUNDMOUND_REGEN_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("hound_mound.png")

    inst.AnimState:SetBank("houndbase")
    inst.AnimState:SetBuild("hound_base")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("beaverchewable") -- by werebeaver
    inst:AddTag("houndmound")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(300)
    inst:ListenForEvent("death", OnKilled)

    -------------------
    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "hound"
    inst.components.childspawner:SetRegenPeriod(TUNING.HOUNDMOUND_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.HOUNDMOUND_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(math.random(TUNING.HOUNDMOUND_HOUNDS_MIN, TUNING.HOUNDMOUND_HOUNDS_MAX))

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.HOUNDMOUND_REGEN_TIME, TUNING.HOUNDMOUND_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.HOUNDMOUND_RELEASE_TIME, TUNING.HOUNDMOUND_ENABLED)
    if not TUNING.HOUNDMOUND_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst:WatchWorldState("issummer", OnIsSummer)
    OnIsSummer(inst, TheWorld.state.issummer)

    ---------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('hound_mound')

    inst:AddComponent("combat")
    inst.components.combat:SetOnHit(SpawnAllGuards)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    ---------------------
    inst:AddComponent("inspectable")
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    MakeSnowCovered(inst)

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("houndmound", fn, assets, prefabs)
