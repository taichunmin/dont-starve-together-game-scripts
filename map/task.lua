Task = Class(function(self, id, data)
	-- print("Task ",id)
	-- dumptable(data,1)
	self.id = id

	-- what locks this task
	self.locks = data.locks
	if type(self.locks) ~= "table" then
		self.locks = { self.locks }
	end
	-- the key that this task provides
	self.keys_given = data.keys_given
	if type(self.keys_given) ~= "table" then
		self.keys_given = { self.keys_given }
	end
	self.region_id = data.region_id

	self.entrance_room = data.entrance_room
	self.entrance_room_chance = data.entrance_room_chance
	self.room_choices = data.room_choices
	self.room_choices_special = data.room_choices_special
	self.room_bg = data.room_bg
	self.background_room = data.background_room
	self.cove_room_name = data.cove_room_name
	self.cove_room_chance = data.cove_room_chance
	self.cove_room_max_edges = data.cove_room_max_edges
	self.colour = data.colour
	self.maze_tiles = data.maze_tiles
	self.maze_tile_size = data.maze_tile_size
	self.crosslink_factor = data.crosslink_factor
	self.make_loop = data.make_loop
    self.room_tags = data.room_tags
    self.required_prefabs = data.required_prefabs
    self.hub_room = data.hub_room
	self.level_set_piece_blocker = data.level_set_piece_blocker -- prevents the task from getting any of the random_set_pieces and required_setpieces defined in the level
end)

function Task:__tostring()
    return "Task: "..self.id
end


