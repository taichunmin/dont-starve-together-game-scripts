local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/rook.zip"),
    Asset("ANIM", "anim/rook_rhino.zip"),
    Asset("ANIM", "anim/rook_rhino_damaged_build.zip"),
    Asset("ANIM", "anim/rook_attacks.zip"),
    Asset("SOUND", "sound/chess.fsb"),
    Asset("MINIMAP_IMAGE", "atrium_key"),
    Asset("SCRIPT", "scripts/prefabs/ruinsrespawner.lua"),
}

local bloodassets =
{
    Asset("ANIM", "anim/rook_rhino_blood_big_fx.zip"),
}

local prefabs =
{
    "meat",
    "minotaurhorn",
    "minotaurchestspawner",
    "atrium_key",
    "collapse_small",
    "minotaur_ruinsrespawner_inst",
    "chesspiece_minotaur_sketch",
    "winter_ornament_boss_minotaur",
    "bigshadowtentacle",
    "shadowhand_fx",
    "ruins_cavein_obstacle",
    "minotaur_blood1",
    "minotaur_blood2",
    "minotaur_blood3",
    "minotaur_blood_big",
}

local prefabs_chest =
{
    "minotaurchest",
    "atrium_key",
}

local brain = require "brains/minotaurbrain"

SetSharedLootTable('minotaur',
{
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"minotaurhorn",1.00},
    {"chesspiece_minotaur_sketch", 1.00},
})

local chest_loot =
{
    {item = {"armorruins", "ruinshat", "ruins_bat"}, count = 1},
    {item = {"orangestaff", "yellowstaff"}, count = 1},
    {item = {"orangeamulet", "yellowamulet"}, count = 1},
    {item = {"yellowgem"}, count = {2, 4}},
    {item = {"orangegem"}, count = {2, 4}},
    {item = {"greengem"}, count = {2, 3}},
    {item = {"thulecite"}, count = {8, 14}},
    {item = {"thulecite_pieces"}, count = {12, 36}},
    {item = {"gears"}, count = {3, 6}},
}


local PHASE1 = 0.6

--Called from stategraph
local function LaunchProjectile(inst, targetpos)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("minotaurphlem")
    projectile.Transform:SetPosition(x, y, z)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.FIRE_DETECTOR_RANGE
    local speed = easing.linear(rangesq, 15, 3, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-25)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)
end

for _,v in ipairs(chest_loot) do
    for _,item in ipairs(v.item) do
        table.insert(prefabs_chest, item)
    end
end

local SLEEP_DIST_FROMHOME_SQ = 20 * 20
local SLEEP_DIST_FROMTHREAT = 40
local MAX_CHASEAWAY_DIST_SQ = 40 * 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local CHARACTER_TAGS = {"character"}
local function BasicWakeCheck(inst)
    return (inst.components.combat ~= nil and inst.components.combat.target ~= nil)
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning() ~= nil)
        or (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() ~= nil)
        or GetClosestInstWithTag(CHARACTER_TAGS, inst, SLEEP_DIST_FROMTHREAT) ~= nil
end

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil
        and inst:GetDistanceSqToPoint(homePos:Get()) < SLEEP_DIST_FROMHOME_SQ
        and not BasicWakeCheck(inst)
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (homePos ~= nil and
            inst:GetDistanceSqToPoint(homePos:Get()) >= SLEEP_DIST_FROMHOME_SQ)
        or BasicWakeCheck(inst)
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "chess", "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local function Retarget(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return not (homePos ~= nil and
                inst:GetDistanceSqToPoint(homePos:Get()) >= MAX_CHASEAWAY_DIST_SQ)
        and FindEntity(
            inst,
            TUNING.MINOTAUR_TARGET_DIST,
            function(guy)
                return not (inst.components.follower ~= nil and inst.components.follower.leader == guy)
                       and inst.components.combat:CanTarget(guy)
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS,
            RETARGET_ONEOF_TAGS
        )
        or nil
end

local function KeepTarget(inst, target)
    if inst.sg ~= nil and inst.sg:HasStateTag("running") then
        return true
    end
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil and inst:GetDistanceSqToPoint(homePos:Get()) < MAX_CHASEAWAY_DIST_SQ
end

local function IsChess(dude)
    return dude:HasTag("chess")
end

local function checkfortentacledrop(inst)
    if inst:IsValid() then
        local chance = Remap(inst.components.health:GetPercent(),0,PHASE1,0.05,0.01)
        if math.random() < chance then
            inst.SpawnBigBloodDrop(inst)
        end

        local chance2 = Remap(inst.components.health:GetPercent(),0,PHASE1,0.8,0.01)
        if math.random() < chance2 then
            inst.SpawnShadowFX(inst)
        end
    end
end

