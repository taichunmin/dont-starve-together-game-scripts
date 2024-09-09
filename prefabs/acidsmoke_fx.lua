local assets =
{
    Asset("ANIM", "anim/acidsmoke.zip"),
}

local INTERVAL_MAX = 8
local INTERVAL_MIN = 5

local function PlayAnim(inst)
    inst.AnimState:PlayAnimation(inst._anim)
end

local function OnAnimOver(inst)
    inst:DoTaskInTime(GetRandomMinMax(INTERVAL_MIN, INTERVAL_MAX), inst.PlayAnim)
end

local function SetLevel(inst, level)
    inst._anim = "idle_"..level
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("acidsmoke")
    inst.AnimState:SetBuild("acidsmoke")
    inst.AnimState:SetFinalOffset(3)
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._anim = "idle_1"

    inst.SetLevel   = SetLevel
    inst.OnAnimOver = OnAnimOver
    inst.PlayAnim   = PlayAnim

    inst.persists = false

    inst:ListenForEvent("animover", inst.OnAnimOver)
    inst:OnAnimOver()

    return inst
end

return Prefab("acidsmoke_fx", fn, assets)