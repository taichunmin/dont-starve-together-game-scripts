local WAXED_PLANTS = require "prefabs/waxed_plant_common"

local DEBUG_MODE = BRANCH == "dev"

function DefaultIgniteFn(inst)
    if inst.components.burnable ~= nil then
        inst.components.burnable:StartWildfire()
    end
end

function DefaultBurnFn(inst)
    if not (inst:HasTag("tree") or inst:HasTag("structure")) then
        inst.persists = false
    end
end

function DefaultBurntFn(inst)
    if inst.components.growable ~= nil then
        inst:RemoveComponent("growable")
    end

    if inst.inventoryitemdata ~= nil then
        inst.inventoryitemdata = nil
    end

    if inst.components.workable ~= nil and inst.components.workable.action ~= ACTIONS.HAMMER then
        inst.components.workable:SetWorkLeft(0)
    end

    local my_x, my_y, my_z = inst.Transform:GetWorldPosition()

    -- Spawn ash everywhere except on the ocean
    if not TheWorld.Map:IsOceanAtPoint(my_x, my_y, my_z, false) then
        local ash = SpawnPrefab("ash")
        ash.Transform:SetPosition(inst.Transform:GetWorldPosition())

        if inst.components.stackable ~= nil then
			ash.components.stackable:SetStackSize(math.min(ash.components.stackable.maxsize, inst.components.stackable.stacksize))
        end
    end

    inst:Remove()
end

function DefaultExtinguishFn(inst)
    if not (inst:HasTag("tree") or inst:HasTag("structure")) then
        inst.persists = true
    end
end

function DefaultBurntStructureFn(inst)
    inst:AddTag("burnt")
    inst.components.burnable.canlight = false
    if inst.AnimState then
        inst.AnimState:PlayAnimation("burnt", true)
    end
    inst:PushEvent("burntup")
    if inst.SoundEmitter then
        inst.SoundEmitter:KillSound("idlesound")
        inst.SoundEmitter:KillSound("sound")
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:KillSound("snd")
    end
    if inst.MiniMapEntity then
        inst.MiniMapEntity:SetEnabled(false)
    end
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.components.childspawner then
        if inst:GetTimeAlive() > 5 then inst.components.childspawner:ReleaseAllChildren() end
        inst.components.childspawner:StopSpawning()
        inst:RemoveComponent("childspawner")
    end
    if inst.components.container then
        inst.components.container:DropEverything()
        inst.components.container:Close()
        inst:RemoveComponent("container")
    end
    if inst.components.dryer then
        inst.components.dryer:StopDrying("fire")
        inst:RemoveComponent("dryer")
    end
    if inst.components.stewer then
        inst.components.stewer:StopCooking("fire")
        inst:RemoveComponent("stewer")
    end
    if inst.components.harvestable then
        inst.components.harvestable:StopGrowing()
        inst:RemoveComponent("harvestable")
    end
    if inst.components.sleepingbag then
        inst:RemoveComponent("sleepingbag")
    end
    if inst.components.grower then
        inst.components.grower:Reset("fire")
        inst:RemoveComponent("grower")
    end
    if inst.components.spawner ~= nil then
        if inst:GetTimeAlive() > 5 and inst.components.spawner:IsOccupied() then
            inst.components.spawner:ReleaseChild()
        end
        inst:RemoveComponent("spawner")
    end
    if inst.components.prototyper ~= nil then
        inst:RemoveComponent("prototyper")
    end
    if inst.components.wardrobe ~= nil then
        inst:RemoveComponent("wardrobe")
    end
	if inst.components.constructionsite ~= nil then
		inst.components.constructionsite:DropAllMaterials()
		inst:RemoveComponent("constructionsite")
	end
	if inst.components.inventoryitemholder ~= nil then
		inst.components.inventoryitemholder:TakeItem()
		inst:RemoveComponent("inventoryitemholder")
	end
    if inst.Light then
        inst.Light:Enable(false)
    end
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
end

function DefaultBurntCorpseFn(inst)
	if not inst.components.burnable.nocharring then
		inst.AnimState:SetMultColour(.2, .2, .2, 1)
	end
	inst.components.burnable.fastextinguish = true
	inst:AddTag("NOCLICK")
	inst.persists = false
	ErodeAway(inst)
end

function DefaultExtinguishCorpseFn(inst)
	--NOTE: nil check burnable in case we reach here via removing burnable component
	if inst.persists and inst.components.burnable ~= nil then
		if not inst.components.burnable.nocharring then
			inst.AnimState:SetMultColour(.2, .2, .2, 1)
		end
		inst:AddTag("NOCLICK")
		inst.persists = false
		if inst.components.burnable.fastextinguish then
			ErodeAway(inst)
		else
			inst:DoTaskInTime(0.5 + math.random() * 0.5, ErodeAway)
		end
	end
end

local burnfx =
{
    character = "character_fire",
    generic = "fire",
}

function MakeSmallBurnable(inst, time, offset, structure, sym)
    local burnable = inst:AddComponent("burnable")
    burnable:SetFXLevel(2)
    burnable:SetBurnTime(time or 10)
    burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0), sym )
    burnable:SetOnIgniteFn(DefaultBurnFn)
    burnable:SetOnExtinguishFn(DefaultExtinguishFn)
    burnable:SetOnBurntFn((structure and DefaultBurntStructureFn) or DefaultBurntFn)

    return burnable
end

function MakeMediumBurnable(inst, time, offset, structure, sym)
    local burnable = inst:AddComponent("burnable")
    burnable:SetFXLevel(3)
    burnable:SetBurnTime(time or 20)
    burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0), sym )
    burnable:SetOnIgniteFn(DefaultBurnFn)
    burnable:SetOnExtinguishFn(DefaultExtinguishFn)
    burnable:SetOnBurntFn((structure and DefaultBurntStructureFn) or DefaultBurntFn)

    return burnable
end

function MakeLargeBurnable(inst, time, offset, structure, sym)
    local burnable = inst:AddComponent("burnable")
    burnable:SetFXLevel(4)
    burnable:SetBurnTime(time or 30)
    burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0), sym )
    burnable:SetOnIgniteFn(DefaultBurnFn)
    burnable:SetOnExtinguishFn(DefaultExtinguishFn)
    burnable:SetOnBurntFn((structure and DefaultBurntStructureFn) or DefaultBurntFn)

    return burnable
end

function MakeSmallPropagator(inst)
    local propagator = inst:AddComponent("propagator")
    propagator.acceptsheat = true
    propagator:SetOnFlashPoint(DefaultIgniteFn)
    propagator.flashpoint = 5 + math.random()*5
    propagator.decayrate = 0.5
    propagator.propagaterange = 3 + math.random()*2
    propagator.heatoutput = 3 + math.random()*2--8

    propagator.damagerange = 2
    propagator.damages = true

    return propagator
