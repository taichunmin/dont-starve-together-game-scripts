
local BALLOONS = require "prefabs/balloons_common"

local assets =
{
    Asset("ANIM", "anim/balloon.zip"),
    Asset("ANIM", "anim/balloon_shapes.zip"),
    Asset("ANIM", "anim/balloon2.zip"),
    Asset("ANIM", "anim/balloon_shapes2.zip"),
    Asset("SCRIPT", "scripts/prefabs/balloons_common.lua"),
}

local NUM_BALLOON_SHAPES = 9
for i = 1, NUM_BALLOON_SHAPES do
	table.insert(assets, Asset("INV_IMAGE", "balloon_"..tostring(i)))
end

local prefabs =
{
    "balloon_held_child", -- used in balloons_common.OnEquip_Hand
}

local function SetBalloonShape(inst, num)
    inst.balloon_num = num
    inst.AnimState:OverrideSymbol("swap_balloon", "balloon_shapes2", "balloon_"..tostring(num))
	inst.components.inventoryitem:ChangeImageName("balloon_"..tostring(num))
end

local function onsave(inst, data)
    data.num = inst.balloon_num
    data.colour_idx = inst.colour_idx
end

local function onload(inst, data)
    if data ~= nil then
        if data.num ~= nil and inst.balloon_num ~= data.num then
			SetBalloonShape(inst, data.num)
        end
        if data.colour_idx ~= nil then
			inst.colour_idx = BALLOONS.SetColour(inst, data.colour_idx)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	BALLOONS.MakeFloatingBallonPhysics(inst)

    inst.AnimState:SetBank("balloon2")
    inst.AnimState:SetBuild("balloon2")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetRayTestOnBB(true)

    inst.DynamicShadow:SetSize(1, .5)

    inst:AddTag("nopunch")
    inst:AddTag("cattoyairborne")
    inst:AddTag("balloon")
    inst:AddTag("noepicmusic")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.balloon_build = "balloon_shapes2"

	BALLOONS.MakeBalloonMasterInit(inst, BALLOONS.DoPop_Floating)

    inst.AnimState:SetTime(math.random() * 2)

	SetBalloonShape(inst, math.random(NUM_BALLOON_SHAPES))

    BALLOONS.SetRopeShape(inst)

	inst.colour_idx = BALLOONS.SetColour(inst)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(BALLOONS.OnEquip_Hand)
    inst.components.equippable:SetOnUnequip(BALLOONS.OnUnequip_Hand)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("balloon", fn, assets, prefabs)
