local assets =
{
    Asset("ANIM", "anim/oceantreenut.zip"),
}

local prefabs =
{
    "rock_break_fx",
	"twigs",
	"spoiled_fish_small",
}

SetSharedLootTable( 'oceantreenut',
{
    {'twigs',				1.00},
    {'twigs',				0.50},
    {'spoiled_fish_small',  0.01},
})

local PHYSICS_RADIUS = .75

local GROW_CHECK_BLOCKER_RADIUS = 2
local GROW_BLOCKER_TAGS = { "tree" }

local ATTEMPT_GROW_FREQUENCY = 60

local CHECK_NEARBY_BOATS_OFFSET = PHYSICS_RADIUS + 0.1

local TWOPI = 6.28319

local function OnWorkedFinished(inst, worker)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")

    inst:Remove()
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "oceantreenut", "swap_body")
end

local function NoNearbyBoats(inst)
    local x, _, z = inst.Transform:GetWorldPosition()
    local theta

    for i = 1, 8 do
        theta = i * (TWOPI / 8)
        if TheWorld.Map:GetPlatformAtPoint(x + math.cos(theta) * CHECK_NEARBY_BOATS_OFFSET, z + math.sin(theta) * CHECK_NEARBY_BOATS_OFFSET) ~= nil then
            return false
        end
    end

    return true
end

local function CanGrow(inst)
    local container = inst.components.submersible:GetUnderwaterObject()
    local underwater_object = container.inst
    if underwater_object ~= nil then
        local x, _, z = underwater_object.Transform:GetWorldPosition()
        return TheWorld.Map:IsOceanAtPoint(x, 0, z, false)
            and next(TheSim:FindEntities(x, 0, z, GROW_CHECK_BLOCKER_RADIUS, GROW_BLOCKER_TAGS)) == nil
            and NoNearbyBoats(underwater_object)
    else
        return false
    end
end

local function Grow(inst)
    local tree = SpawnPrefab("oceantree_short")
    
    local x, _, z = inst.components.submersible:GetUnderwaterObject().inst.Transform:GetWorldPosition()
    tree.Transform:SetPosition(x, 0, z)
    tree:sproutfn()

    inst:Remove()
end

local function AttemptGrow(inst)
    if CanGrow(inst) then
        Grow(inst)
    end
end

local function OnSubmerge(inst, data)
    if inst.components.timer:TimerExists("grow") then
        inst.components.timer:ResumeTimer("grow")
    else
        inst.components.timer:StartTimer("grow", TUNING.OCEANTREENUT_GROW_TIME + math.random() * TUNING.OCEANTREENUT_GROW_TIME_VARIANCE)
    end

    if inst.should_attempt_grow and inst.attempt_grow_task == nil then
        inst.attempt_grow_task = inst:DoPeriodicTask(ATTEMPT_GROW_FREQUENCY, AttemptGrow)
    end
end

local function OnSalvaged(inst)
    inst.components.timer:StopTimer("grow")

    if inst.attempt_grow_task ~= nil then
        inst.attempt_grow_task:Cancel()
        inst.attempt_grow_task = nil
    end

    inst.should_attempt_grow = false
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "grow" then
        if CanGrow(inst) then
            Grow(inst)
        else
            -- inst.components.timer:StartTimer("grow", 15)
            inst.should_attempt_grow = true
            inst.attempt_grow_task = inst:DoPeriodicTask(ATTEMPT_GROW_FREQUENCY, AttemptGrow)
        end
    end
end

local function OnEntitySleep(inst)
    if inst.attempt_grow_task ~= nil then
        inst.attempt_grow_task:Cancel()
        inst.attempt_grow_task = nil
    end
end

local function OnEntityWake(inst)
    if inst.should_attempt_grow and inst.attempt_grow_task == nil then
        inst.attempt_grow_task = inst:DoPeriodicTask(ATTEMPT_GROW_FREQUENCY, AttemptGrow)
    end
end

local function OnSave(inst, data)
    if inst.should_attempt_grow then
        data.should_attempt_grow = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.should_attempt_grow then
        inst.should_attempt_grow = true
    end
end

local function OnLoadPostPass(inst, newents, data)
    local underwater_obj = inst.components.submersible:GetUnderwaterObject()
    if underwater_obj == nil then
        local x, _, z = inst.Transform:GetWorldPosition()
        inst.Transform:SetPosition(x, 0, z)
    else
        if inst.should_attempt_grow and inst.attempt_grow_task == nil then
            inst.attempt_grow_task = inst:DoPeriodicTask(ATTEMPT_GROW_FREQUENCY, AttemptGrow)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("oceantreenut")
    inst.AnimState:SetBuild("oceantreenut")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("heavy")

    MakeHeavyObstaclePhysics(inst, PHYSICS_RADIUS)
    inst:SetPhysicsRadiusOverride(PHYSICS_RADIUS)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.should_attempt_grow = false
    inst.attempt_grow_task = nil

    inst:AddComponent("inspectable")

	inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('oceantreenut')

    inst:AddComponent("heavyobstaclephysics")
    inst.components.heavyobstaclephysics:SetRadius(PHYSICS_RADIUS)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(OnWorkedFinished)

    inst:AddComponent("timer")

    inst:AddComponent("submersible")
    inst:AddComponent("symbolswapdata")
    inst.components.symbolswapdata:SetData("oceantreenut", "swap_body")

    inst:ListenForEvent("on_submerge", OnSubmerge)
    inst:ListenForEvent("on_salvaged", OnSalvaged)

    inst:ListenForEvent("timerdone", OnTimerDone)

    MakeHauntableWork(inst)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.OnLoadPostPass = OnLoadPostPass

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("oceantreenut", fn, assets, prefabs)
