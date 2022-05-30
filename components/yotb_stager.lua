local set_data = require("yotb_costumes")

local thresholds =
{
	{key = "EXTREMEHIGH", threshold = 12},
	{key = "VERYHIGH",    threshold = 7},
	{key = "HIGH",        threshold = 2},
	{key = "PERFECT",     threshold = -2},
	{key = "LOW",         threshold = -8},
	{key = "VERYLOW",     threshold = -13},
}

local target_thresholds =
{
	{key = "EXTREMEHIGH", threshold = 14},
	{key = "VERYHIGH",    threshold = 11},
	{key = "HIGH",        threshold = 8},
	{key = "PERFECT",     threshold = 6},
	{key = "LOW",         threshold = 3},
	{key = "VERYLOW",     threshold = 0},
	{key = "EXTREMELOW",  threshold = -1},
}


local lines =
{
	FEARSOME = {
		EXTREMEHIGH =  { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_EXTREMEHIGH },
		VERYHIGH =     { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_VERYHIGH },
		HIGH =         { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_HIGH },
		PERFECT =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_PERFECT },
		LOW =          { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_LOW },
		VERYLOW =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_VERYLOW },
		EXTREMELOW =   { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_EXTREMELOW },
	},
	FESTIVE = {
		EXTREMEHIGH =  { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_EXTREMEHIGH },
		VERYHIGH =     { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_VERYHIGH },
		HIGH =         { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_HIGH },
		PERFECT =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_PERFECT },
		LOW =          { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_LOW },
		VERYLOW =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_VERYLOW },
		EXTREMELOW =   { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_EXTREMELOW },
	},
	FORMAL = {
		EXTREMEHIGH =  { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_EXTREMEHIGH },
		VERYHIGH =     { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_VERYHIGH },
		HIGH =         { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_HIGH },
		PERFECT =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_PERFECT },
		LOW =          { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_LOW },
		VERYLOW =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_VERYLOW },
		EXTREMELOW =   { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_EXTREMELOW },
	},
}

local target_lines =
{
	FEARSOME = {
		EXTREMEHIGH =  { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_TARGET_EXTREMEHIGH },
		VERYHIGH =     { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_TARGET_VERYHIGH },
		HIGH =         { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_TARGET_HIGH },
		PERFECT =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_TARGET_PERFECT },
		LOW =          { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_TARGET_LOW },
		VERYLOW =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_TARGET_VERYLOW },
		EXTREMELOW =   { duration = 6, strs = STRINGS.YOTB_CONTEST_FEARSOME_TARGET_EXTREMELOW },
	},
	FESTIVE = {
		EXTREMEHIGH =  { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_TARGET_EXTREMEHIGH },
		VERYHIGH =     { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_TARGET_VERYHIGH },
		HIGH =         { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_TARGET_HIGH },
		PERFECT =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_TARGET_PERFECT },
		LOW =          { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_TARGET_LOW },
		VERYLOW =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_TARGET_VERYLOW },
		EXTREMELOW =   { duration = 6, strs = STRINGS.YOTB_CONTEST_FESTIVE_TARGET_EXTREMELOW },
	},
	FORMAL = {
		EXTREMEHIGH =  { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_TARGET_EXTREMEHIGH },
		VERYHIGH =     { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_TARGET_VERYHIGH },
		HIGH =         { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_TARGET_HIGH },
		PERFECT =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_TARGET_PERFECT },
		LOW =          { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_TARGET_LOW },
		VERYLOW =      { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_TARGET_VERYLOW },
		EXTREMELOW =   { duration = 6, strs = STRINGS.YOTB_CONTEST_FORMAL_TARGET_EXTREMELOW },
	},
}

local doll_lines =
{
	FEARSOME = {
		EXTREMEHIGH =  { duration = 6, strs = STRINGS.YOTB_DOLL_FEARSOME_TARGET_EXTREMEHIGH },
		VERYHIGH =     { duration = 6, strs = STRINGS.YOTB_DOLL_FEARSOME_TARGET_VERYHIGH },
		HIGH =         { duration = 6, strs = STRINGS.YOTB_DOLL_FEARSOME_TARGET_HIGH },
		PERFECT =      { duration = 6, strs = STRINGS.YOTB_DOLL_FEARSOME_TARGET_PERFECT },
		LOW =          { duration = 6, strs = STRINGS.YOTB_DOLL_FEARSOME_TARGET_LOW },
		VERYLOW =      { duration = 6, strs = STRINGS.YOTB_DOLL_FEARSOME_TARGET_VERYLOW },
		EXTREMELOW =   { duration = 6, strs = STRINGS.YOTB_DOLL_FEARSOME_TARGET_EXTREMELOW },
	},
	FESTIVE = {
		EXTREMEHIGH =  { duration = 6, strs = STRINGS.YOTB_DOLL_FESTIVE_TARGET_EXTREMEHIGH },
		VERYHIGH =     { duration = 6, strs = STRINGS.YOTB_DOLL_FESTIVE_TARGET_VERYHIGH },
		HIGH =         { duration = 6, strs = STRINGS.YOTB_DOLL_FESTIVE_TARGET_HIGH },
		PERFECT =      { duration = 6, strs = STRINGS.YOTB_DOLL_FESTIVE_TARGET_PERFECT },
		LOW =          { duration = 6, strs = STRINGS.YOTB_DOLL_FESTIVE_TARGET_LOW },
		VERYLOW =      { duration = 6, strs = STRINGS.YOTB_DOLL_FESTIVE_TARGET_VERYLOW },
		EXTREMELOW =   { duration = 6, strs = STRINGS.YOTB_DOLL_FESTIVE_TARGET_EXTREMELOW },
	},
	FORMAL = {
		EXTREMEHIGH =  { duration = 6, strs = STRINGS.YOTB_DOLL_FORMAL_TARGET_EXTREMEHIGH },
		VERYHIGH =     { duration = 6, strs = STRINGS.YOTB_DOLL_FORMAL_TARGET_VERYHIGH },
		HIGH =         { duration = 6, strs = STRINGS.YOTB_DOLL_FORMAL_TARGET_HIGH },
		PERFECT =      { duration = 6, strs = STRINGS.YOTB_DOLL_FORMAL_TARGET_PERFECT },
		LOW =          { duration = 6, strs = STRINGS.YOTB_DOLL_FORMAL_TARGET_LOW },
		VERYLOW =      { duration = 6, strs = STRINGS.YOTB_DOLL_FORMAL_TARGET_VERYLOW },
		EXTREMELOW =   { duration = 6, strs = STRINGS.YOTB_DOLL_FORMAL_TARGET_EXTREMELOW },
	},
}

