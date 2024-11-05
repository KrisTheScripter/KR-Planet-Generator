# Customizable Planet Procedural Generator
Planet generator originally made by Fenix7667 on Roblox and modified by Kris (xXxKrisstalDragonxXx) 

# How to use:
```lua
require(script.Parent.CustomPlanetGenerator.Gen).GenerateSpaceObject("Earth", {
	Noise = {
		Amplitude = 3,
		Persistence = 0.5,
		Octaves = 20,
		MountainsMod = 1.5,
		MountainsFrom = 0.45,
		NoiseDivider = 7,
		Seed = 0.148
	},
	Sea = {
		Radius = 5080,
		Color = Color3.fromRGB(52, 106, 255),
		Transparency = 0.65,
		Material = Enum.Material.SmoothPlastic
	},
	Gen = {
		Resolution = 7,
		Radius = 5000,
		Weld = false,
		IsSmoothSubdivide = true,
		IsAnchored = true,
		Coroutines = 100,
		Position = Vector3.new(0, 0, 0)
	},
	PrintStatus = true
}, {
	Sand = {
		Material = Enum.Material.Sand,
		Color = Color3.fromRGB(109, 93, 0),
		Min = 0.48,
		Max = 0.505
	},
	Grass = {
		Material = Enum.Material.Grass,
		Color = Color3.fromRGB(0, 130, 4),
		Min = 0.505,
		Max = 0.53
	},
	Rocky = {
		Material = Enum.Material.Rock,
		Color = Color3.fromRGB(94, 94, 94),
		Min = 0.53,
		Max = 0.545
	},
	Mountain = {
		Material = Enum.Material.Snow,
		Color = Color3.fromRGB(255, 255, 255),
		Min = 0.545,
		Max = 1
	},
	Deep = {
		Material = Enum.Material.Granite,
		Color = Color3.fromRGB(121, 121, 121),
		Min = 0,
		Max = 0.48
	}
	
}, 1000, game.Workspace)
```
You can also read my comments in the code
