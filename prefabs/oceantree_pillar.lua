local CANOPY_SHADOW_DATA = require("prefabs/canopyshadows")

local assets =
{
    Asset("ANIM", "anim/oceantree_pillar_small_build1.zip"),
    Asset("ANIM", "anim/oceantree_pillar_small_build2.zip"),
    Asset("ANIM", "anim/oceantree_pillar_small.zip"),
    Asset("SCRIPT", "scripts/prefabs/canopyshadows.lua"),
    Asset("MINIMAP_IMAGE", "oceantree_pillar_small"),
}

local prefabs = 
{
    "oceantree_leaf_fx_fall",
    "oceantree_pillar_ripples",
    "oceantree_pillar_roots",
    "oceantree_pillar_leaves",
}

local LEAF_FALL_FX_OFFSET_MIN = 3.5
local LEAF_FALL_FX_OFFSET_VARIANCE = 2

local MIN = TUNING.SHADE_CANOPY_RANGE_SMALL
local MAX = MIN + TUNING.WATERTREE_PILLAR_CANOPY_BUFFER

local DROP_ITEMS_DIST_MIN = 6
local DROP_ITEMS_DIST_VARIANCE = 10

local NUM_DROP_SMALL_ITEMS_MIN = 10
local NUM_DROP_SMALL_ITEMS_MAX = 14

local NUM_DROP_SMALL_ITEMS_MIN_RAM = 4
local NUM_DROP_SMALL_ITEMS_MAX_RAM = 7

local NUM_DROP_SMALL_ITEMS_MIN_LIGHTNING = 3
local NUM_DROP_SMALL_ITEMS_MAX_LIGHTNING = 5

local RAM_ALERT_COCOONS_RADIUS = 20

local NEW_VINES_SPAWN_RADIUS_MIN = 6

local DROPPED_ITEMS_SPAWN_HEIGHT = 10

local small_ram_products =
{
    "twigs",
    "cutgrass",
    "oceantree_leaf_fx_fall",
    "oceantree_leaf_fx_fall",
    "oceantree_leaf_fx_fall",
    "oceantree_leaf_fx_fall",    
    "oceantree_leaf_fx_fall",
    "oceantree_leaf_fx_fall",      
}

local function spawnwaves(inst, numWaves, totalAngle, waveSpeed, wavePrefab, initialOffset, idleTime, instantActivate, random_angle)
    SpawnAttackWaves(
        inst:GetPosition(),
        (not random_angle and inst.Transform:GetRotation()) or nil,
        initialOffset or (inst.Physics and inst.Physics:GetRadius()) or nil,
        numWaves,
        totalAngle,
        waveSpeed,
        wavePrefab,
        idleTime,
        instantActivate
    )
end

local function OnFar(inst, player)
    if player.canopytrees then   
        player.canopytrees = player.canopytrees - 1
        player:PushEvent("onchangecanopyzone", player.canopytrees > 0)
    end
    inst.players[player] = nil
end

local function OnNear(inst,player)
    inst.players[player] = true

    player.canopytrees = (player.canopytrees or 0) + 1

    player:PushEvent("onchangecanopyzone", player.canopytrees > 0)
end

local function removecanopyshadow(inst)
    if inst.canopy_data ~= nil then
        for _, shadetile_key in ipairs(inst.canopy_data.shadetile_keys) do
            if TheWorld.shadetiles[shadetile_key] ~= nil then
                TheWorld.shadetiles[shadetile_key] = TheWorld.shadetiles[shadetile_key] - 1

                if TheWorld.shadetiles[shadetile_key] <= 0 then
                    if TheWorld.shadetile_key_to_leaf_canopy_id[shadetile_key] ~= nil then
                        DespawnLeafCanopy(TheWorld.shadetile_key_to_leaf_canopy_id[shadetile_key])
                        TheWorld.shadetile_key_to_leaf_canopy_id[shadetile_key] = nil
                    end
                end
            end
        end

        for _, ray in ipairs(inst.canopy_data.lightrays) do
            ray:Remove()
        end
    end
