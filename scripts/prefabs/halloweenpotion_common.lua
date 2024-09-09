

local puff_fx = {"halloween_firepuff_1", "halloween_firepuff_2", "halloween_firepuff_3", }
local puff_fx_cold = {"halloween_firepuff_cold_1", "halloween_firepuff_cold_2", "halloween_firepuff_cold_3", }

local prefabs = JoinArrays(puff_fx, puff_fx_cold)
local assets =
{
	Asset("ANIM", "anim/halloween_embers.zip"),
	Asset("ANIM", "anim/halloween_embers_cold.zip"),
}

local function AttachToTarget(inst, target, build, cold_build)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)

	if target.components.burnable ~= nil and target.components.burnable.fxdata[1] ~= nil then
		local fx_data = target.components.burnable.fxdata[1]
		if fx_data.follow ~= nil then
			inst.entity:AddFollower()
			inst.Follower:FollowSymbol(target.GUID, fx_data.follow, fx_data.x or 0, fx_data.y or 0, fx_data.z or 0)
		end
	end
end

local function SpawnPuffFx(inst, target)
	local fx_list = target:HasTag("blueflame") and puff_fx_cold or puff_fx
	local fx = SpawnPrefab(fx_list[math.random(#fx_list)])
	AttachToTarget(fx, target)
	return fx
end


return{
	prefabs = prefabs,
	assets = assets,
	SpawnPuffFx = SpawnPuffFx,
	AttachToTarget = AttachToTarget,
}
