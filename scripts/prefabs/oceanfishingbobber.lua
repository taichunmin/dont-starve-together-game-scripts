
local BOBBERS =
{
	["oceanfishingbobber_none"]			= { make_inv_item = false, bank = "oceanfishing_hook",        build = "oceanfishing_hook",						land_splash_fx = "ocean_splash_ripple",		oneat_sfx = nil,												casting_data = nil, },
	["oceanfishingbobber_twig"]			= { make_inv_item = false, bank = "oceanfishing_bobber_ball", build = "oceanfishing_bobber_twig_build",			land_splash_fx = "ocean_splash_med",		oneat_sfx = "turnoftides/common/together/water/submerge/small", casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_TWIG, },
	["oceanfishingbobber_plug"]			= { make_inv_item = false, bank = "oceanfishing_bobber_ball", build = "oceanfishing_bobber_plug_build",			land_splash_fx = "ocean_splash_med",		oneat_sfx = "turnoftides/common/together/water/submerge/small", casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_PLUG, },
	["oceanfishingbobber_ball"]			= { make_inv_item = true,  bank = "oceanfishing_bobber_ball", build = "oceanfishing_bobber_ball_build",			land_splash_fx = "ocean_splash_med",		oneat_sfx = "turnoftides/common/together/water/submerge/small", casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_BALL,},
	["oceanfishingbobber_oval"]			= { make_inv_item = true,  bank = "oceanfishing_bobber_ball", build = "oceanfishing_bobber_sporty_build",		land_splash_fx = "ocean_splash_med",		oneat_sfx = "turnoftides/common/together/water/submerge/small", casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_OVAL, },

	["oceanfishingbobber_crow"]			= { make_inv_item = true,  bank = "oceanfishing_bobber_ball", build = "oceanfishingbobber_crow_build",			land_splash_fx = "ocean_splash_ripple",		oneat_sfx = "dontstarve/common/fishingpole_baitsplash",			casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_CROW, },
	["oceanfishingbobber_robin"]		= { make_inv_item = true,  bank = "oceanfishing_bobber_ball", build = "oceanfishingbobber_robin_build",			land_splash_fx = "ocean_splash_ripple",		oneat_sfx = "dontstarve/common/fishingpole_baitsplash",			casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_ROBIN, },
	["oceanfishingbobber_robin_winter"]	= { make_inv_item = true,  bank = "oceanfishing_bobber_ball", build = "oceanfishingbobber_robin_winter_build",	land_splash_fx = "ocean_splash_ripple",		oneat_sfx = "dontstarve/common/fishingpole_baitsplash",			casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_ROBIN_WINTER, },
	["oceanfishingbobber_canary"]		= { make_inv_item = true,  bank = "oceanfishing_bobber_ball", build = "oceanfishingbobber_canary_build",		land_splash_fx = "ocean_splash_ripple",		oneat_sfx = "dontstarve/common/fishingpole_baitsplash",			casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_CANARY, },
	["oceanfishingbobber_goose"]		= { make_inv_item = true,  bank = "oceanfishing_bobber_ball", build = "oceanfishingbobber_goose_build",			land_splash_fx = "ocean_splash_small",		oneat_sfx = "dontstarve/common/fishingpole_baitsplash",			casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_GOOSE, },
	["oceanfishingbobber_malbatross"]	= { make_inv_item = true,  bank = "oceanfishing_bobber_ball", build = "oceanfishingbobber_malbatross_build",	land_splash_fx = "ocean_splash_small",		oneat_sfx = "dontstarve/common/fishingpole_baitsplash",			casting_data = TUNING.OCEANFISHING_TACKLE.BOBBER_MALBATROSS, },
}

local function SpawnSplashFx(inst)
	if inst.bobber_def.land_splash_fx ~= nil then
		SpawnPrefab(inst.bobber_def.land_splash_fx .. tostring(math.random(2))).Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

