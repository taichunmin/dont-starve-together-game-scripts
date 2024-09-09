
-- Baits and Lures

local function heavy_charmfish(fish)
	local weight_precent = (fish ~= nil and fish:IsValid() and fish.components.weighable ~= nil) and fish.components.weighable:GetWeightPercent() or 0
	return weight_precent < TUNING.WEIGHABLE_HEAVY_WEIGHT_PERCENT and 0 or 1
end

local LURES =
{
	["oceanfishinglure_spoon_red"]			= { build = "oceanfishing_lure_spoon", symbol = "red",		lure_data = TUNING.OCEANFISHING_LURE.SPOON_DAY, },
	["oceanfishinglure_spoon_green"]		= { build = "oceanfishing_lure_spoon", symbol = "green",	lure_data = TUNING.OCEANFISHING_LURE.SPOON_DUSK, },
	["oceanfishinglure_spoon_blue"]			= { build = "oceanfishing_lure_spoon", symbol = "blue",		lure_data = TUNING.OCEANFISHING_LURE.SPOON_NIGHT, },

	["oceanfishinglure_spinner_red"]		= { build = "oceanfishing_lure_spinner", symbol = "red",	lure_data = TUNING.OCEANFISHING_LURE.SPINNERBAIT_DAY, },
	["oceanfishinglure_spinner_green"]		= { build = "oceanfishing_lure_spinner", symbol = "green",	lure_data = TUNING.OCEANFISHING_LURE.SPINNERBAIT_DUSK, },
	["oceanfishinglure_spinner_blue"]		= { build = "oceanfishing_lure_spinner", symbol = "blue",	lure_data = TUNING.OCEANFISHING_LURE.SPINNERBAIT_NIGHT, },

	["oceanfishinglure_hermit_rain"]		= { build = "oceanfishing_lure_hermit", symbol = "rain",    lure_data = TUNING.OCEANFISHING_LURE.SPECIAL_RAIN, },
	["oceanfishinglure_hermit_snow"]		= { build = "oceanfishing_lure_hermit", symbol = "snow",    lure_data = TUNING.OCEANFISHING_LURE.SPECIAL_SNOW, },
	["oceanfishinglure_hermit_drowsy"]		= { build = "oceanfishing_lure_hermit", symbol = "drowsy",  lure_data = TUNING.OCEANFISHING_LURE.SPECIAL_DROWSY, },
	["oceanfishinglure_hermit_heavy"]		= { build = "oceanfishing_lure_hermit", symbol = "heavy",   lure_data = TUNING.OCEANFISHING_LURE.SPECIAL_HEAVY,		fns = {charm_mod_fn = heavy_charmfish} },

	-- WIP lures, will probably use them in the future
	["oceanfishinglure_spoon_brown"]		= { build = "oceanfishing_lure_spoon", symbol = "brown",	lure_data = TUNING.OCEANFISHING_LURE.SPOON_WIP, },
	["oceanfishinglure_spoon_yellow"]		= { build = "oceanfishing_lure_spoon", symbol = "yellow",	lure_data = TUNING.OCEANFISHING_LURE.SPOON_WIP, },
	["oceanfishinglure_spoon_silver"]		= { build = "oceanfishing_lure_spoon", symbol = "silver",	lure_data = TUNING.OCEANFISHING_LURE.SPOON_WIP, },

	["oceanfishinglure_spinner_orange"]		= { build = "oceanfishing_lure_spinner", symbol = "orange", lure_data = TUNING.OCEANFISHING_LURE.SPINNERBAIT_WIP, },
	["oceanfishinglure_spinner_yellow"]		= { build = "oceanfishing_lure_spinner", symbol = "yellow", lure_data = TUNING.OCEANFISHING_LURE.SPINNERBAIT_WIP, },
	["oceanfishinglure_spinner_white"]		= { build = "oceanfishing_lure_spinner", symbol = "white",	lure_data = TUNING.OCEANFISHING_LURE.SPINNERBAIT_WIP, },

	-- other lures:
	-- spoon = tinket_17
	-- berry = berries, berries_juicy
	-- seed = seeds, seed_<veggie>
}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function item_fn(data, name)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(data.bank or data.build)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:PlayAnimation("idle_"..data.symbol)
    inst.scrapbook_anim = "idle_"..data.symbol

    MakeInventoryFloatable(inst, "small", nil, 0.5)

	inst:AddTag("oceanfishing_lure")

	if name == "oceanfishinglure_hermit_rain" then
		inst.scrapbook_specialinfo = "OCEANFISHINGLURERAIN"
	end
	if name == "oceanfishinglure_hermit_snow" then
		inst.scrapbook_specialinfo = "OCEANFISHINGLURESNOW"
	end	
	if name == "oceanfishinglure_hermit_drowsy" then
		inst.scrapbook_specialinfo = "OCEANFISHINGLUREDROWSY"
	end
	if name == "oceanfishinglure_hermit_heavy" then
		inst.scrapbook_specialinfo = "OCEANFISHINGLUREHEAVY"
	end	
	if name == "oceanfishinglure_spoon_red" or name == "oceanfishinglure_spinner_red" then
		inst.scrapbook_specialinfo = "OCEANFISHINGLURERED"
	end
	if name == "oceanfishinglure_spoon_green" or name == "oceanfishinglure_spinner_green" then
		inst.scrapbook_specialinfo = "OCEANFISHINGLUREGREEN"
	end
	if name == "oceanfishinglure_spoon_blue" or name == "oceanfishinglure_spinner_blue" then
		inst.scrapbook_specialinfo = "OCEANFISHINGLUREBLUE"
	end						

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

	inst:AddComponent("oceanfishingtackle")
	inst.components.oceanfishingtackle:SetupLure(data)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeHauntableLaunch(inst)

    return inst
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local ret = { }

for name, v in pairs(LURES) do
	local assets =
	{
		Asset("ANIM", "anim/"..v.build..".zip"),
	}
	if v.bank ~= nil and v.build ~= v.bank then
		table.insert(assets, Asset("ANIM", "anim/"..v.bank..".zip"))
	end

    table.insert(ret, Prefab(name, function() return item_fn(v, name) end, assets))
end

return unpack(ret)

