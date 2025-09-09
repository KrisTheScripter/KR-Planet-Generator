local module = {}

export type Parameters = {
	Noise:{
		Offset:number,
		Amplitude:number,
		Smoothness:number,
		MountainsModifier:number,
		MountainsStart:number
	},
	Sea:{
		Radius:number,
		Color:Color3,
		Transparency:number,
		Material:Enum.Material|string
	},
	Gen:{
		Resolution:number,
		Radius:number,
		WeldingType:string,
		LoadingSpeed:number,
		IsSmoothSubdivide:boolean,
		IsAnchored:boolean,
		Position:Vector3,
		TerrainCoroutines:number,
		Deform:Vector3
	},
	PrintStatus:boolean
}

export type Biome = {
	Name:string,
	Color:Color3,
	Material:Enum.Material,
	Weight:number,
	IsValid:(Biome, any)->(boolean)
}

return module