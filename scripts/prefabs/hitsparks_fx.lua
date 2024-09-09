local assets =
{
	Asset("ANIM", "anim/lavaarena_hit_sparks_fx.zip"),
}

--------------------------------------------------------------------------

local function PushColour(inst, r, g, b)
	if inst.target.components.colouradder == nil then
		inst.target:AddComponent("colouradder")
	end
	inst.target.components.colouradder:PushColour(inst, r, g, b, 0)
end

local function PopColour(inst)
	if inst.target:IsValid() then
		inst.target.components.colouradder:PopColour(inst)
	end
end

local function UpdateFlash(inst)
	if inst.target:IsValid() then
		if inst.flashstep < 4 then
			local value = (inst.flashstep > 2 and 4 - inst.flashstep or inst.flashstep) * .05
			if inst.flashcolour ~= nil then
				local r, g, b = unpack(inst.flashcolour)
				PushColour(inst, value * r, value * g, value * b)
			else
				PushColour(inst, value, value, value)
			end
			inst.flashstep = inst.flashstep + 1
			return
		else
			PopColour(inst)
		end
	end
	inst.OnRemoveEntity = nil
	inst.components.updatelooper:RemoveOnUpdateFn(UpdateFlash)
end

local function StartFlash(inst, target, flashcolour)
	inst:AddComponent("updatelooper")
	inst.components.updatelooper:AddOnUpdateFn(UpdateFlash)
	inst.target = target
	inst.flashstep = 1
	inst.flashcolour = flashcolour
	inst.OnRemoveEntity = PopColour
	UpdateFlash(inst)
end

--------------------------------------------------------------------------

local function Setup(inst, attacker, target, projectile, flashcolour)
	local x, y, z = target.Transform:GetWorldPosition()
	local radius = target:GetPhysicsRadius(.5)
	local source = projectile or attacker
	if source ~= nil and source:IsValid() then
		local angle = (source.Transform:GetRotation() + 180) * DEGREES
		x = x + math.cos(angle) * radius
		z = z - math.sin(angle) * radius
	end
	inst.Transform:SetPosition(x, .5, z)

	StartFlash(inst, target, flashcolour)
end

local function SetupReflect(inst, attacker, target, projectile, flashcolour)
	local x, y, z = target.Transform:GetWorldPosition()
	local rot
	local source = projectile or attacker

	if source ~= nil and source:IsValid() then
		local x1, y1, z1 = source.Transform:GetWorldPosition()
		if x ~= x1 or z ~= z1 then
			local dx = x - x1
			local dz = z - z1
			local rescale_radius = source:GetPhysicsRadius(.5) / math.sqrt(dx * dx + dz * dz)
			x = x1 + dx * rescale_radius
			z = z1 + dz * rescale_radius
			rot = math.atan2(dz, -dx) * RADIANS
		end
	end

	inst.Transform:SetPosition(x, 1 + math.random(), z)
	inst.Transform:SetRotation((rot or target.Transform:GetRotation()) + 90)

	StartFlash(inst, target, flashcolour)
end

local function SetupPiercing(inst, attacker, target, projectile, flashcolour, inverted, offset_y)
	local x, y, z = (projectile or attacker).Transform:GetWorldPosition()
	local rot
	local source = target
	
	if source ~= nil and source:IsValid() then
		local x1, y1, z1 = source.Transform:GetWorldPosition()
		if x ~= x1 or z ~= z1 then
			local dx = x - x1
			local dz = z - z1
			local rescale_radius = source:GetPhysicsRadius(.5) / math.sqrt(dx * dx + dz * dz)
			x = x1 + dx * rescale_radius
			z = z1 + dz * rescale_radius
			rot = math.atan2(dz, -dx) * RADIANS
			
			if not inverted then
				rot = rot + 180
			end
		end
	end

	inst.Transform:SetPosition(x, offset_y or (1 + math.random()), z)
	inst.Transform:SetRotation((rot or target.Transform:GetRotation()) + 90)

	StartFlash(inst, target, flashcolour)
end

--------------------------------------------------------------------------

local function PlaySparksAnim(proxy, horizontal)
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.Transform:SetFromProxy(proxy.GUID)

	inst.AnimState:SetBank("hits_sparks")
	inst.AnimState:SetBuild("lavaarena_hit_sparks_fx")
	inst.AnimState:PlayAnimation("hit_3")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetFinalOffset(1)
	inst.AnimState:SetScale(proxy.flip:value() and -.7 or .7, .7)
	if proxy.black:value() then
		inst.AnimState:SetMultColour(0, 0, 0, 1)
	end
	if horizontal then
		inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	end

	inst:ListenForEvent("animover", inst.Remove)
end

--------------------------------------------------------------------------

local function MakeFX(name, horizontal, setupfn)
	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddNetwork()

		inst:AddTag("FX")

		--Dedicated server does not need to spawn the local fx
		if not TheNet:IsDedicated() then
			--Delay one frame so that we are positioned properly before starting the effect
			--or in case we are about to be removed
			inst:DoTaskInTime(0, PlaySparksAnim, horizontal)
		end

		inst.flip = net_bool(inst.GUID, "hitsparks_fx.flip")
		inst.black = net_bool(inst.GUID, "hitsparks_fx.black")

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst.persists = false
		inst:DoTaskInTime(1, inst.Remove)

		inst.flip:set(math.random() < .5)

		inst.Setup = setupfn

		return inst
	end

	return Prefab(name, fn, assets)
end

--------------------------------------------------------------------------

return
		MakeFX( "hitsparks_fx",          false, Setup         ),
		MakeFX( "hitsparks_reflect_fx",  true,  SetupReflect  ),
		MakeFX( "hitsparks_piercing_fx", true,  SetupPiercing )
