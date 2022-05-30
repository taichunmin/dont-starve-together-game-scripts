local assets =
{
    Asset("ANIM", "anim/singingshell_cluster.zip"),
    Asset("MINIMAP_IMAGE", "singingshell_cluster"),
}

local prefabs =
{
	"singingshell_octave3",
	"singingshell_octave4",
	"singingshell_octave5",

    "rock_break_fx",

	"underwater_salvageable",
	"splash_green",
}

SetSharedLootTable("shell_cluster",
{
	{ "singingshell_octave3",  1 },
	{ "singingshell_octave4",  1 },
	{ "singingshell_octave5",  1 },
	{ "singingshell_octave3",  .5 },
	{ "singingshell_octave4",  .5 },
	{ "singingshell_octave5",  .5 },
})

local PHYSICS_RADIUS = .75

local function OnWorked(inst, worker)
    local pt = inst:GetPosition()
	SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())

	inst.components.lootdropper:DropLoot(pt)

    inst:Remove()
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "singingshell_cluster", "swap_body")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("singingshell_cluster.png")

    inst.AnimState:SetBank("singingshell_cluster")
    inst.AnimState:SetBuild("singingshell_cluster")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("heavy")

	MakeHeavyObstaclePhysics(inst, PHYSICS_RADIUS)
	inst:SetPhysicsRadiusOverride(PHYSICS_RADIUS)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("shell_cluster")

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
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.SHELL_CLUSTER_MINE)
	inst.components.workable:SetOnFinishCallback(OnWorked)

	inst:AddComponent("submersible")
	inst:AddComponent("symbolswapdata")
	inst.components.symbolswapdata:SetData("singingshell_cluster", "swap_body")

    MakeHauntableWork(inst)

    return inst
end

return Prefab("shell_cluster", fn, assets, prefabs)
