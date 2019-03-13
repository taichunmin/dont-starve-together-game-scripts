local assets =
{
    Asset("ANIM", "anim/quagmire_slaughtertool.zip"),
}

local function GetSlaughterActionString(inst, target)
    local t = GetTime()
    if target ~= inst._lasttarget or inst._lastactionstr == nil or inst._actionresettime < t then
        inst._lastactionstr = GetRandomItem(STRINGS.ACTIONS.SLAUGHTER)
        inst._lasttarget = target
    end
    inst._actionresettime = t + .1
    return inst._lastactionstr
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_slaughtertool")
    inst.AnimState:SetBuild("quagmire_slaughtertool")
    inst.AnimState:PlayAnimation("idle")

    inst.GetSlaughterActionString = GetSlaughterActionString

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_slaughtertool").master_postinit(inst)

    return inst
end

return Prefab("quagmire_slaughtertool", fn, assets)
