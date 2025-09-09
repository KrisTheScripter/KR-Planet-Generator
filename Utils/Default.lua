return {
	Noise = {
		Offset = 0.05,
		Amplitude = 13,
		Smoothness = 7,
		MountainsModifier = 5,
		MountainsStart = 45,
	},
	Sea = {
		Radius = 205,
		Color = Color3.fromRGB(52, 106, 255),
		Transparency = 0.65,
		Material = Enum.Material.SmoothPlastic
	},
	Gen = {
		Resolution = 5,
		Radius = 200,
		WeldingType = "Default",
		LoadingSpeed = 1000,
		IsSmoothSubdivide = false,
		IsAnchored = true,
		Position = Vector3.new(0, 0, 0),
		TerrainCoroutines = 1,
		Deform = Vector3.new(1, 1, 1)
	},
	PrintStatus = true
}