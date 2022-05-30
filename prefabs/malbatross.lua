local brain = require "brains/malbatrossbrain"

local assets =
{
    Asset("ANIM", "anim/malbatross_basic.zip"),
    Asset("ANIM", "anim/malbatross_actions.zip"),
    Asset("ANIM", "anim/malbatross_build.zip"),
}

local rippleassets =
{
    Asset("ANIM", "anim/malbatross_ripple.zip"),
}

local prefabs =
{
    "boss_ripple_fx",
    "wave_med",
    "splash_green_large",
    "splash_green",
    "malbatross_beak",
    "mast_malbatross",
    "mast_malbatross_item",
    "malbatross_feather",
    "malbatross_feather_fall",
	"winter_ornament_boss_malbatross",
	"chesspiece_malbatross_sketch",
	"premiumwateringcan",
}

--------------------------------------------------------------------------

local function PushMusic(inst)
    if ThePlayer == nil or inst:HasTag("flight") then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 50 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "malbatross" })
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 52) then
        inst._playingmusic = false
    end
end

local function OnIsEngagedDirty(inst)
    --Dedicated server does not need to trigger music
    if not TheNet:IsDedicated() then
        if not inst._isengaged:value() then
            if inst._musictask ~= nil then
                inst._musictask:Cancel()
                inst._musictask = nil
            end
            inst._playingmusic = false
        elseif inst._musictask == nil then
            inst._musictask = inst:DoPeriodicTask(1, PushMusic)
            PushMusic(inst)
        end
    end
end

local function SetEngaged(inst, engaged)
    if inst._isengaged:value() ~= engaged then
        inst._isengaged:set(engaged)
        OnIsEngagedDirty(inst)
    end
end

--------------------------------------------------------------------------

local function Relocate(inst)
    SetEngaged(inst, false)

    inst._stolen_fish_count = 0
    inst.components.health:SetCurrentHealth(inst.components.health:GetMaxWithPenalty())

    TheWorld.components.malbatrossspawner:Relocate(inst)
end

local TARGET_DIST = 16
local RETARGET_MUST_TAGS = { "_combat","hostile" }
local RETARGET_CANT_TAGS = { "wall","INLIMBO" }
local function RetargetFn(inst)
    local range = inst:GetPhysicsRadius(0) + 8
    return FindEntity(
            inst,
            TARGET_DIST,
            function(guy)
                return inst.components.combat:CanTarget(guy)
                    and (   guy.components.combat:TargetIs(inst) or
                            guy:IsNear(inst, range)
                        )
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS
        )
end

local function KeepTargetFn(inst, target)
    local home = inst.components.knownlocations:GetLocation("home")
    if home and inst:GetDistanceSqToPoint(home:Get()) > TUNING.MALBATROSS_MAX_CHASEAWAY_DIST * TUNING.MALBATROSS_MAX_CHASEAWAY_DIST then
        return false
    end

    return inst.components.combat:CanTarget(target)
end

local function OnNewTarget(inst, data)
    if data.oldtarget ~= nil then
        inst:RemoveEventCallback("death", inst.TryDisengage, data.oldtarget)
    end
    if data.target ~= nil then
        inst:ListenForEvent("death", inst.TryDisengage, data.target)
        if data.target:HasTag("player") then
            SetEngaged(inst, true)
        end
    end
end

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

local function MalbatrossIsHungry(inst)
    return not inst.components.timer:TimerExists("satiated")
end

local function OnAttacked(inst, data)
    inst.staredown = nil

    inst.components.combat:SetTarget(data.attacker)

    if not inst.components.knownlocations:GetLocation("home") then
        local pos = Vector3(inst.Transform:GetWorldPosition())
        inst.components.knownlocations:RememberLocation("home", pos)
    end

    for i=1,4 do
        if math.random() < 0.05 then
            inst.spawnfeather(inst,0.4)
        end
    end

    if not inst.divetask and not inst.readytodive then
        inst.resetdivetask(inst)
    end
end

local function OnHealthChange(inst,data)
    if data.newpercent <= 0.66 then
        inst.willdive = true
    end
    if data.newpercent <= 0.33 then
        inst.willswoop = true
    end
end

local function OnRemove(inst)
    TheWorld:PushEvent("malbatrossremoved", inst)
end

local function OnDead(inst)
    if inst.swooptask then
        inst.swooptask:Cancel()
        inst.swooptask = nil
    end
    SetEngaged(inst, false)
end

local function OnLostTarget(inst)
    inst.staredown = nil
end

local function OnDroppedTarget(inst, data)
    if data.oldtarget ~= nil then
        inst:RemoveEventCallback("death", inst.TryDisengage, data.oldtarget)
        if data.oldtarget:HasTag("player") then
            inst.TryDisengage()
        end
    end
end

