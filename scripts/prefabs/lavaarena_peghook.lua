local assets =
{
    Asset("ANIM", "anim/lavaarena_peghook_basic.zip"),
    Asset("ANIM", "anim/fossilized.zip"),
}

local assets_projectile =
{
    Asset("ANIM", "anim/gooball_fx.zip"),
}

local assets_splashfx =
{
    Asset("ANIM", "anim/lavaarena_hits_splash.zip"),
}

local prefabs =
{
    "fossilizing_fx",
    "fossilized_break_fx",
    "lavaarena_creature_teleport_medium_fx",
    "peghook_projectile",
    "peghook_spitfx",
}

local prefabs_projectile =
{
    "peghook_hitfx",
    "peghook_dot",
}

local prefabs_hitfx =
{
    "peghook_splashfx",
    "goosplash",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(3, 1.5)
    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(.9, .9, .9)

    MakeCharacterPhysics(inst, 150, .8)

    inst.AnimState:SetBank("peghook")
    inst.AnimState:SetBuild("lavaarena_peghook_basic")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:AddOverrideBuild("fossilized")

    inst:AddTag("LA_mob")
    inst:AddTag("monster")
    inst:AddTag("hostile")

    --fossilizable (from fossilizable component) added to pristine state for optimization
    inst:AddTag("fossilizable")

    ------------------------------------------

    if TheWorld.components.lavaarenamobtracker ~= nil then
        TheWorld.components.lavaarenamobtracker:StartTracking(inst)
    end

    ------------------------------------------

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_peghook").peghook_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

local function CreateTail()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    --MakeInventoryPhysics(inst)
    --inst.Physics:ClearCollisionMask()

    inst.AnimState:SetBank("gooball_fx")
    inst.AnimState:SetBuild("gooball_fx")
    inst.AnimState:PlayAnimation("disappear")
    inst.AnimState:SetMultColour(.2, 1, 0, 1)
    inst.AnimState:SetFinalOffset(3)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function OnUpdateProjectileTail(inst, tails)
    local x, y, z = inst.Transform:GetWorldPosition()
    for tail, _ in pairs(tails) do
        tail:ForceFacePoint(x, y, z)
    end
    if inst.entity:IsVisible() then
        local tail = CreateTail()
        local rot = inst.Transform:GetRotation()
        tail.Transform:SetRotation(rot)
        rot = rot * DEGREES
        local offsangle = math.random() * TWOPI
        local offsradius = math.random() * .2 + .2
        local hoffset = math.cos(offsangle) * offsradius
        local voffset = math.sin(offsangle) * offsradius
        tail.Transform:SetPosition(x + math.sin(rot) * hoffset, y + voffset, z + math.cos(rot) * hoffset)
        --tail.Physics:SetMotorVel(speed * (.2 + math.random() * .3), 0, 0)]]
        tails[tail] = true
        inst:ListenForEvent("onremove", function(tail) tails[tail] = nil end, tail)
        --[[tail:ListenForEvent("onremove", function(inst)
            tail.Transform:SetRotation(tail.Transform:GetRotation() + math.random() * 30 - 15)
        end, inst)]]
    end
end

local function projectilefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:SetCapsule(.2, .2)

    inst:AddTag("NOCLICK")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.AnimState:SetBank("gooball_fx")
    inst.AnimState:SetBuild("gooball_fx")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(.2, 1, 0, 1)

    inst:Hide()

    inst:SetPrefabNameOverride("peghook") -- for backup death announce

    if not TheNet:IsDedicated() then
        inst:DoPeriodicTask(0, OnUpdateProjectileTail, nil, {})
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_peghook").projectile_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

local function spitfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gooball_fx")
    inst.AnimState:SetBuild("gooball_fx")
    inst.AnimState:PlayAnimation("smallblast")
    inst.AnimState:SetMultColour(.2, 1, 0, 1)
    inst.AnimState:SetFinalOffset(3)

    inst.Transform:SetTwoFaced()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

--------------------------------------------------------------------------

local function hitfxfn()
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

    event_server_data("lavaarena", "prefabs/lavaarena_peghook").hitfx_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

local function splashfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_hits_splash")
    inst.AnimState:SetBuild("lavaarena_hits_splash")
    inst.AnimState:PlayAnimation("aoe_hit")
    inst.AnimState:SetMultColour(.2, 1, 0, 1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(.54, .54)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)

    return inst
end

--------------------------------------------------------------------------

local function DoT_OnInit(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        parent:PushEvent("startcorrosivedebuff", inst)
    end
end

local function dotfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("CLASSIFIED")

    inst:DoTaskInTime(0, DoT_OnInit)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_peghook").dot_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

return Prefab("peghook", fn, assets, prefabs),
    Prefab("peghook_projectile", projectilefn, assets_projectile, prefabs_projectile),
    Prefab("peghook_spitfx", spitfxfn, assets_projectile),
    Prefab("peghook_hitfx", hitfxfn, assets_projectile, prefabs_hitfx),
    Prefab("peghook_splashfx", splashfxfn, assets_splashfx),
    Prefab("peghook_dot", dotfn)