local function OnAttacked(inst, data)
    if inst.components.health:GetPercent() < PHASE1 then
        inst.AnimState:SetBuild("rook_rhino_damaged_build")
    end

    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and attacker:HasTag("chess") then
        return
    end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, IsChess, MAX_TARGET_SHARES)

    if inst.components.health:GetPercent() < PHASE1  and not inst.tentacletask then
        inst.tentacletask = inst:DoPeriodicTask(0.2, function() checkfortentacledrop(inst) end)
    end
end

local function OnDeath(inst)
    AwardRadialAchievement("minotaur_killed", inst:GetPosition(), TUNING.ACHIEVEMENT_RADIUS_FOR_GIANT_KILL)
end

local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function cause_obstacle_quake(inst, other)
    if not other.components.timer or not other.components.timer:TimerExists("ram_quake") then 
        TheWorld:PushEvent("ms_miniquake", { rad = 20, num = 20, duration = 2.5, target = inst })
        inst.startobstacledrop(inst)   

        if not other.components.timer then
            other:AddComponent("timer")
        end
        other.components.timer:StartTimer("ram_quake",20)
    end
end

local function breakobjects(inst,other)
    if other == inst then
        return
    end
    if other:HasTag("smashable") and other.components.health ~= nil then
        other.components.health:Kill()
    elseif other.components.workable ~= nil
        and other.components.workable:CanBeWorked()
        and other.components.workable.action ~= ACTIONS.NET then
        other.components.workable:Destroy(inst)
    elseif other.components.health ~= nil and not other.components.health:IsDead() then
        return true
    end
end

local NO_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO", "notarget"}
local function jumpland(inst)
    local hittarget = false
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z,4,nil,NO_TAGS)
    if #ents > 0 then
        for i,ent in ipairs(ents)do
            if breakobjects(inst,ent) then
               hittarget = true
            end 
        end
    end
    if not hittarget then
        inst.chargecount = 0.6
        inst:PushEvent("collision_stun",{land_stun = true})
        return false
    end
    return true
end

local function onothercollide(inst, other)
    if not other:IsValid() or inst.recentlycharged[other] then
        return
    else
        if other:HasTag("charge_barrier") then
            inst:PushEvent("collision_stun",{light_stun = inst.chargecount < 0.3 and true or nil})            
        end
        if other:HasTag("quake_on_charge") then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(20, ClearRecentlyCharged, other)
            cause_obstacle_quake(inst, other)
            --ShakeAllCameras(CAMERASHAKE.FULL, .3, .025, .2, inst, 30)
            ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .02, 1.1, inst, 40)
            other:PushEvent("shake")
        else
            ShakeAllCameras(CAMERASHAKE.SIDE, .5, .05, .1, inst, 40)
        end

        breakobjects(inst,other)

        if ( other.components.health ~= nil and not other.components.health:IsDead())
            or (other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() ) then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        end
    end

end

local function oncollide(inst, other)

    if not (other ~= nil and other:IsValid() and inst:IsValid())
        or inst.recentlycharged[other]
        or other:HasTag("player")
        or Vector3(inst.Physics:GetVelocity()):LengthSq() < 42 then
        return
    end
    inst:DoTaskInTime(2 * FRAMES, onothercollide, other)
end

local function rememberhome(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end


local function SpawnTentacle(inst, pt)
    if not pt then
        pt = Vector3(inst.Transform:GetWorldPosition())
    end
    local tent = SpawnPrefab("bigshadowtentacle")
    tent.Transform:SetPosition(pt.x,pt.y,pt.z)
    tent:PushEvent("arrive")
end

local TENTS_MUSTHAVE = {"shadow"}
local function SpawnBigBloodDrop(inst, pt)
    local mpt = Vector3(inst.Transform:GetWorldPosition())
    local radius = 4
    if not pt then
        pt = mpt
    end

    local count = TheSim:FindEntities(pt.x,pt.y,pt.z,5,TENTS_MUSTHAVE)
    for i=#count,1,-1 do
        if count[i].prefab ~= "bigshadowtentacle" then
            table.remove(count,i)
        end
    end
    if #count < 5 then
        local theta = math.random() * 2* PI
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        pt = pt+offset

        local blood = SpawnPrefab("minotaur_blood_big")
        blood.Transform:SetPosition(pt.x,pt.y,pt.z)

        blood.Transform:SetRotation(theta/DEGREES - 180)
    end
end

local function SpawnShadowFX(inst)

    local pt = Vector3(inst.Transform:GetWorldPosition())
    local radius = 1.5 + math.random()
  
    local theta = math.random() * 2* PI
    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin(  theta ))
    --pt = pt+offset

    local fx = SpawnPrefab("minotaur_blood"..math.random(1,3))
    --local scale = 1 + (math.random()*1)
    fx.Transform:SetPosition(pt.x,pt.y,pt.z)
    --fx.Transform:SetScale(scale,scale,scale)    
    --fx.Transform:SetRotation(inst:GetAngleToPoint(pt))
    fx.Transform:SetRotation(math.random()*360)
