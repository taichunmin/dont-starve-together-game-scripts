
-- Handles the player changing prefabs without going through the character select



local SeamlessPlayerSwapper = Class(function(self, inst)
    self.inst = inst

	self.swap_data = {}
	self.main_data = {}
end)

function SeamlessPlayerSwapper:_StartSwap(new_prefab) 
    local clothing = self.inst.components.skinner:GetClothing()

	local skin_base
    if new_prefab == nil then -- swapping back to the main character
        skin_base = self.main_data.skin_base
		new_prefab = self.main_data.prefab or "wilson"
		-- Clear used stored fields.
		for k in pairs(self.main_data) do
			self.main_data[k] = nil
		end

		self.swap_data[self.inst.prefab] = {skin_base = clothing.base}
    else
        skin_base = self.swap_data[new_prefab] and self.swap_data[new_prefab].skin_base or nil
		-- Clear used stored fields.
		self.swap_data[new_prefab] = nil

		self.main_data.skin_base = clothing.base
		self.main_data.prefab = self.inst.prefab
    end

    TheNet:SpawnSeamlessPlayerReplacement(self.inst.userid, new_prefab, skin_base, clothing.body, clothing.hand, clothing.legs, clothing.feet)
end

function SeamlessPlayerSwapper:DoMonkeyChange() 
	self:_StartSwap("wonkey")
end

function SeamlessPlayerSwapper:SwapBackToMainCharacter()
	self:_StartSwap()
end

-- Note: This runs on the newly created player
function SeamlessPlayerSwapper:OnSeamlessCharacterSwap(old_player)

    local ents = old_player.components.inventory:FindItems(function(item) return item:HasTag("cursed") end)
    for i,ent in ipairs(ents)do
        ent:RemoveTag("applied_curse")
        ent.components.curseditem.cursed_target = nil
    end

	local new_player = self.inst

	old_player:PushEvent("ms_playerreroll") -- remove stuff the old character might have had in the world.
	local old_data = old_player:SaveForReroll()
	--V2C: Overwrite with full OnSave() data instead of SaveForReroll() data.
	old_data.seamlessplayerswapper = old_player.components.seamlessplayerswapper ~= nil and old_player.components.seamlessplayerswapper:OnSave() or nil
	new_player:LoadForReroll(old_data) -- apply the saved stuff from the old player
	old_player:SwapAllCharacteristics(new_player)

	--disable the old player entity
	old_player.Physics:SetActive(false)
	old_player:Hide()
	old_player.DynamicShadow:Enable(false)
	old_player.MiniMapEntity:SetEnabled(false)
	old_player.Network:SetClassifiedTarget(new_player)

	--V2C: this flag is for FORCING mime tag.
	--     only flag if old player is a mime (but NOT FORCED).
	--     only flag if I'm not already a mime.
	self.main_data.mime =
		old_player:HasTag("mime") and
		not (old_player.components.seamlessplayerswapper ~= nil and old_player.components.seamlessplayerswapper.main_data.mime) and
		not self.inst:HasTag("mime") or
		nil

	self:PostTransformSetup()
	new_player:PushEvent("ms_playerseamlessswaped") -- Add post fixup stuff special character traits normally would get for OnNewSpawn but without items.

	if new_player.components.health:IsDead() then
		new_player.sg:GoToState("seamlessplayerswap_death")
	elseif PLAYER_SWAP_TRANSITIONS[new_player.prefab] then
		new_player.sg:GoToState(PLAYER_SWAP_TRANSITIONS[new_player.prefab].transfrom_state)
	elseif PLAYER_SWAP_TRANSITIONS[old_player.prefab] then
		new_player.sg:GoToState(PLAYER_SWAP_TRANSITIONS[old_player.prefab].restore_state)
	else
		new_player.sg:GoToState("idle")
	end
end

function SeamlessPlayerSwapper:PostTransformSetup()
	if self.main_data.mime then
	    self.inst:AddTag("mime")
	end
	self.inst.components.talker.speechproxy = self.main_data.prefab
end

function SeamlessPlayerSwapper:SaveForReroll()
	if next(self.main_data) ~= nil then
		local clothing = self.inst.components.skinner:GetClothing()
		local swap_data = deepcopy(self.swap_data)
		swap_data[self.inst.prefab] = { skin_base = clothing.base }
		return { swap_data = swap_data }
	end
	return next(self.swap_data) ~= nil and { swap_data = self.swap_data } or nil
end

function SeamlessPlayerSwapper:OnSave()
    local data =
    {
		swap_data = next(self.swap_data) ~= nil and self.swap_data or nil,
		main_data = next(self.main_data) ~= nil and self.main_data or nil,
    }
	return next(data) ~= nil and data or nil
end

function SeamlessPlayerSwapper:OnLoad(data)
	if data ~= nil then
        self.swap_data = data.swap_data or {}
        self.main_data = data.main_data or {}
	end

	if next(self.main_data) ~= nil and self.inst.prefab ~= self.main_data.prefab then
		self:PostTransformSetup()
	end
end

return SeamlessPlayerSwapper