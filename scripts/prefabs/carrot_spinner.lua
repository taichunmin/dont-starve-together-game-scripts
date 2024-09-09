local assets =
{
    Asset("ANIM", "anim/carrot_spinner.zip"),
}

local function timerdone(inst, data)
    if data.name == "begin_delay" then
        inst.fadein = true
    end

    if data.name == "end_delay" then
        inst.fadeout = true
    end
end

local FADEIN_ALPHA = 2/30
local FADEOUT_ALPHA = 1/30
local function looperupdate(inst)
    if inst.fadein then
        inst.alpha = inst.alpha + FADEIN_ALPHA
        if inst.alpha > 0.6 then
            inst.alpha = 0.6
            inst.fadein = nil
        end
        inst.AnimState:SetMultColour(1,1,1,inst.alpha)
    elseif inst.fadeout then
        inst.alpha = inst.alpha - FADEOUT_ALPHA
        inst.AnimState:SetMultColour(1,1,1,inst.alpha)
        if inst.alpha < 0 then
            inst:Remove()
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.AnimState:SetBank("carrot_spinner")
    inst.AnimState:SetBuild("carrot_spinner")
    inst.AnimState:PlayAnimation("idle_smear")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.alpha = 0
    inst.AnimState:SetMultColour(1,1,1,0)

    ------------------------------------------------------------
    local timer = inst:AddComponent("timer")
    timer:StartTimer("begin_delay", 0.5)
    timer:StartTimer("end_delay", 3)

    ------------------------------------------------------------
    local updatelooper = inst:AddComponent("updatelooper")
    updatelooper:AddOnUpdateFn(looperupdate)

    ------------------------------------------------------------
    inst:ListenForEvent("timerdone", timerdone)

    return inst
end

return Prefab("carrot_spinner", fn, assets)
