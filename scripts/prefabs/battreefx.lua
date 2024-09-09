local assets =
{
    Asset("ANIM", "anim/bat_tree_fx.zip"),
}

local OVERLAY_DELAY = 1.25

local function MoveForward(inst)
    inst.AnimState:SetSortOrder(1)
end

local function DoFlutterSound(fx)
    fx.SoundEmitter:PlaySound("dontstarve/creatures/bat/flap")
    if fx.entity:GetParent().AnimState:GetCurrentAnimationTime() < OVERLAY_DELAY - 8 * FRAMES then
        fx:DoTaskInTime(math.random(4, 5) * FRAMES, DoFlutterSound)
    else
        fx:Remove()
    end
end

local function PlaySounds(inst)
    local fx = CreateEntity()
    fx:AddTag("FX")
    --[[Non-networked entity]]
    fx.persists = false
    fx.entity:AddTransform()
    fx.entity:AddSoundEmitter()
    fx.entity:SetParent(inst.entity)
    DoFlutterSound(fx)
    fx.SoundEmitter:PlaySound("dontstarve/creatures/bat/bat_explode")
end

local function QueueBatOverlay(inst, delayed)
    if not delayed then
        inst:DoTaskInTime(0, QueueBatOverlay, true)
    elseif ThePlayer ~= nil then
        ThePlayer:DoTaskInTime(math.max(0, OVERLAY_DELAY - inst.AnimState:GetCurrentAnimationTime()), ThePlayer.PushEvent, "batspooked")
    end
end

local function SetViewerAndAnim(inst, viewer, anim)
    if inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end

    inst.AnimState:PlayAnimation(anim)

    inst.Network:SetClassifiedTarget(viewer)
    if viewer == ThePlayer then
        PlaySounds(inst)
        QueueBatOverlay(inst)
    else
        -- hide it from the locally hosted server player
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bat_tree_fx")
    inst.AnimState:SetBuild("bat_tree_fx")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        PlaySounds(inst)
        QueueBatOverlay(inst)

        return inst
    end

    inst:DoTaskInTime(30 * FRAMES, MoveForward)
    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false

    inst._task = inst:DoTaskInTime(0, inst.Remove)
    inst.SetViewerAndAnim = SetViewerAndAnim

    return inst
end

return Prefab("battreefx", fn, assets)
