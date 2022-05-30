local events =
{

}

local function SpawnFragment(lp, prefix, offset_x, offset_y, offset_z, ignite)
    local fragment = SpawnPrefab(prefix)
    fragment.Transform:SetPosition(lp.x + offset_x, lp.y + offset_y, lp.z + offset_z)

    if offset_y > 0 then
        local physics = fragment.Physics
        if physics ~= nil then
            physics:SetVel(0, -0.25, 0)
        end
    end

	if ignite then
		fragment.components.burnable:Ignite()
	end

	return fragment
end

local states =
{
    State{
        name = "place",
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/place")
            inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/large",nil,.3)
            inst.AnimState:PlayAnimation("place")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "idle",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_full", true)
        end,

        events =
        {
            EventHandler("death", function(inst) inst.sg:GoToState("ready_to_snap") end),
        },
    },

    State{
        name = "ready_to_snap",
        onenter = function(inst)
            inst.sg:SetTimeout(0.75)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("snapping")
        end,
    },


    State{
        name = "snapping",
        onenter = function(inst)
            local fx_boat_crackle = SpawnPrefab("fx_boat_crackle")
            fx_boat_crackle.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.AnimState:PlayAnimation("crack")
            inst.sg:SetTimeout(1)

            for k in pairs(inst.components.walkableplatform:GetPlayersOnPlatform()) do
                k:PushEvent("onpresink")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("popping") end),
        },

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/creak")
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage",{intensity= .1})
            end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage",{intensity= .2})
            end),
            TimeEvent(32* FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage",{intensity= .3})
            end),
            TimeEvent(39* FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage",{intensity= .3})
            end),
            TimeEvent(39* FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/creak")
            end),
            TimeEvent(51 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage",{intensity= .4})
            end),
            TimeEvent(58 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage",{intensity= .4})
            end),
            TimeEvent(60 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage",{intensity= .5})
            end),
            TimeEvent(71 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage",{intensity= .5})
            end),
            TimeEvent(75 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage", {intensity= .6})
            end),
            TimeEvent(82 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage", {intensity= .6})
            end),
        },
    },

    State{
        name = "popping",
        onenter = function(inst)
            local fx_boat_crackle = SpawnPrefab("fx_boat_pop")
            fx_boat_crackle.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage", {intensity= 1})
            inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/sink")

            local ignitefragments = inst.activefires > 0
            local locus_point = Vector3(inst.Transform:GetWorldPosition())

            inst:Remove()
			local num_loot = 3
			for i = 1, num_loot do
				local r = math.sqrt(math.random())*2 + 1.5
				local t = i * PI2/num_loot + math.random() * (PI2/(num_loot * .5))
	            SpawnFragment(locus_point, "boards",  math.cos(t) * r,  0, math.sin(t) * r, ignitefragments)
			end
        end,
    },
}

return StateGraph("boat", states, events, "idle")
