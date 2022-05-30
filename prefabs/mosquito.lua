local assets =
{
    Asset("ANIM", "anim/mosquito.zip"),
}

local prefabs =
{
    "mosquitosack"
}

local brain = require("brains/mosquitobrain")

local sounds =
{
    takeoff = "dontstarve/creatures/mosquito/mosquito_takeoff",
    attack = "dontstarve/creatures/mosquito/mosquito_attack",
    buzz = "dontstarve/creatures/mosquito/mosquito_fly_LP",
    hit = "dontstarve/creatures/mosquito/mosquito_hurt",
    death = "dontstarve/creatures/mosquito/mosquito_death",
    explode = "dontstarve/creatures/mosquito/mosquito_explo",
}

SetSharedLootTable('mosquito',
{
    {'mosquitosack', .5},
})

local SHARE_TARGET_DIST = 30
local MAX_TARGET_SHARES = 10

local function OnWorked(inst, worker)
    local owner = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if owner ~= nil and owner.components.childspawner ~= nil then
        owner.components.childspawner:OnChildKilled(inst)
    end
    if worker.components.inventory ~= nil then
        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
    end
end

local function StartBuzz(inst)
    if not inst.components.inventoryitem:IsHeld() then
        inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
    end
end

local function StopBuzz(inst)
    inst.SoundEmitter:KillSound("buzz")
end

local function OnDropped(inst)
    inst.sg:GoToState("idle")
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.brain ~= nil then
        inst.brain:Start()
    end
    if inst.sg ~= nil then
        inst.sg:Start()
    end
    if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
        local x, y, z = inst.Transform:GetWorldPosition()
        while inst.components.stackable:IsStack()do
            local item = inst.components.stackable:Get()
            if item ~= nil then
                if item.components.inventoryitem ~= nil then
                    item.components.inventoryitem:OnDropped()
                end
                item.Physics:Teleport(x, y, z)
            end
        end
    end
end

local function OnPickedUp(inst)
    inst.SoundEmitter:KillSound("buzz")
end

local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "insect", "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "animal", "monster" }
local function KillerRetarget(inst)
    return FindEntity(inst, SpringCombatMod(20),
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        RETARGET_MUST_TAGS,
        RETARGET_CANT_TAGS,
        RETARGET_ONEOF_TAGS)
end

local function SwapBelly(inst, size)
    for i = 1, 4 do
        if i == size then
            inst.AnimState:Show("body_"..tostring(i))
        else
            inst.AnimState:Hide("body_"..tostring(i))
        end
    end
end

local function TakeDrink(inst, data)
    inst.drinks = inst.drinks + 1
    if inst.drinks > inst.maxdrinks then
        inst.toofat = true
        inst.components.health:Kill()
    else
        SwapBelly(inst, inst.drinks)
    end
end

local function ShareTargetFn(dude)
    return dude:HasTag("mosquito") and not dude.components.health:IsDead()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SpringCombatMod(SHARE_TARGET_DIST), ShareTargetFn, MAX_TARGET_SHARES)
end

local function mosquito()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeFlyingCharacterPhysics(inst, 1, .5)

    inst.DynamicShadow:SetSize(.8, .5)
    inst.Transform:SetFourFaced()

    inst:AddTag("mosquito")
    inst:AddTag("insect")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("smallcreature")
    inst:AddTag("cattoyairborne")

    inst.AnimState:SetBank("mosquito")
    inst.AnimState:SetBuild("mosquito")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    MakeInventoryFloatable(inst)

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetBrain(brain)

    ----------

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.MOSQUITO_WALKSPEED
    inst.components.locomotor.runspeed = TUNING.MOSQUITO_RUNSPEED
    inst.components.locomotor.pathcaps = { allowocean = true }
    inst:SetStateGraph("SGmosquito")

    inst.sounds = sounds

    inst.OnEntityWake = StartBuzz
    inst.OnEntitySleep = StopBuzz

    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem.pushlandedevents = false

    ---------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('mosquito')

    inst:AddComponent("tradable")

     ------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)

    MakeSmallBurnableCharacter(inst, "body", Vector3(0, -1, 1))
    MakeTinyFreezableCharacter(inst, "body", Vector3(0, -1, 1))

    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MOSQUITO_HEALTH)

    ------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetDefaultDamage(TUNING.MOSQUITO_DAMAGE)
    inst.components.combat:SetRange(TUNING.MOSQUITO_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(TUNING.MOSQUITO_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(2, KillerRetarget)
    inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.RARELY)

    inst.drinks = 1
    inst.maxdrinks = TUNING.MOSQUITO_MAX_DRINKS
    inst:ListenForEvent("onattackother", TakeDrink)
    SwapBelly(inst, 1)

    MakeHauntablePanic(inst)
    AddHauntableCustomReaction(inst, function(inst, haunter)
        if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
            inst.sg:GoToState("splat")
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
            return true
        end
        return false
    end, true, false, true)

    ------------------
    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true

    ------------------
    inst:AddComponent("knownlocations")

    ------------------
    inst:AddComponent("inspectable")

    inst:ListenForEvent("attacked", OnAttacked)

    MakeFeedableSmallLivestock(inst, TUNING.TOTAL_DAY_TIME * 2, OnPickedUp, OnDropped)

    return inst
end

return Prefab("mosquito", mosquito, assets, prefabs)
