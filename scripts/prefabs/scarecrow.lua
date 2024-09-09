require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/scarecrow.zip"),
    Asset("ANIM", "anim/swap_scarecrow_face.zip"),
    Asset("ANIM", "anim/shadow_skinchangefx.zip"),
}

local prefabs =
{
    "collapse_big",
}

local numfaces =
{
    hit = 4,
    scary = 10,
    screaming = 3,
}

local function CancelDressup(inst)
    if inst._dressuptask ~= nil then
        inst._dressuptask:Cancel()
        inst._dressuptask = nil
        inst.components.wardrobe:Enable(true)
        inst:RemoveTag("NOCLICK")
    end
end

local function IsDressingUp(inst)
    return inst._dressuptask ~= nil
end

local function ChangeFace(inst, prefix)
    if inst:HasTag("fire") then
        prefix = "screaming"
    end
    prefix = prefix or "scary"

    local prev_face = inst.face or 1
    inst.face = math.random(numfaces[prefix]-1)
    if inst.face >= prev_face then
        inst.face = inst.face + 1
    end

    inst.AnimState:OverrideSymbol("swap_scarecrow_face", "swap_scarecrow_face", prefix.."face"..inst.face)
end

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not (IsDressingUp(inst) or inst:HasTag("burnt")) then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
        ChangeFace(inst, "hit")
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/scarecrow_craft")
end

local function onburnt(inst)
    DefaultBurntStructureFn(inst)
    CancelDressup(inst)
    inst:RemoveTag("scarecrow")
    inst.components.playeravatardata:SetData(nil)
end

local function onignite(inst)
    DefaultBurnFn(inst)
    ChangeFace(inst)
end

local function ontransformend(inst)
    inst._dressuptask = nil
    inst.components.wardrobe:Enable(true)
    inst:RemoveTag("NOCLICK")
end

local function ontransform(inst, cb)
    inst._dressuptask = inst:DoTaskInTime(6 * FRAMES, ontransformend)
    if cb ~= nil then
        cb()
    end
end

local function ondressup(inst, cb)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("transform")
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/together/skin_change")
        CancelDressup(inst)
        inst._dressuptask = inst:DoTaskInTime(44 * FRAMES, ontransform, cb)
        inst.components.wardrobe:Enable(false)
        inst:AddTag("NOCLICK")
    end
end

local function ondressedup(inst, data)
    if not inst:HasTag("burnt") then
        local avatardata =
        {
            name = data.doer ~= nil and data.doer:GetBasicDisplayName() or nil,
            prefab = data.doer ~= nil and data.doer.prefab or nil,
        }
        if data.skins ~= nil then
            for k, v in pairs(data.skins) do
                avatardata[k.."_skin"] = v
            end
        end
        inst.components.playeravatardata:SetData(avatardata)
    end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        else
            data = inst.components.playeravatardata:GetData()
            data =
            {
                name = data ~= nil and data.name or nil,
                prefab = data ~= nil and data.prefab or nil,
            }
            for k, v in pairs(inst.components.skinner:GetClothing()) do
                data[k.."_skin"] = v
            end
            inst.components.playeravatardata:SetData(data)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(0.75) --recipe min_spacing/2

    MakeObstaclePhysics(inst, 0.4)

    inst:AddTag("structure")
    inst:AddTag("scarecrow")

    inst.MiniMapEntity:SetIcon("scarecrow.png")

    inst.AnimState:SetBank("scarecrow")
    inst.AnimState:SetBuild("scarecrow")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:OverrideSymbol("shadow_hands", "shadow_skinchangefx", "shadow_hands")
    inst.AnimState:OverrideSymbol("shadow_ball", "shadow_skinchangefx", "shadow_ball")
    inst.AnimState:OverrideSymbol("splode", "shadow_skinchangefx", "splode")

    MakeSnowCoveredPristine(inst)

    inst:AddComponent("playeravatardata")
    inst.components.playeravatardata:AddNameData(true)
    inst.components.playeravatardata:AddClothingData(false)
    inst.components.playeravatardata:SetAllowEmptyName(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_adddeps = { "canary" }

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("wardrobe")
    inst.components.wardrobe:SetCanBeDressed(true)
    inst.components.wardrobe.ondressupfn = ondressup

    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable.onburnt = onburnt
    inst.components.burnable:SetOnIgniteFn(onignite)
    MakeMediumPropagator(inst)

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    inst:AddComponent("skinner")
    inst.components.skinner:SetupNonPlayerData()

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("dressedup", ondressedup)

    inst.OnEntityWake = ChangeFace

    inst.OnSave = onsave
    inst.OnLoad = onload

    ChangeFace(inst)

    return inst
end

return Prefab("scarecrow", fn, assets, prefabs),
    MakePlacer("scarecrow_placer", "scarecrow", "scarecrow", "idle")