end

function MakeMediumPropagator(inst)
    local propagator = inst:AddComponent("propagator")
    propagator.acceptsheat = true
    propagator:SetOnFlashPoint(DefaultIgniteFn)
    propagator.flashpoint = 15+math.random()*10
    propagator.decayrate = 0.5
    propagator.propagaterange = 5 + math.random()*2
    propagator.heatoutput = 5 + math.random()*3.5--12

    propagator.damagerange = 3
    propagator.damages = true

    return propagator
end

function MakeLargePropagator(inst)
    local propagator = inst:AddComponent("propagator")
    propagator.acceptsheat = true
    propagator:SetOnFlashPoint(DefaultIgniteFn)
    propagator.flashpoint = 45+math.random()*10
    propagator.decayrate = 0.5
    propagator.propagaterange = 6 + math.random()*2
    propagator.heatoutput = 6 + math.random()*3.5--12

    propagator.damagerange = 3
    propagator.damages = true

    return propagator
end

function MakeSmallBurnableCharacter(inst, sym, offset)
    local burnable = inst:AddComponent("burnable")
    burnable:SetFXLevel(1)
    burnable:SetBurnTime(6)
    burnable.canlight = false
    burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym)

    local propagator = MakeSmallPropagator(inst)
    propagator.acceptsheat = false

    return burnable, propagator
end

function MakeMediumBurnableCharacter(inst, sym, offset)
    local burnable = inst:AddComponent("burnable")
    burnable:SetFXLevel(2)
    burnable.canlight = false
    burnable:SetBurnTime(8)
    burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym)

    local propagator = MakeSmallPropagator(inst)
    propagator.acceptsheat = false

    return burnable, propagator
end

function MakeLargeBurnableCharacter(inst, sym, offset, scale)
    local burnable = inst:AddComponent("burnable")
    burnable:SetFXLevel(3)
    burnable.canlight = false
    burnable:SetBurnTime(10)
    burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym, nil, scale)

    local propagator = MakeLargePropagator(inst)
    propagator.acceptsheat = false

    return burnable, propagator
end

function MakeSmallBurnableCorpse(inst, time, sym, offset, scale)
	local burnable = inst:AddComponent("burnable")
	burnable:SetFXLevel(1)
	burnable:SetBurnTime(time or 6)
	burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym, nil, scale)
	burnable:SetOnExtinguishFn(DefaultExtinguishCorpseFn)
	burnable:SetOnBurntFn(DefaultBurntCorpseFn)

	local propagator = MakeSmallPropagator(inst)

	return burnable, propagator
end

function MakeMediumBurnableCorpse(inst, time, sym, offset, scale)
	local burnable = inst:AddComponent("burnable")
	burnable:SetFXLevel(2)
	burnable:SetBurnTime(time or 8)
	burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym, nil, scale)
	burnable:SetOnExtinguishFn(DefaultExtinguishCorpseFn)
	burnable:SetOnBurntFn(DefaultBurntCorpseFn)

	local propagator = MakeSmallPropagator(inst)

	return burnable, propagator
end

function MakeLargeBurnableCorpse(inst, time, sym, offset, scale)
	local burnable = inst:AddComponent("burnable")
	burnable:SetFXLevel(3)
	burnable:SetBurnTime(time or 10)
	burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym, nil, scale)
	burnable:SetOnExtinguishFn(DefaultExtinguishCorpseFn)
	burnable:SetOnBurntFn(DefaultBurntCorpseFn)

	local propagator = MakeMediumPropagator(inst)

	return burnable, propagator
end

local shatterfx =
{
    character = "shatter",
}

function MakeTinyFreezableCharacter(inst, sym, offset)
    local freezable = inst:AddComponent("freezable")
    freezable:SetShatterFXLevel(1)
    freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)

    return freezable
end

function MakeSmallFreezableCharacter(inst, sym, offset)
    local freezable = inst:AddComponent("freezable")
    freezable:SetShatterFXLevel(2)
    freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)

    return freezable
end

function MakeMediumFreezableCharacter(inst, sym, offset)
    local freezable = inst:AddComponent("freezable")
    freezable:SetShatterFXLevel(3)
    freezable:SetResistance(2)
    freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)

    return freezable
end

function MakeLargeFreezableCharacter(inst, sym, offset)
    local freezable = inst:AddComponent("freezable")
    freezable:SetShatterFXLevel(4)
    freezable:SetResistance(3)
    freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)

    return freezable
end

function MakeHugeFreezableCharacter(inst, sym, offset)
    local freezable = inst:AddComponent("freezable")
    freezable:SetShatterFXLevel(5)
    freezable:SetResistance(4)
    freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)

    return freezable
end

function MakeInventoryPhysics(inst, mass, rad)
    mass = mass or 1
    rad = rad or .5
	local phys = inst.entity:AddPhysics()
	phys:SetMass(mass)
	phys:SetFriction(.1)
	phys:SetDamping(0)
	phys:SetRestitution(.5)
	phys:SetCollisionGroup(COLLISION.ITEMS)
	phys:ClearCollisionMask()
	phys:CollidesWith(COLLISION.WORLD)
	phys:CollidesWith(COLLISION.OBSTACLES)
	phys:CollidesWith(COLLISION.SMALLOBSTACLES)
	phys:SetSphere(rad)
    return phys
end

function MakeProjectilePhysics(inst, mass, rad)
    mass = mass or 1
    rad = rad or .5
	local phys = inst.entity:AddPhysics()
	phys:SetMass(mass)
	phys:SetFriction(.1)
	phys:SetDamping(0)
	phys:SetRestitution(.5)
	phys:SetCollisionGroup(COLLISION.ITEMS)
	phys:ClearCollisionMask()
	phys:CollidesWith(COLLISION.GROUND)
	phys:SetSphere(rad)
    return phys
end

function MakeCharacterPhysics(inst, mass, rad)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.CHARACTERS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCapsule(rad, 1)
    return phys
end

function MakeFlyingCharacterPhysics(inst, mass, rad)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    phys:CollidesWith(COLLISION.FLYERS)
    phys:SetCapsule(rad, 1)
    return phys
end

function MakeTinyFlyingCharacterPhysics(inst, mass, rad)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    phys:SetCapsule(rad, 1)
    return phys
end

function MakeGiantCharacterPhysics(inst, mass, rad)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.GIANTS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCapsule(rad, 1)
    return phys
end

function MakeFlyingGiantCharacterPhysics(inst, mass, rad)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.GIANTS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    --phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCapsule(rad, 1)
    return phys
