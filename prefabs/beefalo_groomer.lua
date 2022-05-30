require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/beefalo_wardrobe.zip"),
    Asset("ANIM", "anim/swap_scarecrow_face.zip"),
    Asset("ANIM", "anim/shadow_skinchangefx.zip"),
    Asset("MINIMAP_IMAGE", "yotb_beefalowardrobe"),
}

local item_assets =
{
    Asset("ANIM", "anim/beefalo_groomer_item.zip"),
    Asset("INV_IMAGE", "beefalo_groomer_item"),
}

local prefabs =
{
    "collapse_big",
    "beefalo_groomer_item", -- deprecated but kept for existing worlds and mods
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
        inst.components.groomer:Enable(true)
        inst:RemoveTag("NOCLICK")
    end
end

local function IsDressingUp(inst)
    return inst._dressuptask ~= nil
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

    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("yotb_2021/common/beefalo_groomer/place")
end

local function onburnt(inst)
    DefaultBurntStructureFn(inst)
    CancelDressup(inst)
end

local function onignite(inst)
    if inst.components.hitcher and not inst.components.hitcher.canbehitched then
        inst.components.hitcher:Unhitch()
    end
    DefaultBurnFn(inst)
end

local function ontransformend(inst)
    inst._dressuptask = nil
    inst.components.groomer:Enable(true)
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
        inst.components.groomer:Enable(false)
        inst:AddTag("NOCLICK")
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
        end
    end
end

local function onhitch(inst,target)
    if inst.components.groomer then
        inst.components.groomer:SetOccupant(target)
    end
end


local function onunhitch(inst,oldtarget)
    oldtarget:PushEvent("unhitch")
    if inst.components.groomer then
        inst.components.groomer:SetOccupant()
    end
end

local function onremove(inst)
    if inst.components.hitcher and inst.components.hitcher:GetHitched() then
        inst.components.hitcher:Unhitch()
    end
end

local function onunlockskin(inst)
    inst.AnimState:PlayAnimation("gift")
    inst.AnimState:PushAnimation("idle",true)
end

local function changefn(inst)
    inst.SoundEmitter:PlaySound("yotb_2021/common/beefalo_groomer/use")
    inst.AnimState:PlayAnimation("use")
    inst.AnimState:PushAnimation("idle",true)
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.4)

    inst:AddTag("structure")
    inst:AddTag("beefalo_groomer")

    inst.MiniMapEntity:SetIcon("yotb_beefalowardrobe.png")

    inst.AnimState:SetBank("beefalo_wardrobe")
    inst.AnimState:SetBuild("beefalo_wardrobe")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:OverrideSymbol("shadow_hands", "shadow_skinchangefx", "shadow_hands")
    inst.AnimState:OverrideSymbol("shadow_ball", "shadow_skinchangefx", "shadow_ball")
    inst.AnimState:OverrideSymbol("splode", "shadow_skinchangefx", "splode")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("groomer")
    inst.components.groomer:SetCanBeDressed(true)
    inst.components.groomer.ondressupfn = ondressup
    inst.components.groomer.unlockfn = onunlockskin
    inst.components.groomer.changefn = changefn

    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable.onburnt = onburnt
    inst.components.burnable:SetOnIgniteFn(onignite)
    MakeMediumPropagator(inst)

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    inst:AddComponent("skinner")
    inst.components.skinner:SetupNonPlayerData()

    inst:AddComponent("hitcher")
    inst.components.hitcher.hitchedfn = onhitch
    inst.components.hitcher.unhitchfn = onunhitch

    inst:ListenForEvent("onremove", onremove)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("beefalo_groomer", fn, assets, prefabs),
    MakeDeployableKitItem("beefalo_groomer_item", "beefalo_groomer", "beefalo_groomer_item", "beefalo_groomer_item", "idle", item_assets, {size = "med", scale = 0.9}, nil, {fuelvalue = TUNING.MED_FUEL}),
    MakePlacer("beefalo_groomer_item_placer", "beefalo_wardrobe", "beefalo_wardrobe", "idle")
