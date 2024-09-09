local assets =
{
    Asset("ANIM", "anim/merm_king.zip"),
    Asset("ANIM", "anim/mermkingswaps.zip"),
}

local prefabs =
{
    "pondfish",
    "kelp",
    "froglegs",
    "merm_king_splash",
}

local loot =
{
    "pondfish",
    "froglegs",
    "kelp",
    "kelp",
    "kelp",
    "kelp",
}

local trading_items =
{
    { prefabs = { "kelp"  },         min_count = 2, max_count = 4, reset = false, add_filler = false, },
    { prefabs = { "kelp"  },         min_count = 2, max_count = 3, reset = false, add_filler = false, },
    { prefabs = { "seeds" },         min_count = 4, max_count = 6, reset = false, add_filler = false, },
    { prefabs = { "tentaclespots" }, min_count = 1, max_count = 1, reset = false, add_filler = true,  },
    { prefabs = { "cutreeds" },      min_count = 1, max_count = 2, reset = false, add_filler = true,  },

    {
        prefabs = { -- These trinkets are generally good for team play, but tend to be poor for solo play.
            -- Theme
            "trinket_12", -- Dessicated Tentacle
            "trinket_25", -- Air Unfreshener
            -- Team
            "trinket_1", -- Melted Marbles
            -- Fishing
            "trinket_17", -- Bent Spork
            "trinket_8", -- Rubber Bung
        },
        min_count = 1, max_count = 1, reset = false, add_filler = true,
    },

    {
        prefabs = { "durian_seeds", "pepper_seeds", "eggplant_seeds", "pumpkin_seeds", "onion_seeds", "garlic_seeds"  },
        min_count = 1, max_count = 2, reset = false, add_filler = true,
    },
}

local trading_filler = { "seeds", "kelp", "seeds", "seeds"}

local MAX_TARGET_SHARES = 30
local SHARE_TARGET_DIST = 40

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker and inst.components.combat:CanTarget(attacker) then
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(sharer)
            return sharer:HasTag("merm") and not sharer:HasTag("player")
        end, MAX_TARGET_SHARES)
    end
end

