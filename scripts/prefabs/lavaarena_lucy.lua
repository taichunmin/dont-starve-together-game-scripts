local assets =
{
    Asset("ANIM", "anim/swap_lucy_axe.zip"),
    Asset("ANIM", "anim/lavaarena_lucy.zip"),
    Asset("INV_IMAGE", "lucy"),
}

local assets_fx =
{
    Asset("ANIM", "anim/lavaarena_lucy.zip"),
}

local prefabs =
{
    "reticulelong",
    "reticulelongping",
    "weaponsparks",
    "weaponsparks_piercing",
    "weaponsparks_bounce",
    "lucy_transform_fx",
    "splash_ocean",
    "lavaarena_lucy_spin",
    "sunderarmordebuff",
}

--------------------------------------------------------------------------

local function ReticuleTargetFn()
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function ReticuleMouseTargetFn(inst, mousepos)
    if mousepos ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = mousepos.x - x
        local dz = mousepos.z - z
        local l = dx * dx + dz * dz
        if l <= 0 then
            return inst.components.reticule.targetpos
        end
        l = 6.5 / math.sqrt(l)
        return Vector3(x + dx * l, 0, z + dz * l)
    end
end

local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lavaarena_lucy")
    inst.AnimState:SetBuild("lavaarena_lucy")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetSixFaced()

    inst:AddTag("sharp")
    inst:AddTag("throw_line")
    inst:AddTag("chop_attack")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --rechargeable (from rechargeable component) added to pristine state for optimization
    inst:AddTag("rechargeable")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAlwaysValid(true)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticulelong"
    inst.components.aoetargeting.reticule.pingprefab = "reticulelongping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_lucy").master_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

local function CreateSpinFX()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lavaarena_lucy")
    inst.AnimState:SetBuild("lavaarena_lucy")
    inst.AnimState:PlayAnimation("return")
    inst.AnimState:SetMultColour(1, 1, 1, .2)

    inst.Transform:SetSixFaced()

    inst:DoTaskInTime(13 * FRAMES, inst.Remove)

    return inst
end

local function OnUpdateSpin(fx, inst)
    local parent = fx.owner.entity:GetParent()
    if fx.alpha >= .6 and (parent == nil or not (parent.AnimState:IsCurrentAnimation("catch_pre") or parent.AnimState:IsCurrentAnimation("catch"))) then
        fx.dalpha = -.1
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = fx.Transform:GetWorldPosition()
    local dx = x1 - x
    local dz = z1 - z
    local dist = math.sqrt(dx * dx + dz * dz)
    fx.offset = fx.offset * .8 + .2
    fx.vy = fx.vy + fx.ay
    fx.height = fx.height + fx.vy
    fx.Transform:SetPosition(x + dx * fx.offset / dist, fx.height, z + dz * fx.offset / dist)
    if fx.alpha ~= 0 then
        fx.alpha = fx.alpha + fx.dalpha
        if fx.alpha >= 1 then
            fx.dalpha = 0
            fx.alpha = 1
        elseif fx.alpha <= 0 then
            fx:Remove()
        end
        fx.AnimState:SetMultColour(1, 1, 1, fx.alpha)
    end
end

local function OnOriginDirty(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = inst._originx:value() - x
        local dz = inst._originz:value() - z
        local distsq = dx * dx + dz * dz
        local dist = math.sqrt(distsq)
        local fx = CreateSpinFX()
        fx.owner = inst
        fx.offset = math.min(3, dist)
        fx.height = 2
        fx.vy = .2
        fx.ay = -.05
        fx.alpha = .2
        fx.dalpha = .2
        fx.Transform:SetPosition(x + dx * fx.offset / dist, fx.height, z + dz * fx.offset / dist)
        fx:ForceFacePoint(inst._originx:value(), 0, inst._originz:value())
        fx:ListenForEvent("onremove", function() fx:Remove() end, inst)
        fx:DoPeriodicTask(0, OnUpdateSpin, nil, inst)
    end
end

local function SetOrigin(inst, x, y, z)
    if x == 0 then
        --make sure something is dirty for sure
        inst._originx:set_local(0)
    end
    inst._originx:set(x)
    inst._originz:set(z)
    if not TheNet:IsDedicated() then
        OnOriginDirty(inst)
    end
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst._originx = net_float(inst.GUID, "lavaarena_lucy_spin._originx", "origindirty")
    inst._originz = net_float(inst.GUID, "lavaarena_lucy_spin._originz", "origindirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("origindirty", OnOriginDirty)

        return inst
    end

    inst.persists = false
    inst.SetOrigin = SetOrigin
    inst:DoTaskInTime(.5, inst.Remove)

    return inst
end

return Prefab("lavaarena_lucy", fn, assets, prefabs),
    Prefab("lavaarena_lucy_spin", fxfn, assets_fx)
