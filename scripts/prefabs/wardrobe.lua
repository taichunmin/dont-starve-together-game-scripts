require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/wardrobe.zip"),
}

local prefabs =
{
    "collapse_big",
}

local function onchangein(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("active")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/wardrobe_active")
    end
end

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("dontstarve/common/wardrobe_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        if inst.AnimState:IsCurrentAnimation("open") then
            inst.AnimState:PlayAnimation("cancel")
            inst.SoundEmitter:PlaySound("dontstarve/common/wardrobe_close")
        end
    end
end

local function onhammered(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    --close it
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/wardrobe_hit")
    end
    if inst.components.wardrobe ~= nil then
        inst.components.wardrobe:EndAllChanging()
    end
end

local PHYSICSGROW_BLOCKER_MUST_TAGS = { "character", "locomotor" }
local PHYSICSGROW_BLOCKER_CANT_TAGS = { "INLIMBO" }
local function OnUpdatePhysicsRadius(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    local mindist = math.huge
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 2, PHYSICSGROW_BLOCKER_MUST_TAGS, PHYSICSGROW_BLOCKER_CANT_TAGS)) do
        if v.entity:IsVisible() then
            local d = v:GetDistanceSqToPoint(x, y, z)
            d = d > 0 and (v.Physics ~= nil and math.sqrt(d) - v.Physics:GetRadius() or math.sqrt(d)) or 0
            if d < mindist then
                if d <= 0 then
                    mindist = 0
                    break
                end
                mindist = d
            end
        end
    end
    local radius = math.clamp(mindist, 0, inst.physicsradiusoverride)
    if radius > 0 then
        if radius ~= data.radius then
            data.radius = radius
            inst.Physics:SetCapsule(radius, 2)
            inst.Physics:Teleport(x, y, z)
        end
        if data.ischaracterpassthrough then
            data.ischaracterpassthrough = false
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        end
        if radius >= inst.physicsradiusoverride then
            inst._physicstask:Cancel()
            inst._physicstask = nil
        end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/wardrobe_craft")
    PreventCharacterCollisionsWithPlacedObjects(inst)
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1.25) --recipe min_spacing/2
    inst:SetPhysicsRadiusOverride(.75)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst:AddTag("structure")

    --wardrobe (from wardrobe component) added to pristine state for optimization
    inst:AddTag("wardrobe")

    inst.AnimState:SetBank("wardrobe")
    inst.AnimState:SetBuild("wardrobe")
    inst.AnimState:PlayAnimation("closed")

    inst.MiniMapEntity:SetIcon("wardrobe.png")

    MakeSnowCoveredPristine(inst)

    inst.scrapbook_anim = "closed"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("wardrobe")
    inst.components.wardrobe:SetChangeInDelay(20 * FRAMES)
    inst.components.wardrobe.onchangeinfn = onchangein
    inst.components.wardrobe.onopenfn = onopen
    inst.components.wardrobe.onclosefn = onclose

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeLargeBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    return inst
end

return Prefab("wardrobe", fn, assets, prefabs),
    MakePlacer("wardrobe_placer", "wardrobe", "wardrobe", "closed")
