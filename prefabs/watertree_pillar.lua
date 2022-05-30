local CANOPY_SHADOW_DATA = require("prefabs/canopyshadows")

local assets =
{
    Asset("ANIM", "anim/oceantree_pillar_build1.zip"),
    Asset("ANIM", "anim/oceantree_pillar_build2.zip"),
    Asset("ANIM", "anim/oceantree_pillar.zip"),
   -- Asset("ANIM", "anim/oceantree_pillar_leaves.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
    Asset("MINIMAP_IMAGE", "oceantree_pillar"),
    Asset("SCRIPT", "scripts/prefabs/canopyshadows.lua")
}

local grassgator_regen_time = TUNING.GRASSGATOR_REGEN_TIME
local grassgator_release_time = TUNING.GRASSGATOR_RELEASE_TIME

local prefabs = 
{
    "oceantreenut",
    "oceanvine_cocoon",
}

local small_ram_products =
{
    "twigs",
    "cutgrass",
    "oceantree_leaf_fx_fall",
    "oceantree_leaf_fx_fall",
}

local ram_products_to_refabs = {}
for _, v in ipairs(small_ram_products) do
    ram_products_to_refabs[v] = true
end
for k, v in pairs(ram_products_to_refabs) do
    table.insert(prefabs, k)
end

local MIN = TUNING.SHADE_CANOPY_RANGE
local MAX = MIN + TUNING.WATERTREE_PILLAR_CANOPY_BUFFER

local DROP_ITEMS_DIST_MIN = 8
local DROP_ITEMS_DIST_VARIANCE = 12

local NUM_OCEANTREENUTS_MAX = 2
local START_NUM_OCEANTREENUTS = 1

local NUM_DROP_SMALL_ITEMS_MIN = 10
local NUM_DROP_SMALL_ITEMS_MAX = 14

local DROPPED_ITEMS_SPAWN_HEIGHT = 10

local RAM_ALERT_COCOONS_RADIUS = 25

local NEW_VINES_SPAWN_RADIUS_MIN = 6

local ATTEMPT_DROP_OCEANTREENUT_MAX_ATTEMPTS = 5
local ATTEMPT_DROP_OCEANTREENUT_RADIUS = 6

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

local UpdateShadowSize = function(shadow, height)
    local scaleFactor = Lerp(.5, 1.5, height / 35)
    shadow.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)
end 

local function spawnoverride(inst)
    local pt = Vector3(inst.Transform:GetWorldPosition())

    local theta = math.random() * 2* PI
    local radius = math.random()* 10 + 6

    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

    return offset
end

local function onspawnchild( inst, child )
    child.AnimState:PlayAnimation("idle_loop",true)
    child.Transform:SetRotation(180)

    local pt = Vector3(child.Transform:GetWorldPosition())
    child.Physics:Teleport(pt.x, 35, pt.z)
    child.UpdateShadowSize = UpdateShadowSize
    --child.updatetask = child:DoPeriodicTask(FRAMES, _GroundDetectionUpdate, nil, override_density)
    child:PushEvent("startfalling")    

    local home = Vector3(inst.Transform:GetWorldPosition())
    child.components.knownlocations:RememberLocation("home", home)
end

local function make_heavy_object_falling(inst, heavy_obj)
    heavy_obj.components.heavyobstaclephysics:AddFallingStates()
    heavy_obj:PushEvent("startfalling")
    
    heavy_obj.Physics:SetVel(0, 0, 0)
    
    heavy_obj.falltask = heavy_obj:DoPeriodicTask(FRAMES, function()
        local x, y, z = heavy_obj.Transform:GetWorldPosition()
        if y <= 0.2 then
            if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
                -- By this point the dropped object has submerged, so this position is local to the underwater container object
                heavy_obj.Transform:SetPosition(0, 0, 0)
            end

            heavy_obj:PushEvent("stopfalling")

            if heavy_obj.falltask then
                heavy_obj.falltask:Cancel()
                heavy_obj.falltask = nil
            end
        end
    end)
end