end

local OBSTACLE_MUST_TAGS = {"charge_barrier"}

local PILLAR_MUST_TAGS = {"quake_on_charge"}
local function startobstacledrop(inst)
    if inst.spawnlocation then
        local dist = inst:GetDistanceSqToPoint(inst.spawnlocation)

        if dist < 25*25 then
            local instpt = inst.spawnlocation

            for i=1, math.random(3,4) do
                local pt = nil
                local testpt = nil
                local count = 0
                while testpt == nil and count < 8 do
                    count = count + 1
                    local theta = math.random()*2 * PI
                    local radius = math.sqrt(math.random())*20
                    testpt = Vector3(radius*math.cos(theta),0,radius*math.sin(theta))
                    testpt = testpt + instpt
                    testpt.y = 0

                    if not TheWorld.Map:IsPassableAtPoint(testpt.x,0,testpt.z) then
                        testpt = nil
                    end
                    if testpt then
                        local ents = TheSim:FindEntities(testpt.x,testpt.y,testpt.z, 4, PILLAR_MUST_TAGS)
                        if #ents > 0 then
                            testpt = nil
                        end
                    end         
                end

                if testpt then
                    inst:DoTaskInTime(0.3+(math.random()*2), function()
                        local obstacle = SpawnPrefab("ruins_cavein_obstacle")
                        obstacle.Transform:SetPosition(instpt.x,instpt.y,instpt.z)
                        obstacle.fall(obstacle,Vector3(testpt.x,testpt.y,testpt.z))
                    end)
                end
            end
        end
    end
end

--------- LANDING PHYSICS STUFF
local function CancelObstacleTask(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.ischaracterpassthrough = nil
    end
end

local function SetCurrentRadius(inst, radius)
    if inst.currentradius ~= radius then
        inst.currentradius = radius
        inst.Physics:SetCapsule(radius, 4)
    end
end

local CHARACTER_MUST_TAGS = { "character", "locomotor" }
local CHARACTER_CANT_TAGS = { "INLIMBO", "NOCLICK", "flying", "ghost" }
local function OnUpdateObstacleSize(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local mindist = math.huge
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 2, CHARACTER_MUST_TAGS, CHARACTER_CANT_TAGS)) do
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
    local radius = math.clamp(mindist, 0, inst.maxradius)
    if radius > 0 then
        SetCurrentRadius(inst, radius)
        if inst.ischaracterpassthrough then
            inst.ischaracterpassthrough = nil
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        end
        if radius >= inst.maxradius then
            CancelObstacleTask(inst)
        end
    end
end

local function OnChangeToObstacle(inst)

    inst.Physics:SetMass(100)
    inst.Physics:SetCollisionGroup(COLLISION.GIANTS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    
    inst.ischaracterpassthrough = true
    inst.task = inst:DoPeriodicTask(.5, OnUpdateObstacleSize)
    OnUpdateObstacleSize(inst)
    inst.Physics:Teleport(inst.Transform:GetWorldPosition())
end
---------------------------------------------

local function OnSave(inst, data)
    data.spawnlocation = inst.spawnlocation or nil
end

local function OnLoad(inst, data)
    if data then
        inst.spawnlocation = data.spawnlocation or nil
    end
end

local function OnLoadPostPass(inst, newents, data)
    if not inst.spawnlocation then
        for i,v in pairs(Ents) do

            if v.prefab == "minotaur_ruinsrespawner_inst" then
                inst.spawnlocation = Vector3(v.Transform:GetWorldPosition())

                break
            end
        end
    end
end

local function checkstunend(inst, data)
    if data ~= nil then
        if data.name == "endstun" then
            inst:RestartBrain()
            if inst.AnimState:IsCurrentAnimation("stun_jump_pre") or
                inst.AnimState:IsCurrentAnimation("stun_pre") or
                inst.AnimState:IsCurrentAnimation("stun_loop") or
                inst.AnimState:IsCurrentAnimation("stun_hit") then
                inst.sg:GoToState("stun_pst")
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("atrium_key.png")
    inst.MiniMapEntity:SetPriority(15)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    inst.MiniMapEntity:SetRestriction("nightmaretracker")

    inst.DynamicShadow:SetSize(5, 3)
    inst.Transform:SetFourFaced()

    inst.physicsradius = 2.2

    MakeGiantCharacterPhysics(inst, 1000, inst.physicsradius)
    inst.Physics:SetCapsule(1.75, 4) -- update inst.maxradius if you change this
	inst:SetPhysicsRadiusOverride(2.2)

    inst.AnimState:SetBank("rook")
    inst.AnimState:SetBuild("rook_rhino")

    inst:AddTag("cavedweller")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("minotaur")
    inst:AddTag("epic")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.recentlycharged = {}
    inst.Physics:SetCollisionCallback(oncollide)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.MINOTAUR_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.MINOTAUR_RUN_SPEED

    inst:SetStateGraph("SGminotaur")

    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "innerds"
    inst.components.combat:SetAttackPeriod(TUNING.MINOTAUR_ATTACK_PERIOD)
    inst.components.combat:SetDefaultDamage(TUNING.MINOTAUR_DAMAGE)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetRange(4.1-0.5,4.1+0.5)

    inst:AddComponent("groundpounder")
    inst.components.groundpounder.numRings = 2

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MINOTAUR_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('minotaur')

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", checkstunend)

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("maprevealable")
    inst.components.maprevealable:AddRevealSource(inst, "nightmaretracker")
    inst.components.maprevealable:SetIconPriority(15)

    inst:DoTaskInTime(0, rememberhome)

    inst:DoTaskInTime(0, function() OnAttacked(inst) end)

    MakeLargeBurnableCharacter(inst, "swap_fire", nil, 1.4)
    MakeMediumFreezableCharacter(inst, "innerds")

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)
   -- inst:ListenForEvent("collision_stun", OnCollisionStun)

    inst.maxradius = 1.75
        

    inst.SpawnShadowFX = SpawnShadowFX
    inst.SpawnBigBloodDrop = SpawnBigBloodDrop
    inst.startobstacledrop = startobstacledrop
    inst.jumpland = jumpland
    inst.OnChangeToObstacle = OnChangeToObstacle

    inst.PHASE1 = PHASE1

   -- inst.OnSave = OnSave
  --  inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

