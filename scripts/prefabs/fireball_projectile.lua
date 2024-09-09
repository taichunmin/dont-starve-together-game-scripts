local assets_fireballhit =
{
    Asset("ANIM", "anim/fireball_2_fx.zip"),
    Asset("ANIM", "anim/deer_fire_charge.zip"),
}

local assets_blossomhit =
{
    Asset("ANIM", "anim/lavaarena_heal_projectile.zip"),
}

local assets_gooballhit =
{
    Asset("ANIM", "anim/gooball_fx.zip"),
}

--------------------------------------------------------------------------

local function CreateTail(bank, build, lightoverride, addcolour, multcolour)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("disappear")
    if addcolour ~= nil then
        inst.AnimState:SetAddColour(unpack(addcolour))
    end
    if multcolour ~= nil then
        inst.AnimState:SetMultColour(unpack(multcolour))
    end
    if lightoverride > 0 then
        inst.AnimState:SetLightOverride(lightoverride)
    end
    inst.AnimState:SetFinalOffset(3)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function OnUpdateProjectileTail(inst, bank, build, speed, lightoverride, addcolour, multcolour, hitfx, tails)
    local x, y, z = inst.Transform:GetWorldPosition()
    for tail, _ in pairs(tails) do
        tail:ForceFacePoint(x, y, z)
    end
    if inst.entity:IsVisible() then
        local tail = CreateTail(bank, build, lightoverride, addcolour, multcolour)
        local rot = inst.Transform:GetRotation()
        tail.Transform:SetRotation(rot)
        rot = rot * DEGREES
        local offsangle = math.random() * TWOPI
        local offsradius = math.random() * .2 + .2
        local hoffset = math.cos(offsangle) * offsradius
        local voffset = math.sin(offsangle) * offsradius
        tail.Transform:SetPosition(x + math.sin(rot) * hoffset, y + voffset, z + math.cos(rot) * hoffset)
        tail.Physics:SetMotorVel(speed * (.2 + math.random() * .3), 0, 0)
        tails[tail] = true
        inst:ListenForEvent("onremove", function(tail) tails[tail] = nil end, tail)
        tail:ListenForEvent("onremove", function(inst)
            tail.Transform:SetRotation(tail.Transform:GetRotation() + math.random() * 30 - 15)
        end, inst)
    end
end

local function MakeProjectile(name, bank, build, speed, lightoverride, addcolour, multcolour, hitfx)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
    }

    local prefabs = hitfx ~= nil and { hitfx } or nil

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle_loop", true)
        if addcolour ~= nil then
            inst.AnimState:SetAddColour(unpack(addcolour))
        end
        if multcolour ~= nil then
            inst.AnimState:SetMultColour(unpack(multcolour))
        end
        if lightoverride > 0 then
            inst.AnimState:SetLightOverride(lightoverride)
        end
        inst.AnimState:SetFinalOffset(3)

        --projectile (from projectile component) added to pristine state for optimization
        inst:AddTag("projectile")

        if not TheNet:IsDedicated() then
            inst:DoPeriodicTask(0, OnUpdateProjectileTail, nil, bank, build, speed, lightoverride, addcolour, multcolour, hitfx, {})
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("lavaarena", "prefabs/fireball_projectile").projectile_postinit(inst, speed, hitfx)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

--------------------------------------------------------------------------

local function fireballhit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fireball_fx")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/fireball_projectile").fireballhit_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

local function blossomhit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_heal_projectile")
    inst.AnimState:SetBuild("lavaarena_heal_projectile")
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:SetAddColour(0, .1, .05, 0)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/fireball_projectile").blossomhit_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

local function gooballhit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gooball_fx")
    inst.AnimState:SetBuild("gooball_fx")
    inst.AnimState:PlayAnimation("blast")
    inst.AnimState:SetMultColour(.2, 1, 0, 1)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/fireball_projectile").gooballhit_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

return MakeProjectile("fireball_projectile", "fireball_fx", "fireball_2_fx", 15, 1, nil, nil, "fireball_hit_fx"),
    MakeProjectile("blossom_projectile", "lavaarena_heal_projectile", "lavaarena_heal_projectile", 15, 0, { 0, .2, .1, 0 }, nil, "blossom_hit_fx"),
    MakeProjectile("gooball_projectile", "gooball_fx", "gooball_fx", 20, 0, nil, { .2, 1, 0, 1 }, "gooball_hit_fx"),
    Prefab("fireball_hit_fx", fireballhit_fn, assets_fireballhit),
    Prefab("blossom_hit_fx", blossomhit_fn, assets_blossomhit),
    Prefab("gooball_hit_fx", gooballhit_fn, assets_gooballhit)
