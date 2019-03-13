local assets =
{
    Asset("ANIM", "anim/explode.zip")
}

local function MakeExplosion(data)
    local function PlayExplodeAnim(proxy)
        local inst = CreateEntity()

        inst:AddTag("FX")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        inst.Transform:SetFromProxy(proxy.GUID)

        if data ~= nil and data.scale ~= nil then
            inst.Transform:SetScale(data.scale, data.scale, data.scale)
        end

        inst.AnimState:SetBank("explode")
        inst.AnimState:SetBuild("explode")
        inst.AnimState:PlayAnimation(data ~= nil and data.anim or "small")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetLightOverride(1)

        if data ~= nil and type(data.sound) == "function" then
            data.sound(inst)
        else
            inst.SoundEmitter:PlaySound(data ~= nil and data.sound or "dontstarve/common/blackpowder_explo")
        end

        inst:ListenForEvent("animover", inst.Remove)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(0, PlayExplodeAnim)
        end

        inst.Transform:SetFourFaced()

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return fn
end

local extras =
{
    slurtle =
    {
        sound = "dontstarve/creatures/slurtle/explode",
    },
    slurtlehole =
    {
        sound = "dontstarve/creatures/slurtle/mound_explode",
    },
    firecrackers =
    {
        anim = "small_firecrackers",
        sound = function(inst)
            inst.SoundEmitter:PlaySoundWithParams("dontstarve/common/together/fire_cracker", { start = math.random() })
        end,
        scale = .5,
    },
}

return Prefab("explode_small", MakeExplosion(), assets),
    Prefab("explode_small_slurtle", MakeExplosion(extras.slurtle), assets),
    Prefab("explode_small_slurtlehole", MakeExplosion(extras.slurtlehole), assets),
    Prefab("explode_firecrackers", MakeExplosion(extras.firecrackers), assets)
	
