local assets =
{
    Asset("ANIM", "anim/lunar_transformation.zip")
}

local FINISH_SPAWN_TIMERNAME = "finishspawn"
local SPAWN_LIFETIME = 15*FRAMES

local function onbuilt(inst, data)
    inst.builder = data.builder

    if inst.builder ~= nil and inst.builder:IsValid() then
        local pos = inst.builder:GetPosition()
        local offset = FindWalkableOffset(pos, math.random()*TWOPI, 3, 12, false, false, nil, false, true)

        if offset ~= nil then
            pos = pos + offset
            inst.Transform:SetPosition(pos:Get())
        end
    end

    inst:ListenForEvent("onremove", function(_) inst.builder = nil end, inst.builder)
end

local function MakeProxy(prefabname, product)
    local proxy_prefabs = { product }

    local function finish_spawn(inst)
        if inst.builder and inst.builder.components.petleash then
            local x, y, z = inst.Transform:GetWorldPosition()
            local pet = inst.builder.components.petleash:SpawnPetAt(x, y, z, product)
            if pet then
                if inst.builder.components.health and inst.builder.components.health:IsDead() then
                    pet:RemoveWormwoodPet()
                end
            end
        end
    end

    local function timerdone(inst, data)
        if data.name == FINISH_SPAWN_TIMERNAME then
            finish_spawn(inst)
        end
    end

    local function proxy_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("lunar_transformation")
        inst.AnimState:SetBuild("lunar_transformation")
        inst.AnimState:PlayAnimation("transform")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(1)

        inst:SetPhysicsRadiusOverride(2.0) -- For spacing when crafting.

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("timerdone", timerdone)
        inst:ListenForEvent("onbuilt", onbuilt)
        inst:ListenForEvent("animover", inst.Remove)

        local timer = inst:AddComponent("timer")
        timer:StartTimer(FINISH_SPAWN_TIMERNAME, SPAWN_LIFETIME)

        inst.SoundEmitter:PlaySound("meta2/wormwood/animation_dropdown")

        return inst
    end

    return Prefab(prefabname, proxy_fn, assets, proxy_prefabs)
end

return MakeProxy("wormwood_mutantproxy_carrat", "wormwood_carrat"),
    MakeProxy("wormwood_mutantproxy_lightflier", "wormwood_lightflier"),
    MakeProxy("wormwood_mutantproxy_fruitdragon", "wormwood_fruitdragon")