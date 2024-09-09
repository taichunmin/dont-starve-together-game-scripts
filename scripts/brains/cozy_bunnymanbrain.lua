require "behaviours/chaseandattack"
require "behaviours/chattynode"
require "behaviours/doaction"
require "behaviours/faceentity"
require "behaviours/findlight"
require "behaviours/follow"
require "behaviours/leash"
require "behaviours/panic"
require "behaviours/runaway"
require "behaviours/standstill"
require "behaviours/wander"

local BrainCommon = require("brains/braincommon")

local MAX_WANDER_DIST = 3

local MAX_ARENA_WANDER_DIST = TUNING.BUNNY_RING_MINIGAME_ARENA_RADIUS - 1.25

local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6
local GAMERANGE = 10

local SPOILSPORT_DATA = {text=STRINGS.COZY_RABBIT_SPOILSPORT}

local function getcheer()
    return {text=STRINGS.COZY_RABBIT_CHEER[math.random(1,#STRINGS.COZY_RABBIT_CHEER)]}
end
local function getmooncheer()
    return {text=STRINGS.COZY_RABBIT_MOON[math.random(1,#STRINGS.COZY_RABBIT_MOON)]}
end

local function fightringfilter(shrine,rabbit)
    return rabbit and (not rabbit.components.minigame_spectator
        and not rabbit.components.minigame_participator)
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetHomePos(inst)
    return inst.components.knownlocations:GetLocation("pillowSpot")
end

local function GetNoLeaderHomePos(inst)
    return GetHomePos(inst)
end

local function find_bodypillow(item)
    return item:HasTag("bodypillow")
end

local function plantpillow(inst)
    if inst:WantsToGoBackToPillowSpot() or inst.components.sleeper:IsAsleep() or inst.sg:HasStateTag("busy") then
        -- We're sleepy, busy, or planning to dig back to our pillow position when we get a chance.
        -- Let's let those resolve themselves before trying to go drop the pillow.
        return nil
    end

    local pillow_drop_position = inst.components.knownlocations:GetLocation("pillowSpot")
    if not pillow_drop_position then
        -- We don't have a pillow-dropping spot to even try, so let's not.
        return nil
    end

    local home = inst.components.homeseeker:GetHome()
    if home and not home:IsInLimbo() then
        -- We should be trying to go home instead if our home pillow is placed out of our inventory.
        return nil
    end

    local pillow = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if not pillow or not find_bodypillow(pillow) then
        pillow = inst.components.inventory:FindItem(find_bodypillow)
    end

    if pillow then
        local drop_pillow_action = BufferedAction(inst, nil, ACTIONS.DROP, pillow, pillow_drop_position)
        if drop_pillow_action then
            drop_pillow_action.validfn = function() return not inst.sg:HasStateTag("hide") end
            return drop_pillow_action
        end
    end
end

local function gotopillowlocation(inst)
    if inst.components.sleeper:IsAsleep() or inst.sg:HasStateTag("busy") then
        return nil
    end

    local pillow_drop_position = inst.components.knownlocations:GetLocation("pillowSpot")
    if not pillow_drop_position then
        -- We don't have a pillow-dropping spot to even try, so let's not.
        return nil
    end

    local home = inst.components.homeseeker:GetHome()
    if home and not home:IsInLimbo() then
        -- We should be trying to go home instead if our home pillow is placed out of our inventory.
        return nil
    end

    local pillow = inst.components.inventory:FindItem(find_bodypillow)
    local dsq = inst:GetDistanceSqToPoint(pillow_drop_position)

    if not pillow and dsq > 2.0 then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pillow_drop_position)
    end
end

local function shouldgobacktocave(inst)
    if IsSpecialEventActive(SPECIAL_EVENTS.YOTR) and inst.components.entitytracker:GetEntity("shrine") then
        return nil
    end

    local pillow = inst.components.entitytracker:GetEntity("floorpillow")
    if pillow and not pillow.components.inventoryitem then
        inst.needspillow = true
        return nil
    else
        inst.isleaveing = true
        inst:PushEvent("gobacktocave")
    end
end

local function shouldgotopillowforsleep(inst)
    if TheWorld.state["isday"] then
        local pillow = inst.components.entitytracker:GetEntity("floorpillow")
        if pillow and not pillow.components.inventoryitem and inst:GetDistanceSqToInst(pillow) > 0.25 then
			inst.components.combat:DropTarget()
            return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pillow:GetPosition())
        end
    end
end

local QUESTION_DATA = {text=STRINGS.COZY_RABBIT_QUESTION_DANGER}
local function shouldcheer(inst)
    if inst.components.sleeper:IsAsleep() then
        return nil
    end

    if inst.sg:HasStateTag("idle") then
        if inst.shouldquestion == true then
            inst.shouldquestion = nil
            inst:PushEvent("question", QUESTION_DATA)
        elseif math.random() < 0.025 then
            if TheWorld.state.isfullmoon then
                inst:PushEvent("dance", getmooncheer())
            else
                inst:PushEvent("cheer", getcheer())
            end
        end
    end
end

local function trytohide(inst)
    if inst.shouldhide then
        inst:PushEvent("hide")
    end
end

local function dropprizeforplayer(inst)
    local prize_info = inst.fightprizes[1]
    if prize_info then
        local winner = prize_info.winner
        winner = winner:IsValid() and winner or nil
        local my_position = inst:GetPosition()

        local base_position = (winner and winner:GetPosition()) or my_position
        local offset_angle = (winner and winner:GetAngleToPoint(my_position) * DEGREES)
            or TWOPI*math.random()
        local drop_position = base_position + Vector3(3*math.cos(offset_angle), 0, -3*math.sin(offset_angle))

        local drop_prize_action = BufferedAction(inst, nil, ACTIONS.DROP, prize_info.prize, drop_position)
        drop_prize_action:AddSuccessAction(function() table.remove(inst.fightprizes, 1) end)
        return drop_prize_action
    end
end

local function randompillowswing(inst)
    if inst.components.sleeper:IsAsleep() then
        return nil
    end

    local shrine = inst.components.entitytracker:GetEntity("shrine")
    local ents = shrine and shrine:getrabbits(fightringfilter) or {}
    for _, ent in ipairs(ents)do
        if ent ~= inst and math.random()<0.2 then
            inst.components.combat:SetTarget(ent)
            inst.components.timer:StartTimer("pillow_attack_cooldown", 10)
            local ba = BufferedAction(inst, ent, ACTIONS.ATTACK)
            if ba then
                inst._clear_target = inst._clear_target or function()
                    inst.components.combat:SetTarget(nil)
                end
                ba:AddSuccessAction(inst._clear_target)
                ba:AddFailAction(inst._clear_target)
            end
            return ba
        end
    end

    return nil
end

local function GetFaceTargetFn(inst)
    if inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("emote") then
        return nil
    end

    if inst.components.sleeper:IsAsleep() then
        return nil
    end

    if next(inst.components.inventory:GetItemByName("carrot",1)) ~= nil then
        -- if we have a carrot, play the game, don't talk..
        return nil
    end

    if inst.components.timer:TimerExists("facetime_delay") then
        return nil
    end

    inst.components.timer:StartTimer("facetime",5)
    inst.components.timer:StartTimer("facetime_delay",15)

    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return inst ~= nil and target ~= nil
        and inst.components.timer:TimerExists("facetime")
        and inst:IsValid() and target:IsValid()
        and inst:IsNear(target, KEEP_FACE_DIST)
        and not (target:HasTag("notarget") or
                target:HasTag("playerghost"))
end

-----------------------------------------------
-- carrot spin

-- Look at spinning bunny
local function GetSpinFaceTargetFn(inst)
    if inst.carrotgamestatus then
        return nil
    end
    local shrine = inst.components.entitytracker:GetEntity("shrine")
    local ents = shrine and shrine:getrabbits() or nil
    if ents == nil then
        return nil
    end

    local target = nil
    for _, ent in ipairs(ents)do
        if ent.carrotgamestatus then
            target = ent
            break
        end
    end

    return target
end

local function KeepSpinFaceTargetFn(inst, target)
    return inst ~= nil and target ~= nil
        and inst:IsValid() and target:IsValid()
        and target.carrotgamestatus
end
-- END Loot at spinning bunny.

local function sayspoilsport(inst)
    if inst.sg:HasStateTag("idle") then
        inst.sayspoilsport = nil
        inst:PushEvent("disappoint", SPOILSPORT_DATA)
    end
end

-- Eat goop & finish the game
local function shrine_clear_game(shrine)
    shrine.gameinprogress = nil
    shrine:SetShrineWinner(nil)
end

local function goopeaten(inst)
    local shrine = inst.components.entitytracker:GetEntity("shrine")
    if shrine and shrine.gameinprogress then
        shrine.gameinprogress = "endcheer"
        shrine:DoTaskInTime(5, shrine_clear_game)
    end
end

local function goopnoteatenintime_reaction(shrine)
    local buns = shrine:getrabbits(fightringfilter) or {}
    for _, bun in ipairs(buns) do
       bun:PushEvent("disappoint", SPOILSPORT_DATA)
    end
    shrine_clear_game(shrine)
end

local function goopnoteatenintime(inst)
    local shrine = inst.components.entitytracker:GetEntity("shrine")
    if shrine and shrine.gameinprogress then
        shrine:DoTaskInTime(2, goopnoteatenintime_reaction)
    end
end
-- END ----------------------

local function checkforcarrotgame(inst)
    if inst.components.minigame_spectator
            or inst.components.minigame_participator
            or inst.components.knownlocations:GetLocation("pillowfightlocation")
            or inst.components.entitytracker:GetEntity("arena") then
        return nil
    end

    local home = inst.components.homeseeker:GetHome()
    if not home then
        return nil
    end

    local shrine = inst.components.entitytracker:GetEntity("shrine")
    if not shrine then
        return nil
    elseif shrine.gameinprogress then
        return true
    elseif not TheWorld.state.isday and not inst.components.timer:TimerExists("shouldspincheck") then
        inst.components.timer:StartTimer("shouldspincheck", math.random()*10)

        if next(inst.components.inventory:GetItemByName("carrot", 1)) ~= nil
                or (math.random() < 0.05 and not shrine.components.timer:TimerExists("yotr_carrotgamecooldown")) then
            shrine.components.timer:StartTimer("yotr_carrotgamecooldown",math.random()*150 + 30) --180
            shrine.gameinprogress = "beginning"
            inst.gamehost = true
            inst.carrotgamestatus = "home"

            return true
        end
    end

    return nil
end

local function carrotgameplayer(inst)
    local shrine = inst.components.entitytracker:GetEntity("shrine")
    local home = inst.components.homeseeker:GetHome()
    if shrine and shrine.gameinprogress then
        if shrine.gameinprogress == "start" then
            if inst:GetDistanceSqToInst(home) > 0.5*0.5 then
                return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, home:GetPosition())
            end
            inst:ForceFacePoint(shrine.Transform:GetWorldPosition())

            if not inst.sg:HasStateTag("emote") then
                inst:PushEvent("cheer", {text=STRINGS.COZY_RABBIT_SPIN})
            end
        end
        if shrine.gameinprogress == "winner" then
            if shrine.gamewinner ~= inst then
                if math.random() < 0.3 and
                        inst.sg:HasStateTag("idle") and
                        shrine.gamewinner and shrine.gamewinner:IsValid() then
                    inst:ForceFacePoint(shrine.gamewinner.Transform:GetWorldPosition())

                    if not inst.components.timer:TimerExists("cheertimer") then
                        local choice = STRINGS.COZY_RABBIT_WINNER[math.random(1,#STRINGS.COZY_RABBIT_WINNER)]
                        inst:DoTaskInTime(math.random()*0.3, function()
                                if shrine.gamewinner then
                                    inst:PushEvent("cheer", {text=subfmt(choice, {winner=shrine.gamewinner.name})})
                                end
                            end)

                        inst.components.timer:StartTimer("cheertimer",math.random() + 2)
                    end
                end
            end
        end

        if shrine.gameinprogress == "endcheer" then
            if not inst.sg:HasStateTag("emote") then
                inst:PushEvent("dance", {text=STRINGS.COZY_RABBIT_YAY})
            end
        end
    end
end

local function carrotgamemanager(inst)
    local shrine = inst.components.entitytracker:GetEntity("shrine")
    if shrine and inst.carrotgamestatus then

        if inst.carrotgamestatus == "home" then
            local home = inst.components.homeseeker:GetHome()

            inst.carrotgamestatus = "start"
            return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, home:GetPosition())
        end

        if inst.carrotgamestatus == "start" then
            inst:ForceFacePoint(shrine.Transform:GetWorldPosition())

            inst.components.timer:StartTimer("carrot_game_start", 3)

            inst.carrotgamestatus = "startcheer"
        end

        if inst.carrotgamestatus == "startcheer" then
            local theta = inst.Transform:GetRotation()*DEGREES
            local radius = 3
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

            inst.carrotlocation = inst:GetPosition() + offset

            if inst.components.timer:TimerExists("carrot_game_start") then
                if not inst.sg:HasStateTag("emote") then
                    inst:PushEvent("cheer", {text=STRINGS.COZY_RABBIT_SPINGAMESTART})
                end
            else
                shrine.gameinprogress = "start"
                inst.carrotgamestatus = "drop"
            end
        end

        if inst.carrotgamestatus == "drop" then
            local carrot = next(inst.components.inventory:GetItemByName("carrot",1))
            if not carrot then
                carrot = SpawnPrefab("carrot")
                inst.components.inventory:GiveItem(carrot)
            end
            inst.components.entitytracker:TrackEntity("carrot",carrot)

            inst:ListenForEvent("onpickup", function(_, data)
                    if data.owner ~= inst then
                        inst:OnAttacked()
                    end
                end, carrot)

            inst.carrotgamestatus = "return"
            return BufferedAction(inst, nil, ACTIONS.DROP, carrot, inst.carrotlocation)
        end

        if inst.carrotgamestatus == "return" then
            local carrot = inst.components.entitytracker:GetEntity("carrot")
            if carrot then
                carrot:Spin(5)

                inst.carrotgamestatus = "wait"

                local home = inst.components.homeseeker:GetHome()
                return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, home:GetPosition())
            else
                shrine_clear_game(shrine)
            end
        end

        if inst.carrotgamestatus == "wait" then
            local carrot = inst.components.entitytracker:GetEntity("carrot")
            if carrot then
                if not carrot.components.inventoryitem.owner then
                    inst:ForceFacePoint(carrot.Transform:GetWorldPosition())

                    if carrot.AnimState:IsCurrentAnimation("spin_pst") then
                        inst.carrotgamestatus = "declare"
                    end
                end
            else
                inst:finishgame()
            end
        end

        if inst.carrotgamestatus == "declare" then
            local carrot = inst.components.entitytracker:GetEntity("carrot")
            local gamers_to_angles = {}

            -- Add any rabbits that can play.
            local rabbits = shrine:getrabbits(fightringfilter)
            if rabbits then
                for _, rabbit in ipairs(rabbits) do
                    if not rabbit.components.entitytracker or not rabbit.components.entitytracker:GetEntity("arena") then
                        gamers_to_angles[rabbit] = carrot:GetAngleToPoint(rabbit.Transform:GetWorldPosition())
                    end
                end
            end

            -- Add any nearby players that can play.
            local x,y,z = carrot.Transform:GetWorldPosition()
            local players = FindPlayersInRangeSq(x, y, z, GAMERANGE*GAMERANGE, true)
            for _, player in ipairs(players) do
                gamers_to_angles[player] = carrot:GetAngleToPoint(player.Transform:GetWorldPosition())
            end

            -- Find the competitor that our carrot is the closest to pointing at.
            local target = nil
            local diff = 99999
            for gamer, angle in pairs(gamers_to_angles) do
                local testdiff = math.abs(anglediff(carrot.Transform:GetRotation(), angle))
                if testdiff < diff then
                    diff = testdiff
                    target = gamer
                end
            end

            if not target then
                -- no winner
                inst:finishgame()
            else
                --target = FindClosestPlayerToInst(inst,40)   -- DEBUG FOR TESTING PLAYER WIN

                shrine.gameinprogress = "winner"
                shrine:SetShrineWinner(target)

                inst.components.timer:StartTimer("wincheer",3)
                inst.carrotgamestatus = "winnercheer"

                target.light = SpawnPrefab("yotb_post_spotlight")
                target.light.Transform:SetScale(0.75, 0.75, 0.75)
                target.light:DoTaskInTime(5, target.light.fadeout)
                target:AddChild(target.light)
            end
        end

        if inst.carrotgamestatus == "winnercheer" then
            if inst.components.timer:TimerExists("wincheer") then
                if shrine.gamewinner and shrine.gamewinner ~= inst and not inst.sg:HasStateTag("emote") then
                    inst:PushEvent("cheer", {text=shrine.gamewinner.name})
                end
            else
                inst.carrotgamestatus = "prizedeliver"
            end
        end

        if inst.carrotgamestatus == "prizedeliver" then
            local goop = inst.components.entitytracker:GetEntity("goop")

            if not goop then
                goop = SpawnPrefab("hareball")

                inst.components.inventory:GiveItem(goop)
                inst.components.entitytracker:TrackEntity("goop", goop)

                goop.yotr_targeteater = shrine.gamewinner
                goop:ListenForEvent("oneaten", function(food,data)
                        if data.eater == food.yotr_targeteater and
                                inst.components.timer:TimerExists("yotr_waitforplayertoeat") then
                            inst.carrotgamestatus = "givenuggets"
                            inst.components.timer:StopTimer("yotr_waitforplayertoeat")
                        end
                        goopeaten(inst)
                    end)

                if shrine.gamewinner and shrine.gamewinner:HasTag("player") then
                    inst.components.timer:StartTimer("yotr_waitforplayertoeat",10)
                end
            elseif goop.components.inventoryitem.owner == inst then
                local pos

                if shrine.gamewinner and shrine.gamewinner ~= inst then
                    local radius = 3
                    local theta = shrine.gamewinner:GetAngleToPoint(inst.Transform:GetWorldPosition()) * DEGREES
                    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                    pos = shrine.gamewinner:GetPosition() + offset
                else
                    pos = inst:GetPosition()
                end
                return BufferedAction(inst, nil, ACTIONS.DROP, goop, pos)
            else
                if shrine.gamewinner then
                    shrine.gamewinner.gooptoeat = goop
                end
                inst.carrotgamestatus = "prizedelivered"
                inst.components.entitytracker:ForgetEntity("goop")
            end
        end

        if inst.carrotgamestatus == "prizedelivered" then
            local pillow = inst.components.entitytracker:GetEntity("floorpillow")
            if pillow then
                if inst:GetDistanceSqToInst(pillow) > 0.25 then
                    return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pillow:GetPosition())
                else
                    local x,y,z = shrine.Transform:GetWorldPosition()
                    inst:ForceFacePoint(x, 0, z)
                end
            end

            if inst.sayspoilsport == true then
                goopnoteatenintime(inst)
                inst:PushEvent("disappoint", SPOILSPORT_DATA)
                shrine:SetShrineWinner(nil)
            end
        end

        if inst.carrotgamestatus == "givenuggets" then
            inst:PushEvent("setupprizes", {
                type = IsSpecialEventActive(SPECIAL_EVENTS.YOTR) and "lucky_goldnugget" or "goldnugget",
                count = 3,
                winner = shrine.gamewinner,
            })
            inst.carrotgamestatus = "prizedelivered"
            shrine:SetShrineWinner(nil)
        end
    end
end

local function shouldeatcarrot(inst)
    local carrot = inst.components.entitytracker:GetEntity("carrot")
    if carrot then
        if not carrot.components.inventoryitem.owner then
            return BufferedAction(inst, carrot, ACTIONS.EAT)
        else
            inst.components.entitytracker:ForgetEntity("carrot")
        end
    end
end

local function eatgoop(inst)
    if inst.gooptoeat and not inst.gooptoeat.components.inventoryitem.owner then
        return BufferedAction(inst, inst.gooptoeat, ACTIONS.EAT)
    end
end
---------------------------------------------

local function getpillow(inst)
    if inst.components.sleeper:IsAsleep() or
            inst.sg:HasStateTag("busy") or
            inst.sg:HasStateTag("emote") then
        return nil
    end

    local pillow = inst.components.entitytracker:GetEntity("floorpillow")

    -- Pillow exists and is not in someones inventory now
    if not pillow or pillow.components.inventoryitem then
        return nil
    end

    -- Rabbit needs the pillow to do something
    if not inst.needspillow then
        return nil
    end

    local pos = pillow:GetPosition()
    local dsq = inst:GetDistanceSqToPoint(pos)
    if dsq > 1 then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pos )
    else
        return BufferedAction(inst, pillow, ACTIONS.PICKUP )
    end
end

local function shouldgotoarena(inst)
    if inst.components.sleeper:IsAsleep() or inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("emote") then
        return nil
    end

    local pillow = inst.components.entitytracker:GetEntity("floorpillow")
    if pillow and ( not pillow.components.inventoryitem or pillow.components.inventoryitem.owner ~= inst ) then
        return nil
    end

    -- If we have a pillow fight location, we've already gone to the arena, so don't keep trying to go.
    if inst.components.knownlocations and inst.components.knownlocations:GetLocation("pillowfightlocation") then
        return nil
    end

    local arena = inst.components.entitytracker:GetEntity("arena")
    if arena then
        inst:PushEvent("digtolocation", {arena = arena})
    end
end

local function shoulddigbacktopillowring(inst)
    if not inst._return_to_pillow_spot or inst.components.sleeper:IsAsleep() or inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("emote") then
        return nil
    end

    local original_pillow_spot = inst.components.knownlocations:GetLocation("pillowSpot")
    if original_pillow_spot then
        inst:PushEvent("digtolocation", {pos = original_pillow_spot})
    end
end

local function GetArenaPos(inst)
    local arena = inst.components.entitytracker:GetEntity("arena")
    return (arena and arena:GetPosition()) or nil
end

local function is_not_competing_in_pillow_fight(inst)
    local minigame = inst.components.minigame_participator:GetMinigame()
    if minigame and minigame.IsCompeting and not minigame:IsCompeting(inst)
            and not (minigame.components.minigame and minigame.components.minigame:GetIsOutro()) then
        return true
    end
end

local function NotCompetingWatchPosition(inst)
    local minigame = inst.components.minigame_participator:GetMinigame()
    return inst:GetPositionAdjacentTo(minigame, TUNING.BUNNY_RING_MINIGAME_ARENA_RADIUS + 2.0)
end

local function GetArenaFaceForNonCompetitors(inst)
    return inst.components.minigame_participator:GetMinigame()
end

local function PanicChat(inst)
    return (inst.components.hauntable and inst.components.hauntable.panic and STRINGS.RABBIT_PANICHAUNT[math.random(#STRINGS.RABBIT_PANICHAUNT)])
        or (inst.components.health.takingfiredamage and STRINGS.RABBIT_PANICFIRE[math.random(#STRINGS.RABBIT_PANICFIRE)])
        or (inst.components.timer:TimerExists("shouldhide") and STRINGS.COZY_RABBIT_PANICHIT[math.random(#STRINGS.COZY_RABBIT_PANICHIT)])
        or nil
end

local CozyBunnymanBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MINIGAME_WANDER_DATA = {minwalktime=0.2, randwalktime=0.7, minwaittime=0.1, randwaittime=0.3, shouldrun = true}
local ARENA_WANDER_DATA = {minwalktime=0.3, randwalktime=1, minwaittime=3,randwaittime=5}
local WANDER_DATA = {minwaittime=3,randwaittime=5,minwalktime=0.5,randwalktime=2}
local PRIORITY_NODE_RATE = 0.5
function CozyBunnymanBrain:OnStart()

    local pillowfightgame = PriorityNode({
            WhileNode( function() return is_not_competing_in_pillow_fight(self.inst) end, "Not Competing",
                PriorityNode({
                    Leash(self.inst, NotCompetingWatchPosition, 0.1, 0.1, true),
                    FaceEntity(self.inst, GetArenaFaceForNonCompetitors, is_not_competing_in_pillow_fight),
                }, PRIORITY_NODE_RATE)
            ),
            WhileNode( function()
                    if self.inst.components.knownlocations then
                        local minigame = self.inst.components.minigame_participator:GetMinigame()
                        if minigame and minigame.components.minigame and minigame.components.minigame:GetIsIntro() then
                            return true -- If the start position doesn't exist, we'll fail the Leash and continue anyway
                        end
                    end

                    return nil
                end, "go to initial position during minigame intro",
                Leash(self.inst, function() return self.inst.components.knownlocations:GetLocation("yotr_fightring_fightstartpos") end, 0.2, 0.2, true)
            ),

            WhileNode( function() return not self.inst.sg.mem.is_holding_overhead
                                    and not self.inst.components.timer:TimerExists("pillow_attack_cooldown")
                                    and not self.inst.components.minigame_participator:GetMinigame().components.minigame:GetIsOutro()
                        end, "object attack pre cooldown",
                ActionNode(function()
                    self.inst:PushEvent("raiseobject")

                    local hand_weapon = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    local delay = 1.5*((hand_weapon and hand_weapon._laglength) or 1.0)
                    self.inst.components.timer:StartTimer("pillow_minigame_swing_delay", delay)
                    self.inst.components.timer:StartTimer("pillow_attack_cooldown", 2.0 + delay)
                end)),
            WhileNode( function() return self.inst.sg.mem.is_holding_overhead and not self.inst.components.timer:TimerExists("pillow_minigame_swing_delay") end, "ready to swing?", 
                ChaseAndAttack(self.inst, 0.5, 2*TUNING.BUNNY_RING_MINIGAME_ARENA_RADIUS, 1)
            ),
            ParallelNode{
                WaitNode(2.0),
                Wander(self.inst, GetArenaPos, MAX_ARENA_WANDER_DIST, MINIGAME_WANDER_DATA),
            },
            Leash(self.inst, GetArenaPos, TUNING.BUNNY_RING_MINIGAME_ARENA_RADIUS * 0.6, TUNING.BUNNY_RING_MINIGAME_ARENA_RADIUS * 0.4),
            Wander(self.inst, GetArenaPos, MAX_ARENA_WANDER_DIST, MINIGAME_WANDER_DATA),
        }, PRIORITY_NODE_RATE)

    local carrotgame = PriorityNode({

                DoAction(self.inst, eatgoop, "eat goop", true),

                WhileNode( function() return not self.inst.gamehost end, "carrot game player",
                    DoAction(self.inst, carrotgameplayer, "play carrot game", true )),

                WhileNode( function() return not self.inst.components.timer:TimerExists("shouldspincheck") or self.inst.gamehost end, "carrot game manager",
                    DoAction(self.inst, carrotgamemanager, "manage carrot game", true )),

                StandStill(self.inst),

            }, PRIORITY_NODE_RATE)

    local panic_test = function()
        return (self.inst.components.hauntable and self.inst.components.hauntable.panic)
            or self.inst.components.health.takingfiredamage
            or (not self.inst.components.minigame_participator and self.inst.components.timer:TimerExists("shouldhide"))
    end

    local get_pillow_fight_location = function() return self.inst.components.knownlocations:GetLocation("pillowfightlocation") end

    local root =
        PriorityNode(
        {
            BrainCommon.PanicWhenScared(self.inst, .25, "RABBIT_PANICBOSS"),

            WhileNode( panic_test, "Haunted, Hiding, or On Fire",
                ChattyNode(self.inst, PanicChat,
                    Panic(self.inst))),

            DoAction(self.inst, shouldgobacktocave, "should leave", true ),

            FailIfSuccessDecorator(ConditionWaitNode(function() return not self.inst.isleaveing end, "Block While Leaving")),
            -----------------------------------------------------------------------------------------

            DoAction(self.inst, trytohide, "should it hide?", true ),

            DoAction(self.inst, shouldgotopillowforsleep, "sleeptime?", true ),

            WhileNode( function() return self.inst.components.minigame_participator
                        and self.inst.components.minigame_participator:CurrentMinigameType() == "bunnyman_pillowfighting"
                end, "participating in a pillow fight",
                pillowfightgame
            ),

            WhileNode( function() return self.inst.fightprizes and #self.inst.fightprizes > 0 end, "has prizes to give",
                DoAction(self.inst, dropprizeforplayer, "drop prize", true)),

            DoAction(self.inst, getpillow, "pickup pillow", true ),
            DoAction(self.inst, shouldgotoarena, "go to arena", true ),
            DoAction(self.inst, shoulddigbacktopillowring, "return to pillow ring", true),

            IfNode(function() return not self.inst.components.entitytracker:GetEntity("arena") end, "hold pillow behaviour for arena",
                ChattyNode(self.inst, "COZY_RABBIT_PLANTPILLOW",
                    DoAction(self.inst, plantpillow, "plant pillow", true )
                )
            ),

            WhileNode( function() return checkforcarrotgame(self.inst) end, "carrot game on",
                        carrotgame),

            DoAction(self.inst, shouldeatcarrot, "eatcarrot", true),

            DoAction(self.inst, shouldcheer, "cheer", true ),

            WhileNode( function() return not self.inst.components.sleeper:IsAsleep()
                                    and not self.inst.components.minigame_participator
                                    and not self.inst:WantsToGoBackToPillowSpot()
                                    and not self.inst.components.knownlocations:GetLocation("yotr_fightring_fightstartpos")
                                    and not self.inst.components.timer:TimerExists("pillow_attack_cooldown") 
                        end, "no sleep, minigame, or swing cooldown",
                DoAction(self.inst, randompillowswing, "random pillow swing", true )
            ),

            WhileNode( get_pillow_fight_location, "arena leash",
                PriorityNode({
                    ChattyNode(self.inst, "COZY_RABBIT_GETTOKEN",
                        Leash(self.inst, get_pillow_fight_location, 0.5, 0.5),
                        nil, nil, 0.5, 0.5
                    ),
                    Wander(self.inst, get_pillow_fight_location, 0.5, ARENA_WANDER_DATA)
                }, PRIORITY_NODE_RATE)
            ),

            WhileNode(function() return not self.inst.components.entitytracker:GetEntity("arena") end, "go back to pillow spot",
                DoAction(self.inst, gotopillowlocation, "go to pillow spot")
            ),

            ChattyNode(self.inst, "COZY_RABBIT_GREET",
                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn, 3)),

            WhileNode( function() return self.inst.components.entitytracker:GetEntity("arena") end, "arena wander",
                Wander(self.inst, GetArenaPos, MAX_ARENA_WANDER_DIST, ARENA_WANDER_DATA)
            ),

            Wander(self.inst, GetNoLeaderHomePos, MAX_WANDER_DIST, WANDER_DATA),
        }, PRIORITY_NODE_RATE)

    self.bt = BT(self.inst, root)
end

return CozyBunnymanBrain
