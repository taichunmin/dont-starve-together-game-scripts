local YOTC_RaceStats = Class(function(self, inst)
    self.inst = inst

    self.speed = TUNING.RACE_STATS.INIT_STAT_VALUE
    self.direction = TUNING.RACE_STATS.INIT_STAT_VALUE
    self.reaction = TUNING.RACE_STATS.INIT_STAT_VALUE
    self.stamina = TUNING.RACE_STATS.INIT_STAT_VALUE

    --self.baseline_speed = nil
    --self.baseline_direction = nil
    --self.baseline_reaction = nil
    --self.baseline_stamina = nil
end)

function YOTC_RaceStats:GetSpeedModifier()
	return self.speed / TUNING.RACE_STATS.MAX_STAT_VALUE
end

function YOTC_RaceStats:GetDirectionModifier()
	return self.direction / TUNING.RACE_STATS.MAX_STAT_VALUE
end

function YOTC_RaceStats:GetReactionModifier()
	return self.reaction / TUNING.RACE_STATS.MAX_STAT_VALUE
end

function YOTC_RaceStats:GetStaminaModifier()
	return self.stamina / TUNING.RACE_STATS.MAX_STAT_VALUE
end

function YOTC_RaceStats:ModifySpeed(point_mod)
    if point_mod ~= nil and point_mod ~= 0 then
        self.speed = math.clamp(
            self.speed + point_mod,
            self.baseline_speed or TUNING.RACE_STATS.MIN_STAT_VALUE,
            TUNING.RACE_STATS.MAX_STAT_VALUE
        )
    end
end

function YOTC_RaceStats:ModifyDirection(point_mod)
    if point_mod ~= nil and point_mod ~= 0 then
        self.direction = math.clamp(
            self.direction + point_mod,
            self.baseline_direction or TUNING.RACE_STATS.MIN_STAT_VALUE,
            TUNING.RACE_STATS.MAX_STAT_VALUE
        )
    end
end

function YOTC_RaceStats:ModifyReaction(point_mod)
    if point_mod ~= nil and point_mod ~= 0 then
        self.reaction = math.clamp(
            self.reaction + point_mod,
            self.baseline_reaction or TUNING.RACE_STATS.MIN_STAT_VALUE,
            TUNING.RACE_STATS.MAX_STAT_VALUE
        )
    end
end

function YOTC_RaceStats:ModifyStamina(point_mod)
    if point_mod ~= nil and point_mod ~= 0 then
        self.stamina = math.clamp(
            self.stamina + point_mod,
            self.baseline_stamina or TUNING.RACE_STATS.MIN_STAT_VALUE,
            TUNING.RACE_STATS.MAX_STAT_VALUE
        )
    end
end

function YOTC_RaceStats:GetBestStats()
    local highest_stat_value = math.max(self.speed, self.direction, self.reaction, self.stamina)
    local stats = {}
    if self.speed == highest_stat_value then
        table.insert(stats, 1)
    end
    if self.direction == highest_stat_value then
        table.insert(stats, 2)
    end
    if self.reaction == highest_stat_value then
        table.insert(stats, 3)
    end
    if self.stamina == highest_stat_value then
        table.insert(stats, 4)
    end

    return stats
end

function YOTC_RaceStats:GetNumStatPoints()
    return self.speed + self.direction + self.reaction + self.stamina
end

function YOTC_RaceStats:AddRandomPointSpread(num_points)
    -- Can't randomly add no points.
    if not num_points then
        return
    end

    local stats_below_max = {}
    if self.speed < TUNING.RACE_STATS.MAX_STAT_VALUE then
        table.insert(stats_below_max, 1)
    end
    if self.direction < TUNING.RACE_STATS.MAX_STAT_VALUE then
        table.insert(stats_below_max, 2)
    end
    if self.reaction < TUNING.RACE_STATS.MAX_STAT_VALUE then
        table.insert(stats_below_max, 3)
    end
    if self.stamina < TUNING.RACE_STATS.MAX_STAT_VALUE then
        table.insert(stats_below_max, 4)
    end

    for i = 1, num_points do
        local num_stats = #stats_below_max
        if num_stats == 0 then
            return
        end

        local stat_index = math.random(num_stats)
        local stat = stats_below_max[stat_index]
        if stat == 1 then
            self:ModifySpeed(1)
            if self.speed >= TUNING.RACE_STATS.MAX_STAT_VALUE then
                table.remove(stats_below_max, stat_index)
            end
        elseif stat == 2 then
            self:ModifyDirection(1)
            if self.direction >= TUNING.RACE_STATS.MAX_STAT_VALUE then
                table.remove(stats_below_max, stat_index)
            end
        elseif stat == 3 then
            self:ModifyReaction(1)
            if self.reaction >= TUNING.RACE_STATS.MAX_STAT_VALUE then
                table.remove(stats_below_max, stat_index)
            end
        elseif stat == 4 then
            self:ModifyStamina(1)
            if self.stamina >= TUNING.RACE_STATS.MAX_STAT_VALUE then
                table.remove(stats_below_max, stat_index)
            end
        end
    end