--------------------------------------------------------------------------

local function dospawnchest(inst, loading)
    local chest = SpawnPrefab("minotaurchest")
    local x, y, z = inst.Transform:GetWorldPosition()
    chest.Transform:SetPosition(x, 0, z)

    --Set up chest loot
    chest.components.container:GiveItem(SpawnPrefab("atrium_key"))

    local loot_keys = {}
    for i, _ in ipairs(chest_loot) do
        table.insert(loot_keys, i)
    end
	local max_loots = math.min(#chest_loot, chest.components.container.numslots - 1)
    loot_keys = PickSome(math.random(max_loots - 2, max_loots), loot_keys)

    for _, i in ipairs(loot_keys) do
        local loot = chest_loot[i]
        local item = SpawnPrefab(loot.item[math.random(#loot.item)])
        if item ~= nil then
            if type(loot.count) == "table" and item.components.stackable ~= nil then
                item.components.stackable:SetStackSize(math.random(loot.count[1], loot.count[2]))
            end
            chest.components.container:GiveItem(item)
        end
    end
    --

    if not chest:IsAsleep() then
        chest.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

        local fx = SpawnPrefab("statue_transition_2")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
            fx.Transform:SetScale(1, 2, 1)
        end

        fx = SpawnPrefab("statue_transition")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
            fx.Transform:SetScale(1, 1.5, 1)
        end
    end

    if inst.minotaur ~= nil and inst.minotaur:IsValid() and inst.minotaur.sg:HasStateTag("death") then
        inst.minotaur.MiniMapEntity:SetEnabled(false)
        inst.minotaur:RemoveComponent("maprevealable")
    end

    if not loading then
        inst:Remove()
    end
end

local function OnLoadChest(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        dospawnchest(inst, true)
        inst.persists = false
        inst:DoTaskInTime(0, inst.Remove)
    end
end

local function chestfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst.task = inst:DoTaskInTime(3, dospawnchest)

    inst.OnLoad = OnLoadChest

    return inst
end

local function bloodfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("rook_rhino_blood_big_fx")
    inst.AnimState:SetBuild("rook_rhino_blood_big_fx")
    inst.AnimState:PlayAnimation("blood_drop")
    inst.AnimState:SetMultColour(1, 1, 1, .5)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SpawnTentacle = SpawnTentacle
    inst.persists = false
 
    inst:DoTaskInTime(0*FRAMES,function() 
        inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/blood_splurt_large")
    end) 

    inst:DoTaskInTime(21*FRAMES,function() SpawnTentacle(inst) end)
    inst:ListenForEvent("animover", function() inst:Remove() end)

    return inst
end

--------------------------------------------------------------------------

return Prefab("minotaur", fn, assets, prefabs),
    Prefab("minotaurchestspawner", chestfn, nil, prefabs_chest),
    Prefab("minotaur_blood_big", bloodfn, bloodassets),
    RuinsRespawner.Inst("minotaur"), RuinsRespawner.WorldGen("minotaur")