end

function MakeGhostPhysics(inst, mass, rad)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.CHARACTERS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    --phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCapsule(rad, 1)
    return phys
end

function MakeTinyGhostPhysics(inst, mass, rad)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.CHARACTERS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    phys:SetCapsule(rad, 1)
    return phys
end

function ChangeToGhostPhysics(inst)
    local phys = inst.Physics
    phys:SetCollisionGroup(COLLISION.CHARACTERS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    --phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    return phys
end

function ChangeToCharacterPhysics(inst, mass, rad)
    local phys = inst.Physics
    if mass then
        phys:SetMass(mass)
        phys:SetFriction(0)
        phys:SetDamping(5)
    end
    phys:SetCollisionGroup(COLLISION.CHARACTERS)
	phys:SetCollisionMask(COLLISION.WORLD, COLLISION.OBSTACLES, COLLISION.SMALLOBSTACLES, COLLISION.CHARACTERS, COLLISION.GIANTS)
    if rad then
        phys:SetCapsule(rad, 1)
    end
    return phys
end

function ChangeToGiantCharacterPhysics(inst, mass, rad)
	local phys = inst.Physics
	if mass then
		phys:SetMass(mass)
		phys:SetFriction(0)
		phys:SetDamping(5)
	end
	phys:SetCollisionGroup(COLLISION.GIANTS)
	phys:ClearCollisionMask()
	phys:CollidesWith(COLLISION.WORLD)
	phys:CollidesWith(COLLISION.OBSTACLES)
	phys:CollidesWith(COLLISION.CHARACTERS)
	phys:CollidesWith(COLLISION.GIANTS)
	if rad then
		phys:SetCapsule(rad, 1)
	end
end

function ChangeToObstaclePhysics(inst, rad, height)
    local phys = inst.Physics
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:SetMass(0)
    --phys:CollidesWith(COLLISION.GROUND)
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    if rad then
        phys:SetCapsule(rad, height or 2)
    end
    return phys
end

function ChangeToWaterObstaclePhysics(inst)
    local phys = ChangeToObstaclePhysics(inst)
    phys:CollidesWith(COLLISION.OBSTACLES)
    return phys
end

function ChangeToInventoryItemPhysics(inst, mass, rad)
    local phys = inst.Physics
    if mass then
        phys:SetMass(mass)
        phys:SetFriction(.1)
        phys:SetDamping(0)
        phys:SetRestitution(.5)
    end    
    phys:SetCollisionGroup(COLLISION.ITEMS)
    phys:SetCollisionMask(COLLISION.WORLD, COLLISION.OBSTACLES, COLLISION.SMALLOBSTACLES)
    if rad then
        phys:SetSphere(rad, 1)
    end    
    return phys
end

-- USED FOR THE DEPTH WORM
function ChangeToInventoryPhysics(inst)
    local phys = inst.Physics
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    return phys
end

function MakeObstaclePhysics(inst, rad, height)
    inst:AddTag("blocker")
    local phys = inst.entity:AddPhysics()
    phys:SetMass(0) --Bullet wants 0 mass for static objects
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCapsule(rad, height or 2)
    return phys
end

function MakeWaterObstaclePhysics(inst, rad, height, restitution)
    inst:AddTag("blocker")
    local phys = inst.entity:AddPhysics()
    phys:SetMass(0) --Bullet wants 0 mass for static objects
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:SetCapsule(rad, height)

    inst:AddComponent("waterphysics")
    inst.components.waterphysics.restitution = restitution

    return phys
end

function MakeSmallObstaclePhysics(inst, rad, height)
    inst:AddTag("blocker")
    local phys = inst.entity:AddPhysics()
    phys:SetMass(0) --Bullet wants 0 mass for static objects
    phys:SetCollisionGroup(COLLISION.SMALLOBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:SetCapsule(rad, height or 2)
    return phys
end

--Heavy obstacles can be heavy lifted, changing to inventoryitem.
--Use this by pairing it with the heavyobstaclephysics component.
function MakeHeavyObstaclePhysics(inst, rad, height)
    inst:AddTag("blocker")
    local phys = inst.entity:AddPhysics()
    --inventory physics
    phys:SetFriction(.1)
    phys:SetDamping(0)
    phys:SetRestitution(0)
    --obstacle physics
    phys:SetMass(0)
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCapsule(rad, height or 2)
    return phys
end

--Heavy obstacles can be heavy lifted, changing to inventoryitem.
--Use this by pairing it with the heavyobstaclephysics component.
function MakeSmallHeavyObstaclePhysics(inst, rad, height)
    inst:AddTag("blocker")
    local phys = inst.entity:AddPhysics()
    --inventory physics
    phys:SetFriction(.1)
    phys:SetDamping(0)
    phys:SetRestitution(0)
    --obstacle physics
    phys:SetMass(0)
    phys:SetCollisionGroup(COLLISION.SMALLOBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:SetCapsule(rad, height or 2)
    return phys
end

function MakePondPhysics(inst, rad, height)
	inst:AddTag("blocker")
	local phys = inst.entity:AddPhysics()
	phys:SetMass(0) --Bullet wants 0 mass for static objects
	phys:SetCollisionGroup(COLLISION.OBSTACLES)
	phys:ClearCollisionMask()
	phys:CollidesWith(COLLISION.ITEMS)
	phys:CollidesWith(COLLISION.CHARACTERS)
	phys:CollidesWith(COLLISION.GIANTS)
	phys:SetCapsule(rad, height or 2)
	return phys
end

function RemovePhysicsColliders(inst)
    local physics = inst.Physics
    if not physics then
        return
    end
    physics:ClearCollisionMask()
    if physics:GetMass() > 0 then
        physics:CollidesWith(COLLISION.GROUND)
    end
end

local function TogglePickable(pickable, iswinter)
    if iswinter then
        pickable:Pause()
    else
        pickable:Resume()
    end
end

function MakeNoGrowInWinter(inst)
    inst.components.pickable:WatchWorldState("iswinter", TogglePickable)
    TogglePickable(inst.components.pickable, TheWorld.state.iswinter)
end

function MakeSnowCoveredPristine(inst)
    inst.AnimState:OverrideSymbol("snow", "snow", "snow")
    inst:AddTag("SnowCovered")

    inst.AnimState:Hide("snow")
end

function MakeSnowCovered(inst)
    if not inst:HasTag("SnowCovered") then
        MakeSnowCoveredPristine(inst)
    end

    if TheWorld.state.issnowcovered then
        inst.AnimState:Show("snow")
    else
        inst.AnimState:Hide("snow")
    end
end

----------------------------------------------------------------------------------------
local function oneat(inst)
    if inst.components.perishable ~= nil then
        inst.components.perishable:SetPercent(1)
    end
end

local function onperish(inst)
    local owner = inst.components.inventoryitem.owner
    if owner ~= nil then
		local loots
        local container = owner.components.inventory or owner.components.container or nil
        if container ~= nil and inst.components.lootdropper ~= nil then
            local stacksize = inst.components.stackable ~= nil and inst.components.stackable.stacksize or 1
            if inst.components.health ~= nil then
                owner:PushEvent("murdered", { victim = inst, stackmult = stacksize, negligent = true }) -- NOTES(JBK): This is a special case event already adding onto it.
            end
			loots = {}
			local loots_stackable = {}
            for i = 1, stacksize do
				for i, v in ipairs(inst.components.lootdropper:GenerateLoot()) do
					local stackable = loots_stackable[v]
					if stackable then
						if stackable:IsFull() then
							stackable:SetIgnoreMaxSize(true)
						end
						stackable:SetStackSize(stackable:StackSize() + 1)
					else
						local loot = SpawnPrefab(v)
						loots_stackable[v] = loot.components.stackable
						table.insert(loots, loot)
					end
                end
            end
        end

        inst:Remove()

		if loots then
			for i, v in ipairs(loots) do
				container:GiveItem(v)
			end
		end
    end
end

function MakeSmallPerishableCreaturePristine(inst)
    inst:AddTag("show_spoilage")
end

function MakeSmallPerishableCreature(inst, starvetime, oninventory, ondropped)
    MakeSmallPerishableCreaturePristine(inst)

    --We want to see the warnings for duplicating perishable
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(starvetime)
    inst.components.perishable:StopPerishing()
    inst.components.perishable:SetOnPerishFn(onperish)

    inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst, owner)
        inst.components.perishable:StartPerishing()
        if oninventory ~= nil then
            oninventory(inst, owner)
        end
    end)

    inst.components.inventoryitem:SetOnDroppedFn(function(inst)
        inst.components.perishable:StopPerishing()
        if ondropped ~= nil then
            ondropped(inst)
        end
    end)
end

function MakeFeedableSmallLivestockPristine(inst)
    MakeSmallPerishableCreaturePristine(inst)
    inst:AddTag("small_livestock")
end

function MakeFeedableSmallLivestock(inst, starvetime, oninventory, ondropped)
    MakeFeedableSmallLivestockPristine(inst)

    --This is acceptable.  Some eaters are added already to specify diets.
    if inst.components.eater == nil then
        inst:AddComponent("eater")
    end
    inst.components.eater:SetOnEatFn(oneat)

    MakeSmallPerishableCreature(inst, starvetime, oninventory, ondropped)
end

--Backward compatibility for mods
--The old "pets" are now "livestock", since
--DST will have an actual player pet system
MakeFeedablePetPristine = MakeFeedableSmallLivestockPristine
MakeFeedablePet = MakeFeedableSmallLivestock

--Backward compatibility for mods
--Dragonfly bait is not used in DST
function MakeDragonflyBait() end
MaybeMakeDragonflyBait = MakeDragonflyBait
RemoveDragonflyBait = MakeDragonflyBait

function MakeHauntable(inst, cooldown, haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
	inst.components.hauntable:SetHauntValue(haunt_value or TUNING.HAUNT_TINY)
end

function MakeHauntableLaunch(inst, chance, speed, cooldown, haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        chance = chance or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= chance then
            Launch(inst, haunter, speed or TUNING.LAUNCH_SPEED_SMALL)
            inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_TINY

			if inst.components.inventoryitem ~= nil and inst.components.inventoryitem.is_landed then
				inst.components.inventoryitem:SetLanded(false, true)
			end
            return true
        end
        return false
    end)
end

function MakeHauntableLaunchAndSmash(inst, launch_chance, smash_chance, speed, cooldown, launch_haunt_value, smash_haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        launch_chance = launch_chance or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= launch_chance then
            Launch(inst, haunter, speed or TUNING.LAUNCH_SPEED_SMALL)
            inst.components.hauntable.hauntvalue = launch_haunt_value or TUNING.HAUNT_TINY

			if inst.components.inventoryitem ~= nil and inst.components.inventoryitem.is_landed then
				inst.components.inventoryitem:SetLanded(false, true)
			end

            --#HAUNTFIX
            --smash_chance = smash_chance or TUNING.HAUNT_CHANCE_OCCASIONAL
            --if math.random() < smash_chance then
                --inst.components.hauntable.hauntvalue = smash_haunt_value or TUNING.HAUNT_SMALL
                --inst.smashtask = inst:DoPeriodicTask(.1, function(inst)
                    --local pt = Point(inst.Transform:GetWorldPosition())
                    --if pt.y <= .2 then
                        --inst.SoundEmitter:PlaySound("dontstarve/common/stone_drop")
                        --local pt = Vector3(inst.Transform:GetWorldPosition())
                        --local breaking = SpawnPrefab("ground_chunks_breaking") --spawn break effect
                        --breaking.Transform:SetPosition(pt.x, 0, pt.z)
                        --inst:Remove()
                        --inst.smashtask:Cancel()
                        --inst.smashtask = nil
                    --end
                --end)
            --end
            return true
        end
        return false
    end)
end

function MakeHauntableWork(inst, chance, cooldown, haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        --#HAUNTFIX
        --chance = chance or TUNING.HAUNT_CHANCE_OFTEN
        --if math.random() <= chance then
            --if inst.components.workable ~= nil and inst.components.workable:CanBeWorked() then
                --inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_SMALL
                --inst.components.workable:WorkedBy(haunter, 1)
                --return true
            --end
        --end
        return false
    end)
end

function MakeHauntableWorkAndIgnite(inst, work_chance, ignite_chance, cooldown, work_haunt_value, ignite_haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        local ret = false

        --#HAUNTFIX
        --work_chance = work_chance or TUNING.HAUNT_CHANCE_OFTEN
        --if math.random() <= work_chance then
            --if inst.components.workable ~= nil and inst.components.workable:CanBeWorked() then
                --inst.components.hauntable.hauntvalue = work_haunt_value or TUNING.HAUNT_SMALL
                --inst.components.workable:WorkedBy(haunter, 1)
                --ret = true
            --end
        --end

        --#HAUNTFIX
        --ignite_chance = ignite_chance or TUNING.HAUNT_CHANCE_SUPERRARE
        --if math.random() <= ignite_chance then
            --if inst.components.burnable and not inst.components.burnable:IsBurning() then
                --inst.components.burnable:Ignite()
                --inst.components.hauntable.hauntvalue = ignite_haunt_value or TUNING.HAUNT_MEDLARGE
                --inst.components.hauntable.cooldown_on_successful_haunt = false
                --ret = true
            --end
        --end

        return ret
    end)
end

function MakeHauntableFreeze(inst, chance, cooldown, haunt_value)
    if inst.components.hauntable == nil then
        inst:AddComponent("hauntable")
    end
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
        if inst.components.freezable ~= nil and
            not inst.components.freezable:IsFrozen() and
            math.random() <= (chance or TUNING.HAUNT_CHANCE_HALF) then
            inst.components.freezable:AddColdness(math.max(1, inst.components.freezable:ResolveResistance() - inst.components.freezable.coldness + 1))
            inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_MEDIUM
            inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_HUGE
            return true
        end
        return false
    end)
end

function MakeHauntableIgnite(inst, chance, cooldown, haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        --#HAUNTFIX
        --chance = chance or TUNING.HAUNT_CHANCE_VERYRARE
        --if math.random() <= chance then
            --if inst.components.burnable and not inst.components.burnable:IsBurning() then
                --inst.components.burnable:Ignite()
                --inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_LARGE
                --inst.components.hauntable.cooldown_on_successful_haunt = false
                --return true
            --end
        --end
        return false
    end)
end

function MakeHauntableLaunchAndIgnite(inst, launchchance, ignitechance, speed, cooldown, launch_haunt_value, ignite_haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        launchchance = launchchance or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= launchchance then
            Launch(inst, haunter, speed or TUNING.LAUNCH_SPEED_SMALL)
            inst.components.hauntable.hauntvalue = launch_haunt_value or TUNING.HAUNT_TINY

			if inst.components.inventoryitem ~= nil and inst.components.inventoryitem.is_landed then
				inst.components.inventoryitem:SetLanded(false, true)
			end

            --#HAUNTFIX
            --ignitechance = ignitechance or TUNING.HAUNT_CHANCE_VERYRARE
            --if math.random() <= ignitechance then
                --if inst.components.burnable and not inst.components.burnable:IsBurning() then
                    --inst.components.burnable:Ignite()
                    --inst.components.hauntable.hauntvalue = ignite_haunt_value or TUNING.HAUNT_MEDIUM
                    --inst.components.hauntable.cooldown_on_successful_haunt = false
                --end
            --end
            --return true
        end
        return false
    end)
end

local function DoChangePrefab(inst, newprefab, haunter, nofx)
    local x, y, z = inst.Transform:GetWorldPosition()
    if not nofx then
        SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
    end
    local new = SpawnPrefab(type(newprefab) == "table" and newprefab[math.random(#newprefab)] or newprefab)
    if new ~= nil then
        new.Transform:SetPosition(x, y, z)
        if new.components.stackable ~= nil and inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
            new.components.stackable:SetStackSize(math.min(new.components.stackable.maxsize, inst.components.stackable:StackSize()))
        end
        if new.components.inventoryitem ~= nil and inst.components.inventoryitem ~= nil then
            new.components.inventoryitem:InheritMoisture(inst.components.inventoryitem:GetMoisture(), inst.components.inventoryitem:IsWet())
        end
        if new.components.perishable ~= nil and inst.components.perishable ~= nil then
            new.components.perishable:SetPercent(inst.components.perishable:GetPercent())
        end
        if new.components.fueled ~= nil and inst.components.fueled ~= nil then
            new.components.fueled:SetPercent(inst.components.fueled:GetPercent())
        end
        if new.components.finiteuses ~= nil and inst.components.finiteuses ~= nil then
            new.components.finiteuses:SetPercent(inst.components.finiteuses:GetPercent())
        end
        local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
        inst:PushEvent("detachchild")
        if home ~= nil and home.components.childspawner ~= nil then
            home.components.childspawner:TakeOwnership(new)
        end
        new:PushEvent("spawnedfromhaunt", { haunter = haunter, oldPrefab = inst })
        inst:PushEvent("despawnedfromhaunt", { haunter = haunter, newPrefab = new })
        inst.persists = false
        inst.entity:Hide()
        inst:DoTaskInTime(0, inst.Remove)
    end
end

function MakeHauntableChangePrefab(inst, newprefab, chance, haunt_value, nofx)
    if newprefab == nil or (type(newprefab) == "table" and #newprefab <= 0) then
        return
    elseif inst.components.hauntable == nil then
        inst:AddComponent("hauntable")
    end
    inst.components.hauntable.cooldown_on_successful_haunt = false
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if math.random() <= (chance or TUNING.HAUNT_CHANCE_HALF) then
            DoChangePrefab(inst, newprefab, haunter, nofx)
            inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_SMALL
            return true
        end
        return false
    end)
end

function MakeHauntableLaunchOrChangePrefab(inst, launchchance, prefabchance, speed, cooldown, newprefab, prefab_haunt_value, launch_haunt_value, nofx)
    if newprefab == nil or (type(newprefab) == "table" and #newprefab <= 0) then
        return
    elseif inst.components.hauntable == nil then
        inst:AddComponent("hauntable")
    end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if math.random() <= (launchchance or TUNING.HAUNT_CHANCE_ALWAYS) then
            if math.random() <= (prefabchance or TUNING.HAUNT_CHANCE_OCCASIONAL) then
                DoChangePrefab(inst, newprefab, haunter, nofx)
                inst.components.hauntable.hauntvalue = prefab_haunt_value or TUNING.HAUNT_SMALL
            else
                Launch(inst, haunter, speed or TUNING.LAUNCH_SPEED_SMALL)
                inst.components.hauntable.hauntvalue = launch_haunt_value or TUNING.HAUNT_TINY
            end
            return true
        end
        return false
    end)
end

function MakeHauntablePerish(inst, perishpct, chance, cooldown, haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        --#HAUNTFIX
        --chance = chance or TUNING.HAUNT_CHANCE_HALF
        --if math.random() <= chance then
            --if inst.components.perishable then
                --inst.components.perishable:ReducePercent(perishpct or .3)
                --inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_MEDIUM
                --return true
            --end
        --end
        return false
    end)
end

function MakeHauntableLaunchAndPerish(inst, launchchance, perishchance, speed, perishpct, cooldown, launch_haunt_value, perish_haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        launchchance = launchchance or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= launchchance then
            Launch(inst, haunter, speed or TUNING.LAUNCH_SPEED_SMALL)
            inst.components.hauntable.hauntvalue = launch_haunt_value or TUNING.HAUNT_TINY
            inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL

			if inst.components.inventoryitem ~= nil and inst.components.inventoryitem.is_landed then
				inst.components.inventoryitem:SetLanded(false, true)
			end

            --#HAUNTFIX
            --perishchance = perishchance or TUNING.HAUNT_CHANCE_OCCASIONAL
            --if math.random() <= perishchance then
                --if inst.components.perishable then
                    --inst.components.perishable:ReducePercent(perishpct or .3)
                    --inst.components.hauntable.hauntvalue = perish_haunt_value or TUNING.HAUNT_MEDIUM
                    --inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
                --end
            --end
            return true
        end
        return false
    end)
end

function MakeHauntablePanic(inst, panictime, chance, cooldown, haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
	inst.components.hauntable.panicable = true
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if inst.components.sleeper then -- Wake up, there's a ghost!
            inst.components.sleeper:WakeUp()
        end

        chance = chance or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= chance then
            inst.components.hauntable.panic = true
            inst.components.hauntable.panictimer = panictime or TUNING.HAUNT_PANIC_TIME_SMALL
            inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_SMALL
            return true
        end
        return false
    end)
end

function MakeHauntablePanicAndIgnite(inst, panictime, panicchance, ignitechance, cooldown, panic_haunt_value, ignite_haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
	inst.components.hauntable.panicable = true
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        panicchance = panicchance or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= panicchance then
            inst.components.hauntable.panic = true
            inst.components.hauntable.panictimer = panictime or TUNING.HAUNT_PANIC_TIME_SMALL
            inst.components.hauntable.hauntvalue = panic_haunt_value or TUNING.HAUNT_SMALL
            --#HAUNTFIX
            --ignitechance = ignitechance or TUNING.HAUNT_CHANCE_RARE
            --if math.random() <= ignitechance then
                --if inst.components.burnable and not inst.components.burnable:IsBurning() then
                    --inst.components.burnable:Ignite()
                    --inst.components.hauntable.hauntvalue = ignite_haunt_value or TUNING.HAUNT_MEDIUM
                    --inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_HUGE
                --end
            --end
            return true
        end
        return false
    end)
end

function MakeHauntablePlayAnim(inst, anim, animloop, pushanim, animduration, endanim, endanimloop, soundevent, soundname, soundduration, chance, cooldown, haunt_value)
    if not anim then return end

    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        chance = chance or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= chance then

            local loop = animloop ~= nil and animloop or false
            if pushanim then
                inst.AnimState:PushAnimation(anim, loop)
            else
                inst.AnimState:PlayAnimation(anim, loop)
            end
            if animduration and endanim then
                inst:DoTaskInTime(animduration, function(inst) inst.AnimState:PlayAnimation(endanim, endanimloop) end)
            end

            if soundevent and inst.SoundEmitter then
                if soundname then
                    inst.SoundEmitter:PlaySound(soundevent, soundname)
                    if soundduration then
                        inst:DoTaskInTime(soundduration, function(inst) inst.SoundEmitter:KillSound(soundname) end)
                    end
                else
                    inst.SoundEmitter:PlaySound(soundevent)
                end
            end

            inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_TINY
            return true
        end
        return false
    end)
end

--V2C: NOT SAFE TO USE WITH CREATURE STATEGRAPHS
function MakeHauntableGoToState(inst, state, chance, cooldown, haunt_value)
    if not (inst and inst.sg) or not state then return end

    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        chance = chance or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= chance then
            inst.sg:GoToState(state)
            inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_TINY
            return true
        end
        return false
    end)
end

--V2C: NOT SAFE TO USE WITH CREATURE STATEGRAPHS
function MakeHauntableGoToStateWithChanceFunction(inst, state, chancefn, cooldown, haunt_value)
    if not (inst and inst.sg) or not state then return end
    if not inst.components.hauntable then inst:AddComponent("hauntable") end

    inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        local haunt_chance = (chancefn ~= nil and chancefn(inst)) or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= haunt_chance then
            inst.sg:GoToState(state)
            inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_TINY
            return true
        end
        return false
    end)
end

function MakeHauntableDropFirstItem(inst, chance, cooldown, haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL
        --#HAUNTFIX
        --chance = chance or TUNING.HAUNT_CHANCE_OCCASIONAL
        --if math.random() <= chance then
            --if inst.components.inventory then
                --local item = inst.components.inventory:FindItem(function(item) return not item:HasTag("nosteal") end)
                --if item then
                    --local direction = Vector3(haunter.Transform:GetWorldPosition()) - Vector3(inst.Transform:GetWorldPosition() )
                    --inst.components.inventory:DropItem(item, false, direction:GetNormalized())
                    --inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_MEDIUM
                    --inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
                    --return true
                --end
            --end
            --if inst.components.container then
                --local item = inst.components.container:FindItem(function(item) return not item:HasTag("nosteal") end)
                --if item then
                    --inst.components.container:DropItem(item)
                    --inst.components.hauntable.hauntvalue = haunt_value or TUNING.HAUNT_MEDIUM
                    --inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
                    --return true
                --end
            --end
        --end
        return false
    end)
end

function MakeHauntableLaunchAndDropFirstItem(inst, launchchance, dropchance, speed, cooldown, launch_haunt_value, drop_haunt_value)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        launchchance = launchchance or TUNING.HAUNT_CHANCE_ALWAYS
        if math.random() <= launchchance then
            Launch(inst, haunter, speed or TUNING.LAUNCH_SPEED_SMALL)
            inst.components.hauntable.hauntvalue = launch_haunt_value or TUNING.HAUNT_TINY
            inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_SMALL

			if inst.components.inventoryitem ~= nil and inst.components.inventoryitem.is_landed then
				inst.components.inventoryitem:SetLanded(false, true)
			end

            --#HAUNTFIX
            --dropchance = dropchance or TUNING.HAUNT_CHANCE_OCCASIONAL
            --if math.random() <= dropchance then
                --if inst.components.inventory then
                    --local item = inst.components.inventory:FindItem(function(item) return not item:HasTag("nosteal") end)
                    --if item then
                        --local direction = Vector3(haunter.Transform:GetWorldPosition()) - Vector3(inst.Transform:GetWorldPosition() )
                        --inst.components.inventory:DropItem(item, false, direction:GetNormalized())
                        --inst.components.hauntable.hauntvalue = drop_haunt_value or TUNING.HAUNT_MEDIUM
                        --inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
                        --return true
                    --end
                --end
                --if inst.components.container then
                    --local item = inst.components.container:FindItem(function(item) return not item:HasTag("nosteal") end)
                    --if item then
                        --inst.components.container:DropItem(item)
                        --inst.components.hauntable.hauntvalue = drop_haunt_value or TUNING.HAUNT_MEDIUM
                        --inst.components.hauntable.cooldown = cooldown or TUNING.HAUNT_COOLDOWN_MEDIUM
                        --return true
                    --end
                --end
            --end
            return true
        end
        return false
    end)
