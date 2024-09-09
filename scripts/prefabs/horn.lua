local assets =
{
    Asset("ANIM", "anim/horn.zip"),
}

local function FollowLeader(follower, leader)
    follower.sg:PushEvent("heardhorn", { musician = leader })
end

local function TryAddFollower(leader, follower)
    if leader.components.leader ~= nil and
        follower.components.follower ~= nil and
        follower:HasTag("beefalo") and
        not follower:HasTag("baby") and
        leader.components.leader:CountFollowers("beefalo") < TUNING.HORN_MAX_FOLLOWERS
    then
        leader.components.leader:AddFollower(follower)
        follower.components.follower:AddLoyaltyTime(TUNING.HORN_EFFECTIVE_TIME + math.random())
        if follower.components.combat ~= nil and follower.components.combat:TargetIs(leader) then
            follower.components.combat:SetTarget(nil)
        end
        follower:DoTaskInTime(math.random(), FollowLeader, leader)
    end
end

local function HearHorn(inst, musician, instrument)
    if musician.components.leader ~= nil and
        inst.components.herdmember ~= nil and
        inst:HasTag("beefalo") and
        not inst:HasTag("baby")
    then
        if inst.components.combat ~= nil and inst.components.combat:HasTarget() then
            inst.components.combat:GiveUp()
        end

        TryAddFollower(musician, inst)

        local herd = inst.components.herdmember:GetHerd()
        if herd ~= nil and herd.components.herd ~= nil then
            for k, v in pairs(herd.components.herd.members) do
                TryAddFollower(musician, k)
            end
        end
    end

    if inst.components.farmplanttendable ~= nil then
        inst.components.farmplanttendable:TendTo(musician)
    end
end

local function OnPlayHorn(inst, musician)
    if musician ~= nil and
        musician:HasTag("battlesinger") and
        musician.components.skilltreeupdater ~= nil and
        not musician.components.skilltreeupdater:IsActivated("wathgrithr_songs_revivewarrior")
    then
        SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, musician.userid, "wathgrithr_horn_played")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("horn")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    inst.AnimState:SetBank("horn")
    inst.AnimState:SetBuild("horn")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("instrument")
    inst.components.instrument.range = TUNING.HORN_RANGE
    inst.components.instrument:SetOnHeardFn(HearHorn)
    inst.components.instrument:SetOnPlayedFn(OnPlayHorn)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HORN_USES)
    inst.components.finiteuses:SetUses(TUNING.HORN_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("horn", fn, assets)
