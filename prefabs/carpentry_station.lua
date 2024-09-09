require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/carpentry_station.zip"),
    Asset("MINIMAP_IMAGE", "carpentry_station"),
}

local prefabs =
{
    "ash",
    "collapse_small",
}

----
local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT") or nil
end

local function OnHammered(inst, worker)
    if inst.components.burnable and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    if inst:HasTag("burnt") then
        inst.components.lootdropper:SpawnLootPrefab("ash")
    else
        inst.components.lootdropper:DropLoot()
    end

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

local function OnHit(inst, worker)
    if inst:HasTag("burnt") then return end

    inst.AnimState:PlayAnimation("hit_open")
    inst.AnimState:PushAnimation(inst.components.prototyper.on and "proximity_loop" or "idle", inst.components.prototyper.on)
end

--
local function OnTurnOn(inst)
    if inst:HasTag("burnt") then return end

    if inst.AnimState:IsCurrentAnimation("proximity_loop") or inst.AnimState:IsCurrentAnimation("place") or inst.AnimState:IsCurrentAnimation("use") then
        inst.AnimState:PushAnimation("proximity_loop", true)
    else
        inst.AnimState:PlayAnimation("proximity_loop", true)
    end

    if not inst.SoundEmitter:PlayingSound("loop_sound") then
        inst.SoundEmitter:PlaySound("rifts3/sawhorse/proximity_lp", "loop_sound")
    end
end

local function OnTurnOff(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:KillSound("loop_sound")
        inst.SoundEmitter:PlaySound("rifts3/sawhorse/proximity_lp_pst")
    end
end

local function OnActivate(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("use")
        inst.AnimState:PushAnimation("proximity_loop", true)
        inst.SoundEmitter:PlaySound("rifts3/sawhorse/use")
    end
end

--
local CACHED_RECIPE_COST = nil
local function CacheRecipeCost()
    local boardsrecipe = AllRecipes.boards
    if boardsrecipe == nil or boardsrecipe.ingredients == nil then
        return false
    end

    local neededlogs = 0
    for _, ingredient in ipairs(boardsrecipe.ingredients) do
        if ingredient.type ~= "log" then
            return false
        end
        neededlogs = neededlogs + ingredient.amount
    end

    return neededlogs
end
local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("rifts3/sawhorse/place")
end

local function AbleToAcceptTest(inst, item, giver, count)
    if not CACHED_RECIPE_COST then
        return false
    end

    if inst._sawingtask ~= nil then
        return false, "BUSY"
    end

    if inst:HasTag("burnt") or item.prefab ~= "log" then
        return false
    end

    if count == nil or count < CACHED_RECIPE_COST then
        return false
    end

    return true
end

local function GiveOrDropItem(item, doer, inst, pos)
    local pos = inst:GetPosition()

    if doer and doer:IsValid() and doer.components.inventory ~= nil and inst:IsNear(doer, TUNING.RESEARCH_MACHINE_DIST) then
        doer.components.inventory:GiveItem(item, nil, pos)
    else
        inst.components.lootdropper:FlingItem(item, pos)
    end
end

local function GiveBoards(inst, giver, item, count)
    inst._stored_logs_count = nil
    inst._sawingtask = nil

    if not CACHED_RECIPE_COST then
        return
    end

    inst.AnimState:PlayAnimation(inst.components.prototyper.on and "proximity_loop" or "idle", inst.components.prototyper.on)

    local moisture, iswet
    if item then
        moisture, iswet = item.components.inventoryitem:GetMoisture(), item.components.inventoryitem:IsWet()
    else
        moisture, iswet = TheWorld.state.wetness, TheWorld.state.iswet
    end
    local pos = inst:GetPosition()

    local i = 1
    while i * CACHED_RECIPE_COST <= count do
        local loot = SpawnPrefab("boards")
        local room = loot.components.stackable ~= nil and loot.components.stackable:RoomLeft() or 0
        if room > 0 then
            local stacksize = math.floor(count / CACHED_RECIPE_COST)
            loot.components.stackable:SetStackSize(stacksize)
            loot.components.inventoryitem:InheritMoisture(moisture, iswet)
            i = i + stacksize
        else
            i = i + 1
        end
        GiveOrDropItem(loot, giver, inst, pos)
    end
    count = count - (i - 1) * CACHED_RECIPE_COST
    while count > 0 do
        local loot = SpawnPrefab("log")
        local room = loot.components.stackable ~= nil and loot.components.stackable:RoomLeft() or 0
        if room > 0 then
            local stacksize = math.min(count, room)
            loot.components.stackable:SetStackSize(stacksize)
            loot.components.inventoryitem:InheritMoisture(moisture, iswet)
            count = count - stacksize
        else
            count = count - 1
        end
        GiveOrDropItem(loot, giver, inst, pos)
    end
end

local function OnLogsGiven(inst, giver, item, count)
    if not CACHED_RECIPE_COST then
        return
    end

    if count == nil or count < CACHED_RECIPE_COST then
        return
    end

    inst.AnimState:PlayAnimation("use")
    inst.SoundEmitter:PlaySound("rifts3/sawhorse/use")

    inst._stored_logs_count = count
    inst._sawingtask = inst:DoTaskInTime(28 * FRAMES, GiveBoards, giver, item, count)
end

--
local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
    data.logs = inst._stored_logs_count
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.burnt then
        inst.components.burnable.onburnt(inst)
    end
    inst._stored_logs_count = data.logs
end

local function OnLoadPostPass(inst)
    if inst._stored_logs_count then
        GiveBoards(inst, nil, nil, inst._stored_logs_count)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1.25) --recipe min_spacing/2
    inst:SetPhysicsRadiusOverride(0.5)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.MiniMapEntity:SetIcon("carpentry_station.png")

    inst:AddTag("structure")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    inst.AnimState:SetBank("carpentry_station")
    inst.AnimState:SetBuild("carpentry_station")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    if CACHED_RECIPE_COST == nil then
        CACHED_RECIPE_COST = CacheRecipeCost()
    end

    --
    local hauntable = inst:AddComponent("hauntable")
    hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    --
    local inspectable = inst:AddComponent("inspectable")
    inspectable.getstatus = GetStatus

    --
    inst:AddComponent("lootdropper")

    --
    local prototyper = inst:AddComponent("prototyper")
    prototyper.onturnon = OnTurnOn
    prototyper.onturnoff = OnTurnOff
    prototyper.onactivate = OnActivate
    prototyper.trees = TUNING.PROTOTYPER_TREES.CARPENTRY_STATION

    --
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(2)
    workable:SetOnFinishCallback(OnHammered)
    workable:SetOnWorkCallback(OnHit)

    local trader = inst:AddComponent("trader")
    trader:SetAcceptStacks()
    trader:SetAbleToAcceptTest(AbleToAcceptTest)
    trader:SetOnAccept(OnLogsGiven)

    --
    MakeMediumBurnable(inst, nil, nil, true, "station_parts")
    MakeSmallPropagator(inst)

    --
    inst:ListenForEvent("onbuilt", OnBuilt)

    --
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("carpentry_station", fn, assets, prefabs),
    MakePlacer("carpentry_station_placer", "carpentry_station", "carpentry_station", "idle")