end

function AddHauntableCustomReaction(inst, fn, secondrxn, ignoreinitialresult, ignoresecondaryresult)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    local onhaunt = inst.components.hauntable.onhaunt
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        local result = false
        if secondrxn then -- Custom reaction to come after any existing reactions (i.e. additional effects that are conditional on existing reactions)
            if onhaunt then
                result = onhaunt(inst, haunter)
            end
            if not onhaunt or result or ignoreinitialresult then -- Can use ignore flags if we don't care about the return value of a given part
                local prevresult = result
                result = fn(inst, haunter)
                if ignoresecondaryresult then result = prevresult end
            end
        else -- Custom reaction to come before any existing reactions (i.e. conditions required for existing reaction to trigger)
            result = fn(inst, haunter)
            if (result or ignoreinitialresult) and onhaunt then -- Can use ignore flags if we don't care about the return value of a given part
                local prevresult = result
                result = onhaunt(inst, haunter)
                if ignoresecondaryresult then result = prevresult end
            end
        end
        return result
    end)
end

function AddHauntableDropItemOrWork(inst)
    if not inst.components.hauntable then inst:AddComponent("hauntable") end
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        local ret = false
        --#HAUNTFIX
        --if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
            --if inst.components.container then
                --local item = inst.components.container:FindItem(function(item) return not item:HasTag("nosteal") end)
                --if item then
                    --inst.components.container:DropItem(item)
                    --inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
                    --ret = true
                --end
            --end
        --end
        --if math.random() <= TUNING.HAUNT_CHANCE_VERYRARE then
            --if inst.components.workable then
                --inst.components.workable:WorkedBy(haunter, 1)
                --inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
                --ret = true
            --end
        --end
        return ret
    end)
