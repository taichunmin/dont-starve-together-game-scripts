require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/bird_cage.zip"),

    Asset("ANIM", "anim/crow_build.zip"),
    Asset("ANIM", "anim/robin_build.zip"),
    Asset("ANIM", "anim/robin_winter_build.zip"),
    Asset("ANIM", "anim/canary_build.zip"),
    Asset("ANIM", "anim/bird_mutant_build.zip"),
    Asset("ANIM", "anim/bird_mutant_spitter_build.zip"),
}

local prefabs =
{
    "bird_egg",
    "crow",
    "robin",
    "robin_winter",
    "canary",
    "guano",
    "rottenegg",
}

local invalid_foods =
{
    "bird_egg",
    "bird_egg_cooked",
    "rottenegg",
    -- "monstermeat",
    -- "cookedmonstermeat",
    -- "monstermeat_dried",
}

local CAGE_STATES =
{
    DEAD = "_death",
    SKELETON = "_skeleton",
    EMPTY = "_empty",
    FULL = "_bird",
    SICK = "_sick",
}

local function SetBirdType(inst, bird)
    if inst.bird_type then
        inst.AnimState:ClearOverrideBuild(inst.bird_type.."_build")
    end
    inst.bird_type = bird
    inst.AnimState:AddOverrideBuild(inst.bird_type.."_build")
end

local function SetCageState(inst, state)
    inst.CAGE_STATE = state
end

--Only use for hit and idle anims
local function PlayStateAnim(inst, anim, loop)
    inst.AnimState:PlayAnimation(anim..inst.CAGE_STATE, loop)
end

--Only use for hit and idle anims
local function PushStateAnim(inst, anim, loop)
    inst.AnimState:PushAnimation(anim..inst.CAGE_STATE, loop)
end

local function GetBird(inst)
    return (inst.components.occupiable and inst.components.occupiable:GetOccupant()) or nil
end

local function GetHunger(bird)
    return (bird and bird.components.perishable and bird.components.perishable:GetPercent()) or 1
end

local function DigestFood(inst, food)
    if food.components.edible.foodtype == FOODTYPE.MEAT then
        --If the food is meat:
            --Spawn an egg.
        if inst.components.occupiable and inst.components.occupiable:GetOccupant() and inst.components.occupiable:GetOccupant():HasTag("bird_mutant") then
            inst.components.lootdropper:SpawnLootPrefab("rottenegg")
        else
            inst.components.lootdropper:SpawnLootPrefab("bird_egg")
        end
    else
        if inst.components.occupiable and inst.components.occupiable:GetOccupant() and inst.components.occupiable:GetOccupant():HasTag("bird_mutant") then
            inst.components.lootdropper:SpawnLootPrefab("spoiled_food")

        else
            local seed_name = string.lower(food.prefab .. "_seeds")
            if Prefabs[seed_name] ~= nil then
    			inst.components.lootdropper:SpawnLootPrefab(seed_name)
            else
                --Otherwise...
                    --Spawn a poop 1/3 times.
                if math.random() < 0.33 then
                    local loot = inst.components.lootdropper:SpawnLootPrefab("guano")
                    loot.Transform:SetScale(.33, .33, .33)
                end
            end
        end
    end

    --Refill bird stomach.
    local bird = GetBird(inst)
    if bird and bird:IsValid() and bird.components.perishable then
        bird.components.perishable:SetPercent(1)
    end
end

local function ShouldAcceptItem(inst, item)
    local seed_name = string.lower(item.prefab .. "_seeds")

    local can_accept = item.components.edible
        and (Prefabs[seed_name]
        or item.prefab == "seeds"
        or string.match(item.prefab, "_seeds")
        or item.components.edible.foodtype == FOODTYPE.MEAT)

    if table.contains(invalid_foods, item.prefab) then
        can_accept = false
    end

    return can_accept
end

local function OnGetItem(inst, giver, item)
    --If you're sleeping, wake up.
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end

    if item.components.edible ~= nil and
        (   item.components.edible.foodtype == FOODTYPE.MEAT
            or item.prefab == "seeds"
            or string.match(item.prefab, "_seeds")
            or Prefabs[string.lower(item.prefab .. "_seeds")] ~= nil
        ) then
        --If the item is edible...
        --Play some animations (peck, peck, peck, hop, idle)
        inst.AnimState:PlayAnimation("peck")
        inst.AnimState:PushAnimation("peck")
        inst.AnimState:PushAnimation("peck")
        inst.AnimState:PushAnimation("hop")
        PushStateAnim(inst, "idle", true)
        --Digest Food in 60 frames.
        inst:DoTaskInTime(60 * FRAMES, DigestFood, item)
    end
