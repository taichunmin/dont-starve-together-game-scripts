local assets =
{
    Asset("ANIM", "anim/lightning.zip"),
}

local function PlayLightningAnim(pos)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()

    inst.Transform:SetPosition(pos:Get())
    inst.Transform:SetScale(2, 2, 2)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBank("lightning")
    inst.AnimState:SetBuild("lightning")
    inst.AnimState:PlayAnimation("anim")

    inst:ListenForEvent("animover", inst.Remove)
end

local function PlayThunderSound(pos)
    local inst = CreateEntity()

    --[[Non-networked entity]]

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetPosition(pos:Get())
    inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close")

    inst:Remove()
end

local function StartFX(proxy)
    TheWorld:PushEvent("screenflash", .5)

    local pos = Vector3(proxy.Transform:GetWorldPosition())
    PlayLightningAnim(pos)

    --Dedicated server does not need to spawn the local fx
    --(except lightning anim since it affects lighting)
    if TheNet:IsDedicated() then
        return
    end

    local pos0 = Vector3(TheFocalPoint.Transform:GetWorldPosition())
   	local diff = pos - pos0
    local distsq = diff:LengthSq()
    local minsounddist = 10
    local normpos = pos
   	if distsq > minsounddist * minsounddist then
       	--Sound needs to be played closer to us if lightning is too far from player
        local normdiff = diff * (minsounddist / math.sqrt(distsq))
   	    normpos = pos0 + normdiff
    end

    if ThePlayer ~= nil then
        ThePlayer:ShakeCamera(CAMERASHAKE.FULL, .7, .02, .5, proxy, 40)
    end
    PlayThunderSound(normpos)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    --Delay one frame so that we are positioned properly before starting the effect
    --or in case we are about to be removed
    inst:DoTaskInTime(0, StartFX)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("lightning", fn, assets)