require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chaseandattack"
require "behaviours/leash"
local BrainCommon = require("brains/braincommon")

local RETURN_DIST = 4
local BASE_DIST = 2

local MAX_WANDER_DIST = 20

local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30

local SEE_PLAYER_DIST = 5
local STOP_RUN_DIST = 10

local NO_LOOTING_TAGS = { "INLIMBO", "catchable", "fire", "irreplaceable", "heavy", "outofreach", "spider" }
local NO_PICKUP_TAGS = deepcopy(NO_LOOTING_TAGS)
table.insert(NO_PICKUP_TAGS, "_container")

local PowderMonkeyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function findmaxwanderdistfn(inst)
    local dist = MAX_WANDER_DIST
    local boat = inst:GetCurrentPlatform()
    if boat then
        dist = boat.components.walkableplatform and boat.components.walkableplatform.platform_radius -0.3 or dist
    end
    return dist
end

local function findwanderpointfn(inst)
    local boat = inst:GetCurrentPlatform()
    return (boat ~= nil and boat:GetPosition())
        or inst.components.knownlocations:GetLocation("home")
end


local ROWBLOCKER_MUSTNOT = {"FX", "NOCLICK", "DECOR", "INLIMBO", "_inventoryitem"}
local function rowboat(inst)
    if not inst.components.crewmember
            or not inst.components.crewmember:Shouldrow()
            or inst.sg:HasStateTag("busy") then
        return nil
    end

    local boat = inst:GetCurrentPlatform() == inst.components.crewmember.boat and inst:GetCurrentPlatform()
    if not boat then
        return nil
    end

    local pos = inst.rowpos
    if not pos then
        local radius = boat.components.walkableplatform.platform_radius - 0.35
        local blocked = true
        local count = 0
        while blocked == true do
            pos = boat:GetPosition()

            local offset = FindWalkableOffset(pos, TWOPI*math.random(), radius, 12, false,false,nil,false,true)
            if offset then
                pos = pos + offset
            end

            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1.3, nil,ROWBLOCKER_MUSTNOT)

            if #ents == 1 and ents[1] == inst then
                ents = {}
            end

            if #ents == 0 then
                blocked = false
            end

            count = count + 1
            if blocked == true and count > 8 then
                pos = nil
                blocked = false
            end
        end
    end

    if pos then
        inst.rowpos = pos
        return BufferedAction(inst, nil, ACTIONS.ROW, nil, pos)
    end
end

local function reversemastcheck(ent)
    return ent.components.mast ~= nil
        and ent.components.mast.inverted
        and ent:HasTag("saillowered")
        and not ent:HasTag("sail_transitioning")
end

local function mastcheck(ent)
    return ent.components.mast ~= nil
        and not ent.components.mast.inverted
        and ent:HasTag("sailraised")
end

local function anchorcheck(ent)
    return ent.components.anchor ~= nil
        and ent:HasTag("anchor_raised")
        and not ent:HasTag("anchor_transitioning")
end

local function chestcheck(ent)
    return
        ent.components.container ~= nil and
        not ent.components.container:IsEmpty() and
        ent:HasTag("chest") and
        not ent:HasTag("outofreach")
end

local DOTINKER_MUST_HAVE = {"structure"}
local function Dotinker(inst)
    if inst.sg:HasStateTag("busy")
            or (inst.components.timer ~= nil
                and inst.components.timer:TimerExists("reactiondelay")
            ) then
        return nil
    end

    local bc = (inst.components.crewmember ~= nil
        and inst.components.crewmember.boat ~= nil
        and inst.components.crewmember.boat.components.boatcrew)
        or nil
    if bc then
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 10, DOTINKER_MUST_HAVE)

        if #ents > 0 then
            for i=#ents,1,-1 do

                local ent = ents[i]
                local keep = false

                if mastcheck(ent) or anchorcheck(ent) or reversemastcheck(ent) then
                    keep = true
                end

                if not bc or (bc:checktinkertarget(ent) and keep == true) then
                    keep = false
                end

                if not keep then
                    table.remove(ents,i)
                end
            end
        end

        if #ents > 0 then
            local target = ents[1]
            inst.tinkertarget = target

            bc:reserveinkertarget(target)
            if anchorcheck(target) then
                return BufferedAction(inst, target, ACTIONS.LOWER_ANCHOR)
            elseif reversemastcheck(target) then
                return BufferedAction(inst, target, ACTIONS.RAISE_SAIL)
            elseif mastcheck(target) then
                return BufferedAction(inst, target, ACTIONS.HAMMER)
            end
        end
    end

    return nil
