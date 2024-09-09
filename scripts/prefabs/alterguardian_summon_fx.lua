local assets =
{
    Asset("ANIM", "anim/alterguardian_summon_fx.zip"),
}

local function on_endloop(inst)
    inst.AnimState:PlayAnimation("summon_pst")

    inst._end_loop:push()

    inst._pst_started = true
    inst:ListenForEvent("animover", inst.Remove)
end

local function set_lightvalues(inst, val)
    inst.Light:SetIntensity(0.6 * val * val)
    inst.Light:SetRadius(8 * val)
    inst.Light:SetFalloff(4 * val)

    inst.AnimState:SetLightOverride(val)
end

local function pre_over(inst)
    inst._pre_finished = true
end

local PRE_LIGHTMODULATION =
{
    [1] = 0.1,
    [2] = 0.133,
    [3] = 0.166,
    [4] = 0.2,
    [5] = 0.25,
    [6] = 0.3,
    [7] = 0.35,
    [8] = 0.4,
    [9] = 0.5,
    [10] = 0.6,
    [11] = 0.7,
    [12] = 0.8,
    [13] = 0.9,
    [14] = 0.91,
    [15] = 0.92,
    [16] = 0.925,
    [17] = 0.9375,
    [18] = 0.95,
    [19] = 0.9625,
    [20] = 0.975,
    [21] = 0.9875,
    [22] = 0.99,
    [23] = 0.95,
    [24] = 0.99,
}

local LOOP_LIGHTMODULATION =
{
    [1] = 0.99,
    [2] = 0.97,
    [3] = 0.95,
    [4] = 0.93,
    [5] = 0.91,
    [6] = 0.89,
    [7] = 0.87,
    [8] = 0.85,
    [9] = 0.87,
    [10] = 0.89,
    [11] = 0.91,
    [12] = 0.93,
    [13] = 0.95,
    [14] = 0.97,
    [15] = 0.98,
    [16] = 0.99,
}

local PST_LIGHTMODULATION =
{
    [1] = 1.0,
    [2] = 0.9375,
    [3] = 0.875,
    [4] = 0.8125,
    [5] = 0.75,
    [6] = 0.6875,
    [7] = 0.625,
    [8] = 0.5625,
    [9] = 0.5,
    [10] = 0.4375,
    [11] = 0.375,
    [12] = 0.3125,
    [13] = 0.25,
    [14] = 0.1875,
    [15] = 0.125,
    [16] = 0.0625,
}

local function periodic_light_update(inst)
    local frame_num = inst.AnimState:GetCurrentAnimationFrame()

    if not inst._pre_finished then
        local val = PRE_LIGHTMODULATION[frame_num]
        if val ~= nil then
            set_lightvalues(inst, val)
        end
    elseif inst._pst_started then
        local val = PST_LIGHTMODULATION[frame_num]
        if val ~= nil then
            set_lightvalues(inst, val)
        end
    else -- in the loop
        frame_num = RoundBiasedUp(frame_num - math.floor(frame_num / 16) * 16)
        local val = LOOP_LIGHTMODULATION[frame_num]
        if val ~= nil then
            set_lightvalues(inst, val)
        end
    end
end

local function CLIENT_MakeBackFX()
    local inst = CreateEntity("alterguardian_summon_backfx")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("FX")

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.AnimState:SetBank("alterguardian_summon_fx")
    inst.AnimState:SetBuild("alterguardian_summon_fx")

    inst.AnimState:PlayAnimation("summon_back_pre")
    inst.AnimState:PushAnimation("summon_back_loop", true)

    inst.AnimState:SetFinalOffset(-1)

    -- We spawn a frame delayed to make sure the transform is updated,
    -- so we have to skip a frame into the animation.
	inst.AnimState:SetFrame(1)

    return inst
end

local function CLIENT_end_backfx(inst)
    if not inst._back_fx then
        return
    end

    inst._back_fx.AnimState:PlayAnimation("summon_back_pst")

    inst._back_fx:ListenForEvent("animover", inst._back_fx.Remove)
end

local function CLIENT_start_back_fx(inst)
    inst._back_fx = CLIENT_MakeBackFX()
    if inst._back_fx then
        inst._back_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end

    inst:ListenForEvent("alterguardian_summon_fx._end_loop", CLIENT_end_backfx)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    set_lightvalues(inst, 0)
    inst.Light:SetColour(0, 0.35, 1)

    inst.AnimState:SetBank("alterguardian_summon_fx")
    inst.AnimState:SetBuild("alterguardian_summon_fx")
    inst.AnimState:PlayAnimation("summon_pre")
    inst.AnimState:PushAnimation("summon_loop", true)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst._end_loop = net_event(inst.GUID, "alterguardian_summon_fx._end_loop")

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, CLIENT_start_back_fx)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._endloop = nil

    inst:ListenForEvent("endloop", on_endloop)

    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), pre_over)
    inst:DoPeriodicTask(FRAMES, periodic_light_update)

    inst.persists = false

    return inst
end

return Prefab("alterguardian_summon_fx", fn, assets)
