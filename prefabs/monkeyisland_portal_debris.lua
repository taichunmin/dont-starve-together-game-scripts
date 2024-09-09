local assets = 
{
    Asset("ANIM", "anim/portal_debris.zip"),
}

local prefabs =
{
    "collapse_small",
    "wagpunk_bits",
    "gears",
    "trinket_6", --Frazzled Wires
}

SetSharedLootTable("monkeyisland_portal_debris",
{
    {"wagpunk_bits", 0.85},
    {"gears",        0.25},
    {"trinket_6",    0.25},
})

local function OnHammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")

    inst:Remove()
end

local function OnHit(inst, worker)
    inst.AnimState:PlayAnimation("hit" .. inst.debris_id)
    inst.AnimState:PushAnimation("idle" .. inst.debris_id)

    --inst.SoundEmitter:PlaySound("monkeyhut hit sound here")
end

local function setdebristype(inst, index)
    if inst.debris_id == nil or (index ~= nil and inst.debris_id ~= index) then
        inst.debris_id = index or tostring(math.random(1, 3))
        inst.AnimState:PlayAnimation("idle"..inst.debris_id, true)
    end
end

local function onsave(inst, data)
    data.debris_id = inst.debris_id
end

local function onload(inst, data)
    setdebristype(inst, (data ~= nil and data.debris_id) or nil)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("portal_debris")
    inst.AnimState:SetBuild("portal_debris")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------------------------------------------------
    inst:AddComponent("inspectable")

    ---------------------------------------------------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("monkeyisland_portal_debris")

    ---------------------------------------------------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    ---------------------------------------------------------------
    --inst.debris_id = nil
    if not POPULATING then
        setdebristype(inst)
    end

    ---------------------------------------------------------------
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("monkeyisland_portal_debris", fn, assets, prefabs)