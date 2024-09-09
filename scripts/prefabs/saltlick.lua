require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/salt_lick.zip"),
}

local assets_improved =
{
    Asset("ANIM", "anim/salt_lick.zip"),
    Asset("ANIM", "anim/salt_lick_improved_build.zip"),
}

-----------------------------------------------------------------------------------------------------------------------------

local SALTLICKER_MUST_TAGS = { "saltlicker" }
local SALTLICKER_CANT_TAGS = { "INLIMBO" }

local IMAGERANGE = 5

local function AlertNearbyCritters(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, TUNING.SALTLICK_CHECK_DIST, SALTLICKER_MUST_TAGS, SALTLICKER_CANT_TAGS)

    local data = { inst = inst }

    for _, ent in ipairs(ents) do
        ent:PushEvent("saltlick_placed", data)
    end
end

local function GetImageNum(inst)
    return tostring(IMAGERANGE - math.ceil(inst.components.finiteuses:GetPercent() * IMAGERANGE) + 1)
end

local function PlayIdle(inst, push)
    if inst:HasTag("burnt") then
        return
    end

    local anim = "idle"..inst:GetImageNum()

    if push then
        inst.AnimState:PushAnimation(anim, true)
    else
        inst.AnimState:PlayAnimation(anim, true)
    end
end

local function OnUsed(inst, data)
    inst:PlayIdle()
end

local function OnBuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/salt_lick_craft")

    inst.AnimState:PlayAnimation("place")

    inst:PlayIdle(true)
    inst:AlertNearbyCritters()
end

local function OnFinished(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle6", true)
    end

    inst:RemoveTag("saltlick")
end

local function OnHammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

local function OnHit(inst)
    if inst:HasTag("burnt") then
        return
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/salt_lick_hit")

    inst.AnimState:PlayAnimation("hit"..inst:GetImageNum())

    inst:PlayIdle(true)
end

-----------------------------------------------------------------------------------------------------------------------------

local function Regular_OnBurnt(inst)
    inst:RemoveTag("saltlick")

    inst.components.finiteuses:SetUses(0)
end

local function Regular_OnSave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function Regular_OnLoad(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

-----------------------------------------------------------------------------------------------------------------------------

local function Improved_OnRepaired(inst, doer)
    inst.AnimState:PlayAnimation("hit"..inst:GetImageNum())
    inst:PlayIdle(true)

    inst:AddTag("saltlick")

    inst.SoundEmitter:PlaySound("meta4/fancy_saltlick/repair")
end

-----------------------------------------------------------------------------------------------------------------------------

local function CommonFn(build, minimap)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetIcon(minimap)

    inst.AnimState:SetBank("salt_lick")
    inst.AnimState:SetBuild(build)

    inst:AddTag("structure")
    inst:AddTag("saltlick")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnUsed = OnUsed
    inst.PlayIdle = PlayIdle
    inst.GetImageNum = GetImageNum
    inst.AlertNearbyCritters = AlertNearbyCritters

    inst.OnBuilt = OnBuilt

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SALTLICK_MAX_LICKS)
    inst.components.finiteuses:SetUses(TUNING.SALTLICK_MAX_LICKS)
    inst.components.finiteuses:SetOnFinished(OnFinished)
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    inst:PlayIdle()

    inst:ListenForEvent("percentusedchange", inst.OnUsed)

    MakeSnowCovered(inst)
    MakeHauntableLaunch(inst)

    return inst
end

local function RegularFn()
    local inst = CommonFn("salt_lick", "saltlick.png")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnBurnt = Regular_OnBurnt

    inst.OnSave = Regular_OnSave
    inst.OnLoad = Regular_OnLoad

    MakeSmallBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)

    inst:ListenForEvent("burntup", inst.OnBurnt)
    
    return inst
end

local function ImprovedFn()
    local inst = CommonFn("salt_lick_improved_build", "saltlick_improved.png")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = MATERIALS.SALT
    inst.components.repairable.onrepaired = Improved_OnRepaired

    inst.components.finiteuses:SetMaxUses(TUNING.SALTLICK_IMPROVED_MAX_LICKS)
    inst.components.finiteuses:SetUses(TUNING.SALTLICK_IMPROVED_MAX_LICKS)

    return inst
end

return
    Prefab("saltlick",          RegularFn,  assets         ),
    Prefab("saltlick_improved", ImprovedFn, assets_improved),

    MakePlacer("saltlick_placer",          "salt_lick", "salt_lick",                "idle1"),
    MakePlacer("saltlick_improved_placer", "salt_lick", "salt_lick_improved_build", "idle1")