local OCEANTREENUT_BLOCKER_TAGS = { "tree" }
local function DropItems(inst)
    local ind = math.random(1, #inst.items_to_drop)
    local item_to_spawn = inst.items_to_drop[ind]

    local x, _, z = inst.Transform:GetWorldPosition()

    local item = SpawnPrefab(item_to_spawn)

    local dist = DROP_ITEMS_DIST_MIN + DROP_ITEMS_DIST_VARIANCE * math.random()
    local theta = math.random() * 2 * PI

    local spawn_x, spawn_z

    if item:HasTag("heavy") then
        for i=1,ATTEMPT_DROP_OCEANTREENUT_MAX_ATTEMPTS do
            spawn_x, spawn_z = x + math.cos(theta) * dist, z + math.sin(theta) * dist

            local blockers = TheSim:FindEntities(spawn_x, 0, spawn_z, ATTEMPT_DROP_OCEANTREENUT_RADIUS, OCEANTREENUT_BLOCKER_TAGS)
            if blockers ~= nil and next(blockers) ~= nil then
                dist = DROP_ITEMS_DIST_MIN + DROP_ITEMS_DIST_VARIANCE * math.random()
                theta = math.random() * 2 * PI
            else
                break
            end
        end
        -- If no free position is found we accept the last randomized position

        make_heavy_object_falling(inst, item)
        inst.num_oceantreenuts = inst.num_oceantreenuts - 1

        if not inst.components.timer:TimerExists("regrow_oceantreenut") then
            inst.components.timer:StartTimer("regrow_oceantreenut", TUNING.OCEANTREENUT_REGENERATE_TIME + math.random() * TUNING.OCEANTREENUT_REGENERATE_TIME_VARIANCE)
        end
    else
        spawn_x, spawn_z = x + math.cos(theta) * dist, z + math.sin(theta) * dist
    end
    
    item.Transform:SetPosition(spawn_x, DROPPED_ITEMS_SPAWN_HEIGHT, spawn_z)

    if #inst.items_to_drop <= 1 then
        inst.items_to_drop = nil
        inst.drop_items_task = nil
    else
        table.remove(inst.items_to_drop, ind)
        inst:DoTaskInTime(0.1, DropItems)
    end
end

local function generate_items_to_drop(inst)
    inst.items_to_drop = {}

    if inst.num_oceantreenuts ~= nil and inst.num_oceantreenuts > 0 then
        table.insert(inst.items_to_drop, "oceantreenut")
    end

    local num_small_items = math.random(NUM_DROP_SMALL_ITEMS_MIN, NUM_DROP_SMALL_ITEMS_MAX)
    for i = 1, num_small_items do
        table.insert(inst.items_to_drop, small_ram_products[math.random(1, #small_ram_products)])
    end
end

-- Water Strider Cocoon Management ----------------------------------------------------------------
local COCOON_TAGS = {"webbed"}
local function alert_nearby_cocoons(inst, picker, loot)
    local px, py, pz = inst.Transform:GetWorldPosition()
    local nearby_cocoons = TheSim:FindEntities(px, py, pz, RAM_ALERT_COCOONS_RADIUS, COCOON_TAGS)
    for _, cocoon in ipairs(nearby_cocoons) do
        cocoon:PushEvent("activated", {target = picker})
    end
end

local MIN_RESPAWN_DIST = 5
local RESPAWN_DISC_WIDTH = RAM_ALERT_COCOONS_RADIUS - MIN_RESPAWN_DIST
local function cocoon_regrow_check(inst)
    local px, _, pz = inst.Transform:GetWorldPosition()

    local new_cocoon = SpawnPrefab("oceanvine_cocoon")
    local angle = 2*PI*math.random()
    local radius = (RESPAWN_DISC_WIDTH * math.sqrt(math.random())) + MIN_RESPAWN_DIST

    new_cocoon.Transform:SetPosition(px + radius * math.cos(angle), 0, pz + radius * math.sin(angle))
    new_cocoon.AnimState:PlayAnimation("enter")
    new_cocoon.AnimState:PushAnimation("idle", true)

    inst._cocoons_to_regrow = inst._cocoons_to_regrow - 1
    if inst._cocoons_to_regrow > 0 then
        inst.components.timer:StartTimer("cocoon_regrow_check", TUNING.OCEANVINE_COCOON_REGEN_BASE + TUNING.OCEANVINE_COCOON_REGEN_RAND*math.random())
    end
end
---------------------------------------------------------------------------------------------------

local VINE_TAGS = { "oceanvine" }
local function SpawnMissingVines(inst)
    local x, _, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, MAX, VINE_TAGS)
    local num_existing_vines = ents ~= nil and #ents or 0

    if num_existing_vines < TUNING.OCEANTREE_VINE_DROP_MAX+ math.random(1,2)-1  then 

        local num_new_vines = math.random(1,2)
        local radius_variance = MAX - NEW_VINES_SPAWN_RADIUS_MIN

        for i=1,num_new_vines do
            local vine = SpawnPrefab("oceanvine")
            local theta = math.random() * PI * 2
            local offset = NEW_VINES_SPAWN_RADIUS_MIN + radius_variance * math.random()
            vine.Transform:SetPosition(x + math.cos(theta) * offset, 0, z + math.sin(theta) * offset)
            vine:fall_down_fn()
        end
    end
end

local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) / boat_physics.max_velocity + 0.5)

        if hit_velocity > 0.8 then
            inst:DoTaskInTime(0, function()
                -- Delayed so that it is called after the inherent camera shake of boatphysics
                ShakeAllCamerasOnPlatform(CAMERASHAKE.SIDE, 2.8, .025, .3, data.other)
            end)

            if inst.drop_items_task == nil or next(inst.items_to_drop) == nil then
                alert_nearby_cocoons(inst)

                local time = TheWorld.state.cycles + TheWorld.state.time
                if inst.last_ram_time == nil or time - inst.last_ram_time >= TUNING.WATERTREE_PILLAR_RAM_RECHARGE_TIME then
                    inst.last_ram_time = time

                    inst:DoTaskInTime(0.65, SpawnMissingVines)

                    generate_items_to_drop(inst)
                    inst:DoTaskInTime(0.5, DropItems)
                end
            end
        end
    end
end

local function OnTimerDone(inst, data)
    if data ~= nil then
        if data.name == "regrow_oceantreenut" then
            inst.num_oceantreenuts = inst.num_oceantreenuts + 1
            if inst.num_oceantreenuts < NUM_OCEANTREENUTS_MAX then
                inst.components.timer:StartTimer("regrow_oceantreenut", TUNING.OCEANTREENUT_REGENERATE_TIME + math.random() * TUNING.OCEANTREENUT_REGENERATE_TIME_VARIANCE)
            end
        elseif data.name == "cocoon_regrow_check" then
            cocoon_regrow_check(inst)
        end
    end
end

local function OnNearbyCocoonDestroyed(inst, data)
    inst._cocoons_to_regrow = inst._cocoons_to_regrow + 1

    if not inst.components.timer:TimerExists("cocoon_regrow_check") then
        inst.components.timer:StartTimer("cocoon_regrow_check", TUNING.OCEANVINE_COCOON_REGEN_BASE + TUNING.OCEANVINE_COCOON_REGEN_RAND*math.random())
    end
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

    local num_small_items = math.random(NUM_DROP_SMALL_ITEMS_MIN, NUM_DROP_SMALL_ITEMS_MAX)
    local items_to_drop = {}

    for i = 1, num_small_items do
        table.insert(items_to_drop, small_ram_products[math.random(1, #small_ram_products)])
    end

    inst._lightning_drop_task = inst:DoTaskInTime(20*FRAMES, DropLightningItems, items_to_drop)
end

local function OnSave(inst, data)
    data.num_oceantreenuts = inst.num_oceantreenuts
    if inst.last_ram_time ~= nil then
        data.last_ram_time = inst.last_ram_time
    end

    if inst._cocoons_to_regrow ~= nil then
        data.cocoons_to_regrow = inst._cocoons_to_regrow
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, grassgator_release_time, grassgator_regen_time)
end

local function OnLoad(inst, data)
    if data then
        if data.num_oceantreenuts then
            inst.num_oceantreenuts = data.num_oceantreenuts
        end

        if data.last_ram_time then
            inst.last_ram_time = data.last_ram_time
        end

        if data.cocoons_to_regrow ~= nil then
            inst._cocoons_to_regrow = data.cocoons_to_regrow
        end
    end
end

local function OnLoadPostPass(inst, ents, data)

end

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
                player.canopytrees = player.canopytrees - 1
                player:PushEvent("onchangecanopyzone", player.canopytrees > 0)
            end
        end
    end

    inst._hascanopy:set(false)
end

local function OnRemove(inst)
    removecanopy(inst)
end
local FIREFLY_MUST = {"firefly"}
local function OnPhaseChanged(inst, phase)
   if phase == "day" then

        local x, y, z = inst.Transform:GetWorldPosition()

        if TheSim:CountEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE, FIREFLY_MUST) < 10 then
            if math.random()<0.7 then
                local pos = nil
                local offset = nil
                local count = 0
                while offset == nil and count < 10 do
                    local angle = 2*PI*math.random()
                    local radius = math.random() * (TUNING.SHADE_CANOPY_RANGE -4)
                    offset = {x= math.cos(angle) * radius, y=0, z=math.sin(angle) * radius}   
                    count = count + 1

                    pos = {x=x+offset.x,y=0,z=z+offset.z}

                    if TheSim:CountEntities(pos.x, pos.y, pos.z, 5) > 0 then
                        offset = nil
                    end
                end

                if offset then
                    local firefly = SpawnPrefab("fireflies")
                    firefly.Transform:SetPosition(x+offset.x,0,z+offset.z)
                end
            end
        end
   end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeWaterObstaclePhysics(inst, 4, 2, 0.75)

    inst:SetDeployExtraSpacing(TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4)

    -- HACK: this should really be in the c side checking the maximum size of the anim or the _current_ size of the anim instead
    -- of frame 0
    inst.entity:SetAABB(60, 20)

    inst:AddTag("cocoon_home")
    inst:AddTag("shadecanopy")

    inst.MiniMapEntity:SetIcon("oceantree_pillar.png")

    inst.AnimState:SetBank("oceantree_pillar")
    inst.AnimState:SetBuild("oceantree_pillar_build1")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:AddOverrideBuild("oceantree_pillar_build2")

    if not TheNet:IsDedicated() then
        inst:AddComponent("distancefade")
        inst.components.distancefade:Setup(15,25)
    end

    inst._hascanopy = net_bool(inst.GUID, "oceantree_pillar._hascanopy", "hascanopydirty")
    inst._hascanopy:set(true)  
    inst:ListenForEvent("hascanopydirty", function()
                if not inst._hascanopy:value() then 
                    removecanopyshadow(inst) 
                end
        end)

    inst:DoTaskInTime(0,function()
        inst.canopy_data = CANOPY_SHADOW_DATA.spawnshadow(inst, math.floor(TUNING.SHADE_CANOPY_RANGE/4))
    end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst.target_num_oceanvines = nil
    -- inst.items_to_drop = nil
    -- inst.drop_items_task = nil
    -- inst.last_ram_time = nil
    inst.num_oceantreenuts = START_NUM_OCEANTREENUTS
    inst._cocoons_to_regrow = 0

    -------------------

    inst.players = {}
   
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    inst.components.playerprox:SetDist(MIN, MAX)
    inst.components.playerprox:SetOnPlayerFar(OnFar)
    inst.components.playerprox:SetOnPlayerNear(OnNear)

    --------------------
    inst:AddComponent("inspectable")

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "grassgator"
    inst.components.childspawner:SetRegenPeriod(grassgator_regen_time)  
    inst.components.childspawner:SetSpawnPeriod(grassgator_release_time)
    inst.components.childspawner:SetMaxChildren(TUNING.GRASSGATOR_MAXCHILDREN)
    inst.components.childspawner.overridespawnlocation = spawnoverride

    WorldSettings_ChildSpawner_SpawnPeriod(inst, grassgator_release_time, TUNING.GRASSGATOR_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, grassgator_regen_time, TUNING.GRASSGATOR_ENABLED)

    if not TUNING.GRASSGATOR_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    --------------------
    inst:AddComponent("timer")

    --------------------
    inst:AddComponent("lightningblocker")
    inst.components.lightningblocker:SetBlockRange(TUNING.SHADE_CANOPY_RANGE)
    inst.components.lightningblocker:SetOnLightningStrike(OnLightningStrike)

    inst:ListenForEvent("on_collide", OnCollide)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("cocoon_destroyed", OnNearbyCocoonDestroyed)
    inst:ListenForEvent("onremove", OnRemove)
    inst:ListenForEvent("phasechanged", function(src, phase) OnPhaseChanged(inst,phase) end, TheWorld)

    --inst.components.childspawner.canspawnfn = canspawn
    inst.components.childspawner:SetSpawnedFn(onspawnchild)
    inst.components.childspawner:StartSpawning()


    inst._ripples = SpawnPrefab("watertree_pillar_ripples")
    inst._ripples.entity:SetParent(inst.entity)

    inst.roots = SpawnPrefab("watertree_pillar_roots")
    inst.roots.entity:SetParent(inst.entity)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

local function ripples_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("oceantree_pillar")
    inst.AnimState:SetBuild("oceantree_pillar_build1")
    inst.AnimState:PlayAnimation("root_ripple", true)

    inst.AnimState:AddOverrideBuild("oceantree_pillar_build2")

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

    inst.AnimState:SetBank("oceantree_pillar")
    inst.AnimState:SetBuild("oceantree_pillar_build1")
    inst.AnimState:PlayAnimation("root_shadow", false)

    inst.AnimState:AddOverrideBuild("oceantree_pillar_build2")
    
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
    inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("watertree_pillar", fn, assets, prefabs),
    Prefab("watertree_pillar_ripples", ripples_fn, assets),
    Prefab("watertree_pillar_roots", roots_fn, assets)