function ApplyBobberSkin( nameoverride, skin_build, anim_state, guid )
	if nameoverride ~= "oceanfishingbobber_none" then
		if skin_build ~= nil then
			for _,sym in pairs( { "bobber_01", "bobber_shad", "line_01", "line_loop", "bobberstring2" } ) do
				anim_state:OverrideItemSkinSymbol(sym, skin_build, sym, guid, "oceanfishing_bobber_twig_build") --twig fallback if skin fails
			end
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function OnProjectileLand(inst, caster, target)
	local rod = inst.components.complexprojectile.owningweapon
	if rod ~= nil and rod:IsValid() then
		local x, y, z = inst.Transform:GetWorldPosition()

        local virtualoceanent = FindVirtualOceanEntity(x, y, z)
		if virtualoceanent ~= nil or TheWorld.Map:IsOceanAtPoint(x, y, z) then
			local bobber = SpawnPrefab(inst._floater_prefab)
			bobber.Transform:SetPosition(x, y, z)
			bobber:ForceFacePoint(caster.Transform:GetWorldPosition())

			ApplyBobberSkin( inst.nameoverride, rod.skin_build_name, bobber.AnimState, rod.GUID )

			SpawnSplashFx(bobber)
			bobber.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash")

			bobber.components.oceanfishable:SetRod(rod)
			if bobber.components.oceanfishinghook ~= nil then
				bobber.components.oceanfishinghook:SetLureData(rod.components.oceanfishingrod:GetLureData(), rod.components.oceanfishingrod:GetLureFunctions())
			end

            if virtualoceanent ~= nil then
                virtualoceanent:PushEvent("startfishinginvirtualocean", {fisher = caster, rod = rod,})
            end
		elseif TheWorld.Map:IsPassableAtPoint(x, y, z) then
			rod.components.oceanfishingrod:StopFishing("badcast")

			local bobber = SpawnPrefab(inst._floater_prefab)
			bobber.Transform:SetPosition(x, y, z)
			bobber:ForceFacePoint(caster.Transform:GetWorldPosition())
			bobber:RemoveComponent("oceanfishable")
			bobber:RemoveComponent("oceanfishinghook")
			bobber.AnimState:PlayAnimation("idle")
			bobber.persists = false
			bobber:DoTaskInTime(1, ErodeAway)
		else -- void
			rod.components.oceanfishingrod:StopFishing("badcast")
			SpawnPrefab("splash_ocean").Transform:SetPosition(x, y, z)
		end
	end

    inst:Remove()
end

local function OnSetRod(inst, rod)
	if rod == nil then
		inst:Remove()
	end
end

local function OnEaten(inst)
	SpawnSplashFx(inst)
	if inst.bobber_def ~= nil and inst.bobber_def.oneat_sfx ~= nil then
		inst.SoundEmitter:PlaySound(inst.bobber_def.oneat_sfx)
	end
	inst:Remove()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function projectile_fn(data, name)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics()
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetCapsule(0.2, 0.2)

	inst.Transform:SetTwoFaced()

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build or data.bank)
	inst.AnimState:PlayAnimation("spin_pre", false)
	inst.AnimState:PushAnimation("spin_loop", true)

	inst:SetPrefabNameOverride(name)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	inst._floater_prefab = data.floater_prefab or (name.."_floater")

	inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(OnProjectileLand)

	inst:AddComponent("oceanfishable")
	inst.components.oceanfishable.onsetrodfn = OnSetRod

    return inst
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local function OverrideUnreelRateFn(inst, rod)
	local dir_to_rod = rod:GetPosition() - inst:GetPosition()
	local delta_dist = dir_to_rod:Length() - rod.components.oceanfishingrod.line_dist - 3
	return delta_dist > 0 and delta_dist or 0
end