end

local ITEM_MUST = {"_inventoryitem"}
local ITEM_MUSTNOT = { "INLIMBO", "NOCLICK", "knockbackdelayinteraction", "catchable", "fire", "minesprung", "mineactive", "spider", "nosteal", "irreplaceable" }

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "playerghost" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }

local CHEST_MUST_TAGS = { "chest", "_container" }
local CHEST_CANT_TAGS = { "outofreach" }

local function shouldsteal(inst)

    if inst.sg:HasStateTag("busy") or inst.components.timer:TimerExists("hit") then
        return nil
    end

    inst.nothingtosteal = nil
    if inst.components.inventory:IsFull() then
        return nil
    end

    if inst.components.combat.target and not inst.components.combat:InCooldown() then
        return nil
    end

    local boattarget = inst.components.crewmember and inst.components.crewmember.boat and inst.components.crewmember.boat.components.boatcrew and inst.components.crewmember.boat.components.boatcrew.target or nil
    local current_platform = inst:GetCurrentPlatform()
    if not boattarget and (current_platform and inst.components.crewmember and current_platform == inst.components.crewmember.boat ) then
        return nil
    end

    local x,y,z = inst.Transform:GetWorldPosition()
    local range = 15

    local ents = TheSim:FindEntities(x, y, z, range, ITEM_MUST, ITEM_MUSTNOT)

    if #ents > 0 then
        for i=#ents,1,-1 do
            local ent = ents[i]
            if  not ent.components.inventoryitem or
                not ent.components.inventoryitem.canbepickedup or
                not ent.components.inventoryitem.cangoincontainer or
                ent.components.sentientaxe or
                ent.components.inventoryitem:IsHeld() then
                table.remove(ents,i)
            end
        end
    end

    if #ents > 0 then
        for i=#ents,1,-1 do
			if ents[i]:IsOnOcean() then
                table.remove(ents,i)
            end
        end
    end

    if #ents > 0 then
        for i,ent in ipairs(ents)do
            if ent.prefab == "cave_banana" or ent.prefab == "cave_banana_cooked" then
                inst.itemtosteal = ents[i]
                return BufferedAction(inst, inst.itemtosteal, ACTIONS.PICKUP)
                --return true
            end
        end
        inst.itemtosteal = ents[1]
        return BufferedAction(inst, inst.itemtosteal, ACTIONS.PICKUP)
    else

        -- NOTHING TO PICK UP.

        -- LOOK FOR A CHEST TO BUST
        local bc = inst.components.crewmember and inst.components.crewmember.boat and inst.components.crewmember.boat.components.boatcrew or nil
        if bc then
            local target = nil
            local chests = TheSim:FindEntities(x, y, z, 10, CHEST_MUST_TAGS, CHEST_CANT_TAGS)
            if #chests > 0 then
                for i=#chests,1,-1 do

                    local chest = chests[i]
                    local keep = false

                    if chestcheck(chest) then
                        keep = true
                    end

                    if not bc or (bc:checktinkertarget(chest) and keep == true) then
                        keep = false
                    end

                    if not keep then
                        table.remove(chests,i)
                    end
                end
            end

            if #chests > 0 then
                target = chests[1]
            end

            if target and chestcheck(target) then
                return BufferedAction(inst, target, ACTIONS.EMPTY_CONTAINER)
            end
        end
        -- LOOK FOR SOMEONE TO PUNCH

        if TheWorld.components.piratespawner
                and TheWorld.components.piratespawner.queen
                and TheWorld.components.piratespawner.queen.components.timer:TimerExists("right_of_passage") then
            inst.nothingtosteal = true
            return nil
        end

        if not inst.components.combat.target then
            local target = FindEntity(
                    inst,
                    10,
                    function(guy)
                        if guy:HasTag("monkey") then
                            return false
                        end

                        if not guy.components.inventory or guy.components.inventory:NumItems() == 0 then
                            return false
                        end

                        local count = 0
                        for k,v in pairs(guy.components.inventory.itemslots) do
                            local keep = true

                            if v:HasTag("nosteal") then
                                keep = false
                            end

                            if keep == true then
                                count = count +1
                            end
                        end

                        if count == 0 then
                            return false
                        end

                        local targetplatform = guy:GetCurrentPlatform()
                        local instplatform = inst:GetCurrentPlatform()

                        if targetplatform and instplatform then
                            local radius = targetplatform.components.walkableplatform.platform_radius + instplatform.components.walkableplatform.platform_radius + 4
                            if targetplatform:GetDistanceSqToInst(instplatform) > radius * radius then
                                return false
                            end
                        end

                        return inst.components.combat:CanTarget(guy)
                    end,
                    RETARGET_MUST_TAGS,
                    RETARGET_CANT_TAGS,
                    RETARGET_ONEOF_TAGS
                )
            if target then
                return BufferedAction(inst, target, ACTIONS.STEAL)
            else
                inst.nothingtosteal = true
            end
        end
    end