end

--------------------------------------------------------------------------
--V2C: new for DST, useful for allowing creatures to jump or dash through things
--     (taken from lavaarena)
--NOTE: -prefab must call inst:SetPhysicsRadiusOverride(r) during construction
--      -must set inst.sg.mem.radius = inst.physicsradiusoverride after adding stategraph

local ONUPDATEPHYSICSRADIUS_MUST_TAGS = { "character", "locomotor" }
local ONUPDATEPHYSICSRADIUS_CANT_TAGS = { "INLIMBO" }
local function OnUpdatePhysicsRadius(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local mindist = math.huge
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 2, ONUPDATEPHYSICSRADIUS_MUST_TAGS, ONUPDATEPHYSICSRADIUS_CANT_TAGS)) do
        if v ~= inst and v.entity:IsVisible() then
            local d = v:GetDistanceSqToPoint(x, y, z)
            d = d > 0 and (v.Physics ~= nil and math.sqrt(d) - v.Physics:GetRadius() or math.sqrt(d)) or 0
            if d < mindist then
                if d <= 0 then
                    mindist = 0
                    break
                end
                mindist = d
            end
        end
    end
    local radius = math.clamp(mindist, 0, inst.physicsradiusoverride)
    if radius > 0 then
        if radius ~= inst.sg.mem.radius then
            inst.sg.mem.radius = radius
            inst.Physics:SetCapsule(radius, 1)
            inst.Physics:Teleport(x, y, z)
            if inst.sg:HasStateTag("idle") then
                inst.Physics:Stop()
            end
        end
        if inst.sg.mem.ischaracterpassthrough then
            inst.sg.mem.ischaracterpassthrough = nil
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        end
        if radius >= inst.physicsradiusoverride then
            inst.sg.mem.physicstask:Cancel()
            inst.sg.mem.physicstask = nil
        end
    end
