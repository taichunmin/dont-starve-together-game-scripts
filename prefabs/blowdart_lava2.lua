local assets =
{
    Asset("ANIM", "anim/blowdart_lava2.zip"),
    Asset("ANIM", "anim/swap_blowdart_lava2.zip"),
}

local assets_projectile =
{
    Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
}

local prefabs =
{
    "blowdart_lava2_projectile",
    "blowdart_lava2_projectile_explosive",
    "reticulelong",
    "reticulelongping",
}

local prefabs_projectile =
{
    "weaponsparks_piercing",
}

local prefabs_projectile_explosive =
{
    "explosivehit",
}

local PROJECTILE_DELAY = 4 * FRAMES

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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blowdart_lava2")
    inst.AnimState:SetBuild("blowdart_lava2")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("blowdart")
    inst:AddTag("sharp")

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

    inst.projectiledelay = PROJECTILE_DELAY

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/blowdart_lava2").blowdart_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

local FADE_FRAMES = 5

local tails =
{
    ["tail_5_2"] = .15,
    ["tail_5_3"] = .15,
    ["tail_5_4"] = .2,
    ["tail_5_5"] = .8,
    ["tail_5_6"] = 1,
    ["tail_5_7"] = 1,
}

local thintails =
{
    ["tail_5_8"] = 1,
    ["tail_5_9"] = .5,
}

local function CreateTail(thintail, tail_suffix)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation(weighted_random_choice(thintail and thintails or tails)..tail_suffix)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    if not thintail then
        inst.AnimState:SetAddColour(1, 1, 0, 0)
    end

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function OnUpdateProjectileTail(inst, tail_suffix)
    local c = (not inst.entity:IsVisible() and 0) or (inst._fade ~= nil and (FADE_FRAMES - inst._fade:value() + 1) / FADE_FRAMES) or 1
    if c > 0 then
        local tail = CreateTail(inst.thintailcount > 0, tail_suffix)
        tail.Transform:SetPosition(inst.Transform:GetWorldPosition())
        tail.Transform:SetRotation(inst.Transform:GetRotation())
        if c < 1 then
            tail.AnimState:SetTime(c * tail.AnimState:GetCurrentAnimationLength())
        end
        if inst.thintailcount > 0 then
            inst.thintailcount = inst.thintailcount - 1
        end
    end
end

local function commonprojectilefn(anim, tail_suffix, alt)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation(anim, true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetAddColour(1, 1, 0, 0)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    if not TheNet:IsDedicated() then
        inst.thintailcount = alt and math.random(3, 5) or math.random(2, 4)
        inst:DoPeriodicTask(0, OnUpdateProjectileTail, nil, tail_suffix)
    end

    if alt then
        inst._fade = net_tinybyte(inst.GUID, "blowdart_lava2_projectile_explosive._fade")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/blowdart_lava2").projectile_postinit(inst, alt)

    return inst
end

local function projectilefn()
    return commonprojectilefn("attack_4", "", false)
end

local function projectileexplosivefn()
    return commonprojectilefn("attack_4_large", "_large", true)
end

return Prefab("blowdart_lava2", fn, assets, prefabs),
    Prefab("blowdart_lava2_projectile", projectilefn, assets_projectile, prefabs_projectile),
    Prefab("blowdart_lava2_projectile_explosive", projectileexplosivefn, assets_projectile, prefabs_projectile_explosive)