end

local function OnRefuseItem(inst, item)
    --Play animation (flap, idle)
    inst.AnimState:PlayAnimation("flap")
    PushStateAnim(inst, "idle", true)
    --Play sound (wingflap in cage)
    inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
end

local function DoPlaySound(inst, soundname)
    inst.SoundEmitter:PlaySound(soundname)
end

local function DoAnimationTask(inst)
    local bird = GetBird(inst)
    local hunger = GetHunger(bird)
    local rand = math.random()

    if hunger < 0.33 then
    --If you're REALLY hungry...
        --Play either idle or idle3
        if rand < 0.75 then
            inst.AnimState:PlayAnimation("idle_bird3")
            --Flaps - 5, 15, 28, 99
            inst:DoTaskInTime(5 * FRAMES, DoPlaySound, "dontstarve/birds/wingflap_cage")
            inst:DoTaskInTime(15 * FRAMES, DoPlaySound, "dontstarve/birds/wingflap_cage")
            inst:DoTaskInTime(28 * FRAMES, DoPlaySound, "dontstarve/birds/wingflap_cage")
            inst:DoTaskInTime(99 * FRAMES, DoPlaySound, "dontstarve/birds/wingflap_cage")
            --Chirps - 4, 27, 42, 100
            inst:DoTaskInTime(4 * FRAMES, DoPlaySound, bird.sounds.chirp)
            inst:DoTaskInTime(27 * FRAMES, DoPlaySound, bird.sounds.chirp)
            inst:DoTaskInTime(42 * FRAMES, DoPlaySound, bird.sounds.chirp)
            inst:DoTaskInTime(100 * FRAMES, DoPlaySound, bird.sounds.chirp)
        end
    elseif hunger < 0.66 then
    --If you're hungry...
        --Play either idle or idle2
        if rand < 0.5 then
            inst.AnimState:PlayAnimation("idle_bird2")
            --26, 81, 96
            inst:DoTaskInTime(26 * FRAMES, DoPlaySound, bird.sounds.chirp)
            inst:DoTaskInTime(81 * FRAMES, DoPlaySound, bird.sounds.chirp)
            inst:DoTaskInTime(96 * FRAMES, DoPlaySound, bird.sounds.chirp)
        end
    else
    --If you're content...
        --Play either caw (50%), flap (10%) or hop (40%)
        if rand < 0.5 then
            inst.AnimState:PlayAnimation("caw")
            if inst.chirpsound then
                inst.SoundEmitter:PlaySound(inst.chirpsound)
            end
        elseif rand < 0.6 then
            inst.AnimState:PlayAnimation("flap")
            inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
        else
            inst.AnimState:PlayAnimation("hop")
        end
    end
    --End with pushing "idle" animation
    PushStateAnim(inst, "idle", true)
end

local function StartAnimationTask(inst)
    if inst.AnimationTask ~= nil then
        inst.AnimationTask:Cancel()
    end
    inst.AnimationTask = inst:DoPeriodicTask(6, DoAnimationTask)
end

local function StopAnimationTask(inst)
    if inst.AnimationTask then
        inst.AnimationTask:Cancel()
        inst.AnimationTask = nil
    end
end

local function ShouldSleep(inst)
    --Sleep during night, but not if you're very hungry.
    local bird = GetBird(inst)
    return bird and bird.components.sleeper and DefaultSleepTest(bird) and GetHunger(bird) >= 0.33
end

local function GoToSleep(inst)
    if inst.components.occupiable:IsOccupied() then
        StopAnimationTask(inst)
        inst.AnimState:PlayAnimation("sleep_pre")
        inst.AnimState:PushAnimation("sleep_loop", true)
    end
end

local function ShouldWake(inst)
    --Wake during day or if you're very hungry.
    local bird = GetBird(inst)
    return bird and DefaultWakeTest(bird) or GetHunger(bird) < 0.33
end