local function spawnfeather(inst,time)
    local feather = SpawnPrefab("malbatross_feather_fall")
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local angle = math.random() * 2* PI
    local offset = Vector3(math.cos(angle), 0, -math.sin(angle)):Normalize() * (math.random()*2+ 1)
    pos = pos + offset
    feather.Transform:SetPosition(pos.x,pos.y,pos.z)

    if time then
        local set = time * 79/30
        feather.AnimState:SetTime( set )
    end

    feather.Transform:SetRotation(math.random()*360)

    if not inst.feathers then
        inst.feathers = 0
    end
    inst.feathers = inst.feathers + 1
end


local function OnEntitySleep(inst)
    inst.components.timer:StartTimer("sleeping_relocate", TUNING.MALBATROSS_ENTITYSLEEP_RELOCATE_TIME)
end

local function OnEntityWake(inst)
    inst.components.timer:StopTimer("sleeping_relocate")
end

local function OnTimerDone(inst, data)
    if data.name == "sleeping_relocate" then
        inst:Relocate()
    elseif data.name == "divetask" then
        inst.readytodive = true
    elseif data.name == "disengage" then
        if inst.components.combat.target == nil then
            SetEngaged(inst, false)
        end
    end
end

local function resetdivetask(inst)
    inst.components.timer:StopTimer("divetask")
    inst.components.timer:StartTimer("divetask", 10)
end

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

local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function onothercollide(inst, other)
    if not other:IsValid() or inst.recentlycharged[other] or
            (not other:HasTag("tree") and not other:HasTag("mast") and not other.components.health) then
        return
    end

    if other:HasTag("smashable") and other.components.health ~= nil then
        --other.Physics:SetCollides(false)
        other.components.health:Kill()
    elseif other.components.workable ~= nil
        and other.components.workable:CanBeWorked()
        and other.components.workable.action ~= ACTIONS.NET then

        if other:HasTag("mast") then
            local boat = other:GetCurrentPlatform()
            if boat then
                local vx, vy, vz = inst.Physics:GetVelocity()
                vx, vz = VecUtil_Normalize(vx, vz)

                local boat_physics = boat.components.boatphysics
                boat_physics:ApplyForce(vx, vz, 3)
            end

            spawnfeather(inst,0.4)
            spawnfeather(inst,0.4)
            spawnfeather(inst,0.4)
            if math.random() < 0.3 then
                spawnfeather(inst,0.4)
            end
            if math.random() < 0.3 then
                spawnfeather(inst,0.4)
            end
        end

        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)

        inst.recentlycharged[other] = true
        inst:DoTaskInTime(3, ClearRecentlyCharged, other)
    elseif other.components.health ~= nil and not other.components.health:IsDead() then
        inst.recentlycharged[other] = true
        inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        inst.components.combat:DoAttack(other, inst.weapon)
    end
end

local function oncollide(inst, other)
    if other ~= nil and other:IsValid() and inst:IsValid() and not inst.recentlycharged[other] then
        inst:DoTaskInTime(2 * FRAMES, onothercollide, other)
    end
end


local function OnSave(inst, data)
    if inst.feathers then
        data.feathers = inst.feathers
    end

    -- Our default is 0, so we don't have to save in that case.
    if inst._stolen_fish_count ~= nil and inst._stolen_fish_count ~= 0 then
        data.stolen_fish = inst._stolen_fish_count
    end
end

local function OnLoad(inst, data)
    --print("OnLoad", inst, data.ispet)
    if data ~= nil then
        if data.feathers then
            inst.feathers = data.feathers
        end
        if data.stolen_fish then
            inst._stolen_fish_count = data.stolen_fish
        end
    end
end

local function CreateWeapon(inst)
    local weapon = CreateEntity()
    --[[Non-networked entity]]
    weapon.entity:AddTransform()
    weapon:AddComponent("weapon")
    weapon.components.weapon:SetDamage(75)
    weapon.components.weapon:SetRange(0)
    weapon:AddComponent("inventoryitem")
    weapon.persists = false
    weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)
    weapon:AddComponent("equippable")
    inst.components.inventory:GiveItem(weapon)
    inst.weapon = weapon
end

--[[ PLAYER TRACKING ]]

local function OnPlayerAction(inst, player, data)
    if data.action == nil or inst.components.sleeper:IsAsleep() or inst.components.health:IsDead() then
        return -- don't react to things when asleep
    end

    if data.action.action ~= ACTIONS.OCEAN_FISHING_CATCH then
        return
    end

    local distsq_to_player = inst:GetDistanceSqToInst(player)
    if distsq_to_player > TUNING.MALBATROSS_NOTICEPLAYER_DISTSQ then
        return
    end

    inst._stolen_fish_count = (inst._stolen_fish_count or 0) + 1
    if inst._stolen_fish_count < TUNING.MALBATROSS_STOLENFISH_AGGROCOUNT then
        if not inst.sg:HasStateTag("busy") then
            inst:ForceFacePoint(player.Transform:GetWorldPosition())
            inst.sg:GoToState("taunt")
        end
    else
        -- Ensure that the next caught fish will suggest a new target
        inst._stolen_fish_count = TUNING.MALBATROSS_STOLENFISH_AGGROCOUNT - 1
        inst.components.combat:SuggestTarget(player)
    end
