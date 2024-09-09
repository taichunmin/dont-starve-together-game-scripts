local sqrt = math.sqrt

function VecUtil_Add(p1_x, p1_z, p2_x, p2_z)
    return p1_x + p2_x, p1_z + p2_z
end

function VecUtil_Sub(p1_x, p1_z, p2_x, p2_z)
    return p1_x - p2_x, p1_z - p2_z
end

function VecUtil_Scale(p1_x, p1_z, scale)
    return p1_x * scale, p1_z * scale
end

function VecUtil_LengthSq(p1_x, p1_z)
    return p1_x * p1_x + p1_z * p1_z
end

function VecUtil_Length(p1_x, p1_z)
    return sqrt(p1_x * p1_x + p1_z * p1_z)
end

function VecUtil_DistSq(p1_x, p1_z, p2_x, p2_z)
    return (p1_x - p2_x) * (p1_x - p2_x) + (p1_z - p2_z) * (p1_z - p2_z)
end

function VecUtil_Dist(p1_x, p1_z, p2_x, p2_z)
    return sqrt((p1_x - p2_x) * (p1_x - p2_x) + (p1_z - p2_z) * (p1_z - p2_z))
end

function VecUtil_Dot(p1_x, p1_z, p2_x, p2_z)
	return p1_x * p2_x + p1_z * p2_z
end

function VecUtil_Lerp(p1_x, p1_z, p2_x, p2_z, percent)
	return (p2_x - p1_x) * percent + p1_x,  (p2_z - p1_z) * percent + p1_z
end

--returns 0,0 if normalize would result in a NaN
function VecUtil_NormalizeNoNaN(p1_x, p1_z)
	if p1_x == 0 and p1_z == 0 then
		return 0, 0
	end
    local x_sq = p1_x * p1_x
    local z_sq = p1_z * p1_z
    local length = sqrt(x_sq + z_sq)
    return p1_x / length, p1_z / length
end

function VecUtil_Normalize(p1_x, p1_z)
    local x_sq = p1_x * p1_x
    local z_sq = p1_z * p1_z
    local length = sqrt(x_sq + z_sq)
    return p1_x / length, p1_z / length
end

function VecUtil_NormalAndLength(p1_x, p1_z)
    local x_sq = p1_x * p1_x
    local z_sq = p1_z * p1_z
    local length = sqrt(x_sq + z_sq)
    return p1_x / length, p1_z / length, length
end

function VecUtil_GetAngleInDegrees(p1_x, p1_z)
	local angle = math.atan2(p1_z, p1_x) * RADIANS
	if angle < 0 then
		angle = 360 + angle
	end
	return angle
end

function VecUtil_GetAngleInRads(p1_x, p1_z)
    local angle = math.atan2(p1_z, p1_x)
    if angle < 0 then
    	angle = PI + PI + angle
    end
    return angle;
end

function VecUtil_Slerp(p1_x, p1_z, p2_x, p2_z, percent)
	local p1_angle = VecUtil_GetAngleInRads(p1_x, p1_z)
	local p2_angle = VecUtil_GetAngleInRads(p2_x, p2_z)

	if math.abs(p2_angle - p1_angle) > PI then
		if p2_angle > p1_angle then
			p2_angle = p2_angle - PI - PI
		else
			p1_angle = p1_angle - PI - PI
		end
	end

	local lerped_angle = Lerp(p1_angle, p2_angle, percent)

	local cos_lerped_angle = math.cos(lerped_angle)
	local sin_lerped_angle = math.sin(lerped_angle)

	return cos_lerped_angle, sin_lerped_angle
end

function VecUtil_RotateAroundPoint(a_x, a_z, b_x, b_z, theta) -- in radians
	local dir_x, dir_z = b_x - a_x, b_z - a_z
	local ct, st = math.cos(theta), math.sin(theta)
	return a_x + dir_x * ct - dir_z * st, a_z + dir_x * st + dir_z * ct
end

function VecUtil_RotateDir(dir_x, dir_z, theta) -- in radians
	local ct, st = math.cos(theta), math.sin(theta)
	return dir_x * ct - dir_z * st, dir_x * st + dir_z * ct
end