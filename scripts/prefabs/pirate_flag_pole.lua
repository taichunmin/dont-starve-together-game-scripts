require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/pirate_flag_pole.zip"),
}

local prefabs =
{
    "collapse_big",
    "blackflag",
}

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle1", false)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle1", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/scarecrow_craft")
end

local function onburnt(inst)
    if inst.flagtask then
        inst.flagtask:Cancel()
        inst.flagtask = nil
    end
    DefaultBurntStructureFn(inst)
end

local function onignite(inst)
    DefaultBurnFn(inst)
end

local function flagidletask(inst)
    inst.flagtask = inst:DoTaskInTime(math.random()*10,function()
        if inst.AnimState:IsCurrentAnimation("idle1") then
            inst.AnimState:PlayAnimation("idle"..math.random(2,3))
            inst.AnimState:PushAnimation("idle1")
        end
        flagidletask(inst)
    end)
end

---------------

local function setflagnumber(inst, number)
    if inst.flag_number == nil or (number ~= nil and number ~= inst.flag_number) then
        inst.flag_number = number or ("0"..tostring(math.random(1, 4)))

        inst.AnimState:OverrideSymbol("flag_01", "pirate_flag_pole", "flag_"..inst.flag_number)
    end
end

---------------
-- SAVE/LOAD --
---------------

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end

    data.flag_number = inst.flag_number
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        else
            setflagnumber(inst, data.flag_number)
        end
    end
end

local function OnEntitySleep(inst)
    if inst.flagtask then
        inst.flagtask:Cancel()
        inst.flagtask = nil
    end
end

local function OnEntityWake(inst)
    flagidletask(inst)
end

---------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.2)

    inst:AddTag("structure")

    inst.MiniMapEntity:SetIcon("pirate_flag_pole.png")

    inst.AnimState:SetBank("pirate_flag_pole")
    inst.AnimState:SetBuild("pirate_flag_pole")
    inst.AnimState:PlayAnimation("idle1",false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable.onburnt = onburnt
    inst.components.burnable:SetOnIgniteFn(onignite)
    MakeMediumPropagator(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    flagidletask(inst)

    ---------------------------------------------------------------
    --inst.flag_number = nil
    if not POPULATING then
        setflagnumber(inst)
    end

    ---------------------------------------------------------------
    inst.OnSave = onsave
    inst.OnLoad = onload

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

return Prefab("pirate_flag_pole", fn, assets, prefabs),
       MakePlacer("pirate_flag_pole_placer", "pirate_flag_pole", "pirate_flag_pole", "placer" )

