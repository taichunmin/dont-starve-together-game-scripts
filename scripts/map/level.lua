local tasks = require("map/tasks")
local tasksets = require("map/tasksets")

Level = Class( function(self, data)
	assert( data.id ~= nil, "level must specify an id." )
	self:SetID(data.id)
	self:SetBaseID(data.baseid)
	self:SetNameAndDesc(data.name, data.desc)
	self.override_level_string = data.override_level_string or false
    assert(data.location ~= nil, "Levels must specify a location, no more default.")
    self.location = data.location
    self.hideinfrontend = data.hideinfrontend
	self.overrides = data.overrides or {}
	self.substitutes = data.substitutes or {}
	self.override_triggers = data.override_triggers --UNUSED
    assert(data.set_pieces == nil, "level 'set_pieces' should be specified as an override via 'task_set' now.")
	self.set_pieces = nil
    assert(data.numoptionaltasks == nil, "level 'numoptionaltasks' should be specified as an override via 'task_set' now.")
	self.numoptionaltasks = nil
    assert(data.optionaltasks == nil, "level 'optionaltasks' should be specified as an override via 'task_set' now.")
	self.optionaltasks = nil
    assert(data.valid_start_tasks == nil, "level 'valid_start_tasks' should be specified as an override via 'task_set' now.")
    self.valid_start_tasks = nil
	self.hideminimap = data.hideminimap or false
	self.min_playlist_position = data.min_playlist_position or 0  --UNUSED
	self.max_playlist_position = data.max_playlist_position or 999  --UNUSED
	self.ordered_story_setpieces = data.ordered_story_setpieces -- Deprecated
	self.required_prefabs = data.required_prefabs
	self.background_node_range = data.background_node_range
	self.blocker_blank_room_name = data.blocker_blank_room_name

	self.required_setpieces = data.required_setpieces
	self.numrandom_set_pieces = data.numrandom_set_pieces or 0
	self.random_set_pieces = data.random_set_pieces or nil

	self.playstyle = data.playstyle

    self.chosen_tasks = nil

    self.version = data.version or 1
end)

function Level:ApplyModsToTasks(tasklist)

	for i,task in ipairs(tasklist) do
		--print(i, "modding task "..task.id)
		local modfns = ModManager:GetPostInitFns("TaskPreInit", task.id)
		for i,modfn in ipairs(modfns) do
			print("Applying mod to task '"..task.id.."'")
			modfn(task)
		end
	end
end

function Level:GetOverridesForTasks(tasklist)
	-- Update the task with whatever overrrides are going
	local resources = require("map/resource_substitution")

	-- WE MAKE ONE SELECTION FOR ALL TASKS or ONE PER TASK
	for name, override in pairs(self.substitutes) do

		local substitute = resources.GetSubstitute(name)

		if name ~= substitute then
			print("Substituting [".. substitute.."] for [".. name.."]")
			for task_idx,val in ipairs(tasklist) do
				local chance = 	math.random()
				if chance < override.perstory then
					if tasklist[task_idx].substitutes == nil then
						tasklist[task_idx].substitutes = {}
					end
					--print(task_idx, "Overriding", name, "with", substitute, "for:", self.name, chance, override.perstory )
					tasklist[task_idx].substitutes[name] = {name = substitute, percent = override.pertask}
				-- else
				-- 	print("NOT overriding ", name, "with", substitute, "for:", self.name, chance, override.perstory)

				end
			end
		end
	end

	return tasklist
end

function Level:GetTasksForLevel()
    return self.chosen_tasks
end