end

local function OnPlayerJoined(inst, player)
    for i, v in ipairs(inst._activeplayers) do
        if v == player then
            return
        end
    end

    inst:ListenForEvent("performaction", inst._OnPlayerAction, player)
    table.insert(inst._activeplayers, player)
end

local function OnPlayerLeft(inst, player)
    for i, v in ipairs(inst._activeplayers) do
        if v == player then
            inst:RemoveEventCallback("performaction", inst._OnPlayerAction, player)
            table.remove(inst._activeplayers, i)
            return
        end
    end
end

--[[ END PLAYER TRACKING ]]

SetSharedLootTable( 'malbatross',
{
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'malbatross_beak',                     1.00},
    {'bluegem',                             1},
    {'bluegem',                             1},
    {'bluegem',                             0.3},
    {'yellowgem',                           0.05},
	{'chesspiece_malbatross_sketch',		1.00},

})


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeTinyFlyingCharacterPhysics(inst,1000, 1.5)

    local s  = 1.30
    inst.Transform:SetScale(s, s, s)

    inst.AnimState:SetBank("malbatross")
    inst.AnimState:SetBuild("malbatross_build")

    inst:AddTag("malbatross")
    inst:AddTag("epic")
    inst:AddTag("noepicmusic")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")

    inst.DynamicShadow:SetSize(6, 2)
    inst.Transform:SetSixFaced()

    inst.AnimState:PlayAnimation("idle_loop", true)

    MakeInventoryFloatable(inst, "large")

    inst._isengaged = net_bool(inst.GUID, "dragonfly._isengaged", "isengageddirty")
    inst._playingmusic = false
    inst._musictask = nil

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("isengageddirty", OnIsEngagedDirty)

        return inst
    end

    inst.recentlycharged = {}
    inst.oncollide = oncollide

    ------------------------------------------

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { allowocean = true }
    ------------------------------------------

    inst:SetStateGraph("SGmalbatross")

    ------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MALBATROSS_HEALTH)
    inst.components.health.destroytime = 5

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.MALBATROSS_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.MALBATROSS_DAMAGE_PLAYER_PERCENT
    inst.components.combat:SetRange(TUNING.MALBATROSS_ATTACK_RANGE)
    inst.components.combat:SetAreaDamage(TUNING.MALBATROSS_AOE_RANGE, TUNING.MALBATROSS_AOE_SCALE)
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetAttackPeriod(TUNING.MALBATROSS_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    ------------------------------------------

    inst:AddComponent("inventory")

    ------------------------------------------

    inst:AddComponent("explosiveresist")

    ------------------------------------------

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('malbatross')

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    ------------------------------------------

    inst:AddComponent("timer")

    ------------------------------------------

    inst:AddComponent("knownlocations")

    ------------------------------------------

    inst:AddComponent("entitytracker")

    ------------------------------------------

    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("healthdelta", OnHealthChange)
--    inst:ListenForEvent("onhitother", OnHitOther)
    inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onremove", OnRemove)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("entitywake", OnEntityWake)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("losttarget", OnLostTarget)
    inst:ListenForEvent("droppedtarget", OnDroppedTarget)

    MakeLargeBurnableCharacter(inst, "body")
    MakeHugeFreezableCharacter(inst, "body")

    CreateWeapon(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.spawnwaves = spawnwaves
    inst.IsHungry = MalbatrossIsHungry
    inst.spawnfeather = spawnfeather
    inst.resetdivetask = resetdivetask
    inst.Relocate = Relocate

    inst.TryDisengage = function()
        if not inst.components.timer:TimerExists("disengage") then
            inst.components.timer:StartTimer("disengage", 2)
        end
    end

    inst.readytoswoop = true
    inst.readytosplash = true
    inst.willswoop = false -- changed when health is lowered.

    --[[ PLAYER TRACKING ]]

    --inst._stolen_fish_count = nil
    inst._activeplayers = {}
    inst._OnPlayerAction = function(player, data) OnPlayerAction(inst, player, data) end
    inst:ListenForEvent("ms_playerjoined", function(src, player) OnPlayerJoined(inst, player) end, TheWorld)
    inst:ListenForEvent("ms_playerleft", function(src, player) OnPlayerLeft(inst, player) end, TheWorld)

    for i, v in ipairs(AllPlayers) do
        OnPlayerJoined(inst, v)
    end

    --[[ END PLAYER TRACKING ]]

    return inst
end

return Prefab("malbatross", fn, assets, prefabs)
