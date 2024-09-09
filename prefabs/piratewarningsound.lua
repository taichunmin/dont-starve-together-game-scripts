local function CreateSoundFxAt(x, z)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

	inst.Transform:SetPosition(x, 0, z)
	inst.SoundEmitter:PlaySound("monkeyisland/primemate/announce")

	inst:Remove()
end

local function PlayWarningSound(inst)
	local player = ThePlayer
	if player ~= nil then
		local boat = player:GetCurrentPlatform()
		local range = 40 + (boat ~= nil and boat.components.walkableplatform ~= nil and boat.components.walkableplatform.platform_radius or 0)
		local x, y, z = inst.Transform:GetWorldPosition()
		local px, py, pz = player.Transform:GetWorldPosition()
		local dx, dz = x - px, z - pz
		local dist = dx * dx + dz * dz
		-- <= since we spawn at exactly RANGE 40
		-- see piratespawner to match range check
		if dist <= range * range then
			dist = math.sqrt(dist)
			if dist > 15 then
				dist = 15 / dist
				x = px + dx * dist
				z = pz + dz * dist
			end
			CreateSoundFxAt(x, z)
		end
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddNetwork()

	inst.entity:SetCanSleep(false)

	inst:AddTag("FX")

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		--Delay one frame so that we are positioned properly before starting the effect
		--or in case we are about to be removed
		inst:DoTaskInTime(0, PlayWarningSound)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	inst:DoTaskInTime(1, inst.Remove)

	return inst
end

return Prefab("piratewarningsound", fn)