end

function ToggleOffCharacterCollisions(inst)
    if not inst.sg.mem.ischaracterpassthrough then
        inst.sg.mem.ischaracterpassthrough = true
		inst.Physics:ClearCollidesWith(COLLISION.CHARACTERS)
    end
    if inst.sg.mem.physicstask ~= nil then
        inst.sg.mem.physicstask:Cancel()
        inst.sg.mem.physicstask = nil
        inst.sg.mem.radius = inst.physicsradiusoverride
        inst.Physics:SetCapsule(inst.physicsradiusoverride, 1)
        inst.Physics:Teleport(inst.Transform:GetWorldPosition())
    end
end

function ToggleOnCharacterCollisions(inst)
    if inst.sg.mem.ischaracterpassthrough and inst.sg.mem.physicstask == nil then
        inst.sg.mem.physicstask = inst:DoPeriodicTask(.5, OnUpdatePhysicsRadius)
        OnUpdatePhysicsRadius(inst)
    end
end

function ToggleOffAllObjectCollisions(inst)
    if not (inst.sg.mem.isobstaclepassthrough and inst.sg.mem.ischaracterpassthrough) then
        inst.sg.mem.isobstaclepassthrough = true
        inst.sg.mem.ischaracterpassthrough = true
		inst.Physics:ClearCollidesWith(COLLISION.CHARACTERS)
		inst.Physics:ClearCollidesWith(COLLISION.OBSTACLES)
		inst.Physics:ClearCollidesWith(COLLISION.SMALLOBSTACLES)
		inst.Physics:ClearCollidesWith(COLLISION.GIANTS)
    end
    if inst.sg.mem.physicstask ~= nil then
        inst.sg.mem.physicstask:Cancel()
        inst.sg.mem.physicstask = nil
        inst.sg.mem.radius = inst.physicsradiusoverride
        inst.Physics:SetCapsule(inst.physicsradiusoverride, 1)
        inst.Physics:Teleport(inst.Transform:GetWorldPosition())
    end
