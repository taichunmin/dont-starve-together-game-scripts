local assets =
{
    Asset("ANIM", "anim/lavaarena_boaraudience1.zip"),
    Asset("ANIM", "anim/lavaarena_boaraudience1_build_1.zip"),
    Asset("ANIM", "anim/lavaarena_boaraudience1_build_2.zip"),
    Asset("ANIM", "anim/lavaarena_boaraudience1_build_3.zip"),
    Asset("ANIM", "anim/lavaarena_decor.zip"),
    Asset("ANIM", "anim/lavaarena_banner.zip"),
}

local prefabs =
{
    "lavaarena_center",
    "lavaarena_teambanner",
    "lavaarena_spectator",
}

local function CreateClientBanner()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetEightFaced()

    --[[Non-networked entity]]
    inst.persists = false

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.AnimState:SetBank("lavaarena_banner")
    inst.AnimState:SetBuild("lavaarena_banner")
    inst.AnimState:PlayAnimation("idle")

    return inst
end

local function CreateFenceDecor()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetEightFaced()

    --[[Non-networked entity]]
    inst.persists = false

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.AnimState:SetBank("lavaarena_decor")
    inst.AnimState:SetBuild("lavaarena_decor")
    inst.AnimState:PlayAnimation("idle")

    for i, v in ipairs({ "banner1", "banner2", "teeth1", "teeth3", "teeth2", "teeth4" }) do
        inst.AnimState:Hide(v)
    end

    return inst
end

local function CreateGroundTargetBlocker(parent)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:AddTransform()

    inst.entity:SetParent(parent.entity)
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst:SetGroundTargetBlockerRadius(8)

    return inst
end

local function add_decor(parent, createfn, x_offset, z_offset, rot, x_scale, y_scale, z_scale)
    local inst = createfn()
    inst.entity:SetParent(parent.entity)
    inst.Transform:SetPosition(x_offset, 0, z_offset)
    inst.Transform:SetRotation(rot)
    if x_scale ~= nil then
        inst.Transform:SetScale(x_scale, y_scale or x_scale, z_scale or x_scale)
    end
    return inst
end

local function populate_stand_client(inst)
    local rot
    if TheWorld.ismastersim then
        rot = inst:GetAngleToPoint(TheWorld.components.lavaarenaevent:GetArenaCenterPoint())
        rot = math.floor((rot + 44) / 90) * 90
    else
        rot = inst.Transform:GetRotation()
    end
    local x_size = inst.stand_height:value() * 4 + 1
    local z_size = inst.stand_width:value() * 4 + 1
    local x_count = math.floor(.5 * x_size)
    local z_count = math.floor(.5 * z_size)

    add_decor(inst, CreateClientBanner,  x_count, -z_count, rot + 90)
    add_decor(inst, CreateClientBanner,  x_count,  z_count, rot + 90)

    add_decor(inst, CreateClientBanner, -x_count, -z_count, rot + 90, 1.1)
    add_decor(inst, CreateClientBanner, -x_count,  z_count, rot + 90, 1.1)

    for z = 1 - z_count, z_count - 1 do
        local fence = add_decor(inst, CreateFenceDecor, x_count, z, rot + 90)
        if z_count == 4 then
            if z == -3 then fence.AnimState:Show("teeth1") fence.AnimState:Show("teeth4")
            elseif z == -2 then fence.AnimState:Show("banner1")
            elseif z == -1 then fence.AnimState:Show("teeth2") fence.AnimState:Show("teeth3")
            elseif z == 0 then fence.AnimState:Show("banner1") --fence.AnimState:Show("teeth1") fence.AnimState:Show("teeth2")
            elseif z == 1 then fence.AnimState:Show("teeth1") fence.AnimState:Show("teeth4")
            elseif z == 2 then fence.AnimState:Show("banner1")
            elseif z == 3 then fence.AnimState:Show("teeth2") fence.AnimState:Show("teeth3")
            end
        elseif z_count == 6 then
            if z == -5 then fence.AnimState:Show("teeth1") fence.AnimState:Show("teeth4")
            elseif z == -4 then fence.AnimState:Show("banner1")
            elseif z == -3 then fence.AnimState:Show("teeth2") fence.AnimState:Show("teeth3")
            elseif z == -2 then fence.AnimState:Show("banner1")
            elseif z == -1 then fence.AnimState:Show("teeth1") fence.AnimState:Show("teeth4")
            elseif z == 0 then fence.AnimState:Show("banner1")
            elseif z == 1 then fence.AnimState:Show("teeth2") fence.AnimState:Show("teeth3")
            elseif z == 2 then fence.AnimState:Show("banner1")
            elseif z == 3 then fence.AnimState:Show("teeth1") fence.AnimState:Show("teeth4")
            elseif z == 4 then fence.AnimState:Show("banner1")
            elseif z == 5 then fence.AnimState:Show("teeth2") fence.AnimState:Show("teeth3")
            end
        end
        if z ~= 0 then
            local fence = add_decor(inst, CreateFenceDecor, -x_count, z, rot + 90, 1.2, 1.5, 1.2)
            fence.AnimState:Show("teeth2")
            fence.AnimState:Show("teeth1")
        end
    end

    for x = 1 - x_count, x_count - 1 do
        local fence = add_decor(inst, CreateFenceDecor, x, -z_count, rot + 180)
        fence.AnimState:Show("teeth3") fence.AnimState:Show("teeth4")

        fence = add_decor(inst, CreateFenceDecor, x,  z_count, rot + 180)
        fence.AnimState:Show("teeth3") fence.AnimState:Show("teeth4")
    end
end

local function stand_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("CLASSIFIED")

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, populate_stand_client)
    end

    inst.stand_width = net_tinybyte(inst.GUID, "lavaarena_crowdstand.stand_width")
    inst.stand_height = net_tinybyte(inst.GUID, "lavaarena_crowdstand.stand_height")
    inst.stand_width:set(1)
    inst.stand_height:set(1)

    CreateGroundTargetBlocker(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_crowdstand").stand_postinit(inst)

    return inst
end

local function teambanner_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.Transform:SetScale(1.5, 1.5, 1.5)
    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("lavaarena_banner")
    inst.AnimState:SetBuild("lavaarena_banner")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    --[[if not TheWorld.ismastersim then
        return inst
    end]]

    return inst
end

local function spectator_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBuild("lavaarena_boaraudience1")
    inst.AnimState:SetBank("lavaarena_boaraudience1")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_crowdstand").spectator_postinit(inst)

    return inst
end

local function groundtargetblocker_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetCanSleep(false)

    inst:AddTag("FX")
    inst:SetGroundTargetBlockerRadius(8)

    inst.entity:SetPristine()

    --[[if not TheWorld.ismastersim then
        return inst
    end]]

    return inst
end

return Prefab("lavaarena_crowdstand", stand_fn, assets, prefabs),
    Prefab("lavaarena_teambanner", teambanner_fn, assets),
    Prefab("lavaarena_spectator", spectator_fn, assets),
    Prefab("lavaarena_groundtargetblocker", groundtargetblocker_fn, assets)
