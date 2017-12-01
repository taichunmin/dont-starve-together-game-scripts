local assets =
{
    Asset("ANIM", "anim/warg_actions.zip"),
    Asset("ANIM", "anim/warg_build.zip"),
    Asset("SOUND", "sound/vargr.fsb"),
}

local prefabs =
{
    "hound",
    "icehound",
    "firehound",
    "monstermeat",
    "houndstooth",
}

local brain = require("brains/wargbrain")

SetSharedLootTable('warg',
{
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             0.50},
    {'monstermeat',             0.50},
    
    {'houndstooth',             1.00},
    {'houndstooth',             0.66},
    {'houndstooth',             0.33},
})

local function RetargetFn(inst)
    if inst.sg:HasStateTag("hidden") then return end
    return FindEntity(inst, TUNING.WARG_TARGETRANGE, function(guy)
        return inst.components.combat:CanTarget(guy) 
    end,
    nil,
    {"wall","warg","hound"}
    )
end

local function KeepTargetFn(inst, target)
    if inst.sg:HasStateTag("hidden") then return end
    if target then
        return distsq(inst:GetPosition(), target:GetPosition()) < 40*40
        and not target.components.health:IsDead()
        and inst.components.combat:CanTarget(target)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, TUNING.WARG_MAXHELPERS, function(dude)
            return dude:HasTag("warg") or dude:HasTag("hound") 
            and not dude.components.health:IsDead()
        end, TUNING.WARG_TARGETRANGE)
end

local function NumHoundsToSpawn(inst)
    local numHounds = TUNING.WARG_BASE_HOUND_AMOUNT

    local pt = Vector3(inst.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.WARG_NEARBY_PLAYERS_DIST, {"player"}, {"playerghost"})
    for i,player in ipairs(ents) do
        local playerAge = player.components.age:GetAgeInDays()
        local addHounds = math.clamp(Lerp(1, 4, playerAge/100), 1, 4)
        numHounds = numHounds + addHounds
    end
    local numFollowers = inst.components.leader:CountFollowers()
    local num = math.min(numFollowers+numHounds/2, numHounds) -- only spawn half the hounds per howl
    num = (math.log(num)/0.4)+1 -- 0.4 is approx log(1.5)

    num = RoundToNearest(num, 1)

    return num - numFollowers
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2.5, 1.5)

    local s = 1
    inst.Transform:SetScale(s, s, s)
    inst.Transform:SetSixFaced()

    MakeCharacterPhysics(inst, 1000, 1)

    inst:AddTag("monster")
    inst:AddTag("warg")
    inst:AddTag("scarytoprey")
    inst:AddTag("houndfriend")
    inst:AddTag("largecreature")

    inst.AnimState:SetBank("warg")
    inst.AnimState:SetBuild("warg_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("leader")

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.WARG_RUNSPEED
    inst.components.locomotor:SetShouldRun(true)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.WARG_DAMAGE)
    inst.components.combat:SetRange(TUNING.WARG_ATTACKRANGE)
    inst.components.combat:SetAttackPeriod(TUNING.WARG_ATTACKPERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/vargr/hit")
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WARG_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('warg') 

    inst:AddComponent("sleeper")

    MakeLargeFreezableCharacter(inst)
    MakeLargeBurnableCharacter(inst, "swap_fire")

    inst:SetStateGraph("SGwarg")

    MakeHauntableGoToState(inst, "howl", TUNING.HAUNT_CHANCE_OCCASIONAL, TUNING.HAUNT_COOLDOWN_MEDIUM, TUNING.HAUNT_CHANCE_LARGE)

    inst.NumHoundsToSpawn = NumHoundsToSpawn

    inst:SetBrain(brain)

    return inst
end

return Prefab("warg", fn, assets, prefabs)
