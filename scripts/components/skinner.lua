local Skinner = Class(function(self, inst)
	self.inst = inst
	self.skin_name = ""
	self.clothing = { body = "", hand = "", legs = "", feet = "" }

	self.skintype = "normal_skin"
end)

local clothing_order = { "legs", "body", "feet", "hand" }

function SetSkinsOnAnim( anim_state, prefab, base_skin, clothing_names, monkey_curse, skintype, default_build )
	skintype = skintype or "normal_skin"
	default_build = default_build or ""
	base_skin = base_skin or ""

	local monkey_pieces = {}
	if monkey_curse ~= nil then
		if monkey_curse == "MONKEY_CURSE_1" then
			monkey_pieces = {
				"foot"
			}
		elseif monkey_curse == "MONKEY_CURSE_2" then
			monkey_pieces = {
				"foot",
				"hand"
			}
		elseif monkey_curse == "MONKEY_CURSE_3" then
			monkey_pieces = {
				"foot",
				"hand",
				"tail"
			}
		end
	end
	if prefab == "wonkey" then
		monkey_pieces = {
			"foot",
			"hand",
			"tail"
		}
	end

	if skintype ~= "NO_BASE" then
		anim_state:SetSkin(base_skin, default_build)
	end
	for sym,_ in pairs(CLOTHING_SYMBOLS) do
		anim_state:ClearOverrideSymbol(sym)
	end

	anim_state:ClearSymbolExchanges()
	for sym,_ in pairs(HIDE_SYMBOLS) do
		anim_state:ShowSymbol(sym)
	end

	--if not ghost, then we need to apply the clothing
	if table.contains(SKIN_TYPES_THAT_RECEIVE_CLOTHING, skintype) then
		local needs_legacy_fixup = not anim_state:BuildHasSymbol( "torso_pelvis" ) --support clothing on legacy mod characters
		local torso_build = nil
		local pelvis_build = nil
		local skirt_build = nil
		local leg_build = nil --for boot switching and nubs
		local foot_build = nil --for boot switching

		local tuck_torso = BASE_TORSO_TUCK[base_skin] or "skirt" --tucked into the skirt is the default
		--print( "tuck_torso is ", tuck_torso, base_skin )

		local legs_cuff_size = BASE_LEGS_SIZE[base_skin] or 1
		local feet_cuff_size = BASE_FEET_SIZE[base_skin] or 1
		--print( "legs_cuff_size and feet_cuff_size is ", legs_cuff_size, feet_cuff_size, base_skin )

		local allow_arms = true
		local allow_torso = true
		if prefab == "wolfgang" then
			if skintype == "wimpy_skin" then
				--allow clothing
			elseif skintype == "normal_skin" then
				allow_arms = false
			elseif skintype == "mighty_skin" then
				allow_arms = false
				allow_torso = false

				--check to see if we're wearing a one piece clothing, if so, allow the torso
				local name = clothing_names["body"]
				if CLOTHING[name] ~= nil then
					local has_torso = false
					local has_pelvis = false
					for _,sym in pairs(CLOTHING[name].symbol_overrides) do
						if sym == "torso" then
							has_torso = true
						end
						if sym == "torso_pelvis" then
							has_pelvis = true
						end
					end
					if has_torso and has_pelvis then
						--one piece clothing, so allow the torso
						allow_torso = true
					end
				end
			end
		end

		--collect the list of symbols that the clothing pieces have requested to fall back to the base skin.
		local symbols_to_use_base = {}
		for _,name in pairs(clothing_names) do
			if CLOTHING[name] ~= nil and CLOTHING[name].base_fallbacks then
				for _,base_sym in pairs(CLOTHING[name].base_fallbacks) do
					table.insert(symbols_to_use_base, base_sym)
				end
			end
		end

		local symbol_overridden = {}

		local torso_symbol = "torso"
		local pelvis_symbol = "torso_pelvis"

		for _,type in pairs( clothing_order ) do
			local name = clothing_names[type]
			if CLOTHING[name] ~= nil then
				local src_symbols = nil
				local src_symbols_alt = nil

				--wolfgang
				if skintype == "wimpy_skin" and CLOTHING[name].symbol_overrides_skinny then
					src_symbols = CLOTHING[name].symbol_overrides_skinny
					
				elseif skintype == "normal_skin" and (CLOTHING[name].symbol_overrides_skinny or CLOTHING[name].symbol_overrides_mighty) then
					if CLOTHING[name].symbol_overrides_skinny ~= nil
					and (CLOTHING[name].symbol_overrides_skinny["arm_upper"]
						or CLOTHING[name].symbol_overrides_skinny["arm_upper_skin"]
						or CLOTHING[name].symbol_overrides_skinny["arm_lower"]
						or CLOTHING[name].symbol_overrides_skinny["arm_lower_cuff"])
					or CLOTHING[name].symbol_overrides_mighty ~= nil
					and (CLOTHING[name].symbol_overrides_mighty["arm_upper"]
						or CLOTHING[name].symbol_overrides_mighty["arm_upper_skin"]
						or CLOTHING[name].symbol_overrides_mighty["arm_lower"]
						or CLOTHING[name].symbol_overrides_mighty["arm_lower_cuff"]) then
						allow_arms = true
					end

				elseif skintype == "mighty_skin" and CLOTHING[name].symbol_overrides_mighty then
					src_symbols = CLOTHING[name].symbol_overrides_mighty

					if CLOTHING[name].symbol_overrides_skinny ~= nil
					and (CLOTHING[name].symbol_overrides_skinny["arm_upper"]
						or CLOTHING[name].symbol_overrides_skinny["arm_upper_skin"]
						or CLOTHING[name].symbol_overrides_skinny["arm_lower"]
						or CLOTHING[name].symbol_overrides_skinny["arm_lower_cuff"])
					or CLOTHING[name].symbol_overrides_mighty ~= nil
					and (CLOTHING[name].symbol_overrides_mighty["arm_upper"]
						or CLOTHING[name].symbol_overrides_mighty["arm_upper_skin"]
						or CLOTHING[name].symbol_overrides_mighty["arm_lower"]
						or CLOTHING[name].symbol_overrides_mighty["arm_lower_cuff"]) then
						allow_arms = true
					end

					if CLOTHING[name].symbol_overrides_mighty["torso"] then
						allow_torso = true
					end
				
				--wormwood
				elseif skintype == "stage_2" and CLOTHING[name].symbol_overrides_stage2 then
					src_symbols = CLOTHING[name].symbol_overrides_stage2
				elseif skintype == "stage_3" and CLOTHING[name].symbol_overrides_stage3 then
					src_symbols = CLOTHING[name].symbol_overrides_stage3
				elseif skintype == "stage_4" and CLOTHING[name].symbol_overrides_stage4 then
					src_symbols = CLOTHING[name].symbol_overrides_stage4

				--wurt
				elseif skintype == "powerup" and CLOTHING[name].symbol_overrides_powerup then
					src_symbols = CLOTHING[name].symbol_overrides_powerup
				
				--wanda
				elseif skintype == "old_skin" and CLOTHING[name].symbol_overrides_old then
					src_symbols = CLOTHING[name].symbol_overrides_old

				end

				--A secondary set of alternate src_symbols
				if CLOTHING[name].symbol_overrides_by_character ~= nil then
					src_symbols_alt = CLOTHING[name].symbol_overrides_by_character[prefab] or CLOTHING[name].symbol_overrides_by_character["default"]
				end

                if type == "body" then
                    --the last iteration was the legs type, so check if the leg symbol was using the a boot, then we can assume it also set the foot
                    local use_leg_boot = leg_build and CLOTHING[leg_build] and CLOTHING[leg_build].has_leg_boot
	                if leg_build == foot_build and use_leg_boot then
		                if table.contains(CLOTHING[name].symbol_overrides, "leg") then
                            --the body uses the leg symbol, so we need to take the rest of the boot off otherwise it could get split
                            anim_state:ClearOverrideSymbol("foot")
                            foot_build = nil
                            feet_cuff_size = 1
                        end
	                end
                end

				for _,sym in pairs(CLOTHING[name].symbol_overrides) do
					if not ModManager:IsModCharacterClothingSymbolExcluded( prefab, sym ) then
						if (not allow_torso and sym == "torso") or (not allow_arms and ((sym == "arm_upper" or sym == "arm_upper_skin" or sym == "arm_lower") or (sym == "arm_lower_cuff" and type == "body" )) ) then
							--skip this symbol for wolfgang

						elseif table.contains(symbols_to_use_base, sym) then
							--skip this symbol because one of the clothing requested it fall to the default (hand_willow_gladiator)
							--print("skip symbol and leave it at base:", sym)
						else
							local src_sym = sym
							if src_symbols then
								src_sym = src_symbols[sym] or sym
							end
							if src_symbols_alt then
								src_sym = src_symbols_alt[sym] or src_sym
							end

							local real_build = GetBuildForItem(name)
							if sym == "torso" then
								torso_build = real_build
								torso_symbol = src_sym
							end
							if sym == "torso_pelvis" then
								pelvis_build = real_build
								pelvis_symbol = src_sym
							end
							if sym == "skirt" then skirt_build = real_build end
							if sym == "leg" then leg_build = real_build end
							if sym == "foot" then foot_build = real_build end

							anim_state:ShowSymbol(sym)
							anim_state:OverrideSkinSymbol(sym, real_build, src_sym )
							symbol_overridden[sym] = true
							--print("setting skin", sym, name )

							if sym == "leg" then
								anim_state:ShowSymbol("foot") --Hack for wormwood cactus legs hiding feet. If someone else sets legs (full body piece) we want to show the feet again. This should be generalized better if we're going to do more silly stuff like feet hiding.

								if CLOTHING[name].legs_cuff_size ~= nil then
									legs_cuff_size = CLOTHING[name].legs_cuff_size
									--print("setting legs_cuff_size to", legs_cuff_size, name )
								else
									legs_cuff_size = 1
								end
							end
							if sym == "foot" then
								if CLOTHING[name].feet_cuff_size ~= nil then
									feet_cuff_size = CLOTHING[name].feet_cuff_size
									--print("setting feet_cuff_size to", feet_cuff_size, name )
								else
									feet_cuff_size = 1
									--print("setting feet_cuff_size to 1", name )
								end
							end
						end
					end
				end

				--override the base skin's torso_tuck value
				if CLOTHING[name].torso_tuck ~= nil and allow_torso then
					tuck_torso = CLOTHING[name].torso_tuck
					--print("setting tuck_torso to", tuck_torso, name )
				end

				if CLOTHING[name].symbol_hides then
					for _,sym in pairs(CLOTHING[name].symbol_hides) do
						if sym == "arm_upper_skin" and not allow_arms then
							--don't hide arm_upper_skin if we're not allowed to show the arms, otherwise we'll be hiding the
						else
							anim_state:HideSymbol(sym)
						end
					end
				end
				if CLOTHING[name].symbol_in_base_hides then
					for _,sym in pairs(CLOTHING[name].symbol_in_base_hides) do
						if not symbol_overridden[sym] then
							anim_state:HideSymbol(sym)
						end
					end
				end
				for _, sym in pairs(symbols_to_use_base) do -- Force these to show in case any of them were hidden.
					anim_state:ShowSymbol(sym)
				end
				if CLOTHING[name].symbol_shows then
					for _,sym in pairs(CLOTHING[name].symbol_shows) do
						anim_state:ShowSymbol(sym)
					end
				end
			end
		end
		
		for _, sym in pairs(monkey_pieces) do
			anim_state:ShowSymbol(sym)
			anim_state:OverrideSymbol( sym, "wonkey", sym )
			if sym == "foot" then
				feet_cuff_size = 3
			end
		end

		--Wolfgang's topless torso should always be tucked
		if not allow_torso then
			tuck_torso = "full"
		end

		--Future work to be done here: Is this a workable solution long term for skirt issues?
		--Maybe we need a better system for tagging dresses that can't have torso symbols tucked into them.
		--Hide any of the base symbols if requested (probably only ever the default skirts). This allows us to turn the skirt on manually with a clothing choice)
		--for _,name in pairs( clothing_names ) do
		--	if CLOTHING[name] ~= nil and CLOTHING[name].symbol_hides_only_base then
		--		for _,sym in pairs(CLOTHING[name].symbol_hides_only_base) do
		--			if not symbol_overridden[sym] then
		--				anim_state:HideSymbol(sym)
		--			end
		--		end
		--	end
		--end

		local wide = false
		--Certain builds need to use the wide versions to fit clothing, nil build indicates it will use the base
		if (BASE_ALTERNATE_FOR_BODY[base_skin] and torso_build == nil and (pelvis_build ~= nil or skirt_build ~= nil)) then
			torso_symbol = "torso_wide"
			--print("torso replaced with torso_wide")
			wide = true
			anim_state:OverrideSkinSymbol("torso", base_skin, torso_symbol )
		end
		if (BASE_ALTERNATE_FOR_BODY[base_skin] and pelvis_build == nil and (torso_build ~= nil or skirt_build ~= nil)) then
			pelvis_symbol = "torso_pelvis_wide"
			--print("torso_pelvis replaced with torso_pelvis_wide")
			wide = true
			anim_state:OverrideSkinSymbol("torso_pelvis", base_skin, pelvis_symbol )
		end
		if BASE_ALTERNATE_FOR_SKIRT[base_skin] and torso_build ~= nil and skirt_build == nil then
			wide = true
			anim_state:OverrideSkinSymbol("skirt", base_skin, "skirt_wide")
		end

		--one piece skirt fixes (willow skin bases)
		if ONE_PIECE_SKIRT[base_skin] and (tuck_torso == "full" or tuck_torso == "skirt") and torso_build ~= nil and skirt_build == nil  then
			anim_state:HideSymbol("skirt")
		end

		--deal with leg boots (yes, we're using the leg_build as the skinname. Sometime we override the build, but the base skin "should" have the same definition)
		local use_leg_boot = leg_build and CLOTHING[leg_build] and CLOTHING[leg_build].has_leg_boot
		if leg_build == foot_build and use_leg_boot then
			local boot_symbol = "leg_boot"
			if CLOTHING[leg_build].symbol_overrides_by_character ~= nil then
				local alt_symbols = CLOTHING[leg_build].symbol_overrides_by_character[prefab] or CLOTHING[leg_build].symbol_overrides_by_character["default"] 
				boot_symbol = alt_symbols["leg_boot"] or "leg_boot"
			end

			anim_state:OverrideSkinSymbol("leg", leg_build, boot_symbol )
		end

		--deal with foot nubs
		local has_nub = BASE_FEET_SIZE[base_skin] == -1
		local nub_build = base_skin
		local nub_symbol_name = "nub"
		local assigned_leg = clothing_names["legs"]
		if assigned_leg ~= nil and CLOTHING[assigned_leg] ~= nil and CLOTHING[assigned_leg].has_nub then
			has_nub = true
			nub_build = clothing_names["legs"]
			if skintype == "powerup" and CLOTHING[assigned_leg].symbol_overrides_powerup ~= nil then
				nub_symbol_name = CLOTHING[assigned_leg].symbol_overrides_powerup["nub"] or "nub"
			end
		end
		if has_nub and symbol_overridden["leg"] and not symbol_overridden["foot"] and leg_build ~= nub_build then
			anim_state:OverrideSkinSymbol("foot", nub_build, nub_symbol_name )
			feet_cuff_size = 0
		end

		--characters with skirts, and untucked torso clothing need to exchange the render order of the torso and skirt so that the torso is above the skirt
		if tuck_torso == "untucked" or (tuck_torso == "untucked_wide" and wide) then
			--print("torso over the skirt")
			anim_state:SetSymbolExchange( "skirt", "torso" )
		elseif tuck_torso == "pelvis_skirt" then
			--print("torso_pelvis over the skirt")
			anim_state:SetSymbolExchange( "skirt", "torso_pelvis" )
		end
		if legs_cuff_size > feet_cuff_size then
			--if inst.user ~= "KU_MikeBell" then --mike always tucks his pants into all shoes, including high heels...
				--print("put the leg in front of the foot")
				anim_state:SetMultiSymbolExchange( "leg", "foot" ) --put the legs in front of the feet
			--end
		end

		if tuck_torso == "full" then
			torso_build = torso_build or base_skin
			pelvis_build = pelvis_build or base_skin
			--print("put the pelvis on top of the base torso")
			anim_state:OverrideSkinSymbol("torso", pelvis_build, pelvis_symbol ) --put the pelvis on top of the base torso by putting it in the torso slot
			--print("put the torso in pelvis slot")
			anim_state:OverrideSkinSymbol("torso_pelvis", torso_build, torso_symbol ) --put the torso in pelvis slot to go behind
		elseif needs_legacy_fixup then
			if torso_build ~= nil and pelvis_build ~= nil then
				--fully clothed, no fixup required
			elseif torso_build == nil and pelvis_build ~= nil then
				--print("~~~~~ put base torso behind, [" .. base_skin .. "]")
				anim_state:OverrideSkinSymbol("torso_pelvis", base_skin, torso_symbol ) --put the base torso in pelvis slot to go behind
				anim_state:OverrideSkinSymbol("torso", pelvis_build, pelvis_symbol ) --put the clothing pelvis on top of the base torso by putting it in the torso slot
			elseif torso_build ~= nil and pelvis_build == nil then
				--print("~~~~~ fill in the missing pelvis, [" .. base_skin .. "]")
				anim_state:OverrideSkinSymbol("torso_pelvis", base_skin, "torso" ) --fill in the missing pelvis, with the base torso
			else
				--no clothing at all, nothing to fixup
			end
		end
	end
end

function Skinner:GetSkinMode()
    return self.skintype
end

function Skinner:SetSkinMode(skintype, default_build)
	skintype = skintype or self.skintype
	local base_skin = ""

	self.skintype = skintype

	if self.skin_data == nil then
		--fix for legacy saved games with already spawned players that don't have a skin_name set
		self:SetSkinName(self.inst.prefab.."_none", nil, true)
	end

	if skintype == "ghost_skin" then
		--DST characters should all be using self.skin_data, ghostbuild is legacy for mod characters
		base_skin = self.skin_data[skintype] or self.inst.ghostbuild or default_build or "ghost_" .. self.inst.prefab .. "_build"
	else
		base_skin = self.skin_data[skintype] or default_build or self.inst.prefab
	end

	SetSkinsOnAnim( self.inst.AnimState, self.inst.prefab, base_skin, self.clothing, self.monkey_curse, skintype, default_build )
	if self.base_change_cb ~= nil then
		self.base_change_cb()
	end

	self.inst.Network:SetPlayerSkin( self.skin_name or "", self.clothing["body"] or "", self.clothing["hand"] or "", self.clothing["legs"] or "", self.clothing["feet"] or "" )
end

function Skinner:SetupNonPlayerData()
	self.skin_name = "NON_PLAYER"
	self.skin_data = {}
	self:SetSkinMode("NO_BASE")
end

function Skinner:SetSkinName(skin_name, skip_beard_setup, skip_skins_set)
    if skin_name == "" then
        skin_name = self.inst.prefab.."_none"
    end

	self.skin_name = skin_name
	self.skin_data = {}
	local skin_prefab = nil
	if self.skin_name ~= nil and self.skin_name ~= "" then
		skin_prefab = Prefabs[skin_name] or nil
		if skin_prefab and skin_prefab.skins then
			for k,v in pairs(skin_prefab.skins) do
				self.skin_data[k] = v
			end
		end
	end

    if self.skin_data.normal_skin == nil then
        print("ERROR!!! Invisible werebeaver is probably about to happen!!!")
    end

	--Attempt to assign a matching beard skin
	if not skip_beard_setup then
		if self.inst.components.beard ~= nil and self.inst.components.beard.is_skinnable then
			if skin_prefab ~= nil and skin_prefab.linked_beard ~= nil and TheInventory:CheckClientOwnership(self.inst.userid, skin_prefab.linked_beard) then
				self.inst.components.beard:SetSkin( skin_prefab.linked_beard )
			else
				self.inst.components.beard:SetSkin( nil )
			end
		end
	end

	if not skip_skins_set then
		self:SetSkinMode()
	end
end

local function _InternalSetClothing(self, type, name, set_skin_mode)
	if self.clothing[type] and self.clothing[type] ~= "" then
		self.inst:PushEvent("unequipskinneditem", self.clothing[type])
	end

	self.clothing[type] = name

	if name and name ~= "" then
		self.inst:PushEvent("equipskinneditem", name)
		AwardPlayerAchievement("equip_skin_clothing", self.inst)
	end

	if set_skin_mode then
		self:SetSkinMode()
	end
end

function Skinner:SetMonkeyCurse( monkey_curse )
	self.monkey_curse = monkey_curse
	self:SetSkinMode()
end

function Skinner:GetMonkeyCurse()
	return self.monkey_curse
end

function Skinner:ClearMonkeyCurse()
	self.monkey_curse = nil	
	self:SetSkinMode()
end


function Skinner:SetClothing( name )
	if IsValidClothing(name) then
		_InternalSetClothing(self, CLOTHING[name].type, name, true)
	end
end

function Skinner:GetClothing()
	return {
		base = self.skin_name,
		body = self.clothing.body,
		hand = self.clothing.hand,
		legs = self.clothing.legs,
		feet = self.clothing.feet,
	}
end

function Skinner:HideAllClothing(anim_state)
	for _,name in pairs(self.clothing) do
		if name ~= nil and name ~= "" and CLOTHING[name] ~= nil then
			for _,sym in pairs(CLOTHING[name].symbol_overrides) do
				anim_state:ClearOverrideSymbol(sym)
			end
		end
	end
end

function Skinner:ClearAllClothing()
	for type,_ in pairs(self.clothing) do
		_InternalSetClothing(self, type, "", false)
	end
	self:SetSkinMode()
end

function Skinner:ClearClothing(type)
	_InternalSetClothing(self, type, "", true)
end

function Skinner:CopySkinsFromPlayer(player)
	-- NOTES(JBK): This assumes things please be careful.
	local onto = self.inst

	-- Grab skins and validate with AnimState.
	local skins = player.components.skinner:GetClothing()
	onto.AnimState:AssignItemSkins(player.userid, skins.base or "", skins.body or "", skins.hand or "", skins.legs or "", skins.feet or "")

	-- Grab details used to apply.
	local monkey_curse = player.components.skinner:GetMonkeyCurse()
	local skin_mode = player.components.skinner:GetSkinMode()

	-- For legacy mod support, this part is like this.
	local skindata = GetSkinData(skins.base)
	local base_skin = player.prefab --.. "_none"
	if skindata.skins ~= nil then
		base_skin = skindata.skins[skin_mode] or base_skin
	end

	-- Paste it and hope nothing has went wrong.
	SetSkinsOnAnim(onto.AnimState, player.prefab, base_skin, skins, monkey_curse, skin_mode, player.prefab)
end

function Skinner:OnSave()
	return {skin_name = self.skin_name, clothing = self.clothing}
end

function Skinner:OnLoad(data)
    --V2C: InGamePlay() is used to check whether world has finished
    --     loading and snapshot player sessions have been restored.
    --     Do not validate inventory when restoring snapshot saves,
    --     because the user is not actually logged in at that time.

    if data.clothing ~= nil then
        self.clothing = data.clothing

        if InGamePlay() then
            --it's possible that the clothing was traded away. Check to see if the player still owns it on load.
            for type,clothing in pairs( self.clothing ) do
                if clothing ~= "" and not TheInventory:CheckClientOwnership(self.inst.userid, clothing) then
                    self.clothing[type] = ""
                end
            end
        end
    end

    if data.skin_name == "NON_PLAYER" then
		self:SetupNonPlayerData()
    else
		local skin_name = self.inst.prefab.."_none"
		if data.skin_name ~= nil and
			data.skin_name ~= skin_name and
			(not InGamePlay() or TheInventory:CheckClientOwnership(self.inst.userid, data.skin_name)) then
			--load base skin (check that it hasn't been traded away)
			skin_name = data.skin_name
		end
		self:SetSkinName(skin_name, true)
	end
end

return Skinner
