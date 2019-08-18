require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/trap_bramble.zip"),
    Asset("MINIMAP_IMAGE", "trap_bramble"),
}

local prefabs =
{
    "bramblefx_trap",
}

local function onfinished_normal(inst)
    inst:RemoveComponent("inventoryitem")
    inst:RemoveComponent("mine")
    inst.persists = false
    inst.Physics:SetActive(false)
    inst.AnimState:PushAnimation("used", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:DoTaskInTime(3, inst.Remove)
end

local function DoThorns(inst, pos)
    SpawnPrefab("bramblefx_trap").Transform:SetPosition(pos:Get())
end

local function OnExplode(inst)--, target)
    inst.AnimState:PlayAnimation("trap")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wormwood/bramble_trap/trigger")

    inst:DoTaskInTime(11 * FRAMES, DoThorns, inst:GetPosition())

    if inst.components.finiteuses ~= nil then
        inst.components.finiteuses:Use(1)
    end
end

local function OnReset(inst)
    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem.nobounce = true
    end
    if not inst:IsInLimbo() then
        inst.MiniMapEntity:SetEnabled(true)
    end
    if not inst.AnimState:IsCurrentAnimation("idle") then
        inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_reset")
        inst.SoundEmitter:PlaySound("dontstarve/characters/wormwood/bramble_trap/set")
        inst.AnimState:PlayAnimation("reset")
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function SetSprung(inst)
    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem.nobounce = true
    end
    if not inst:IsInLimbo() then
        inst.MiniMapEntity:SetEnabled(true)
    end
    inst.AnimState:PlayAnimation("trap_idle")
end

local function SetInactive(inst)
    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem.nobounce = false
    end
    inst.MiniMapEntity:SetEnabled(false)
    inst.AnimState:PlayAnimation("inactive")
end

local function OnDropped(inst)
    inst.components.mine:Deactivate()
end

local function ondeploy(inst, pt, deployer)
    inst.components.mine:Reset()
    inst.Physics:Stop()
    inst.Physics:Teleport(pt:Get())
end

local function OnHaunt(inst, haunter)
    if inst.components.mine == nil or inst.components.mine.inactive then
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
        Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
        return true
    elseif not inst.components.mine.issprung then
        return false
    elseif math.random() <= TUNING.HAUNT_CHANCE_OFTEN then
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        inst.components.mine:Reset()
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("trap_bramble.png")

    inst.AnimState:SetBank("trap_bramble")
    inst.AnimState:SetBuild("trap_bramble")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("trap")

    MakeInventoryFloatable(inst, "small", nil, {1.2, 0.8, 1.2})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("mine")
    inst.components.mine:SetRadius(TUNING.TRAP_BRAMBLE_RADIUS)
    inst.components.mine:SetAlignment("player")
    inst.components.mine:SetOnExplodeFn(OnExplode)
    inst.components.mine:SetOnResetFn(OnReset)
    inst.components.mine:SetOnSprungFn(SetSprung)
    inst.components.mine:SetOnDeactivateFn(SetInactive)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.TRAP_BRAMBLE_USES)
    inst.components.finiteuses:SetUses(TUNING.TRAP_BRAMBLE_USES)
    inst.components.finiteuses:SetOnFinished(onfinished_normal)

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst.components.mine:Reset()

    return inst
end

return Prefab("trap_bramble", fn, assets, prefabs),
    MakePlacer("trap_bramble_placer", "trap_bramble", "trap_bramble", "idle")