local function OnWallUpdate(inst, dt)
	local rod = inst.components.oceanfishable:GetRod()
	if rod ~= nil and rod.components.oceanfishingrod ~= nil then
		local vx, vy, vz = inst.Physics:GetVelocity()
		local cur_speed = vx * vx + vz * vz
		cur_speed = cur_speed == 0 and cur_speed or math.sqrt(cur_speed)

		local dir_to_rod = rod:GetPosition() - inst:GetPosition()
		local cur_dist = dir_to_rod:Length()
		dir_to_rod:Normalize()
		local target_dist = rod.components.oceanfishingrod.line_dist
		local delta_dist = cur_dist - target_dist

		if delta_dist > 0.01 then
			if not inst.AnimState:IsCurrentAnimation("reel") then
				inst.AnimState:PlayAnimation("reel", true)
				inst._idle_pushed = false
			end

			-- ? here's some math that kinda works
			local x = (1 + rod.components.oceanfishingrod.line_tension)
			local delta_speed = math.min(TUNING.BOAT.MAX_ALLOWED_VELOCITY * 1.5, delta_dist + x*x - cur_speed )
			if delta_speed > 0 then
				inst.Physics:SetVel(vx + dir_to_rod.x * delta_speed, 0, vz + dir_to_rod.z * delta_speed)
			else
				inst.Physics:SetVel(vx, 0, vz)
			end
		else
			if not inst._idle_pushed and not inst.AnimState:IsCurrentAnimation("idle_loop") then
				inst._idle_pushed = true
				inst.AnimState:PushAnimation("idle_loop", true)
			end
		end
	end
end

local function floater_fn(data, name)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build or data.bank)
    inst.AnimState:PlayAnimation("idle_loop", true)

	inst.Transform:SetSixFaced()

	inst:AddTag("fishinghook") -- for oceanfishinghook

	inst:SetPrefabNameOverride(name)

	if not TheNet:IsDedicated() then
		local ripple_fx = SpawnPrefab("oceanfishinghook_ripple")
		inst:AddChild(ripple_fx)
	    ripple_fx.Transform:SetPosition(0, 0, 0)
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false
	inst.bobber_def = data

    inst:AddComponent("inspectable")

	inst:AddComponent("oceanfishable")
	inst.components.oceanfishable.onsetrodfn = OnSetRod
	inst.components.oceanfishable.oneatenfn = OnEaten
	inst.components.oceanfishable.catch_distance = TUNING.OCEAN_FISHING.STOP_FISHING_HOOK_DIST -- stop fishing dist
	inst.components.oceanfishable.overrideunreelratefn = OverrideUnreelRateFn

	inst:AddComponent("oceanfishinghook")
	inst.components.oceanfishinghook.onwallupdate = OnWallUpdate

    MakeHauntableLaunch(inst)

    return inst
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function item_fn(data, name)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build or data.bank)
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", nil, 0.5)

	inst:AddTag("oceanfishing_bobber")
	inst:AddTag("cattoy")

	inst.scrapbook_specialinfo = "FLOAT"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

	inst:AddComponent("oceanfishingtackle")
	inst.components.oceanfishingtackle:SetCastingData(data.casting_data, data.projectile_prefab or (name.."_projectile"))

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeHauntableLaunch(inst)

    return inst
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local function ripple_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	--[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")
    inst:AddTag("FX")

    inst.AnimState:SetBank("oceanfishing_hook")
    inst.AnimState:SetBuild("oceanfishing_hook")
    inst.AnimState:PlayAnimation("fx_ripple_small", true)

    --inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    --inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)

	inst.persists = false

	return inst
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local ret =
{
	Prefab("oceanfishinghook_ripple", ripple_fn, {Asset("ANIM", "anim/oceanfishing_hook.zip")}),
}

for name, v in pairs(BOBBERS) do
	local assets =
	{
		Asset("ANIM", "anim/"..v.bank..".zip"),
	}
	if v.build ~= nil then
		table.insert(assets, Asset("ANIM", "anim/"..v.build..".zip"))
	end

	local prefabs =
	{
		name.."_projectile",
		name.."_floater",
		"oceanfishinghook_ripple",
		"ocean_splash_med1",
		"ocean_splash_med2",
		"ocean_splash_small1",
		"ocean_splash_small2",
		"ocean_splash_ripple1",
		"ocean_splash_ripple2",
		"splash_ocean",
	}
	if v.make_inv_item then
		table.insert(prefabs, name)
	end

    table.insert(ret, Prefab(name.."_projectile", function() return projectile_fn(v, name) end, assets, prefabs))
    table.insert(ret, Prefab(name.."_floater", function() return floater_fn(v, name) end, assets, prefabs))

	if v.make_inv_item then
	    table.insert(ret, Prefab(name, function() return item_fn(v, name) end, assets, prefabs))
	end
end

return unpack(ret)

