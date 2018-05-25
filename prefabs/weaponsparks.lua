local assets =
{
    Asset("ANIM", "anim/lavaarena_hit_sparks_fx.zip"),
}

--------------------------------------------------------------------------

local function PlaySparksAnim(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("hits_sparks")
    inst.AnimState:SetBuild("lavaarena_hit_sparks_fx")
    inst.AnimState:PlayAnimation("hit_3")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetScale(proxy.flip:value() and -.7 or .7, .7)

    inst:ListenForEvent("animover", inst.Remove)
end

--------------------------------------------------------------------------

local function Piercing_PlaySparksAnimBack(front, rot, x, y, z, flip)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetRotation(rot)
    inst.Transform:SetPosition(x, y, z)

    inst.AnimState:SetBank("hits_sparks")
    inst.AnimState:SetBuild("lavaarena_hit_sparks_fx")
    inst.AnimState:PlayAnimation("hit_2")
    inst.AnimState:Hide("glow")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    if flip then
        inst.AnimState:SetScale(-1, 1)
    end

    inst:ListenForEvent("animover", inst.Remove)
end

local function Piercing_PlaySparksAnim(proxy, yoffset)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)
    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = parent.Transform:GetWorldPosition()
        y = y1 + y + (yoffset or 0)
        inst.Transform:SetPosition(x1 + x, y, z1 + z)

        inst:DoTaskInTime(3 * FRAMES, Piercing_PlaySparksAnimBack, inst.Transform:GetRotation() + 180, x1 - x, y, z1 - z, proxy.flip:value() == 2 or proxy.flip:value() == 4)
    end

    inst.AnimState:SetBank("hits_sparks")
    inst.AnimState:SetBuild("lavaarena_hit_sparks_fx")
    inst.AnimState:PlayAnimation("hit_3")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetFinalOffset(1)
    if proxy.flip:value() > 2 then
        inst.AnimState:SetScale(-1, 1)
    end

    inst:ListenForEvent("animover", inst.Remove)
end

--------------------------------------------------------------------------

local function Thrusting_PlaySparksAnim(proxy)
    Piercing_PlaySparksAnim(proxy, 1)
end

--------------------------------------------------------------------------

local function Bounce_PlaySparksAnim(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("hits_sparks")
    inst.AnimState:SetBuild("lavaarena_hit_sparks_fx")
    inst.AnimState:PlayAnimation("hit_2")
    inst.AnimState:Hide("glow")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
    if proxy.flip:value() then
        inst.AnimState:SetScale(-1, 1)
    end

    inst:ListenForEvent("animover", inst.Remove)
end

--------------------------------------------------------------------------

local function MakeSparks(name, fxfn, variation, doubleflip)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(0, fxfn)
        end

        inst.flip = (doubleflip and net_tinybyte or net_bool)(inst.GUID, "weaponsparks.flip")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("lavaarena", "prefabs/weaponsparks").master_postinit(inst, variation, doubleflip)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeSparks("weaponsparks", PlaySparksAnim, "normal"),
    MakeSparks("weaponsparks_piercing", Piercing_PlaySparksAnim, "piercing", true),
    MakeSparks("weaponsparks_thrusting", Thrusting_PlaySparksAnim, "piercing", true),
    MakeSparks("weaponsparks_bounce", Bounce_PlaySparksAnim)
