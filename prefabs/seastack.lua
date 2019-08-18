local assets =
{
    Asset("ANIM", "anim/water_rock_01.zip"),
    Asset("MINIMAP_IMAGE", "seastack"),
}

local prefabs =
{
    
}

SetSharedLootTable( 'seastack',
{
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'rocks',  1.00},
})


local function updateart(inst)

    local workleft = inst.components.workable.workleft
    inst.AnimState:PlayAnimation(
        (workleft > 6 and inst.stackid.."_full") or
        (workleft > 3 and inst.has_medium_state and inst.stackid.."_med") or inst.stackid.."_low"
    )
end

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        local pt = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())

        local loot_dropper = inst.components.lootdropper
        --local boat_physics = worker.components.boatphysics

        inst:SetPhysicsRadiusOverride(nil)

        --if boat_physics ~= nil then
    --        loot_dropper.min_speed = 3
    --        loot_dropper.max_speed = 5.5
    --        loot_dropper:SetFlingTarget(worker:GetPosition(), 20)
        --end

        loot_dropper:DropLoot(pt)

        inst:Remove()
    else
        updateart(inst)
    end
end

local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local damage_scale = 0.5
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * damage_scale / boat_physics.max_velocity + 0.5)
        inst.components.workable:WorkedBy(data.other, hit_velocity * TUNING.SEASTACK_MINE)
    end
end



local function SetupStack(inst, stackid)
    if inst.stackid == nil then
        inst.stackid = stackid or math.random(5)
    end

    if inst.stackid == 4 then
        inst.components.floater:SetVerticalOffset(0.2)
        inst.components.floater:SetScale(0.85)
        inst.components.floater:SetSize("large")
        inst.has_medium_state = true
    elseif inst.stackid == 3 then
        inst.components.floater:SetVerticalOffset(0.2)
        inst.components.floater:SetScale(0.72)
        inst.components.floater:SetSize("large")   
    elseif inst.stackid == 2 then
        inst.has_medium_state = true
    elseif inst.stackid == 1 then        
        inst.components.floater:SetScale(1.1)    
        inst.components.floater:SetVerticalOffset(0.15)
        inst.has_medium_state = true
    end

    updateart(inst)
end

local function onsave(inst, data)
    data.stackid = inst.stackid
end

local function onload(inst, data)
    SetupStack(inst, data ~= nil and data.stackid or nil)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("seastack.png")

    inst:SetPhysicsRadiusOverride(2.35)

    MakeWaterObstaclePhysics(inst, 0.80, 2, 1.25)

    inst:AddTag("ignorewalkableplatforms")

    inst.AnimState:SetBank("water_rock01")
    inst.AnimState:SetBuild("water_rock_01")
    inst.AnimState:PlayAnimation("1_full")

    MakeInventoryFloatable(inst, "med", nil, 0.85)
    inst.components.floater.bob_percent = 0

    inst.entity:SetPristine()    

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0, function(inst)
        SetupStack(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst:AddComponent("lootdropper")     
    inst.components.lootdropper:SetChanceLootTable('seastack')
    inst.components.lootdropper.max_speed = 2
    inst.components.lootdropper.min_speed = 0.3
    inst.components.lootdropper.y_speed = 14
    inst.components.lootdropper.y_speed_variance = 4
    inst.components.lootdropper.spawn_loot_inside_prefab = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.SEASTACK_MINE)
    inst.components.workable:SetOnWorkCallback(OnWork)    

    inst:AddComponent("inspectable")

    inst:ListenForEvent("on_collide", OnCollide)

    --------SaveLoad
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

--[[
local function checkforseastackspawning(inst)

end
]]

local function spawnerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()    

    if not TheWorld.ismastersim then
        return inst
    end
    --[[
    inst:DoTaskInTime(math.random()*20,function()
            inst:DoPeriodicTask(20,function()
                checkforseastackspawning(inst)
            end)
        end)
        ]]
--[[
    inst:DoTaskInTime(0,function() 
            local mark = SpawnPrefab("log")
            local x,y,z = inst.Transform:GetWorldPosition()
            mark.Transform:SetPosition(x,y,z)
        end)
        ]]
    return inst
end

return Prefab("seastack", fn, assets, prefabs),
       Prefab("seastack_spawner_swell", spawnerfn, assets, prefabs),
       Prefab("seastack_spawner_rough", spawnerfn, assets, prefabs)