end

function YOTC_RaceStats:DegradePoints(num_points)
    local base_speed = (self.baseline_speed or TUNING.RACE_STATS.INIT_STAT_VALUE)
    local base_direction = (self.baseline_direction or TUNING.RACE_STATS.INIT_STAT_VALUE)
    local base_reaction = (self.baseline_reaction or TUNING.RACE_STATS.INIT_STAT_VALUE)
    local base_stamina = (self.baseline_stamina or TUNING.RACE_STATS.INIT_STAT_VALUE)

    if not num_points then
        -- If we weren't given a number of points to degrade by, just bust ourselves down to initial values
        self.speed = base_speed
        self.direction = base_direction
        self.reaction = base_reaction
        self.stamina = base_stamina
    else
        local stats_above_base = {}
        if self.speed > base_speed then
            table.insert(stats_above_base, 1)
        end
        if self.direction > base_direction then
            table.insert(stats_above_base, 2)
        end
        if self.reaction > base_reaction then
            table.insert(stats_above_base, 3)
        end
        if self.stamina > base_stamina then
            table.insert(stats_above_base, 4)
        end

        for i = 1, num_points do
            local num_stats = #stats_above_base
            if num_stats == 0 then
                return
            end

            local stat_index = math.random(num_stats)
            local stat = stats_above_base[stat_index]
            if stat == 1 then
                self:ModifySpeed(-1)
                if self.speed <= base_speed then
                    table.remove(stats_above_base, stat_index)
                end
            elseif stat == 2 then
                self:ModifyDirection(-1)
                if self.direction <= base_direction then
                    table.remove(stats_above_base, stat_index)
                end
            elseif stat == 3 then
                self:ModifyReaction(-1)
                if self.reaction <= base_reaction then
                    table.remove(stats_above_base, stat_index)
                end
            elseif stat == 4 then
                self:ModifyStamina(-1)
                if self.stamina <= base_stamina then
                    table.remove(stats_above_base, stat_index)
                end
            end
        end
    end

    -- Return true if we have still have points to degrade.
    return self.speed > base_speed or
            self.direction > base_direction or
            self.reaction > base_reaction or
            self.stamina > base_stamina
end

function YOTC_RaceStats:SaveCurrentStatsAsBaseline()
    self.baseline_speed = self.speed
    self.baseline_direction = self.direction
    self.baseline_reaction = self.reaction
    self.baseline_stamina = self.stamina
end

function YOTC_RaceStats:OnSave()
    return
    {
        speed = self.speed,
        direction = self.direction,
        reaction = self.reaction,
        stamina = self.stamina,
        baseline_speed = self.baseline_speed,
        baseline_direction = self.baseline_direction,
        baseline_reaction = self.baseline_reaction,
        baseline_stamina = self.baseline_stamina,
    }
end

function YOTC_RaceStats:OnLoad(data)
    if data ~= nil then
        self.speed = data.speed
        self.direction = data.direction
        self.reaction = data.reaction
        self.stamina = data.stamina

        self.baseline_speed = data.baseline_speed
        self.baseline_direction = data.baseline_direction
        self.baseline_reaction = data.baseline_reaction
        self.baseline_stamina = data.baseline_stamina
    end
end

function YOTC_RaceStats:GetDebugString()
    local s = string.format(
        "Sp: %2u,  Dr: %2u,  Re: %2u,  St: %2u",
        self.speed,
        self.direction,
        self.reaction,
        self.stamina
    )

    -- Assume that the baseline values are either all nil or all not-nil
    if self.baseline_speed ~= nil then
        s = s .. "\n" .. string.format(
            "        Baseline:     %2u,       %2u,       %2u,       %2u)",
            self.baseline_speed,
            self.baseline_direction,
            self.baseline_reaction,
            self.baseline_stamina
        )
    end

    return s
end

return YOTC_RaceStats
