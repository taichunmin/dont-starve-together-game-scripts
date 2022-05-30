local assets =
{
    Asset("ANIM", "anim/mole_build.zip"),
    Asset("ANIM", "anim/mole_basic.zip"),
    Asset("SOUND", "sound/mole.fsb"),
}

-- make him pop up periodically

local prefabs =
{
    "smallmeat",
    "cookedsmallmeat",
    "mole_move_fx",
    "molehat",
}

local brain = require("brains/molebrain")

local MOLE_TAGS = {'mole'}
local function OnAttacked(inst, data)
    -- Don't spread the word when whacked
    -- V2C: this doesn't work because weapon is an inst
    --      commenting out to preserve behaviour rather
    --      fixing it to check for hammer tag on weapon
    --if data and data.weapon and data.weapon == "hammer" then return end

    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 30, MOLE_TAGS)

    local num_friends = 0
    local maxnum = 5
    for i,v in ipairs(ents) do
        v:PushEvent("gohome")
        num_friends = num_friends + 1

        if num_friends > maxnum then
            break
        end
    end
end

local function OnWentHome(inst)
    local molehill = inst.components.homeseeker and inst.components.homeseeker.home or nil
    if not molehill then return end
    if molehill.components.inventory then
        inst.components.inventory:TransferInventory(molehill)
    end
    inst.sg:GoToState("idle")
end

local function OnHomeDugUp(inst)
    inst.components.inventory:DropEverything(false, true)
    if inst.components.health ~= nil and not inst.components.health:IsDead() then
        inst.sg:GoToState("stunned", false)
    end
end

local function OnCookedFn(inst)
    if inst.components.health then
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/death")
    end
end

local function onpickup(inst)
    inst:PushEvent("ontrapped")
    inst.SoundEmitter:KillSound("move")
    inst.SoundEmitter:KillSound("sniff")
    inst.SoundEmitter:KillSound("stunned")
    if inst.sg.statemem.playtask ~= nil then
        inst.sg.statemem.playtask:Cancel()
        inst.sg.statemem.playtask = nil
    end
    if inst.sg.statemem.killtask ~= nil then
        inst.sg.statemem.killtask:Cancel()
        inst.sg.statemem.killtask = nil
    end
end

local function OnLoad(inst, data)
    if data then
        inst.needs_home_time = data.needs_home_time and -data.needs_home_time or nil
    end
end

local function OnSave(inst, data)
    data.needs_home_time = inst.needs_home_time and (GetTime() - inst.needs_home_time) or nil
end

local function SetUnderPhysics(inst)
    if inst.isunder ~= true then
        inst.isunder = true
		inst:AddTag("notdrawable")
        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    end
end

local function SetAbovePhysics(inst)
    if inst.isunder ~= false then
        inst.isunder = false
		inst:RemoveTag("notdrawable")
        ChangeToCharacterPhysics(inst)
    end
end

local function displaynamefn(inst)
    return inst:HasTag("noattack")
        and not inst:HasTag("INLIMBO")
        and not (inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:CanBePickedUp())
        and STRINGS.NAMES.MOLE_UNDERGROUND
        or STRINGS.NAMES.MOLE_ABOVEGROUND
end

local function getstatus(inst)
    return (inst.components.inventoryitem ~= nil and inst.components.inventoryitem:IsHeld() and "HELD")
        or (inst.isunder and "UNDERGROUND")
        or "ABOVEGROUND"
end

local function TestForMakeHome(inst)
    if not (inst.components.homeseeker ~= nil and inst.components.homeseeker.home ~= nil and inst.components.homeseeker.home:IsValid()) then
        inst.needs_home_time = GetTime()
    end
end

local function ondrop(inst)
    inst.SoundEmitter:KillSound("move")
    inst.SoundEmitter:KillSound("sniff")
    inst.SoundEmitter:KillSound("stunned")
    inst.sg:GoToState("stunned", true)
    TestForMakeHome(inst)
end

local function OnSleep(inst)
    inst.SoundEmitter:KillAllSounds()
end

local function OnRemove(inst)
    inst.SoundEmitter:KillAllSounds()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    --inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    --inst.DynamicShadow:SetSize(1, .75)
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 99999, 0.5)
    SetUnderPhysics(inst)

    inst.AnimState:SetBank("mole")
    inst.AnimState:SetBuild("mole_build")
    inst.AnimState:PlayAnimation("idle_under")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("mole")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")
    inst:AddTag("baitstealer")
    inst:AddTag("cattoy")
    inst:AddTag("catfood")
    inst:AddTag("whackable")
    inst:AddTag("stunnedbybomb")
    --inst:AddTag("wildfireprotected") --Only if burnable

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    MakeFeedableSmallLivestockPristine(inst)

    inst.displaynamefn = displaynamefn

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.isunder = nil --this flag is not valid on clients

        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2.75

    inst:SetStateGraph("SGmole")
    inst:SetBrain(brain)

    inst:AddComponent("cookable")
    inst.components.cookable.product = "cookedsmallmeat"
    inst.components.cookable:SetOnCookedFn(OnCookedFn)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MOLE_HEALTH)
    inst.components.health.murdersound = "dontstarve_DLC001/creatures/mole/death"
    inst.components.health.fire_damage_scale = 0

    inst:AddComponent("combat")
    --inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/mole/hurt")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODTYPE.ELEMENTAL})

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"smallmeat"})
    inst.components.lootdropper.trappable = false

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 3
    inst.force_onwenthome_message = true

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem.trappable = false
    inst.components.inventoryitem:SetSinks(true)
    -- inst.components.inventoryitem:SetOnPickupFn(onpickup)
    -- inst.components.inventoryitem:SetOnDroppedFn(ondrop) Done in MakeFeedableSmallLivestock

    inst:AddComponent("knownlocations")
    inst.last_above_time = 0
    inst.make_home_delay = math.random(5,10)
    inst.peek_interval = math.random(15,25)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetNocturnal(true)

    inst.SetUnderPhysics = SetUnderPhysics
    inst.SetAbovePhysics = SetAbovePhysics

    -- MakeSmallBurnableCharacter(inst, "mole")
    MakeTinyFreezableCharacter(inst, "chest")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    -- inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep
    inst.OnRemoveEntity = OnRemove
    inst:ListenForEvent("enterlimbo", OnRemove)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onwenthome", OnWentHome)
    inst:ListenForEvent("molehill_dug_up", OnHomeDugUp)

    MakeFeedableSmallLivestock(inst, TUNING.TOTAL_DAY_TIME*2, onpickup, ondrop)

    inst:DoTaskInTime(inst.make_home_delay, TestForMakeHome)

    AddHauntableCustomReaction(inst, function(inst, haunter)
        if math.random() < TUNING.HAUNT_CHANCE_OFTEN then
            local action = BufferedAction(inst, nil, ACTIONS.MOLEPEEK)
            inst.components.locomotor:PushAction(action, true)
            return true
        end
        return false
    end, nil, true, true)

    return inst
end

return Prefab("mole", fn, assets, prefabs)
