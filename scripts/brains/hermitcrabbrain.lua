require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/findlight"
require "behaviours/panic"
require "behaviours/chattynode"
require "behaviours/leash"

local BrainCommon = require "brains/braincommon"

local MAX_WANDER_DIST = 40

local START_RUN_DIST = 3
local STOP_RUN_DIST = 5
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30
local SEE_LIGHT_DIST = 20
local TRADE_DIST = 20
local SEE_TREE_DIST = 15
local SEE_TARGET_DIST = 20
local SEE_FOOD_DIST = 10

local SEE_BURNING_HOME_DIST_SQ = 20*20

local COMFORT_LIGHT_LEVEL = 0.3

local KEEP_CHOPPING_DIST = 10

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6

local function getstring(inst, stringdata)
    if stringdata["LOW"] then
        local gfl = inst.getgeneralfriendlevel(inst)
        return stringdata[gfl][math.random(1,#stringdata[gfl])]
    else
        return stringdata[math.random(1,#stringdata)]
    end
end

-- UMBRELLA
local function using_umbrella(inst)
    local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    return equipped and equipped:HasTag("umbrella") or nil
end

local function has_umbrella(inst)
    return inst.components.inventory:FindItem(function(testitem) return testitem:HasTag("umbrella") end)
end

local function getumbrella(inst)
    local handequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    return inst.components.inventory:FindItem(function(testitem) return testitem:HasTag("umbrella") end) or (handequipped and  handequipped:HasTag("umbrella") and handequipped )
end

local function EquipUmbrella(inst)
    local umbrella = getumbrella(inst)
    if umbrella then
        inst.components.inventory:Equip(umbrella)
    end
end

local function UnEquipHands(inst)
    local item = inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
    inst.components.inventory:GiveItem(item)
end


-- COAT
local function using_coat(inst)
    local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    return equipped and inst.iscoat(equipped) or nil
end

local function has_coat(inst)
    return inst.components.inventory:FindItem(function(testitem) return inst.iscoat(testitem) end)
end

local function getcoat(inst)
    local bodyequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    return inst.components.inventory:FindItem(function(testitem) return inst.iscoat(testitem) end) or (bodyequipped and  inst.iscoat(bodyequipped) and bodyequipped )
end

local function EquipCoat(inst)
    local coat = getcoat(inst)
    if coat then
        inst.components.inventory:Equip(coat)
    end
end

local function UnEquipBody(inst)
    local item = inst.components.inventory:Unequip(EQUIPSLOTS.BODY)
    inst.components.inventory:GiveItem(item)
end

local function ShouldRunAway(inst, target)
    return not inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetTraderFn(inst)
    if inst.sg:HasStateTag("talking") then
        return nil
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TRADE_DIST, true)
    for i, v in ipairs(players) do
        if inst.components.trader:IsTryingToTradeWithMe(v) then

            local gfl = inst.getgeneralfriendlevel(inst)
            local chatter_name = "HERMITCRAB_ATTEMPT_TRADE."..gfl
            inst.components.npc_talker:Chatter(chatter_name, math.random(#(STRINGS["HERMITCRAB_ATTEMPT_TRADE"][gfl])), nil, nil, true)

            if inst.components.timer:TimerExists("speak_time") then
                inst.components.timer:SetTimeLeft("speak_time", TUNING.HERMITCRAB.SPEAKTIME)
            else
                inst.components.timer:StartTimer("speak_time",TUNING.HERMITCRAB.SPEAKTIME)
            end

            if inst.components.timer:TimerExists("complain_time") then
                local time = inst.components.timer:GetTimeLeft("complain_time")
                inst.components.timer:SetTimeLeft("complain_time", time + 10)
            else
                inst.components.timer:StartTimer("complain_time",10 + (math.random()*30))
            end

            return v
        end
    end
end

local function KeepTraderFn(inst, target)
    if inst.sg:HasStateTag("talking") then
        return nil
    end

    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function HasValidHome(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    return home ~= nil
        and home:IsValid()
        and not (home.components.burnable ~= nil and home.components.burnable:IsBurning())
        and not home:HasTag("burnt")
end

local function allnighttest(inst)
    if inst.segs and inst.segs["night"] + inst.segs["dusk"] >= 16 then
        return true
    end
end

local function GoHomeAction(inst)
    if HasValidHome(inst) and not allnighttest(inst) then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function GetHomePos(inst)
    return HasValidHome(inst) and inst.components.homeseeker:GetHomePos()
end

local LIGHTS_TAGS = {"lightsource"}

local function GetNearestLightPos(inst)
    local light = GetClosestInstWithTag(LIGHTS_TAGS, inst, SEE_LIGHT_DIST)
    if light then
        return Vector3(light.Transform:GetWorldPosition())
    end
    return nil
end

local function GetNearestLightRadius(inst)
    local light = GetClosestInstWithTag(LIGHTS_TAGS, inst, SEE_LIGHT_DIST)
    if light then
        return light.Light:GetCalculatedRadius()
    end
    return 1
end

local function formatstring(inst,str,target)
    return string.format(str,target:GetDisplayName())
end

local function getfriendlevelspeech(inst, target)
    if not inst.components.timer:TimerExists("speak_time") then

        local level = inst.components.friendlevels.level
        local str = STRINGS.HERMITCRAB_GREETING[level][math.random(#STRINGS.HERMITCRAB_GREETING[level])]

        if type(str) == "table" then
            local new = {}
            for i,sstr in ipairs(str)do
                table.insert(new,formatstring(inst,sstr,target))
            end
            str = new
        else
            str = formatstring(inst,str,target)
        end

        -- override if there are rewards.
        local rewardstr = inst.rewardcheck(inst)
        if rewardstr then
            str = rewardstr
            if inst.giverewardstask then
                inst.giverewardstask:Cancel()
                inst.giverewardstask = nil
            end
        else
            --othewise, do some cutsom stuff for fun.
            if target and level == 10 and not inst.components.timer:TimerExists("hermit_grannied"..target.GUID) then
                inst.components.timer:StartTimer("hermit_grannied"..target.GUID,TUNING.TOTAL_DAY_TIME)

                local sanity = target.components.sanity and target.components.sanity:GetPercent() or nil
                local health = target.components.health and target.components.health:GetPercent() or nil
                local hunger = target.components.hunger and target.components.hunger:GetPercent() or nil

                if (not sanity or sanity > 0.5) and
                    (not health or health > 0.5) and
                    (not hunger or hunger > 0.5) then
                    str = STRINGS.HERMITCRAB_LEVEL10_PLAYERGOOD[math.random(1,#STRINGS.HERMITCRAB_LEVEL10_PLAYERGOOD)]
                elseif sanity and (not health or sanity <= health) and (not hunger or sanity <= hunger) then
                    str = STRINGS.HERMITCRAB_LEVEL10_LOWSANITY[math.random(1,#STRINGS.HERMITCRAB_LEVEL10_LOWSANITY)]
                elseif health and (not sanity or health <= sanity) and (not hunger or health <= hunger) then
                    str = STRINGS.HERMITCRAB_LEVEL10_LOWHEALTH[math.random(1,#STRINGS.HERMITCRAB_LEVEL10_LOWHEALTH)]
                elseif hunger and (not sanity or hunger <= sanity) and (not health or hunger <= health) then
                    str = STRINGS.HERMITCRAB_LEVEL10_LOWHUNGER[math.random(1,#STRINGS.HERMITCRAB_LEVEL10_LOWHUNGER)]
                end
            end
        end

        inst.components.timer:StartTimer("speak_time",TUNING.HERMITCRAB.SPEAKTIME)

        if inst.components.timer:TimerExists("complain_time") then
            local time = inst.components.timer:GetTimeLeft("complain_time")
            inst.components.timer:SetTimeLeft("complain_time", time + 10)
        else
            inst.components.timer:StartTimer("complain_time",10 + (math.random()*30))
        end

        return str
    end
end

local function GetFaceTargetFn(inst)
    if inst.sg:HasStateTag("talking") then
        return nil
    end
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    if not target then
        inst.hasgreeted = nil
    end
    local shouldface = target ~= nil and not target:HasTag("notarget") and target or nil

    if shouldface and not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("alert") and not inst.hasgreeted then
        local str = getfriendlevelspeech(inst, target)
        if str then
            -- TODO (SAM) Leaving this as Say for now, because some of the getfriendspeechlevel options
            -- format in the player's name.
            inst.components.npc_talker:Say(str, nil, true)
        end
        inst.hasgreeted = true
    end

    if shouldface and inst.sg:HasStateTag("npc_fishing") then
        inst.sg:RemoveStateTag("canrotate")
        inst:PushEvent("oceanfishing_stoppedfishing",{reason="bothered"})
    end

    if shouldface then
        if target and target._hermit_music then
            target._hermit_music:push()
        end
    end
    return shouldface
end

local function KeepFaceTargetFn(inst, target)
    return inst ~= nil
        and target ~= nil
        and inst:IsValid()
        and target:IsValid()
        and not (target:HasTag("notarget") or
                target:HasTag("playerghost") or
                    target.sg:HasStateTag("talking"))
        and inst:IsNear(target, KEEP_FACE_DIST)
end

local function DoCommentAction(inst)
    if inst.comment_data then
        if inst.comment_data.speech then
            return BufferedAction(inst, nil, ACTIONS.COMMENT, nil, inst.comment_data.pos, nil, inst.comment_data.distance)
        else
            local buffered_action = BufferedAction(inst, nil, ACTIONS.WALKTO, nil, inst.comment_data.pos, nil, inst.comment_data.distance)
            if buffered_action then
                buffered_action:AddSuccessAction(function() inst.comment_data = nil end)
            end
            return buffered_action
        end
    end
end

local HARVEST_TAGS = {"dried"}
local function DoHarvestMeat(inst)
    local source = inst.CHEVO_marker
    if source then
        local x,y,z = source.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, inst.island_radius, HARVEST_TAGS)
        local target = nil
        for i,ent in ipairs(ents)do
            if ent.components.dryer and ent.components.dryer:IsDone() then
                target = ent
            end
        end
        if target then
            return BufferedAction(inst, target, ACTIONS.HARVEST)
        end
    end
end

local PICKABLE_TAGS = {"pickable","bush"}
local function DoHarvestBerries(inst)
    local source = inst.CHEVO_marker
    if source then
        local x,y,z = source.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, inst.island_radius, PICKABLE_TAGS)
        local target = (#ents > 0 and ents[1]) or nil
        if target then
            return BufferedAction(inst, target, ACTIONS.PICK)
        end
    end
end

local FISHING_MARKER_TAGS = {"hermitcrab_marker_fishing"}
local FISH_TAGS = {"oceanfish"}
local function DoFishingAction(inst)
    if not using_umbrella(inst) then
        local source = inst.CHEVO_marker
        if source then
            local x,y,z = source.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, inst.island_radius, FISHING_MARKER_TAGS)
            local mostfish = {total=0,idx=0}
            for i,ent in ipairs(ents)do
                local x1,y1,z1 = ent.Transform:GetWorldPosition()

                local fish = TheSim:FindEntities(x1,y1,z1, 8, FISH_TAGS)
                if #fish > mostfish.total then
                    mostfish = {total=#fish,idx=i}
                end
            end
            if mostfish.idx > 0 then
                local pos = Vector3(ents[mostfish.idx].Transform:GetWorldPosition())
                if pos then
                    inst.startfishing(inst)
                    local rod = inst.components.inventory:FindItem(function(item) return item.prefab == "oceanfishingrod" end) or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    return BufferedAction(inst, nil, ACTIONS.OCEAN_FISHING_CAST, rod, pos)
                end
            end
        end
    end
end

local function DoReel(inst)
    if inst.hookfish and inst:HasTag("fishing_idle") then
        return BufferedAction(inst, nil, ACTIONS.OCEAN_FISHING_REEL)
    end
end

local function runawaytest(inst)
    if inst.components.friendlevels.level <= TUNING.HERMITCRAB.UNFRIENDLY_LEVEL then
        local player = FindClosestPlayerToInst(inst, STOP_RUN_DIST, true)
        if not player then
            inst.hasgreeted = nil
        end
        if player and not inst.sg:HasStateTag("busy") and not inst.hasgreeted then
            local str = getfriendlevelspeech(inst, player)
            if str then
                -- TODO (SAM) Leaving this as Say for now, because some of the getfriendspeechlevel options
                -- format in the player's name.
                inst.components.npc_talker:Say(str, nil, true)
            end
            inst.hasgreeted = true
        end
        return true
    end
end

local function DoBottleToss(inst)
    if not inst.components.timer:TimerExists("bottledelay") and not using_umbrella(inst) then
        local source = inst.CHEVO_marker
        if source then
            local x,y,z = source.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, inst.island_radius, FISHING_MARKER_TAGS)
            if #ents > 0 then
                local pos = ents[math.random(1,#ents)]:GetPosition()

                if pos then
                    local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    local bottle = inst.components.inventory:FindItem(function(item) return item.prefab == "messagebottle_throwable" end) or (equipped and  equipped.prefab == "messagebottle_throwable" and equipped )
                    if not bottle  then
                        bottle = SpawnPrefab("messagebottle_throwable")
                        inst.components.inventory:GiveItem(bottle)
                    end
                    if not bottle.components.equippable.isequipped then
                        inst.components.inventory:Equip(bottle)
                    end

                    inst.dotalkingtimers(inst)
                    return BufferedAction(inst, nil, ACTIONS.WATER_TOSS, bottle, pos)
                end
            end
        end
    end
end

local SITTABLE_TAGS = {"cansit"}
local SITTABLE_WONT_TAGS = {"uncomfortable_chair"}
local function DoChairSit(inst)
    if not inst:HasTag("sitting_on_chair") and not inst.components.timer:TimerExists("sat_on_chair") then
        local source = inst.CHEVO_marker
        if source then
            local x,y,z = source.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, inst.island_radius, SITTABLE_TAGS, SITTABLE_WONT_TAGS)
            local target = nil
            if #ents > 0 then
                for _, ent in ipairs(ents)do
                    target = ent
                    break
                end
            end
            if target then
                return BufferedAction(inst, target, ACTIONS.SITON)
            end
        end
    end
end

local function DoTalkQueue(inst)
    if inst.components.npc_talker:haslines() and not inst.sg:HasStateTag("talking") and not inst.sg:HasStateTag("busy") and not inst.components.timer:TimerExists("speak_time") then
        inst.components.npc_talker:donextline()
    end
end

local function DoThrow(inst)
    if inst.itemstotoss and not inst.sg:HasStateTag("mandatory") then
        inst:PushEvent("tossitem")
    end
end

local CHATTERPARAMS_LOW = {
	echotochatpriority = CHATPRIORITIES.LOW,
}
local CHATTERPARAMS_HIGH = {
	echotochatpriority = CHATPRIORITIES.HIGH,
}

local HermitBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function HermitBrain:OnStart()

    local day = WhileNode( function() return TheWorld.state.isday or allnighttest(self.inst) end, "IsDay",
        PriorityNode{
            WhileNode( function() return not self.inst.sg:HasStateTag("mandatory") end, "unfriendly",
                PriorityNode{
                    WhileNode( function() return self.inst.comment_data ~= nil end, "comment",
                        DoAction(self.inst, DoCommentAction, "comment", true, 10 )),
                    ChattyNode(self.inst, {
                            name = function(inst) return "HERMITCRAB_ATTEMPT_TRADE."..inst.getgeneralfriendlevel(inst) end,
                            chatterparams = CHATTERPARAMS_LOW,
                        },
                        FaceEntity(self.inst, GetTraderFn, KeepTraderFn)),
                    FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
                    IfNode( function() return runawaytest(self.inst) end, "unfriendly",
                        RunAway(self.inst, "player", START_RUN_DIST, STOP_RUN_DIST)),
                    IfNode( function() return self.inst.components.friendlevels.level > TUNING.HERMITCRAB.UNFRIENDLY_LEVEL end, "friendly",
                        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn, 7)),
                    DoAction(self.inst, DoReel, "reel", true ),
                    IfNode( function() return not self.inst.sg:HasStateTag("alert")
                                        and not self.inst.sg:HasStateTag("npc_fishing")
                                        and not self.inst.sg:HasStateTag("busy")
                                        and not self.inst.components.locomotor.dest end, "Not Acting",
                        PriorityNode{
                            DoAction(self.inst, DoHarvestMeat, "meat harvest", true ),
                            DoAction(self.inst, DoHarvestBerries, "berry harvest", true ),
                            DoAction(self.inst, DoChairSit, "sit on chairs", true ),
                            DoAction(self.inst, DoFishingAction, "gone fishing", true ),
                            DoAction(self.inst, DoBottleToss, "bottle", true ),
                            IfNode( function() return not self.inst.sg:HasStateTag("sitting") end, "not sitting",
                                Wander(self.inst, GetHomePos, MAX_WANDER_DIST, nil, nil, nil, nil, {should_run = false})
                            ),
                        },0.5),
                },0.5),
        }, 0.5)

    local night = WhileNode( function() return not TheWorld.state.isday and not allnighttest(self.inst) end, "IsNight",
        PriorityNode{
            RunAway(self.inst, "player", START_RUN_DIST, STOP_RUN_DIST, function(target) return ShouldRunAway(self.inst, target) end ),
            ChattyNode(self.inst, { name = "HERMITCRAB_GO_HOME", chatterparams = CHATTERPARAMS_LOW },
                WhileNode( function() return not TheWorld.state.iscaveday or not self.inst:IsInLight() end, "Cave nightness",
                    DoAction(self.inst, GoHomeAction, "go home", true ))),
            ChattyNode(self.inst, { name = "HERMITCRAB_PANIC", chatterparams = CHATTERPARAMS_LOW },
                Panic(self.inst)),
        }, 1)

    local root =
        PriorityNode(
        {

            WhileNode( function() return BrainCommon.ShouldTriggerPanic(self.inst) end, "PanicHaunted",
                ChattyNode(self.inst, { name = "HERMITCRAB_PANICHAUNT", chatterparams = CHATTERPARAMS_LOW },
                    Panic(self.inst))),
            RunAway(self.inst, function(guy) return guy:HasTag("pig") and guy.components.combat and guy.components.combat.target == self.inst end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST ),

            IfNode( function() return not self.inst.sg:HasStateTag("busy") and TheWorld.state.israining and has_umbrella(self.inst) and not using_umbrella(self.inst) end, "umbrella",
                    DoAction(self.inst, EquipUmbrella, "umbrella", true )),
            IfNode( function() return not self.inst.sg:HasStateTag("busy") and not TheWorld.state.israining and using_umbrella(self.inst) end, "stop umbrella",
                    DoAction(self.inst, UnEquipHands, "stop umbrella", true )),
            IfNode( function() return not self.inst.sg:HasStateTag("busy") and TheWorld.state.issnowing and has_coat(self.inst) and not using_coat(self.inst) end, "coat",
                    DoAction(self.inst, EquipCoat, "coat", true )),
            IfNode( function() return not self.inst.sg:HasStateTag("busy") and not TheWorld.state.issnowing and using_coat(self.inst) end, "stop coat",
                    DoAction(self.inst, UnEquipBody, "stop coat", true )),

            DoAction(self.inst, DoThrow, "toss item", true ),
            DoAction(self.inst, DoTalkQueue, "finish talking", true ),
            day,
            night,
        }, .5)

    self.bt = BT(self.inst, root)
end

return HermitBrain

