local assets =
{
    Asset("ANIM", "anim/moonrock_idol.zip"),
    Asset("INV_IMAGE", "moonrockidolon"),
}

local function turnon(inst, instant)
    if instant then
        inst.AnimState:PlayAnimation("idol_loop", true)
		inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
    else
        inst.AnimState:PlayAnimation("idol_pre")
        inst.AnimState:PushAnimation("idol_loop")
    end
    inst.AnimState:SetLightOverride(.2)
end

local function turnoff(inst)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(0)
end

local function topocket(inst)
    if inst._task ~= nil then
        turnoff(inst)
    end
end

local function toground(inst)
    if inst._task ~= nil then
        turnon(inst)
    end
end

local function onproximitytimeout(inst)
    inst._task = nil
    inst.components.inventoryitem:ChangeImageName()
    if not inst.components.inventoryitem:IsHeld() then
        turnoff(inst)
    end
end

local function onmoonportalproximity(inst, data)
    if inst._task ~= nil then
        inst._task:Cancel()
    else
        inst.components.inventoryitem:ChangeImageName("moonrockidolon")
        if not inst.components.inventoryitem:IsHeld() then
            turnon(inst, data ~= nil and data.instant)
        end
    end
    inst._task = inst:DoTaskInTime(1.05, onproximitytimeout)
end

local MOONPORTAL_TAGS = { "moonportal" }
local function onbuilt(inst, builder)
    local x, y, z = inst.Transform:GetWorldPosition()
    if #TheSim:FindEntities(x, y, z, 8, MOONPORTAL_TAGS) > 0 then
        onmoonportalproximity(inst, { instant = true })
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("moonrock_idol")
    inst.AnimState:SetBuild("moonrock_idol")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("moonportalkey")
    inst:AddTag("donotautopick")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("moonrelic")

    MakeHauntableLaunch(inst)

    inst._task = nil
    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)
    inst:ListenForEvent("ms_moonportalproximity", onmoonportalproximity)

    inst.OnBuiltFn = onbuilt

    return inst
end

return Prefab("moonrockidol", fn, assets)
