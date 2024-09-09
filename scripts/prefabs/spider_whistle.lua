local assets =
{
    Asset("ANIM", "anim/spider_whistle.zip"),
}

local prefabs = 
{
    "spider_whistle_buff",
    "spider_summoned_buff",
}

local function CanHerd(whistle, leader)
    if not leader:HasTag("spiderwhisperer") then
        return false, "WEBBERONLY"
    end

    return true
end

local function OnHerd(whistle, leader)
    local x, y, z = leader.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SPIDER_WHISTLE_RANGE, nil, nil, {"spidercocoon", "spiderden"})

    for _, den in pairs(ents) do
        if den.components.childspawner and den.components.childspawner.childreninside > 0 and den.SummonChildren then
            den:SummonChildren()
        end
    end

    ents = TheSim:FindEntities(x, y, z, TUNING.SPIDER_WHISTLE_RANGE, {"spider"}, {"spiderqueen"})
    for _, spider in pairs(ents) do
        if spider.components.sleeper and spider.components.sleeper:IsAsleep() then
            spider.components.sleeper:WakeUp()
            spider:AddDebuff("spider_summoned_buff", "spider_summoned_buff")
        end
    end

    for follower, v in pairs(leader.components.leader.followers) do
        if follower:HasTag("spider") then
            follower:AddDebuff("spider_whistle_buff", "spider_whistle_buff")
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("spider_whistle")
    inst.AnimState:SetBuild("spider_whistle")
    inst.AnimState:PlayAnimation("idle", true)
    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "small", 0.15, 0.9)

	inst:AddTag("spider_whistle")

    inst.scrapbook_specialinfo = "SPIDERWHISTLE"

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(function() inst:Remove() end)

    inst:AddComponent("followerherder")
    inst.components.followerherder:SetCanHerdFn(CanHerd)
    inst.components.followerherder:SetOnHerdFn(OnHerd)
    inst.components.followerherder:SetUseAmount(TUNING.SPIDER_WHISTLE_USE_AMOUNT)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)

    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("spider_whistle", fn, assets, prefabs)