end

local function ShouldRunFn(inst)
    local bc = (inst.components.crewmember and inst.components.crewmember.boat and inst.components.crewmember.boat.components.boatcrew)
        or nil
    if bc and bc.status == "retreat" then
        return true
    end
end

local function shouldattack(inst)
    if (inst.bufferedaction ~= nil and inst.bufferedaction.id == ACTIONS.PICKUP.id)
            or inst.components.combat:InCooldown()
            or inst.sg:HasStateTag("busy") then
        return nil
    end

    local retreat = false
    local crewboat = (inst.components.crewmember and inst.components.crewmember.boat) or nil
    local bc = (crewboat ~= nil and crewboat.components.boatcrew) or nil
    if bc and bc.status == "retreat" then
        retreat = true
    end

    return inst.components.combat.target ~= nil
        and (not retreat or inst.components.combat.target:GetCurrentPlatform() == crewboat)
end

local function count_loot(inst)
    local loot = 0
    for k,v in pairs(inst.components.inventory.itemslots) do
        if not v:HasTag("personal_possession") then
            if v.components.stackable then
                loot = loot + v.components.stackable.stacksize
            else
                loot = loot + 1
            end
        end
    end
    return loot
end

local function DoAbandon(inst)
    if inst.components.crewmember and (inst.components.crewmember.boat == nil or not inst.components.crewmember.boat:IsValid()) then
        if (inst.nothingtosteal or count_loot(inst) > 3) and inst:GetCurrentPlatform() then
            inst.abandon = true
        end
    end

    if inst:GetCurrentPlatform() and inst:GetCurrentPlatform().components.health:IsDead() then
        inst.abandon = true
    end

    if not inst.abandon then
        return nil
    end

    local pos = Vector3(0,0,0)
    local platform = inst:GetCurrentPlatform()
    if platform then
        local x,y,z = inst.Transform:GetWorldPosition()
        local clear = false
        local count = 0
        while clear == false and count < 16 do
            local theta = platform:GetAngleToPoint(x, y, z)* DEGREES + (count * PI/8)
            count = count + 1
            local radius = platform.components.walkableplatform.platform_radius - 0.5
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

            local boatpos = platform:GetPosition()

            pos = Vector3( boatpos.x+offset.x,0,boatpos.z+offset.z )

            -- SAM should offest be getting applied twice here...?
            if not TheWorld.Map:GetPlatformAtPoint(pos.x+ offset.x, pos.z+offset.z) then
                clear = true
            end
        end

        return BufferedAction(inst, nil, ACTIONS.ABANDON, nil, pos)
    end

    return nil
end

