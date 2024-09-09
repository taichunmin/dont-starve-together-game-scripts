local shadowassets =
{
    Asset("ANIM", "anim/shadow_fire_fx.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local throwassets =
{
    Asset("ANIM", "anim/flamethrow_fx.zip"),
    Asset("SOUND", "sound/common.fsb"),
}


local frenzyassets = {
    Asset("ANIM", "anim/frenzy_fx.zip"),
}

local prefabs =
{
    "firefx_light",
    "willow_shadow_fire_explode",
}

local shadowfirelevels =
{
    {anim="anim1", sound="meta3/willow/shadowflame", radius=2, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=.1},
    {anim="anim2",                                   radius=2, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=.1},
    {anim="anim3",                                   radius=2, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=.1},
    {anim="anim3",                                   radius=2, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=.1},
}

local throwfirelevels =
{
    {anim="pre", sound="dontstarve/common/campfire", radius=2, intensity=.8, falloff=.33, colour = {253/255,179/255,179/255}, soundintensity=.1},
}

local CLOSERANGE = 1

local TARGETS_MUST = { "_health", "_combat" }
local TARGETS_CANT = { "INLIMBO", "invisible", "noattack", "notarget", "flight" }

local function TargetIsHostile(isplayer, source, target)
	if source.HostileTest then
		return source:HostileTest(target)
	elseif isplayer and target.HostileToPlayerTest then
		return target:HostileToPlayerTest(source)
	else
		return target:HasTag("hostile")
	end
end

local function settarget(inst,target,life,source)
    local maxdeflect = 30

    if life > 0 then

        inst.shadowfire_task = inst:DoTaskInTime(0.1,function()

            local theta = inst.Transform:GetRotation() * DEGREES
            local radius = CLOSERANGE

			if not (source and source.components.combat and source:IsValid()) then
				target = nil
			elseif target == nil or not source.components.combat:CanTarget(target) then
				target = nil

				local isplayer = source:HasTag("player")

				local x, y, z = inst.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x, y, z, 20, TARGETS_MUST, TARGETS_CANT)

                if #ents > 0 then
					--mimic playercontroller attack targeting
                    for i=#ents, 1, -1 do
                        local ent = ents[i]
						if not source.components.combat:CanTarget(ent) or
							source.components.combat:IsAlly(ent)
						then
							table.remove(ents, i)
						elseif isplayer and ent.HostileToPlayerTest and ent.components.shadowsubmissive and not ent:HostileToPlayerTest(source) then
							--shadowsubmissive needs to ignore TargetIs() test,
							--since they have you targeted even when not hostile
							table.remove(ents, i)
						elseif not ent.components.combat:TargetIs(source) then
							if not TargetIsHostile(isplayer, source, ent) then
								table.remove(ents, i)
							elseif ent.components.follower then
								local leader = ent.components.follower:GetLeader()
								if leader and leader:HasTag("player") and not leader.components.combat:TargetIs(source) then
									table.remove(ents, i)
								end
							end
						end
                    end
				end

                if #ents > 0 then

                    local anglediffs = {}

                    local lowestdiff = nil
                    local lowestent = nil

					for i, ent in ipairs(ents) do

                        local ex,ey,ez = ent.Transform:GetWorldPosition()
                        local diff = math.abs(inst:GetAngleToPoint(ex,ey,ez) - inst.Transform:GetRotation())
                        if diff > 180 then diff = math.abs(diff - 360) end

                        if not lowestdiff or lowestdiff > diff then
                            lowestdiff = diff
                            lowestent = ent
                        end                        
                    end

                    target = lowestent
                end
            end

			if target then
                local dist = inst:GetDistanceSqToInst(target)

                if dist<CLOSERANGE*CLOSERANGE then

                    local blast = SpawnPrefab("willow_shadow_fire_explode")
                    local pos = Vector3(target.Transform:GetWorldPosition())
                    blast.Transform:SetPosition(pos.x,pos.y,pos.z)

                    local weapon = inst

                    source.components.combat.ignorehitrange = true
                    source.components.combat.ignoredamagereflect = true

                    source.components.combat:DoAttack(target, weapon)

                    source.components.combat.ignorehitrange = false
                    source.components.combat.ignoredamagereflect = false

                    theta = nil
                else
                    local pt = Vector3(target.Transform:GetWorldPosition())
                    local angle = inst:GetAngleToPoint(pt.x,pt.y,pt.z)
                    local anglediff = angle - inst.Transform:GetRotation()
                    if anglediff > 180 then
                        anglediff = anglediff - 360
                    elseif anglediff < -180 then
                        anglediff = anglediff + 360
                    end
                    if math.abs(anglediff) > maxdeflect then
                        anglediff = math.clamp(anglediff, -maxdeflect, maxdeflect)
                    end

                    theta = (inst.Transform:GetRotation() + anglediff) * DEGREES
                end
            else
                if not inst.currentdeflection then
                    inst.currentdeflection = {time = math.random(1,10), deflection = maxdeflect * ((math.random() *2)-1) }
                end
                inst.currentdeflection.time = inst.currentdeflection.time -1
                if inst.currentdeflection.time then
                    inst.currentdeflection = {time = math.random(1,10), deflection = maxdeflect * ((math.random() *2)-1) }
                end

                theta =  (inst.Transform:GetRotation() + inst.currentdeflection.deflection) * DEGREES
            end

            if theta  then
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                local newpos = Vector3(inst.Transform:GetWorldPosition()) + offset
                local newangle = inst:GetAngleToPoint(newpos.x,newpos.y,newpos.z)

                local fire = SpawnPrefab("willow_shadow_flame")
                fire.Transform:SetRotation(newangle)
                fire.Transform:SetPosition(newpos.x,newpos.y,newpos.z)
                fire:settarget(target,life-1, source)
            end
        end)

    end
end

local function shadowfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("shadow_fire_fx")
    inst.AnimState:SetBuild("shadow_fire_fx")
    inst.AnimState:PlayAnimation("anim"..math.random(1,3),false)

    inst.AnimState:SetMultColour(0, 0, 0, .6)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("willow_shadow_flame")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("firefx")
    inst.components.firefx.levels = shadowfirelevels

    inst.components.firefx:SetLevel(math.random(1,4))

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.WILLOW_LUNAR_FIRE_DAMAGE * 3)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.WILLOW_LUNAR_FIRE_PLANAR_DAMAGE * 3)


    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WILLOW_SHADOW_FIRE_BONUS)


    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("anim1") or inst.AnimState:IsCurrentAnimation("anim2") or inst.AnimState:IsCurrentAnimation("anim3") then
            inst:Remove()
        end
    end)

    inst.settarget = settarget

    return inst
