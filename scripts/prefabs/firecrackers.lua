local assets =
{
    Asset("ANIM", "anim/firecrackers.zip"),
}

local prefabs =
{
    "explode_firecrackers",
}

local STARTLE_TAGS = { "canbestartled" }
local function DoPop(inst, remaining, total, level, hissvol)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("explode_firecrackers").Transform:SetPosition(x, y, z)

    for i, v in ipairs(TheSim:FindEntities(x, y, z, TUNING.FIRECRACKERS_STARTLE_RANGE, STARTLE_TAGS)) do
        v:PushEvent("startle", { source = inst })
    end

    if remaining > 1 then
        inst.AnimState:PlayAnimation("spin_loop"..tostring(math.random(3)))

        if hissvol > .5 then
            hissvol = hissvol - .1
            inst.SoundEmitter:SetVolume("hiss", hissvol)
        end

        local newlevel = 8 - math.ceil(8 * remaining / total)
        for i = level + 1, newlevel do
            inst.AnimState:Hide("F"..tostring(i))
        end

        local angle = math.random() * TWOPI
        local spd = 1.5
        inst.Physics:Teleport(x, math.max(y * .5, .1), z)
        inst.Physics:SetVel(math.cos(angle) * spd, 8, math.sin(angle) * spd)

        --23 frames in spin_loop, so if the delay gets longer, loop the anim
        inst:DoTaskInTime(.3 + .3 * math.random(), DoPop, remaining - 1, total, newlevel, hissvol)
    else
        inst:Remove()
    end
end

local function StartExploding(inst, count)
    inst:AddTag("NOCLICK")
    inst:AddTag("scarytoprey")
    inst.Physics:SetFriction(.2)
    DoPop(inst, count, count, 0, 1)
end

local function StartFuse(inst)
    inst.starttask = nil
    inst:RemoveComponent("burnable")

    inst.AnimState:PlayAnimation("burn")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")

    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), StartExploding, math.floor(33.4 * math.sqrt(inst.components.stackable:StackSize() + 3) - 58.8 + .5))

    inst:RemoveComponent("stackable")
    inst.persists = false
end

local function OnIgniteFn(inst)
    if inst.starttask == nil then
        inst.starttask = inst:DoTaskInTime(0, StartFuse)
    end
    inst.components.inventoryitem.canbepickedup = false
end

local function OnExtinguishFn(inst)
    if inst.starttask ~= nil then
        inst.starttask:Cancel()
        inst.starttask = nil
        inst.components.inventoryitem.canbepickedup = true
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("firecrackers")
    inst.AnimState:SetBuild("firecrackers")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("explosive")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inventoryitem")

    inst:AddComponent("inspectable")

    inst:AddComponent("burnable")
    inst.components.burnable:SetBurnTime(nil)
    inst.components.burnable:SetOnIgniteFn(OnIgniteFn)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguishFn)

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("firecrackers", fn, assets, prefabs)
