local messagebottletreasures = require("messagebottletreasures")

local assets =
{
	Asset("ANIM", "anim/bottle.zip"),

	Asset("ANIM", "anim/bottle.zip"),
	Asset("INV_IMAGE", "messagebottle"),

	Asset("ANIM", "anim/swap_bottle.zip"),
}

local prefabs =
{
	"messagebottleempty",
	"messagebottle_throwable",
}
JoinArrays(prefabs, messagebottletreasures.GetPrefabs())

local function playidleanim(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, y, z, false) then
		inst.AnimState:PlayAnimation("idle_water")
	else
		inst.AnimState:PlayAnimation("idle")
	end
end

local function ondropped(inst)
	inst.AnimState:PlayAnimation("idle")
end

local function getrevealtargetpos(inst, doer)
	if TheWorld.components.messagebottlemanager == nil then
		return false, "MESSAGEBOTTLEMANAGER_NOT_FOUND"
	end

	local pos, reason = TheWorld.components.messagebottlemanager:UseMessageBottle(inst, doer)
	return pos, reason
end

local function turn_empty(inst, targetpos)
	local inventory = inst.components.inventoryitem:GetContainer() -- Also returns inventory component

	local empty_bottle = SpawnPrefab("messagebottleempty")
	empty_bottle.Transform:SetPosition(inst.Transform:GetWorldPosition())

	inst:Remove()

	if inventory ~= nil then
		inventory:GiveItem(empty_bottle)
	end
end

local function onplayerfinishedreadingnote(player)
	if player.AnimState:IsCurrentAnimation("build_pst") then
		if player.components.talker ~= nil then
			player.components.talker:Say(STRINGS.MESSAGEBOTTLE_NOTES[math.random(#STRINGS.MESSAGEBOTTLE_NOTES)])
		end
	end

	player:RemoveEventCallback("animover", onplayerfinishedreadingnote)
end

local function prereveal(inst, doer)
	local bottle_contains_note = false

	if TheWorld.components.messagebottlemanager ~= nil then
		if (TheWorld.components.messagebottlemanager:GetPlayerHasUsedABottle(doer) or TheWorld.components.messagebottlemanager:GetPlayerHasFoundHermit(doer))
			and math.random() < TUNING.MESSAGEBOTTLE_NOTE_CHANCE then

			bottle_contains_note = true
		end

		TheWorld.components.messagebottlemanager:SetPlayerHasUsedABottle(doer)
	end

	if bottle_contains_note then
		doer:ListenForEvent("animover", onplayerfinishedreadingnote)
		turn_empty(inst)
		return false
	else
		return true
	end
end

local function messagebottlefn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddNetwork()

    inst.entity:AddAnimState()
    inst.AnimState:SetBank("bottle")
    inst.AnimState:SetBuild("bottle")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "small", -0.04, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0)

	inst:AddComponent("mapspotrevealer")
	inst.components.mapspotrevealer:SetGetTargetFn(getrevealtargetpos)
	inst.components.mapspotrevealer:SetPreRevealFn(prereveal)

	inst:ListenForEvent("on_landed", playidleanim)
	inst:ListenForEvent("on_reveal_map_spot_pst", turn_empty)

	inst:ListenForEvent("ondropped", ondropped)

	return inst
end

local function playidleanim_empty(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, y, z, false) then
		inst.AnimState:PlayAnimation("idle_empty_water")
	else
		inst.AnimState:PlayAnimation("idle_empty")
	end
end

local function ondropped_empty(inst)
	inst.AnimState:PlayAnimation("idle_empty")
end

local function emptybottlefn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bottle")
    inst.AnimState:SetBuild("bottle")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "small", -0.04, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
	end

    inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0)

	inst:ListenForEvent("on_landed", playidleanim_empty)

	inst:ListenForEvent("ondropped_empty", ondropped)

	return inst
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_bottle", "swap_bottle")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnHit(inst, attacker, target)
    local x, y, z = inst.Transform:GetWorldPosition()
    if not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) and not TheWorld.Map:GetPlatformAtPoint(x,z) then
    	SpawnPrefab("splash_green_small").Transform:SetPosition(x,y,z)
		inst.components.inventoryitem.canbepickedup = false

    	inst.AnimState:PlayAnimation("bob")
		inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    else
		SpawnPrefab("messagebottle_break_fx").Transform:SetPosition(x,y,z)
		inst:Remove()
    end
end

local function onthrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.AnimState:PlayAnimation("spin_loop", true)

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:SetCapsule(.2, .2)
end

local function throwingbottlefn()
	local inst = messagebottlefn()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.components.inventoryitem:ChangeImageName("messagebottle")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHit)
    inst.components.complexprojectile.water_targetable = true
    inst.useonimpassible = true
	return inst
end

local function bobbottlefn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bottle")
    inst.AnimState:SetBuild("bottle")
	inst.AnimState:PlayAnimation("bob")

	--MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "small", -0.04, 1)


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inventoryitem")
	inst.canbepickedup = false
	inst:ListenForEvent("animover", function(inst) inst:Remove() end)

	return inst
end

return Prefab("messagebottle", messagebottlefn, assets, prefabs),
		Prefab("messagebottleempty", emptybottlefn, assets),
		Prefab("messagebottle_throwable", throwingbottlefn, assets)