end

function ToggleOnAllObjectCollisionsAt(inst, x, z)
    if inst.sg.mem.isobstaclepassthrough then
        inst.sg.mem.isobstaclepassthrough = nil
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
    end
    inst.Physics:Teleport(x, 0, z)
    ToggleOnCharacterCollisions(inst)
end

--------------------------------------------------------------------------
--V2C: new for DST, useful for preventing player collisions when placing large objects
local function OnUpdatePlacedObjectPhysicsRadius(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    local mindist = math.huge
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 2, ONUPDATEPHYSICSRADIUS_MUST_TAGS, ONUPDATEPHYSICSRADIUS_CANT_TAGS)) do
        if v.entity:IsVisible() then
            local d = v:GetDistanceSqToPoint(x, y, z)
            d = d > 0 and (v.Physics ~= nil and math.sqrt(d) - v.Physics:GetRadius() or math.sqrt(d)) or 0
            if d < mindist then
                if d <= 0 then
                    mindist = 0
                    break
                end
                mindist = d
            end
        end
    end
    local radius = math.clamp(mindist, 0, inst.physicsradiusoverride)
    if radius > 0 then
        if radius ~= data.radius then
            data.radius = radius
            inst.Physics:SetCapsule(radius, 2)
            inst.Physics:Teleport(x, y, z)
        end
        if data.ischaracterpassthrough then
            data.ischaracterpassthrough = false
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        end
        if radius >= inst.physicsradiusoverride then
            inst._physicstask:Cancel()
            inst._physicstask = nil
        end
    end
