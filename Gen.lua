--Version 1.1.0
--Made by Kris (xXxKrisstalDragonxXx)
--[[
	See my API on github for more info
	Now has autofill
	More parameters for generation time provided
]]
--Biomes table example:
--[[

{
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
	
}

]]

local module = {}

--Variables

local RunService = game:GetService("RunService");
local IcosphereInformation = require(script.IcosphereInformation);
local Draw3DTriangle = require(script.Draw3DTriangle);
local Vertices = IcosphereInformation[2];
local TriSet = IcosphereInformation[1];
local BaseVertices = IcosphereInformation[6]
local ThreeDNoise = require(script.PerlinNoise);
local WeldingM = require(script.Weld)

--Functions

local function SetProperties(Object, Properties)
	for Property, Value in pairs(Properties) do
		Object[Property] = Value;
	end;
end;

local GetMedian = function(Position1, Position2)
	return (Position1 + Position2) / 2;
end;

local GetCentre = function()
	local Median = Vertices[1];
	for _, Vertice in pairs(Vertices) do
		Median = GetMedian(Median, Vertice);
	end;
	return Median;
end;

local function countTable(tab)
	local i = 0
	for _, _ in pairs(tab) do
		i += 1
	end
	return i
end

local function findIndex(tab, tofind)
	for i, v in pairs(tab) do
		if i == tofind then return v end
	end
end

local function fromNumber(tab, num)
	local i2 = 0
	for i, v in pairs(tab) do
		i2 += 1
		if i2 == num then return v end
	end
end

local function autofill(v, auto)
	if v == nil then return auto
	else return v end
end

local function getns(pos:Vector3, rad:number, deform:Vector3)
	local c = GetCentre()
	local unit = (pos-c).Unit
	--local def = unit*rad*deform
	local diff = (pos - c).Magnitude * (unit / deform).Magnitude / rad-1
	return diff*1000
end

--Module functions

