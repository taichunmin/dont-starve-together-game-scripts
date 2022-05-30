local function AddDurabilityMult(inst, equip)
    if equip ~= nil and equip.components.weapon ~= nil and equip.components.finiteuses ~= nil then
        equip.components.weapon.attackwearmultipliers:SetModifier(inst, TUNING.BATTLESONG_DURABILITY_MOD)
    end
end

local function RemoveDurabilityMult(inst, equip)
   if equip ~= nil and equip.components.weapon ~= nil and equip.components.finiteuses ~= nil then
        equip.components.weapon.attackwearmultipliers:RemoveModifier(inst)
    end
end

local function AddEnemyDebuffFx(fx, target)
    target:DoTaskInTime(math.random()*0.25, function()
        local x, y, z = target.Transform:GetWorldPosition()
        local fx = SpawnPrefab(fx)
        if fx then
            fx.Transform:SetPosition(x, y, z)
        end

        return fx
    end)
end

-- Possible params: TICK_RATE, ONAPPLY, ONEXTENDED, ONDETACH, TICK_FN, ATTACH_FX, DETTACH_FX, INSTANT, DELTA, USES, SOUND
-- INSTANT, DELTA AND TARGET_PLAYERS are quote only
-- I'm keeping USES around in case we change our minds and decide the make the battlesongs consumable
local song_defs =
{
    battlesong_durability =
    {
        ONAPPLY = function(inst, target)
            if target.components.inventory then
                local equip = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                AddDurabilityMult(inst, equip)

                inst:ListenForEvent("equip", function(target, data)
                    if data.eslot == EQUIPSLOTS.HANDS then
                        AddDurabilityMult(inst, data.item)
                    end
                end, target)

                inst:ListenForEvent("unequip", function(target, data)
                    if data.eslot == EQUIPSLOTS.HANDS then
                        RemoveDurabilityMult(inst, data.item)
                    end
                end, target)
            end
        end,

        ONDETACH = function(inst, target)
            if target.components.inventory then
                local equip = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                RemoveDurabilityMult(inst, equip)
            end
        end,

        ATTACH_FX = "battlesong_attach",
        LOOP_FX = "battlesong_durability_fx",
        DETACH_FX = "battlesong_detach",
        SOUND = "dontstarve_DLC001/characters/wathgrithr/song/durability",
    },

    battlesong_healthgain =
    {
        ONAPPLY = function(inst, target)
            if target.components.health then
                inst:ListenForEvent("onattackother", function(attacker, data)
                    if target:HasTag("battlesinger") then
                        target.components.health:DoDelta(TUNING.BATTLESONG_HEALTHGAIN_DELTA_SINGER)
                    else
                        target.components.health:DoDelta(TUNING.BATTLESONG_HEALTHGAIN_DELTA)
                    end
                end, target)
            end
        end,

        ATTACH_FX = "battlesong_attach",
        LOOP_FX = "battlesong_healthgain_fx",
        DETACH_FX = "battlesong_detach",
        SOUND = "dontstarve_DLC001/characters/wathgrithr/song/healthgain",
    },

    battlesong_sanitygain =
    {
        ONAPPLY = function(inst, target)
            if target.components.sanity then
                inst:ListenForEvent("onattackother", function(attacker, data)
                    target.components.sanity:DoDelta(TUNING.BATTLESONG_SANITYGAIN_DELTA)
                end, target)
            end
        end,

        ATTACH_FX = "battlesong_attach",
        LOOP_FX = "battlesong_sanitygain_fx",
        DETACH_FX = "battlesong_detach",
        SOUND = "dontstarve_DLC001/characters/wathgrithr/song/sanitygain",
    },

    battlesong_sanityaura =
    {
        ONAPPLY = function(inst, target)
            if target.components.sanity ~= nil then
                target.components.sanity.neg_aura_modifiers:SetModifier(inst, TUNING.BATTLESONG_NEG_SANITY_AURA_MOD)
            end
        end,

        ONDETACH = function(inst, target)
            if target.components.sanity ~= nil then
                target.components.sanity.neg_aura_modifiers:RemoveModifier(inst)
            end
        end,

        ATTACH_FX = "battlesong_attach",
        LOOP_FX = "battlesong_sanityaura_fx",
        DETACH_FX = "battlesong_detach",
        SOUND = "dontstarve_DLC001/characters/wathgrithr/song/sanityaura",
    },

    battlesong_fireresistance =
    {
        ONAPPLY = function(inst, target)
            if target.components.health ~= nil then
                target.components.health.externalfiredamagemultipliers:SetModifier(inst, TUNING.BATTLESONG_FIRE_RESIST_MOD)
            end
        end,

        ONDETACH = function(inst, target)
            if target.components.health ~= nil then
                target.components.health.externalfiredamagemultipliers:RemoveModifier(inst)
            end
        end,

        ATTACH_FX = "battlesong_attach",
        LOOP_FX = "battlesong_fireresistance_fx",
        DETACH_FX = "battlesong_detach",
        SOUND = "dontstarve_DLC001/characters/wathgrithr/song/fireresistance",
    },

    ------------------------------------------------
    ------------- Quotes/Instant songs -------------
    ------------------------------------------------

    battlesong_instant_taunt =
    {
        ONINSTANT = function(singer, target)
			if not target:HasTag("bird") and target.components.combat then
	            target.components.combat:SetTarget(singer)
		        AddEnemyDebuffFx("battlesong_instant_taunt_fx", target)
			end
        end,

        INSTANT = true,
        DELTA = TUNING.BATTLESONG_INSTANT_COST,
		ATTACH_FX = "battlesong_instant_taunt_fx",
        SOUND = "dontstarve_DLC001/characters/wathgrithr/quote/taunt",
    },

    battlesong_instant_panic =
    {
        ONINSTANT = function(singer, target)
            if target.components.hauntable ~= nil and target.components.hauntable.panicable then
				target.components.hauntable:Panic(TUNING.BATTLESONG_PANIC_TIME)
				AddEnemyDebuffFx("battlesong_instant_panic_fx", target)
			end
        end,

        INSTANT = true,
        DELTA = TUNING.BATTLESONG_INSTANT_COST,
		ATTACH_FX = "battlesong_instant_panic_fx",
        SOUND = "dontstarve_DLC001/characters/wathgrithr/quote/dropattack",
    }
}

local battlesong_netid = 1
local battlesong_netid_lookup = {}

local function AddNewBattleSongNetID(prefab, song_def)
	song_def.battlesong_netid = battlesong_netid
	table.insert(battlesong_netid_lookup, prefab)
	assert(battlesong_netid < 8, "the max number of battle songs has been passed, you will need to change the netvar for player_classified.inspirationsong1/2/3 to support more")

	battlesong_netid = battlesong_netid + 1
end

for k, v in pairs(song_defs) do
    v.ITEM_NAME  = k
	v.NAME = k.."_buff" -- this name is actually the buff's name, not the inventory item
	if not v.INSTANT then
		AddNewBattleSongNetID(k, v)
	end
end

local function GetBattleSongDefFromNetID(netid)
	local def = netid ~= nil and battlesong_netid_lookup[netid] or nil
	return def ~= nil and song_defs[def] or nil
end

return {song_defs = song_defs, GetBattleSongDefFromNetID = GetBattleSongDefFromNetID, AddNewBattleSongNetID = AddNewBattleSongNetID}