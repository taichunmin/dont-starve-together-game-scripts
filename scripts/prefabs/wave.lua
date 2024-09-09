local waveassets =
{
	Asset( "ANIM", "anim/wave.zip" ),
}

local splashassets =
{
    Asset( "ANIM", "anim/splash_water_rot.zip" ),
}

local prefabs =
{
    "wave_splash",
}

local SPLASH_WETNESS = 9

local function DoSplash(inst)
    local wave_splash = SpawnPrefab("wave_splash")
    local pos = inst:GetPosition()
    TintByOceanTile(wave_splash)
    wave_splash.Transform:SetPosition(pos.x, pos.y, pos.z)
    wave_splash.Transform:SetRotation(inst.Transform:GetRotation())

    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 4)
    for _, v in pairs(ents) do
        local moisture = v.components.moisture
        if moisture ~= nil then
            local waterproofness = moisture:GetWaterproofness()
            moisture:DoDelta(SPLASH_WETNESS * (1 - waterproofness))

            local entity_splash = SpawnPrefab("splash")
            entity_splash.Transform:SetPosition(v:GetPosition():Get())
        end
    end

    inst:Remove()
end

local function oncollidewave(inst, other)
    if other and (inst.waveactive or not other:HasTag("wave")) then
        if other.components.boatphysics and inst.waveactive then
            local vx, vy, vz = inst.Physics:GetVelocity()
            local norm_x, norm_z, length = VecUtil_NormalAndLength(vx, vz)
            other.components.boatphysics:ApplyForce(norm_x, norm_z, length * 0.5)
        end

        DoSplash(inst)
    end
end

local function CheckGround(inst)
    --Check if I'm about to hit land
    local x, y, z = inst.Transform:GetWorldPosition()
    local vx, vy, vz = inst.Physics:GetVelocity()

    if TheWorld.Map:IsVisualGroundAtPoint(x + vx, y, z + vz) then
        DoSplash(inst)
    end
end

local function launch_in_direction(thing_to_launch, vx, vz)
    if thing_to_launch ~= nil and thing_to_launch.Physics ~= nil and thing_to_launch.Physics:IsActive() then
        thing_to_launch.Physics:SetVel(vx, 0, vz)
    end
end

local NO_PUSH_TAGS = {"INLIMBO", "outofreach", "smallcreature"}
local PICKUP_TAGS = {"_inventoryitem", "kelp"}
local function CheckForItems(inst)
    if not inst.waveactive then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local vx, vy, vz = inst.Physics:GetVelocity()

    local nearby_inventory_entities = TheSim:FindEntities(
        x, y, z,
        2,
        nil,
        NO_PUSH_TAGS,
        PICKUP_TAGS
    )
    if #nearby_inventory_entities > 0 then
        for i, ent in ipairs(nearby_inventory_entities) do
            launch_in_direction(ent, vx, vz)
        end
    end
end

local function OnRemoveEntity(inst)
    inst.SoundEmitter:KillSound("wave")
end

local function med_fn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBuild("wave")
    inst.AnimState:SetBank("wave_ripple")

    TintByOceanTile(inst)

    local phys = inst.entity:AddPhysics()
    phys:SetSphere(1)
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCollides(false) --Still will get collision callback, just not dynamic collisions.

    inst:AddTag("scarytoprey")
    inst:AddTag("wave")
    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst:AddComponent("boattrail")
        inst.components.boattrail.effect_spawn_rate = 2.5
        inst.components.boattrail.radius = 1
        inst.components.boattrail.scale_x = 0.75
        inst.components.boattrail.scale_z = 0.75
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    inst:DoPeriodicTask(0.5, CheckGround)
    inst:DoPeriodicTask(10*FRAMES, CheckForItems, 0)

    inst.OnEntitySleep = inst.Remove

    inst.Physics:SetCollisionCallback(oncollidewave)
    inst.waveactive = false

    inst:SetStateGraph("SGwave")

    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/wave/LP", "wave")
    inst.SoundEmitter:SetParameter("wave", "size", 0.5)

    inst.OnRemoveEntity = OnRemoveEntity

    inst.DoSplash = DoSplash

    return inst
end

local function wavesplash_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("splash_water_rot")
    inst.AnimState:SetBank("splash_water_rot")
    inst.AnimState:PlayAnimation("burst")

	inst.Transform:SetScale(0.7, 0.7, 0.7)
    inst.Transform:SetFourFaced()

    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
		inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small", nil, nil, true)
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    inst.AnimState:SetTime(math.random() / 3)

    inst:ListenForEvent("animover", inst.Remove)
	inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 0.1, inst.Remove)

    return inst
end

return Prefab( "wave_med", med_fn, waveassets, prefabs ),
       Prefab( "wave_splash", wavesplash_fn, splashassets)