local categories =
{
	"FEARSOME",
	"FESTIVE",
	"FORMAL",
}

local prizes =
{
	{ 2 },
	{ 3,2 },
	{ 3,2,2 },
	--4
	{
	  4,3,3,3
	},
	--5
	{
      6,5,4,3,3
	},
	--6
	{
	  8,7,6,5,4,3
	},
	--7
	{
	  10,9,8,7,6,5,4
	},
	--8
	{
	  13,11,9,8,7,6,5,5
	},
}

local function selectcomment(list)
	return list[math.random(1,#list)]
end

local YOTB_Stager = Class(function(self, inst)
    self.inst = inst
    self.tasks = {}
    self.choice = "far"
    self.queue = {}

    self.inst:ListenForEvent("yotb_contest_abort", function(inst,data)
    	self:AbortContest(data)
    end)
    self.inst:ListenForEvent("yotb_advance_queue", function(inst,data)
    	self:AdvanceQueue(data)
    end)
    self.inst:ListenForEvent("timerdone", function(inst,data)

    	if data.name == "prizedeadline" then
			self:EndContest("toolate")
    	elseif data.name == "warndeadline" then
    		self.inst.components.talker:Say(STRINGS.YOTB_HURRY_PRIZE, 5.5)
    	end
    end)

end)

function YOTB_Stager:cleartimers()
	if self.inst.components.timer:TimerExists("prizedeadline") then self.inst.components.timer:StopTimer("prizedeadline") end
	if self.inst.components.timer:TimerExists("warndeadline") then self.inst.components.timer:StopTimer("warndeadline") end
end

function YOTB_Stager:AdvanceQueue(data)
	if #self.queue > 0 then
		self.queue[1](self)
		table.remove(self.queue,1)
	end
end

function YOTB_Stager:SpawnVoice(pos,comment,duration)
	self.voice.Transform:SetPosition(pos.x,pos.y,pos.z)
	self.voice.components.talker:Say(comment,duration -0.5)
end

function YOTB_Stager:AbortContest(data)

	TheWorld:PushEvent("yotb_onabortcontest")

	self:cleartimers()

	self.queue = {}

	for i,task in pairs(self.tasks)do
		task:Cancel()
		task = nil
	end

	if self.temp_trainers then
		for i,trainer in ipairs(self.temp_trainers) do
			self.inst:DoTaskInTime(math.random()*0.5, function() self:RemoveTrainer(trainer) end)
		end
	end
	if self.temp_beefalo then
		for i,beef in ipairs(self.temp_beefalo) do
			self.inst:DoTaskInTime(math.random()*0.5, function() self:RemoveBeefalo(beef) end)
		end
	end

	if not self.contest_ending then

		if self.victors then
			for i=#self.victors,1,-1 do
				local victor = self.victors[i]
				if not victor or not victor.userid then
					table.remove(self.victors,i)
				end
			end
		end

		if self.victors and #self.victors > 0 then
			self.inst.components.talker:Say(STRINGS.YOTB_COLLECT_PRIZE_QUICK, 5.5)
		else
			self.contest_ending = true
			self.abort_task = self.inst:DoTaskInTime(0.5,function()
				self:EndContest(data.reason)
			end)
		end
	end
	if self.posts and #self.posts > 0 then
		for i, post in ipairs(self.posts) do
			local beef = post.components.hitcher:GetHitched()
			if beef then
				beef.components.markable_proxy:SetMarkable(false)
				beef.components.markable_proxy.proxy = nil
			end
			post.components.markable:SetMarkable(false)
		end
	end
	self.inst.SoundEmitter:KillSound("gametune")
end

local function generatepart(itemcat)
	local types = {}
	for i,theme in pairs(set_data.costumes) do
		if not theme.not_a_theme then
			table.insert(types,i)
		end
	end

	return itemcat.."_"..string.lower(types[math.random(1,#types)])
end

function YOTB_Stager:RemoveBeefalo(beefalo)
	if beefalo and beefalo:IsValid() then
		if beefalo:HasTag("hitched") then
			beefalo.components.hitchable:Unhitch()
		end
	 	local fx = SpawnPrefab("spawn_fx_medium")
	    fx.Transform:SetPosition(beefalo.Transform:GetWorldPosition())
		beefalo:Remove()
	end
end

function YOTB_Stager:RemoveTrainer(trainer)
	if trainer and trainer:IsValid() then
	 	local fx = SpawnPrefab("spawn_fx_medium")
	    fx.Transform:SetPosition(trainer.Transform:GetWorldPosition())

	    if trainer.yotb_prize_to_collect and not trainer.yotb_prize_to_collect:HasTag("INLIMBO") then
	    	local sfx = SpawnPrefab("spawn_fx_small")
	   	 	sfx.Transform:SetPosition(trainer.yotb_prize_to_collect.Transform:GetWorldPosition())
	    	trainer.yotb_prize_to_collect:Remove()
	    end
		trainer:Remove()
	end
end

local function onattacked(inst, data)
	inst.npc_stage:PushEvent("yotb_contest_abort",{reason="attack"})

	local fx = SpawnPrefab("spawn_fx_medium")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

function YOTB_Stager:RemoveTempTrainer(trainer)
	if self.temp_trainers then
		for i=#self.temp_trainers,1,-1 do
			if trainer == self.temp_trainers then
				table.remove(self.temp_trainers,i)
			end
		end
	end
end

function YOTB_Stager:RemoveTempBeef(beefalo)
	if self.temp_beefalo then
		for i=#self.temp_beefalo,1,-1 do
			if beefalo == self.temp_beefalo then
				table.remove(self.temp_beefalo,i)
			end
		end
	end
end

function YOTB_Stager:MakeRandomBeef(post, name)
	local trainertype = (math.random() < 0.5 and "pigman") or "merm"
	local trainer = SpawnPrefab(trainertype)
	trainer.persists = false

	local pos = Vector3(post.Transform:GetWorldPosition())
	local dir = self.inst:GetAngleToPoint(pos.x,pos.y,pos.z)*DEGREES
	local offset = FindWalkableOffset(pos, dir, 3.5, 8)
	trainer.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)
	trainer.npc_stage = self.inst
	trainer:AddComponent("timer")
	trainer:AddTag("NPC_contestant")
 	local fx = SpawnPrefab("spawn_fx_medium")
    fx.Transform:SetPosition(trainer.Transform:GetWorldPosition())

	trainer:ListenForEvent("onremove", function()
		self:RemoveTempBeef(trainer)
	end)

    trainer:ListenForEvent("attacked", onattacked)
    trainer:ListenForEvent("death",  onattacked)

	if not self.temp_trainers then
		self.temp_trainers = {}
	end
	table.insert(self.temp_trainers,trainer)

    local task = self.inst:DoTaskInTime(0.3, function()

		local beefalo = SpawnPrefab("beefalo")
		beefalo.persists = false
		beefalo.yotb_tempcontestbeefalo = true
		beefalo.Transform:SetPosition(post.Transform:GetWorldPosition())
		beefalo.npc_stage = self.inst

        if beefalo.components.follower ~= nil then
            beefalo.components.follower:SetLeader(trainer)
        end

		post.components.hitcher:SetHitched(beefalo)

		if not beefalo.components.named then
			beefalo:AddComponent("named")
		end
		beefalo.components.named:SetName(name or STRINGS.BEEFALONAMING.BEEFNAMES[math.random(1,#STRINGS.BEEFALONAMING.BEEFNAMES)])

		if not self.temp_beefalo then
			self.temp_beefalo = {}
		end
		table.insert(self.temp_beefalo,beefalo)

		local skins = {
			beef_horn = generatepart("beefalo_horn"),
			beef_body = generatepart("beefalo_body"),
			beef_head = generatepart("beefalo_head"),
			beef_tail = generatepart("beefalo_tail"),
			beef_feet = generatepart("beefalo_feet"),
		}

		beefalo.components.skinner_beefalo:ApplyTargetSkins(skins,self.starter)
		beefalo:ListenForEvent("onremove", function()
			self:RemoveTempBeef(beefalo)
		end)
 		beefalo:ListenForEvent("attacked", onattacked)
 		beefalo:ListenForEvent("death", onattacked)

		local fx = SpawnPrefab("spawn_fx_medium")
		fx.Transform:SetPosition(beefalo.Transform:GetWorldPosition())
	end)
	table.insert(self.tasks,task)
end

function YOTB_Stager:EnableContest()

	local manager = TheWorld.components.yotb_stagemanager
	if manager and (manager:IsContestActive() or not manager:IsContestEnabled()) then
		return
	end

	self.inst:AddTag("yotb_contestenabled")
	self.inst:AddTag("yotb_conteststartable")
	self.inst:AddTag("nomagic")
	self.inst:PushEvent("contestenabled")
	--TODO: disable green staff
end

function YOTB_Stager:DisableContest()
	self.inst:RemoveTag("yotb_contestenabled")
	self.inst:RemoveTag("nomagic")
	self.inst:PushEvent("contestdisabled")
	--TODO: enable green staff
end

local function shuffle_table(t)
	local shuffled = {}
	local count = #t

	for i=1,count do
		table.insert(shuffled, table.remove(t, math.random(1, #t)))
	end

	return shuffled
end

local function angle_table(pt,t)

	table.sort(t,function(a,b)
		return a:GetAngleToPoint(pt.x, pt.y, pt.z) > b:GetAngleToPoint(pt.x, pt.y, pt.z)
	end)
	return t
end

local STAGE_TAGS = { "yotb_post" }
local AREACLEAR_IGNORE_PLAYERS = {"player"}
local AREACLEAR_CHECK_FOR_HOSTILES = {"hostile", "monster"}
local AREACLEAR_COMBAT = {"_combat"}
function YOTB_Stager:TestStartContest(starter)

    local hounded = TheWorld.components.hounded
    if hounded ~= nil and (hounded:GetWarning() or hounded:GetAttacking()) then
        return "unsafe"
    end
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, TUNING.PIG_MINIGAME_ARENA_RADIUS * 2, nil, AREACLEAR_IGNORE_PLAYERS, AREACLEAR_CHECK_FOR_HOSTILES) -- musttags, canttags, mustoneoftags
	if #ents > 0 then
		return "unsafe"
	end

	local ents = TheSim:FindEntities(x, y, z, TUNING.PIG_MINIGAME_ARENA_RADIUS * 2, nil, nil, AREACLEAR_COMBAT) -- musttags, canttags, mustoneoftags
	for _, ent in ipairs(ents) do
		if ent.components.combat:HasTarget() then
			return "unsafe"
		end
	end

	if TheWorld.net ~= nil and TheWorld.net.components.clock ~= nil and TheWorld.net.components.clock:GetTimeUntilPhase("night") <= TUNING.PIG_MINIGAME_REQUIRED_TIME then
		return "notime"
	end

	self.posts = TheSim:FindEntities(x, y, z, TUNING.YOTB_STAGERANGE, STAGE_TAGS)
	if #self.posts <= 3 then
		return "notenoughposts"
	end

	local beefs = 0
	if #self.posts > 0 then
		for i,post in ipairs(self.posts)do
			if post.components.hitcher:GetHitched() then
				beefs = beefs + 1
			end
		end
	end
	if beefs == 0 then
		return "nocontestants"
	end

	return
end

function YOTB_Stager:Start_fail(result)
	if result == "unsafe" then
		self.inst.components.talker:Say(STRINGS.YOTB_START_FAIL_DANGER, 3.5)
	elseif result == "notime" then
		self.inst.components.talker:Say(STRINGS.YOTB_START_FAIL_LATE, 3.5)
	elseif result == "notenoughposts" then
		self.inst.components.talker:Say(STRINGS.YOTB_START_FAIL_NOT_ENOUGH_POSTS, 3.5)
	elseif result == "nocontestants" then
		self.inst.components.talker:Say(STRINGS.YOTB_START_FAIL_NO_CONTESTANTS, 3.5)
	end

	local task = self.inst:DoTaskInTime(4, function()
		--self.inst:resetworkable()
		self.inst:PushEvent("trader_leaves")
	end)

	table.insert(self.tasks,task)
end

function YOTB_Stager:StartContest(starter)

	self.inst.components.workable:SetWorkable(false)

	local result = self:TestStartContest()
	if result then
		self.inst:PushEvent("trader_arrives")
		table.insert(self.queue, function()
			self:Start_fail(result)
		end)
	else
		self.voice = SpawnPrefab("yotb_stage_voice")
		self.voice.proxy = self.inst
		self.voice.Transform:SetPosition(self.inst.Transform:GetWorldPosition())

		-- prime variables again
		if #self.tasks > 0 then
			for i, task in ipairs(self.tasks)do
				task:Cancel()
				task = nil
			end
		end
	    self.tasks = {}
	    self.queue = {}
		self.starter = starter

		self.inst:RemoveTag("yotb_conteststartable")

		self.inst:PushEvent("conteststarted")
		self.inst:PushEvent("trader_arrives")

		self.inst.SoundEmitter:PlaySound("yotb_2021/music/event","eventbg")

		table.insert(self.queue, function()
			self:Start_phase2()
		end)
	end
end

local function onplayerbeefattacked(inst)
	local stage = TheWorld.components.yotb_stagemanager and TheWorld.components.yotb_stagemanager:GetActiveStage()
	if stage then
		stage.components.yotb_stager:AbortContest({reason="attack"})
	end
end

function YOTB_Stager:Start_phase2()

	local x, y, z = self.inst.Transform:GetWorldPosition()
	self.posts = TheSim:FindEntities(x, y, z, TUNING.YOTB_STAGERANGE, STAGE_TAGS)

	for i,post in ipairs(self.posts)do
		post.components.workable:SetWorkable(false)
		local beef = post.components.hitcher:GetHitched()
		if beef then
			self.inst:ListenForEvent("attacked",onplayerbeefattacked,beef)
			self.inst:ListenForEvent("death",onplayerbeefattacked,beef)
		end
	end

	self.posts = angle_table(Vector3(self.inst.Transform:GetWorldPosition()),self.posts)

	self.current_post = 0
	self.target_values = {
		FEARSOME = 0,
		FESTIVE = 0,
		FORMAL = 0,
	}

	for i, cat in ipairs(categories) do
		self.target_values[cat] = math.random(0, 25)
	end
	self.inst:PushEvent("onflourishstart")
	table.insert(self.queue, function()
		self:Start_phase3()
	end)

end

function YOTB_Stager:Start_phase3()
	self.inst.components.talker:Say(STRINGS.YOTB_CONTEST_START,3.5)

	local extrabeef = false
	for i,post in ipairs(self.posts)do
		if not post.components.hitcher:GetHitched() then
			extrabeef = true
			break
		end
	end
	if extrabeef then
		local task = self.inst:DoTaskInTime(4, function()
			self.inst.components.talker:Say(STRINGS.YOTB_EXTRA_BEEF,3.5)

            local beef_name_idxs = shuffleArray(math.range(1, #STRINGS.BEEFALONAMING.BEEFNAMES))

			for i, post in ipairs(self.posts) do
				if not post.components.hitcher:GetHitched() then
					local subtask = self.inst:DoTaskInTime(2+(math.random()*1.5), function()
                        local name_idx = (#beef_name_idxs < i and nil) or beef_name_idxs[i]
						self:MakeRandomBeef(post, STRINGS.BEEFALONAMING.BEEFNAMES[name_idx])
					end)
					table.insert(self.tasks,subtask)
				end
			end
			local task2 = self.inst:DoTaskInTime(4, function() self.inst.components.talker:Say(STRINGS.YOTB_CONTEST_BEGIN,3.5) end)
			local task3 = self.inst:DoTaskInTime(8, function() self:StateParameters() end)

			table.insert(self.tasks,task2)
			table.insert(self.tasks,task3)
		end)
		table.insert(self.tasks,task)
	else

		local task = self.inst:DoTaskInTime(4, function()
			self.inst.components.talker:Say(STRINGS.YOTB_NO_EXTRA_BEEF,3.5)
		end)
		table.insert(self.tasks,task)

		local task2 = self.inst:DoTaskInTime(8, function() self:StateParameters() end)
		table.insert(self.tasks,task2)
	end
	for i,post in ipairs(self.posts)do
		post.components.hitcher:Lock(true)
		post.stage = self.inst
	end
end


function YOTB_Stager:GetParameterLine(category)
	local selected_line = target_lines[category].EXTREMELOW
	for i, v in ipairs(target_thresholds) do
	    if self.target_values[category] > v.threshold then
	    	selected_line = target_lines[category][v.key]
	        break
	    end
	end
	return selected_line.strs
end

function YOTB_Stager:StateParameters()
	self.inst.components.talker:Say(STRINGS.YOTB_CONTEST_TARGET_PARAMS,3.5)

	local task = self.inst:DoTaskInTime(3.5, function()
		self.inst.sg:GoToState("thinking")
		table.insert(self.queue,function()
			self:StateParameters_Phase2()
		end)
	end)
	table.insert(self.tasks,task)
end

function YOTB_Stager:StateParameters_Phase2()
	local time = 0

	self.inst.components.talker:Say(selectcomment(self:GetParameterLine("FORMAL")), 5.5)

	time = time + 6
	local task2 = self.inst:DoTaskInTime(time, function()
		self.inst.components.talker:Say(selectcomment(self:GetParameterLine("FESTIVE")), 5.5)
	end)
	table.insert(self.tasks,task2)

	time = time + 6
	local task3 = self.inst:DoTaskInTime(time, function()
		self.inst.components.talker:Say(selectcomment(self:GetParameterLine("FEARSOME")), 5.5)
	end)
	table.insert(self.tasks,task3)

	time = time + 6
	local task4 = self.inst:DoTaskInTime(time, function() self:BuildSuspense() end)
	table.insert(self.tasks,task4)

	local task5 = self.inst:DoTaskInTime(time-1, function() self.inst.SoundEmitter:KillSound("eventbg") end)
	table.insert(self.tasks,task5)
end

function YOTB_Stager:unhighlitepost(post)
	self.inst.current_contest_target = nil
	if self.light then
	self.light.fadeout(self.light)
	end
end

function YOTB_Stager:highlitepost(post)
	self.inst.current_contest_target = post
	self.light = SpawnPrefab("yotb_post_spotlight")
	self.light.Transform:SetPosition(post.Transform:GetWorldPosition())
end

function YOTB_Stager:CheckForMarks(post,doer)
	for i,post in ipairs(self.posts)do
		for t,marker in ipairs(post.components.markable.marks)do
			if marker.doer == doer then
				return post
			end
		end
	end
	return false
end

function YOTB_Stager:GetBeefScore(beef)
	local clothing = beef.components.skinner_beefalo and beef.components.skinner_beefalo:GetClothing() or {
		beef_body = "",
		beef_horn = "",
		beef_tail = "",
		beef_head = "",
		beef_feet = "",
	}

	local score = {
		FEARSOME = 0,
		FESTIVE = 0,
		FORMAL = 0,
	}

	for i,item in pairs(clothing) do
		local data = set_data.parts[item] or set_data.parts["default"]
		score["FEARSOME"] = score["FEARSOME"] + data["FEARSOME"]
		score["FESTIVE"] = score["FESTIVE"] + data["FESTIVE"]
		score["FORMAL"] = score["FORMAL"] + data["FORMAL"]
	end

	return score
end

function YOTB_Stager:GetClosest(values)
	local close = 9999
	local closecat = {}
	for i,cat in ipairs(categories)do
		local diff = values[cat] - self.target_values[cat]
		if math.abs(diff) < close then
			close = math.abs(diff)
			closecat = {cat}
		elseif math.abs(diff) == close then
			table.insert(closecat,cat)
		end
	end
	local cat = closecat[math.random(1,#closecat)]
	return cat
end

function YOTB_Stager:GetFurthest(values)
	local far = 0
	local farcat = {}
	for i,cat in ipairs(categories)do
		local diff = values[cat] - self.target_values[cat]
		if math.abs(diff) > far then
			far = math.abs(diff)
			farcat = {cat}
		elseif math.abs(diff) == far then
			table.insert(farcat,cat)
		end
	end
	local cat = farcat[math.random(1,#farcat)]
	return cat
end

function YOTB_Stager:GetRandom()
	local cat = categories[math.random(1,#categories)]
	return cat
end

function YOTB_Stager:GetComment(post)

	local beefalo = post.components.hitcher and post.components.hitcher:GetHitched() or nil
	if beefalo then

		-- TODO actually compare it with the values generated
		beefalo.candidate_values = self:GetBeefScore(beefalo)

		local selected_category = categories[1]
		if self.choice == "random" then
			selected_category = self:GetRandom(beefalo.candidate_values)
		elseif self.choice == "far" then
			selected_category = self:GetFurthest(beefalo.candidate_values)
		elseif not self.choice or self.choice == "close" then
			selected_category = self:GetClosest(beefalo.candidate_values)
		end

		local diff = beefalo.candidate_values[selected_category] - self.target_values[selected_category]

		local selected_line = lines[selected_category].EXTREMELOW
		for i, v in pairs(thresholds) do
		    if diff > v.threshold then
		        selected_line = lines[selected_category][v.key]
		        break
		    end
		end

		return selected_line
	end
end

function YOTB_Stager:BuildSuspense()
	if self.current_post and self.current_post > 0 then
		self:unhighlitepost(self.posts[self.current_post])
	end
	for i, post in ipairs(self.posts)do
		local beef = post.components.hitcher:GetHitched()
		if beef then
		--	beef:AddComponent("markable_proxy")
			beef.components.markable_proxy.proxy = post
			beef.components.markable_proxy:SetMarkable(true)
		end
	end

	self.inst.SoundEmitter:PlaySound("yotb_2021/music/contest_tune","gametune")
	if self.temp_trainers and #self.temp_trainers > 0 then
		for i, trainer in ipairs(self.temp_trainers) do
			trainer:DoTaskInTime(0.3+(math.random()*1), function()
				trainer.components.timer:StartTimer("contest_panic",1 + (math.random()*7))
				trainer:ListenForEvent("timerdone", function(inst,data)
					if data.name == "contest_panic" then
						local post = self.posts[math.random(1,#self.posts)]
						trainer.yotb_post_to_mark = post
					end
				end)
			end)
		end
	end

	self.inst.components.talker:Say(STRINGS.YOTB_GUESS_WHO_1, 5.5)

	local task1 = self.inst:DoTaskInTime(6, function()
		self.inst.components.talker:Say(STRINGS.YOTB_GUESS_WHO_2, 5.5)
	end)
	local task2 = self.inst:DoTaskInTime(12, function()
		self.inst.components.talker:Say(STRINGS.YOTB_GUESS_WHO_3, 4.5)
	end)
	local task3 = self.inst:DoTaskInTime(20, function()
		for i, post in ipairs(self.posts) do
			local beef = post.components.hitcher:GetHitched()
			if beef then
				beef.components.markable_proxy:SetMarkable(false)
				beef.components.markable_proxy.proxy = nil
			end
			post.components.markable:SetMarkable(false)
		end
		self.inst.components.talker:Say(STRINGS.YOTB_GUESS_WHO_4, 4.5)
	end)

	local task4 = self.inst:DoTaskInTime(23, function()
		self.inst.SoundEmitter:PlaySound("yotb_2021/music/event","eventbg")
	end)

	local task5 = self.inst:DoTaskInTime(25, function()
		self:DeclareWinner()
	end)
	table.insert(self.tasks,task1)
	table.insert(self.tasks,task2)
	table.insert(self.tasks,task3)
	table.insert(self.tasks,task4)
	table.insert(self.tasks,task5)
end

function YOTB_Stager:SpawnVoiceName(rank,speech)
	self.current_post = rank.post
		self:highlitepost(self.posts[self.current_post])
		local name = self.posts[self.current_post] and
			self.posts[self.current_post].components.hitcher and
			self.posts[self.current_post].components.hitcher:GetHitched() and
			self.posts[self.current_post].components.hitcher:GetHitched().components.named and
			self.posts[self.current_post].components.hitcher:GetHitched().components.named.name
			or speech
	self:SpawnVoice( Vector3(self.posts[self.current_post].Transform:GetWorldPosition()), name, 4)
	return name
end

function YOTB_Stager:DeclareWinner()
	local time = 0
	if self.current_post and self.current_post > 0 then
		self:unhighlitepost(self.posts[self.current_post])
	end

	local scores = {}

	local lowest_score = 9999
	local lowest_index = 0

	for index,v in ipairs(self.posts) do
		local beefalo = v.components.hitcher:GetHitched()

		if beefalo then

			beefalo.candidate_values = self:GetBeefScore(beefalo)
			local score = 0
			for i,cat in ipairs(categories) do
				score = score + math.abs(beefalo.candidate_values[cat] - self.target_values[cat])
			end

			table.insert(scores,{post = index, score=score})

			if score < lowest_score then
				lowest_score = score
				lowest_index = index
			end
		end
	end

	table.sort(scores,function(a,b)
		return a.score < b.score
	end)

	local first = scores[1]
	local second = scores[2]
	local third = scores[3]

	local task1 = self.inst:DoTaskInTime(time, function()
		self.inst.components.talker:Say(STRINGS.YOTB_CONTEST_THIRD_PLACE, 3.5)
	end)
	table.insert(self.tasks,task1)

	time = time + 4
	local task2 = self.inst:DoTaskInTime(time, function()
		self:SpawnVoiceName(third,STRINGS.YOTB_CONGRATS_WINNER_THIRD)
	end)
	table.insert(self.tasks,task2)

		time = time + 4
		local task3 = self.inst:DoTaskInTime(time, function()

			local comment = self:GetComment(self.posts[self.current_post])
			self:SpawnVoice( Vector3(self.posts[self.current_post].Transform:GetWorldPosition()), selectcomment(comment.strs), 6)
		end)
		table.insert(self.tasks,task3)

	time = time + 6
	local task4 = self.inst:DoTaskInTime(time, function()
		self:unhighlitepost(self.posts[self.current_post])
		self.inst.components.talker:Say(STRINGS.YOTB_CONTEST_SECOND_PLACE, 3.5)
	end)
	table.insert(self.tasks,task4)

	time = time + 4
	local task5 = self.inst:DoTaskInTime(time, function()
		self:SpawnVoiceName(second,STRINGS.YOTB_CONGRATS_WINNER_SECOND)
	end)
	table.insert(self.tasks,task5)

	time = time + 4
		local task6 = self.inst:DoTaskInTime(time, function()
			local comment = self:GetComment(self.posts[self.current_post])
			self:SpawnVoice( Vector3(self.posts[self.current_post].Transform:GetWorldPosition()), selectcomment(comment.strs), 6)
		end)
		table.insert(self.tasks,task6)

	time = time + 6
	local task7 = self.inst:DoTaskInTime(time, function()
		self:unhighlitepost(self.posts[self.current_post])
		self.inst.components.talker:Say(STRINGS.YOTB_CONTEST_FIRST_PLACE, 3.5)
	end)
	table.insert(self.tasks,task7)

	local skip_next = false
	time = time + 4
	local task8 = self.inst:DoTaskInTime(time, function()
		local name = self:SpawnVoiceName(first,STRINGS.YOTB_CONGRATS_WINNER)
		if name == STRINGS.YOTB_CONGRATS_WINNER then
			skip_next = true
		end
		local fx = SpawnPrefab("confetti_fx")
		fx.Transform:SetPosition(self.posts[self.current_post].Transform:GetWorldPosition())
	end)
	table.insert(self.tasks,task8)

	if not skip_next then
		time = time + 4
		local task9 = self.inst:DoTaskInTime(time, function()
			self:SpawnVoice( Vector3(self.posts[self.current_post].Transform:GetWorldPosition()), STRINGS.YOTB_CONGRATS_WINNER, 4)
		end)
		table.insert(self.tasks,task9)
	end

	time = time + 4
	local task = self.inst:DoTaskInTime(time, function() self:AwardVictors() end) -- self:WaitForVictor()
	table.insert(self.tasks,task)
end

local function OnRestoreItemPhysics(item)
    item.Physics:CollidesWith(COLLISION.OBSTACLES)
end

local function LaunchGameItem(inst, item, angle, minorspeedvariance, target)
    local x, y, z = inst.Transform:GetWorldPosition()
    local spd = 3.5 + math.random() * (minorspeedvariance and 1 or 3.5)
    item.Physics:ClearCollisionMask()
    item.Physics:CollidesWith(COLLISION.WORLD)
    item.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    item.Physics:Teleport(x, 2.5, z)
    item.Physics:SetVel(math.cos(angle) * spd, 11.5, math.sin(angle) * spd)
    item:DoTaskInTime(.6, OnRestoreItemPhysics)
    item:PushEvent("knockbackdropped", { owner = inst, knocker = inst, delayinteraction = .75, delayplayerinteraction = .5 })
    if item.components.burnable ~= nil then
        inst:ListenForEvent("onignite", function()
            for k, v in pairs(inst._minigame_elites) do
                k:SetCheatFlag()
            end
        end, item)
    end

   	item:ListenForEvent("onland")
end

function YOTB_Stager:Tossprize(target, pattern, other)

	if not pattern then
		local x, y, z = self.inst.Transform:GetWorldPosition()

		local pouch = SpawnPrefab("redpouch_yotb")
	    local prize_items = {}

	    if other then
	    	table.insert(prize_items, SpawnPrefab("lucky_goldnugget"))
	    else
			local race_prize = {}
			local total = prizes[math.min(#self.posts,8)][math.min(self.prizes,8)]
			for i=1,total do
				table.insert(race_prize,"lucky_goldnugget")
			end
		    for _, p in ipairs(race_prize) do
		        table.insert(prize_items, SpawnPrefab(p))
		    end
		end

	    pouch.components.unwrappable:WrapItems(prize_items)
		for i, v in ipairs(prize_items) do
			v:Remove()
		end

	    local angle
		if target ~= nil and target:IsValid() then
			angle = 180 - target:GetAngleToPoint(x, 0, z)
		else
			local down = TheCamera:GetDownVec()
			angle = math.atan2(down.z, down.x) / DEGREES
		end
	    LaunchGameItem(self.inst, pouch, GetRandomWithVariance(angle, 5) * DEGREES, true, target)

	    if target and target:HasTag("NPC_contestant") then
	    	target.yotb_prize_to_collect = pouch
		end
	else
		local pattern = SpawnPrefab("yotb_pattern_fragment_"..math.random(1,3))
		LaunchGameItem(self.inst, pattern, math.random()*2*PI, true)
	end
end

function YOTB_Stager:Tossprizes()

	if self.victors and #self.victors > 0 then
		for i, victor in ipairs(self.victors) do
			if victor:HasTag("NPC_contestant") then
				victor:PushEvent("win_yotb")
			else
				self:Tossprize(victor)
			end
		end
	end
	self.victors = nil

	if self.others and #self.others > 0 then
		for i, other in ipairs(self.others) do
			if other:HasTag("NPC_contestant") then
				other:PushEvent("win_yotb")
			else
				self:Tossprize(other, nil, true)
			end
		end
	end
	self.others = nil

	if self.patterns and self.patterns > 0 then
		for i=1, self.patterns do
			self:Tossprize(nil, true)
		end
	end
	self.patterns = nil
end

function YOTB_Stager:AwardVictors()

	if TheWorld.components.yotb_stagemanager then
		TheWorld.components.yotb_stagemanager:SetContestEnabled(false)
	end

	self:unhighlitepost(self.posts[self.current_post])
	self.victors = {}
	self.notvictors = {}
	local marks = self.posts[self.current_post].components.markable and self.posts[self.current_post].components.markable.marks
	if marks and #marks > 0 then
		for i, mark in ipairs(marks) do
			table.insert(self.victors,mark.doer)
		end
	end

	for i,post in pairs(self.posts)do
		if post ~= self.posts[self.current_post] then
			local marks = post.components.markable and post.components.markable.marks
			for t, mark in ipairs(marks) do
				table.insert(self.notvictors,mark.doer)
			end
		end
	end

	self.prizes = #self.victors

	if not self.victors or #self.victors == 0 then
		self.victors = nil
		self.inst.components.talker:Say(STRINGS.YOTB_NO_PRIZE)
	elseif #self.victors == 1 then
		self.inst:PushEvent("yotb_throwprizes")
		self.inst.components.talker:Say(STRINGS.YOTB_PRIZE)
	else
		self.inst:PushEvent("yotb_throwprizes")
		self.inst.components.talker:Say(STRINGS.YOTB_PRIZES)
	end

	if #self.notvictors > 0 then
		table.insert(self.queue, function()
			local task = self.inst:DoTaskInTime(2,function() self:Give_consoleprizes() end)
			table.insert(self.tasks,task)
		end)
	else
		table.insert(self.queue, function()
			local task = self.inst:DoTaskInTime(2,function() self:Give_Patterns() end)
			table.insert(self.tasks,task)
		end)
	end
end

function YOTB_Stager:Give_consoleprizes()
	self.others = {}
	for i,inst in ipairs(self.notvictors) do
		table.insert(self.others,inst)
	end
	self.notvictors = nil
	self.inst:PushEvent("yotb_throwprizes")
	self.inst.components.talker:Say(STRINGS.YOTB_CONSOLE_PRIZES)

	table.insert(self.queue, function()
		local task = self.inst:DoTaskInTime(2,function() self:Give_Patterns() end)
		table.insert(self.tasks,task)
	end)
end

function YOTB_Stager:Give_Patterns()
	self.inst:PushEvent("yotb_throwprizes")
	self.inst.components.talker:Say(STRINGS.YOTB_PATTERNS,4)
	self.patterns = #self.posts
	local task = self.inst:DoTaskInTime(5, function() self:EndContest() end)
	table.insert(self.tasks,task)
end

function YOTB_Stager:EndContest(reason)

	TheWorld:PushEvent("yotb_oncontestfinshed")

	self:cleartimers()
	self.inst:RemoveTag("has_prize")

	if self.posts and #self.posts > 0 then

		self:unhighlitepost(self.posts[self.current_post])

		for i,post in pairs(self.posts)do

			local beef = post.components.hitcher:GetHitched()
			if beef then
				beef:RemoveEventCallback("attacked",onplayerbeefattacked)
				beef:RemoveEventCallback("death",onplayerbeefattacked)
			end

			post.components.markable:Unmarkall()
			post.components.hitcher:Lock(false)
			post.components.workable:SetWorkable(true)
		end
	end

	self.posts = nil

	self.inst:PushEvent("onflourishend")

	local speech = STRINGS.YOTB_CONTEST_END
	if reason then
		if reason == "attack" then
			speech = STRINGS.YOTB_CONTEST_FIGHT_END
		elseif reason == "toolate" then
			speech = STRINGS.YOTB_TOO_LATE_PRIZE
		end
	end

	self.inst.components.talker:Say(speech,3)

	table.insert(self.queue, function()
		self:EndContest_phase2()
	end)
end

function YOTB_Stager:EndContest_phase2()

	self:DisableContest()

	self.inst:PushEvent("trader_leaves")
	self.inst.components.workable:SetWorkable(true)

	self.inst.SoundEmitter:KillSound("eventbg")

	if self.temp_beefalo and #self.temp_beefalo > 0 then
		for i=#self.temp_beefalo,1,-1 do
			local ent = self.temp_beefalo[i]
			if ent then
				ent:DoTaskInTime(math.random()*0.5,function() self:RemoveBeefalo(ent) end)
			end
		end
	end

	self.temp_beefalo = nil

	if self.temp_trainers and #self.temp_trainers > 0 then
		for i=#self.temp_trainers,1,-1 do
			local ent = self.temp_trainers[i]
			if ent then
				ent:DoTaskInTime(math.random()*0.5,function() self:RemoveTrainer(ent) end)
			end
		end
	end

	self.temp_trainers = nil

	self.contest_ending = nil

	self.voice:Remove()

	self.inst:DoTaskInTime(2,function()
		if TheWorld.components.yotb_stagemanager and TheWorld.components.yotb_stagemanager:IsContestEnabled() then
			self:EnableContest()
		end
	end)
end
-------------------------------
-- APPRAISE

function YOTB_Stager:appraisedoll(doll)

	self.doll_values =  {
		FEARSOME = set_data.categories[doll.category].FEARSOME * 5,
		FESTIVE = set_data.categories[doll.category].FESTIVE * 5,
		FORMAL = set_data.categories[doll.category].FORMAL * 5,
	}


	self.inst.components.workable:SetWorkable(false)

	self.voice = SpawnPrefab("yotb_stage_voice")
	self.voice.proxy = self.inst
	self.voice.Transform:SetPosition(self.inst.Transform:GetWorldPosition())

	-- prime variables again
	if #self.tasks > 0 then
		for i, task in ipairs(self.tasks)do
			task:Cancel()
			task = nil
		end
	end
    self.tasks = {}
    self.queue = {}

	self.inst:RemoveTag("yotb_conteststartable")

	self.inst:PushEvent("trader_arrives")

	table.insert(self.queue, function()
		self:appraisedoll2()
	end)
end

function YOTB_Stager:appraisedoll2()

	self.inst.components.talker:Say(STRINGS.YOTB_APPRAISE_START,3.5)

	local task = self.inst:DoTaskInTime(3.5, function()
		self.inst.sg:GoToState("thinking")
		table.insert(self.queue,function()
			self:appraisedoll3()
		end)
	end)
	table.insert(self.tasks,task)
end


function YOTB_Stager:GetParameterLineDoll(category)
	local selected_line = doll_lines[category].EXTREMELOW
	for i, v in ipairs(target_thresholds) do
	    if self.doll_values[category] > v.threshold then
	    	selected_line = doll_lines[category][v.key]
	        break
	    end
	end
	return selected_line.strs
end

function YOTB_Stager:appraisedoll3()

	local time = 0

	self.inst.components.talker:Say(selectcomment(self:GetParameterLineDoll("FORMAL")), 5.5)

	time = time + 6
	local task2 = self.inst:DoTaskInTime(time, function()
		self.inst.components.talker:Say(selectcomment(self:GetParameterLineDoll("FESTIVE")), 5.5)
	end)
	table.insert(self.tasks,task2)

	time = time + 6
	local task3 = self.inst:DoTaskInTime(time, function()
		self.inst.components.talker:Say(selectcomment(self:GetParameterLineDoll("FEARSOME")), 5.5)
	end)
	table.insert(self.tasks,task3)

	time = time + 6
	local task4 = self.inst:DoTaskInTime(time, function()
		self.inst.components.talker:Say(STRINGS.YOTB_APPRAISE_END, 3.5)
	end)
	table.insert(self.tasks,task4)

	time = time + 4
	local task5 = self.inst:DoTaskInTime(time, function() self:Endppraisedoll() end)
	table.insert(self.tasks,task5)
end

function YOTB_Stager:Endppraisedoll()
	self.doll_values = nil
	self.inst:PushEvent("trader_leaves")
	self.inst.components.workable:SetWorkable(true)
	self.inst:AddTag("yotb_conteststartable")
	self.voice:Remove()
end
-------------------------------


function YOTB_Stager:LoadPostPass(ents, data)
    self:cleartimers()
end

return YOTB_Stager