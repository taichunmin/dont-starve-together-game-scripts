--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------
local easing = require("easing")


--------------------------------------------------------------------------
--[[ BaseHassler class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "MooseSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------

local _moosedensity = TUNING.MOOSE_DENSITY --This number is what % of nests in the world the moose will occupy.
local _seasonalnests = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function FindNests()
	local nests = {}

	for k,v in pairs(Ents) do
		if v.prefab == "moose_nesting_ground" then
			table.insert(nests, v)
		end
	end

	return nests
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:OverrideAttackDensity(density)
	--depreciated
end

function self:DoSoftSpawn(nest)
	--Spawn the moose and let it act out laying an egg etc.
	nest.mooseIncoming = false
	local spawnpt = nest:GetPosition()
	spawnpt.y = spawnpt.y + 30
	local moose = SpawnPrefab("moose")
	moose.Transform:SetPosition(spawnpt:Get())
	moose.sg:GoToState("glide")
	moose.components.timer:StartTimer("WantsToLayEgg", TUNING.SEG_TIME * math.random(4, 8))

	nest.components.timer:StopTimer("CallMoose")
end

function self:DoHardSpawn(nest)

	nest.mooseIncoming = false

	local spawnpt = nest:GetPosition()

	local egg = SpawnPrefab("mooseegg")
	egg.Transform:SetPosition(spawnpt:Get())

	local offset = FindWalkableOffset(egg:GetPosition(), math.random() * 2 * math.pi, 4, 12) or Vector3(0,0,0)

	local moose = SpawnPrefab("moose")
	local pt = offset + egg:GetPosition()
	moose.Transform:SetPosition(pt:Get())

	moose.components.entitytracker:TrackEntity("egg", egg)
	egg.components.entitytracker:TrackEntity("mother", moose)
	egg:InitEgg()
end

function self:InitializeNest(nest)
	nest.components.timer:StartTimer("CallMoose", TUNING.SEG_TIME * math.random(8, 24))
	nest.mooseIncoming = true
end

function self:InitializeNests()
	--print("MooseSpawner - InitializeNests")
	local nests = FindNests()
	local num_to_spawn = math.ceil(#nests * _moosedensity)
	_seasonalnests = PickSome(num_to_spawn, nests)

	for _, nest in ipairs(_seasonalnests) do
		self:InitializeNest(nest)
	end
end

local function OnSpringChange(inst, isSpring)
	if isSpring and TheWorld.state.cycles > TUNING.NO_BOSS_TIME then
		self:InitializeNests()
	end
end

self.inst:WatchWorldState("isspring", OnSpringChange)

end)