local function ReturnToBoat(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    local myboat = inst.components.crewmember and inst.components.crewmember.boat or nil
    if myboat ~= nil and myboat.components.boatcrew and myboat.components.boatcrew.status == "retreat" then
        return myboat
    end
end

local function GoToHut(inst)
    local home = (inst.components.homeseeker ~= nil and inst.components.homeseeker.home)
        or nil
    if home == nil
            or (home.components.burnable ~= nil and home.components.burnable:IsBurning())
            or home:HasTag("burnt") then
        return nil
    end

    if inst.components.combat.target == nil then
        return BufferedAction(inst, home, ACTIONS.GOHOME)
    end
end

local HARVEST_MUSTHAVE_TAGS = {"bananabush"}
local function HarvestBanana(inst)
    local x,y,z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, 15, HARVEST_MUSTHAVE_TAGS)
    if #ents > 0 then
        for i=#ents,1,-1 do
            local ent = ents[i]
            if ent.prefab == "bananabush" and ent.components.pickable and ent.components.pickable.canbepicked then
                return BufferedAction(inst, ents[1], ACTIONS.PICK)
            end
        end
    end
end

local function item_is_monkeyqueen_bribe(item)
    return item:HasTag("monkeyqueenbribe")
end

local function bananahandoff(inst)
    -- has banana
    if not TheWorld.components.piratespawner then
        return nil
    end

    local queen = TheWorld.components.piratespawner.queen
    if not queen or queen.sg:HasStateTag("busy") then
        return nil
    end

    if inst.components.crewmember then
        return nil
    end

    local banana = inst.components.inventory:FindItem(item_is_monkeyqueen_bribe)
    if banana then
        return BufferedAction(inst, queen, ACTIONS.GIVE, banana)
    end
end

local function is_stashable_item(item)
    return item.prefab ~= "cave_banana"
        and item.prefab ~= "cave_banana_cooked"
        and not item:HasTag("personal_possession")
end
local function stashhomeloot(inst)

    local home = (inst.components.homeseeker ~= nil and inst.components.homeseeker.home)
        or nil
    if home == nil
            or (home.components.burnable ~= nil and home.components.burnable:IsBurning())
            or home:HasTag("burnt") then
        return nil
    end

    local item = inst.components.inventory:FindItem(is_stashable_item)
    if item then
        return BufferedAction(inst, home, ACTIONS.GOHOME)
    end
end


local CANNON_MUST = {"boatcannon"}
local BOAT_MUST = {"boat"}

local function hastargetboat(inst, arc)
    local px, py, pz = inst.Transform:GetWorldPosition()

    local cannons
    if inst.components.crewmember and inst.components.crewmember.boat then
        cannons = inst.components.crewmember.boat.cannons or {}
    else
        cannons = TheSim:FindEntities(px, py, pz, 25, CANNON_MUST) or {}
    end

    if #cannons > 0 then
        local targetboats = TheSim:FindEntities(px, py, pz, 25, BOAT_MUST)

        if #targetboats > 0 then
            for _, boat in ipairs(targetboats) do
                if not inst.components.crewmember or boat ~= inst.components.crewmember.boat then
                    for _, cannon in ipairs(cannons) do
                        if cannon:IsValid() and not cannon.components.timer:TimerExists("monkey_biz") and cannon:GetDistanceSqToInst(boat) < 25*25 then
                            return {cannon=cannon,boat=boat}
                        end
                    end
                end
            end
        end
    end
end

local function findcannonspot(inst, cannon, boat)
    local cannonpos = cannon:GetPosition()
    local radius = 2
    local theta = boat:GetAngleToPoint(cannonpos.x, cannonpos.y, cannonpos.z)* DEGREES
    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

    if offset and inst:GetDistanceSqToPoint(cannonpos+offset) > (0.25*0.25) then
        return cannonpos+offset
    end
end


local function gotocannon(inst)
    local arc = (not inst.components.crewmember and 45) or nil
    local data = hastargetboat(inst, arc)
    if data and data.cannon and data.boat then
        local pos = findcannonspot(inst, data.cannon, data.boat)
        if pos then
            return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pos)
        end
    end
end