end

local function throwfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("flamethrow_fx")
    inst.AnimState:SetBuild("flamethrow_fx")
    inst.AnimState:PlayAnimation("pre",false)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("firefx")
    inst.components.firefx.levels = throwfirelevels

    inst.components.firefx:SetLevel(1)
    inst:DoTaskInTime(10/30,function()
            local x,y,z= inst.Transform:GetWorldPosition()
            SpawnPrefab("deerclops_laserscorch").Transform:SetPosition(x, 0, z)
    end)

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("pre") then
            inst:Remove()
        end
    end)

    return inst
end

---- FRENZY

local function FrenzyOnUpdate(inst,dt)
    local rate = 15
    local rot = inst.Transform:GetRotation()

    inst.Transform:SetRotation(rot + (rate * dt))
end

local FRENZY_SCALE = 0.85

local function AddFrenzyFX()
    local inst = CreateEntity()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("frenzy_fx")
    inst.AnimState:SetBuild("frenzy_fx")
    inst.AnimState:PlayAnimation("pre", false)
    inst.AnimState:PlayAnimation("loop", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.AnimState:SetMultColour(1, 1, 1, 0.2)

    inst.Transform:SetScale(FRENZY_SCALE, FRENZY_SCALE, FRENZY_SCALE)

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(FrenzyOnUpdate)

    return inst
end

local function FrenzyDoOnClientInit(inst)
    inst.fx = AddFrenzyFX()

    inst:AddChild(inst.fx)
end

local function OnFrenzyKilled(inst)
    if inst.fx ~= nil then
        inst.fx.AnimState:PlayAnimation("post")
    end

    if TheWorld.ismastersim then
        inst:DoTaskInTime(16 * FRAMES, inst.Remove)
    end
end

local function FrenzyKill(inst)
    inst._kill:push()
    inst:OnFrenzyKilled()
end

local function frenzyfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst._kill = net_event(inst.GUID, "willow_frenzy._kill", "killdirty")

    inst.OnFrenzyKilled = OnFrenzyKilled
    inst.FrenzyDoOnClientInit = FrenzyDoOnClientInit

    -- Dedicated server does not need the fx.
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("killdirty", inst.OnFrenzyKilled)

        inst:FrenzyDoOnClientInit()
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Kill = FrenzyKill

    inst.persists = false

    return inst
end

return Prefab("willow_shadow_flame", shadowfn, shadowassets, prefabs),
       Prefab("willow_throw_flame", throwfn, throwassets, prefabs),
       Prefab("willow_frenzy", frenzyfn, frenzyassets)
