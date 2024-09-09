local assets =
{
    Asset("ANIM", "anim/balloon.zip"),
    Asset("ANIM", "anim/balloon_shapes.zip"),
}

-- the index is saved and also used as a net var on balloon_held_child
local colours =
{
	-- index 0 is no colour tint
    { 198/255,  43/255,  43/255, 1 },
    {  79/255, 153/255,  68/255, 1 },
    {  35/255, 105/255, 235/255, 1 },
    { 233/255, 208/255,  69/255, 1 },
    { 109/255,  50/255, 163/255, 1 },
    { 222/255, 126/255,  39/255, 1 },
}

local function SetColour(inst, colour_idx)
	colour_idx = colour_idx ~= nil and Clamp(colour_idx, 1, #colours) or math.random(#colours)
    inst.AnimState:SetMultColour(unpack(colours[colour_idx]))
	return colour_idx
end

local AREAATTACK_EXCLUDETAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }
local function doareaattack(inst, remove)
    inst.components.combat:DoAreaAttack(inst, TUNING.BALLOON_ATTACK_RANGE, nil, nil, nil, AREAATTACK_EXCLUDETAGS)
	if remove then
		inst:Remove()
	end
end

local function DeactiveBalloon(inst)
    RemovePhysicsColliders(inst)
	inst:AddTag("notarget")
    inst:AddTag("NOCLICK")
	inst.persists = false
	inst.components.inventoryitem.canbepickedup = false
	if inst.DynamicShadow ~= nil then
	    inst.DynamicShadow:Enable(false)
	end
end

local function DoPop_Floating(inst)
	DeactiveBalloon(inst)

	inst.AnimState:PlayAnimation("pop")
	inst.SoundEmitter:PlaySound("dontstarve/common/balloon_pop")

	local time_mult = 0.7 + math.random() * 0.4
	inst.AnimState:SetDeltaTimeMultiplier(time_mult)

	local attack_delay = (.1 + math.random() * .2)*time_mult
	inst:DoTaskInTime(attack_delay, doareaattack)

	local remove_delay = math.max(attack_delay, inst.AnimState:GetCurrentAnimationLength() * time_mult) + FRAMES
	inst:DoTaskInTime(remove_delay, inst.Remove)
end

local function DoPop(inst)
	DeactiveBalloon(inst)

	local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem:GetGrandOwner()
	if owner ~= nil and owner:IsValid() then
		if owner.components.rider == nil or not owner.components.rider:IsRiding() then -- don't pop balloon items if you are mounted
			if owner.components.inventory ~= nil then
				local fx = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) == inst and "balloon_pop_head"
						or owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) == inst and "balloon_pop_body"
						or nil

				if fx ~= nil then
					if owner.components.combat ~= nil and not owner:HasTag("player") then
						local x, y, z = owner.Transform:GetWorldPosition()
						owner.components.combat:SuggestTarget(TheSim:FindEntities(x, y, z, 10, {"balloonomancer"})[1])
					end

					SpawnPrefab(fx).Transform:SetPosition(inst.Transform:GetWorldPosition())
					doareaattack(inst)
				end

			end
			inst:Remove()
		end
	else
		SpawnPrefab("balloon_pop_body").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Hide()

		local delay = math.random(0, 3) * FRAMES
		inst:DoTaskInTime(delay, doareaattack, true)
	end
end

local function onremove(inst)
    if inst._body ~= nil then
        inst._body:Remove()
    end
end

local function OnEquip_Hand(inst, owner, from_ground)
	owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst._body ~= nil then
        inst._body:Remove()
    end
    inst._body = SpawnPrefab("balloon_held_child")
	inst._body:SetupFromBaseItem(inst, owner, from_ground, inst.colour_idx)

    inst:ListenForEvent("onremove", onremove)
    inst:ListenForEvent("onremove", function() inst.body = nil end, inst._body)

	inst.onownerattackedfn = function(_owner)
		if _owner:IsValid() and (owner.components.rider == nil or not owner.components.rider:IsRiding()) then -- don't pop balloon items if you are mounted
			_owner.components.inventory:DropItem(inst)
		end
	end
    inst:ListenForEvent("attacked", inst.onownerattackedfn, owner)
end

local function OnUnequip_Hand(inst, owner)
    if inst._body ~= nil then
        inst._body:Remove()
		inst._body = nil
    end

	if inst.onownerattackedfn ~= nil then
		inst:RemoveEventCallback("attacked", inst.onownerattackedfn, owner)
		inst.onownerattackedfn = nil
	end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function ondeath(inst)
	inst.components.poppable:Pop()
end

local function MakeBalloonMasterInit(inst, onpopfn, drop_on_built)
	if inst.components.inspectable == nil then
	    inst:AddComponent("inspectable")
	end

	inst:AddComponent("poppable")
	inst.components.poppable.onpopfn = onpopfn

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BALLOON_DAMAGE)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)
    inst.components.health.nofadeout = true
	inst.components.health.canmurder = false
    inst:ListenForEvent("death", ondeath)

	if inst.components.inventoryitem == nil then
	    inst:AddComponent("inventoryitem")
	end

	MakeHauntableLaunch(inst)
end

local function oncollide(inst, other)
    if (inst:IsValid() and Vector3(inst.Physics:GetVelocity()):LengthSq() > .1) or
        (other ~= nil and other:IsValid() and other.Physics ~= nil and Vector3(other.Physics:GetVelocity()):LengthSq() > .1) then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function MakeFloatingBallonPhysics(inst)
    local phys = inst.Physics or inst.entity:AddPhysics()
    phys:SetMass(10)
    phys:SetFriction(.3)
    phys:SetDamping(0)
    phys:SetRestitution(1)
    phys:SetCollisionGroup(COLLISION.CHARACTERS)

    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)

    phys:SetCapsule(.25, 2)

    phys:SetCollisionCallback(oncollide)

    return phys
end

local function FueledDepletedPop(inst)
	inst.components.poppable:Pop()
end

local function SetRopeShape(inst)
    inst.AnimState:OverrideSymbol("swap_rope", "balloon2", "rope_"..tostring(math.random(4)))
end

return
{
	MakeBalloonMasterInit = MakeBalloonMasterInit,
	MakeFloatingBallonPhysics = MakeFloatingBallonPhysics,

	SetColour = SetColour,
	SetRopeShape = SetRopeShape,

	OnEquip_Hand = OnEquip_Hand,
	OnUnequip_Hand = OnUnequip_Hand,

	DeactiveBalloon = DeactiveBalloon,
	DoPop = DoPop,
	DoPop_Floating = DoPop_Floating,

	FueledDepletedPop = FueledDepletedPop,
}