local function monkeyinarc(inst, cannon, target)


    local tx,ty,tz = target.Transform:GetWorldPosition()
    local mx,my,mz = inst.Transform:GetWorldPosition()
    local angle_to_target = cannon:GetAngleToPoint(tx, ty, tz)
    local angle_to_monkey = cannon:GetAngleToPoint(mx, my, mz)

    local function finddiff(a1,a2)
        local diff = math.abs(a1 - a2)
        if diff > 180 then
            diff = math.abs(diff - 360)
        end
        return diff
    end
    local anglediff =  finddiff(angle_to_target,angle_to_monkey)
    
    --print(inst.GUID, anglediff)

    if anglediff < 90 then
        return true
    end
end

local function firecannon(inst)
    local arc = (not inst.components.crewmember and 45) or nil
    local data = hastargetboat(inst, arc)

    if data and data.cannon and data.boat and data.cannon:GetDistanceSqToInst(inst) < 2*2 and data.boat and not monkeyinarc(inst, data.cannon, data.boat) then
        local bx, by, bz = data.boat.Transform:GetWorldPosition()
        data.cannon.Transform:SetRotation(data.cannon:GetAngleToPoint(bx, by, bz) + math.random()*60-30)
        return BufferedAction(inst, data.cannon, ACTIONS.BOAT_CANNON_SHOOT)
    end
end

local function shouldrun(inst)
    return inst.components.combat.target ~= nil and inst.components.timer:TimerExists("hit")
end

function PowderMonkeyBrain:OnStart()

    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
		WhileNode(
			function()
				return self.inst.components.homeseeker ~= nil
					and self.inst.components.homeseeker.home
					and self.inst.components.homeseeker.home.components.burnable
					and self.inst.components.homeseeker.home.components.burnable:IsBurning()
			end,
			"OnFire", Panic(self.inst)),

        ChattyNode(self.inst, "MONKEY_TALK_ABANDON",
            DoAction(self.inst, DoAbandon, "abandon", true )),

        WhileNode(function() return shouldrun(self.inst) end, "Should run",
            RunAway(self.inst, function(guy) return self.inst.components.combat.target and self.inst.components.combat.target == guy or nil end, SEE_PLAYER_DIST, STOP_RUN_DIST, nil, true)),

        -- if has a combat target fight it, unless in cooldown or has the order to retreat and not on their own boat.
        WhileNode(function() return shouldattack(self.inst) end, "Should attack",
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),

        ChattyNode(self.inst, "MONKEY_TALK_FIRECANNON",
            DoAction(self.inst, firecannon, "cannon", true )),
        DoAction(self.inst, gotocannon, "gotocannon", true ),

        DoAction(self.inst, rowboat,"rowing",nil,3),

        ChattyNode(self.inst, "MONKEY_TALK_RETREAT",
            Follow(self.inst, ReturnToBoat, 0, 1, 2)),

        -- if should run away, go to and stay on your own boat.
        WhileNode(function() return ShouldRunFn(self.inst) end, "running away",
            Leash(self.inst, function() return self.inst.components.crewmember ~= nil and 
                                        self.inst.components.crewmember.boat ~= nil and 
                                        self.inst.components.crewmember.boat:GetPosition()
                                    end, RETURN_DIST, BASE_DIST)),

        -- otherwise , tinter with stuff and
        DoAction(self.inst, Dotinker, "tinker", true ),

        DoAction(self.inst, bananahandoff,"bananahandoff",nil,3),
        DoAction(self.inst, stashhomeloot,"stash ",nil,3),

        -- steal stuff
        ChattyNode(self.inst, "MONKEY_TALK_STEAL",
            DoAction(self.inst, shouldsteal, "steal")),

        ChattyNode(self.inst, "MONKEY_TALK_RETREAT",
            WhileNode(function() return TheWorld.state.isnight end, "Is Night",
                DoAction(self.inst, GoToHut, "Go Home", true))),

        DoAction(self.inst, HarvestBanana, "harvestbanana", true ),
        Wander(self.inst,
            function() return findwanderpointfn(self.inst) end,
            function() return findmaxwanderdistfn(self.inst) end,
            {minwalktime=0.2,randwalktime=.8,minwaittime=1,randwaittime=5}
        )

    }, .25)
    self.bt = BT(self.inst, root)
end

return PowderMonkeyBrain