local function WakeUp(inst)
    if inst.components.occupiable:IsOccupied() then
        inst.AnimState:PlayAnimation("sleep_pst")
        PushStateAnim(inst, "idle", true)
        StartAnimationTask(inst)
    end
end

local function OnOccupied(inst, bird)
    SetCageState(inst, CAGE_STATES.FULL)

    --Add the sleeper component & initialize
    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)

    --Enable the trader component
    inst.components.trader:Enable()

    --Set up the bird symbol, play an animation.
    SetBirdType(inst, bird.prefab)

    inst.chirpsound = bird.sounds and bird.sounds.chirp
    inst.AnimState:PlayAnimation("flap")
    inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
    PushStateAnim(inst, "idle", true)

    --Start the idling task
    StartAnimationTask(inst)
end

local function OnEmptied(inst, bird)

    if inst.bird_type then
        inst.AnimState:ClearOverrideBuild(inst.bird_type.."_build")
    end

    SetCageState(inst, CAGE_STATES.EMPTY)

    --Remove sleeper component
    inst:RemoveComponent("sleeper")

    --Disable trader component
    inst.components.trader:Disable()

    --Refresh anim state.
    PlayStateAnim(inst, "idle", false)

    --Stop the idling task
    StopAnimationTask(inst)
end

local function OnWorkFinished(inst, worker)
    --If there is a bird inside drop the proper loot (bird, meat or rot)
    if inst.components.occupiable and inst.components.occupiable:IsOccupied() then
        local item = inst.components.occupiable:Harvest()
        if item then
            item.Transform:SetPosition(inst.Transform:GetWorldPosition())
            item.components.inventoryitem:OnDropped()
        end
    end
    inst.components.lootdropper:DropLoot()
    inst.components.inventory:DropEverything(true)

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function OnWorked(inst, worker)
    --If there is a bird play the bird animations/ sound
    PlayStateAnim(inst, "hit", false)

    if inst.components.occupiable and inst.components.occupiable:IsOccupied() then
        inst.AnimState:PushAnimation("flap")
        inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
    end

    PushStateAnim(inst, "idle", true)
end

local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("place")
    PushStateAnim(inst, "idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/birdcage_craft")
end

local function OnBirdRot(inst)
    StopAnimationTask(inst)
    SetCageState(inst, CAGE_STATES.SKELETON)
    PlayStateAnim(inst, "idle", false)

    inst:DoTaskInTime(0, function()
        local item = inst.components.inventory:GetItemInSlot(1)
        if item then
            inst.components.shelf:PutItemOnShelf(item)
        end
    end)
end

local function OnBirdStarve(inst, bird)
    StopAnimationTask(inst)
    SetCageState(inst, CAGE_STATES.DEAD)

    inst.AnimState:PlayAnimation("death")
    PushStateAnim(inst, "idle", false)

    --Put loot on "shelf"
    local loot = SpawnPrefab("smallmeat")
    inst.components.inventory:GiveItem(loot)
    inst.components.shelf:PutItemOnShelf(loot)
end

local function DoSickAnimationTask(inst)
    inst.AnimState:PlayAnimation(math.random() < .5 and "idle_sick2" or "idle_sick3")
    inst:DoTaskInTime(11 * FRAMES, DoPlaySound, "dontstarve/creatures/together/canary/cough")
    PushStateAnim(inst, "idle", false)
    inst.AnimationTask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + math.random() * 2, DoSickAnimationTask)
end

local function StartSickAnimationTask(inst)
    if inst.AnimationTask ~= nil then
        inst.AnimationTask:Cancel()
    end
    inst.AnimationTask = inst:DoTaskInTime(math.random() * 2, DoSickAnimationTask)
end

local function OnBirdPoisoned(inst, data)
    local pct = data.bird.components.perishable ~= nil and data.bird.components.perishable:GetPercent() or 1
    data.bird:Remove()

    SetCageState(inst, CAGE_STATES.SICK)

    inst.AnimState:PlayAnimation("fall_sick")
    PushStateAnim(inst, "idle", false)

    local loot = SpawnPrefab(data.poisoned_prefab)
    if loot ~= nil then
        if loot.components.perishable ~= nil then
            loot.components.perishable:SetPercent(loot.components.perishable:GetPercent() * pct)
        end
        inst.components.inventory:GiveItem(loot)
        inst.components.shelf:PutItemOnShelf(loot)
    end

    StartSickAnimationTask(inst)
