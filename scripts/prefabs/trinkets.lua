
function PickRandomTrinket()
    local chessunlocks = TheWorld.components.chessunlocks

	local has_locked_chess = chessunlocks ~= nil and (chessunlocks:GetNumLockedTrinkets() > 0)
	local is_hallowednights = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS)

	local unlocked_trinkets = {}
	for i = 1,NUM_TRINKETS do
		if (not has_locked_chess or not chessunlocks:IsLocked("trinket_"..i))
			and (is_hallowednights or not(i >= HALLOWEDNIGHTS_TINKET_START and i <= HALLOWEDNIGHTS_TINKET_END)) then

			table.insert(unlocked_trinkets, i)
		end
    end

    return "trinket_"..unlocked_trinkets[math.random(#unlocked_trinkets)]
end

local assets =
{
    Asset("ANIM", "anim/trinkets.zip"),
}

local TRADEFOR =
{
    [15] = {"chesspiece_bishop_sketch"},
    [16] = {"chesspiece_bishop_sketch"},
    [28] = {"chesspiece_rook_sketch"},
    [29] = {"chesspiece_rook_sketch"},
    [30] = {"chesspiece_knight_sketch"},
    [31] = {"chesspiece_knight_sketch"},
}

local SMALLFLOATS =
{
    [2]     = {0.9, 0.0},
    [4]     = {0.7, 0.1},
    [5]     = {0.6, 0.1},
    [6]     = {0.7, 0.1},
    [8]     = {0.7, 0.05},
    [9]     = {0.9, 0.1},
    [10]    = {0.9, 0.1},
    [11]    = {0.9, 0.1},
    [12]    = {0.7, 0.1},
    [13]    = {0.7, 0.1},
    [14]    = {0.7, 0.1},
    [15]    = {0.5, 0.15},
    [16]    = {0.5, 0.15},
    [19]    = {0.9, 0.1},
    [22]    = {0.8, 0.1},
    [24]    = {0.8, 0.05},
    [26]    = {0.6, 0.1},
    [28]    = {0.5, 0.15},
    [29]    = {0.5, 0.15},
    [30]    = {0.5, 0.15},
    [31]    = {0.5, 0.15},
    [32]    = {1.0, 0.2},
    [33]    = {0.8, 0.1},
    [35]    = {1.0, 0.1},
    [36]    = {0.8, 0.0},
    [38]    = {1.0, 0.1},
    [39]    = {1.3, 0.05},
    [41]    = {0.65, 0.15},
    [43]    = {0.9, 0.05},
    [44]    = {0.7, 0.1},
    [45]    = {0.9, 0.05},
}

local OCEANFISHING_BOBBER =
{
	[8] = {tuning = TUNING.OCEANFISHING_TACKLE.BOBBER_PLUG, projectile_prefab = "oceanfishingbobber_plug_projectile"},
}

local OCEANFISHING_LURE =
{
	[17] = { build = "oceanfishing_lure_spoon", symbol = "spork", lure_data = TUNING.OCEANFISHING_LURE.SPOON_SPORK, },
}

local EXTRA_DATA = {}
for i = 1, NUM_TRINKETS do
	table.insert(EXTRA_DATA, {})
end
EXTRA_DATA[1] = { slingshotammo = true }


local function MakeTrinket(num)
    local prefabs = TRADEFOR[num] or {}
	if OCEANFISHING_BOBBER[num] ~= nil and OCEANFISHING_BOBBER[num].projectile_prefab ~= nil then
		table.insert(prefabs, OCEANFISHING_BOBBER[num].projectile_prefab)
	end
	if EXTRA_DATA[num].slingshotammo then
		table.insert(prefabs, "trinket_"..tostring(num).."_proj")
	end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("trinkets")
        inst.AnimState:SetBuild("trinkets")
        inst.AnimState:PlayAnimation(tostring(num))
        inst.scrapbook_anim = tostring(num)

        inst:AddTag("molebait")
        inst:AddTag("cattoy")

		if OCEANFISHING_BOBBER[num] ~= nil then
			inst:AddTag("oceanfishing_bobber")
		end

		if OCEANFISHING_LURE[num] ~= nil then
			inst:AddTag("oceanfishing_lure")
		end

		if EXTRA_DATA[num].slingshotammo then
			inst:AddTag("slingshotammo")
			inst:AddTag("reloaditem_ammo")
		end

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

		if EXTRA_DATA[num].slingshotammo then
			inst:AddComponent("reloaditem")
		end

        inst:AddComponent("inspectable")
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inventoryitem")

        if SMALLFLOATS[num] ~= nil then
            inst.components.floater:SetScale(SMALLFLOATS[num][1])
            inst.components.floater:SetVerticalOffset(SMALLFLOATS[num][2])
        end

        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.TRINKETS[num] or 3
        inst.components.tradable.tradefor = TRADEFOR[num]

		if num >= HALLOWEDNIGHTS_TINKET_START and num <= HALLOWEDNIGHTS_TINKET_END then
	        if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
				inst.components.tradable.halloweencandyvalue = 5
			end
		end
		inst.components.tradable.rocktribute = math.ceil(inst.components.tradable.goldvalue / 3)

        MakeHauntableLaunchAndSmash(inst)

        inst:AddComponent("bait")

		if OCEANFISHING_BOBBER[num] ~= nil then
			inst:AddComponent("oceanfishingtackle")
			inst.components.oceanfishingtackle:SetCastingData(OCEANFISHING_BOBBER[num].tuning, OCEANFISHING_BOBBER[num].projectile_prefab)
		end
		if 	OCEANFISHING_LURE[num] ~= nil then
			inst:AddComponent("oceanfishingtackle")
			inst.components.oceanfishingtackle:SetupLure(OCEANFISHING_LURE[num])
		end

        return inst
    end

    return Prefab("trinket_"..tostring(num), fn, assets, prefabs)
end

local ret = {}
for k = 1, NUM_TRINKETS do
    table.insert(ret, MakeTrinket(k))
end

return unpack(ret)
