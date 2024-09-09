local sqrt = math.sqrt

function Vec3Util_Add(p1_x, p1_y, p1_z, p2_x, p2_y, p2_z)
    return p1_x + p2_x, p1_y + p2_y, p1_z + p2_z
end

function Vec3Util_Sub(p1_x, p1_y, p1_z, p2_x, p2_y, p2_z)
    return p1_x - p2_x, p1_y - p2_y, p1_z - p2_z
end

function Vec3Util_Scale(p1_x, p1_y, p1_z, scale)
    return p1_x * scale, p1_y * scale, p1_z * scale
end

function Vec3Util_LengthSq(p1_x, p1_y, p1_z)
    return p1_x * p1_x + p1_y * p1_y + p1_z * p1_z
end

function Vec3Util_Length(p1_x, p1_y, p1_z)
    return sqrt(p1_x * p1_x + p1_y * p1_y + p1_z * p1_z)
end

function Vec3Util_DistSq(p1_x, p1_y, p1_z, p2_x, p2_y, p2_z)
    return (p1_x - p2_x) * (p1_x - p2_x) + (p1_y - p2_y) * (p1_y - p2_y) + (p1_z - p2_z) * (p1_z - p2_z)
end

function Vec3Util_Dist(p1_x, p1_y, p1_z, p2_x, p2_y, p2_z)
    return sqrt((p1_x - p2_x) * (p1_x - p2_x) + (p1_y - p2_y) * (p1_y - p2_y) + (p1_z - p2_z) * (p1_z - p2_z))
end

function Vec3Util_Dot(p1_x, p1_y, p1_z, p2_x, p2_y, p2_z)
	return p1_x * p2_x + p1_y * p2_y + p1_z * p2_z
end

function Vec3Util_Lerp(p1_x, p1_y, p1_z, p2_x, p2_y, p2_z, percent)
	return (p2_x - p1_x) * percent + p1_x, (p2_y - p1_y) * percent + p1_y,  (p2_z - p1_z) * percent + p1_z
end

function Vec3Util_Normalize(p1_x, p1_y, p1_z)
    local length = sqrt(p1_x * p1_x + p1_y * p1_y + p1_z * p1_z)
    return p1_x / length, p1_y / length, p1_z / length
end

function Vec3Util_NormalAndLength(p1_x, p1_y, p1_z)
    local length = sqrt(p1_x * p1_x + p1_y * p1_y + p1_z * p1_z)
    return p1_x / length, p1_y / length, p1_z / length, length
end

