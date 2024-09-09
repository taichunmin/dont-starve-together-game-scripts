local assets =
{
    Asset("ANIM", "anim/houndwhistle.zip"),
    Asset("ANIM", "anim/houndwhistle_water.zip"),
}

local function TryAddFollower(leader, follower)
    local ishound = follower:HasTag("hound")
    local iswarg = not ishound and follower:HasTag("warg")
    if (ishound or iswarg) and follower.sg ~= nil and not follower.sg:HasStateTag("statue") then
        if leader.components.leader ~= nil and
            follower.components.follower ~= nil and
            not follower:HasTag("moonbeast") and
            (follower.components.follower.leader == leader or leader.components.leader:CountFollowers("hound") < TUNING.HOUNDWHISTLE_MAX_FOLLOWERS) then
            if follower.components.follower.leader ~= leader then
                leader.components.leader:AddFollower(follower)
            end
            follower.components.follower:AddLoyaltyTime(TUNING.HOUNDWHISTLE_EFFECTIVE_TIME + math.random())
            if follower.components.combat ~= nil and follower.components.combat:TargetIs(leader) then
                follower.components.combat:SetTarget(nil)
            end
        end
        follower:DoTaskInTime((iswarg and .1 or .5) * math.random(), follower.PushEvent, "heardwhistle", { musician = leader })
    end
end

local function HearHoundWhistle(inst, musician, instrument)
    if musician.components.leader ~= nil and
        (inst:HasTag("hound") or inst:HasTag("warg")) and
		not inst:HasTag("lunar_aligned") and
        not (inst.sg ~= nil and inst.sg:HasStateTag("statue")) then
        if inst.components.combat ~= nil and inst.components.combat:HasTarget() then
            inst.components.combat:GiveUp()
        end
        TryAddFollower(musician, inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("whistle")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    inst.AnimState:SetBank("hound_whistle")
    inst.AnimState:SetBuild("houndwhistle")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.025, {1.1, 0.7, 1.1})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("instrument")
    inst.components.instrument.range = TUNING.HOUNDWHISTLE_RANGE
    inst.components.instrument:SetOnHeardFn(HearHoundWhistle)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HOUNDWHISTLE_USES)
    inst.components.finiteuses:SetUses(TUNING.HOUNDWHISTLE_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    inst:ListenForEvent("floater_startfloating", function(inst) inst.AnimState:PlayAnimation("float") end)
    inst:ListenForEvent("floater_stopfloating", function(inst) inst.AnimState:PlayAnimation("idle") end)

    return inst
end

return Prefab("houndwhistle", fn, assets)