function GenerationDone(Planet:Model,Biomes,LoadingSpeed,Pars)
	--Filling the biomes' parameters if not set
	for i, v in pairs(Biomes) do
		if not v.Min or not v.Max then --PLEASE CONSIDER TO SET MIN AND MAX THIS THING IS SMTH
			v.Min = math.random(400, 550) / 1000
			local biome
			repeat
				biome = fromNumber(Biomes, math.random(1, countTable(Biomes)))
			until biome ~= v
			if findIndex(biome, "Max") then v.Min = biome.Max end
			v.Max = 0
			for i2, v2 in pairs(Biomes) do
				if not v2["Min"] then continue end
				if v2.Min > v.Min then v.Max = v2.Min end
			end
			if v.Max == 0 then v.Max = math.random(v.Min * 1000, 600) / 1000 end
		end
		if not v.Weight then
			v.Weight = math.random(1, countTable(Biomes))
		end
	end
	local function randomize(num)--randomize the color
		num *= (math.random(98, 102) / 100)
		num = math.clamp(num, 0, 1)
		return num
	end
	local function rBiome()--random biome
		local rand = math.random(1, countTable(Biomes))
		local i2 = 0
		for i, v in pairs(Biomes) do
			i2 += 1
			if i2 == rand then
				return i
			end
		end
	end
	--Painting
	local Triangles: {WedgePart} = Planet:GetChildren()
	local completed = 0
	local function pastpart(imin, imax)
		for i=imin, imax do
			local Triangle = Triangles[i]
			local Noise = getns(Triangle.Position, Pars.Gen.Radius, Pars.Gen.Deform)-- / (500 * (Pars.Gen.Radius / 1000));
			local material, weight, color = nil, 0, Color3.new(0, 0, 0)
			for i2, v in pairs(Biomes) do
				if Noise > v.Min and Noise < v.Max then
					if v.Weight > weight then
						material = v.Material :: Enum.Material
						weight = v.Weight
						color = v.Color
					end
				end
			end
			if not material then--a random biome. If your don't fill the min and max then random can't even assign it properly so we result in a random biome
				local biome = rBiome()
				color = Biomes[biome].Color
				material = Biomes[biome].Material
			end
			Triangle.Color = Color3.new(randomize(color.R),randomize(color.G),randomize(color.B))
			Triangle.Material = material
			Triangle.Name = Noise
			completed += 1
			if i % (LoadingSpeed * 2) == 0 then task.wait() end
		end;
	end
	local partcount: number = Pars.Gen.TerrainCoroutines
	local part = math.ceil(#Triangles/partcount)
	for i=1, partcount do
		if i == partcount then
			coroutine.wrap(pastpart)(part*(i-1) + 1, #Triangles)
		else
			coroutine.wrap(pastpart)(part*(i-1) + 1, part*i)
		end
	end
	repeat
		task.wait()
		if Pars.PrintStatus then print("Painting: "..completed.."/"..#Triangles) end
	until completed == #Triangles
	task.wait()
	--creating the core
	local core = Instance.new("Part")
	SetProperties(core, {
		Size = Vector3.new(1, 1, 1),
		Material = Enum.Material.CrackedLava,
		Anchored = Pars.Gen.IsAnchored,
		Name = "Core",
		Position = GetCentre(),
		Parent = Planet,
		Color = Color3.fromRGB(255, 0, 0)
	})
	task.wait()
	local coreMesh = game.ReplicatedStorage.Assets.BallMesh:Clone();
	SetProperties(coreMesh, {
		Scale = Vector3.new(1, 1, 1) * (Pars.Gen.Radius * 0.75);
		Parent = core;
	});
	task.wait()
	Planet.PrimaryPart = core
	--creating the sea
	if Pars.Sea.Radius > 0 then
		task.wait()
		local Water = Instance.new("Part");
		SetProperties(Water, {
			Color = Pars.Sea.Color;
			Material = Pars.Sea.Material;
			Size = Vector3.new(1, 1, 1);
			Position = GetCentre();
			Name = "Sea";
			CastShadow = false;
			Transparency = Pars.Sea.Transparency;
			CanCollide = false;
			Anchored = false;
			Parent = Planet;
		});
		task.wait()
		local Mesh = game.ReplicatedStorage.Assets.BallMesh:Clone();
		SetProperties(Mesh, {
			Scale = Vector3.new(1, 1, 1) * Pars.Gen.Deform * Pars.Sea.Radius * 2;
			Parent = Water;
		});
		task.wait()
		local Weld = Instance.new("WeldConstraint")
		SetProperties(Weld, {
			Part0 = Planet.PrimaryPart;
			Part1 = Water;
			Parent = Planet.PrimaryPart;
			Name = "SeaWeld"
		});
	end
	--welding
	local wtype = Pars.Gen.WeldingType
	if wtype > 0 then
		local parts = {}
		for i, v in pairs(Planet:GetChildren()) do
			if v:IsA("WedgePart") then table.insert(parts, v) end
		end
		if wtype == 1 then
			WeldingM.RandomWeld(parts, core, 100, Pars.PrintStatus)
		elseif wtype == 2 then
			WeldingM.PartsWeld(parts, core, 100, LoadingSpeed, Pars.PrintStatus)
		end
	else
		for i, v: WedgePart in pairs(Planet:GetChildren()) do
			if not v:IsA("WedgePart") then continue end
			v.Transparency = 0
			v.CanCollide = true
		end
	end
	
	Planet:PivotTo(CFrame.new(Pars.Gen.Position))
	
	if Pars.PrintStatus then print("Completed") end
	--And done!
end;

function Awake(Planet,Pars,Biomes)
	--Importing variables from Parameters
	
	local res, rad = Pars.Gen.Resolution, Pars.Gen.Radius
	local nstab = Pars.Noise
	local mountmod, ndiv, ampl, octs, pers = nstab.MountainsMod, nstab.NoiseDivider, nstab.Amplitude, nstab.Octaves, nstab.Persistence
	local mountfrom = nstab.MountainsFrom
	local issmooth = Pars.Gen.IsSmoothSubdivide
	
	local Triangles = {};
	
	for Index, Tris in pairs(TriSet) do
		local Corners = {1};

		for Index, VerticeNumber in pairs(Tris) do
			local Vertice = Vertices[VerticeNumber +1];

			Corners[Index] = Vertice * rad;
		end;

		table.insert(Triangles, Corners);
	end;
	
	local GetLatitudeAndLongitude = function(Center, Point)
		local dir = (Point-Center).Unit;
		local up = Vector3.new(0,1,0);
		local right = Vector3.new(1,0,0);

		local longitude = math.deg(math.acos(up:Dot(dir)));
		local latitude = math.deg(math.atan2(dir.Z,dir.X));

		return Vector2.new(latitude,longitude);
	end;

	local Centre = GetCentre();
	local function Subdivide(Amount, IsSmooth)
		local deform = Pars.Gen.Deform
		for i = 1, Amount do
			local NewTriangles = {};
			for Index, Triangle in pairs(Triangles) do
				local Corners = {};
				for Index, Vertice in pairs(Triangle) do
					Corners[Index] = Vertice;
				end;

				--| Replace triangle by 4 triangles
				local A: Vector3 = GetMedian(Corners[1], Corners[2]);
				local B: Vector3 = GetMedian(Corners[2], Corners[3]);
				local C: Vector3 = GetMedian(Corners[3], Corners[1]);
				
				if IsSmooth then
					A = (A-Centre).Unit*rad
					B = (B-Centre).Unit*rad
					C = (C-Centre).Unit*rad
				end

				table.insert(NewTriangles, {Corners[1]; A, C;});
				table.insert(NewTriangles, {Corners[2]; B, A;});
				table.insert(NewTriangles, {Corners[3]; C, B;});
				table.insert(NewTriangles, {A; B; C;});
			end;

			Triangles = NewTriangles;
			
			task.wait()
			if Pars.PrintStatus then print("Subdivide: "..i) end
		end;
	end;
	
	Subdivide(res, issmooth);
	
	--Applying noise
	local deform = Pars.Gen.Deform
	for Index, Tris in pairs(Triangles) do
		for Index, Vertice in pairs(Tris) do
			local unit = (Vertice - Centre).Unit
			Tris[Index] = unit*deform*rad
			local Vertice = Tris[Index]
			local LatitudeAndLongitude = GetLatitudeAndLongitude(GetCentre(), Vertice) / ndiv;
			local ns = ThreeDNoise.new({LatitudeAndLongitude.X; LatitudeAndLongitude.Y;Pars.Noise.Seed}, ampl, octs, pers);
			local Dir = (Vertice - GetCentre());
			--[[if getns(Vertice, rad, deform) >= mountfrom then
				Vertice += Vector3.new(0, Vertice.Y * 0.10 * mountmod, 0);
			end;]]
			if ns > mountfrom then ns *= mountmod end
			--local ns = 0
			Tris[Index] = Vertice + (Dir * (ns * 0.10));
		end;
		if Index % 2500 == 0 then task.wait()
			if Pars.PrintStatus then print("Generating: "..Index.."/"..#Triangles) end
		end
	end;
	local LoadingSpeed = Pars.Gen.LoadingSpeed
	local completed = 0
	local function pastpart(imin, imax)
		for i=imin, imax do
			local Triangle = Triangles[i]
			local w1, w2 = Draw3DTriangle(Triangle[1], Triangle[2], Triangle[3], Planet);
			completed += 1
			if i % math.round(LoadingSpeed / 4) == 0 then task.wait() end
		end;
	end
	local partcount: number = Pars.Gen.TerrainCoroutines
	local part = math.ceil(#Triangles/partcount)
	for i=1, partcount do
		if i == partcount then
			coroutine.wrap(pastpart)(part*(i-1) + 1, #Triangles)
		else
			coroutine.wrap(pastpart)(part*(i-1) + 1, part*i)
		end
	end
	repeat
		task.wait()
		if Pars.PrintStatus then print("Pasting: "..completed.."/"..#Triangles) end
	until completed == #Triangles
	GenerationDone(Planet,Biomes,LoadingSpeed,Pars);
end;

function module.GenerateSpaceObject(Name:string,Pars:{},Biomes:{},Parent:Instance)
	local obj = Instance.new("Model")
	obj.Name = Name
	obj.Parent = Parent
	local noise, sea, gen = Pars.Noise, Pars.Sea, Pars.Gen
	noise.Amplitude = autofill(noise.Amplitude, 5) :: number
	noise.Persistence = autofill(noise.Persistence, 0.5) :: number
	noise.Octaves = autofill(noise.Octaves, 10) :: number
	noise.MountainsMod = autofill(noise.MountainsMod, 1) :: number
	noise.MountainsFrom = autofill(noise.MountainsFrom, 0) :: number
	noise.NoiseDivider = autofill(noise.NoiseDivider, 5) :: number
	noise.Seed = autofill(noise.Seed, 0.148) :: number
	sea.Material = autofill(sea.Material, Enum.Material.SmoothPlastic) :: Enum.Material
	sea.Transparency = autofill(sea.Transparency, 0.68) :: number
	gen.WeldingType = autofill(gen.WeldingType, 0) :: boolean
	gen.IsSmoothSubdivide = autofill(gen.IsSmoothSubdivide, true) :: boolean
	gen.IsAnchored = autofill(gen.IsAnchored, true) :: boolean
	gen.TerrainCoroutines = autofill(gen.TerrainCoroutines, 4) :: number
	gen.LoadingSpeed = autofill(gen.LoadingSpeed, 800) :: number
	Pars.PrintStatus = autofill(Pars.PrintStatus, false) :: boolean
	Awake(obj,Pars,Biomes)
end

return module