end

function PreventCharacterCollisionsWithPlacedObjects(inst)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    if inst._physicstask ~= nil then
        inst._physicstask:Cancel()
    end
    local data = { radius = inst.physicsradiusoverride, ischaracterpassthrough = true }
    inst._physicstask = inst:DoPeriodicTask(.5, OnUpdatePlacedObjectPhysicsRadius, nil, data)
    OnUpdatePlacedObjectPhysicsRadius(inst, data)
end

--------------------------------------------------------------------------
--V2C: new for DST, useful for allowing entities to prevent targeting players that attacked them

local function StopTargetingAttacker(inst, attacker)
    if inst.components.combat ~= nil and inst.components.combat:TargetIs(attacker) then
        inst.components.combat:DropTarget()
    end
end

function PreventTargetingOnAttacked(inst, attacker, tag)
    if attacker.WINDSTAFF_CASTER ~= nil and attacker.WINDSTAFF_CASTER:IsValid() then
        attacker = attacker.WINDSTAFF_CASTER
    end
    if attacker:HasTag(tag) then
        StopTargetingAttacker(inst, attacker)
        --V2C: fire darts and tornado staves may set target after, so do this again next frame
        inst:DoTaskInTime(0, StopTargetingAttacker, attacker)
        return true
    end
    return false
end

--------------------------------------------------------------------------

function AddDefaultRippleSymbols(inst, ripple, shadow)
    -- used if something has the ripple effects but it's an inventory item
	if ripple then
	    inst.AnimState:OverrideSymbol("water_ripple", "swimming_ripple", "water_ripple")
	end
	if shadow then
	    inst.AnimState:OverrideSymbol("water_shadow", "swimming_ripple", "water_shadow")
	end
end

function MakeInventoryFloatable(inst, size, offset, scale, swap_bank, float_index, swap_data)
    local floater = inst:AddComponent("floater")
    floater:SetSize(size or "small")

    if offset then
        floater:SetVerticalOffset(offset)
    end

    if scale then
        floater:SetScale(scale)
    end

    if swap_bank then
        floater:SetBankSwapOnFloat(swap_bank, float_index, swap_data)
    elseif swap_data then
        floater:SetSwapData(swap_data)
    end

    return floater
end

--------------------------------------------------------------------------

local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS

local function fertilizer_ondeploy(inst, pt, deployer)
    local tile_x, tile_z = TheWorld.Map:GetTileCoordsAtPoint(pt:Get())
    local nutrients = inst.components.fertilizer.nutrients
    TheWorld.components.farming_manager:AddTileNutrients(tile_x, tile_z, nutrients[1], nutrients[2], nutrients[3])
    
    inst.components.fertilizer:OnApplied(deployer)
    if deployer ~= nil and deployer.SoundEmitter ~= nil and inst.components.fertilizer.fertilize_sound ~= nil then
        deployer.SoundEmitter:PlaySound(inst.components.fertilizer.fertilize_sound)
    end

    if inst.ondeployed_fertilzier_extra_fn then
        inst.ondeployed_fertilzier_extra_fn(inst, pt, deployer)
    end
end

local function fertilizer_candeploy(inst, pt, mouseover, deployer)
    return TheWorld.Map:IsFarmableSoilAtPoint(pt:Get())
end

function MakeDeployableFertilizerPristine(inst)
    inst._custom_candeploy_fn = fertilizer_candeploy
    inst.overridedeployplacername = "gridplacer_farmablesoil"
    inst:AddTag("deployable")
    inst:AddTag("tile_deploy")
end

function MakeDeployableFertilizer(inst)
    local deployable = inst:AddComponent("deployable")
    deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
    deployable.ondeploy = fertilizer_ondeploy
    deployable:SetUseGridPlacer(false)
    deployable.keep_in_inventory_on_deploy = true

    return deployable
end

--------------------------------------------------------------------------
local function OnStartRegrowth(inst, data)
    -- NOTES(JBK): inst will most likely be not valid right after this.
    TheWorld:PushEvent("beginregrowth", inst)
end
function RemoveFromRegrowthManager(inst)
    inst:RemoveEventCallback("onremove", OnStartRegrowth)
    inst:RemoveEventCallback("despawnedfromhaunt", RemoveFromRegrowthManager)
    inst.OnStartRegrowth = nil
end
function AddToRegrowthManager(inst)
    inst:ListenForEvent("onremove", OnStartRegrowth)
    inst:ListenForEvent("despawnedfromhaunt", RemoveFromRegrowthManager)
    inst.OnStartRegrowth = OnStartRegrowth -- For any special cases that need to call this.
end

--------------------------------------------------------------------------

function MakeForgeRepairable(inst, material, onbroken, onrepaired)
	local function _onbroken(inst)
		if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
			local owner = inst.components.inventoryitem.owner
			if owner ~= nil and owner.components.inventory ~= nil then
				local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
				if item ~= nil then
					owner.components.inventory:GiveItem(item, nil, owner:GetPosition())
				end
			end
		end
		if onbroken ~= nil then
			onbroken(inst)
		end		
	end

	--V2C: asserts to prevent overwriting callbacks already setup by the prefab

	if inst.components.armor ~= nil then
		assert(not (DEBUG_MODE and inst.components.armor.onfinished ~= nil))
		inst.components.armor:SetKeepOnFinished(true)
		inst.components.armor:SetOnFinished(_onbroken)
	elseif inst.components.finiteuses ~= nil then
		assert(not (DEBUG_MODE and inst.components.finiteuses.onfinished ~= nil))
		inst.components.finiteuses:SetOnFinished(_onbroken)
	elseif inst.components.fueled ~= nil then
		assert(not (DEBUG_MODE and inst.components.fueled.depleted ~= nil))
		inst.components.fueled:SetDepletedFn(_onbroken)
	end

	inst:AddComponent("forgerepairable")
	inst.components.forgerepairable:SetRepairMaterial(material)
	inst.components.forgerepairable:SetOnRepaired(onrepaired)
end

--------------------------------------------------------------------------

function MakeWaxablePlant(inst)
    local waxable = inst:AddComponent("waxable")
    waxable:SetWaxfn(WAXED_PLANTS.WaxPlant)
    waxable:SetNeedsSpray()
end
