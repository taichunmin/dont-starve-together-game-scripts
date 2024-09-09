-- See consolecommands.lua c_guitartab() function for example use.

--

local m = -1

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------

-- Standard tuning:			E2, A2, D3, G3, B3, E4
local tuning =			{	29,	34,	39,	44,	48,	53	}

local transposition = 8
local spacing_multiplier = 2.25

local tab =
{
	--	E	A	D	G	B	e
	------------------------------
	{	m,	2,	m,	4,	m,	m	},
	m,
	{	2,	m,	m,	m,	m,	2	},
	m,
	{	m,	2,	m,	4,	m,	m	},
	m,									{	m,	m,	m,	m,	m,	2, t=.33	},		{	m,	m,	m,	m,	m,	3, t=.66	},
	{	2,	m,	m,	m,	m,	2	},
	m,
	--
	{	m,	2,	m,	4,	m,	m	},
	m,
	{	m,	2,	m,	m,	3,	m	},		{	m,	m,	m,	4,	m,	m, t=.66	},
	m,									{	m,	m,	m,	1,	m,	m, t=.33	},
	{	m,	m,	4,	3,	m,	m	},
	m,
	{	m,	4,	m,	m,	m,	m	},		{	m,	m,	5,	m,	m,	m, t=.66	},
	m,									{	m,	m,	4,	m,	m,	m, t=.33	},
	--
	{	m,	2,	m,	4,	m,	m	},
	m,									{	m,	m,	m,	m,	3,	m, t=.33	},		{	m,	4,	m,	m,	m,	m, t=.66	},
	{	m,	m,	0,	m,	m,	2	},
	m,									{	m,	m,	m,	m,	3,	m, t=.33	},
	{	3,	m,	m,	m,	m,	3	},
	m,									{	m,	m,	m,	m,	m,	0, t=.33	},
	{	0,	m,	m,	m,	0,	m	},
	m,
	--
	{	2,	m,	m,	m,	3,	m	},
	m,
	{	m,	4,	m,	6,	m,	m	},
	m,									{	6,	m,	m,	7,	m,	m, t=.33	},
	{	7,	m,	9,	m,	m,	m	},
	m,
	m,
	m,
}

return { tuning = tuning, transposition = transposition, tab = tab, spacing_multiplier = spacing_multiplier }