local assets =
{
	Asset( "ANIM", "anim/wave_shore.zip" )
}

local function onSleep(inst)
	inst:Remove()
end

local function SetAnim(inst)
	local ex, ey, ez = inst.Transform:GetWorldPosition()
	local bearing = -(inst.Transform:GetRotation() + 90) * DEGREES

	local map = TheWorld.Map
	local xr45, yr45 = map:GetTileXYAtPoint(ex + math.cos(bearing - 0.25*math.pi), ey, ez + math.sin(bearing - 0.25*math.pi))
	local xr90, yr90 = map:GetTileXYAtPoint(ex + math.cos(bearing - 0.5*math.pi), ey, ez + math.sin(bearing - 0.5*math.pi))
	local xl45, yl45 = map:GetTileXYAtPoint(ex + math.cos(bearing + 0.25*math.pi), ey, ez + math.sin(bearing + 0.25*math.pi))
	local xl90, yl90 = map:GetTileXYAtPoint(ex + math.cos(bearing + 0.5*math.pi), ey, ez + math.sin(bearing + 0.5*math.pi))

	local left = IsLandTile(map:GetTile(xl45, yl45)) and IsOceanTile(map:GetTile(xl90, yl90))
	local right = IsLandTile(map:GetTile(xr45, yr45)) and IsOceanTile(map:GetTile(xr90, yr90))

	if left and right then
		inst.AnimState:PlayAnimation("idle_big", false)
	elseif left then
		inst.Transform:SetPosition(ex - 0.5 * TILE_SCALE * math.cos(bearing - 0.5*math.pi), ey, ez - 0.5 * TILE_SCALE * math.sin(bearing - 0.5*math.pi))
		inst.AnimState:PlayAnimation("idle_med", false)
	elseif right then
		inst.Transform:SetPosition(ex + 0.5 * TILE_SCALE * math.cos(bearing - 0.5*math.pi), ey, ez + 0.5 * TILE_SCALE * math.sin(bearing - 0.5*math.pi))
		inst.AnimState:PlayAnimation("idle_med", false)
	else
		local small = {"idle_small", "idle_small2", "idle_small3", "idle_small4"}
		inst.AnimState:PlayAnimation(small[math.random(1, #small)], false)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    anim:SetOceanBlendParams(TUNING.OCEAN_SHADER.WAVE_TINT_AMOUNT)

	inst.persists = false

    anim:SetBuild( "wave_shore" )
    anim:SetBank( "wave_shore" )
    anim:PlayAnimation( "idle_small", false )
    anim:SetOrientation( ANIM_ORIENTATION.OnGround )
    anim:SetLayer(LAYER_BACKGROUND)
    anim:SetSortOrder(ANIM_SORT_ORDER.OCEAN_WAVES)

	inst:AddTag( "FX" )
	inst:AddTag( "NOCLICK" )
	inst:AddTag("NOBLOCK")
	inst:AddTag("ignorewalkableplatforms")

	inst.OnEntitySleep = onSleep
	--swap comments on these lines:
	inst:ListenForEvent( "animover", function(inst) inst:Remove() end )

	inst.SetAnim = SetAnim

    return inst
end

return Prefab( "common/fx/wave_shore", fn, assets )
