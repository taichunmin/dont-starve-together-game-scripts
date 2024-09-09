local assets =
{
	Asset("ANIM", "anim/flotsam.zip"),
}

local water_prefabs =
{
	"splash",
	"oceanfishableflotsam",
}

local SWIMMING_COLLISION_MASK   = COLLISION.GROUND
								+ COLLISION.LAND_OCEAN_LIMITS
								+ COLLISION.OBSTACLES
								+ COLLISION.SMALLOBSTACLES
local PROJECTILE_COLLISION_MASK = COLLISION.GROUND

local weighted_loot =
{
	kelp			= 35,
	bullkelp_root	= 1,
	cutgrass		= 19,
	twigs			= 15,
	driftwood_log	= 5,
	feather_crow	= 5,
	spoiled_fish	= 5,

	trinket_3		= 0.20,
	trinket_4		= 0.20,
	trinket_5		= 0.20,
	trinket_6		= 0.20,
	trinket_7		= 0.20,
	trinket_8		= 0.20,
	trinket_9		= 0.20,
	trinket_17		= 0.20,
	trinket_22		= 0.20,
	trinket_27		= 0.20,
	-- total trinkets = 10

	oceanfishingbobber_ball = 1,
	oceanfishingbobber_oval = 1,
	oceanfishinglure_spoon_red = 1/3,
	oceanfishinglure_spoon_green = 1/3,
	oceanfishinglure_spoon_blue = 1/3,
	oceanfishinglure_spinner_red = 1/3,
	oceanfishinglure_spinner_green = 1/3,
	oceanfishinglure_spinner_blue = 1/3,

	oceanfishingbobber_crow_tacklesketch = 1.0,
}
local land_prefabs = {}
for k,v in pairs(weighted_loot) do
	table.insert(land_prefabs, k)
end

local NUM_LOOTS = 2

local MAX_CATCH_RADIUS = 1.4

local REEL_SPEED_LOW = 0.5
local REEL_SPEED_HIGH = 2.25

local UNREEL_RATE = .5


local HOOK_CANT_TAGS = { "INLIMBO" }
local HOOK_ONEOF_TAGS = { "fishinghook" }
local function OnUpdate(inst)
	local rod = inst.components.oceanfishable:GetRod()

	if rod == nil then
		local hook = FindEntity(inst, MAX_CATCH_RADIUS, nil, nil, HOOK_CANT_TAGS, HOOK_ONEOF_TAGS)

		if hook ~= nil and hook.components.oceanfishable ~= nil then
			inst.components.oceanfishable:SetRod(hook.components.oceanfishable:GetRod())
		end
	else
		local vx, vy, vz = inst.Physics:GetVelocity()
		local cur_speed = vx * vx + vz * vz
		cur_speed = cur_speed == 0 and cur_speed or math.sqrt(cur_speed)

		local delta = rod:GetPosition() - inst:GetPosition()
		local angle = math.atan2(delta.z, delta.x)

		local tension = rod.components.oceanfishingrod ~= nil and rod.components.oceanfishingrod:GetTensionRating() or 0

		if tension > TUNING.OCEAN_FISHING.LINE_TENSION_HIGH then
			cur_speed = Lerp(REEL_SPEED_LOW, REEL_SPEED_HIGH, math.sin(Remap(tension, TUNING.OCEAN_FISHING.LINE_TENSION_HIGH, 1, 0, 1) * math.pi * .5))
			inst.Physics:SetVel(math.cos(angle) * cur_speed, 0, math.sin(angle) * cur_speed)
		end
	end
end

local function StartUpdating(inst)
	if inst.updatetask ~= nil then
		inst.updatetask:Cancel()
	end
	inst.updatetask = inst:DoPeriodicTask(0, OnUpdate)
end

local function StopUpdating(inst)
	if inst.updatetask ~= nil then
		inst.updatetask:Cancel()
		inst.updatetask = nil
	end
end

local function playlandfx(inst)
	local puddle = SpawnPrefab("flotsam_puddle")
	puddle.entity:SetParent(inst.entity)
	local scale = 1.15
	puddle.Transform:SetScale(scale, scale, scale)
	puddle.Transform:SetRotation(math.random() * 360)
end

local function OnLand(inst)
	local x, y, z = inst.Transform:GetWorldPosition()

	local land_in_water = not TheWorld.Map:IsPassableAtPoint(x, y, z)
	if land_in_water then
		StartUpdating(inst)

	    inst:RemoveComponent("complexprojectile")
		inst.Physics:SetCollisionMask(SWIMMING_COLLISION_MASK)
		inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
		inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)
		inst.AnimState:PlayAnimation("idle_water_loop", true)
	    SpawnPrefab("splash").Transform:SetPosition(x, y, z)
	else
		local item = SpawnPrefab("oceanfishableflotsam")
		item.Transform:SetPosition(x, y, z)
		item.Transform:SetRotation(inst.Transform:GetRotation())

		item:DoTaskInTime(2*FRAMES, playlandfx)

	    inst:Remove()
	end
end

local function OnMakeProjectile(inst)
	StopUpdating(inst)

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(OnLand)

	inst.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)

    inst.AnimState:SetSortOrder(0)
    inst.AnimState:SetLayer(LAYER_WORLD)

	inst.AnimState:PlayAnimation("catching_pre")
	inst.AnimState:PushAnimation("catching_loop", true)

    SpawnPrefab("splash").Transform:SetPosition(inst.Transform:GetWorldPosition())

	return inst