function Level:ChooseTasks()
	--print("Getting tasks for level:", self.name)
	local tasklist = {}
    assert(self.overrides["task_set"] ~= nil, "Must specify the task set for a level!")
    local task_set = self.overrides["task_set"]
	local task_set_data = tasksets.GetGenTasks(task_set)
	local modfns = ModManager:GetPostInitFns("TaskSetPreInit", task_set)
	for i,modfn in ipairs(modfns) do
		print("Applying mod to task set '"..task_set.."'")
		modfn(task_set_data)
	end
	modfns = ModManager:GetPostInitFns("TaskSetPreInitAny")
	for i,modfn in ipairs(modfns) do
		print("Applying mod to current task set")
		modfn(task_set_data)
	end

    assert(task_set_data ~= nil, ("TaskSet '" .. tostring(task_set) .. "' has no data! If preset '".. tostring(self.id) .. "' was created with mods enabled, please enable the mods."))

	for k, v in pairs(task_set_data) do
		self[k] = v
	end

	local modfns = ModManager:GetPostInitFns("LevelPreInit", self.id)
	for i,modfn in ipairs(modfns) do
		print("Applying mod to level '"..self.id.."'")
		modfn(self)
	end
	modfns = ModManager:GetPostInitFns("LevelPreInitAny")
	for i,modfn in ipairs(modfns) do
		print("Applying mod to current level")
		modfn(self)
	end

	for i=1,#self.tasks do
		self:EnqueueATask(tasklist, self.tasks[i])
	end

	self:ApplyModsToTasks(tasklist)

	if self.numoptionaltasks and self.numoptionaltasks > 0 and self.optionaltasks then
		local shuffletasknames = shuffleArray(self.optionaltasks)
		local numtoadd = self.numoptionaltasks
		local i = 1
		while numtoadd > 0 and i <= #self.optionaltasks do
			if type(self.optionaltasks[i]) == "table" then
				for i,taskname in ipairs(self.optionaltasks[i]) do
					self:EnqueueATask(tasklist, taskname)
					numtoadd = numtoadd - 1
				end
			else
				self:EnqueueATask(tasklist, self.optionaltasks[i])
				numtoadd = numtoadd - 1
			end
			i = i + 1
		end
	end

	self:GetOverridesForTasks(tasklist)

	self.chosen_tasks = tasklist
end

function Level:GetTasksForLevelSetPieces()
	local tasks = {}
	for _, v in ipairs(self.chosen_tasks) do
		if not v.level_set_piece_blocker then
			table.insert(tasks, v)
		end
	end
	return tasks
end

function Level:ChooseSetPieces()
    assert(self.chosen_tasks ~= nil, "Must call ChooseTasks before ChooseSetPieces")

	local tasks = self:GetTasksForLevelSetPieces()
	if #tasks > 0 then
		local set_pieces = {}
		if self.required_setpieces ~= nil then
			set_pieces = deepcopy(self.required_setpieces)
			for i = 1, self.numrandom_set_pieces do
				--Get random set piece to put in task
				table.insert(set_pieces, self.random_set_pieces[math.random(#self.random_set_pieces)])
			end
		end

		for _, set_piece in ipairs(set_pieces) do
			--Get random task
			local idx = math.random(#tasks)

			if tasks[idx].random_set_pieces == nil then
				tasks[idx].random_set_pieces = {}
			end
			print(set_piece .. " added to task " .. tasks[idx].id)
			table.insert(tasks[idx].random_set_pieces, set_piece)
		end
	end
	for name, choicedata in pairs(self.set_pieces or {}) do
        --print("Adding",name, choicedata.count)
		local found = false
		local idx = {}
		for i, task in ipairs(self.chosen_tasks) do
			idx[task.id] = i
		end
        local availabletasks = table.invert(idx)

		-- Pick one of the choices and add it to that task
		local choices = ArrayIntersection(choicedata.tasks, availabletasks)
		local count = choicedata.count or 1

		assert(choices and #choices > 0, "Trying to add set piece '"..name.."' but no choices given.")

		-- Only one layout per task, so we stop when we run out of tasks or
		while count > 0 and #choices > 0 do
            local idx_choice = math.random(#choices)
            local choice = idx[choices[idx_choice]]
            if self.chosen_tasks[choice].set_pieces == nil then
                self.chosen_tasks[choice].set_pieces = {}
            end
            --print("\tinserted in",self.chosen_tasks[choice])
            table.insert(self.chosen_tasks[choice].set_pieces, {name=name, restrict_to=choicedata.restrict_to})

            idx[choices[idx_choice]] = nil
            table.remove(choices, idx_choice)
            count = count-1
		end
	end
end

function Level:EnqueueATask(tasklist, taskname)
	local task = tasks.GetTaskByName(taskname)
	if task then
		--print("\tChoosing task:",task.id)
		table.insert(tasklist, deepcopy(task))
	else
		assert(task, "Could not find a task called "..taskname)
	end
end

function Level:SetID(id)
	assert(id ~= nil, "level must specify an id." )
	self.id = id
	self.worldgen_id = id
end

function Level:SetBaseID(id)
	self.baseid = id
	self.worldgen_baseid = id
end

function Level:SetNameAndDesc(name, desc)
	self.name = name or ""
	self.desc = desc or ""
	self.worldgen_name = self.name
	self.worldgen_desc = self.desc
end