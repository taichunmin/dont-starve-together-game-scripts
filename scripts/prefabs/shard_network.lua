local function PostInit(inst)
    inst:LongUpdate(0)
    inst.entity:FlushLocalDirtyNetVars()

    for k, v in pairs(inst.components) do
        if v.OnPostInit ~= nil then
            v:OnPostInit()
        end
    end
end

local function OnRemoveEntity(inst)
    if TheWorld ~= nil then
        assert(TheWorld.shard == inst)
        TheWorld.shard = nil
    end
end

local function fn()
    local inst = CreateEntity()

    assert(TheWorld ~= nil and TheWorld.shard == nil and TheWorld.ismastersim)
    TheWorld.shard = inst

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddShardNetwork()
    inst:AddTag("CLASSIFIED")
    inst.entity:SetPristine()

    inst:AddComponent("shard_clock")
    inst:AddComponent("shard_seasons")
    inst:AddComponent("shard_sinkholes")
    inst:AddComponent("shard_players")
    inst:AddComponent("shard_worldreset")
    inst:AddComponent("shard_worldvoter")
    inst:AddComponent("shard_autosaver")
    inst:AddComponent("shard_daywalkerspawner")
    inst:AddComponent("shard_mermkingwatcher")

    inst.OnRemoveEntity = OnRemoveEntity

    inst:DoTaskInTime(0, PostInit)

    return inst
end

return Prefab("shard_network", fn)
