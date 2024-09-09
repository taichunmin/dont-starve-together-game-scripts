local assets =
{
    Asset("ANIM", "anim/lavaarena_creature_teleport.zip"),
}

local assets_decor =
{
    Asset("ANIM", "anim/lavaarena_wrestling_sparks.zip"),
}

local prefabs =
{
    "lavaarena_creature_teleport_smoke_fx_1",
    "lavaarena_creature_teleport_smoke_fx_2",
    "lavaarena_creature_teleport_smoke_fx_3",
}

--------------------------------------------------------------------------

local instance_count = { 0, 0, 0 }

local function ClearInstance(inst)
    instance_count[inst.instance_page] = instance_count[inst.instance_page] - 1
    inst.OnRemoveEntity = nil
end

local function RegisterInstance(inst, instance_page)
    inst.instance_page = instance_page
    instance_count[instance_page] = instance_count[instance_page] + 1
    inst:DoTaskInTime(.1, ClearInstance)
    inst.OnRemoveEntity = ClearInstance
end

--------------------------------------------------------------------------

local function ScaleVolume(count, maxcount, minvolume)
    if count >= maxcount then
        return minvolume
    end
    count = count / maxcount
    return 1 - count * count * (1 - minvolume)
end

--------------------------------------------------------------------------

local function PlayAnim(proxy, fxanim, instance_page)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("lavaarena_creature_teleport")
    inst.AnimState:SetBuild("lavaarena_creature_teleport")
    inst.AnimState:PlayAnimation(fxanim)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/spawn", nil, ScaleVolume(instance_count[instance_page], 10, .5))

    inst:ListenForEvent("animover", inst.Remove)
end

local function SpawnSmokeFx(inst)
    SpawnPrefab("lavaarena_creature_teleport_smoke_fx_"..tostring(math.random(3))).Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function makespawnfx(instance_page, name, fxanim)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(0, PlayAnim, fxanim, instance_page)

            RegisterInstance(inst, instance_page)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:DoTaskInTime(math.random() * .2, SpawnSmokeFx)

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

--------------------------------------------------------------------------

local function PlayDecor(proxy, anims, instance_page)
    local inst = CreateEntity()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        inst.entity:SetParent(parent.entity)
    end

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("lavaarena_wrestling_sparks")
    inst.AnimState:SetBuild("lavaarena_wrestling_sparks")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    for i, v in ipairs(anims) do
        if i <= 1 then
            inst.AnimState:PlayAnimation(v)
        else
            inst.AnimState:PushAnimation(v, false)
        end
    end

    local count = instance_count[proxy.instance_page]
    inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/spawner_decor", nil, ScaleVolume(instance_count[instance_page], 18, .5))

    inst:ListenForEvent("animqueueover", inst.Remove)
end

local function makespawndecorfx(instance_page, name, anims)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(0, PlayDecor, anims, instance_page)

            RegisterInstance(inst, instance_page)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets_decor)
end

--------------------------------------------------------------------------

return makespawnfx(1, "lavaarena_creature_teleport_small_fx", "spawn_small"),
    makespawnfx(1, "lavaarena_creature_teleport_medium_fx", "spawn_medium"),
    makespawndecorfx(2, "lavaarena_spawnerdecor_fx_small", { "spark_small_pre", "spark_small_loop", "spark_small_loop", "spark_small_pst" }),
    makespawndecorfx(3, "lavaarena_spawnerdecor_fx_1", { "spark_1_pre", "spark_1_pst" }),
    makespawndecorfx(3, "lavaarena_spawnerdecor_fx_2", { "spark_2_pre", "spark_2_pst" }),
    makespawndecorfx(3, "lavaarena_spawnerdecor_fx_3", { "spark_3_pre", "spark_3_pst" })
