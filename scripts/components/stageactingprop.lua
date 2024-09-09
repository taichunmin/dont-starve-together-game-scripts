
local MONOLOGUE = { "MONOLOGUE" }

local GENERALSCRIPTS = require("play_generalscripts")
local play_commonfns = require("play_commonfn")

local StageActingProp = Class(function(self, inst)
    self.inst = inst
	self.inst:AddTag("stageactingprop")

	self.cast = nil
	self.script = nil
	self.performance_problem = nil

	self.costumes = {}

	self.current_act = nil

    self.generalscripts = {}
    self.scripts = {}

    for script_name, script_data in pairs(GENERALSCRIPTS) do
        self:AddGeneralScript(script_name, script_data)
    end

    self._do_lines = function()
        self:DoLines()
    end
end)

function StageActingProp:AddGeneralScript(script_name, script_content)
	assert(not self.generalscripts[script_name] and not self.scripts[script_name], "act Title Already Exists")

	self.generalscripts[script_name] = script_content
	self.scripts[script_name] = script_content
end

function StageActingProp:AddPlay(playdata)
    self.costumes = {}
    for costume,cont in pairs(playdata.costumes)do
        self.costumes[costume] = cont
    end

    self.scripts = {}
    for act,cont in pairs(self.generalscripts)do
        self.scripts[act] = cont
    end

    for act,cont in pairs(playdata.scripts)do
        self.scripts[act] = cont
    end

    self.current_act = playdata.current_act
end

function StageActingProp:EnableProp()
	self.inst:AddTag("stageactingprop")
	if self.enablefn then
		self.enablefn(self.inst)
	end
end

function StageActingProp:DisableProp(time)
	if self.dissablefn then
		self.dissablefn(self.inst)
	end
	self.inst:RemoveTag("stageactingprop")
	if time then
		self.time = time
		self.inst:StartUpdatingComponent(self)
	end
end

function StageActingProp:SetEnabledFn(fn)
	self.enablefn = fn
end

function StageActingProp:SetDisabledFn(fn)
	self.dissablefn = fn
end

function StageActingProp:FindCostume(head,body)
	local partial_match = false
	for costume,data in pairs(self.costumes) do
		if data.head == head and data.body == body then
			return costume
		end

		if data.head == head or data.body == body  then
			partial_match = true
		end
	end
	if partial_match then
		self.performance_problem = "BAD_COSTUMES"
	end
end

function StageActingProp:CheckCostume(player)
	local head = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	local body = player.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

	return self:FindCostume(head and head.prefab,body and body.prefab)
end

local ACTOR_MUST = {"stageactor"}
local ACTOR_CANT = {"fire", "burnt"}
function StageActingProp:CollectCast(doer)
	local x,y,z = self.inst.Transform:GetWorldPosition()
	local actors = TheSim:FindEntities(x,y,z, 5.5, ACTOR_MUST, ACTOR_CANT)
	self.cast = {}

	local doercostume = self:CheckCostume(doer)
	if doercostume == nil then
		self.cast[doer.prefab] = {castmember=doer}
		return
	end

	for i=#actors,1,-1 do
		local costume = self:CheckCostume(actors[i])

		if costume then
			if self.cast[costume] then
				self.cast[costume..actors[i].GUID] = {castmember=actors[i]}
				self.performance_problem = "REPEAT_COSTUMES"
			else
				self.cast[costume] = {castmember = actors[i]}
			end
		end
	end
end