end

local function OnGetShelfItem(inst, item)
    --De-activate occupiable
    inst:RemoveComponent("occupiable")
    inst.components.shelf.cantakeitem = true

    item.OnRotFn = function() OnBirdRot(inst) end
    inst:ListenForEvent("perished", item.OnRotFn, item)
end

local function OnLoseShelfItem(inst, taker, item)
    if item and item.OnRotFn then
        inst:RemoveEventCallback("perished", item.OnRotFn, item)
    end

    --Activate occupiable
    if not inst.components.occupiable then
        inst:AddComponent("occupiable")
        inst.components.occupiable.occupanttype = OCCUPANTTYPE.BIRD
        inst.components.occupiable.onoccupied = OnOccupied
        inst.components.occupiable.onemptied = OnEmptied
        inst.components.occupiable.onperishfn = OnBirdStarve
    end

    local bird = GetBird(inst)
    if bird then
        OnOccupied(inst, bird)
    else
        OnEmptied(inst, bird)
    end
end

local function OnSave(inst, data)
    data.CAGE_STATE = inst.CAGE_STATE
    data.bird_type = inst.bird_type
end

local function OnLoad(inst, data)
    if data and data.CAGE_STATE then
        SetCageState(inst, data.CAGE_STATE)
    end
    if data and data.bird_type then
        SetBirdType(inst, data.bird_type)
    end
    if inst.CAGE_STATE == CAGE_STATES.SICK then
        PlayStateAnim(inst, "idle", false)
        StartSickAnimationTask(inst)
    else
        PlayStateAnim(inst, "idle", true)
    end
end

local function OnLoadPostPass(inst, ents, data)
    --Check in inventory, put on shelf if needed.
    local item = inst.components.inventory:GetItemInSlot(1)

    if item then
        inst.components.shelf:PutItemOnShelf(item)
    end
end

local function GetStatus(inst)
    if inst.CAGE_STATE == CAGE_STATES.EMPTY then
        return "GENERIC"
    elseif inst.CAGE_STATE == CAGE_STATES.FULL then
        local bird = GetBird(inst)
        local hunger = GetHunger(bird)
        if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
            return "SLEEPING"
        elseif hunger < 0.33 then
            return "STARVING"
        elseif hunger < 0.66 then
            return "HUNGRY"
        else
            return "OCCUPIED"
        end

    elseif inst.CAGE_STATE == CAGE_STATES.DEAD or inst.CAGE_STATE == CAGE_STATES.SICK then
        return "DEAD"
    elseif inst.CAGE_STATE == CAGE_STATES.SKELETON then
        return "SKELETON"
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("birdcage.png")

    inst.AnimState:SetBank("birdcage")
    inst.AnimState:SetBuild("bird_cage")
    inst.AnimState:PlayAnimation("idle_empty")

    inst:AddTag("structure")
    inst:AddTag("cage")

    --trader (from trader component) added to pristine state for optimization
    --inst:AddTag("trader")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("lootdropper")

    inst:AddComponent("occupiable")
    inst.components.occupiable.occupanttype = OCCUPANTTYPE.BIRD
    inst.components.occupiable.onoccupied = OnOccupied
    inst.components.occupiable.onemptied = OnEmptied
    inst.components.occupiable.onperishfn = OnBirdStarve

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)
    inst.components.workable:SetOnWorkCallback(OnWorked)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItem
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader:Disable()

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1

    inst:AddComponent("shelf")
    inst.components.shelf:SetOnShelfItem(OnGetShelfItem)
    inst.components.shelf:SetOnTakeItem(OnLoseShelfItem)

    MakeSnowCovered(inst)

    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("gotosleep", GoToSleep)
    inst:ListenForEvent("onwakeup", WakeUp)

    if TheWorld.components.toadstoolspawner ~= nil then
        inst:ListenForEvent("birdpoisoned", OnBirdPoisoned)
    end

    inst.CAGE_STATE = nil
    SetCageState(inst, CAGE_STATES.EMPTY)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("birdcage", fn, assets, prefabs),
    MakePlacer("birdcage_placer", "birdcage", "bird_cage", "idle_empty")
