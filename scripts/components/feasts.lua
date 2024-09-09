--------------------------------------------------------------------------
--[[ Feasts class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Feasts should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _tablegroups = {}
local _feasters = {}

local TICK_RATE = 1/3

local NUM_FEASTERS_MAX_ANNOUNCE_RATE = 5
local ANNOUNCE_INITIAL_DELAY = 0.25
local ANNOUNCE_RATE_BASE_MIN = 5.5
local ANNOUNCE_RATE_VARIANCE_MIN = 3
local ANNOUNCE_RATE_BASE_MAX = 9
local ANNOUNCE_RATE_VARIANCE_MAX = 5.5

local DELAY_ANNOUNCE_BUFF = 0.65
local DELAY_ANNOUNCE_BUFF_VARIANCE = 0.6

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------
local function isintable(testtable,entry)
    for i,data in ipairs(testtable)do
        if data == entry then
            return true
        end
    end
end

local function gettablegroup(target)
    for i,group in ipairs(_tablegroups)do
        for c,checktable in ipairs(group)do
            if checktable == target then
                return i
            end
        end
    end
end

local function ApplyFeastBuff(feaster, tables, totalfeasters)

    local foods = {}
    local totalfood = 0
    for i,wintertable in ipairs(tables)do
        local food = wintertable.components.inventory:GetItemInSlot(1)
        if food ~= nil and food:HasTag("wintersfeastcookedfood") then
            foods[food.prefab] = true
            totalfood = totalfood + 1
        end
    end
    local differentfoodtypes = 0
    for i,food in pairs(foods)do
        differentfoodtypes = differentfoodtypes +1
    end
    --print("PLAYER FEASTING",feaster.prefab,"FOODS:",differentfoodtypes,"FEASTERS:",totalfeasters,"totalfood",totalfood)
    feaster:AddDebuff("wintersfeastbuff", "wintersfeastbuff")
    local buff = feaster:GetDebuff("wintersfeastbuff")
    if buff ~= nil then
        buff.addeffectbonusfn(buff, totalfeasters, differentfoodtypes, totalfood)
    end
end

local function doFeastCheck()
    local activegroups = {}
    for i,set in ipairs(_feasters)do
        local group = gettablegroup(set.target )
        if not activegroups[group] then
            activegroups[group] = {}
        end
        table.insert(activegroups[group],set.player)
    end

    for group,feasters in pairs(activegroups)do
        for i,wintertable in ipairs(_tablegroups[group])do
            wintertable.components.wintersfeasttable:DepleteFood(#feasters)
            if wintertable.AnimState:IsCurrentAnimation("idle") then
                if math.random()<0.05 then
                    wintertable:PushEvent("ruffle")
                end
            end
        end
        for i, feaster in ipairs(feasters)do
            ApplyFeastBuff(feaster,_tablegroups[group],#feasters)
        end

		_tablegroups[group].time_until_announce = (_tablegroups[group].time_until_announce or ANNOUNCE_INITIAL_DELAY) - TICK_RATE
		if _tablegroups[group].time_until_announce <= 0 then
			local announcer = #feasters > 0 and (_tablegroups[group].force_announcer or feasters[math.random(1, #feasters)])
			if announcer ~= nil and announcer:IsValid() and announcer.components.talker ~= nil and
				(#feasters == 1 or announcer ~= _tablegroups[group].previous_announcer) then

				_tablegroups[group].previous_announcer = announcer
				announcer.components.talker:Say(GetString(announcer, "ANNOUNCE_IS_FEASTING"))

				local denominator = NUM_FEASTERS_MAX_ANNOUNCE_RATE - 1
				local alpha = math.min(#feasters - 1, denominator) / denominator
				_tablegroups[group].time_until_announce = Lerp(ANNOUNCE_RATE_BASE_MAX, ANNOUNCE_RATE_BASE_MIN, alpha)
					+ Lerp(ANNOUNCE_RATE_VARIANCE_MAX, ANNOUNCE_RATE_VARIANCE_MIN, alpha) * math.random()
			else
				-- Else keep trying every tick
				_tablegroups[group].time_until_announce = 0
			end

			_tablegroups[group].force_announcer = nil
		end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function FeasterOnRemove(inst)--Runs on player inst that was removed from feast
	TheWorld:PushEvent("feasterfinished",{player=inst, target=nil})
end

local function OnFeasterAdded(inst,data)
	table.insert(_feasters,{player=data.player,target=data.target})
	data.player:ListenForEvent("onremove", FeasterOnRemove)
    if not inst.feastingtask then
        inst.feastingtask = inst:DoPeriodicTask(TICK_RATE,doFeastCheck)
	end

	local group = gettablegroup(data.target)
	if group ~= nil then
		_tablegroups[group].time_until_announce = ANNOUNCE_INITIAL_DELAY
		_tablegroups[group].force_announcer = data.player
	end
end

local function OnFeasterRemoved(inst,data)
	data.player:RemoveEventCallback("onremove", FeasterOnRemove)

    local feaster = nil
    for i,set in ipairs(_feasters)do
        if set.player == data.player then
            table.remove(_feasters,i)
            break
        end
    end
    if #_feasters <= 0 then
        if inst.feastingtask then
            inst.feastingtask:Cancel()
            inst.feastingtask = nil
        end
    end

	if data.player._task_announce_winters_feast_buff ~= nil then
		data.player._task_announce_winters_feast_buff:Cancel()
		data.player._task_announce_winters_feast_buff = nil
	end
	if not data.is_in_dark then
		data.player._task_announce_winters_feast_buff = data.player:DoTaskInTime(DELAY_ANNOUNCE_BUFF + math.random() * DELAY_ANNOUNCE_BUFF_VARIANCE, function(inst)
			if inst.components.talker ~= nil then
				inst.components.talker:Say(GetString(inst, "ANNOUNCE_WINTERS_FEAST_BUFF"))
			end
			inst._task_announce_winters_feast_buff = nil
		end)
	end
end
---------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:ListenForEvent("feasterstarted", OnFeasterAdded, TheWorld)
inst:ListenForEvent("feasterfinished", OnFeasterRemoved, TheWorld)


--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------
function self:GetTableGroup(inst)
    return gettablegroup(inst)
end

function self:GetFeasters()
    return _feasters
end

function self:GetTableGroups()
    return _tablegroups
end

function self:GetFeasterGroup(feaster)
    local group = nil
    local wintertable = nil
    for i,chardata in ipairs(_feasters)do
        if chardata.player == feaster then
          wintertable = data.target
          break
        end
    end

    if wintertable then
        return gettablegroup(wintertable)
    end
end

local FEAST_TABLE_TAG = { "wintersfeasttable" }
function self:RegisterTable(inst)
    --find tables in range of this table. Check for their groups. Merge groups if necessary.
    local x,y,z = inst.Transform:GetWorldPosition()
    local tables = TheSim:FindEntities(x, y, z, TUNING.WINTERSFEASTTABLE.TABLE_RANGE, FEAST_TABLE_TAG)
    local closegroups = {}
    for f,foundtable in ipairs(tables)do
        if foundtable ~= inst then
            for t,tablegroup in ipairs(_tablegroups)do
                for g,grouptable in ipairs(tablegroup)do
                    if grouptable == foundtable and not isintable(closegroups,t) then
                        if not inst:GetCurrentPlatform() or (grouptable:GetCurrentPlatform() and inst:GetCurrentPlatform() == grouptable:GetCurrentPlatform()) then
                            table.insert(closegroups,t)
                            break
                        end
                    end
                end
            end
        end
    end
    -- merge all found groups together.

    if #closegroups > 0 then
        table.insert(_tablegroups[closegroups[1]],inst)

        if #closegroups > 1 then
			table.sort(closegroups)
            for i=#closegroups, 2, -1 do
                for t,grouptable in ipairs(_tablegroups[closegroups[i]])do
                    table.insert(_tablegroups[closegroups[1]],grouptable)
                end
                table.remove(_tablegroups,closegroups[i])
            end
        end
    else
        table.insert(_tablegroups,{inst})
    end

    local thisgroup = self:GetTableGroup(inst)
    local delay = 0.2    -- delay*(#self:GetTableGroups()[thisgroup]-i+1)
    for i=#self:GetTableGroups()[thisgroup],1,-1 do
        local wintertable = self:GetTableGroups()[thisgroup][i]
        if wintertable ~= inst then
            local dist = inst:GetDistanceSqToInst(wintertable)
            local oneseconddist = 20
            local time = Remap(dist,0,oneseconddist*oneseconddist,0,1)
            wintertable:DoTaskInTime(time,function()
                wintertable:PushEvent("ruffle")
            end)
        end
    end
end

function self:UnregisterTable(inst)
    -- find the group this table is in.
    local group = nil
    for t,tablegroup in ipairs(_tablegroups)do
        for g,grouptable in ipairs(tablegroup)do
            if grouptable == inst then
                group = t
                table.remove(tablegroup,g)
                break
            end
        end
    end

    -- group up remaining tables here
    if group then -- table might have burned?
        while #_tablegroups[group] > 0 do
            local openlist = {_tablegroups[group][1]}
            local closedlist = {}

            while #openlist > 0 do
                for c,checktable in ipairs(_tablegroups[group])do
                    if not isintable(closedlist,checktable) and not isintable(openlist,checktable) and checktable:GetDistanceSqToInst(openlist[1]) < TUNING.WINTERSFEASTTABLE.TABLE_RANGE * TUNING.WINTERSFEASTTABLE.TABLE_RANGE then
                        table.insert(openlist,checktable)
                    end
                end
                table.insert(closedlist,openlist[1])
                table.remove(openlist,1)
            end
            for i=#_tablegroups[group], 1, -1 do
                if isintable(closedlist,_tablegroups[group][i]) then
                    table.remove(_tablegroups[group],i)
                end
            end
            table.insert(_tablegroups,closedlist)
        end
        table.remove(_tablegroups,group)

    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return string.format("groups:%d", #_tablegroups)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