function StageActingProp:FindScript(doer)
	local potentialscripts = {}
	local topcastsize = 0

	if self.performance_problem then
		return self.performance_problem
	end

	for script,scriptdata in pairs(self.scripts) do
		if not scriptdata.playbill or (scriptdata.playbill and script == self.current_act) then
			local rolesleft = #scriptdata.cast
			for _, role in pairs(scriptdata.cast) do
				local current_roles =  rolesleft
				for costume,data in pairs(self.cast) do
					if costume == role or (not self.costumes[costume] and role == "MONOLOGUE") then
						rolesleft = rolesleft - 1
						break
					end
				end
			end

			if rolesleft == 0 then
				if topcastsize < #scriptdata.cast then
					potentialscripts = {}
					topcastsize = #scriptdata.cast
					table.insert(potentialscripts, script)
				elseif topcastsize == #scriptdata.cast then
					table.insert(potentialscripts, script)
				end
			end
		end
	end

	if #potentialscripts > 0 then
		local choice = math.random(1, #potentialscripts)

		if self.scripts[potentialscripts[choice]].cast == MONOLOGUE then
			self.cast = {}
			self.cast["MONOLOGUE"] = {castmember=doer}
		end

		return potentialscripts[choice]
	else
		self.performance_problem = "NO_SCRIPT"
		return "NO_SCRIPT"
	end
end

function abortplay(ent)
    local stage = ent.components.stageactor:GetStage()
    if stage ~= nil and not ent.sg:HasStateTag("acting") then
        local cast = stage.components.stageactingprop.cast
        local pos = nil
        if cast and next(cast) then
	        for costume, data in pairs(cast) do
	            if data.castmember == ent then
	                pos = data.target
	                break
	            end
	        end
    	end

        local test_destination = (ent.components.locomotor ~= nil
                            and ent.components.locomotor.dest ~= nil
                            and ent.components.locomotor.dest.pt)
                        or ent:GetPosition()
        local matched_location = pos ~= nil and pos:DistSq(test_destination) < 0.01

        if not ent.sg:HasStateTag("running") or not matched_location then
            stage.components.stageactingprop:ClearPerformance(ent)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
-- END PERFORMANCE
------------------------------------------------------------------------------------------------------------------------
local function do_endofperformance_talk(castmember)
    if castmember:HasTag("player") then
        castmember.components.talker:Say(GetString(castmember, "ANNOUNCE_OFF_SCRIPT"))
    else
        castmember.components.talker:Say(STRINGS.HECKLERS_OFF_SCRIPT[math.random(1, #STRINGS.HECKLERS_OFF_SCRIPT)])
    end
end

local function remove_progress_tags(inst)
    inst:RemoveTag("play_in_progress")
    inst:RemoveTag("NOCLICK")
end

function StageActingProp:EndPerformance(doer)
    if self.onperformanceended ~= nil then
        self.onperformanceended(self.inst, doer, self.script, self.cast)
    end

    if self.inst.sg:HasStateTag("on") then
        self.inst.sg:GoToState("narrator_off")
    end

	for role, data in pairs(self.cast) do
		data.castmember:RemoveTag("acting")
		data.castmember.AnimState:ClearSymbolBloom("swap_hat")

        if data.castmember.components.stageactor then
            data.castmember.components.stageactor:SetStage(nil)
            self.inst:RemoveEventCallback("newstate", abortplay, data.castmember)
			data.castmember:PushEvent("stopstageacting")

			if doer ~= nil and data.castmember ~= doer and data.castmember.components.talker ~= nil then
				data.castmember:DoTaskInTime(math.random() * 0.3, do_endofperformance_talk)
			end
        end
	end

	play_commonfns.exitbirds(self.inst, nil, self.cast)

	self.cast = nil
	self.script = nil
	self.performance_problem = nil

	self.inst:DoTaskInTime(2, remove_progress_tags)
end
------------------------------------------------------------------------------------------------------------------------

function StageActingProp:ClearPerformance(doer)
	self:EndPerformance(doer)

	if self.playtask then
		scheduler:KillTask(self.playtask)
        self.playtask = nil
	end
end

function StageActingProp:DoPerformance(doer)
    -- In case multiple actions are buffered before a play has started.
    if self.inst:HasTag("play_in_progress") then
        return false
    end

    self:CollectCast(doer)

    self.script = self:FindScript(doer)

    if self.script then
        self.playtask = self.inst:StartThread(self._do_lines)
        for role, data in pairs(self.cast) do
            data.castmember:AddTag("acting")
            data.castmember.components.stageactor:SetStage(self.inst)
			data.castmember:PushEvent("startstageacting")
            if data.castmember.sg ~= nil then
                self.inst:ListenForEvent("newstate", abortplay, data.castmember)
            end
        end

        self.inst:PushEvent("play_begun")
        if self.onperformancebegun ~= nil then
            self.onperformancebegun(self.inst, self.script, self.cast)
        end

        self.inst:AddTag("play_in_progress")
        self.inst:AddTag("NOCLICK")
        return true
    else
        self:ClearPerformance()
    end
end

local function should_skip_line(self, line)
    -- Look for a lucy if it's required
    if line.lucytest and self.cast[line.lucytest] then
        local lucy_owner = self.cast[line.lucytest].castmember
        if lucy_owner == nil or lucy_owner.components.inventory == nil then
            return true
        end
		local lucy = play_commonfns.findlucy(lucy_owner)
        if not lucy then
            return true
        end
    end

    -- Look for a tree costume if it's required
    if line.treetest and not self.cast["TREE"] then
        return true
    end
end

function StageActingProp:DoLines()
    local script_data = self.scripts[self.script]
	for _, line in ipairs(script_data.lines) do
		local skip = should_skip_line(self, line)

		if not skip and self.cast then
			local duration = line.duration 
			if line.actionfn then
				line.actionfn(self.inst, line, self.cast)
			end

			if line.roles then
				for __, speaker in ipairs(line.roles) do
					local actor = (self.cast[speaker] and self.cast[speaker].castmember)
                        or (self.cast["MONOLOGUE"] and self.cast["MONOLOGUE"].castmember)

					if line.anim or line.line then
                        local next_line_data = { anim = line.anim, line = line.line, animtype = line.animtype }
						actor:PushEvent("perform_do_next_line", next_line_data)

                        if line.line then
                            local line_text = ProcessString(actor) or line.line
                            actor.components.talker:Say(line_text, duration, nil, nil, nil, nil, nil, nil, nil, line.sgparam)
                        end

						if line.castsound and actor.SoundEmitter then
							for sound_role, sound_name in pairs(line.castsound) do
								if sound_role == speaker then
									actor.SoundEmitter:PlaySound(sound_name)
								end
							end
						end
					end
				end
			end

            if not line.nopause then
                Sleep(duration)
            end
        end
    end

    self.inst:PushEvent("play_performed", { next = script_data.next, error = self.performance_problem })

    if script_data.next then
        self:FinishAct(script_data.next)
    end

    self:EndPerformance()
end

function StageActingProp:FinishAct(next_act)
	local lecturn  = self.inst.components.entitytracker:GetEntity("lecturn")
	if lecturn then
		lecturn.components.playbill_lecturn:ChangeAct(next_act)
    end
    self.current_act = next_act
end

function StageActingProp:SpawnBirds(arch)
    self.arch = arch or self.inst

	local x,y,z = self.arch.Transform:GetWorldPosition()

	self.bird1 = SpawnPrefab("charlie_heckler")
	self.bird1.Follower:FollowSymbol(self.arch.GUID, "bird2", 0, 0, 0, true)
	self.bird1:ForceFacePoint(x,y,z)
    self.bird1.sound_set = "a"

	self.bird2 = SpawnPrefab("charlie_heckler")
	self.bird2.Follower:FollowSymbol(self.arch.GUID, "bird1", 0, 0, 0, true)
	self.bird2:ForceFacePoint(x,y,z)
    self.bird2.sound_set = "b"
end

function StageActingProp:OnUpdate(dt)
	if self.time then
		self.time = self.time - dt
		if self.time <= 0 then
			self.time = nil
			self.inst:StopUpdatingComponent(self)
			self:EnableProp()
		end
	end
end

function StageActingProp:LongUpdate(dt)
    self:OnUpdate(dt)
end

function StageActingProp:OnSave()
	local data = {
		time = self.time,
	}
	return data
end

function StageActingProp:LoadPostPass(newents,data)
	if data then
		if data.time then
			self:DisableProp(data.time)
		end
    end
end

function StageActingProp:OnRemoveFromEntity()
    self.inst:RemoveTag("stageactingprop")
end

return StageActingProp