end

local OCEANVINES_MUST = {"oceanvine"}
local function removecanopy(inst)
    if inst.roots then
        inst.roots:Remove()
    end
    if inst._ripples then
        inst._ripples:Remove()
    end

    for player in pairs(inst.players) do
        if player:IsValid() then
            if player.canopytrees then
                OnFar(inst, player)
            end
        end
    end
    local point = inst:GetPosition()
    local oceanvines = TheSim:FindEntities(point.x, point.y, point.z, MAX+1, OCEANVINES_MUST)
    if #oceanvines > 0 then
        for i, ent in ipairs(oceanvines) do
            ent.fall(ent)
        end
    end

    inst._hascanopy:set(false)    
end

local function chop_tree(inst, chopper, chopsleft, numchops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then

            inst.SoundEmitter:PlaySound(
                chopper ~= nil and chopper:HasTag("beaver") and
                "dontstarve/characters/woodie/beaver_chop_tree" or
                chopper ~= nil and chopper:HasTag("boat") and
                "dontstarve/characters/woodie/beaver_chop_tree" or
                "dontstarve/wilson/use_axe_tree"
            )
    end

    inst.AnimState:PlayAnimation("chop")
    inst.AnimState:PushAnimation("idle")
    ShakeAllCameras(CAMERASHAKE.FULL, 0.25, 0.03, 0.2, inst, 6)

    if inst.components.workable.workleft / inst.components.workable.maxwork == 0.2 then 
        inst.SoundEmitter:PlaySound("waterlogged2/common/watertree_pillar/cracking")
    elseif inst.components.workable.workleft / inst.components.workable.maxwork == 0.12 then 
        inst.SoundEmitter:PlaySound("waterlogged2/common/watertree_pillar/cracking")
    end

    if math.random() < 0.58 then
        local theta = math.random() * PI * 2
        local offset = LEAF_FALL_FX_OFFSET_MIN + math.random() * LEAF_FALL_FX_OFFSET_VARIANCE
        
        local x, _, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("oceantree_leaf_fx_fall").Transform:SetPosition(x + math.cos(theta) * offset, 10, z + math.sin(theta) * offset)
    end
end

local function Dropleafitems(inst)
    local x, _, z = inst.Transform:GetWorldPosition()
    local item = SpawnPrefab("oceantree_pillar_leaves")
    local dist = DROP_ITEMS_DIST_MIN + DROP_ITEMS_DIST_VARIANCE * math.random()
    local theta = math.random() * 2 * PI
    local spawn_x, spawn_z
    spawn_x, spawn_z = x + math.cos(theta) * dist, z + math.sin(theta) * dist
    item.Transform:SetPosition(spawn_x, 0, spawn_z)
end

local function Dropleaves(inst)
    if not inst.leafcounter then
        inst.leafcounter = 0
    end
    Dropleafitems(inst)
    Dropleafitems(inst)
    Dropleafitems(inst)
    inst.leafcounter = inst.leafcounter + 0.05

    if inst.leafcounter > 1 then
        inst.dropleaftask:Cancel()
        inst.dropleaftask = nil
    end
end

local function DropItem(inst)
    if inst.items_to_drop and #inst.items_to_drop > 0 then
        local ind = math.random(1, #inst.items_to_drop)
        local item_to_spawn = inst.items_to_drop[ind]

        local x, _, z = inst.Transform:GetWorldPosition()

        local item = SpawnPrefab(item_to_spawn)

        local dist = DROP_ITEMS_DIST_MIN + DROP_ITEMS_DIST_VARIANCE * math.random()
        local theta = math.random() * 2 * PI

        local spawn_x, spawn_z

        spawn_x, spawn_z = x + math.cos(theta) * dist, z + math.sin(theta) * dist

        item.Transform:SetPosition(spawn_x, DROPPED_ITEMS_SPAWN_HEIGHT, spawn_z)    
        table.remove(inst.items_to_drop, ind)
    end
end
local function DropItems(inst)
 
    DropItem(inst)
    DropItem(inst)

    if #inst.items_to_drop < 1 then
        inst.items_to_drop = nil
        inst.drop_items_task:Cancel()
        inst.drop_items_task = nil
        if inst.removeme then
            inst.itemsdone = true  
            if inst.falldone then
                inst:Remove() 
            end                        
        end
    else
        inst.drop_items_task = inst:DoTaskInTime(0.05, function() DropItems(inst) end)
    end
end

local function DropLog(inst)
    if inst.logs > 0 then
     
        local item_to_spawn = "log"

        local x, _, z = inst.Transform:GetWorldPosition()

        local item = SpawnPrefab(item_to_spawn)

        local dist = 0 + (math.random()*6)
        local theta = math.random() * 2 * PI

        local spawn_x, spawn_z

        spawn_x, spawn_z = x + math.cos(theta) * dist, z + math.sin(theta) * dist

        item.Transform:SetPosition(spawn_x, DROPPED_ITEMS_SPAWN_HEIGHT, spawn_z)    
        inst.logs = inst.logs -1
    end
end

local function DropLogs(inst)
    
    DropLog(inst)
    DropLog(inst)
    if inst.logs < 1 then
        inst.logs = nil
        inst.drop_logs_task:Cancel()
        inst.drop_logs_task = nil        
    else
        inst.drop_logs_task = inst:DoTaskInTime(0.05, function() DropLogs(inst) end)
    end    
end

local function generate_items_to_drop(inst, itemnum)
    inst.items_to_drop = {}

    for i = 1, itemnum do
        table.insert(inst.items_to_drop, small_ram_products[math.random(1, #small_ram_products)])
    end
end

local function dropcanopy(inst, dropleaves)    
    DropItems(inst)
    if dropleaves then 
        inst.dropleaftask = inst:DoPeriodicTask(0.05, function() Dropleaves(inst)  end)
    end
end

local function dropcanopystuff(inst,num, dropleaves)
    if not inst.items_to_drop or num > #inst.items_to_drop then
        inst.items_to_drop = {}
        generate_items_to_drop(inst, num)
    end
    dropcanopy(inst,dropleaves)
end

local function spawnvine(inst)
    local x, _, z = inst.Transform:GetWorldPosition()
    local radius_variance = MAX - NEW_VINES_SPAWN_RADIUS_MIN
    local vine = SpawnPrefab("oceanvine")
    vine.components.pickable:MakeEmpty()
    local theta = math.random() * PI * 2
    local offset = NEW_VINES_SPAWN_RADIUS_MIN + radius_variance * math.random()
    vine.Transform:SetPosition(x + math.cos(theta) * offset, 0, z + math.sin(theta) * offset)
    vine:fall_down_fn()    

    vine.SoundEmitter:PlaySound("dontstarve/movement/foley/hidebush")
end


local VINE_TAGS = { "oceanvine" }
local function SpawnMissingVines(inst)
    local x, _, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, MAX, VINE_TAGS)
    local num_existing_vines = ents ~= nil and #ents or 0

    if num_existing_vines < 1  then 

        local num_new_vines = math.random(1,2)

        for i=1,num_new_vines do
            spawnvine(inst)
        end
    end
end

local COCOON_TAGS = {"webbed"}
local function alert_nearby_cocoons(inst, picker, loot)
    local px, py, pz = inst.Transform:GetWorldPosition()
    local nearby_cocoons = TheSim:FindEntities(px, py, pz, RAM_ALERT_COCOONS_RADIUS, COCOON_TAGS)
    for _, cocoon in ipairs(nearby_cocoons) do
        cocoon:PushEvent("activated", {target = picker})
    end
end

local DAMAGE_SCALE = 0.25
local function OnCollide(inst, data)

    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) / boat_physics.max_velocity + 0.5)

        if hit_velocity > 0.8 then
            inst:DoTaskInTime(0, function()                
                -- Delayed so that it is called after the inherent camera shake of boatphysics
                local time = TheWorld.state.cycles + TheWorld.state.time
                if inst.last_ram_time == nil or time - inst.last_ram_time >= TUNING.WATERTREE_PILLAR_RAM_RECHARGE_TIME then                
                    inst.last_ram_time = time
                    dropcanopystuff(inst, math.random(NUM_DROP_SMALL_ITEMS_MIN_RAM,NUM_DROP_SMALL_ITEMS_MAX_RAM))
                end
                ShakeAllCamerasOnPlatform(CAMERASHAKE.SIDE, 2.8, .025, .3, data.other)
            end)

            if inst.drop_items_task == nil or next(inst.items_to_drop) == nil then
                alert_nearby_cocoons(inst)

                local time = TheWorld.state.cycles + TheWorld.state.time
                if inst.last_ram_time == nil or time - inst.last_ram_time >= TUNING.WATERTREE_PILLAR_RAM_RECHARGE_TIME then
                    inst.last_ram_time = time

                    inst:DoTaskInTime(0.65, SpawnMissingVines)

                    dropcanopystuff(inst, math.random(NUM_DROP_SMALL_ITEMS_MIN,NUM_DROP_SMALL_ITEMS_MAX), true )
                end
            end

        end
    end    
end

local function chop_down_tree(inst, chopper)
    removecanopy(inst)
    inst.SoundEmitter:PlaySound("waterlogged2/common/watertree_pillar/fall")
    local pt = inst:GetPosition()

    inst:ListenForEvent("animover", function() 
        inst.falldone = true  
        if inst.itemsdone then
            inst:Remove() 
        end
    end)
    inst.AnimState:PlayAnimation("fall")

    inst:DoTaskInTime(7*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)    
    inst:DoTaskInTime(28*FRAMES,function() 
        inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/large")  
        spawnwaves(inst, 6, 360, 4, nil, 2, 2, nil, true)
    end)
    inst:DoTaskInTime(38*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)    
    inst:DoTaskInTime(51*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(56*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(60*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(63*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(68*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(75*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(94*FRAMES,function() 
        inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/large")  
        spawnwaves(inst, 6, 360, 4, nil, 2, 2, nil, true)
    end)    
    
    inst.components.lootdropper:DropLoot(pt)
    inst.removeme = true
    inst.persits = false
    dropcanopystuff(inst, math.random(NUM_DROP_SMALL_ITEMS_MIN,NUM_DROP_SMALL_ITEMS_MAX), true )
    inst.logs = 15
    DropLogs(inst)
    
    inst:DoTaskInTime(.5, function() ShakeAllCameras(CAMERASHAKE.FULL, 0.25, 0.03, 0.6, inst, 6) end)
end

local function OnRemove(inst)
    removecanopy(inst)
end

local function OnSprout(inst)

    inst.AnimState:PlayAnimation("grow_tall_to_pillar")
    inst.AnimState:PushAnimation("idle",true)    
end

local function OnBurnt(inst)
    removecanopy(inst)
    inst.SoundEmitter:PlaySound("waterlogged2/common/watertree_pillar/fall")
    local pt = inst:GetPosition()

    inst.components.lootdropper:SetLoot({"charcoal", "charcoal", "charcoal", "charcoal","charcoal", "charcoal", "charcoal"})
    inst.components.lootdropper:DropLoot(pt)

    inst:ListenForEvent("animover", function() 
        inst.falldone = true  
        if inst.itemsdone then
            inst:Remove() 
        end
    end)
    inst:DoTaskInTime(7*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)    
    inst:DoTaskInTime(28*FRAMES,function() 
        inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/large")  
        spawnwaves(inst, 6, 360, 4, nil, 2, 2, nil, true)
    end)
    inst:DoTaskInTime(38*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)    
    inst:DoTaskInTime(51*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(56*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(60*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(63*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(68*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(75*FRAMES,function() inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")  end)
    inst:DoTaskInTime(94*FRAMES,function() 
        inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/large")  
        spawnwaves(inst, 6, 360, 4, nil, 2, 2, nil, true)
    end)     
    inst.AnimState:PlayAnimation("burnt",false)

    inst.removeme = true
    inst.persits = false
    dropcanopystuff(inst, math.random(NUM_DROP_SMALL_ITEMS_MIN,NUM_DROP_SMALL_ITEMS_MAX), true )
    
    inst:DoTaskInTime(.5, function() ShakeAllCameras(CAMERASHAKE.FULL, 0.25, 0.03, 0.6, inst, 6) end)
end

local function DropLightningItems(inst, items)
    local x, _, z = inst.Transform:GetWorldPosition()
    local num_items = #items

    for i, item_prefab in ipairs(items) do
        local dist = DROP_ITEMS_DIST_MIN + DROP_ITEMS_DIST_VARIANCE * math.random()
        local theta = 2 * PI * math.random()

        inst:DoTaskInTime(i * 5 * FRAMES, function(inst2)
            local item = SpawnPrefab(item_prefab)
            item.Transform:SetPosition(x + dist * math.cos(theta), 20, z + dist * math.sin(theta))

            if i == num_items then
                inst._lightning_drop_task:Cancel()
                inst._lightning_drop_task = nil
            end 
        end)
    end
end

local function OnLightningStrike(inst)
    if inst._lightning_drop_task ~= nil then
        return
    end

    local num_small_items = math.random(NUM_DROP_SMALL_ITEMS_MIN_LIGHTNING, NUM_DROP_SMALL_ITEMS_MAX_LIGHTNING)
    local items_to_drop = {}

    for i = 1, num_small_items do
        table.insert(items_to_drop, small_ram_products[math.random(1, #small_ram_products)])
    end

    inst._lightning_drop_task = inst:DoTaskInTime(20*FRAMES, DropLightningItems, items_to_drop)
end

local function startvines(inst)
    inst:DoTaskInTime(2 + math.random(),function() spawnvine(inst) end)
    inst:DoTaskInTime(2.5 + math.random(),function() spawnvine(inst) end)
    inst:DoTaskInTime(2.5 + math.random(),function() spawnvine(inst) end)
    if math.random() < 0.33 then 
        inst:DoTaskInTime(3 + math.random(),function() spawnvine(inst) end)
    end
    inst.droppedvines = true
end


local function OnSave(inst, data)
    if inst.droppedvines then
        data.droppedvines = true
    end
end


local function OnLoad(inst, data)
    if data and data.droppedvines then
        inst.droppedvines = true
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    
    MakeWaterObstaclePhysics(inst, 1.5, 2, 0.75)

    inst:SetDeployExtraSpacing(TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 1.5)

    -- HACK: this should really be in the c side checking the maximum size of the anim or the _current_ size of the anim instead
    -- of frame 0
    inst.entity:SetAABB(60, 20)

    inst:AddTag("shadecanopysmall")
    inst:AddTag("event_trigger")

    inst.MiniMapEntity:SetIcon("oceantree_pillar_small.png")

    inst.AnimState:SetBank("oceantree_pillar_small")
    inst.AnimState:SetBuild("oceantree_pillar_small_build1")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:AddOverrideBuild("oceantree_pillar_small_build2")

    if not TheNet:IsDedicated() then
        inst:AddComponent("distancefade")
        inst.components.distancefade:Setup(15,25)
    end
    
    inst._hascanopy = net_bool(inst.GUID, "oceantree_pillar._hascanopy", "hascanopydirty")
    inst._hascanopy:set(true)    
    inst:DoTaskInTime(0, function()    
        inst.canopy_data = CANOPY_SHADOW_DATA.spawnshadow(inst, math.floor(TUNING.SHADE_CANOPY_RANGE_SMALL/4), true)
    end)

    inst:ListenForEvent("hascanopydirty", function()
                if not inst._hascanopy:value() then 
                    removecanopyshadow(inst) 
                end
        end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then        
        return inst
    end

    -- inst.canopy_data = nil
    inst.sproutfn = OnSprout

    -------------------
   
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"log", "log", "log", "log", "twigs", "twigs", "twigs"})

    inst.players = {}

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    inst.components.playerprox:SetDist(MIN, MAX)
    inst.components.playerprox:SetOnPlayerFar(OnFar)
    inst.components.playerprox:SetOnPlayerNear(OnNear)

    -------------------

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetMaxWork(TUNING.OCEANTREE_PILLAR_CHOPS)
    inst.components.workable:SetWorkLeft(TUNING.OCEANTREE_PILLAR_CHOPS)
    inst.components.workable:SetOnWorkCallback(chop_tree)
    inst.components.workable:SetOnFinishCallback(chop_down_tree)

    --------------------
    inst:AddComponent("inspectable")
    
    --------------------
    inst:AddComponent("lightningblocker")
    inst.components.lightningblocker:SetBlockRange(TUNING.SHADE_CANOPY_RANGE_SMALL)
    inst.components.lightningblocker:SetOnLightningStrike(OnLightningStrike)

    --------------------

    MakeLargeBurnable(inst)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetFXLevel(6)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst:ListenForEvent("on_collide", OnCollide)
    inst:ListenForEvent("onremove", OnRemove)

    inst._ripples = SpawnPrefab("oceantree_pillar_ripples")
    inst._ripples.entity:SetParent(inst.entity)
    
    inst.roots = SpawnPrefab("oceantree_pillar_roots")
    inst.roots.entity:SetParent(inst.entity)

    inst.OnSave = OnSave    
    inst.OnLoad = OnLoad

    inst:DoTaskInTime(0.5,function()
        if not inst.droppedvines then
            startvines(inst)
        end
    end)

    return inst
end

local function ripples_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("oceantree_pillar_small")
    inst.AnimState:SetBuild("oceantree_pillar_small_build1")
    inst.AnimState:PlayAnimation("root_ripple", true)
    inst.AnimState:AddOverrideBuild("oceantree_pillar_small_build2")

    inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function roots_fn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("oceantree_pillar_small")
    inst.AnimState:SetBuild("oceantree_pillar_small_build1")
    inst.AnimState:PlayAnimation("root_shadow", false)
    inst.AnimState:AddOverrideBuild("oceantree_pillar_small_build2")
    
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
    inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function leaves_fn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("oceantree_pillar_small")
    inst.AnimState:SetBuild("oceantree_pillar_small_build1")
    inst.AnimState:PlayAnimation("leaf_fall_ground", false)
    inst.AnimState:AddOverrideBuild("oceantree_pillar_small_build2")
    
    inst:ListenForEvent("animover", function() inst:Remove() end)

    inst:DoTaskInTime(0, function()  
            local point = Vector3(inst.Transform:GetWorldPosition())
            if not TheWorld.Map:IsVisualGroundAtPoint(point.x,point.y,point.z) then
                inst.AnimState:PlayAnimation("leaf_fall_water", false)     
                inst:DoTaskInTime(11*FRAMES, function() 
                    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")
                end)
            end

        end)
    
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("oceantree_pillar", fn, assets, prefabs),
    Prefab("oceantree_pillar_ripples", ripples_fn, assets),
    Prefab("oceantree_pillar_roots", roots_fn, assets),
    Prefab("oceantree_pillar_leaves", leaves_fn, assets)