local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local function TradeItem(inst)
    local item = inst.itemtotrade
    local giver = inst.tradegiver

    local x, _, z = inst.Transform:GetWorldPosition()
    local y = 5.5

    local angle
    if giver ~= nil and giver:IsValid() then
        angle = 180 - giver:GetAngleToPoint(x, 0, z)
    else
        local down = TheCamera:GetDownVec()
        angle = math.atan2(down.z, down.x) * RADIANS
    end

    local selected_index = math.random(#inst.trading_items)
    local selected_item = inst.trading_items[selected_index]

    local isabigheavyfish = item.components.weighable and item.components.weighable:GetWeightPercent() >= TUNING.WEIGHABLE_HEAVY_WEIGHT_PERCENT or false
    local bigheavyreward = isabigheavyfish and math.random(1, 2) or 0

    local filler_min = 2 -- Not biasing minimum for filler.
    local filler_max = 4 + bigheavyreward
    local reward_count = math.random(selected_item.min_count, selected_item.max_count) + bigheavyreward

    for _ = 1, reward_count do
        local reward_item = SpawnPrefab(selected_item.prefabs[math.random(#selected_item.prefabs)])
        reward_item.Transform:SetPosition(x, y, z)
        launchitem(reward_item, angle)
    end

    if selected_item.add_filler then
        for _ = filler_min, filler_max do
            local filler_item = SpawnPrefab(trading_filler[math.random(#trading_filler)])
            filler_item.Transform:SetPosition(x, y, z)
            launchitem(filler_item, angle)
        end
    end
    if item:HasTag("oceanfish") then
        local goldmin, goldmax, goldprefab = 1, 2, "goldnugget"
        if item.prefab:find("oceanfish_medium_") == 1 then
            goldmin, goldmax = 2, 4
            if item.prefab == "oceanfish_medium_6_inv" or item.prefab == "oceanfish_medium_7_inv" then -- YoT events.
                goldprefab = "lucky_goldnugget"
            end
        end

        local amt = math.random(goldmin, goldmax) + bigheavyreward
        for _ = 1, amt do
            local reward_item = SpawnPrefab(goldprefab)
            reward_item.Transform:SetPosition(x, y, z)
            launchitem(reward_item, angle)
        end
    end

    -- Cycle out rewards.
    table.remove(inst.trading_items, selected_index)
    if #inst.trading_items == 0 or selected_item.reset then
        inst.trading_items = deepcopy(trading_items)
    end

    inst.itemtotrade = nil
    inst.tradegiver  = nil

    item:Remove()
end

-- Trader fns -------------------------------------
local function item_is_trident(item) return item.prefab == "trident" end
local function item_is_crown(item) return item.prefab == "ruinshat" end
local function item_is_marblearmor(item) return item.prefab == "armormarble" end
local function ShouldAcceptItem(inst, item, giver)
    if not giver:HasTag("merm") then return false end

    local can_eat = (item.components.edible and inst.components.eater:CanEat(item))
        and (inst.components.hunger and inst.components.hunger:GetPercent() < 1)
    if can_eat or item:HasTag("fish") then
        return true
    end

    local giver_skilltreeupdater = giver.components.skilltreeupdater
    if giver_skilltreeupdater then
        return (item.prefab == "trident"
                and giver_skilltreeupdater:IsActivated("wurt_mermkingtrident")
                and inst.components.inventory:FindItem(item_is_trident) == nil
            ) or (item.prefab == "ruinshat"
                and giver_skilltreeupdater:IsActivated("wurt_mermkingcrown")
                and inst.components.inventory:FindItem(item_is_crown) == nil
            ) or (item.prefab == "armormarble"
                and giver_skilltreeupdater:IsActivated("wurt_mermkingshoulders")
                and inst.components.inventory:FindItem(item_is_marblearmor) == nil
            )
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item.components.edible ~= nil then
        if inst.components.combat:TargetIs(giver) then
            inst.components.combat:SetTarget(nil)
        end

        if not item:HasTag("fish") and inst.components.eater:CanEat(item) then
            local hunger = item.components.edible:GetHunger(inst)
            local chews = (hunger < TUNING.CALORIES_SMALL and 0)    -- 12.5
                or (hunger < TUNING.CALORIES_MEDSMALL and 1)        -- 18.75
                or 2                                                -- Most crockpot foods.
            inst.sg:GoToState("eat", { chews = chews, })

            inst:RefreshHungerParameters(giver)

            inst.components.eater:Eat(item)
        else
            inst.sg:GoToState("trade")
            inst.itemtotrade = item
            inst.tradegiver = giver
        end
    elseif item.prefab == "trident" then
        inst.sg:GoToState("get_trident")
        TheWorld:PushEvent("onmermkingtridentadded")
    elseif item.prefab == "ruinshat" and not inst._crown_data then
        inst.sg:GoToState("get_crown")
        TheWorld:PushEvent("onmermkingcrownadded")
    elseif item.prefab == "armormarble" and not inst._shoulders_data then
        inst.sg:GoToState("get_pauldron")
        TheWorld:PushEvent("onmermkingpauldronadded")
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
end

---------------------------------------------------
local function OnHaunt(inst, haunter)
    if inst.components.trader ~= nil and inst.components.trader.enabled then
        OnRefuseItem(inst)
        return true
    else
        return false
    end
end

local function HungerDelta(inst, data)
    local new_hunger_percent = data.newpercent
    if not new_hunger_percent then return end

    local increase = (inst.lastpercent_hunger ~= nil) and ((new_hunger_percent - inst.lastpercent_hunger) > 0)
    inst.lastpercent_hunger = new_hunger_percent

    if new_hunger_percent == 1
            or not inst.components.timer:TimerExists("hungrytalk_cooldown")
            or (increase and not inst.components.timer:TimerExists("hungrytalk_increase_cooldown") ) then
        inst.components.talker:Say(
            (new_hunger_percent <= 0 and STRINGS.MERM_KING_TALK_HUNGER_STARVING)
            or (new_hunger_percent < 0.1 and STRINGS.MERM_KING_TALK_HUNGER_CLOSE_STARVING)
            or (new_hunger_percent < 0.25 and STRINGS.MERM_KING_TALK_HUNGER_VERY_HUNGRY)
            or (new_hunger_percent < 0.5 and STRINGS.MERM_KING_TALK_HUNGER_HUNGRY)
            or (new_hunger_percent < 0.95 and STRINGS.MERM_KING_TALK_HUNGER_HUNGRISH)
            or STRINGS.MERM_KING_TALK_HUNGER_FULL
        )

        if increase then
            inst.components.timer:StopTimer("hungrytalk_increase_cooldown")
            inst.components.timer:StartTimer("hungrytalk_increase_cooldown", 10)
        end

        local time = Remap(new_hunger_percent, 1,0, 30,8)
        inst.components.timer:StopTimer("hungrytalk_cooldown")
        inst.components.timer:StartTimer("hungrytalk_cooldown", time)
    end

    if new_hunger_percent <= 0 then
        inst.components.health:StopRegen()

        inst:RefreshHungerParameters()
    end

    if data.oldpercent and data.oldpercent == 0 and new_hunger_percent > data.oldpercent then
        inst.components.health:StartRegen(TUNING.MERM_KING_HEALTH_REGEN, TUNING.MERM_KING_HEALTH_REGEN_PERIOD)
    end
end

local function call_guard_task_callback(inst)
    inst.guards_available = 4
    inst.call_guard_task = nil
end
local function HealthDelta(inst, data)
    local new_health_percent = data.newpercent
    if new_health_percent and inst.components.combat.target ~= nil then
        if new_health_percent < 0.75 and data.oldpercent > new_health_percent then
            inst.guards_available = inst.guards_available or 4

            if inst.guards_available > 0
                    and (inst.guards == nil or #inst.guards == 0)
                    and not inst.sg:HasStateTag("calling_guards")
                    and not inst.components.health:IsDead() then
                inst.sg:PushEvent("call_guards")

                inst.call_guard_task = inst.call_guard_task or inst:DoTaskInTime(TUNING.TOTAL_DAY_TIME, call_guard_task_callback)
            end
        end
    end
end

local INVENTORYITEM_MUST_TAGS = {"_inventoryitem"}
local INVENTORYITEM_NONE_TAGS = { "DECOR", "FX", "INLIMBO", "NOCLICK", "locomotor", }
local INVENTORYITEM_RANGE = 1.5
local function OnCreated(inst)
    inst.components.hunger:SetPercent(0.25)
    inst.lastpercent_hunger = 0.25
    inst.guards_available = 4
    inst.guards = {}

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local nearby_inventoryitems = TheSim:FindEntities(ix, 0, iz, INVENTORYITEM_RANGE, INVENTORYITEM_MUST_TAGS, INVENTORYITEM_NONE_TAGS)
    for _, nearby_item in pairs(nearby_inventoryitems) do
        Launch(nearby_item, inst, 1)
        nearby_item.components.inventoryitem:SetLanded(false, true)
    end
end

local function KeepTarget(inst, target)
    if target and not inst:IsNear(target, 75) then
        return false
    end

    if inst.guards and #inst.guards > 0 then
        for _, guard in ipairs(inst.guards) do
            if guard.components.combat.target == target then
                return true
            end
        end

        return false
    end

    return true
end

local function OnGuardDeath(inst)
    local remove_at = nil
    for i,v in ipairs(inst.king.guards) do
        if v == inst then
            remove_at = i
            break
        end
    end

    if remove_at then
        table.remove(inst.king.guards, remove_at)
    end

    inst.king:RemoveEventCallback("death",  inst.king.OnGuardDeath, inst)
    inst.king:RemoveEventCallback("onremove", inst.king.OnGuardRemoved, inst)
    inst.king:RemoveEventCallback("enterlimbo", inst.king.OnGuardEnterLimbo, inst)
end

local function OnGuardRemoved(inst)
    if inst.king.guards_available < 4 then
        inst.king.guards_available = inst.king.guards_available + 1
    end
    OnGuardDeath(inst)
end

local function OnGuardEnterLimbo(inst)
    inst:Remove()
end

local function CallGuards(inst)
    inst:RemoveTag("companion")
    local merm_positions =
    {
        { x =  2.5, z =  2.5 },
        { x = -2.5, z =  2.5 },
        { x =  2.5, z = -2.5 },
        { x = -2.5, z = -2.5 },
    }

    local x,y,z = inst.Transform:GetWorldPosition()
    inst.guards = {}

    inst.guards_available = inst.guards_available or 4

    for i = 1, inst.guards_available do
        local new_merm = SpawnPrefab("mermguard")
        new_merm.Transform:SetPosition(x + merm_positions[i].x, y, z + merm_positions[i].z)
        new_merm.components.combat:SetTarget(inst.components.combat.target)
        new_merm.king = inst

        local fx = SpawnPrefab("merm_spawn_fx")
        fx.Transform:SetPosition(new_merm.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/throne/spawn")

        table.insert(inst.guards, new_merm)
        inst:ListenForEvent("death",  OnGuardDeath, new_merm)
        inst:ListenForEvent("onremove", OnGuardRemoved, new_merm)
        inst:ListenForEvent("enterlimbo", OnGuardEnterLimbo, new_merm)
    end

    inst.guards_available = 0
end

local function ReturnMerms(inst)
    inst:AddTag("companion")
    inst.guards = inst.guards or {}

    for _, guard in ipairs(inst.guards) do
        if guard.components.combat.target ~= nil then
            guard.components.combat:GiveUp()
        end

        guard.return_to_king = true
    end
end

local function OnGiveUpTarget(inst, data)
    ReturnMerms(inst)
end

local function OnDroppedItem(inst, data)
    local item = data.item
    if item then
        if item.prefab == "trident" then
            TheWorld:PushEvent("onmermkingtridentremoved")
            inst.AnimState:ClearOverrideSymbol("trident")
        elseif item.prefab == "ruinshat" then
            TheWorld:PushEvent("onmermkingcrownremoved")
            inst.AnimState:ClearOverrideSymbol("crown")
        elseif item.prefab == "armormarble" then
            TheWorld:PushEvent("onmermkingpauldronremoved")
            inst.AnimState:ClearOverrideSymbol("shoulder_lilly")
        end
    end
end

local function HasTrident(inst)
    return (inst.components.inventory:FindItem(item_is_trident) ~= nil)
end

local function HasCrown(inst)
    return (inst.components.inventory:FindItem(item_is_crown) ~= nil)
end

local function HasPauldron(inst)
    return (inst.components.inventory:FindItem(item_is_marblearmor) ~= nil)
end

local function OnSave(inst, data)
    local ents = {}

    if inst.components.hunger.max ~= TUNING.MERM_KING_HUNGER then
        data.max_hunger = inst.components.hunger.max
    end

    if inst.guards_available ~= nil then
        data.guards_available = inst.guards_available
    end

    if inst.guards and #inst.guards then
        data.guards = {}
        for _, guard in ipairs(inst.guards) do
            table.insert(data.guards, guard.GUID)
            table.insert(ents, guard.GUID)
        end
    end

    if inst.call_guard_task then
        data.task_remaining = GetTaskRemaining(inst.call_guard_task)
    end

    return ents
end

local function OnPreLoad(inst, data)
    if data ~= nil and data.max_hunger ~= nil then
        inst.components.hunger:SetMax(data.max_hunger)
    end
end

local function OnLoad(inst, data, newents)
    if HasTrident(inst) then
        inst.AnimState:OverrideSymbol("trident", "mermkingswaps", "trident")
        TheWorld:PushEvent("onmermkingtridentadded")
    end

    if HasCrown(inst) then
        inst.AnimState:OverrideSymbol("crown", "mermkingswaps", "crown")
        TheWorld:PushEvent("onmermkingcrownadded")
    end

    if HasPauldron(inst) then
        inst.AnimState:OverrideSymbol("shoulder_lilly", "mermkingswaps", "shoulder_lilly")
        TheWorld:PushEvent("onmermkingpauldronadded")
    end
end

local function OnLoadPostPass(inst, newents, savedata)
    if savedata.guards_available then
        inst.guards_available = savedata.guards_available
    end

    inst.guards = {}
    if savedata.guards then
        for _, guard_GUID in ipairs(savedata.guards) do
            local guard = newents[guard_GUID].entity
            if guard then
                table.insert(inst.guards, guard)
                guard.king = inst
                guard.return_to_king = true

                inst:ListenForEvent("death",  OnGuardDeath, guard)
                inst:ListenForEvent("onremove", OnGuardRemoved, guard)
                inst:ListenForEvent("enterlimbo", OnGuardEnterLimbo, guard)
            else
                print ("ERROR, COULD NOT FIND GUARD WITH PROVIDED GUID")
            end
        end
    end

    if savedata.task_remaining then
        inst.call_guard_task = inst:DoTaskInTime(savedata.task_remaining, call_guard_task_callback)
    end
end

local function RefreshHungerParameters(inst, feeder)
    local new_max_hunger

    if feeder == nil and inst.components.hunger.max ~= TUNING.MERM_KING_HUNGER then
        new_max_hunger = TUNING.MERM_KING_HUNGER

        inst.components.hunger.burnratemodifiers:RemoveModifier(inst, "wurt_skill")

    elseif feeder ~= nil and feeder.components.skilltreeupdater ~= nil then
        local skill_level = feeder.components.skilltreeupdater:CountSkillTag("merm_king_max_hunger")
        local skill_mod = skill_level > 0 and TUNING.SKILLS.WURT.MERM_KING_MAX_HUNGER_MULT[skill_level] or nil

        new_max_hunger = skill_mod ~= nil and (TUNING.MERM_KING_HUNGER * skill_mod) or nil

        if new_max_hunger ~= nil and new_max_hunger < inst.components.hunger.max then
            new_max_hunger = nil
        end

        if feeder.components.skilltreeupdater:HasSkillTag("merm_king_hunger_rate") then
            inst.components.hunger.burnratemodifiers:SetModifier(inst, TUNING.SKILLS.WURT.MERM_KING_HUNGER_RATE_MULT, "wurt_skill")
        end
    end

    if new_max_hunger ~= nil then
        inst.components.hunger.max = new_max_hunger
        inst.components.hunger:DoDelta(0)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("merm_king")
    inst.AnimState:SetBuild("merm_king")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("character")
    inst:AddTag("merm")
    inst:AddTag("mermking")
    inst:AddTag("wet")
    inst:AddTag("companion")
    inst.controller_priority_override_is_ally = true

    inst:AddTag("trader")
    inst:AddTag("alltrader")

    inst:AddComponent("talker")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetStateGraph("SGmermking")

    MakeLargeBurnableCharacter(inst, "torso")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.VEGETARIAN }, { FOODGROUP.VEGETARIAN })

    -- Keep in sync with Wurt + merm! But make sure no bonuses are applied!
    local foodaffinity = inst:AddComponent("foodaffinity")
    foodaffinity:AddFoodtypeAffinity(FOODTYPE.VEGGIE, 1)
    foodaffinity:AddPrefabAffinity  ("kelp",          1) -- prevents the negative stats
    foodaffinity:AddPrefabAffinity  ("kelp_cooked",   1) -- prevents the negative stats
    foodaffinity:AddPrefabAffinity  ("boatpatch_kelp",1) -- prevents the negative stats
    foodaffinity:AddPrefabAffinity  ("durian",        1) -- prevents the negative stats
    foodaffinity:AddPrefabAffinity  ("durian_cooked", 1) -- prevents the negative stats

    local hunger = inst:AddComponent("hunger")
    hunger:SetMax(TUNING.MERM_KING_HUNGER)
    hunger:SetKillRate(TUNING.MERM_KING_HEALTH / TUNING.MERM_KING_HUNGER_KILL_TIME)
    hunger:SetRate(TUNING.MERM_KING_HUNGER_RATE)

    inst:AddComponent("combat")
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    local health = inst:AddComponent("health")
    health:SetMaxHealth(TUNING.MERM_KING_HEALTH)
    health.destroytime = 3.5
    health:StartRegen(TUNING.MERM_KING_HEALTH_REGEN, TUNING.MERM_KING_HEALTH_REGEN_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("inventory")
    inst:AddComponent("inspectable")

    inst:AddComponent("timer")

    local trader = inst:AddComponent("trader")
    trader:SetAcceptTest(ShouldAcceptItem)
    trader.onaccept = OnGetItemFromPlayer
    trader.onrefuse = OnRefuseItem
    trader.deleteitemonaccept = false
    trader.acceptnontradable = true

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("hungerdelta", HungerDelta)
    inst:ListenForEvent("healthdelta", HealthDelta)
    inst:ListenForEvent("oncreated", OnCreated)
    inst:ListenForEvent("giveuptarget", OnGiveUpTarget)
    inst:ListenForEvent("droppedtarget", OnGiveUpTarget)
    inst:ListenForEvent("dropitem", OnDroppedItem)

    inst.trading_items = deepcopy(trading_items)
    inst.TradeItem = TradeItem

    inst.CallGuards = CallGuards
    inst.ReturnMerms = ReturnMerms

    inst.OnGuardDeath = OnGuardDeath
    inst.OnGuardRemoved = OnGuardRemoved
    inst.OnGuardEnterLimbo = OnGuardEnterLimbo

    inst.RefreshHungerParameters = RefreshHungerParameters

    inst.HasTrident = HasTrident
    inst.HasCrown = HasCrown
    inst.HasPauldron = HasPauldron

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("mermking", fn, assets, prefabs)