end

local function OnReelingIn(inst, doer)
	SpawnPrefab("splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnReelingInPst(inst, doer)
	local rod = inst.components.oceanfishable:GetRod()
	if rod == nil or (rod.components.oceanfishingrod ~= nil and not rod.components.oceanfishingrod:IsLineTensionHigh()) then
		inst.AnimState:PlayAnimation("struggle_pre")
		inst.AnimState:PushAnimation("struggle_loop")
		inst.AnimState:PushAnimation("struggle_pst")
		inst.AnimState:PushAnimation("idle_water_loop", true)
	end
end

local function OverrideUnreelRateFn(inst, rod)
	return UNREEL_RATE
end

local function OnSetRod(inst, rod)
	if rod ~= nil then
		inst:AddTag("scarytooceanprey")
	else
		inst:RemoveTag("scarytooceanprey")
	end

	SpawnPrefab("splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnPicked(inst, picker)
    local x, y, z = inst.Transform:GetWorldPosition()

	for i=1,NUM_LOOTS do
		local loot = weighted_random_choice(weighted_loot)
		SpawnPrefab(loot).Transform:SetPosition(x, y, z)
	end
	if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and math.random() < TUNING.HALLOWEEN_ORNAMENT_FLOTSAM_CHANCE then
		SpawnPrefab("halloween_ornament_"..tostring(math.random(NUM_HALLOWEEN_ORNAMENTS))).Transform:SetPosition(x, y, z)
	end

    SpawnPrefab("flotsam_break").Transform:SetPosition(x, y, z)
	return true --This makes the inventoryitem component not actually give the flotsam to the player
end

local function overrideflotsamsinkfn(inst)
	if inst.entity:IsAwake() then
		inst.AnimState:PlayAnimation("dissappear")
		inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), function(inst) inst:Remove() end)
	else
		inst:Remove()
	end
end

local function OnSalvage(inst)
	local product = SpawnPrefab("oceanfishableflotsam")
	product.Transform:SetPosition(inst.Transform:GetWorldPosition())
	return product
end

local function OnEntityWake(inst)
	StartUpdating(inst)
end

local function OnEntitySleep(inst)
	StopUpdating(inst)
end

local function waterfn(data)
   local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddPhysics()

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0.16)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:SetCollisionMask(SWIMMING_COLLISION_MASK)
    inst.Physics:SetCapsule(0.5, 1)

    inst:AddTag("ignorewalkableplatforms")
	inst:AddTag("notarget")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")-- it's fine to build things on top of them
	inst:AddTag("oceanfishable")
	inst:AddTag("oceanfishinghookable")
	inst:AddTag("swimming")
	inst:AddTag("winchtarget")--from winchtarget component

    inst.AnimState:SetBank("flotsam")
    inst.AnimState:SetBuild("flotsam")
    inst.AnimState:PlayAnimation("idle_water_loop", true)

    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
    inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("oceanfishable")
	inst.components.oceanfishable.makeprojectilefn = OnMakeProjectile
	inst.components.oceanfishable.onreelinginfn = OnReelingIn
	inst.components.oceanfishable.onreelinginpstfn = OnReelingInPst
	inst.components.oceanfishable.onsetrodfn = OnSetRod
	inst.components.oceanfishable.overrideunreelratefn = OverrideUnreelRateFn
	inst.components.oceanfishable.catch_distance = TUNING.OCEAN_FISHING.MUDBALL_CATCH_DIST

    inst:AddComponent("winchtarget")
	inst.components.winchtarget:SetSalvageFn(OnSalvage)
	inst.components.winchtarget.depth = 2

	-- Overrides default sink behavior defined in flotsamgenerator
	inst.overrideflotsamsinkfn = overrideflotsamsinkfn

	inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

	StartUpdating(inst)

    return inst
end

local function OnSink(inst)
	SpawnPrefab("oceanfishableflotsam_water").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
end

local function OnLanded(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, y, z, false) then
		inst:PushEvent("onsink")
	end
end

local function landfn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("flotsam")
    inst.AnimState:SetBuild("flotsam")
    inst.AnimState:PlayAnimation("catching_pst")
	inst.AnimState:PushAnimation("idle_land")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup = false
	inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem.canonlygoinpocket = true -- Without this, the player's inventory tries to make this its active item when removed from a winch.

	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "hookline/common/ocean_flotsam/picked"
	inst.components.pickable.onpickedfn = OnPicked
	inst.components.pickable.remove_when_picked = true
	inst.components.pickable.canbepicked = true

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable("oceanfishableflotsam")

	inst:AddComponent("symbolswapdata")
	inst.components.symbolswapdata:SetData("flotsam", "swap_body")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
            OnPicked(inst, nil)
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
        end
        return true
	end)

	inst:ListenForEvent("onsink", OnSink)
	inst:ListenForEvent("on_landed", OnLanded)

    return inst
end

return Prefab("oceanfishableflotsam_water", waterfn, assets, water_prefabs),
	Prefab("oceanfishableflotsam", landfn, assets, land_prefabs)