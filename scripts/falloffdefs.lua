local TileManager = require("tilemanager")

mod_protect_TileManager = false

TileManager.AddFalloffTexture(
    FALLOFF_IDS.FALLOFF,
    {
        name = "falloff",
        noise_texture = "images/square.tex",
        should_have_falloff = TileGroups.LandTilesWithDefaultFalloff,
        should_have_falloff_result = true,
        neighbor_needs_falloff = TileGroups.LandTilesWithDefaultFalloff,
        neighbor_needs_falloff_result = false
    }
)

TileManager.AddFalloffTexture(
    FALLOFF_IDS.DOCK_FALLOFF,
    {
        name = "dock_falloff",
        noise_texture = "images/square.tex",
        should_have_falloff = TileGroups.DockTiles,
        should_have_falloff_result = true,
        neighbor_needs_falloff = TileGroups.TransparentOceanTiles,
        neighbor_needs_falloff_result = true
    }
)

TileManager.AddFalloffTexture(
    FALLOFF_IDS.OCEANICE_FALLOFF,
    {
        name = "oceanice_falloff",
        noise_texture = "images/square.tex",
        should_have_falloff = TileGroups.OceanIceTiles,
        should_have_falloff_result = true,
        neighbor_needs_falloff = TileGroups.TransparentOceanTiles,
        neighbor_needs_falloff_result = true,
    }
)

TileManager.AddFalloffTexture(
    FALLOFF_IDS.INVISIBLE,
    {
        name = "invisible_falloff",
        noise_texture = "images/square.tex",
        should_have_falloff = TileGroups.LandTilesInvisible,
        should_have_falloff_result = true,
        neighbor_needs_falloff = TileGroups.LandTilesWithDefaultFalloff,
        neighbor_needs_falloff_result = true,
    }
)

mod_protect_TileManager = true