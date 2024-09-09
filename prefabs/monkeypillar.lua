local assets =
{
    Asset("ANIM", "anim/pillar_monkey.zip"),
}

--------------------------------------------------------------------------------

local set_moveanim_trigger = nil

local function queue_moveanim_task(inst)
    inst._moveanim_task = inst:DoTaskInTime(15 + 10 * math.random(), set_moveanim_trigger)
end

set_moveanim_trigger = function(inst)
    inst._moveanim_trigger = true
    queue_moveanim_task(inst)
end

local function OnAnimOver(inst)
    local idlename = "idle"..inst.pillar_id

    if inst._moveanim_trigger then
        inst.AnimState:PlayAnimation(idlename.."_move")
        inst._moveanim_trigger = false
    else
        inst.AnimState:PlayAnimation(idlename)
    end
end

--------------------------------------------------------------------------------

local function setpillartype(inst, index)
    if inst.pillar_id == nil or (index ~= nil and inst.pillar_id ~= index) then
        inst.pillar_id = index or tostring(math.random(1, 4))
        inst.AnimState:PlayAnimation("idle"..inst.pillar_id)
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    end
end

local function OnSave(inst, data)
    data.pillar_id = inst.pillar_id
end

local function OnLoad(inst, data)
    setpillartype(inst, (data ~= nil and data.pillar_id) or nil)
end

--------------------------------------------------------------------------------

local function OnEntitySleep(inst)
    if inst._moveanim_task ~= nil then
        inst._moveanim_task:Cancel()
        inst._moveanim_task = nil
    end
end

local function OnEntityWake(inst)
    if inst._moveanim_task == nil then
        queue_moveanim_task(inst)
    end
end

--------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.6, 24)

    MakeSnowCoveredPristine(inst)

    inst.Light:SetIntensity(0.6)
    inst.Light:SetRadius(2.5)
    inst.Light:SetFalloff(0.8)
    inst.Light:SetColour(125/255, 125/255, 125/255)
    inst.Light:Enable(true)

    inst.AnimState:SetBank ("pillar_monkey")
    inst.AnimState:SetBuild("pillar_monkey")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(0.25)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._moveanim_trigger = false

    inst:ListenForEvent("animover", OnAnimOver)

    ---------------------------------------------------------------
    inst:AddComponent("inspectable")

    -----------------------------------------------------------
    MakeSnowCovered(inst)

    ---------------------------------------------------------------
    --inst.pillar_id = nil
    if not POPULATING then
        setpillartype(inst)
    end
    queue_moveanim_task(inst)

    ---------------------------------------------------------------
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

return Prefab("monkeypillar", fn, assets)