local function OnAmmoLoaded(inst)
	inst.AnimState:HideSymbol("cannon_flap_up")
	inst.AnimState:ShowSymbol("cannon_flap_down")
end

local function OnAmmoUnloaded(inst)
	inst.AnimState:ShowSymbol("cannon_flap_up")
	inst.AnimState:HideSymbol("cannon_flap_down")
end

local events =
{
	EventHandler("ammoloaded", OnAmmoLoaded),
	EventHandler("ammounloaded", OnAmmoUnloaded),
}

local dummyfn = function() end
local OverrideLoadedAmmoEvent = EventHandler("loadedammo", dummyfn)
local OverrideUnloadedAmmoEvent = EventHandler("unloadedammo", dummyfn)

local function RefreshAmmoState(inst)
	if inst.components.boatcannon:IsAmmoLoaded() then
		OnAmmoLoaded(inst)
	else
		OnAmmoUnloaded(inst)
	end
end

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
        end,
    },

    State{
        name = "load",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("load")
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("monkeyisland/cannon/load")
				OnAmmoLoaded(inst)
            end),
        },

        events =
        {
			OverrideLoadedAmmoEvent,
			OverrideUnloadedAmmoEvent,
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

		onexit = RefreshAmmoState,
    },

    State{
        name = "shoot",
        tags = { "busy", "shooting" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("shoot")
            inst.SoundEmitter:PlaySound("monkeyisland/cannon/shoot")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.components.boatcannon:Shoot()
            end),
			TimeEvent(10 * FRAMES, OnAmmoUnloaded),
        },

        events =
        {
			OverrideLoadedAmmoEvent,
			OverrideUnloadedAmmoEvent,
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

		onexit = RefreshAmmoState,
    },

    State{
        name = "place",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("monkeyisland/cannon/place")
            inst.AnimState:PlayAnimation("place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst, light)
            inst.SoundEmitter:PlaySound("monkeyisland/cannon/hit")
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

return StateGraph("boatcannon", states, events, "idle")
